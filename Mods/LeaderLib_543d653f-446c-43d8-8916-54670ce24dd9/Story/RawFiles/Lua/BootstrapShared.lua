---@diagnostic disable lowercase-global

---@class LOGLEVEL
LOGLEVEL = {
	--- Ext.Print
	DEFAULT = 0,
	--- print, will allow the message to show up when in input mode in the command window.
	TRACE = 1,
	--- Ext.PrintWarning
	WARNING = 2,
	--- Ext.PrintError
	ERROR = 3,
	--- Ext.Print if in DeveloperMode
	TRACE2 = 4,
}

---Prints a string formatted message with optional severity.
---@param severity integer|LOGLEVEL
---@param str string
function fprint(severity, str, ...)
	if type(severity) == "string" then
		if string.find(severity, "%s", 1, true) then
			Ext.Print(string.format(severity, str, ...))
		else
			Ext.Print(severity, str, ...)
		end
	elseif type(str) == "string" then
		local msg = string.format(str, ...)
		if severity == LOGLEVEL.ERROR then
			Ext.PrintError(msg)
		elseif severity == LOGLEVEL.WARNING then
			Ext.PrintWarning(msg)
		elseif severity == LOGLEVEL.TRACE then
			if Vars.DebugMode then
				print(msg)
			end
		elseif severity == LOGLEVEL.TRACE2 then
			if Vars.DebugMode then
				Ext.Print(msg)
			end
		else
			Ext.Print(msg)
		end
	else
		Ext.Print(severity,str,...)
	end
end

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

if Classes == nil then Classes = {} end

Ext.Require("Shared/_InitShared.lua")
Ext.Require("Shared/Classes/Enum.lua")
Ext.Require("Shared/Data/_Init.lua")
Ext.Require("Shared/Settings/GameSettingsManager.lua")
Ext.Require("Shared/Helpers/DebugHelpers.lua")
Ext.Require("Shared/Helpers/ExtenderHelpers.lua")
Ext.Require("Shared/Helpers/FileHelpers.lua")
Ext.Require("Shared/Helpers/MathHelpers.lua")
Ext.Require("Shared/Helpers/TooltipHelpers.lua")
Ext.Require("Shared/Helpers/SharedGameHelpers.lua")
Ext.Require("Shared/Helpers/TableHelpers.lua")
Ext.Require("Shared/Helpers/StringHelpers.lua")
Ext.Require("Shared/Helpers/StatsHelpers.lua")
Ext.Require("Shared/Helpers/StatsCache.lua")
Ext.Require("Shared/Helpers/SharedStatusHelpers.lua")
Ext.Require("Shared/Helpers/ItemHelpers.lua")
Ext.Require("Shared/Helpers/CharacterHelpers.lua")
Ext.Require("Shared/Helpers/VoiceMetaDataRegistration.lua")
Ext.Require("Shared/Common.lua")
Ext.Require("Shared/Classes/_Init.lua")
Ext.Require("Shared/Data/LocalizedText.lua")
Ext.Require("Shared/System/Timers.lua")
Ext.Require("Shared/Helpers/GridHelpers.lua")
Ext.Require("Shared/Helpers/SurfaceHelpers.lua")
Ext.Require("Shared/Helpers/UIHelpers.lua")
Ext.Require("Shared/Settings/LeaderLibGameSettings.lua")
Ext.Require("Shared/Libraries/_Init.lua")
Ext.Require("Shared/Settings/SettingsManager.lua")
Ext.Require("Shared/Settings/ModSettingsConfigLoader.lua")
Ext.Require("Shared/Settings/LeaderLibDefaultGlobalSettings.lua")
Ext.Require("Shared/System/SharedDataManager.lua")
Ext.Require("Shared/Main.lua")
Ext.Require("Shared/SharedDebug.lua")
Ext.Require("Shared/Stats/CustomSkillProperties.lua")
Ext.Require("Shared/Stats/StatOverrides.lua")
Ext.Require("Shared/System/FeaturesHandler.lua")
Ext.Require("Shared/System/Visuals/VisualManager.lua")

Ext.Require("Shared/QOL/WingsWorkaround.lua")
Ext.Require("Shared/QOL/WorldTooltips.lua")
Ext.Require("Shared/QOL/ContextMenuQualityOfLife.lua")
Ext.Require("Shared/QOL/HotbarSkillTagRequirements.lua")
if Ext.IsDeveloperMode() then
	Ext.Require("Shared/Debug/TestingSystem.lua")
end
Ext.Require("Shared/Debug/ConsoleWindowHelpers.lua")
Ext.Require("Shared/Debug/SharedCommands.lua")
Ext.Require("Shared/Patches/ModPatching.lua")