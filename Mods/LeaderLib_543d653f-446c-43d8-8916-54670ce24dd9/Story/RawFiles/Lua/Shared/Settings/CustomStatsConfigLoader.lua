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

local properties = {
	DISPLAYNAME = {Name="DisplayName", Type = "string"},
	DESCRIPTION = {Name="Description", Type = "string"},
	ICON = {Name="Icon", Type = "string"},
	CREATE = {Name="Create", Type = "boolean"},
	TOOLTIPTYPE = {Name="TooltipType", Type = "string"}
}

local function LoadConfig(uuid, file)
	local settings = SettingsManager.GetMod(uuid, true)
	local config = Common.JsonParse(file)
	local loadedStats = nil
	if config ~= nil then
		if type(config.Stats) == "table" then
			loadedStats = {}
			for id,data in pairs(config.Stats) do
				if type(data) == "table" then
					local statData = {
						ID = id
					}
					for property,value in pairs(data) do
						if type(property) == "string" then
							local propKey = string.upper(property)
							local propData = properties[propKey]
							local t = type(value)
							if propData and t == propData.Type then
								statData[propData.Name] = value
							else
								fprint(LOGLEVEL.ERROR, "[LeaderLib:CustomStatsConfig] Invalid property (%s) with value type(%s)", property, t)
							end
						end
					end
					if statData.DisplayName then
						loadedStats[id] = statData
					end
				end
			end
		end
	end
	return loadedStats
end

local function TryFindConfig(info)
	--local filePath = string.format("Mods/%s/ModSettingsConfig.json", info.Directory)
	local filePath = string.format("Mods/%s/CustomStatsConfig.json", info.Directory)
	local file = Ext.LoadFile(filePath, "data")
	return file
end


---@return table<string, table<string, CustomStatData>>
local function LoadConfigFiles()
	local allStats = {}
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
					local loadedStats = LoadConfig(uuid, result)
					if loadedStats then
						allStats[uuid] = loadedStats
					end
				end
			end
		end
	end
	return allStats
end

return LoadConfigFiles