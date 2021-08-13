--[[
Format:
{
	"Stats": {
		"ID": {
			"DisplayName": "",
			"Description": "",
			"Icon": ""
		}
	}
}
]]

local categoryPropertyMap = {
	DISPLAYNAME = {Name="DisplayName", Type = "string"},
	DESCRIPTION = {Name="Description", Type = "string"},
	ICON = {Name="Icon", Type = "string"},
	TOOLTIPTYPE = {Name="TooltipType", Type = "string"},
	SHOWALWAYS = {Name="ShowAlways", Type = "boolean"},
	HIDETOTALPOINTS = {Name="HideTotalPoints", Type = "boolean"},
	SORTNAME = {Name="SortName", Type = "string"},
	SORTVALUE = {Name="SortValue", Type = "number"},
	LOADSTRINGKEY = {Name="LoadStringKey", Type = "boolean"},
}

local statPropertyMap = {
	DISPLAYNAME = {Name="DisplayName", Type = "string"},
	DESCRIPTION = {Name="Description", Type = "string"},
	ICON = {Name="Icon", Type = "string"},
	CREATE = {Name="Create", Type = "boolean"},
	TOOLTIPTYPE = {Name="TooltipType", Type = "string"},
	CATEGORY = {Name="Category", Type = "string"},
	POINTID = {Name="PointID", Type = "string"},
	DISPLAYMODE = {Name="DisplayMode", Type = "string"},
	DISPLAYVALUEINTOOLTIP = {Name="DisplayValueInTooltip", Type = "boolean"},
	VISIBLE = {Name="Visible", Type = "boolean"},
	ICONWIDTH = {Name="IconWidth", Type = "number"},
	ICONHEIGHT = {Name="IconHeight", Type = "number"},
	SORTNAME = {Name="SortName", Type = "string"},
	SORTVALUE = {Name="SortValue", Type = "number"},
	LOADSTRINGKEY = {Name="LoadStringKey", Type = "boolean"},
	--Defaults to true. AvailablePoints are added to when a stat is lowered in the UI.
	AUTOADDAVAILABLEPOINTSONREMOVE = {Name="AutoAddAvailablePointsOnRemove", Type = "boolean"},
	MAXAMOUNT = {Name="MaxAmount", Type = "number"},
}

local isClient = Ext.IsClient()

local STAT_ID = -1

local function setAvailablePointsHandler(data)
	local AvailablePointsHandler = {}
	AvailablePointsHandler.__index = function(table, characterId)
		if characterId == nil then
			return 0
		end
		local pointId = data.ID
		if not StringHelpers.IsNullOrWhitespace(data.PointID) then
			pointId = data.PointID
		end
		local characterData = CustomStatSystem.PointsPool[characterId]
		if characterData then
			return math.max(characterData[pointId] or 0, characterData[data.ID] or 0)
		end
		--fprint(LOGLEVEL.ERROR, "[LeaderLib:CustomStatsData:AvailablePoints] Failed to fetch available points for id (%s) and character(%s). Context(%s).", pointId, uuid, isClient and "CLIENT" or "SERVER")
		return 0
	end
	AvailablePointsHandler.__newindex = function(table, characterId, value)
		local pointId = data.ID
		if not StringHelpers.IsNullOrWhitespace(data.PointID) then
			pointId = data.PointID
		end
		CustomStatSystem:SetAvailablePoints(characterId, pointId, value, true)
	end
	setmetatable(data.AvailablePoints, AvailablePointsHandler)
end

local function parseTable(tbl, propertyMap, modId, defaults)
	local tableData = nil
	if type(tbl) == "table" then
		tableData = {}
		for k,v in pairs(tbl) do
			if type(v) == "table" then
				local data = {
					ID = k,
					Mod = modId
				}
				if defaults then
					for property,value in pairs(defaults) do
						if type(property) == "string" then
							local propKey = string.upper(property)
							local propData = propertyMap[propKey]
							local t = type(value)
							if propData and (propData.Type == "any" or t == propData.Type) then
								data[propData.Name] = value
							else
								fprint(LOGLEVEL.WARNING, "[LeaderLib:CustomStatsConfig] Defaults for stat(%s) has unknown property (%s) with value type(%s)", k, property, t)
							end
						end
					end
				end
				for property,value in pairs(v) do
					if type(property) == "string" then
						local propKey = string.upper(property)
						local propData = propertyMap[propKey]
						local t = type(value)
						if propData and (propData.Type == "any" or t == propData.Type) then
							data[propData.Name] = value
						else
							fprint(LOGLEVEL.WARNING, "[LeaderLib:CustomStatsConfig] Stat(%s) has unknown property (%s) with value type(%s)", k, property, t)
						end
					end
				end
				if propertyMap == statPropertyMap then
					data.Type = "SheetCustomStatData"
					data.AvailablePoints = {}
					if not CustomStatSystem:GMStatsEnabled() then
						STAT_ID = STAT_ID + 1
						data.Double = STAT_ID
					end
					Classes.SheetCustomStatData.SetDefaults(data)
					setAvailablePointsHandler(data)
					setmetatable(data, Classes.SheetCustomStatData)
				else
					setmetatable(data, Classes.SheetCustomStatCategoryData)
				end

				tableData[k] = data
			end
		end
	end
	return tableData
end

local function LoadConfig(uuid, file)
	local settings = SettingsManager.GetMod(uuid, true)
	local config = Common.JsonParse(file)
	local loadedStats = nil
	local loadedCategories = nil
	local statDefaults,categoryDefaults = nil,nil
	if config ~= nil then
		if config.Defaults then
			if config.Defaults.Stats then
				statDefaults = config.Defaults.Stats
			end
			if config.Defaults.Categories then
				categoryDefaults = config.Defaults.Categories
			end
		end
		local categories = parseTable(config.Categories, categoryPropertyMap, uuid, categoryDefaults)
		local stats = parseTable(config.Stats, statPropertyMap, uuid, statDefaults)

		if categories then
			loadedCategories = categories
		end
		if stats then
			loadedStats = stats
		end
	end
	return loadedCategories,loadedStats
end

local function TryFindConfig(info)
	local filePath = string.format("Mods/%s/CustomStatsConfig.json", info.Directory)
	local file = Ext.LoadFile(filePath, "data")
	return file
end


---@return table<string, table<string, SheetCustomStatBase>>
local function LoadConfigFiles()
	local allCategories,allStats = {},{}
	local order = Ext.GetModLoadOrder()
	for i=1,#order do
		local uuid = order[i]
		if IgnoredMods[uuid] ~= true then
			local info = Ext.GetModInfo(uuid)
			if info ~= nil then
				local b,result = xpcall(TryFindConfig, debug.traceback, info)
				if not b then
					Ext.PrintError(result)
				elseif result ~= nil and result ~= "" then
					local categories,stats = LoadConfig(uuid, result)
					if stats then
						allStats[uuid] = stats
					end
					if categories then
						allCategories[uuid] = categories
					end
				end
			end
		end
	end
	if Vars.DebugMode and CustomStatSystem.DebugEnabled then
		local categories,stats = LoadConfig(ModuleUUID, Ext.LoadFile("Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Story/RawFiles/Lua/Shared/Debug/TestCustomStatsConfig.json", "data"))
		if stats then
			allStats[ModuleUUID] = stats
		end
		if categories then
			allCategories[ModuleUUID] = categories
		end
	end
	return allCategories,allStats
end

return LoadConfigFiles