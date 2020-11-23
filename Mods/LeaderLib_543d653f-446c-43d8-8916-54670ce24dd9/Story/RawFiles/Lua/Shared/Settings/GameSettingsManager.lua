
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

			local settings = GameSettings.Settings.APSettings.Player
			local statChanges = {}
			for i,v in pairs(Osi.DB_IsPlayer:Get(nil)) do
				local character = Ext.GetCharacter(v[1])
				if character ~= nil then
					local userid = CharacterGetReservedUserID(v[1])
					local stats = {}
					if GameSettings.Settings.APSettings.Player.Enabled then
						if settings.Start > 0 then
							stats.APStart = settings.Start
						end
						if settings.Max > 0 then
							stats.APMaximum = settings.Max
						end
						if settings.Recovery > 0 then
							stats.APRecovery = settings.Recovery
						end
					else
						stats.APStart = character.Stats.APStart
						stats.APMaximum = settings.Stats.APMaximum
						stats.APRecovery = settings.Stats.APRecovery
					end
					
					table.insert(statChanges, {
						NetID = character.NetID,
						Stats = stats
					})
				end
			end
			Ext.BroadcastMessage("LeaderLib_SetGameSettingsStats", Ext.JsonStringify(statChanges), nil)

		elseif state == "Paused" then
			applyGameSettingsOnRunning = true
			syncGameSettingsOnRunning = sync ~= nil and sync or false
		end
	end
end

function LoadGameSettings(sync)
	local b,result = xpcall(function()
		local settings = Classes.LeaderLibGameSettings:Create()
		local tblString = Ext.LoadFile("LeaderLib_GameSettings.json")
		if tblString ~= nil then
			settings = settings:LoadString(tblString)
			return settings
		else
			Ext.PrintError("Failed to load LeaderLib_GameSettings.json. Does it exist?")
			return false
		end
	end, debug.traceback)
	if b and result ~= false then
		GameSettings = result
		if GameSettings.Settings ~= nil and GameSettings.Settings.Version ~= nil then
			if GameSettings.Settings.Version < GameSettings.Default.Version then
				GameSettings.Settings.Version = GameSettings.Default.Version
				SaveGameSettings()
			end
		end
	else
		if result == false then
			Ext.Print("[LeaderLib] Generating and saving LeaderLib_GameSettings.json")
		end
		--Ext.PrintError("[LeaderLib:LoadGameSettings]", result)
		GameSettings = Classes.LeaderLibGameSettings:Create()
		SaveGameSettings()
	end
	ApplyGameSettings(sync)
	return GameSettings
end

function SaveGameSettings()
	if GameSettings ~= nil then
		local b,err = xpcall(function() 
			Ext.SaveFile("LeaderLib_GameSettings.json", Ext.JsonStringify(GameSettings))
		end, debug.traceback)
		if not b then
			print(err)
		end
	elseif Ext.IsDeveloperMode() then
		Ext.PrintWarning("[LeaderLib:GameSettingsManager:SaveGameSettings] GameSettings is nil?")
	end
end

function SyncGameSettings(id)
	if Ext.IsServer() then
		if id ~= nil then
			Ext.PostMessageToUser(id, "LeaderLib_SyncGameSettings", Classes.MessageData:CreateFromTable("LeaderLibGameSettings", {Settings = GameSettings}):ToString())
		else
			Ext.BroadcastMessage("LeaderLib_SyncGameSettings", Classes.MessageData:CreateFromTable("LeaderLibGameSettings", {Settings = GameSettings}):ToString(), nil)
		end
	end
end

if Ext.IsClient() then
	Ext.RegisterNetListener("LeaderLib_SyncGameSettings", function(call, gameSettingsStr)
		local settings = Classes.MessageData:CreateFromString(gameSettingsStr)
		GameSettings = settings.Params.Settings
		setmetatable(GameSettings, Classes.LeaderLibGameSettings)
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
						print(string.format("[LeaderLib_SetCharacterStats] Set %s | %s => %s", k, current, target[k]))
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
		print("[GameSettingsManager:GameStateChanged]", from, to, applyGameSettingsOnRunning, syncGameSettingsOnRunning)
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