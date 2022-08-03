if GameHelpers.VoiceMetaData == nil then
	GameHelpers.VoiceMetaData = {}
end

---Contains functions for registering a character's UUID with various existing voices.
GameHelpers.VoiceMetaData.Register = {}
Ext.Require("Shared/Data/VoiceMetaData/Adventurer_Female.lua")
Ext.Require("Shared/Data/VoiceMetaData/Adventurer_Male.lua")
Ext.Require("Shared/Data/VoiceMetaData/Scholar_Female.lua")
Ext.Require("Shared/Data/VoiceMetaData/Scholar_Male.lua")
Ext.Require("Shared/Data/VoiceMetaData/Trickster_Female.lua")
Ext.Require("Shared/Data/VoiceMetaData/Trickster_Male.lua")
Ext.Require("Shared/Data/VoiceMetaData/Warrior_Female.lua")
Ext.Require("Shared/Data/VoiceMetaData/Warrior_Male.lua")