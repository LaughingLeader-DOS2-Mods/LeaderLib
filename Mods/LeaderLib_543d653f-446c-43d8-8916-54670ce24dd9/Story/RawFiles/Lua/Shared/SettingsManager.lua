SettingsManager = {}

local FlagData = Classes.ModSettingsClasses.FlagData
local VariableData = Classes.ModSettingsClasses.VariableData
local SettingsData = Classes.ModSettingsClasses.SettingsData
local ProfileSettings = Classes.ModSettingsClasses.ProfileSettings
local ModSettings = Classes.ModSettingsClasses.ModSettings

function SettingsManager.AddSettings(modSettings)
	if GlobalSettings == nil then
		GlobalSettings = {
			Mods = {},
			Version = Ext.GetModInfo("7e737d2f-31d2-4751-963f-be6ccc59cd0c").Version,
		}
	end
	if GlobalSettings.Mods == nil then
		GlobalSettings.Mods = {}
	end
	-- print("[SHARED] Added ", modSettings.Name, "IsClient", Ext.IsClient())
	-- if Ext.IsClient() then
	-- 	print(Common.Dump(GlobalSettings))
	-- end
	GlobalSettings.Mods[modSettings.UUID] = modSettings
end

function SettingsManager.Remove(uuid)
	GlobalSettings.Mods[uuid] = nil
end

---@param uuid string
---@param createIfMissing boolean|nil
---@return ModSettings|nil
function SettingsManager.GetMod(uuid, createIfMissing)
	if uuid ~= nil and uuid ~= "" then
		local data = GlobalSettings.Mods[uuid]
		if data ~= nil then
			return data
		end
		if createIfMissing == true then
			local settings = ModSettings:Create(uuid)
			table.insert(GlobalSettings.Mods, settings)
			return settings
		end
	end
	return nil
end

local function ExportGlobalSettings(forSyncing)
	local globalSettings = {
		Mods = {},
		Version = GlobalSettings.Version
	}
	for uuid,v in pairs(GlobalSettings.Mods) do
		v:Update()
		globalSettings.Mods[uuid] = v:Copy(forSyncing)
	end
	return globalSettings
end

function SettingsManager.LoadAllModSettings()
	local mods = Ext.GetModLoadOrder()
	for i,uuid in pairs(mods) do
		if IgnoredMods[uuid] ~= true then
			local info = Ext.GetModInfo(uuid)
			local settingsFile = info.Directory .. "/ModSettings.json"
			local file = Ext.LoadFile(settingsFile)
			if file ~= nil then
				local data = Ext.JsonParse(file)
				if data ~= nil then
					local settings = SettingsManager.GetMod(uuid, true)
					if data.Flags ~= nil then
						for id,flagData in pairs(data.Flags) do
							local flagType = flagData.FlagType or "Global"
							local enabled = flagData.Enabled or false
							local displayName = flagData.DisplayName
							local tooltip = flagData.Tooltip
							local canExport = flagData.CanExport or true
							settings.Global:AddFlag(id, flagType, enabled, displayName, tooltip, canExport)
						end
					end
				end
			end
		end
	end
end

