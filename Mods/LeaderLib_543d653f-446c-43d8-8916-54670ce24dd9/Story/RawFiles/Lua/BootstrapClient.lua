Ext.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/Overrides/characterSheet.swf")
--Ext.AddPathOverride("Public/Game/GUI/characterCreation.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/Overrides/characterCreation.swf")
--Ext.AddPathOverride("Public/Game/GUI/statsPanel_c.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/Overrides/statsPanel_c.swf")
--Ext.AddPathOverride("Public/Game/GUI/characterCreation_c.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/Overrides/characterCreation_c.swf")

Ext.Require("BootstrapShared.lua")
Ext.Require("Client/_Init.lua")

local function LeaderLib_SyncRanSeed(call, seedstr)
	_G["LEADERLIB_RAN_SEED"] = math.tointeger(seedstr)
	PrintDebug("[LeaderLib:BootstrapClient.lua:LeaderLib_SyncRanSeed] Set [LEADERLIB_RAN_SEED] to ("..tostring(_G["LEADERLIB_RAN_SEED"])..").")
end

Ext.RegisterNetListener("LeaderLib_SyncRanSeed", LeaderLib_SyncRanSeed)

InvokeListenerCallbacks(Listeners.Loaded)