if UI == nil then
UI = {
	Tooltip = {}
}
end

Ext.Require("Client/UI/CharacterSheet.lua")
Ext.Require("Client/UI/ModMenu.lua")
Ext.Require("Client/UI/Debug.lua")
Ext.Require("Client/UI/TooltipHandler.lua")
Ext.Require("Client/UI/TooltipHelpers.lua")

Ext.Require("Client/ClientNetMessages.lua")

if Ext.IsDeveloperMode() then
	Ext.Require("Client/UI/UIFeatures.lua")
end