---@type QuestData[]
local _questRegistration = {}

local function RegisterQuests()
	for i=1,#_questRegistration do
		local quest = _questRegistration[i]
		if quest and quest.AutoRegister then
			quest:RegisterDatabases()
		end
	end
	_questRegistration = {}
end

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

local function _idToString(tbl)
	return tbl.ID
end

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
	if type(params) == "table" then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, {
		__index = QuestStateData,
		__tostring = _idToString
	})
	self:UpdateFlags()
    return this
end

function QuestStateData:UpdateFlags()
	if self.Parent ~= nil then
		self.Flags.Update = string.format("QuestUpdate_%s_%s", self.Parent.ID, self.ID)
	end
end

---@param uuid string Character UUID
function QuestStateData:Activate(uuid)
	if self.Flags.Update ~= nil and self.Flags.Update ~= "" and Osi.ObjectGetFlag(uuid, self.Flags.Update) == 0 then
		if Vars.DebugMode then
			fprint(LOGLEVEL.DEFAULT, "[LeaderLib:QuestStateData] Activating quest state (%s:%s) on (%s)[%s]", self.ID, self.Flags.Update, GameHelpers.GetCharacter(uuid).DisplayName, uuid)
		end
		Osi.ObjectSetFlag(uuid, self.Flags.Update, 0)
	end
end

---@class QuestDataRegistration
---@field Started fun(callback:fun(data:QuestData, character:EsvCharacter))
---@field StateChanged fun(callback:fun(data:QuestData, state:QuestStateData, character:EsvCharacter, isCompleted:boolean))
---@field Completed fun(callback:fun(data:QuestData, character:EsvCharacter))

---@class QuestDataFields
---@field ID string
---@field States QuestStateData[]
---@field AutoRegister boolean Defaults to true. RegisterDatabases will be called automatically by LeaderLib.

---@class QuestData:QuestDataFields
---@field Register QuestDataRegistration
local QuestData = {
	Type = "QuestData",
	ID = "",
	---@type QuestStateData[]
	States = {},
	Flags = {
		Add = "",
		Close = ""
	},
	AutoRegister = true
}

---@param this QuestData
local function CreateRegistrationWrapper(this)
	this.Register = {
		Started = function(callback)
			RegisterListener("QuestStarted", this.ID, function (id, character)
				local b,err = xpcall(callback, debug.traceback, this, character)
				if not b then
					Ext.Utils.PrintError(err)
				end
			end)
		end,
		StateChanged = function(callback)
			RegisterListener("QuestStateChanged", this.ID, function (id, character)
				local b,err = xpcall(callback, debug.traceback, this, character)
				if not b then
					Ext.Utils.PrintError(err)
				end
			end)
		end,
		Completed = function(callback)
			RegisterListener("QuestCompleted", this.ID, function (id, stateId, character)
				local state = this:GetState(stateId)
				local b,err = xpcall(callback, debug.traceback, state or stateId, character)
				if not b then
					Ext.Utils.PrintError(err)
				end
			end)
		end,
	}
end

