local enableDebugUIListeners = nil
if Vars.DebugMode then
	Ext.Require("Client/UI/DialogKeywords.lua") -- TODO
	Ext.Require("Client/Debug/ClientConsoleCommands.lua")
	enableDebugUIListeners = Ext.Require("Client/Debug/UIDebugListeners.lua")
end

--Temp Workaround for mods calling this still on the client side
if not Data.AddPreset then
	Data.AddPreset = function() end
end

if not Classes.PresetData then
	Classes.PresetData = {Create = function() end}
end

local function OnSessionLoaded()
	Vars.ControllerEnabled = (Ext.GetBuiltinUI("Public/Game/GUI/msgBox_c.swf") or Ext.GetUIByType(Data.UIType.msgBox_c)) ~= nil
	if enableDebugUIListeners then
		enableDebugUIListeners()
	end
end

if Ext.Version() >= 56 then
	Ext.Events.SessionLoaded:Subscribe(OnSessionLoaded, {Priority=999})
else
	Ext.RegisterListener("SessionLoaded", OnSessionLoaded)
end