--[[
Format:
{
	"Flags": {
		{
			"Type" : "Global",
			"Entries" = {

			}}
		"FlagName" : 
		{
			"Enabled" : false,
			"FlagType" : "Global",
		},
	}
}
]]

local function GetValue(val)
	if val ~= nil then
		if type(val) == "string" and string.find(val, "ExtraData.") then
			val = string.gsub(val, "ExtraData.", "")
			return Ext.ExtraData[val] or 0
		end
	end
	return val
end

local function TryFindCallback(uuid, name)
	local b,result = pcall(function()
		local tbl = Mods[uuid]
		if tbl then
			local pathway = StringHelpers.Split(name, ".")
			local last = tbl
			for _,key in ipairs(pathway) do
				local value = last[key]
				if value then
					last = value
				else
					Ext.PrintError("Error trying to find global variable at Mods[%s].%s", uuid, name)
					break
				end
			end
			if last ~= nil and type(last) == "function" or type(last) == "table" then
				return last
			end
		end
		return nil
	end)
	
	return result
end

local function LoadModSettingsConfig(uuid, file)
	local settings = SettingsManager.GetMod(uuid, true)
	local config = Ext.JsonParse(file)
	if config ~= nil then
		if config.TitleColor ~= nil then
			settings.TitleColor = config.TitleColor
		end
		if config.Data ~= nil then
			if config.Data.Flags ~= nil then
				for _,data in pairs(config.Data.Flags) do
					local flagType = data.Type or "Global"
					if data.Entries ~= nil then
						for _,id in pairs(data.Entries) do
							settings.Global:AddLocalizedFlag(id, flagType, false)
						end
					end
					if data.Settings ~= nil then
						for id,paramSettings in pairs(data.Settings) do
							local flag = settings.Global.Flags[id]
							if flag ~= nil then
								for param,value in pairs(paramSettings) do
									flag[param] = value
								end
							end
						end
					end
				end
			end
			if config.Data.Variables ~= nil then
				local data = config.Data.Variables
				local namePrefix = data.NamePrefix or ""
				local defaultMin = data.DefaultMin
				local defaultMax = data.DefaultMax
				local defaultIncrement = data.DefaultIncrement or 1
				if data.Entries ~= nil then
					for id,varSettings in pairs(data.Entries) do
						local min = GetValue(varSettings.Min or defaultMin)
						local max = GetValue(varSettings.Max or defaultMax)
						local value = GetValue(varSettings.Value or 0)
						local increment = GetValue(varSettings.Increment or defaultIncrement)
						settings.Global:AddLocalizedVariable(id, namePrefix .. id, value, min, max, increment)
					end
				end
			end
			if config.Data.Buttons ~= nil then
				local buttonid = 0
				for _,data in pairs(config.Data.Buttons) do
					local id = data.ID or string.format("%s_%s", uuid, buttonid)
					local enabled = data.Enabled ~= nil and data.Enabled or true
					local callbackName = data.Callback
					local callback = nil
					if callbackName ~= nil then
						callback = TryFindCallback(uuid, callbackName)
					end
					local namePrefix = data.NamePrefix or ""
					settings.Global:AddLocalizedButton(id, namePrefix .. id, callback, data.Enabled, data.HostOnly)
					buttonid = buttonid + 1
				end
			end
		end
		--print(Ext.JsonStringify(config), Common.Dump(settings.Global))
		if config.MenuOrder ~= nil and type(config.MenuOrder) == "table" then
			settings.GetMenuOrder = function()
				return config.MenuOrder
			end
			-- for _,section in pairs(config.MenuOrder) do
			-- 	local name = section.Name
			-- 	local entries = section.Entries
			-- end
		end
	end
	return true
end

local function TryFindConfig(info)
	--local filePath = string.format("Mods/%s/ModSettingsConfig.json", info.Directory)
	local filePath = string.format("Mods/%s/ModSettingsConfig.json", info.Directory)
	local file = Ext.LoadFile(filePath, "data")
	if file ~= nil then
		Ext.Print("Loaded", filePath)
	end
	return file
end
--Mods/SuperEnemyUpgradeOverhaul_e21fcd37-daec-490d-baec-f6f3e83f1ac9/ModSettingsConfig.json
function SettingsManager.LoadConfigFiles()
	local order = Ext.GetModLoadOrder()
	for i,uuid in pairs(order) do
		if IgnoredMods[uuid] ~= true then
			local info = Ext.GetModInfo(uuid)
			if info ~= nil then
				local b,result = xpcall(TryFindConfig, debug.traceback, info)
				if not b then
					Ext.PrintError(result)
				elseif result ~= nil and result ~= "" then
					LoadModSettingsConfig(uuid, result)
				end
			end
		end
	end
end