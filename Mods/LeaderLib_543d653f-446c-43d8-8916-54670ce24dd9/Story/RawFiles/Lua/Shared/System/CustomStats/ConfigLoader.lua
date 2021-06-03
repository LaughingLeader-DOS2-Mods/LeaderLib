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
}

local statPropertyMap = {
	DISPLAYNAME = {Name="DisplayName", Type = "string"},
	DESCRIPTION = {Name="Description", Type = "string"},
	ICON = {Name="Icon", Type = "string"},
	CREATE = {Name="Create", Type = "boolean"},
	TOOLTIPTYPE = {Name="TooltipType", Type = "string"},
	CATEGORY = {Name="Category", Type = "string"},
	POINTID = {Name="PointID", Type = "string"},
}

local isClient = Ext.IsClient()

---@class CustomStatDataBase
local CustomStatDataBase = {
	Type="CustomStatDataBase",
	Description = ""
}
CustomStatDataBase.__index = CustomStatDataBase
Classes.CustomStatDataBase = CustomStatDataBase

local function FormatText(txt)
	if string.find(txt, "_", 1, true) then
		txt = GameHelpers.GetStringKeyText(txt)
	end
	return GameHelpers.Tooltip.ReplacePlaceholders(txt)
end

function CustomStatDataBase:GetDisplayName()
	if self.DisplayName then
		return FormatText(self.DisplayName)
	end
	return self.ID
end

function CustomStatDataBase:GetDescription()
	if self.Description then
		return FormatText(self.Description)
	end
	return ""
end

---@param character UUID|NETID|EsvCharacter|EclCharacter
---@return integer
function CustomStatDataBase:GetAmount(character)
	if self.Type == "CustomStatData" then
		if StringHelpers.IsNullOrWhitespace(self.UUID) then
			return 0
		end
		if type(character) == "userdata" then
			return character:GetCustomStat(self.UUID) or 0
		else
			character = Ext.GetCharacter(character)
			if character then
				return character:GetCustomStat(self.UUID) or 0
			end
		end
	end
	return 0
end

local function setAvailablePointsHandler(data)
	local AvailablePointsHandler = {}
	AvailablePointsHandler.__index = function(table, uuid)
		local parentTable = nil
		if isClient then
			parentTable = CustomStatSystem.PointsPool
		else
			parentTable = PersistentVars.CustomStatAvailablePoints
		end
		local pointId = data.ID
		if not StringHelpers.IsNullOrWhitespace(data.PointID) then
			pointId = data.PointID
		end
		local characterData = parentTable[uuid]
		if characterData then
			return characterData[pointId]
		end
		--fprint(LOGLEVEL.ERROR, "[LeaderLib:CustomStatsData:AvailablePoints] Failed to fetch available points for id (%s) and character(%s). Context(%s).", pointId, uuid, isClient and "CLIENT" or "SERVER")
		return 0
	end
	AvailablePointsHandler.__newindex = function(table, uuid, value)
		local pointId = data.ID
		if not StringHelpers.IsNullOrWhitespace(data.PointID) then
			pointId = data.PointID
		end
		CustomStatSystem:SetAvailablePoints(uuid, pointId, value, true)
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
								fprint(LOGLEVEL.ERROR, "[LeaderLib:CustomStatsConfig] Invalid default property (%s) with value type(%s)", property, t)
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
							fprint(LOGLEVEL.ERROR, "[LeaderLib:CustomStatsConfig] Invalid property (%s) with value type(%s)", property, t)
						end
					end
				end
				if propertyMap == statPropertyMap then
					data.Type = "CustomStatData"
					data.AvailablePoints = {}
					setAvailablePointsHandler(data)
				else
					data.Type = "CustomStatCategoryData"
				end
				setmetatable(data, CustomStatDataBase)
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
	--local filePath = string.format("Mods/%s/ModSettingsConfig.json", info.Directory)
	local filePath = string.format("Mods/%s/CustomStatsConfig.json", info.Directory)
	local file = Ext.LoadFile(filePath, "data")
	return file
end


---@return table<string, table<string, CustomStatDataBase>>
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
	if Vars.DebugMode then
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