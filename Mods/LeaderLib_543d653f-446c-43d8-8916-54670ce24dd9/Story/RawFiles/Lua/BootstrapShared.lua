Ext.Require("Shared/_InitShared.lua")
Ext.Require("Shared/Settings/GameSettingsManager.lua")
Ext.Require("Shared/Helpers/DebugHelpers.lua")
Ext.Require("Shared/Helpers/ExtenderHelpers.lua")
Ext.Require("Shared/Helpers/MathHelpers.lua")
Ext.Require("Shared/Helpers/TooltipHelpers.lua")
Ext.Require("Shared/Helpers/SharedGameHelpers.lua")
Ext.Require("Shared/Helpers/TableHelpers.lua")
Ext.Require("Shared/Helpers/StringHelpers.lua")
Ext.Require("Shared/Helpers/StatsHelpers.lua")
Ext.Require("Shared/Helpers/SharedStatusHelpers.lua")
Ext.Require("Shared/Helpers/CharacterHelpers.lua")
Ext.Require("Shared/Helpers/VoiceMetaDataRegistration.lua")
Ext.Require("Shared/Helpers/CombatLogHelper.lua")
Ext.Require("Shared/Common.lua")
Ext.Require("Shared/Classes/_Init.lua")
Ext.Require("Shared/System/Timers.lua")
Ext.Require("Shared/Helpers/UIHelpers.lua")
Ext.Require("Shared/Settings/LeaderLibGameSettings.lua")
Ext.Require("Shared/Libraries/_Init.lua")
Ext.Require("Shared/Settings/SettingsManager.lua")
Ext.Require("Shared/Settings/ModSettingsConfigLoader.lua")
Ext.Require("Shared/Settings/LeaderLibDefaultGlobalSettings.lua")
Ext.Require("Shared/Data/_Init.lua")
Ext.Require("Shared/System/SharedDataManager.lua")
Ext.Require("Shared/Main.lua")
Ext.Require("Shared/SharedDebug.lua")
Ext.Require("Shared/Stats/CustomSkillProperties.lua")
Ext.Require("Shared/Stats/StatOverrides.lua")
Ext.Require("Shared/System/FeaturesHandler.lua")
Ext.Require("Shared/System/AbilityAPI.lua")

if Ext.Version() >= 55 then
Ext.Require("Shared/System/CustomStats/CustomStatSystem.lua")
end
Ext.Require("Shared/System/CustomStats/_Debug.lua")
Ext.Require("Shared/QOL/WingsWorkaround.lua")
Ext.Require("Shared/QOL/SkipTutorial.lua")
Ext.Require("Shared/QOL/WorldTooltips.lua")
if Vars.DebugMode then
	--Ext.Require("Shared/Debug/GameMathTracing.lua")
	Ext.Require("Shared/Debug/TestingSystem.lua")
end
Ext.Require("Shared/Debug/ConsoleWIndowHelpers.lua")