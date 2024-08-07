local _Enum = Classes.Enum

---@enum AnimType
Data.AnimType = {
	None = -1,
	OneHanded = 0,
	TwoHanded = 1,
	Bow = 2,
	DualWield = 3,
	Shield = 4,
	SmallWeapons = 5,
	PoleArms = 6,
	Unarmed = 7,
	CrossBow = 8,
	TwoHanded_Sword = 9,
	Sitting = 10,
	Lying = 11,
	DualWieldSmall = 12,
	Staves = 13,
	Wands = 14,
	DualWieldWands = 15,
	ShieldWands = 16,
	[-1] = "None",
	[0] = "OneHanded",
	[1] = "TwoHanded",
	[2] = "Bow",
	[3] = "DualWield",
	[4] = "Shield",
	[5] = "SmallWeapons",
	[6] = "PoleArms",
	[7] = "Unarmed",
	[8] = "CrossBow",
	[9] = "TwoHanded_Sword",
	[10] = "Sitting",
	[11] = "Lying",
	[12] = "DualWieldSmall",
	[13] = "Staves",
	[14] = "Wands",
	[15] = "DualWieldWands",
	[16] = "ShieldWands",
}

_Enum:Create(Data.AnimType)

Data.DamageTypes = {
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
	Shadow = 11,
	[0] = "None",
	[1] = "Physical",
	[2] = "Piercing",
	[3] = "Corrosive",
	[4] = "Magic",
	[5] = "Chaos",
	[6] = "Fire",
	[7] = "Air",
	[8] = "Water",
	[9] = "Earth",
	[10] = "Poison",
	[11] = "Shadow",
}

_Enum:Create(Data.DamageTypes)
---@deprecated
Data.DamageTypeEnums = Data.DamageTypes

Data.EquipmentSlots = {
	Helmet = 0,
	Breast = 1,
	Leggings = 2,
	Weapon = 3,
	Shield = 4,
	Ring = 5,
	Belt = 6,
	Boots = 7,
	Gloves = 8,
	Amulet = 9,
	Ring2 = 10,
	Wings = 11,
	Horns = 12,
	Overhead = 13,
	Sentinel = 14,
	[0] = "Helmet",
	[1] = "Breast",
	[2] = "Leggings",
	[3] = "Weapon",
	[4] = "Shield",
	[5] = "Ring",
	[6] = "Belt",
	[7] = "Boots",
	[8] = "Gloves",
	[9] = "Amulet",
	[10] = "Ring2",
	[11] = "Wings",
	[12] = "Horns",
	[13] = "Overhead",
	[14] = "Sentinel",
}

_Enum:Create(Data.EquipmentSlots)
---@deprecated
Data.EquipmentSlotNames = Data.EquipmentSlots

Data.VisibleEquipmentSlots = {
	[0]="Helmet",
	[1]="Breast",
	[2]="Leggings",
	[3]="Weapon",
	[4]="Shield",
	[5]="Ring",
	[6]="Belt",
	[7]="Boots",
	[8]="Gloves",
	[9]="Amulet",
	[10]="Ring2",
	Helmet = 0,
	Breast = 1,
	Leggings = 2,
	Weapon = 3,
	Shield = 4,
	Ring = 5,
	Belt = 6,
	Boots = 7,
	Gloves = 8,
	Amulet = 9,
	Ring2 = 10,
}
_Enum:Create(Data.VisibleEquipmentSlots)

--- Enums for every ability in the game.
Data.Ability = {
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
	--Sentinel = 40,
}

_Enum:Create(Data.Ability)
---@deprecated
Data.AbilityEnum = Data.Ability

Data.Attribute = {
	Strength = 0,
	Finesse = 1,
	Intelligence = 2,
	Constitution = 3,
	Memory = 4,
	Wits = 5,
	[0] = "Strength",
	[1] ="Finesse",
	[2] ="Intelligence",
	[3] ="Constitution",
	[4] ="Memory",
	[5] ="Wits"
}
_Enum:Create(Data.Attribute)
---@deprecated
Data.AttributeEnum = Data.Attribute

