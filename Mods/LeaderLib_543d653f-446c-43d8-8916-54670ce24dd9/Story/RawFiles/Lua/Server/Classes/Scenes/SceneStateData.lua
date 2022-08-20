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
			Ext.Utils.PrintError(err)
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
	PrintDebug("SceneStateData:Resume", self.Parent.ID, self.ID, self.Action, self.Thread, self:GetStatus())
	if not self.Thread or self:GetStatus() == "dead" then
		self.Thread = coroutine.create(RunAction)
	end
	if self.Thread and self:GetStatus() ~= "running" then
		self.Active = true
		local last,b = coroutine.running()
		if last and not b then
			SceneManager.LastThread = last
		end
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
	PrintDebug("SceneStateData:Pause", self.Active, self:GetStatus())
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
		SceneManager.AddToQueue(SceneManager.QueueType.StoryEvent, self.Parent.ID, self.ID, event, character)
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
		SceneManager.AddToQueue(SceneManager.QueueType.StoryEvent, self.Parent.ID, self.ID, event, character)
		Osi.ProcCharacterMoveTo(character, target, running or true, event)
		self:Pause()
	end
	return true
end

---@param timeInMilliseconds integer How long to wait in milliseconds.
function SceneStateData:Wait(timeInMilliseconds)
	PrintDebug("Waiting", timeInMilliseconds, "ms", self.Parent.ID, self.ID)
	SceneManager.AddToQueue(SceneManager.QueueType.Waiting, self.Parent.ID, self.ID, timeInMilliseconds)
	self:Pause()
	return true
end

---@param dialog string
---@param isAutomated boolean
---@vararg string
function SceneStateData:WaitForDialogEnd(dialog, isAutomated, ...)
	if isAutomated == nil then
		isAutomated = false
	end
	if not GameHelpers.IsInDialog(dialog, ...) then
		SceneManager.AddToQueue(SceneManager.QueueType.DialogEnded, self.Parent.ID, self.ID, dialog, isAutomated)
		Osi.Proc_StartDialog(isAutomated or false, dialog, ...)
		self:Pause()
		return true
	else
		local instance = GameHelpers.GetDialogInstance(dialog, ...)
		if instance ~= -1 then
			SceneManager.AddToQueue(SceneManager.QueueType.DialogEnded, self.Parent.ID, self.ID, dialog, isAutomated, instance)
			self:Pause()
			return true
		end
	end
	return false
end

---@param character string
---@param animation string
---@param event string
function SceneStateData:PlayAnimation(character, animation, event)
	if not event then
		event = "LLSSD_PA_" .. character .. animation
	end
	character = StringHelpers.GetUUID(character)
	SceneManager.AddToQueue(SceneManager.QueueType.StoryEvent, self.Parent.ID, self.ID, event, character)
	PlayAnimation(character, animation, event)
	self:Pause()
	return true
end

---@param signalName string
---@param timeout integer|nil
function SceneStateData:WaitForSignal(signalName, timeout)
	SceneManager.AddToQueue(SceneManager.QueueType.Signal, self.Parent.ID, self.ID, signalName, timeout)
	self:Pause()
	return true
end

Classes.SceneStateData = SceneStateData