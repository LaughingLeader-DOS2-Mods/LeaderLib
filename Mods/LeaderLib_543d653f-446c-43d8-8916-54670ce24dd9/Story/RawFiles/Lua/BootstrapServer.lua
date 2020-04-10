-- local function LeaderLib_GameSessionLoad()
-- 	Ext.Print("[LeaderLib:Bootstrap.lua] Session is loading.")
-- end

-- local function LeaderLib_ModuleLoading()
-- 	Ext.Print("[LeaderLib:Bootstrap.lua] Module is loading.")
-- end

-- Ext.RegisterListener("SessionLoading", LeaderLib_GameSessionLoad)
-- Ext.RegisterListener("ModuleLoading", LeaderLib_ModuleLoading)

Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "BootstrapShared.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_Main.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_Versioning.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_Statuses.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_GameMechanics.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_GlobalSettings.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_Debug.lua")