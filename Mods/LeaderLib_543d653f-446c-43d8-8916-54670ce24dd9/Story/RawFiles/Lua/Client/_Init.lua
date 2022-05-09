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
Ext.Require("Client/UI/Tooltips/Game.Tooltip.Extended.lua")
Ext.Require("Client/UI/CharacterSheet.lua")
Ext.Require("Client/UI/ModMenu/_Init.lua")
Ext.Require("Client/UI/Tooltips/TooltipHandler.lua")
Ext.Require("Client/UI/Tooltips/TooltipInfoExpander.lua")
Ext.Require("Client/UI/Tooltips/ExperienceTooltipFix.lua")
Ext.Require("Client/UI/ControllerUIHelpers.lua")
Ext.Require("Client/UI/UIFeatures.lua")
Ext.Require("Client/UI/UIExtensions.lua")
Ext.Require("Client/UI/InterfaceCommands.lua")
Ext.Require("Client/UI/ContextMenu.lua")
Ext.Require("Client/UI/CharacterCreation/CCExtensionUI.lua")
if Ext.Version() >= 56 then
	Ext.Require("Client/UI/CharacterCreation/PresetExtension.lua")
	Ext.Require("Client/QOL/ChatLogHider.lua")
end

if Vars.DebugMode then
	Ext.Require("Client/UI/DialogKeywords.lua") -- TODO
	Ext.Require("Client/Debug/UIGeneralDebug.lua")
	Ext.Require("Client/Debug/ClientConsoleCommands.lua")
end

--Temp Workaround for mods calling this still on the client side
if not Data.AddPreset then
	Data.AddPreset = function() end
end

if not Classes.PresetData then
	Classes.PresetData = {Create = function() end}
end

local function OnSessionLoaded()
	if Vars.LeaderDebugMode then
		Ext.Require("Client/Debug/UIDebugListeners.lua")
	end

	if Vars.ControllerEnabled then
		InvokeListenerCallbacks(Listeners.ControllerModeEnabled)
	end
end

if Ext.Version() >= 56 then
	Ext.Events.SessionLoaded:Register(OnSessionLoaded, {Priority=999})
else
	Ext.RegisterListener("SessionLoaded", OnSessionLoaded)
end