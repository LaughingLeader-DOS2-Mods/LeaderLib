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
---@param entry SheetAbilityData|SheetStatData|SheetTalentData|CustomStatData
---@return integer|boolean
---@return table<SHEET_ENTRY_ID, integer> The mod data table containing all stats.
function SheetManager.Save.GetEntryData(characterId, entry)
	characterId = GameHelpers.GetCharacterID(characterId)
	local data = self.CurrentValues[characterId]
	if entry and data then
		local tableName = SheetManager.Save.GetTableNameForType(entry.StatType)
		if tableName ~= nil then
			local statTypeTable = data[tableName]
			if statTypeTable then
				local modTable = statTypeTable[entry.Mod]
				if modTable then
					return modTable[entry.ID],modTable
				end
			end
		end
	end
	return data
end

---@param characterId UUID|EsvCharacter|NETID|EclCharacter
---@param entry SheetAbilityData|SheetStatData|SheetTalentData|CustomStatData
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
			self.CharacterStatValues = data

			--[[ for characterId,values in pairs(data) do
				local savedData = self.Save.CreateCharacterData(characterId)

				for statTypeTable,mods in pairs(values) do
					savedData[statTypeTable] = mods
				end
			end ]]
		end
	end)

	Ext.RegisterNetListener("LeaderLib_SheetManager_LoadCharacterSyncData", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			assert(type(data.NetID) == "number", "NetID is invalid.")
			assert(data.Values ~= nil, "Payload has no values.")

			self.CharacterStatValues[data.NetID] = data.Values

			--[[ local savedData = self.Save.CreateCharacterData(data.NetID)

			for statTypeTable,mods in pairs(data.Values) do
				savedData[statTypeTable] = mods
			end ]]
		end
	end)
	
	---Request a value change for a sheet entry on the server side.
	---@param entry SheetAbilityData|SheetStatData|SheetTalentData|CustomStatData
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
end