SettingsManager = {
	LoadedInitially = false
}

Managers.Settings = SettingsManager

local isClient = Ext.IsClient()

local ModSettings = Classes.ModSettingsClasses.ModSettings

function SettingsManager.AddSettings(modSettings)
	if GlobalSettings == nil then
		GlobalSettings = {
			Mods = {},
			Version = StringHelpers.Join(".", Ext.Mod.GetMod(ModuleUUID).Info.ModVersion),
		}
	end
	if GlobalSettings.Mods == nil then
		GlobalSettings.Mods = {}
	end
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
---@param createIfMissing boolean|nil
---@param tryInitialLoad boolean|nil
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
	---@type ModSettings
	local modSettings = SettingsManager.GetMod(uuid, true, false)
	local isOldModSettings = tbl.globalflags ~= nil or tbl.integers ~= nil

	if not Ext.Mod.IsModLoaded(uuid) and modSettings ~= nil then
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
				if not isClient and _OSIRIS() then
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
						Ext.Utils.PrintError("[LeaderLib:ParseSettings] Error parsing mod settings:")
						Ext.Utils.PrintError(err)
					end
				end
			end
		end
	end
end

---@param skipEventInvoking boolean|nil Skip invoking the ModSettingsLoaded and GlobalSettingsLoaded events.
function LoadGlobalSettings(skipEventInvoking)
	local b,result = xpcall(function()
		SettingsManager.LoadConfigFiles()
		local saved_data = GameHelpers.IO.LoadJsonFile("LeaderLib_GlobalSettings.json")
		if saved_data then
			ParseSettings(saved_data)
		end
		return true
	end, debug.traceback)
	if not b then
		SettingsManager.LoadedInitially = false
		Ext.Utils.PrintError("[LeaderLib:LoadGlobalSettings] Error loading global settings:")
		Ext.Utils.PrintError(result)
		return false
	else
		SettingsManager.LoadedInitially = true
		local callOsiris = _OSIRIS()
		for uuid,v in pairs(GlobalSettings.Mods) do
			if callOsiris then
				v:ApplyToGame()
			end
			if skipEventInvoking ~= true then
				Events.ModSettingsLoaded:Invoke({UUID=uuid, Settings=v})
			end
		end
		if skipEventInvoking ~= true then
			Events.GlobalSettingsLoaded:Invoke({Settings=GlobalSettings, FromSync=false})
		end
		return result
	end
end

local syncTimerIndex = nil

function SaveGlobalSettings()
	if not SettingsManager.LoadedInitially then
		LoadGlobalSettings()
	end
	local b,err = xpcall(function()
		local export = ExportGlobalSettings(false)
		local json = Common.JsonStringify(export)
		Ext.SaveFile("LeaderLib_GlobalSettings.json", json)
		return true
	end, debug.traceback)
	if not b then
		Ext.Utils.PrintError("[LeaderLib:LoadGlobalSettings] Error loading global settings:")
		Ext.Utils.PrintError(err)
	elseif not isClient then
		if syncTimerIndex then
			Events.TimerFinished:Unsubscribe(syncTimerIndex)
			syncTimerIndex = nil
		end
		syncTimerIndex = Timer.StartOneshot("LeaderLib_SyncGlobalSetting", 250, function(e)
			SettingsManager.SyncGlobalSettings()
		end)
	end
end

