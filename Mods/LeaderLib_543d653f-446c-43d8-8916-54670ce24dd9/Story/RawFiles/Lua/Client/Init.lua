if UI == nil then
	UI = {
		ControllerEnabled = false,
	}
end

UI.Tooltip = {}

UIListeners = {
	OnTooltipPositioned = {},
	OnWorldTooltip = {}
}

--- Registers a function to call when a specific Lua LeaderLib UI event fires.
---@param event string OnTooltipPositioned
---@param callback function
function UI.RegisterListener(event, callback)
	if UIListeners[event] ~= nil then
		table.insert(UIListeners[event], callback)
	else
		error("[LeaderLib:Client/Init.lua:RegisterUIListener] Event ("..tostring(event)..") is not a valid LeaderLib ui event!")
	end
end

---@param ui UIObject
Ext.RegisterListener("UIObjectCreated", function(ui)
	if ui:GetTypeId() == Data.UIType.msgBox_c then
		UI.ControllerEnabled = true
		Ext.Print("[LeaderLib] Controller mod enabled.")
	end
end)

-- Should exist before SessionLoaded
UI.ControllerEnabled = (Ext.GetBuiltinUI("Public/Game/GUI/msgBox_c.swf") or Ext.GetUIByType(Data.UIType.msgBox_c)) ~= nil
-- if controllerUI ~= nil then
-- 	Ext.Require("Client/UI/Game.Tooltip.Controllers.lua")
-- end
Ext.Require("Client/ClientHelpers.lua")
Ext.Require("Client/UI/Game.Tooltip.Controllers.lua")

Ext.Require("Client/UI/CharacterSheet.lua")
Ext.Require("Client/UI/ModMenu/_Init.lua")
Ext.Require("Client/UI/Debug.lua")
Ext.Require("Client/UI/TooltipHandler.lua")
Ext.Require("Client/UI/ControllerUIHelpers.lua")
Ext.Require("Client/UI/UIFeatures.lua")
Ext.Require("Client/UI/InterfaceCommands.lua")

Ext.Require("Client/ClientNetMessages.lua")
