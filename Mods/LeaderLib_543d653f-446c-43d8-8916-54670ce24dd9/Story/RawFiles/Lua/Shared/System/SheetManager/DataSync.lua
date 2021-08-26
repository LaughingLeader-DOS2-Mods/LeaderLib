local self = SheetManager
local isClient = Ext.IsClient()

---@class SheetManagerSaveData:table
---@field Stats table<MOD_UUID, table<SHEET_ENTRY_ID, integer>>
---@field Abilities table<MOD_UUID, table<SHEET_ENTRY_ID, integer>>
---@field Talents table<MOD_UUID, table<SHEET_ENTRY_ID, boolean>>
---@field Custom table<MOD_UUID, table<SHEET_ENTRY_ID, integer>>

---@type table<UUID|NETID, SheetManagerSaveData>
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

SheetManager.Save = {}

---@private
---@param characterId UUID|EsvCharacter|NETID|EclCharacter
---@return SheetManagerSaveData
function SheetManager.Save.CreateCharacterData(characterId)
	characterId = GameHelpers.GetCharacterID(characterId)
	assert(type(characterId) == "string" or type(characterId) == "number", "Character ID (UUID or NetID) required.")
	local data = self.CurrentValues[characterId]
	if not data then
		data = {
			Stats = {},
			Abilities = {},
			Talents = {},
			CustomStats = {}
		}
		self.CurrentValues[characterId] = data
	end
	return data
end

---@param statType SheetEntryType
---@return integer|boolean
function SheetManager.Save.GetTableNameForType(statType)
	if statType == self.StatType.PrimaryStat or statType == self.StatType.SecondaryStat then
		return "Stats"
	elseif statType == self.StatType.Ability then
		return "Abilities"
	elseif statType == self.StatType.Talent then
		return "Talents"
	elseif statType == self.StatType.Custom then
		return "CustomStats"
	end
end

---@param characterId UUID|EsvCharacter|NETID|EclCharacter
---@param statType SheetStatType|nil
---@param mod string|nil
---@param entryId string|nil
---@return table
function SheetManager.Save.GetCharacterData(characterId, statType, mod, entryId)
	local data = self.CurrentValues[characterId]
	if data then
		if statType then
			local tableName = SheetManager.Save.GetTableNameForType(statType)
			if tableName ~= nil then
				local statTypeTable = data[tableName]
				if statTypeTable then
					if mod then
						local modData = statTypeTable[mod]
						if entryId then
							return modData[entryId]
						end
						return modData
					end
					return statTypeTable
				end
			end
		end
		if mod then
			for statType,modData in pairs(data) do
				if modData[mod] then
					if entryId then
						return modData[mod][entryId]
					end
					return modData[mod]
				end
			end
		elseif entryId then
			for statType,modData in pairs(data) do
				for modId,statData in pairs(modData) do
					if statData[entryId] then
						return statData[entryId]
					end
				end
			end
		end
		return data
	end
	return nil
end

---@param characterId UUID|EsvCharacter|NETID|EclCharacter
---@param entry SheetAbilityData|SheetStatData|SheetTalentData|SheetCustomStatData
---@return integer|boolean
---@return table<SHEET_ENTRY_ID, integer> The mod data table containing all stats.
function SheetManager.Save.GetEntryValue(characterId, entry)
	local t = type(entry)
	assert(t == "table", string.format("[SheetManager.Save.GetEntryValue] Entry type invalid (%s). Must be one of the following types: SheetAbilityData|SheetStatData|SheetTalentData|SheetCustomStatData", t))
	if entry then
		local defaultValue = 0
		if entry.ValueType == "boolean" then
			defaultValue = false
		end
		characterId = GameHelpers.GetCharacterID(characterId)
		local data = self.CurrentValues[characterId]
		if data then
			local tableName = SheetManager.Save.GetTableNameForType(entry.StatType)
			if tableName ~= nil then
				local statTypeTable = data[tableName]
				if statTypeTable then
					local modTable = statTypeTable[entry.Mod]
					if modTable then
						local value = modTable[entry.ID]
						if value == nil then
							value = defaultValue
						end
						return value,modTable
					end
				end
			end
		end
		return defaultValue
	end
	return nil
end

