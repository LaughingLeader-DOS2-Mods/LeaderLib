if SheetManager == nil then
	---@class SheetManager
	SheetManager = {}
end

---@alias SHEET_ENTRY_ID string

SheetManager.__index = SheetManager
SheetManager.Loaded = false

local isClient = Ext.IsClient()

Ext.Require("Shared/System/SheetManager/Data/SheetDataValues.lua")
Ext.Require("Shared/System/SheetManager/Getters.lua")
Ext.Require("Shared/System/SheetManager/Setters.lua")
Ext.Require("Shared/System/SheetManager/Listeners.lua")

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

local function LoadData()
	if Vars.DebugMode then
		Vars.LeaderDebugMode = Ext.LoadFile("LeaderDebug") ~= nil
	end
	
	local b,data = xpcall(loader, debug.traceback)
	if b and data then
		for uuid,entryData in pairs(data) do

			if not SheetManager.Data.Abilities[uuid] then
				SheetManager.Data.Abilities[uuid] = entryData.Abilities or {}
			elseif entryData.Abilities then
				TableHelpers.AddOrUpdate(SheetManager.Data.Abilities[uuid], entryData.Abilities)
			end

			if not SheetManager.Data.Talents[uuid] then
				SheetManager.Data.Talents[uuid] = entryData.Talents or {}
			elseif entryData.Talents then
				TableHelpers.AddOrUpdate(SheetManager.Data.Talents[uuid], entryData.Talents)
			end

			if not SheetManager.Data.Stats[uuid] then
				SheetManager.Data.Stats[uuid] = entryData.Stats or {}
			elseif entryData.Stats then
				TableHelpers.AddOrUpdate(SheetManager.Data.Stats[uuid], entryData.Stats)
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
	else
		local valueData = {}
		for id,charData in pairs(PersistentVars.CharacterSheetValues) do
			valueData[id] = {}
			for uuid,value in pairs(charData) do
				local netid = GameHelpers.GetNetID(uuid)
				if netid then
					valueData[id][netid] = value
				end
			end
		end
		Ext.BroadcastMessage("LeaderLib_SheetManager_SyncCurrentValues", Ext.JsonStringify(valueData))
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
			return self.Data.ID_MAP.Stats.Entries[generatedId]
		elseif statType == "Ability" then
			return self.Data.ID_MAP.Abilities.Entries[generatedId]
		elseif statType == "Talent" then
			return self.Data.ID_MAP.Talents.Entries[generatedId]
		end
	end
	for t,tbl in pairs(self.Data.ID_MAP) do
		for checkId,data in pairs(tbl.Entries) do
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
		---@type EsvCharacter|EclCharacter
		local character = characterId
		if type(characterId) ~= "userdata" then
			character = Ext.GetCharacter(characterId)
		else
			characterId = GameHelpers.GetCharacterID(characterId)
		end
		if not StringHelpers.IsNullOrWhitespace(stat.BoostAttribute) then
			if character and character.Stats then
				if not isClient then
					if stat.StatType == "Talent" then
						NRD_CharacterSetPermanentBoostTalent(characterId, string.gsub(stat.BoostAttribute, "TALENT_", ""), value)
						CharacterAddAttribute(characterId, "Dummy", 0)
						--character.Stats.DynamicStats[2][stat.BoostAttribute] = value
					else
						NRD_CharacterSetPermanentBoostInt(characterId, stat.BoostAttribute, value)
						--character.Stats.DynamicStats[2][stat.BoostAttribute] = value
					end
				else
					character.Stats.DynamicStats[2][stat.BoostAttribute] = value
				end
				local success = character.Stats.DynamicStats[2][stat.BoostAttribute] == value
				fprint(LOGLEVEL.DEFAULT, "[%s][SetEntryValue:%s] BoostAttribute(%s) Changed(%s) Current(%s) => Desired(%s)", isClient and "CLIENT" or "SERVER", stat.ID, stat.BoostAttribute, success, character.Stats.DynamicStats[2][stat.BoostAttribute], value)
			else
				fprint(LOGLEVEL.ERROR, "[%s][SetEntryValue:%s] Failed to get character from id (%s)", isClient and "CLIENT" or "SERVER", stat.ID, characterId)
			end
		else
			if self.CurrentValues[stat.ID] == nil then
				self.CurrentValues[stat.ID] = {}
			end
			self.CurrentValues[stat.ID][characterId] = value
		end
		if not skipListenerInvoke then
			for listener in self:GetListenerIterator(self.Listeners.OnEntryChanged[stat.ID], self.Listeners.OnEntryChanged.All) do
				local b,err = xpcall(listener, debug.traceback, stat.ID, stat, character, last, value, isClient)
				if not b then
					fprint(LOGLEVEL.ERROR, "[LeaderLib.CustomStatSystem:OnStatPointAdded] Error calling OnAvailablePointsChanged listener for stat (%s):\n%s", stat.ID, err)
				end
			end
			if not isClient then
				if stat.StatType == "Ability" then
					Osi.CharacterBaseAbilityChanged(character.MyGuid, stat.ID, last, value)
				elseif stat.StatType == "Talent" then
					if value then
						Osi.CharacterUnlockedTalent(character.MyGuid, stat.ID)
					else
						Osi.CharacterLockedTalent(character.MyGuid, stat.ID)
					end
				end
			end
		end
		if not skipSync and isClient then
			--Server-side updating
			self:RequestValueChange(stat, characterId, value)
		end
	end
	if not skipSync and not isClient then
		Ext.BroadcastMessage("LeaderLib_SheetManager_EntryValueChanged", Ext.JsonStringify({
			ID = stat.ID,
			Mod = stat.Mod,
			NetID = GameHelpers.GetNetID(characterId),
			Value = value,
			StatType = stat.StatType
		}))
	end
