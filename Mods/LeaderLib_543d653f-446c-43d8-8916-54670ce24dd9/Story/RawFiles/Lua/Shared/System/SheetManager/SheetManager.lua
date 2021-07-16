if SheetManager == nil then
	---@class SheetManager
	SheetManager = {}
end

---@alias SHEET_ENTRY_ID string
---@alias OnSheetStatChangedCallback fun(id:string, stat:SheetStatData, character:EsvCharacter, lastValue:integer, value:integer, isClientSide:boolean):void
---@alias OnSheetAbilityChangedCallback fun(id:string, stat:SheetAbilityData, character:EsvCharacter, lastValue:integer, value:integer, isClientSide:boolean):void
---@alias OnSheetTalentChangedCallback fun(id:string, stat:SheetTalentData, character:EsvCharacter, lastValue:boolean, value:boolean, isClientSide:boolean):void

SheetManager.__index = SheetManager
SheetManager.Loaded = false
local isClient = Ext.IsClient()

Ext.Require("Shared/System/SheetManager/Data/SheetDataValues.lua")

SheetManager.Listeners = {
	Loaded = {},
	---@type table<string, OnSheetStatChangedCallback|OnSheetAbilityChangedCallback|OnSheetTalentChangedCallback[]>
	OnEntryChanged = {All = {}}
}

local self = SheetManager

---@private
function SheetManager:RegisterListener(tbl, callback, key)
	if callback == nil then
		return
	end
	local t = type(key)
	if t == "table" then
		for i=1,#key do
			self:RegisterListener(tbl, callback, key[i])
		end
	elseif t == "number" or t == "string" then
		if tbl[key] == nil then
			tbl[key] = {}
		end
		table.insert(tbl[key], callback)
	elseif key == nil then
		table.insert(tbl, callback)
	end
end

---@param callback fun(self:SheetManager):void
function SheetManager:RegisterLoadedListener(callback)
	self:RegisterListener(self.Listeners.Loaded, callback)
end

---@param id string|string[]|number|number[]
---@param callback OnSheetStatChangedCallback
function SheetManager:RegisterStatChangedListener(id, callback)
	if StringHelpers.Equals(id, "All", true) then
		id = "All"
	end
	self:RegisterListener(self.Listeners.OnEntryChanged, callback, id)
end

---@param id string|string[]|number|number[]
---@param callback OnSheetAbilityChangedCallback
function SheetManager:RegisterAbilityChangedListener(id, callback)
	if StringHelpers.Equals(id, "All", true) then
		id = "All"
	end
	self:RegisterListener(self.Listeners.OnEntryChanged, callback, id)
end

---@param id string|string[]|number|number[]
---@param callback OnSheetTalentChangedCallback
function SheetManager:RegisterTalentChangedListener(id, callback)
	if StringHelpers.Equals(id, "All", true) then
		id = "All"
	end
	self:RegisterListener(self.Listeners.OnEntryChanged, callback, id)
end

---@type table<SHEET_ENTRY_ID,table<UUID|NETID, integer|boolean>>
SheetManager.CurrentValues = {}
if not isClient then
	local Handler = {
		__index = function(tbl,k)
			return PersistentVars.CharacterSheetValues[k]
		end,
		__newindex = function(tbl,k,v)
			PersistentVars.CharacterSheetValues[k] = v
		end
	}
	setmetatable(SheetManager.CurrentValues, Handler)
end

SheetManager.Data = {
	---@type table<MOD_UUID, table<SHEET_ENTRY_ID, SheetAbilityData>>
	Abilities = {},
	---@type table<MOD_UUID, table<SHEET_ENTRY_ID, SheetTalentData>>
	Talents = {},
	---@type table<MOD_UUID, table<SHEET_ENTRY_ID, SheetStatData>>
	Stats = {},
	ID_MAP = {
		Abilities = {
			NEXT_ID = 1999,
			---@type table<integer, SheetAbilityData>
			Entries = {}
		},
		---@type table<integer, SheetTalentData>
		Talents = {
			NEXT_ID = 1999,
			Entries = {}
		},
		---@type table<integer, SheetTalentData>
		Stats = {
			NEXT_ID = 1999,
			Entries = {}
		},
	}
}

---@type fun():table<string, table<string, SheetAbilityData|SheetTalentData|SheetStatData>>
local loader = Ext.Require("Shared/System/SheetManager/ConfigLoader.lua")
--Ext.Require("Shared/System/SheetManager/DataSync.lua")
--Ext.Require("Shared/System/SheetManager/Getters.lua")
--Ext.Require("Shared/System/SheetManager/PointsHandler.lua")

