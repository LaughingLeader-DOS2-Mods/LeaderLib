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
		for id,tbl in pairs(Mods) do
			if tbl.ModuleUUID == uuid then
				if tbl[name] ~= nil then
					return tbl[name]
				end
				local pathway = StringHelpers.Split(name, ".")
				local last = tbl
				for _,key in ipairs(pathway) do
					local value = last[key]
					if value then
						last = value
					end
				end
				if last ~= nil and type(last) == "function" or type(last) == "table" then
					return last
				end
				fprint(LOGLEVEL.WARNING, "[LeaderLib:TryFindCallback] Failed to find global variable within Mods[%s].%s", id, name)
				return nil
			end
		end
		fprint(LOGLEVEL.ERROR, "[LeaderLib:TryFindCallback] Failed to find global mod table for UUID (%s) and name (%s)", uuid, name)
		return nil
	end)
	
	return result
end

local function LoadModSettingsConfig(uuid, file)
	local config = Common.JsonParse(file)
	if config ~= nil then
		if config.Enabled == false then
			return false
		end
		local settings = SettingsManager.GetMod(uuid, true)
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
							if StringHelpers.Equals(id, "all", true, true) then
								for flagId,flagData in pairs(settings.Global.Flags) do
									for param,value in pairs(paramSettings) do
										flagData[param] = value
									end
								end
							else
								local flagData = settings.Global.Flags[id]
								if flagData ~= nil then
									for param,value in pairs(paramSettings) do
										flagData[param] = value
									end
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
				if data.Settings ~= nil then
					for id,paramSettings in pairs(data.Settings) do
						if StringHelpers.Equals(id, "all", true, true) then
							for _,varData in pairs(settings.Global.Variables) do
								for param,value in pairs(paramSettings) do
									varData[param] = value
								end
							end
						else
							local varData = settings.Global.Variables[id]
							if varData ~= nil then
								for param,value in pairs(paramSettings) do
									varData[param] = value
								end
							end
						end
					end
				end
			end
			if config.Data.Buttons ~= nil then
				local data = config.Data.Buttons
				local buttonid = 0
				for _,buttonData in pairs(data) do
					local id = buttonData.ID or string.format("%s_%s", uuid, buttonid)
					local enabled = buttonData.Enabled ~= nil and buttonData.Enabled or buttonData.Enabled == nil and true
					local callbackName = buttonData.Callback
					local callback = nil
					if callbackName ~= nil then
						callback = TryFindCallback(uuid, callbackName)
					end
					local namePrefix = buttonData.NamePrefix or ""
					settings.Global:AddLocalizedButton(id, namePrefix .. id, callback, buttonData.Enabled, buttonData.HostOnly)
					buttonid = buttonid + 1
				end
				if data.Settings ~= nil then
					for id,paramSettings in pairs(data.Settings) do
						if StringHelpers.Equals(id, "all", true, true) then
							for _,buttonData in pairs(settings.Global.Buttons) do
								for param,value in pairs(paramSettings) do
									buttonData[param] = value
								end
							end
						else
							local buttonData = settings.Global.Buttons[id]
							if buttonData ~= nil then
								for param,value in pairs(paramSettings) do
									buttonData[param] = value
								end
							end
						end
					end
				end
			end
		end
		--print(Common.JsonStringify(config), Common.Dump(settings.Global))
		if config.MenuOrder ~= nil and type(config.MenuOrder) == "table" then
			settings.GetMenuOrder = function()
				return config.MenuOrder
			end
			-- for _,section in pairs(config.MenuOrder) do
			-- 	local name = section.Name
			-- 	local entries = section.Entries
			-- end
		end
		return true
	end
	return false
end

local function TryFindConfig(info)
	local filePath = string.format("Mods/%s/ModSettingsConfig.json", info.Directory)
	local file = Ext.LoadFile(filePath, "data")
	return file
end

function SettingsManager.LoadConfigFiles()
	local order = Ext.GetModLoadOrder()
	for i,uuid in pairs(order) do
		if IgnoredMods[uuid] ~= true then
			local info = Ext.GetModInfo(uuid)
			if info ~= nil then
				local b,result = xpcall(TryFindConfig, debug.traceback, info)
				if not b then
					Ext.PrintError(result)
				elseif not StringHelpers.IsNullOrEmpty(result) then
					LoadModSettingsConfig(uuid, result)
				end
			end
		end
	end
end