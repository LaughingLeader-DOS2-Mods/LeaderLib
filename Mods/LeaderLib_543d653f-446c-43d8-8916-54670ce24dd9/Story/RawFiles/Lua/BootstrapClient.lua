Ext.Require("BootstrapShared.lua")
Ext.Require("Client/_Init.lua")
Ext.Require("Shared/UI/CombatLog.lua")
Ext.Require("Shared/UI/MessageBox.lua")
Ext.Require("Shared/UI/Overhead.lua")
Ext.Require("Shared/System/TutorialManager.lua")

local function LeaderLib_SyncRanSeed(call, seedstr)
	_G["LEADERLIB_RAN_SEED"] = math.tointeger(seedstr)
	PrintDebug("[LeaderLib:BootstrapClient.lua:LeaderLib_SyncRanSeed] Set [LEADERLIB_RAN_SEED] to ("..tostring(_G["LEADERLIB_RAN_SEED"])..").")
end

Ext.RegisterNetListener("LeaderLib_SyncRanSeed", LeaderLib_SyncRanSeed)

InvokeListenerCallbacks(Listeners.Loaded)

Ext.RegisterListener("SessionLoaded", function()
	if not SettingsManager.LoadedInitially then
		LoadGlobalSettings()
	end
end)