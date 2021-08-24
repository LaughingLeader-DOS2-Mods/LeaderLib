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
	IsActive = false,
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
		StateOrder = {},
		IsActive = false,
		CurrentState = ""
	}
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)
    return this
end

---@param id string
---@param action SceneStateActionCallback
---@param params table<string,any>
---@return SceneStateData
function SceneData:CreateState(id, action, params)
	local state = SceneStateData:Create(id, action, params)
	self:AddState(state)
	return state
end

---@param state SceneStateData
function SceneData:AddState(state)
	state.Parent = self
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

---@param self SceneData
local function SetInactive(self)
	if SceneManager.ActiveScene.ID == self.ID then
		SceneManager.ActiveScene.ID = ""
		SceneManager.ActiveScene.State = ""
	end
	self.CurrentState = ""
	self.IsActive = false
end

---@param self SceneData
local function SetActive(self, state)
	self.CurrentState = state
	SceneManager.ActiveScene.ID = self.ID
	SceneManager.ActiveScene.State = state
	self.IsActive = true
end

---@param id string
function SceneData:Resume(id, ...)
	if id == nil and self.CurrentState == "" then
		id = self.StateOrder[1]
	end
	PrintDebug("SceneData:Resume", self.ID, id, ...)
	local state = self.States[id]
	if state and state:CanResume(...) then
		SetActive(self, id)
		return state:Resume(...)
	end
	SetInactive(self)
	return false
end

function SceneData:Start(...)
	if self.CurrentState == "" then
		local id = self.StateOrder[1]
		if id then
			return self:Resume(id, ...)
		end
	else
		SceneData:Resume(self.CurrentState)
	end
	SetInactive(self)
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
		return self:Resume(id, ...)
	end
	SetInactive(self)
	return false
end

---@param state SceneStateData
function SceneData:StateDone(state, ...)
	fprint(LOGLEVEL.TRACE, "[SceneData:StateDone:%s] State(%s)", self.ID, state.ID)
	if not self:Next(...) then
		SceneManager.ResumeLastThread()
	end
end

Classes.SceneData = SceneData