---@param characterId UUID|EsvCharacter|NETID|EclCharacter
---@param entry SheetAbilityData|SheetStatData|SheetTalentData|SheetCustomStatData
---@param value integer|boolean
---@return boolean
function SheetManager.Save.SetEntryValue(characterId, entry, value)
	characterId = GameHelpers.GetCharacterID(characterId)
	local data = self.CurrentValues[characterId] or SheetManager.Save.CreateCharacterData(characterId)
	local tableName = SheetManager.Save.GetTableNameForType(entry.StatType)
	assert(tableName ~= nil, string.format("Failed to find data table for stat type (%s)", entry.StatType))
	if data[tableName][entry.Mod] == nil then
		data[tableName][entry.Mod] = {}
	end
	data[tableName][entry.Mod][entry.ID] = value
	return true
end

if not isClient then
	---@private
	---@param character UUID|EsvCharacter
	---@param user integer|nil
	function SheetManager:SyncData(character, user)
		if character ~= nil then
			local characterId = GameHelpers.GetCharacterID(character)
			local data = {
				NetID = GameHelpers.GetNetID(character),
				Values = {}
			}
			if PersistentVars.CharacterSheetValues[characterId] ~= nil then
				data.Values = TableHelpers.SanitizeTable(PersistentVars.CharacterSheetValues[characterId])
			end
			data = Ext.JsonStringify(data)
			if user then
				local t = type(user)
				if t == "number" then
					Ext.PostMessageToUser(user, "LeaderLib_SheetManager_LoadCharacterSyncData", data)
					return true
				elseif t == "string" then
					Ext.PostMessageToClient(user, "LeaderLib_SheetManager_LoadCharacterSyncData", data)
					return true
				else
					fprint(LOGLEVEL.ERROR, "[SheetManager:SyncData] Invalid type (%s)[%s] for user parameter.", t, user)
				end
			end
			Ext.BroadcastMessage("LeaderLib_SheetManager_LoadCharacterSyncData", data)
		else
			local data = {}
			for uuid,entries in pairs(TableHelpers.SanitizeTable(PersistentVars.CharacterSheetValues)) do
				local netid = GameHelpers.GetNetID(uuid)
				if netid then
					data[netid] = entries
				end
			end

			data = Ext.JsonStringify(data)
			if user then
				local t = type(user)
				if t == "number" then
					Ext.PostMessageToUser(user, "LeaderLib_SheetManager_LoadSyncData", data)
					return true
				elseif t == "string" then
					Ext.PostMessageToClient(user, "LeaderLib_SheetManager_LoadSyncData", data)
					return true
				else
					fprint(LOGLEVEL.ERROR, "[SheetManager:SyncData] Invalid type (%s)[%s] for user parameter.", t, user)
				end
			end
			Ext.BroadcastMessage("LeaderLib_SheetManager_LoadSyncData", data)
			return true
		end
		return false
	end
else
	Ext.RegisterNetListener("LeaderLib_SheetManager_LoadSyncData", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			self.CurrentValues = data
		end
	end)

	Ext.RegisterNetListener("LeaderLib_SheetManager_LoadCharacterSyncData", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			assert(type(data.NetID) == "number", "NetID is invalid.")
			assert(data.Values ~= nil, "Payload has no Values table.")

			self.CurrentValues[data.NetID] = data.Values
		end
	end)
	
	---Request a value change for a sheet entry on the server side.
	---@param entry SheetAbilityData|SheetStatData|SheetTalentData|SheetCustomStatData
	---@param character EclCharacter|NETID
	---@param value integer|boolean
	function SheetManager:RequestValueChange(entry, character, value)
		local netid = GameHelpers.GetNetID(character)
		Ext.PostMessageToServer("LeaderLib_SheetManager_RequestValueChange", Ext.JsonStringify({
			ID = entry.ID,
			Mod = entry.Mod,
			NetID = netid,
			Value = value,
			StatType = entry.StatType
		}))
	end

	Ext.RegisterNetListener("LeaderLib_SheetManager_EntryValueChanged", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local characterId = GameHelpers.GetCharacterID(data.NetID)
			local stat = SheetManager:GetEntryByID(data.ID, data.Mod, data.StatType)
			if characterId and stat then
				local skipInvoke = data.SkipInvoke
				if skipInvoke == nil then
					skipInvoke = false
				end
				SheetManager:SetEntryValue(stat, characterId, data.Value, skipInvoke, true)
			end
		end
	end)
end