---@param id string
---@param params QuestDataFields|nil Optional table of QuestData parameters to set.
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
	if type(params) == "table" then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	CreateRegistrationWrapper(this)
	setmetatable(this, {
		__index = QuestData,
		__tostring = _idToString
	})
	_questRegistration[#_questRegistration+1] = this
	-- if _OSIRIS() and Ext.GetGameState() == "Running" then
	-- end
    return this
end

---Adds a quest state, or a table of states.
---Returns self, for easier function chaining.
---@param state QuestStateData|QuestStateData[] Quest states to add.
---@return QuestData
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
	return self
end

---Get a quest state by ID.
---@param id string
---@return QuestStateData
function QuestData:GetState(id)
	for i,v in pairs(self.States) do
		if v.ID == id then
			return v
		end
	end
	return nil
end

---Clear all related quest database entries for this quest ID.
---@return QuestData
function QuestData:ClearDatabases()
	if not StringHelpers.IsNullOrEmpty(self.ID) then
		Osi.DB_QuestDef_State:Delete(self.ID, nil)
		Osi.DB_QuestDef_State:Delete(self.ID, nil, nil)
		Osi.DB_QuestDef_AddEvent:Delete(self.ID, nil)
		Osi.DB_QuestDef_UpdateEvent:Delete(self.ID, nil, nil)
		Osi.DB_QuestDef_CloseEvent:Delete(self.ID, nil)
		Osi.DB_QuestNPC:Delete(self.ID, nil)
		Osi.DB_ActivatedQuests:Delete(self.ID)
	end
	return self
end

---Registers the quest data to all related databases.
---@return QuestData
function QuestData:RegisterDatabases()
	for i,state in pairs(self.States) do
		Osi.DB_QuestDef_State(self.ID, state.ID)
	end
	return self
end

local function _uuidCheck(v)
	local uuid = GameHelpers.GetUUID(v)
	if not StringHelpers.IsNullOrEmpty(uuid) and Osi.ObjectIsCharacter(uuid) == 1 then
		return uuid
	else
		error(string.format("Function requires a valid character UUID. '%s' was given.", v), 2)
	end
end

---@param uuid string Character uuid
---@return boolean
function QuestData:HasQuest(uuid)
	local uuid = _uuidCheck(uuid)
	if uuid then
		return Osi.ObjectGetFlag(uuid, self.Flags.Add) == 1
	end
	return false
end

---@param uuid string Character UUID
---@param state QuestStateData|string Either a state object, or a quest flag to check.
---@return boolean
function QuestData:Activate(uuid, state)
	local uuid = _uuidCheck(uuid)
	if not uuid then
		return false
	end

	local addedFlags = {}
	if Osi.ObjectGetFlag(uuid, self.Flags.Add) == 0 then
		if Vars.DebugMode then
			fprint(LOGLEVEL.DEFAULT, "[LeaderLib:QuestData] Activating quest (%s:%s) on (%s)[%s]", self.ID, self.Flags.Add, GameHelpers.GetCharacter(uuid).DisplayName, uuid)
		end
		Osi.ObjectSetFlag(uuid, self.Flags.Add, 0)
		addedFlags[#addedFlags+1] = self.Flags.Add
	end
	if state ~= nil then
		local t = type(state)
		if t == "table" and state.Type == "QuestStateData" then
			Osi.ObjectSetFlag(uuid, state.Flags.Update, 0)
			addedFlags[#addedFlags+1] = state.Flags.Update
		elseif t == "string" then
			local stateObject = self:GetState(state)
			if stateObject then
				Osi.ObjectSetFlag(uuid, stateObject.Flags.Update, 0)
				addedFlags[#addedFlags+1] = stateObject.Flags.Update
			else
				if not string.find(state, "QuestUpdate_") then
					local flag = string.format("QuestUpdate_%s_%s", self.ID, state)
					Osi.ObjectSetFlag(uuid, flag, 0)
					addedFlags[#addedFlags+1] = flag
				else
					Osi.ObjectSetFlag(uuid, state, 0)
					addedFlags[#addedFlags+1] = state
				end
			end
		end
	end
	local success = true
	for i=1,#addedFlags do
		local flag = addedFlags[i]
		if Osi.ObjectGetFlag(uuid, flag) == 0 then
			fprint(LOGLEVEL.ERROR, "[LeaderLib:QuestData:%s] Quest flag (%s) was not set on character (%s)", self.ID, flag, uuid)
			success = false
			break
		end
	end
	return success
end

---Close and archive a quest.
---@param uuid string Character UUID
function QuestData:Complete(uuid)
	local uuid = _uuidCheck(uuid)
	assert(uuid ~= nil, "UUID is invalid")
	Osi.ObjectSetFlag(uuid, self.Flags.Close, 0)
end

Classes.QuestStateData = QuestStateData
Classes.QuestData = QuestData

Events.RegionChanged:Subscribe(function (e)
	if e.State == REGIONSTATE.STARTED then
		RegisterQuests()
	end
end)

---@param flag string
local function GetQuestFromFlag(flag)
	--DB_QuestDef_UpdateEvent first since the same flag could be used in DB_QuestDef_AddEvent
	local b,id,stateId = GameHelpers.DB.TryUnpack(Osi.DB_QuestDef_UpdateEvent:Get(nil, nil, flag))
	if b then
		return id,"QuestStateChanged",stateId
	end
	local b,id = GameHelpers.DB.TryUnpack(Osi.DB_QuestDef_AddEvent:Get(nil, flag))
	if b then
		return id,"QuestStarted"
	end
	local b,id = GameHelpers.DB.TryUnpack(Osi.DB_QuestDef_CloseEvent:Get(nil, flag))
	if b then
		return id,"QuestCompleted"
	end
	-- local b,id,rewardState = GameHelpers.DB.TryUnpack(Osi.DB_QuestDef_QuestReward:Get(nil, nil, flag))
	-- if b then
	-- 	return id,"QuestReward",rewardState
	-- end
end

--Called after ObjectFlagSet for a flag in the various quest databases
RegisterProtectedOsirisListener("ProcMigrateQuestFlag", 3, "after", function (char, id, flag)
	local questId,listenerEvent,extraParam = GetQuestFromFlag(flag)
	if listenerEvent then
		local character = GameHelpers.GetCharacter(char)
		if listenerEvent == "QuestStateChanged" then
			InvokeListenerCallbacks(Listeners.QuestStateChanged, id, extraParam, character)
		else
			InvokeListenerCallbacks(Listeners[listenerEvent][id], id, character)
			InvokeListenerCallbacks(Listeners[listenerEvent].All, id, character)
		end
	end
end)

--Called after a Quest AddEvent flag is set.
RegisterProtectedOsirisListener("ProcCheckMigrateQuestAddFlag", 3, "after", function (char, id, flag)
	--[[Larian skips calling ProcMigrateQuestFlag is this "AddFlag" is also an update event flag.
	We want to invoke QuestStarted if so since ProcMigrateQuestFlag isn't called otherwise.]]
	local b = GameHelpers.DB.TryUnpack(Osi.DB_QuestDef_UpdateEvent:Get(id, nil, flag))
	if b then
		local character = GameHelpers.GetCharacter(char)
		InvokeListenerCallbacks(Listeners.QuestStarted[id], id, character)
		InvokeListenerCallbacks(Listeners.QuestStarted.All, id, character)
	end
end)

-- RegisterProtectedOsirisListener("ProcGiveQuestReward", 3, "after", function (char, id, rewardState)
-- 	local character = GameHelpers.GetCharacter(char)
-- end)

if Vars.DebugMode then
	RegisterListener("QuestStarted", "TUT_ShipMurder", function (id, character)
		Ext.Utils.PrintError("[QuestStarted:TUT_ShipMurder] THERE'S BEEN A MURDER!", character.DisplayName)
	end)

	RegisterListener("QuestStarted", function (id, character)
		fprint(LOGLEVEL.TRACE, "[QuestStarted] id(%s) character(%s)[%s]", id, character.DisplayName, character.MyGuid)
	end)

	RegisterListener("QuestCompleted", function (id, character)
		fprint(LOGLEVEL.TRACE, "[QuestCompleted] id(%s) character(%s)[%s]", id, character.DisplayName, character.MyGuid)
	end)

	RegisterListener("QuestStateChanged", function (id, state, character)
		fprint(LOGLEVEL.TRACE, "[QuestStateChanged] id(%s) state(%s) character(%s)[%s]", id, state, character.DisplayName, character.MyGuid)
	end)
end