end

---@param stat SheetAbilityData|SheetStatData|SheetTalentData
---@param characterId UUID|NETID
function SheetManager:GetValueByEntry(stat, characterId)
	if not StringHelpers.IsNullOrWhitespace(stat.BoostAttribute) then
		local character = Ext.GetCharacter(characterId)
		if character and character.Stats then
			local charValue = character.Stats.DynamicStats[2][stat.BoostAttribute]
			if charValue ~= nil then
				return charValue
			end
		end
	else
		local dataTable = self.CurrentValues[stat.ID]
		if dataTable then
			local charValue = dataTable[characterId]
			if charValue ~= nil then
				return charValue
			end
		end
	end
	if stat.StatType == "Talent" then
		return false
	end
	return 0
end

if isClient then
	if SheetManager.UI == nil then
		SheetManager.UI = {}
	end

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

	Ext.RegisterNetListener("LeaderLib_SheetManager_EntryValueChanged", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local characterId = GameHelpers.GetCharacterID(data.NetID)
			local stat = SheetManager:GetStatByID(data.ID, data.Mod, data.StatType)
			if characterId and stat then
				local skipInvoke = data.SkipInvoke
				if skipInvoke == nil then
					skipInvoke = false
				end
				SheetManager:SetEntryValue(stat, characterId, data.Value, skipInvoke, true)
			end
		end
	end)

	Ext.RegisterNetListener("LeaderLib_SheetManager_SyncCurrentValues", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			SheetManager.CurrentValues = data
		end
	end)
else
	Ext.RegisterNetListener("LeaderLib_SheetManager_RequestValueChange", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local characterId = GameHelpers.GetCharacterID(data.NetID)
			local stat = SheetManager:GetStatByID(data.ID, data.Mod, data.StatType)
			if characterId and stat then
				if stat.UsePoints then
					local points = SheetManager:GetBuiltinAvailablePointsForEntry(stat, characterId)
					if points > 0 then
						if SheetManager:ModifyAvailablePointsForEntry(stat, characterId, -1) then
							SheetManager:SetEntryValue(stat, characterId, data.Value)
						end
					end
				else
					SheetManager:SetEntryValue(stat, characterId, data.Value)
				end
			end
		end
	end)

	--Query support

	local function Query_GetAttribute(uuid, id, val, boostCheck, statType)
		local stat = SheetManager:GetStatByID(id, nil, statType or "PrimaryStat")
		if stat and (boostCheck ~= true or stat.BoostAttribute) then
			return stat:GetValue(StringHelpers.GetUUID(uuid))
		end
	end
	Ext.RegisterOsirisListener("CharacterGetAttribute", 3, "after", Query_GetAttribute)
	Ext.RegisterOsirisListener("CharacterGetBaseAttribute", 3, "after", Query_GetAttribute)
	Ext.RegisterOsirisListener("NRD_ItemGetPermanentBoostInt", 3, "after", function(uuid,id,val) 
		return Query_GetAttribute(uuid,id,val,true,"Stat")
	end)

	local function Query_GetAbility(uuid, id, value, boostCheck)
		local stat = SheetManager:GetStatByID(id, nil, "Ability")
		if stat and (boostCheck ~= true or stat.BoostAttribute) then
			return stat:GetValue(StringHelpers.GetUUID(uuid))
		end
	end
	Ext.RegisterOsirisListener("CharacterGetAbility", 3, "after", Query_GetAbility)
	Ext.RegisterOsirisListener("CharacterGetBaseAbility", 3, "after", Query_GetAbility)
	Ext.RegisterOsirisListener("NRD_ItemGetPermanentBoostAbility", 3, "after", function(uuid,id,bool) 
		return Query_GetAbility(uuid,id,bool,true) 
	end)

	local function Query_HasTalent(uuid, id, bool, boostCheck)
		if bool ~= 1 then
			local stat = SheetManager:GetStatByID(id, nil, "Talent")
			if stat and (boostCheck ~= true or stat.BoostAttribute) then
				return stat:GetValue(StringHelpers.GetUUID(uuid))
			end
		end
	end
	Ext.RegisterOsirisListener("CharacterHasTalent", 3, "after", Query_HasTalent)
	Ext.RegisterOsirisListener("NRD_ItemGetPermanentBoostTalent", 3, "after", function(uuid,id,bool) 
		return Query_HasTalent(uuid,id,bool,true) 
	end)
end

--print(CharacterGetAbility(Osi.DB_IsPlayer:Get(nil)[1][1], "Test1"))
--print(CharacterGetAbility("41a06985-7851-4c29-8a78-398ccb313f39", "Test1"))