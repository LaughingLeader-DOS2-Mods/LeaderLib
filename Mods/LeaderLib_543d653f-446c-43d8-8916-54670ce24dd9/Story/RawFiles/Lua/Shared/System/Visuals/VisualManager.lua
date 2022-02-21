local isClient = Ext.IsClient()
local _EXTVERSION = Ext.Version()

if VisualManager == nil then
	VisualManager = {}
end

if not isClient then
	Ext.Require("Shared/System/Visuals/Elements/ElementManager.lua")
	Ext.Require("Shared/System/Visuals/Events.lua")
else
	Ext.Require("Shared/System/Visuals/ClientVisuals.lua")
end