if UI == nil then
	UI = {}
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

-- Should exist before SessionLoaded
local controllerUI = Ext.GetBuiltinUI("Public/Game/GUI/msgBox_c.swf") or Ext.GetUIByType(75)
if controllerUI ~= nil then
	Ext.Require("Client/UI/Game.Tooltip.Controllers.lua")
end

Ext.Require("Client/UI/CharacterSheet.lua")
Ext.Require("Client/UI/ModMenu/_Init.lua")
Ext.Require("Client/UI/Debug.lua")
Ext.Require("Client/UI/TooltipHandler.lua")
Ext.Require("Client/UI/ControllerUIHelpers.lua")
Ext.Require("Client/UI/UIFeatures.lua")
Ext.Require("Client/UI/InterfaceCommands.lua")

Ext.Require("Client/ClientNetMessages.lua")
