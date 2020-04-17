local Data = {
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
	Ability = {
		[0] = "None",
		"WarriorLore",
		"RangerLore",
		"RogueLore",
		"SingleHanded",
		"TwoHanded",
		"Reflection",
		"Ranged",
		"Shield",
		"Reflexes",
		"PhysicalArmorMastery",
		"Sourcery",
		"Telekinesis",
		"FireSpecialist",
		"WaterSpecialist",
		"AirSpecialist",
		"EarthSpecialist",
		"Necromancy",
		"Summoning",
		"Polymorph",
		"Sulfurology",
		"Repair",
		"Sneaking",
		"Pickpocket",
		"Thievery",
		"Loremaster",
		"Crafting",
		"Barter",
		"Charm",
		"Intimidate",
		"Reason",
		"Persuasion",
		"Leadership",
		"Luck",
		"DualWielding",
		"Wand",
		"MagicArmorMastery",
		"VitalityMastery",
		"Perseverance",
		"Runecrafting",
		"Brewmaster"
	},
	Attribute = {
		[0] = "Strength",
		"Finesse",
		"Intelligence",
		"Constitution",
		"Memory",
		"Wits"
	}
}

local ID = {
	MESSAGE = {
		ATTRIBUTE_CHANGED = "AttributeChanged",
		ABILITY_CHANGED = "AbilityChanged",
		STORE_PARTY_VALUES = "StorePartySheetValues"
	},
	HOTBAR = {
		CharacterSheet = 1
	}
}

LeaderLib.Data = Data
LeaderLib.ID = ID