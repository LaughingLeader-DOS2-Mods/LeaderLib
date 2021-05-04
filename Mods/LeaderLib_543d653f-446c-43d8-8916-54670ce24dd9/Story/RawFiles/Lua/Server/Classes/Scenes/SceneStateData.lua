---@class SceneStateData
local SceneStateData = {
	Type = "SceneStateData",
	---@type SceneData
	Parent = nil,
	ID = "",
	---@type fun(self:SceneStateData, ...):void
	Action = nil,
	---@type thread
	Thread = nil,
	Active = false,
	---@type fun():boolean
	CanResumeCallback = nil
}
SceneStateData.__index = SceneStateData

---@param parent SceneData
---@param id string
---@param params table<string,any>
---@return SceneStateData
function SceneStateData:Create(id, params)
    local this =
    {
		ID = id or "",
		Parent = nil,
		Action = nil,
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
	if self.Thread then
		self.Active = true
		coroutine.resume(self.Thread, self, ...)
		self.Parent:StateDone(self, ...)
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
	SceneManager.AddToQueue("StoryEvent", self.Parent.ID, self.ID, event)
	CharacterMoveToPosition(character, x, y, z, running or true, event)
	return self:Pause()
end

---@param timeInMilliseconds integer How long to wait in milliseconds.
function SceneStateData:Wait(timeInMilliseconds)
	SceneManager.AddToQueue("Waiting", self.Parent.ID, self.ID, timeInMilliseconds)
	return self:Pause()
end

Classes.SceneStateData = SceneStateData