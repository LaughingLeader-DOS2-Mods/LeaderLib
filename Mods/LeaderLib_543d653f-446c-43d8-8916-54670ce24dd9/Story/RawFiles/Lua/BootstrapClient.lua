Ext.Require("BootstrapShared.lua")
Ext.Require("Client/_Init.lua")

Ext.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/characterSheet.swf")
Ext.AddPathOverride("Public/Game/GUI/characterCreation.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/characterCreation.swf")

local function LeaderLib_SyncRanSeed(call, seedstr)
	_G["LEADERLIB_RAN_SEED"] = math.tointeger(seedstr)
	PrintDebug("[LeaderLib:BootstrapClient.lua:LeaderLib_SyncRanSeed] Set [LEADERLIB_RAN_SEED] to ("..tostring(_G["LEADERLIB_RAN_SEED"])..").")
end

Ext.RegisterNetListener("LeaderLib_SyncRanSeed", LeaderLib_SyncRanSeed)