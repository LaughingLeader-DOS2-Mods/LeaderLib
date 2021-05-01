Ext.Require("Client/UI/ModMenu/ModMenuManager.lua")
Ext.Require("Client/UI/ModMenu/GameSettingsMenu.lua")
Ext.Require("Client/UI/ModMenu/OptionsSettingsHooks.lua")

Ext.AddPathOverride("Public/Game/GUI/optionsSettings.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/optionsSettings.swf")
Ext.AddPathOverride("Public/Game/GUI/optionsSettings_c.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/optionsSettings_c.swf")
if Vars.DebugMode then
	Ext.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/characterSheet.swf")
end