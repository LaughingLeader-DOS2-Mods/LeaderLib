PersistentVars = {}
PersistentVars.TimerData = {}

-- local function LeaderLib_GameSessionLoad()
-- 	PrintDebug("[LeaderLib:Bootstrap.lua] Session is loading.")
-- end

-- local genericPresetOverrideTest = "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/CharacterCreation/OriginPresets/LeaderLib_GenericOverrideTest.lsx"
-- local pathOverrides = {
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic2.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic3.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic4.lsx"] = genericPresetOverrideTest,
-- }

local function ModuleResume()
	--PrintDebug("[LeaderLib:Bootstrap.lua] Module is loading.")
	-- if Ext.IsDeveloperMode() then
	-- 	for file,override in pairs(pathOverrides) do
	-- 		Ext.AddPathOverride(file, override)
	-- 	end
	-- end
	if #Listeners.ModuleResume > 0 then
		for i,callback in ipairs(Listeners.ModuleResume) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("Error calling function for 'ModuleResume':\n", err)
			end
		end
	end
end
Ext.RegisterListener("ModuleResume", ModuleResume)

local function SessionLoaded()
	if #Listeners.SessionLoaded > 0 then
		for i,callback in ipairs(Listeners.SessionLoaded) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("Error calling function for 'SessionLoaded':\n", err)
			end
		end
	end
end
Ext.RegisterListener("SessionLoaded", SessionLoaded)

-- Ext.RegisterListener("SessionLoading", LeaderLib_GameSessionLoad)

Ext.Require("BootstrapShared.lua")
Ext.Require("Server/Init.lua")
Ext.Require("Server/Debug/DebugMain.lua")
Ext.Require("Server/GameHelpers.lua")
Ext.Require("Server/Game/DamageHelpers.lua")
Ext.Require("Server/Game/HitHelpers.lua")
Ext.Require("Server/Game/ItemHelpers.lua")
Ext.Require("Server/Game/ProjectileHelpers.lua")
Ext.Require("Server/Game/SkillHelpers.lua")
Ext.Require("Server/Game/StatusHelpers.lua")
Ext.Require("Server/Game/GameEvents.lua")
Ext.Require("Server/Listeners/ClientMessageReceiver.lua")
Ext.Require("Server/Listeners/FeaturesHandler.lua")
Ext.Require("Server/Listeners/HitListener.lua")
Ext.Require("Server/Listeners/SkillListeners.lua")
Ext.Require("Server/ModMenu/ModMenuServer.lua")
Ext.Require("Server/Settings/GlobalSettings.lua")
Ext.Require("Server/Timers.lua")
Ext.Require("Server/OsirisHelpers.lua")
Ext.Require("Server/Versioning.lua")