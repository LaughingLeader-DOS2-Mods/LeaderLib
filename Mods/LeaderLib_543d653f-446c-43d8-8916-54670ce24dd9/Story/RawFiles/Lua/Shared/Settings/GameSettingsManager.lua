
local applyGameSettingsOnRunning = false
local syncGameSettingsOnRunning = false

function ApplyGameSettings(sync)
	if GameSettings.Settings.BackstabSettings.Player.Enabled or GameSettings.Settings.BackstabSettings.NPC.Enabled then
		EnableFeature("BackstabCalculation")
	end
	if Ext.IsServer() then
		local state = Ext.GetGameState()
		if state == "Running" then
			applyGameSettingsOnRunning = false
			syncGameSettingsOnRunning = false
			if sync == true then
				SyncGameSettings()
			end
			SyncStatOverrides(GameSettings, true)
			GameSettings:Apply()
		elseif state == "Paused" then
			applyGameSettingsOnRunning = true
			syncGameSettingsOnRunning = sync ~= nil and sync or false
		end
	end
end

function LoadGameSettings(sync)
	local b,result = xpcall(function()
		return GameSettings:LoadString(Ext.LoadFile("LeaderLib_GameSettings.json"))
	end, debug.traceback)
	if b and result then
		if GameSettings.Settings ~= nil and GameSettings.Settings.Version ~= nil then
			if GameSettings.Settings.Version < GameSettings.Default.Version then
				GameSettings.Settings.Version = GameSettings.Default.Version
				SaveGameSettings()
			end
		end
	else
		Ext.Print("[LeaderLib] Generating and saving LeaderLib_GameSettings.json")
		--Ext.PrintError("[LeaderLib:LoadGameSettings]", result)
		GameSettings = Classes.LeaderLibGameSettings:Create()
		SaveGameSettings()
	end
	GameSettings.Loaded = true
	ApplyGameSettings(sync)
	return GameSettings
end

function SaveGameSettings()
	if GameSettings ~= nil then
		local b,err = xpcall(function() 
			GameSettings:Apply()
			Ext.SaveFile("LeaderLib_GameSettings.json", GameSettings:ToString())
		end, debug.traceback)
		if not b then
			Ext.PrintError(err)
		end
	elseif Vars.DebugMode then
		Ext.PrintWarning("[LeaderLib:GameSettingsManager:SaveGameSettings] GameSettings is nil?")
	end
end

function SyncGameSettings(id)
	if Ext.IsServer() then
		if id ~= nil then
			Ext.PostMessageToUser(id, "LeaderLib_SyncGameSettings", GameSettings:ToString())
		else
			Ext.BroadcastMessage("LeaderLib_SyncGameSettings", GameSettings:ToString())
		end
	end
end

if Ext.IsClient() then
	Ext.RegisterNetListener("LeaderLib_SyncGameSettings", function(call, gameSettingsStr)
		local clientSettings = {}
		if GameSettings and GameSettings.Settings and GameSettings.Settings.Client then
			for k,v in pairs(GameSettings.Settings.Client) do
				clientSettings[k] = v
			end
		end
		GameSettings:LoadString(gameSettingsStr)
		if not GameSettings.Settings.Client then
			GameSettings.Settings.Client = clientSettings
		else
			for k,v in pairs(clientSettings) do
				GameSettings.Settings.Client[k] = v
			end
		end
		GameSettings:Apply()
		GameSettings.Loaded = true
		Ext.Print("[LeaderLib_SyncGameSettings] Synced game settings from server.")
	end)

	local Qualifiers = {
		Strength = true,
		Finesse = true,
		Intelligence = true,
		Constitution = true,
		Memory = true,
		Wits = true,
		Sight = true,
		Hearing = true,
		CriticalChance = true,
		["Act strength"] = true,
	}
	
	---@param tbl table
	local function SetCharacterStats(target, tbl)
		for k,v in pairs(tbl) do
			if type(v) == "table" and target[k] ~= nil then
				SetCharacterStats(target[k], v)
			else
				local b,err = xpcall(function()
					if target[k] ~= nil then
						local current = target[k]
						if Qualifiers[k] == true then
							if v == "None" then
								target[k] = "0"
							else
								target[k] = tostring(v)
							end
						else
							target[k] = v
						end
						if Vars.DebugMode then
							PrintLog("[LeaderLib_SetCharacterStats] Set %s | %s => %s", k, current, target[k])
						end
					end
				end, debug.traceback)
				if not b then
					Ext.PrintError(err)
				end
			end
		end
	end

	Ext.RegisterNetListener("LeaderLib_SetGameSettingsStats", function(cmd, dataStr)
		local data = Common.JsonParse(dataStr)
		if data ~= nil then
			for _,v in pairs(data) do
				if v.NetID ~= nil and v.Stats ~= nil then
					local character = Ext.GetCharacter(v.NetID)
					if character ~= nil then
						SetCharacterStats(character.Stats.DynamicStats[1], v.Stats)
					end
				end
			end
			SaveGameSettings()
		end
	end)
end

if Ext.IsServer() then
	Ext.RegisterNetListener("LeaderLib_GameSettingsChanged", function(call, gameSettingsStr)
		GameSettings:LoadString(gameSettingsStr)
		ApplyGameSettings()
	end)

	Ext.RegisterListener("GameStateChanged", function(from, to)
		if Vars.DebugMode then
			PrintLog("[GameSettingsManager:GameStateChanged] (%s => %s) applyGameSettingsOnRunning(%s) syncGameSettingsOnRunning(%s)", from, to, applyGameSettingsOnRunning, syncGameSettingsOnRunning)
		end
		if to == "Running" and from == "Paused" then
			if applyGameSettingsOnRunning or syncGameSettingsOnRunning then
				ApplyGameSettings(syncGameSettingsOnRunning)
			end
		end
	end)
end

--Ext.RegisterListener("ModuleLoadStarted", LoadSettings)

Ext.RegisterListener("ModuleLoadStarted", function()
	--- So we can initialize the settings file in the main menu.
	LoadGameSettings()
end)

Ext.RegisterListener("SessionLoading", function()
	if Ext.Version() >= 53 then
		SettingsManager.LoadConfigFiles()
	end
end)