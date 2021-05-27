if CustomStatSystem == nil then
	CustomStatSystem = {}
end

---@class CustomStatTooltipType
CustomStatSystem.TooltipType = {
	Default = "Stat",
	Ability = "Ability", -- Icon
	Stat = "Stat",
	Tag = "Tag", -- Icon
}

local self = CustomStatSystem

---@class CustomStatCategoryData:CustomStatDataBase
---@field ID string
---@field Mod string The mod UUID that added this stat, if any. Auto-set.
---@field DisplayName string
---@field Description string
---@field Icon string|nil
---@field ShowAlways boolean|nil Whether to always show this category or not. If false, it will only show when a child stat is active.
---@field TooltipType CustomStatTooltipType|nil
---@field GroupId integer Auto-generated integer id used in the characterSheet swf.

---@class CustomStatData:CustomStatDataBase
---@field ID string
---@field Mod string The mod UUID that added this stat, if any. Auto-set.
---@field DisplayName string
---@field Description string
---@field Icon string|nil
---@field Create boolean|nil Whether the server should create this stat automatically.
---@field TooltipType CustomStatTooltipType|nil
---@field Category string The stat's category id, if any.
---@field Double number The stat's double (handle) value. Determined dynamically.

---@alias MOD_UUID string
---@alias STAT_ID string

---@type table<MOD_UUID, table<STAT_ID, CustomStatCategoryData>>
CustomStatSystem.Categories = {}
---@type table<MOD_UUID, table<STAT_ID, CustomStatData>>
CustomStatSystem.Stats = {}

---@type fun():table<string, table<string, CustomStatData>>
local loader = Ext.Require("Shared/System/CustomStats/ConfigLoader.lua")
Ext.Require("Shared/System/CustomStats/Getters.lua")
Ext.Require("Shared/System/CustomStats/PointsHandler.lua")

local function LoadCustomStatsData()
	local categories,stats = loader()
	TableHelpers.AddOrUpdate(CustomStatSystem.Categories, categories)
	TableHelpers.AddOrUpdate(CustomStatSystem.Stats, stats)

	if Ext.IsServer() then
		for uuid,stats in pairs(CustomStatSystem.Stats) do
			local modName = Ext.GetModInfo(uuid).Name
			for id,stat in pairs(stats) do
				if stat.Create == true and stat.DisplayName then
					local existingData = Ext.GetCustomStatByName(stat.DisplayName)
					if not existingData then
						Ext.CreateCustomStat(stat.DisplayName, stat.Description)
						fprint(LOGLEVEL.DEFAULT, "[LeaderLib:LoadCustomStatsData] Created a new custom stat for mod [%s]. ID(%s) DisplayName(%s) Description(%s)", modName, id, stat.DisplayName, stat.Description)

						existingData = Ext.GetCustomStatByName(stat.DisplayName)
					else
						print("Found custom stat:", Common.Dump(existingData))
					end
					if existingData then
						stat.UUID = existingData.Id
					end
				end
			end
		end
	else
		local categoryId = 1 -- 0 is Misc
		for category in CustomStatSystem:GetAllCategories() do
			category.GroupId = categoryId
			categoryId = categoryId + 1
		end
	end

	-- if Vars.DebugMode then
	-- 	print(Ext.IsServer() and "SERVER" or "CLIENT")
	-- 	print("Categories", Ext.JsonStringify(CustomStatSystem.Categories))
	-- 	print("Stats", Ext.JsonStringify(CustomStatSystem.Stats))
	-- end
end

Ext.RegisterListener("SessionLoaded", LoadCustomStatsData)
RegisterListener("LuaReset", LoadCustomStatsData)

---@param character EsvCharacter|EclCharacter
---@return boolean
function CustomStatSystem:IsTooltipWorking(character)
	if Ext.IsClient() then
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

if Ext.IsServer() then
	local canFix = Ext.GetCustomStatByName ~= nil
	Ext.RegisterNetListener("LeaderLib_CheckCustomStatCallback", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local statDouble = data.Stat
			local character = Ext.GetCharacter(data.Character)
			if character and CustomStatSystem.IsTooltipWorking(character) then
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
	--Creates a table of stat id to uuid, for sending stat UUIDs to the client
	function CustomStatSystem:GetSyncData()
		local data = {}
		for uuid,stats in pairs(self.Stats) do
			data[uuid] = {}
			for id,stat in pairs(stats) do
				if stat.UUID then
					data[uuid][id] = stat.UUID
				end
			end
		end
		return data
	end
else
	Ext.Require("Shared/System/CustomStats/UISetup.lua")
	Ext.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/characterSheet.swf")
	--Ext.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/Game/GUI/characterSheet.swf")
	--Loads a table of stat UUIDs from the server.
	function CustomStatSystem:LoadSyncData(data)
		for uuid,stats in pairs(data) do
			local existing = CustomStatSystem.Stats[uuid]
			if existing then
				for id,statId in pairs(stats) do
					if existing[id] then
						existing[id].UUID = statId
					end
				end
			end
		end
	end
end