---@alias SceneStateActionCallback fun(self:SceneStateData):void

---@class SceneStateData
local SceneStateData = {
	Type = "SceneStateData",
	---@type SceneData
	Parent = nil,
	ID = "",
	---@type SceneStateActionCallback
	Action = nil,
	---@type thread
	Thread = nil,
	Active = false,
	---@type fun():boolean
	CanResumeCallback = nil,
	--If the distance between a character and position are less than this, movement is skipped.
	MoveDistanceThreshold = 0.5
}
SceneStateData.__index = SceneStateData

---@param self SceneStateData
local function RunAction(self, ...)
	if self.Action then
		local b,err = xpcall(self.Action, debug.traceback, self, ...)
		if not b then
			Ext.PrintError(err)
		end
	end
	if self.Parent then
		self.Parent:StateDone(self, ...)
	end
end

---@param id string
---@param action SceneStateActionCallback
---@param params table<string,any>
---@return SceneStateData
function SceneStateData:Create(id, action, params)
	local this =
	{
		ID = id or "",
		Parent = nil,
		Action = action or nil,
		Active = false
	}
	this.Thread = coroutine.create(RunAction)
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)

	return this
end

function SceneStateData:Resume(...)
	print("SceneStateData:Resume", self.Parent.ID, self.ID, self.Action, self.Thread, self:GetStatus())
	if not self.Thread or self:GetStatus() == "dead" then
		self.Thread = coroutine.create(RunAction)
	end
	if self.Thread and self:GetStatus() ~= "running" then
		self.Active = true
		coroutine.resume(self.Thread, self, ...)
		return true
	end
	self.Active = self:GetStatus() == "running"
	return self.Active
end
function SceneStateData:CanResume(...)
	if self.CanResumeCallback then
		return self.CanResumeCallback(...)
	end
	return true
end

function SceneStateData:Pause()
	local doYield = self.Thread and coroutine.running() == self.Thread
	print("SceneStateData:Pause", self.Active, self:GetStatus())
	if doYield then
		self.Active = false
		coroutine.yield()
	else
		self.Active = self:GetStatus() == "running"
	end
	return self.Active
end

---@return string
function SceneStateData:GetStatus()
	if self.Thread then
		return coroutine.status(self.Thread)
	end
	return "nil"
end

---@param character string
---@param event string
---@param x number
---@param y number
---@param z number
---@param running boolean
function SceneStateData:MoveToPosition(character, event, x, y, z, running)
	character = StringHelpers.GetUUID(character)
	local dist = GetDistanceToPosition(character, x, y, z)
	if dist >= self.MoveDistanceThreshold then
		SceneManager.AddToQueue("StoryEvent", self.Parent.ID, self.ID, event, character)
		Osi.ProcCharacterMoveToPosition(character, x, y, z, running or true, event)
		self:Pause()
	end
	return true
end

---@param character string
---@param event string
---@param target string
---@param running boolean
function SceneStateData:MoveToObject(character, event, target, running)
	character = StringHelpers.GetUUID(character)
	local dist = GetDistanceTo(character, target)
	if dist >= self.MoveDistanceThreshold then
		SceneManager.AddToQueue("StoryEvent", self.Parent.ID, self.ID, event, character)
		Osi.ProcCharacterMoveTo(character, target, running or true, event)
		self:Pause()
	end
	return true
end

---@param timeInMilliseconds integer How long to wait in milliseconds.
function SceneStateData:Wait(timeInMilliseconds)
	SceneManager.AddToQueue("Waiting", self.Parent.ID, self.ID, timeInMilliseconds)
	if self:Pause() then
		return true
	end
	return false
end

Classes.SceneStateData = SceneStateData