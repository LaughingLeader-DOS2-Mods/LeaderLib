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
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)

	if self.Action then
		self.Thread = coroutine.create(self.Action)
	end
    return this
end

function SceneStateData:Resume(...)
	print("SceneStateData:Resume", self.Parent.ID, self.ID, ...)
	if not self.Thread and self.Action then
		self.Thread = coroutine.create(self.Action)
	end
	if self.Thread and self:GetStatus() ~= "running" then
		self.Active = true
		coroutine.resume(self.Thread, self, ...)
		self.Parent:StateDone(self, ...)
		return true
	end
end
function SceneStateData:CanResume(...)
	if self.CanResumeCallback then
		return self.CanResumeCallback(...)
	end
	return true
end

function SceneStateData:Pause()
	if self.Thread then
		coroutine.yield()
		self.Active = coroutine.status(self.Thread) ~= "running"
		return true
	end
	return false
end

---@return string
function SceneStateData:GetStatus()
	if self.Thread then
		return coroutine.status(self.Thread)
	end
	return "dead"
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
		if self:Pause() then
			SceneManager.AddToQueue("StoryEvent", self.Parent.ID, self.ID, event, character)
			--CharacterMoveToPosition(character, x, y, z, running or true, event)
			Osi.ProcCharacterMoveToPosition(character, x, y, z, running or true, event)
		end
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
		if self:Pause() then
			SceneManager.AddToQueue("StoryEvent", self.Parent.ID, self.ID, event, character)
			Osi.ProcCharacterMoveTo(character, target, running or true, event)
		end
	end
	return true
end

---@param timeInMilliseconds integer How long to wait in milliseconds.
function SceneStateData:Wait(timeInMilliseconds)
	SceneManager.AddToQueue("Waiting", self.Parent.ID, self.ID, timeInMilliseconds)
	return self:Pause()
end

Classes.SceneStateData = SceneStateData