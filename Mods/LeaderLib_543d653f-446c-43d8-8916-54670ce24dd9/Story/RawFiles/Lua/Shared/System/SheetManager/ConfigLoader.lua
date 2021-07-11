--[[
Format:
{
	"Talents": {
		"ID": {
			"DisplayName": "",
			"Description": "",
			"Icon": ""
		}
	},
	"Abilities": {
		"ID": {
			"DisplayName": "",
			"Description": "",
			"Icon": ""
		}
	},
	"Stats": {
		"ID": {
			"DisplayName": "",
			"Description": ""
		}
	}
}
]]

local basePropertyMap = {
	DISPLAYNAME = {Name="DisplayName", Type = "string"},
	DESCRIPTION = {Name="Description", Type = "string"},
	TOOLTIPTYPE = {Name="TooltipType", Type = "string"},
	VISIBLE = {Name="Visible", Type = "boolean"},
	SORTNAME = {Name="SortName", Type = "string"},
	SORTVALUE = {Name="SortValue", Type = "number"},
	LOADSTRINGKEY = {Name="LoadStringKey", Type = "boolean"},
}

local talentPropertyMap = {
	ICON = {Name="Icon", Type = "string"},
	ICONWIDTH = {Name="IconWidth", Type = "number"},
	ICONHEIGHT = {Name="IconHeight", Type = "number"},
}

local abilityPropertyMap = {
	ICON = {Name="Icon", Type = "string"},
	ICONWIDTH = {Name="IconWidth", Type = "number"},
	ICONHEIGHT = {Name="IconHeight", Type = "number"},
	GROUPID = {Name="GroupID", Type = "number"},
}

local isClient = Ext.IsClient()

local function parseTable(tbl, propertyMap, modId, defaults, class)
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
								fprint(LOGLEVEL.WARNING, "[LeaderLib:SheetManager.ConfigLoader] Defaults for stat(%s) has unknown property (%s) with value type(%s)", k, property, t)
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
							fprint(LOGLEVEL.WARNING, "[LeaderLib:SheetManager.ConfigLoader] Stat(%s) has unknown property (%s) with value type(%s)", k, property, t)
						end
					end
				end
				if class then
					if class.SetDefaults then
						class.SetDefaults(data)
					end
					setmetatable(data, class)
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
	local loaded = {}
	local statDefaults,talentDefaults,abilityDefaults = nil,nil,nil
	if config ~= nil then
		if config.Defaults then
			if config.Defaults.Stats then
				statDefaults = config.Defaults.Stats
			end
			if config.Defaults.Abilities then
				abilityDefaults = config.Defaults.Abilities
			end
			if config.Defaults.Talents then
				talentDefaults = config.Defaults.Talents
			end
		end
		local stats = parseTable(config.Stats, basePropertyMap, uuid, statDefaults, Classes.SheetStatData)
		local talents = parseTable(config.Talents, talentPropertyMap, uuid, talentDefaults, Classes.SheetTalentData)
		local abilities = parseTable(config.Ablities, abilityPropertyMap, uuid, abilityDefaults, Classes.SheetAbilityData)

		if stats then
			loaded.Stats = stats
			loaded.Success = true
		end
		if talents then
			loaded.Talents = talents
			loaded.Success = true
		end
		if abilities then
			loaded.Abilities = abilities
			loaded.Success = true
		end
	end
	return loaded
end

local function TryFindConfig(info)
	--local filePath = string.format("Mods/%s/ModSettingsConfig.json", info.Directory)
	local filePath = string.format("Mods/%s/CharacterSheetConfig.json", info.Directory)
	local file = Ext.LoadFile(filePath, "data")
	return file
end


---@return table<string, table<string, CustomStatDataBase>>
local function LoadConfigFiles()
	local entries = {}
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
					local data = LoadConfig(uuid, result)
					if data and data.Success then
						entries[uuid] = data
					end
				end
			end
		end
	end
	if Vars.DebugMode and CustomStatSystem.DebugEnabled then
		local data = LoadConfig(ModuleUUID, Ext.LoadFile("Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Story/RawFiles/Lua/Shared/Debug/TestSheetEntriesConfig.json", "data"))
		if data and data.Success then
			entries[ModuleUUID] = data
		end
	end
	return entries
end

return LoadConfigFiles