SettingsManager = {
	LoadedInitially = false
}

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
	if GlobalSettings.Mods[uuid] ~= nil then
		GlobalSettings.Mods[uuid] = nil
		if Ext.GetGameState() == "Running" then
			SettingsManager.SyncGlobalSettings()
		end
	end
end

---@param uuid string
---@param createIfMissing ?boolean
---@param tryInitialLoad ?boolean
---@return ModSettings|nil
function SettingsManager.GetMod(uuid, createIfMissing, tryInitialLoad)
	if not StringHelpers.IsNullOrEmpty(uuid) then
		if tryInitialLoad and not SettingsManager.LoadedInitially then
			LoadGlobalSettings()
		end
		local data = GlobalSettings.Mods[uuid]
		if data ~= nil then
			return data
		elseif createIfMissing == true then
			local settings = ModSettings:Create(uuid)
			GlobalSettings.Mods[uuid] = settings
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

---@param uuid string
---@param tbl ModSettings
local function ParseModData(uuid, tbl)
	local modSettings = SettingsManager.GetMod(uuid, true, false)
	local isOldModSettings = tbl.globalflags ~= nil or tbl.integers ~= nil

	if not Ext.IsModLoaded(uuid) and modSettings ~= nil then
		modSettings.Name = tbl.Name or ""
	end

	modSettings.LoadedExternally = true

	if not isOldModSettings then
		if tbl.Global ~= nil then
			if tbl.Global.Flags ~= nil then
				for flag,data in pairs(tbl.Global.Flags) do
					modSettings.Global:AddFlag(flag, data.FlagType or "Global", data.Enabled, nil, nil, true, true)
				end
			end
			if tbl.Global.Variables ~= nil then
				for name,data in pairs(tbl.Global.Variables) do
					modSettings.Global:AddVariable(name, data.Value, nil, nil, nil, nil, nil, true, true)
				end
			end
		end
	elseif modSettings ~= nil then
		local flags = tbl["globalflags"]
		if flags ~= nil and type(flags) == "table" then
			for flag,v in pairs(flags) do
				modSettings.Global:AddFlag(flag, "Global", v, nil, nil, true, true)
			end
		end
		local integers = tbl["integers"]
		if integers ~= nil and type(integers) == "table" then
			for varname,v in pairs(integers) do
				local intnum = math.tointeger(v)
				modSettings.Global:AddVariable(varname, intnum, nil, nil, nil, nil, nil, true, true)
				if Ext.IsServer() and Ext.OsirisIsCallable() then
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
	local b,result = xpcall(function()
		SettingsManager.LoadConfigFiles()
		local saved_data = GameHelpers.IO.LoadJsonFile("LeaderLib_GlobalSettings.json")
		if saved_data then
			ParseSettings(saved_data)
		end
		for uuid,v in pairs(GlobalSettings.Mods) do
			InvokeListenerCallbacks(Listeners.ModSettingsLoaded[uuid], v)
		end
		return true
	end, debug.traceback)
	if not b then
		SettingsManager.LoadedInitially = false
		Ext.PrintError("[LeaderLib:LoadGlobalSettings] Error loading global settings:")
		Ext.PrintError(result)
		return false
	else
		SettingsManager.LoadedInitially = true
		if Ext.OsirisIsCallable() then
			for uuid,v in pairs(GlobalSettings.Mods) do
				v:ApplyToGame()
			end
		end
		InvokeListenerCallbacks(Listeners.ModSettingsLoaded.All, GlobalSettings)
		for k,v in pairs(Listeners.ModSettingsLoaded) do
			if k ~= "All" then
				InvokeListenerCallbacks(v)
			end
		end
		return result
	end
end

function SaveGlobalSettings()
	if not SettingsManager.LoadedInitially then
		LoadGlobalSettings()
	end
	local status,err = xpcall(function()
		local export = ExportGlobalSettings(false)
		local json = Common.JsonStringify(export)
		Ext.SaveFile("LeaderLib_GlobalSettings.json", json)
		PrintDebug("[LeaderLib] Saved LeaderLib_GlobalSettings.json")
		return true
	end, debug.traceback)
	if not status then
		Ext.PrintError("[LeaderLib:LoadGlobalSettings] Error loading global settings:")
		Ext.PrintError(err)
	end
end

if Ext.IsServer() then
	function SettingsManager.SyncGlobalSettings()
		GameHelpers.Net.Broadcast("LeaderLib_SyncGlobalSettings", Common.JsonStringify(ExportGlobalSettings(true)))
	end
	
	function SettingsManager.SyncAllSettings(id, skipSyncStatOverrides)
		if id then
			fprint(LOGLEVEL.DEFAULT, "[LeaderLib:SettingsManager.SyncAllSettings] Syncing all settings with user (%s).", id)
		else	
			Ext.Print("[LeaderLib:SettingsManager.SyncAllSettings] Syncing all settings with clients.")
		end
		local data = {
			GlobalSettings = ExportGlobalSettings(true),
			Features = Features,
			GameSettings = GameSettings
		}
		if type(id) == "number" then
			GameHelpers.Net.PostToUser(id, "LeaderLib_SyncAllSettings", Common.JsonStringify(data))
		else
			GameHelpers.Net.Broadcast("LeaderLib_SyncAllSettings", Common.JsonStringify(data))
		end
		if skipSyncStatOverrides ~= true then
			SyncStatOverrides(GameSettings, true)
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