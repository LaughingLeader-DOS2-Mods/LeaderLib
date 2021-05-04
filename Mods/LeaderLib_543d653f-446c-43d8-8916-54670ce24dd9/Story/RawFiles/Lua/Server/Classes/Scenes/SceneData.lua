local SceneStateData = Classes.SceneStateData

---@class SceneData
local SceneData = {
	Type = "SceneData",
	ID = "",
	---@type table<string, SceneStateData>
	States = {},
	---@type string[]
	StateOrder = {},
	CurrentState = "",
}
SceneData.__index = SceneData

---@param id string
---@param params table<string,any>
---@return SceneData
function SceneData:Create(id, params)
    local this =
    {
		ID = id or "",
		States = {},
	}
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)
    return this
end

---@param state SceneStateData
function SceneData:AddState(state)
	self.States[state.ID] = state
	self.StateOrder[#self.StateOrder+1] = state.ID
end

---@param id string
function SceneData:RemoveStateById(id)
	self.States[id] = nil
	for i,v in pairs(self.StateOrder) do
		if v == id then
			table.remove(self.StateOrder, i)
		end
	end
end

---@param id string
function SceneData:ResumeState(id, ...)
	local state = self.States[id]
	if state and state:CanResume(...) then
		state:Resume(...)
	end
end

function SceneData:Start(...)
	local id = self.StateOrder[1]
	if id then
		local state = self.States[id]
		if state then
			self.CurrentState = id
			state:Resume(...)
			return state
		end
	end
	return false
end

function SceneData:Next(...)
	local nextIndex = -1
	for i,v in pairs(self.StateOrder) do
		if v == self.CurrentState then
			nextIndex = i+1
			break
		end
	end
	local id = self.StateOrder[nextIndex]
	if id then
		local state = self.States[id]
		if state then
			self.CurrentState = id
			state:Resume(...)
			return state
		end
	end
	return false
end

---@param state SceneStateData
function SceneData:StateDone(state, ...)
	print("SceneData:StateDone", self.ID, state.ID, ...)
	self:Next(...)
end

Classes.SceneData = SceneData