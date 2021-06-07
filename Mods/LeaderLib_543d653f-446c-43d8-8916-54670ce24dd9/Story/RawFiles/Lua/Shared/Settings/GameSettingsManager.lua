if GameSettingsManager == nil then
	GameSettingsManager = {}
end
GameSettingsManager.__index = GameSettingsManager
function GameSettingsManager.GetSettings()
	return GameSettings.Settings
end

local isClient = Ext.IsClient()
local self = GameSettingsManager

function GameSettingsManager.Apply(sync)
	if not isClient and sync then
		SyncStatOverrides(GameSettings, true)
	end
	GameSettings:Apply()
end

function GameSettingsManager.Load(sync)
	local b,result = xpcall(function()
		return GameSettings:LoadString(Ext.LoadFile("LeaderLib_GameSettings.json"))
	end, debug.traceback)
	if b and result then
		if GameSettings.Settings ~= nil and GameSettings.Settings.Version ~= nil then
			if GameSettings.Settings.Version < GameSettings.Default.Version then
				GameSettings.Settings.Version = GameSettings.Default.Version
				GameSettingsManager.Save()
			end
		end
	else
		Ext.Print("[LeaderLib] Generating and saving LeaderLib_GameSettings.json")
		--Ext.PrintError("[LeaderLib:GameSettingsManager.Load]", result)
		GameSettings = Classes.LeaderLibGameSettings:Create()
		self.Save()
	end
	GameSettings.Loaded = true
	self.Apply(sync)
	return GameSettings
end

LoadGameSettings = GameSettingsManager.Load

function GameSettingsManager.Save()
	if GameSettings ~= nil then
		local b,err = xpcall(function() 
			GameSettings:Apply()
			Ext.SaveFile("LeaderLib_GameSettings.json", GameSettings:ToString())
		end, debug.traceback)
		if not b then
			Ext.PrintError(err)
		end
	elseif Vars.DebugMode then
		Ext.PrintWarning("[LeaderLib:GameSettingsManager:GameSettingsManager.Save] GameSettings is nil?")
	end
end

SaveGameSettings = GameSettingsManager.Save

function GameSettingsManager.Sync(id)
	if not isClient then
		if id ~= nil then
			Ext.PostMessageToUser(id, "LeaderLib_SyncGameSettings", GameSettings:ToString())
		else
			Ext.BroadcastMessage("LeaderLib_SyncGameSettings", GameSettings:ToString())
		end
	else
		Ext.PostMessageToServer("LeaderLib_SyncGameSettings", GameSettings:ToString())
	end
end

if not isClient then
	Ext.RegisterNetListener("LeaderLib_GameSettingsChanged", function(call, gameSettingsStr)
		fprint(LOGLEVEL.TRACE, "[%s]", call)
		GameSettings:LoadString(gameSettingsStr)
		self.Apply(true)
	end)
end

Ext.RegisterListener("GameStateChanged", function(from, to)
	fprint(LOGLEVEL.TRACE, "[GameStateChanged:%s] (%s) => (%s)", isClient and "CLIENT" or "SERVER", from, to)
end)

--Ext.RegisterListener("ModuleLoadStarted", LoadSettings)

Ext.RegisterListener("ModuleLoadStarted", function()
	--- So we can initialize the settings file in the main menu.
	GameSettingsManager.Load()
end)