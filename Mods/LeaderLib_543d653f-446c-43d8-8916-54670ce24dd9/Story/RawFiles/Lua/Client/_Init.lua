if UI == nil then
	UI = {}
end

UI.Tooltip = {}

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
		Vars.ControllerEnabled = true
		Ext.Print("[LeaderLib] Controller mod enabled.")
	end
end)

-- Should exist before SessionLoaded
Vars.ControllerEnabled = (Ext.GetBuiltinUI("Public/Game/GUI/msgBox_c.swf") or Ext.GetUIByType(Data.UIType.msgBox_c)) ~= nil
-- if controllerUI ~= nil then
-- 	Ext.Require("Client/UI/Game.Tooltip.Controllers.lua")
-- end
Ext.Require("Client/Data/_Init.lua")
Ext.Require("Client/ClientHelpers.lua")
Ext.Require("Client/ClientNetMessages.lua")
Ext.Require("Client/InputManager.lua")

Ext.Require("Client/Helpers/UIHelpers.lua")

Ext.Require("Client/UI/Game.Tooltip.Controllers.lua")
Ext.Require("Client/UI/CharacterSheet.lua")
Ext.Require("Client/UI/ModMenu/_Init.lua")
if Vars.DebugMode then
	Ext.Require("Client/Debug/UIGeneralDebug.lua")
	Ext.Require("Client/Debug/UIDebugListeners.lua")
end
Ext.Require("Client/UI/TooltipHandler.lua")
Ext.Require("Client/UI/ControllerUIHelpers.lua")
Ext.Require("Client/UI/UIFeatures.lua")
Ext.Require("Client/UI/UIExtensions.lua")
Ext.Require("Client/UI/Talents/TalentManager.lua")
Ext.Require("Client/UI/Talents/GamepadSupport.lua")
Ext.Require("Client/UI/InterfaceCommands.lua")