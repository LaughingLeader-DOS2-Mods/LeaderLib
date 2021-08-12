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
	BOOSTATTRIBUTE = {Name="BoostAttribute", Type = "string"},
	SUFFIX = {Name="Suffix", Type = "string"},
	ICON = {Name="Icon", Type = "string"},
	ICONWIDTH = {Name="IconWidth", Type = "number"},
	ICONHEIGHT = {Name="IconHeight", Type = "number"},
	USEPOINTS = {Name="UsePoints", Type = "boolean"},
}

local statPropertyMap = {
	STATTYPE = {Name="StatType", Type = "enum", Parse = function(val,t)
		if t == "string" then
			local id = string.lower(val)
			for k,v in pairs(SheetManager.Stats.Data.StatType) do
				if string.lower(k) == id then
					return k
				end
			end
		else
			fprint(LOGLEVEL.WARNING, "[SheetManager:ConfigLoader] Property value type [%s](%s) is incorrect for property StatType.", t, val)
		end
		return SheetManager.Stats.Data.StatType.Secondary
	end},
	SECONDARYSTATTYPE = {Name="SecondaryStatType", Type = "enum", Parse = function(val,t) 
		if t == "string" then
			local id = string.lower(val)
			for k,v in pairs(SheetManager.Stats.Data.SecondaryStatType) do
				if string.lower(k) == id then
					return k
				end
			end
		elseif t == "number" then
			local id = SheetManager.Stats.Data.SecondaryStatTypeInteger[val]
			if id then
				return id
			end
		end
		fprint(LOGLEVEL.WARNING, "[SheetManager:ConfigLoader] Property value type [%s](%s) is incorrect for property Stat StatType. Using default.", t, val)
		return SheetManager.Stats.Data.SecondaryStatType.Info
	end},
	SHEETICON = {Name="SheetIcon", Type = "string"},
	SHEETICONWIDTH = {Name="SheetIconWidth", Type = "number"},
	SHEETICONHEIGHT = {Name="SheetIconHeight", Type = "number"},
	SPACINGHEIGHT = {Name="SpacingHeight", Type = "number"},
	FRAME = {Name="Frame", Type = "number"},
}

local talentPropertyMap = {
	ISRACIAL = {Name="IsRacial", Type = "boolean"},
}

local abilityPropertyMap = {
	ISCIVIL = {Name="IsCivil", Type = "boolean"},
	GROUPID = {Name="GroupID", Type = "enum", Parse = function(val,t)
		if t == "string" then
			local id = string.lower(val)
			for k,v in pairs(SheetManager.Abilities.Data.GroupID) do
				if string.lower(k) == id then
					return v
				end
			end
		elseif t == "number" then
			local id = SheetManager.Abilities.Data.GroupID[val]
			if id then
				return val
			end
		end
		fprint(LOGLEVEL.WARNING, "[SheetManager:ConfigLoader] Property value type [%s](%s) is incorrect for property Ability GroupID. Using default.", t, val)
		return SheetManager.Abilities.Data.GroupID.Skills
	end},
}

local isClient = Ext.IsClient()

local function parseTable(tbl, propertyMap, modId, defaults, class, id_map)
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
							local propData = propertyMap[propKey] or basePropertyMap[propKey]
							local t = type(value)
							if propData then
								if propData.Type == "enum" then
									data[propData.Name] = propData.Parse(value,t)
								elseif (propData.Type == "any" or t == propData.Type) then
									data[propData.Name] = value
								end
							else
								fprint(LOGLEVEL.WARNING, "[LeaderLib:SheetManager.ConfigLoader] Defaults for stat(%s) has unknown property (%s) with value type(%s)", k, property, t)
							end
						end
					end
				end
				for property,value in pairs(v) do
					if type(property) == "string" then
						local propKey = string.upper(property)
						local propData = propertyMap[propKey] or basePropertyMap[propKey]
						local t = type(value)
						if propData then
							if propData.Type == "enum" then
								data[propData.Name] = propData.Parse(value,t)
							elseif (propData.Type == "any" or t == propData.Type) then
								data[propData.Name] = value
							end
						else
							fprint(LOGLEVEL.WARNING, "[LeaderLib:SheetManager.ConfigLoader] Stat(%s) has unknown property (%s) with value type(%s)", k, property, t)
						end
					end
				end
				id_map.NEXT_ID = id_map.NEXT_ID + 1
				data.GeneratedID = id_map.NEXT_ID
				if class then
					if class.SetDefaults then
						class.SetDefaults(data)
					end
					setmetatable(data, class)
				end
				tableData[k] = data
				id_map.Entries[data.GeneratedID] = data
			end
		end
	end
	return tableData
end

local function LoadConfig(uuid, file)
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
		local stats = parseTable(config.Stats, statPropertyMap, uuid, statDefaults, Classes.SheetStatData, SheetManager.Data.ID_MAP.Stats)
		local talents = parseTable(config.Talents, talentPropertyMap, uuid, talentDefaults, Classes.SheetTalentData, SheetManager.Data.ID_MAP.Talents)
		local abilities = parseTable(config.Abilities, abilityPropertyMap, uuid, abilityDefaults, Classes.SheetAbilityData, SheetManager.Data.ID_MAP.Abilities)

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


---@return table<string, table<string, SheetCustomStatBase>>
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

	if Vars.DebugMode and Vars.LeaderDebugMode then
		--local data = LoadConfig(ModuleUUID, Ext.LoadFile("Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Story/RawFiles/Lua/Shared/Debug/TestSheetEntriesConfig.json", "data"))
		local data = LoadConfig(ModuleUUID, Ext.LoadFile("Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Story/RawFiles/Lua/Shared/Debug/TestSheetEntriesConfig2.json", "data"))
		if data and data.Success then
			entries[ModuleUUID] = data
		end
	end
	return entries
end

return LoadConfigFiles