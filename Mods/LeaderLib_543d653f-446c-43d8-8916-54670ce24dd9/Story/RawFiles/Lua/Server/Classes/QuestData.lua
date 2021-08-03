---@class QuestStateData
local QuestStateData = {
	Type = "QuestStateData",
	---@type QuestData
	Parent = nil,
	ID = "",
	Flags = {
		Update = "",
	}
}
QuestStateData.__index = QuestStateData

---@param parent QuestData
---@param id string
---@param params table<string,any>
---@return QuestStateData
function QuestStateData:Create(id, params)
    local this =
    {
		ID = id or "",
		Flags = {
			Update = "",
		},
		Parent = nil
	}
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)
	self:UpdateFlags()
    return this
end

function QuestStateData:UpdateFlags()
	if self.Parent ~= nil then
		self.Flags.Update = string.format("QuestUpdate_%s_%s", self.Parent.ID, self.ID)
	end
end

---@param uuid string Character UUID
function QuestStateData:Activate(uuid, state)
	if self.Flags.Update ~= nil and self.Flags.Update ~= "" and ObjectGetFlag(uuid, self.Flags.Update) == 0 then
		if Vars.DebugMode then
			Ext.Print(string.format("[LeaderLib:QuestData] Activating quest state (%s:%s) on (%s)[%s]", self.ID, self.Flags.Update, Ext.GetCharacter(uuid).DisplayName, uuid))
		end
		ObjectSetFlag(uuid, self.Flags.Update, 0)
	end
end

---@class QuestData
local QuestData = {
	Type = "QuestData",
	ID = "",
	---@type QuestStateData[]
	States = {},
	Flags = {
		Add = "",
		Close = ""
	}
}
QuestData.__index = QuestData

---@param id string
---@param params table<string,any>
---@return QuestData
function QuestData:Create(id, params)
    local this =
    {
		ID = id or "",
		States = {},
		Flags = {
			Add = "",
			Close = ""
		}
	}
	this.Flags.Add = string.format("QuestAdd_%s", this.ID)
	this.Flags.Close = string.format("QuestClose_%s", this.ID)
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)
    return this
end

---Adds quest states.
---@param state QuestStateData|QuestStateData[] Quest states to add.
function QuestData:AddState(state, index)
	if state.Type == "QuestStateData" then
		if index == nil or #self.States > index then
			self.States[#self.States+1] = state
		else
			table.insert(self.States, index, state)
		end
		state.Parent = self
		state:UpdateFlags()
	elseif type(state) == "table" then
		for i,v in pairs(state) do
			self:AddState(v, index)
		end
	end
end

function QuestData:ClearDatabases()
	if self.ID ~= "" and self.ID ~= nil then
		Osi.DB_QuestDef_State:Delete(self.ID, nil)
		Osi.DB_QuestDef_State:Delete(self.ID, nil, nil)
		Osi.DB_QuestDef_AddEvent:Delete(self.ID, nil)
		Osi.DB_QuestDef_UpdateEvent:Delete(self.ID, nil, nil)
		Osi.DB_QuestDef_CloseEvent:Delete(self.ID, nil)
		Osi.DB_QuestNPC:Delete(self.ID, nil)
	end
end

---Registers the quest data to all related databases.
function QuestData:RegisterDatabases()
	for i,state in pairs(self.States) do
		Osi.DB_QuestDef_State(self.ID, state.ID)
	end
end

---@param uuid string Character uuid
---@return boolean
function QuestData:HasQuest(uuid)
	if ObjectGetFlag(uuid, self.Flags.Add) == 0 then
		self:Activate(uuid)
	end
end

---@param uuid string Character UUID
---@param state string|QuestStateData Character UUID
function QuestData:Activate(uuid, state)
	if ObjectGetFlag(uuid, self.Flags.Add) == 0 then
		if Vars.DebugMode then
			Ext.Print(string.format("[LeaderLib:QuestData] Activating quest (%s:%s) on (%s)[%s]", self.ID, self.Flags.Add, Ext.GetCharacter(uuid).DisplayName, uuid))
		end
		ObjectSetFlag(uuid, self.Flags.Add, 0)
	end
	if state ~= nil then
		local t = type(state)
		if t == "table" and state.Type == "QuestStateData" then
			ObjectSetFlag(uuid, state.Flags.Update, 0)
		elseif t == "string" then
			if not string.find(state, "QuestUpdate_") then
				ObjectSetFlag(uuid, string.format("QuestUpdate_%s_%s", self.ID, state), 0)
			else
				ObjectSetFlag(uuid, state, 0)
			end
		end
	end
end

---@param uuid string Character UUID
function QuestData:Close(uuid)
	ObjectSetFlag(uuid, self.Flags.Close, 0)
end

Classes.QuestStateData = QuestStateData
Classes.QuestData = QuestData