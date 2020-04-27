Data = {
	DamageTypes = {
		[0] = "None",
		"Physical",
		"Piercing",
		"Corrosive",
		"Magic",
		"Chaos",
		"Fire",
		"Air",
		"Water",
		"Earth",
		"Poison",
		"Shadow"
	},
	DamageTypeEnums = {
		None = 0,
		Physical = 1,
		Piercing = 2,
		Corrosive = 3,
		Magic = 4,
		Chaos = 5,
		Fire = 6,
		Air = 7,
		Water = 8,
		Earth = 9,
		Poison = 10,
		Shadow = 11
	},
	EquipmentSlots = {
		[0] = "Weapon",
		"Shield",
		"Helmet",
		"Breast",
		"Gloves",
		"Leggings",
		"Boots",
		"Belt",
		"Amulet",
		"Ring",
		"Ring2",
		"Wings",
		"Horns",
		"Overhead"
	},
	VisibleEquipmentSlots = {
		[0] = "Weapon",
		"Shield",
		"Helmet",
		"Breast",
		"Gloves",
		"Leggings",
		"Boots",
		"Belt",
		"Amulet",
		"Ring",
		"Ring2"
	},
	--- Enums for every ability in the game.
	---@type table<string,integer>
	AbilityEnum = {
		WarriorLore = 0,
		RangerLore = 1,
		RogueLore = 2,
		SingleHanded = 3,
		TwoHanded = 4,
		PainReflection = 5,
		Ranged = 6,
		Shield = 7,
		Reflexes = 8,
		PhysicalArmorMastery = 9,
		MagicArmorMastery = 10,
		VitalityMastery = 11,
		Sourcery = 12,
		FireSpecialist = 13,
		WaterSpecialist = 14,
		AirSpecialist = 15,
		EarthSpecialist = 16,
		Necromancy = 17,
		Summoning = 18,
		Polymorph = 19,
		Telekinesis = 20,
		Repair = 21,
		Sneaking = 22,
		Pickpocket = 23,
		Thievery = 24,
		Loremaster = 25,
		Crafting = 26,
		Barter = 27,
		Charm = 28,
		Intimidate = 29,
		Reason = 30,
		Persuasion = 31,
		Leadership = 32,
		Luck = 33,
		DualWielding = 34,
		Wand = 35,
		Perseverance = 36,
		Runecrafting = 37,
		Brewmaster = 38,
		Sulfurology = 39,
		Sentinel = 40,
	},
	---@type table<integer,string>
	Ability = {},
	Attribute = {
		[0] = "Strength",
		"Finesse",
		"Intelligence",
		"Constitution",
		"Memory",
		"Wits"
	}
}

for name,i in pairs(Data.AbilityEnum) do
	Data.Ability[i] = name
end

ID = {
	MESSAGE = {
		ATTRIBUTE_CHANGED = "ATTRIBUTE_CHANGED",
		ABILITY_CHANGED = "ABILITY_CHANGED",
		STORE_PARTY_VALUES = "STORE_PARTY_VALUES"
	},
	HOTBAR = {
		CharacterSheet = 1
	}
}

SKILL_STATE = {
	PREPARE = "PREPARE",
	USED = "USED",
	CAST = "CAST",
	HIT = "HIT",
}