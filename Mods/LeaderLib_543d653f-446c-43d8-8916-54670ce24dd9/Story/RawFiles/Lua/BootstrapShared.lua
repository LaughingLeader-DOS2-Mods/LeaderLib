---Similar to error, but formats a string with provided values.
---@param message string The error message to display.
---@vararg any
---@see _G#error
function ferror(message, ...)
	local b,msg = pcall(string.format, message, ...)
	error(msg,2)
end

---Similar to assert, but formats a string with provided values.
---@param b boolean Whether the asset passes or not.
---@param message string The assert message to display.
---@vararg any
---@see _G#assert
function fassert(b, message, ...)
	if b then
		return b, ...
	end
	local b,msg = pcall(string.format, message, ...)
	error(msg,2)
end

Ext.Require("Shared/_InitShared.lua")
Ext.Require("Shared/Data/_Init.lua")
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
Ext.Require("Shared/Common.lua")
Ext.Require("Shared/Classes/_Init.lua")
Ext.Require("Shared/Data/LocalizedText.lua")
Ext.Require("Shared/System/Timers.lua")
Ext.Require("Shared/Helpers/UIHelpers.lua")
Ext.Require("Shared/Settings/LeaderLibGameSettings.lua")
Ext.Require("Shared/Libraries/_Init.lua")
Ext.Require("Shared/Settings/SettingsManager.lua")
Ext.Require("Shared/Settings/ModSettingsConfigLoader.lua")
Ext.Require("Shared/Settings/LeaderLibDefaultGlobalSettings.lua")
Ext.Require("Shared/System/CombatLog.lua")
Ext.Require("Shared/System/MessageBox.lua")
Ext.Require("Shared/System/SharedDataManager.lua")
Ext.Require("Shared/Main.lua")
Ext.Require("Shared/SharedDebug.lua")
Ext.Require("Shared/Stats/CustomSkillProperties.lua")
Ext.Require("Shared/Stats/StatOverrides.lua")
Ext.Require("Shared/System/FeaturesHandler.lua")

Ext.Require("Shared/QOL/WingsWorkaround.lua")
Ext.Require("Shared/QOL/SkipTutorial.lua")
Ext.Require("Shared/QOL/WorldTooltips.lua")
Ext.Require("Shared/QOL/ContextMenuQualityOfLife.lua")
Ext.Require("Shared/QOL/HotbarSkillTagRequirements.lua")
if Vars.DebugMode then
	--Ext.Require("Shared/Debug/GameMathTracing.lua")
	Ext.Require("Shared/Debug/TestingSystem.lua")
end
Ext.Require("Shared/Debug/ConsoleWindowHelpers.lua")

Ext.RegisterConsoleCommand("modorder", function(cmd, uuidOnly)
	fprint(LOGLEVEL.DEFAULT, "Mods [%s]", Ext.IsClient() and "CLIENT" or "SERVER")
	fprint(LOGLEVEL.DEFAULT, "=============")
	local mods = Ext.GetModLoadOrder()
	for i=1,#mods do
		local info = Ext.GetModInfo(mods[i])
		fprint(LOGLEVEL.DEFAULT, "[%i] %s (%s) [%s]", i, info and info.Name or "???", mods[i], info and info.ModuleType or "")
	end
	fprint(LOGLEVEL.DEFAULT, "=============")
end)