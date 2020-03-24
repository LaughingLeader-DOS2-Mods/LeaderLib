local function LeaderLib_GameSessionLoad()
	Ext.Print("[LeaderLib:Bootstrap.lua] Session is loading.")
end

local function LeaderLib_ModuleLoading()
	Ext.Print("[LeaderLib:Bootstrap.lua] Module is loading.")
	-- local loadOrder = Ext.GetModLoadOrder();
	-- Ext.Print("[LeaderLib:Bootstrap.lua] Mod Order:")
	-- for i=1,#loadOrder do
	-- 	local uuid = loadOrder[i]
	-- 	local mod = Ext.GetModInfo(uuid)
	-- 	Ext.Print("  " .. tostring(i) .. ". " .. mod.Name .. "(".. uuid .. ")")
	-- end
end

Ext.RegisterListener("SessionLoading", LeaderLib_GameSessionLoad)
Ext.RegisterListener("ModuleLoading", LeaderLib_ModuleLoading)

Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Shared\\LeaderLib_Common.lua")

Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server\\LeaderLib_Main.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server\\LeaderLib_Versioning.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server\\LeaderLib_Statuses.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server\\LeaderLib_GameMechanics.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server\\LeaderLib_GlobalSettings.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server\\LeaderLib_Debug.lua")