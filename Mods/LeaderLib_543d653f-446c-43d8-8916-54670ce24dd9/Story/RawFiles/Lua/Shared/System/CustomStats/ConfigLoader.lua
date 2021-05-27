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
}

---@class CustomStatDataBase
local CustomStatDataBase = {
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

local function parseTable(tbl, propertyMap, modId)
	local tableData = nil
	if type(tbl) == "table" then
		tableData = {}
		for k,v in pairs(tbl) do
			if type(v) == "table" then
				local data = {
					ID = k,
					Mod = modId
				}
				for property,value in pairs(v) do
					if type(property) == "string" then
						local propKey = string.upper(property)
						local propData = propertyMap[propKey]
						local t = type(value)
						if propData and t == propData.Type then
							data[propData.Name] = value
						else
							fprint(LOGLEVEL.ERROR, "[LeaderLib:CustomStatsConfig] Invalid property (%s) with value type(%s)", property, t)
						end
					end
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
	if config ~= nil then
		local categories = parseTable(config.Categories, categoryPropertyMap, uuid)
		local stats = parseTable(config.Stats, statPropertyMap, uuid)

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


---@return table<string, table<string, CustomCustomStatDataBase>>
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
	return allCategories,allStats
end

return LoadConfigFiles