if not isClient then
	function SettingsManager.SyncGlobalSettings()
		GameHelpers.Net.Broadcast("LeaderLib_SyncGlobalSettings", Common.JsonStringify(ExportGlobalSettings(true)))
	end
	
	function SettingsManager.SyncAllSettings(id, skipSyncStatOverrides)
		if id then
			fprint(LOGLEVEL.DEFAULT, "[LeaderLib:SettingsManager.SyncAllSettings] Syncing all settings with user (%s).", id)
		elseif Vars.DebugMode then
			Ext.Utils.Print("[LeaderLib:SettingsManager.SyncAllSettings] Syncing all settings with clients.")
		end
		local data = {
			GlobalSettings = ExportGlobalSettings(true),
			Features = Features
		}
		if type(id) == "number" then
			GameHelpers.Net.PostToUser(id, "LeaderLib_SyncAllSettings", Common.JsonStringify(data))
		else
			GameHelpers.Net.Broadcast("LeaderLib_SyncAllSettings", Common.JsonStringify(data))
		end
		GameSettingsManager.Sync(id)
		if skipSyncStatOverrides ~= true then
			SyncStatOverrides(GameSettings.Settings)
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
				mod_settings.Global:AddFlag(flag, "Global")
			end
		end
	end
	
	---@param uuid string
	---@param varname string
	---@param valuestr string
	function GlobalSettings_StoreGlobalInteger(uuid, varname, valuestr)
		local mod_settings = SettingsManager.GetMod(uuid, true)
		if mod_settings ~= nil then
			mod_settings.Global:AddVariable(varname, tonumber(valuestr))
		end
	end
	
	---@deprecated
	---@param modid string
	---@param author string
	---@param flag string
	function GlobalSettings_StoreGlobalFlag_Old(modid, author, flag)
	
	end
	
	---@deprecated
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
			local mod = Ext.Mod.GetMod(uuid)
			if mod ~= nil then
				mod_settings.Version = GameHelpers.GetModVersion(ModuleUUID, true)
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
	
	---@deprecated
	---@param modid string
	---@param author string
	function GlobalSettings_StoreModVersion_Old(modid, author, version_str)
	
	end

	--Called from LeaderLib_GlobalSettings_SaveIntegerVariable in Goals\LeaderLib_00_0_0_GlobalSettings.txt
	function GlobalSettings_UpdateIntegerVariable(uuid, id, value)
		uuid = StringHelpers.GetUUID(uuid)
		value = tonumber(value)
		if value then
			local settings = SettingsManager.GetMod(uuid, false, false)
			if settings then
				settings:SetVariable(id, value)
			else
				fprint(LOGLEVEL.WARNING, "[LeaderLib:GlobalSettings_UpdateIntegerVariable] Failed to get mod global settings for uuid (%s). Variable(%s) = %s", uuid, id, value)
			end
		end
	end
else
	local function SetGlobalSettingsMetatables()
		for _,v in pairs(GlobalSettings.Mods) do
			setmetatable(v, Classes.ModSettingsClasses.ModSettings)
			Classes.ModSettingsClasses.SettingsData.SetMetatables(v.Global)
			setmetatable(v.Global, Classes.ModSettingsClasses.SettingsData)
			for _,p in pairs(v.Profiles) do
				Classes.ModSettingsClasses.SettingsData.SetMetatables(p.Settings)
				setmetatable(p, Classes.ModSettingsClasses.ProfileSettings)
				setmetatable(p.Settings, Classes.ModSettingsClasses.SettingsData)
			end
		end
	end
	
	---@param settings GlobalSettings
	local function LoadGlobalSettingsOnClient(settings)
		if GlobalSettings ~= nil then
			GlobalSettings.Version = settings.Version
			for uuid,v in pairs(settings.Mods) do
				local target = v
				if GlobalSettings.Mods[uuid] == nil then
					GlobalSettings.Mods[uuid] = v
				else
					local existing = GlobalSettings.Mods[uuid]
					if existing.Global == nil then
						existing.Global = v.Global
					else
						existing.Global:CopySettings(v.Global)
					end
					if existing.Profiles == nil then
						existing.Profiles = v.Profiles
					else
						for k2,v2 in pairs(v.Profiles) do
							local existingProfile = existing.Profiles[k2]
							if existingProfile ~= nil then
								existingProfile.Settings:CopySettings(v2.Settings)
							else
								existing.Profiles[k2] = v2
							end
						end
					end
					existing.Version = v.Version
					target = existing
				end
				Events.ModSettingsSynced:Invoke({UUID=uuid, Settings=target})
			end
		else
			Ext.Utils.PrintError("[LeaderLib:CLIENT] GlobalSettings is nil.")
			GlobalSettings = settings
		end
		SetGlobalSettingsMetatables()
	end
	
	Ext.RegisterNetListener("LeaderLib_SyncAllSettings", function(call, dataString)
		local data = Common.JsonParse(dataString)
		if data.Features ~= nil then Features = data.Features end
		if data.GlobalSettings ~= nil then 
			LoadGlobalSettingsOnClient(data.GlobalSettings)
		end
		for uuid,v in pairs(GlobalSettings.Mods) do
			Events.ModSettingsLoaded:Invoke({UUID=uuid, Settings=v})
		end
		Events.GlobalSettingsLoaded:Invoke({Settings=GlobalSettings, FromSync=true})
	end)

	Ext.RegisterNetListener("LeaderLib_SyncGlobalSettings", function(cmd, dataString)
		local data = Common.JsonParse(dataString)
		if data ~= nil then
			LoadGlobalSettingsOnClient(data)
		end
	end)
end