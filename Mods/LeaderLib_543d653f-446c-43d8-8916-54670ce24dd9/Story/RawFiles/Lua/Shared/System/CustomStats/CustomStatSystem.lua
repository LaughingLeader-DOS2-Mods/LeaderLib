if CustomStatSystem == nil then
	---@class CustomStatSystem
	CustomStatSystem = {}
end

CustomStatSystem.__index = CustomStatSystem
CustomStatSystem.Loaded = false
CustomStatSystem.MISC_CATEGORY = 99999

CustomStatSystem.Listeners = {
	---@type table<string, OnAvailablePointsChangedCallback[]>
	OnAvailablePointsChanged = {All = {}},
	---@type table<string, OnStatValueChangedCallback[]>
	OnStatValueChanged = {All = {}},
	Loaded = {},
}

---@param callback fun(self:CustomStatSystem):void
function CustomStatSystem:RegisterLoadedListener(callback)
	if callback == nil then
		return
	end
	if type(callback) == "table" then
		for i=1,#callback do
			self:RegisterLoadedListener(callback[i])
		end
	else
		table.insert(self.Listeners.Loaded, callback)
	end
end

---@class CustomStatTooltipType
CustomStatSystem.TooltipType = {
	Default = "Stat",
	Ability = "Ability", -- Icon
	Stat = "Stat",
	Tag = "Tag", -- Icon
}

local self = CustomStatSystem

local isClient = Ext.IsClient()

CustomStatSystem.PointsPool = {}
if not isClient then
	local PointsPoolHandler = {
		__index = function(tbl,k)
			return PersistentVars.CustomStatAvailablePoints[k]
		end,
		__newindex = function(tbl,k,v)
			PersistentVars.CustomStatAvailablePoints[k] = v
		end
	}
	setmetatable(CustomStatSystem.PointsPool, PointsPoolHandler)
end

Ext.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/characterSheet.swf")

---@alias MOD_UUID string
---@alias STAT_ID string

---@type table<MOD_UUID, table<STAT_ID, CustomStatCategoryData>>
CustomStatSystem.Categories = {}
---@type table<MOD_UUID, table<STAT_ID, CustomStatData>>
CustomStatSystem.Stats = {}
CustomStatSystem.UnregisteredStats = {}

Ext.Require("Shared/System/CustomStats/Data/CustomStatBase.lua")
Ext.Require("Shared/System/CustomStats/Data/CustomStatData.lua")
Ext.Require("Shared/System/CustomStats/Data/CustomStatCategoryData.lua")

---@type fun():table<string, table<string, CustomStatData>>
local loader = Ext.Require("Shared/System/CustomStats/ConfigLoader.lua")
Ext.Require("Shared/System/CustomStats/Getters.lua")
Ext.Require("Shared/System/CustomStats/DataSync.lua")
Ext.Require("Shared/System/CustomStats/PointsHandler.lua")

local function LoadCustomStatsData()
	local categories,stats = loader()
	TableHelpers.AddOrUpdate(CustomStatSystem.Categories, categories)
	TableHelpers.AddOrUpdate(CustomStatSystem.Stats, stats)

	if not isClient then
		local foundStats = {}
		for uuid,stats in pairs(CustomStatSystem.Stats) do
			local modName = Ext.GetModInfo(uuid).Name
			for id,stat in pairs(stats) do
				if stat.DisplayName then
					local existingData = Ext.GetCustomStatByName(stat.DisplayName)
					if not existingData then
						if stat.Create == true then
							Ext.CreateCustomStat(stat.DisplayName, stat.Description)
							fprint(LOGLEVEL.DEFAULT, "[LeaderLib:LoadCustomStatsData] Created a new custom stat for mod [%s]. ID(%s) DisplayName(%s) Description(%s)", modName, id, stat.DisplayName, stat.Description)
							existingData = Ext.GetCustomStatByName(stat.DisplayName)
						end
					else
					end
					if existingData then
						stat.UUID = existingData.Id
						for player in GameHelpers.Character.GetPlayers() do
							stat:UpdateLastValue(player)
						end
						foundStats[stat.UUID] = true
					end
				end
			end
		end
		CustomStatSystem.UnregisteredStats = {}
	
		for _,uuid in pairs(Ext.GetAllCustomStats()) do
			if not foundStats[uuid] then
				local stat = Ext.GetCustomStatById(uuid)
				if stat then
					local data = {
						UUID = uuid,
						ID = uuid,
						DisplayName = stat.Name,
						Description = stat.Description,
						LastValue = {}
					}
					setmetatable(data, Classes.UnregisteredCustomStatData)
					CustomStatSystem.UnregisteredStats[uuid] = data
					foundStats[uuid] = true

					for player in GameHelpers.Character.GetPlayers() do
						data:UpdateLastValue(player)
					end
				end
			end
		end
	else
		local categoryId = 0
		for category in CustomStatSystem:GetAllCategories() do
			if categoryId == CustomStatSystem.MISC_CATEGORY then
				categoryId = categoryId + 1
			end
			category.GroupId = categoryId
			categoryId = categoryId + 1
		end
		CustomStatSystem.TooltipValueEnabled = {}
		for stat in CustomStatSystem:GetAllStats() do
			if stat.DisplayValueInTooltip then
				CustomStatSystem.TooltipValueEnabled[stat.ID] = true
			end
		end
	end
	CustomStatSystem.Loaded = true

	InvokeListenerCallbacks(CustomStatSystem.Listeners.Loaded, CustomStatSystem)
end

if not isClient then
	RegisterListener("Initialized", LoadCustomStatsData)
else
	Ext.RegisterListener("SessionLoaded", LoadCustomStatsData)
end
--RegisterListener("LuaReset", LoadCustomStatsData)

---@private
---@param character EsvCharacter|EclCharacter
---@return boolean
function CustomStatSystem:IsTooltipWorking(character)
	if isClient then
		local characterData = Client:GetCharacterData()
		if characterData then
			return characterData.IsGameMaster and not characterData.IsPossessed
		end
	else
		character = character or (Client and Client:GetCharacter()) or nil
		if character then
			--return character.IsPossessed or (not character.IsGameMaster and character.IsPlayer) and character.UserID > -1
			return character.IsGameMaster and not character.IsPossessed
		end
	end
	return false
end

if not isClient then
	local canFix = Ext.GetCustomStatByName ~= nil
	Ext.RegisterNetListener("LeaderLib_CheckCustomStatCallback", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local statDouble = data.Stat
			local character = Ext.GetCharacter(data.Character)
			if character and not CustomStatSystem.IsTooltipWorking(character) then
				if canFix then
					local stat = Ext.GetCustomStatByName(data.StatId)
					if stat then
						data.DisplayName = stat.Name
						data.ID = stat.Id
						data.Description = stat.Description
					else
						data.DisplayName = data.StatId
						data.Description = ""
					end
				end
				Ext.PostMessageToClient(character.MyGuid, "LeaderLib_CreateCustomStatTooltip", Ext.JsonStringify(data))
			end
		end
	end)
	Ext.RegisterNetListener("LeaderLib_RequestCustomStatData", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local uuid = data.UUID
			local character = Ext.GetCharacter(data.Character)
			local statValue = NRD_CharacterGetCustomStat(character.MyGuid, uuid)
			--TODO Need some way to get a custom stat's name and tooltip from the UUID.
		end
	end)
else
	Ext.Require("Shared/System/CustomStats/UISetup.lua")
end