local function LoadData()
	local b,data = xpcall(loader, debug.traceback)
	if b and data then
		for uuid,entryData in pairs(data) do
			if not SheetManager.Data.Abilities[uuid] then
				SheetManager.Data.Abilities[uuid] = {}
			end
			if not SheetManager.Data.Talents[uuid] then
				SheetManager.Data.Talents[uuid] = {}
			end
			if not SheetManager.Data.Stats[uuid] then
				SheetManager.Data.Stats[uuid] = {}
			end
			if data.Abilities then
				TableHelpers.AddOrUpdate(SheetManager.Data.Abilities[uuid], data.Abilities)
			end
			if data.Talents then
				TableHelpers.AddOrUpdate(SheetManager.Data.Talents[uuid], data.Talents)
			end
			if data.Stats then
				TableHelpers.AddOrUpdate(SheetManager.Data.Stats[uuid], data.Stats)
			end
		end
		
	else
		Ext.PrintError(data)
	end

	SheetManager.Talents.LoadRequirements()

	--SheetManager.Talents.HideTalent("LoneWolf", ModuleUUID)

	if isClient then
		---Divine Talents
		if Ext.IsModLoaded("ca32a698-d63e-4d20-92a7-dd83cba7bc56") or GameSettings.Settings.Client.DivineTalentsEnabled then
			SheetManager.Talents.ToggleDivineTalents(true)
		end
	end

	SheetManager.Loaded = true
	InvokeListenerCallbacks(SheetManager.Listeners.Loaded, SheetManager)
end

if not isClient then
	RegisterListener("Initialized", LoadData)
else
	Ext.RegisterListener("SessionLoaded", LoadData)
	--Ext.Require("Shared/System/SheetManager/UI/_Init.lua")
end

---Gets custom sheet data from a string id.
---@param id string
---@param mod string|nil
---@param statType string|nil Stat,PrimaryStat,SecondaryStat,Ability,Talent
---@return SheetAbilityData|SheetStatData|SheetTalentData
function SheetManager:GetStatByID(id, mod, statType)
	local targetTable = nil
	if statType then
		if statType == "Stat" or statType == "PrimaryStat" or statType == "SecondaryStat" then
			targetTable = self.Data.Stats
		elseif statType == "Ability" then
			targetTable = self.Data.Abilities
		elseif statType == "Talent" then
			targetTable = self.Data.Talents
		end
	end
	if targetTable then
		if mod then
			return targetTable[mod][id]
		else
			for modId,tbl in pairs(targetTable) do
				if tbl[id] then
					return tbl[id]
				end
			end
		end
	end
	return nil
end

---Gets custom sheet data from a generated id.
---@param generatedId integer
---@param statType string|nil PrimaryStat,SecondaryStat,Ability,Talent
---@return SheetAbilityData|SheetStatData|SheetTalentData
function SheetManager:GetStatByGeneratedID(generatedId, statType)
	if statType then
		if statType == "Stat" or statType == "PrimaryStat" or statType == "SecondaryStat" then
			return self.Data.ID_MAP.Stats[generatedId]
		elseif statType == "Ability" then
			return self.Data.ID_MAP.Abilities[generatedId]
		elseif statType == "Talent" then
			return self.Data.ID_MAP.Talents[generatedId]
		end
	end
	for t,tbl in pairs(self.Data.ID_MAP) do
		for checkId,data in pairs(tbl) do
			if checkId == generatedId then
				return data
			end
		end
	end
	return nil
end

---@param stat SheetAbilityData|SheetStatData|SheetTalentData
---@param characterId UUID|NETID
---@param value integer|boolean
---@param skipListenerInvoke boolean|nil If true, Listeners.OnEntryChanged invoking is skipped.
---@param skipSync boolean|nil If on the client and this is true, the value change won't be sent to the server.
function SheetManager:SetEntryValue(stat, characterId, value, skipListenerInvoke, skipSync)
	local last = stat:GetValue(characterId)
	if last ~= value then
		if self.CurrentValues[stat.ID] == nil then
			self.CurrentValues[stat.ID] = {}
		end
		self.CurrentValues[stat.ID][characterId] = value
		if not skipListenerInvoke then
			local character = Ext.GetGameObject(characterId)
			for listener in self:GetListenerIterator(self.Listeners.OnEntryChanged[stat.ID], self.Listeners.OnEntryChanged.All) do
				local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, last, value, isClient)
				if not b then
					fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointAdded] Error calling OnAvailablePointsChanged listener for stat (%s):\n%s", stat.ID, err)
				end
			end
		end
		if isClient and not skipSync then
			self:RequestValueChange(stat, characterId, value)
		end
	end
end

if isClient then
	---Gets custom sheet data from a generated id.
	---@param stat SheetAbilityData|SheetStatData|SheetTalentData
	---@param character EsvCharacter|EclCharacter|string|number
	---@param value integer|boolean
	function SheetManager:RequestValueChange(stat, character, value)
		local netid = GameHelpers.GetNetID(character)
		Ext.PostMessageToServer("LeaderLib_SheetManager_RequestValueChange", Ext.JsonStringify({
			ID = stat.ID,
			Mod = stat.Mod,
			NetID = netid,
			Value = value,
			StatType = stat.StatType
		}))
	end
else
	Ext.RegisterNetListener("LeaderLib_SheetManager_RequestValueChange", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local stat = SheetManager:GetStatByID(data.ID, data.Mod, data.StatType)
			if stat then
				SheetManager:SetEntryValue(stat, Ext.GetCharacter(data.NetID), data.Value)
			end
		end
	end)
end