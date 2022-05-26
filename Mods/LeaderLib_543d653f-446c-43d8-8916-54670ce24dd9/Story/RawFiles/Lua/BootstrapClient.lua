Ext.Require("BootstrapShared.lua")
Ext.Require("Client/_Init.lua")
Ext.Require("Shared/UI/CombatLog.lua")
Ext.Require("Shared/UI/MessageBox.lua")
Ext.Require("Shared/UI/Overhead.lua")
Ext.Require("Shared/System/TutorialManager.lua")
if Ext.IsDeveloperMode() then
	Ext.Require("Shared/Debug/SharedDebug.lua")
end

local function LeaderLib_SyncRanSeed(call, seedstr)
	LEADERLIB_RAN_SEED = math.tointeger(seedstr)
	fprint(LOGLEVEL.TRACE, "[LeaderLib:BootstrapClient.lua:LeaderLib_SyncRanSeed] Set [LEADERLIB_RAN_SEED] to (%s", LEADERLIB_RAN_SEED)
end

Ext.RegisterNetListener("LeaderLib_SyncRanSeed", LeaderLib_SyncRanSeed)

Ext.RegisterListener("SessionLoaded", function()
	if not SettingsManager.LoadedInitially then
		LoadGlobalSettings()
	end
end)

Events.Loaded:Invoke(nil)