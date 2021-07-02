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

Ext.Require("Client/UI/StatusHider.lua")
Ext.Require("Client/UI/Tooltips/Game.Tooltip.Extended.lua")
Ext.Require("Client/UI/CharacterSheet.lua")
Ext.Require("Client/UI/ModMenu/_Init.lua")
Ext.Require("Client/UI/Tooltips/TooltipHandler.lua")
Ext.Require("Client/UI/Tooltips/TooltipInfoExpander.lua")
Ext.Require("Client/UI/ControllerUIHelpers.lua")
Ext.Require("Client/UI/UIFeatures.lua")
Ext.Require("Client/UI/UIExtensions.lua")
Ext.Require("Client/UI/Talents/TalentManager.lua")
Ext.Require("Client/UI/InterfaceCommands.lua")
Ext.Require("Client/UI/ContextMenu.lua")

if Vars.DebugMode then
	Ext.Require("Client/UI/DialogKeywords.lua") -- TODO
	Ext.Require("Client/Debug/UIGeneralDebug.lua")
	Ext.Require("Client/Debug/UIDebugListeners.lua")
	Ext.Require("Client/Debug/ClientConsoleCommands.lua")
end

--Temp Workaround for mods calling this still on the client side
if not Data.AddPreset then
	Data.AddPreset = function() end
end

if not Classes.PresetData then
	Classes.PresetData = {Create = function() end}
end