Data.Talents = {
	ItemMovement = 1,
	ItemCreation = 2,
	Flanking = 3,
	AttackOfOpportunity = 4,
	Backstab = 5,
	Trade = 6,
	Lockpick = 7,
	ChanceToHitRanged = 8,
	ChanceToHitMelee = 9,
	Damage = 10,
	ActionPoints = 11,
	ActionPoints2 = 12,
	Criticals = 13,
	IncreasedArmor = 14,
	Sight = 15,
	ResistFear = 16,
	ResistKnockdown = 17,
	ResistStun = 18,
	ResistPoison = 19,
	ResistSilence = 20,
	ResistDead = 21,
	Carry = 22,
	Throwing = 23,
	Repair = 24,
	ExpGain = 25,
	ExtraStatPoints = 26,
	ExtraSkillPoints = 27,
	Durability = 28,
	Awareness = 29,
	Vitality = 30,
	FireSpells = 31,
	WaterSpells = 32,
	AirSpells = 33,
	EarthSpells = 34,
	Charm = 35,
	Intimidate = 36,
	Reason = 37,
	Luck = 38,
	Initiative = 39,
	InventoryAccess = 40,
	AvoidDetection = 41,
	AnimalEmpathy = 42,
	Escapist = 43,
	StandYourGround = 44,
	SurpriseAttack = 45,
	LightStep = 46,
	ResurrectToFullHealth = 47,
	Scientist = 48,
	Raistlin = 49,
	MrKnowItAll = 50,
	WhatARush = 51,
	FaroutDude = 52,
	Leech = 53,
	ElementalAffinity = 54,
	FiveStarRestaurant = 55,
	Bully = 56,
	ElementalRanger = 57,
	LightningRod = 58,
	Politician = 59,
	WeatherProof = 60,
	LoneWolf = 61,
	Zombie = 62,
	Demon = 63,
	IceKing = 64,
	Courageous = 65,
	GoldenMage = 66,
	WalkItOff = 67,
	FolkDancer = 68,
	SpillNoBlood = 69,
	Stench = 70,
	Kickstarter = 71,
	WarriorLoreNaturalArmor = 72,
	WarriorLoreNaturalHealth = 73,
	WarriorLoreNaturalResistance = 74,
	RangerLoreArrowRecover = 75,
	RangerLoreEvasionBonus = 76,
	RangerLoreRangedAPBonus = 77,
	RogueLoreDaggerAPBonus = 78,
	RogueLoreDaggerBackStab = 79,
	RogueLoreMovementBonus = 80,
	RogueLoreHoldResistance = 81,
	NoAttackOfOpportunity = 82,
	WarriorLoreGrenadeRange = 83,
	RogueLoreGrenadePrecision = 84,
	WandCharge = 85,
	DualWieldingDodging = 86,
	Human_Inventive = 87,
	Human_Civil = 88,
	Elf_Lore = 89,
	Elf_CorpseEating = 90,
	Dwarf_Sturdy = 91,
	Dwarf_Sneaking = 92,
	Lizard_Resistance = 93,
	Lizard_Persuasion = 94,
	Perfectionist = 95,
	Executioner = 96,
	ViolentMagic = 97,
	QuickStep = 98,
	Quest_SpidersKiss_Str = 99,
	Quest_SpidersKiss_Int = 100,
	Quest_SpidersKiss_Per = 101,
	Quest_SpidersKiss_Null = 102,
	Memory = 103,
	Quest_TradeSecrets = 104,
	Quest_GhostTree = 105,
	BeastMaster = 106,
	LivingArmor = 107,
	Torturer = 108,
	Ambidextrous = 109,
	Unstable = 110,
	ResurrectExtraHealth = 111,
	NaturalConductor = 112,
	Quest_Rooted = 113,
	PainDrinker = 114,
	DeathfogResistant = 115,
	Sourcerer = 116,
	Rager = 117,
	Elementalist = 118,
	Sadist = 119,
	Haymaker = 120,
	Gladiator = 121,
	Indomitable = 122,
	WildMag = 123,
	Jitterbug = 124,
	Soulcatcher = 125,
	MasterThief = 126,
	GreedyVessel = 127,
	MagicCycles = 128,
}

_Enum:Create(Data.Talents)
---@deprecated
Data.TalentEnum = Data.Talents

Data.Traits = {
	Forgiving = 0,
	Vindictive = 1,
	Bold = 2,
	Timid = 3,
	Altruistic = 4,
	Egotistical = 5,
	Independent = 6,
	Obedient = 7,
	Pragmatic = 8,
	Romantic = 9,
	Spiritual = 10,
	Materialistic = 11,
	Righteous = 12,
	Renegade = 13,
	Blunt = 14,
	Considerate = 15,
	Compassionate = 16,
	Heartless = 17,
}
_Enum:Create(Data.Traits)

Data.ItemRarity = {
	Sentinel = -1,
	Common = 0,
	Unique = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Divine = 6,
	[-1] = "Sentinel",
	[0] = "Common",
	[1] = "Unique",
	[2] = "Uncommon",
	[3] = "Rare",
	[4] = "Epic",
	[5] = "Legendary",
	[6] = "Divine",
}

_Enum:Create(Data.ItemRarity, nil, nil, 0)

---@enum SKILL_STATE
SKILL_STATE = {
	PREPARE = "PREPARE",
	USED = "USED",
	CAST = "CAST",
	HIT = "HIT",
	PROJECTILEHIT = "PROJECTILEHIT",
	BEFORESHOOT = "BEFORESHOOT",
	SHOOTPROJECTILE = "SHOOTPROJECTILE",
	CANCEL = "CANCEL", -- When preparing is stopped without casting
	LEARNED = "LEARNED",
	MEMORIZED = "MEMORIZED",
	UNMEMORIZED = "UNMEMORIZED",
	GETAPCOST = "GETAPCOST",
	GETDAMAGE = "GETDAMAGE"
}

Ext.Events.SessionLoaded:Subscribe(function (e)
	--Support for mods adding new damage types
	if #Ext.Enums.DamageType > #Data.DamageTypes then
		local dt = {}
		for i,v in pairs(Ext.Enums.DamageType) do
			if type(i) == "number" then
				local value = tostring(v)
				dt[i] = value
				dt[value] = i
			end
		end
		_Enum:Create(dt)
		Data.DamageTypes = dt
	end
end)