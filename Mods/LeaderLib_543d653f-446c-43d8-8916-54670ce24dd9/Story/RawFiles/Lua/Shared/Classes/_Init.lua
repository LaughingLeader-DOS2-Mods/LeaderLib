Ext.Require("Shared/Classes/TranslatedString.lua")
Ext.Require("Shared/Classes/MessageData.lua")
Ext.Require("Shared/Classes/ClientData.lua")
Ext.Require("Shared/Classes/LeaderLibGameSettings.lua")
Ext.Require("Shared/Classes/SkillData/HitData.lua")
Ext.Require("Shared/Classes/SkillData/ProjectileHitData.lua")
Ext.Require("Shared/Classes/SkillData/SkillEventData.lua")
Ext.Require("Shared/Classes/PresetData.lua")
Ext.Require("Shared/Classes/ModSettingsClasses.lua")

if Ext.IsServer() then
	Ext.Require("Shared/Classes/QuestData.lua")
end