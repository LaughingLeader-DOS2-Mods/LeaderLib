if GameHelpers.VoiceMetaData == nil then
	GameHelpers.VoiceMetaData = {}
end

---Contains functions for registering a character's UUID with various existing voices.
GameHelpers.VoiceMetaData.Register = {
	AdventurerFemale = Ext.Require("Shared/Data/VoiceMetaData/Adventurer_Female.lua"),
	AdventurerMale = Ext.Require("Shared/Data/VoiceMetaData/Adventurer_Male.lua"),
	ScholarFemale = Ext.Require("Shared/Data/VoiceMetaData/Scholar_Female.lua"),
	ScholarMale = Ext.Require("Shared/Data/VoiceMetaData/Scholar_Male.lua"),
	TricksterFemale = Ext.Require("Shared/Data/VoiceMetaData/Trickster_Female.lua"),
	TricksterMale = Ext.Require("Shared/Data/VoiceMetaData/Trickster_Male.lua"),
	WarriorFemale = Ext.Require("Shared/Data/VoiceMetaData/Warrior_Female.lua"),
	WarriorMale = Ext.Require("Shared/Data/VoiceMetaData/Warrior_Male.lua"),
}