if Ext.IsServer() then
	function SettingsManager.Sync()
		Ext.BroadcastMessage("LeaderLib_SyncGlobalSettings", Ext.JsonStringify(ExportGlobalSettings(true)), nil)
	end
	
	function SettingsManager.SyncAllSettings(id, skipSyncStatOverrides)
		Ext.Print("[LeaderLib:SettingsManager.SyncAllSettings] Syncing all settings with clients.")
		local data = {
			GlobalSettings = ExportGlobalSettings(true),
			Features = Features,
			GameSettings = GameSettings
		}
		if id ~= nil then
			Ext.PostMessageToUser(id, "LeaderLib_SyncAllSettings", Ext.JsonStringify(data))
		else
			Ext.BroadcastMessage("LeaderLib_SyncAllSettings", Ext.JsonStringify(data), nil)
		end
		if skipSyncStatOverrides ~= true then
			SyncStatOverrides(GameSettings, true)
		end
	end
	
	---@param uuid string
	---@param tbl ModSettings
	local function ParseModData(uuid, tbl)
		local modSettings = SettingsManager.GetMod(uuid, true)
		local isOldModSettings = tbl.globalflags ~= nil or tbl.integers ~= nil
	
		if not Ext.IsModLoaded(uuid) and modSettings ~= nil then
			modSettings.Name = tbl.Name or ""
		end
	
		modSettings.LoadedExternally = true
	
		if not isOldModSettings then
			if tbl.Global ~= nil then
				if tbl.Global.Flags ~= nil then
					for flag,data in pairs(tbl.Global.Flags) do
						modSettings.Global:AddFlag(flag, data.FlagType or "Global", data.Enabled)
					end
				end
				if tbl.Global.Variables ~= nil then
					for name,data in pairs(tbl.Global.Variables) do
						modSettings.Global:AddVariable(name, data.Value)
					end
				end
			end
		else
			local flags = tbl["globalflags"]
			if flags ~= nil and type(flags) == "table" then
				for flag,v in pairs(flags) do
					if modSettings ~= nil then
						modSettings.Global:AddFlag(flag, "Global", v)
					end
				end
			end
			local integers = tbl["integers"]
			if integers ~= nil and type(integers) == "table" then
				for varname,v in pairs(integers) do
					local intnum = math.tointeger(v)
					if modSettings ~= nil then
						modSettings.Global:AddVariable(varname, intnum)
						Osi.LeaderLib_GlobalSettings_SetIntegerVariable(uuid, varname, intnum)
					end
				end
			end
		end
		return true
	end
	
	local function ParseSettings(tbl)
		for k,v in pairs(tbl) do
			if Common.StringEquals(string.lower(k), "mods") then
				for k2,v2 in pairs(v) do
					local uuid = v2["uuid"] or v2["UUID"]
					if not StringHelpers.IsNullOrEmpty(uuid) then
						local status,err = xpcall(function()
							ParseModData(uuid, v2)
							return true
						end, debug.traceback)
						if not status then
							Ext.PrintError("[LeaderLib:ParseSettings] Error parsing mod settings:")
							Ext.PrintError(err)
						end
					end
				end
			end
		end
	end
	
	function LoadGlobalSettings()
		local status,err = xpcall(function()
			local json = NRD_LoadFile("LeaderLib_GlobalSettings.json")
			if json ~= nil and json ~= "" then
				local json_tbl = Ext.JsonParse(json)
				ParseSettings(json_tbl)
			end
			return true
		end, debug.traceback)
		if not status then
			Ext.PrintError("[LeaderLib:LoadGlobalSettings] Error loading global settings:")
			Ext.PrintError(err)
		else
			if Ext.OsirisIsCallable() or Ext.GetGameState() == "Running" then
				for uuid,v in pairs(GlobalSettings.Mods) do
					v:ApplyToGame()
				end
			end
			if #Listeners.ModSettingsLoaded > 0 then
				for i,callback in pairs(Listeners.ModSettingsLoaded) do
					local status,err = xpcall(callback, debug.traceback, GlobalSettings)
					if not status then
						Ext.PrintError("[LeaderLib:LoadGlobalSettings] Error invoking callback for ModSettingsLoaded:")
						Ext.PrintError(err)
					end
				end
			end
		end
	end
	
	function SaveGlobalSettings()
		local status,err = xpcall(function()
			local export = ExportGlobalSettings()
			local json = Ext.JsonStringify(export)
			NRD_SaveFile("LeaderLib_GlobalSettings.json", json)
			PrintDebug("[LeaderLib] Saved LeaderLib_GlobalSettings.json")
			return true
		end, debug.traceback)
		if not status then
			Ext.PrintError("[LeaderLib:LoadGlobalSettings] Error loading global settings:")
			Ext.PrintError(err)
		end
	end
	
	function GlobalSettings_Initialize()
		Osi.LeaderLib_GlobalSettings_Internal_Init()
	end
	
	---@param uuid string
	---@param flag string
	function GlobalSettings_StoreGlobalFlag(uuid, flag)
		if flag ~= nil then
			local mod_settings = SettingsManager.GetMod(uuid, true)
			if mod_settings ~= nil then
				mod_settings.Global:AddFlag(flag)
			end
		end
	end
	
	---@param uuid string
	---@param varname string
	---@param valuestr string
	function GlobalSettings_StoreGlobalInteger(uuid, varname, valuestr)
		local mod_settings = SettingsManager.GetMod(uuid, true)
		if mod_settings ~= nil then
			mod_settings.Global:AddVariable(varname, math.tointeger(tonumber(valuestr)))
		end
	end
	
	---@param modid string
	---@param author string
	---@param flag string
	function GlobalSettings_StoreGlobalFlag_Old(modid, author, flag)
	
	end
	
	---@param modid string
	---@param author string
	---@param varname string
	---@param defaultvalue string
	function GlobalSettings_StoreGlobalInteger_Old(modid, author, varname, defaultvalue)
	
	end
	
	---@param uuid string
	function GlobalSettings_GetAndStoreModVersion(uuid)
		local mod_settings = SettingsManager.GetMod(uuid, true)
		if mod_settings ~= nil then
			local modinfo = Ext.GetModInfo(uuid)
			if modinfo ~= nil then
				mod_settings.Version = modinfo.Version
			end
		end
	end
	
	---@param uuid string
	---@param version string
	function GlobalSettings_StoreModVersion(uuid, version)
		local mod_settings = SettingsManager.GetMod(uuid, true)
		if mod_settings ~= nil then
			mod_settings.Version = math.tointeger(version)
		end
	end
	
	---@param modid string
	---@param author string
	function GlobalSettings_StoreModVersion_Old(modid, author, version_str)
	
	end
end