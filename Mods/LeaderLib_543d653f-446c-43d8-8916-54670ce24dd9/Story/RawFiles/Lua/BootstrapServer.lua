-- local function LeaderLib_GameSessionLoad()
-- 	Ext.Print("[LeaderLib:Bootstrap.lua] Session is loading.")
-- end

-- local genericPresetOverrideTest = "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/CharacterCreation/OriginPresets/LeaderLib_GenericOverrideTest.lsx"
-- local pathOverrides = {
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic2.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic3.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic4.lsx"] = genericPresetOverrideTest,
-- }

local function LeaderLib_ModuleLoading()
	--Ext.Print("[LeaderLib:Bootstrap.lua] Module is loading.")
	-- if Ext.IsDeveloperMode() then
	-- 	for file,override in pairs(pathOverrides) do
	-- 		Ext.AddPathOverride(file, override)
	-- 	end
	-- end
end
-- Ext.RegisterListener("ModuleLoading", LeaderLib_ModuleLoading)
-- Ext.RegisterListener("ModuleResume", LeaderLib_ModuleLoading)
-- Ext.RegisterListener("SessionLoading", LeaderLib_ModuleLoading)

-- Ext.RegisterListener("SessionLoading", LeaderLib_GameSessionLoad)

Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "BootstrapShared.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_Main.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_Versioning.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_Statuses.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_GameMechanics.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_GlobalSettings.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_ClientMessageReceiver.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_Timers.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Server/LeaderLib_Debug.lua")