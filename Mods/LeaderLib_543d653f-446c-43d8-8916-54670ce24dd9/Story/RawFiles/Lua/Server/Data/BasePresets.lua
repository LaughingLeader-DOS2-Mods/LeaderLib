---@type PresetData
local p = Classes.PresetData

--@type table<string,table<string, PresetData>>
Data.Presets = {
	Start = {
		Battlemage = p:Create("Battlemage", "Class_Battlemage_Start", "Class_Battlemage", "Class_Battlemage_Start_Undead"),
		Cleric = p:Create("Cleric", "Class_Cleric_Start", "Class_Cleric", "Class_Cleric_Start_Undead"),
		Enchanter = p:Create("Enchanter", "Class_Enchanter_Start", "Class_Enchanter", "Class_Enchanter_Start_Undead"),
		Fighter = p:Create("Fighter", "Class_Fighter_Start", "Class_Fighter", "Class_Fighter_Start_Undead"),
		Inquisitor = p:Create("Inquisitor", "Class_Inquisitor_Start", "Class_Inquisitor", "Class_Inquisitor_Start_Undead"),
		Knight = p:Create("Knight", "Class_Knight_Start", "Class_Knight", "Class_Knight_Start_Undead"),
		Metamorph = p:Create("Metamorph", "Class_Metamorph_Start", "Class_Metamorph", "Class_Metamorph_Start_Undead"),
		Ranger = p:Create("Ranger", "Class_Ranger_Start", "Class_Ranger", "Class_Ranger_Start_Undead"),
		Rogue = p:Create("Rogue", "Class_Rogue_Start", "Class_Rogue", "Class_Rogue_Start_Undead"),
		Shadowblade = p:Create("Shadowblade", "Class_Shadowblade_Start", "Class_Shadowblade", "Class_Shadowblade_Start_Undead"),
		Conjurer = p:Create("Conjurer", "Class_Conjurer_Start", "Class_Conjurer", "Class_Conjurer_Start_Undead"),
		Wayfarer = p:Create("Wayfarer", "Class_Wayfarer_Start", "Class_Wayfarer", "Class_Wayfarer_Start_Undead"),
		Witch = p:Create("Witch", "Class_Witch_Start", "Class_Witch", "Class_Witch_Start_Undead"),
		Wizard = p:Create("Wizard", "Class_Wizard_Start", "Class_Wizard", "Class_Wizard_Start_Undead"),
	},
	Act2 = {
		Battlemage = p:Create("Battlemage_Act2", "Class_Battlemage_Act2", "Class_Battlemage_Act2"),
		Cleric = p:Create("Cleric_Act2", "Class_Cleric_Act2", "Class_Cleric_Act2"),
		Enchanter = p:Create("Enchanter_Act2", "Class_Enchanter_Act2", "Class_Enchanter_Act2"),
		Fighter = p:Create("Fighter_Act2", "Class_Fighter_Act2", "Class_Fighter_Act2"),
		Inquisitor = p:Create("Inquisitor_Act2", "Class_Inquisitor_Act2", "Class_Inquisitor_Act2"),
		Knight = p:Create("Knight_Act2", "Class_Knight_Act2", "Class_Knight_Act2"),
		Metamorph = p:Create("Metamorph_Act2", "Class_Metamorph_Act2", "Class_Metamorph_Act2"),
		Ranger = p:Create("Ranger_Act2", "Class_Ranger_Act2", "Class_Ranger_Act2"),
		Rogue = p:Create("Rogue_Act2", "Class_Rogue_Act2", "Class_Rogue_Act2"),
		Shadowblade = p:Create("Shadowblade_Act2", "Class_Shadowblade_Act2", "Class_Shadowblade_Act2"),
		Conjurer = p:Create("Conjurer_Act2", "Class_Conjurer_Act2", "Class_Conjurer_Act2"),
		Wayfarer = p:Create("Wayfarer_Act2", "Class_Wayfarer_Act2", "Class_Wayfarer_Act2"),
		Witch = p:Create("Witch_Act2", "Class_Witch_Act2", "Class_Witch_Act2"),
		Wizard = p:Create("Wizard_Act2", "Class_Wizard_Act2", "Class_Wizard_Act2"),
	},
	Preview = {
		Battlemage = p:Create("Battlemage", "Class_Battlemage", "Class_Battlemage_Act2", "", true),
		Cleric = p:Create("Cleric", "Class_Cleric", "Class_Cleric_Act2", "", true),
		Enchanter = p:Create("Enchanter", "Class_Enchanter", "Class_Enchanter_Act2", "", true),
		Fighter = p:Create("Fighter", "Class_Fighter", "Class_Fighter_Act2", "", true),
		Inquisitor = p:Create("Inquisitor", "Class_Inquisitor", "Class_Inquisitor_Act2", "", true),
		Knight = p:Create("Knight", "Class_Knight", "Class_Knight_Act2", "", true),
		Metamorph = p:Create("Metamorph", "Class_Metamorph", "Class_Metamorph_Act2", "", true),
		Ranger = p:Create("Ranger", "Class_Ranger", "Class_Ranger_Act2", "", true),
		Rogue = p:Create("Rogue", "Class_Rogue", "Class_Rogue_Act2", "", true),
		Shadowblade = p:Create("Shadowblade", "Class_Shadowblade", "Class_Shadowblade_Act2", "", true),
		Conjurer = p:Create("Conjurer", "Class_Conjurer", "Class_Conjurer_Act2", "", true),
		Wayfarer = p:Create("Wayfarer", "Class_Wayfarer", "Class_Wayfarer_Act2", "", true),
		Witch = p:Create("Witch", "Class_Witch", "Class_Witch_Act2", "", true),
		Wizard = p:Create("Wizard", "Class_Wizard", "Class_Wizard_Act2", "", true),
	}
}

---@param group string Start|Act2|Preview
---@param id string The preset's ClassType value.
---@param data PresetData
function Data.AddPreset(group, id, data)
	if Data.Presets[group] == nil then
		Data.Presets[group] = {}
	end
	Data.Presets[group][id] = data
end