Ext.Require("BootstrapShared.lua")
if UI == nil then
	UI = {}
end

---Deprecated since UIListeners were moved to the regular Listeners.
---Registers a function to call when a specific Lua LeaderLib UI event fires.
---@param event string OnTooltipPositioned
---@param callback function
function UI.RegisterListener(event, callback, ...)
	RegisterListener(event, callback, ...)
end

---@param ui UIObject
Ext.RegisterListener("UIObjectCreated", function(ui)
	if ui:GetTypeId() == Data.UIType.msgBox_c then
		if not Vars.ControllerEnabled then
			Vars.ControllerEnabled = true
			Ext.Print("[LeaderLib] Controller mod enabled.")
			InvokeListenerCallbacks(Listeners.ControllerModeEnabled)
		end
	end
end)

-- Should exist before SessionLoaded
Vars.ControllerEnabled = (Ext.GetBuiltinUI("Public/Game/GUI/msgBox_c.swf") or Ext.GetUIByType(Data.UIType.msgBox_c)) ~= nil
-- if controllerUI ~= nil then
-- 	Ext.Require("Client/UI/Game.Tooltip.Controllers.lua")
-- end

Ext.Require("Client/Classes/_Init.lua")
Ext.Require("Client/Data/_Init.lua")
Ext.Require("Client/ClientHelpers.lua")
Ext.Require("Client/ClientNetMessages.lua")
Ext.Require("Client/InputManager.lua")

Ext.Require("Client/UI/UITypeWorkaround.lua")
Ext.Require("Client/UI/UIListeners.lua")
Ext.Require("Client/QOL/StatusHider.lua")
Ext.Require("Client/QOL/InventoryTweaks.lua")
if Ext.Version() < 57 then
	Ext.Require("Client/UI/Tooltips/Game.Tooltip.Extended.lua")
end
Ext.Require("Client/UI/CharacterSheet.lua")
Ext.Require("Client/UI/ModMenu/_Init.lua")
Ext.Require("Client/UI/Tooltips/TooltipHandler.lua")
Ext.Require("Client/UI/Tooltips/TooltipInfoExpander.lua")
Ext.Require("Client/UI/Tooltips/ExperienceTooltipFix.lua")
Ext.Require("Client/UI/Tooltips/StatusMalusTooltipFix.lua")
Ext.Require("Client/UI/ControllerUIHelpers.lua")
Ext.Require("Client/UI/UIFeatures.lua")
Ext.Require("Client/UI/UIExtensions.lua")
Ext.Require("Client/UI/InterfaceCommands.lua")
Ext.Require("Client/UI/ContextMenu.lua")
Ext.Require("Client/UI/CharacterCreation/CCExtensionUI.lua")
if Ext.Version() >= 56 then
	Ext.Require("Client/UI/CharacterCreation/PresetExtension.lua")
	Ext.Require("Client/QOL/ChatLogHider.lua")
	Ext.Require("Shared/QOL/ExtenderVisualSupport.lua")
end
Ext.Require("Client/UI/JournalChangelog.lua")
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