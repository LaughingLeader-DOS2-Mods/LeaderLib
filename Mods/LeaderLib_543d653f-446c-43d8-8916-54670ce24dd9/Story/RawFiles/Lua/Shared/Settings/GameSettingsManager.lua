if GameSettingsManager == nil then
	GameSettingsManager = {}
end
Managers.GameSettings = GameSettingsManager

---@return LeaderLibGameSettings gameSettings
---@return boolean justLoaded
function GameSettingsManager.GetSettings()
	local justLoaded = false
	if not GameSettings.Loaded then
		GameSettingsManager.Load(false)
		justLoaded = true
	end
	return GameSettings.Settings,justLoaded
end

local _ISCLIENT = Ext.IsClient()
local self = GameSettingsManager

function GameSettingsManager.Apply(sync)
	if not _ISCLIENT and sync then
		SyncStatOverrides(GameSettings.Settings)
	end
	GameSettings:Apply()
end

---@return LeaderLibGameSettingsWrapper
function GameSettingsManager.Load(sync)
	local b,result = xpcall(function()
		return GameSettings:LoadString(GameHelpers.IO.LoadFile("LeaderLib_GameSettings.json"))
	end, debug.traceback)
	if b and result then
		if GameSettings.Settings ~= nil and GameSettings.Settings.Version ~= nil then
			if GameSettings.Settings.Version < GameSettings.Default.Version then
				GameSettings.Settings.Version = GameSettings.Default.Version
				GameSettingsManager.Save()
			end
		end
	else
		Ext.Utils.Print("[LeaderLib] Generating and saving LeaderLib_GameSettings.json")
		--Ext.Utils.PrintError("[LeaderLib:GameSettingsManager.Load]", result)
		GameSettings = Classes.LeaderLibGameSettings:Create()
		self.Save()
	end
	GameSettings.Loaded = true
	self.Apply(sync)
	return GameSettings
end

---@return LeaderLibGameSettingsWrapper
function GameSettingsManager.LoadClientSettings()
	if _ISCLIENT then
		local b,result = xpcall(function()
			local tbl = Common.JsonParse(GameHelpers.IO.LoadFile("LeaderLib_GameSettings.json"))
			if tbl ~= nil then
				if tbl.Settings ~= nil and type(tbl.Settings) == "table" and type(tbl.Settings.Client) == "table" then
					return tbl.Settings.Client
				end
			end
			return nil
		end, debug.traceback)
		if b and result then
			TableHelpers.AddOrUpdate(GameSettings.Settings.Client, result, false, true)
			GameSettings:ApplyClient()
			GameSettings.Loaded = true
		end
	end
	return GameSettings
end

LoadGameSettings = GameSettingsManager.Load

function GameSettingsManager.Save()
	if GameSettings ~= nil then
		local b,err = xpcall(function()
			GameSettings:Apply()
			Ext.SaveFile("LeaderLib_GameSettings.json", GameSettings:ToString(false))
		end, debug.traceback)
		if not b then
			Ext.Utils.PrintError(err)
		end
	elseif Vars.DebugMode then
		Ext.Utils.PrintWarning("[LeaderLib:GameSettingsManager:GameSettingsManager.Save] GameSettings is nil?")
	end
end

SaveGameSettings = GameSettingsManager.Save

function GameSettingsManager.Sync(id, excludeUser)
	if not GameSettings.Loaded then
		GameSettingsManager.Load(false)
	end
	if not _ISCLIENT then
		if id ~= nil then
			GameHelpers.Net.PostToUser(id, "LeaderLib_SyncGameSettings", GameSettings:ToString(true))
		else
			GameHelpers.Net.Broadcast("LeaderLib_SyncGameSettings", GameSettings:ToString(true), excludeUser)
		end
	else
		fprint(LOGLEVEL.WARNING, "[GameSettingsManager.Sync] Syncing with the host from the client-side is unsupported.")
	end
end

if not _ISCLIENT then
	Ext.RegisterNetListener("LeaderLib_GameSettingsChanged", function(call, gameSettingsStr, user)
		GameSettings:LoadString(gameSettingsStr)
		self.Apply(true)
		Events.GameSettingsChanged:Invoke({Settings = GameSettings.Settings, FromSync=true})
		--Resync to clients, but exclude the host that just sent us data
		if GameHelpers.Data.GetTotalUsers() > 1 then
			if user then
				user = GameHelpers.GetUUID(GetCurrentCharacter(user))
			end
			GameSettingsManager.Sync(nil, user)
		end
	end)
end

if Vars.DebugMode then
	Ext.Events.GameStateChanged:Subscribe(function(e)
		fprint(LOGLEVEL.TRACE, "[GameStateChanged:%s] (%s) => (%s)", _ISCLIENT and "CLIENT" or "SERVER", e.FromState, e.ToState)
	end)
end

Ext.Events.ModuleLoadStarted:Subscribe(function(e)
	--- So we can initialize the settings file in the main menu.
	GameSettingsManager.Load(false)
end)

Ext.Events.SessionLoaded:Subscribe(function (e)
	if not GameSettings.Loaded then
		GameSettingsManager.Load(false)
	elseif _ISCLIENT then
		GameSettingsManager.LoadClientSettings()
	end
	GlobalSettings.Version = StringHelpers.Join(".", Ext.Mod.GetMod(ModuleUUID).Info.ModVersion)
end, {Priority=9999})