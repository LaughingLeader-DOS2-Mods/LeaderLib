if GameHelpers.Ext == nil then
	GameHelpers.Ext = {}
end

local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()
local _type = type

local characterStatAttributes = {
	"Strength",
	"Finesse",
	"Intelligence",
	"Constitution",
	"Memory",
	"Wits",
	"SingleHanded",
	"TwoHanded",
	"Ranged",
	"DualWielding",
	"RogueLore",
	"WarriorLore",
	"RangerLore",
	"FireSpecialist",
	"WaterSpecialist",
	"AirSpecialist",
	"EarthSpecialist",
	"Sourcery",
	"Necromancy",
	"Polymorph",
	"Summoning",
	"PainReflection",
	"Leadership",
	"Perseverance",
	"Telekinesis",
	"Sneaking",
	"Thievery",
	"Loremaster",
	"Repair",
	"Barter",
	"Persuasion",
	"Luck",
	"FireResistance",
	"EarthResistance",
	"WaterResistance",
	"AirResistance",
	"PoisonResistance",
	"PiercingResistance",
	"PhysicalResistance",
	"Sight",
	"Hearing",
	"FOV",
	"APMaximum",
	"APStart",
	"APRecovery",
	"Initiative",
	"Vitality",
	"MagicPoints",
	"ChanceToHitBoost",
	"Movement",
	"MovementSpeedBoost",
	"CriticalChance",
	"Gain",
	"Armor",
	"ArmorBoost",
	"ArmorBoostGrowthPerLevel",
	"MagicArmor",
	"MagicArmorBoost",
	"MagicArmorBoostGrowthPerLevel",
	"Accuracy",
	"Dodge",
	"Act",
	"Act part",
	"Act strength",
	"MaxResistance",
	"Weight",
	"Talents",
	"Traits",
	"PathInfluence",
	--"Flags", -- AttributeFlags error
	"Reflection",
	"StepsType",
	"MaxSummons",
	"MPStart",
	"DamageBoost",
	"DamageBoostGrowthPerLevel",
}

local characterStatProperties = {
	Accuracy = "integer",
	AcidImmunity = "boolean",
	AirResistance = "integer",
	AirSpecialist = "integer",
	APCostBoost = "integer",
	APMaximum = "integer",
	APRecovery = "integer",
	APStart = "integer",
	Armor = "integer",
	ArmorBoost = "integer",
	ArmorBoostGrowthPerLevel = "integer",
	Arrow = "boolean",
	Barter = "integer",
	BleedingImmunity = "boolean",
	BlessedImmunity = "boolean",
	BlindImmunity = "boolean",
	Bodybuilding = "integer",
	--BonusWeapon = "integer",
	--BonusWeaponDamageMultiplier = "integer",
	Brewmaster = "integer",
	BurnContact = "boolean",
	BurnImmunity = "boolean",
	ChanceToHitBoost = "integer",
	Charm = "integer",
	CharmImmunity = "boolean",
	ChickenImmunity = "boolean",
	ChillContact = "boolean",
	ChilledImmunity = "boolean",
	ClairvoyantImmunity = "boolean",
	Constitution = "integer",
	CorrosiveResistance = "integer",
	Crafting = "integer",
	CrippledImmunity = "boolean",
	CriticalChance = "integer",
	CursedImmunity = "boolean",
	CustomResistance = "integer",
	DamageBoost = "integer",
	DamageBoostGrowthPerLevel = "integer",
	DecayingImmunity = "boolean",
	DeflectProjectiles = "boolean",
	DisarmedImmunity = "boolean",
	DiseasedImmunity = "boolean",
	Dodge = "integer",
	DrunkImmunity = "boolean",
	DualWielding = "integer",
	EarthResistance = "integer",
	EarthSpecialist = "integer",
	EnragedImmunity = "boolean",
	EntangledContact = "boolean",
	FearImmunity = "boolean",
	Finesse = "integer",
	FireResistance = "integer",
	FireSpecialist = "integer",
	Floating = "boolean",
	FOV = "integer",
	FreezeContact = "boolean",
	FreezeImmunity = "boolean",
	Gain = "integer",
	Grounded = "boolean",
	HastedImmunity = "boolean",
	Hearing = "integer",
	IgnoreClouds = "boolean",
	IgnoreCursedOil = "boolean",
	InfectiousDiseasedImmunity = "boolean",
	Initiative = "integer",
	Intelligence = "integer",
	Intimidate = "integer",
	InvisibilityImmunity = "boolean",
	KnockdownImmunity = "boolean",
	Leadership = "integer",
	Level = "integer",
	LifeSteal = "integer",
	LootableWhenEquipped = "boolean",
	Loremaster = "integer",
	LoseDurabilityOnCharacterHit = "boolean",
	Luck = "integer",
	MadnessImmunity = "boolean",
	MagicalSulfur = "boolean",
	MagicArmor = "integer",
	MagicArmorBoost = "integer",
	MagicArmorBoostGrowthPerLevel = "integer",
	MagicArmorMastery = "integer",
	MagicPoints = "integer",
	MagicResistance = "integer",
	MaxResistance = "integer",
	MaxSummons = "integer",
	Memory = "integer",
	Movement = "integer",
	MovementSpeedBoost = "integer",
	MuteImmunity = "boolean",
	Necromancy = "integer",
	PainReflection = "integer",
	Perseverance = "integer",
	Persuasion = "integer",
	PetrifiedImmunity = "boolean",
	PhysicalArmorMastery = "integer",
	PhysicalResistance = "integer",
	Pickpocket = "integer",
	PickpocketableWhenEquipped = "boolean",
	PiercingResistance = "integer",
	PoisonContact = "boolean",
	PoisonImmunity = "boolean",
	PoisonResistance = "integer",
	Polymorph = "integer",
	ProtectFromSummon = "boolean",
	RangeBoost = "integer",
	Ranged = "integer",
	RangerLore = "integer",
	Reason = "integer",
	Reflexes = "integer",
	RegeneratingImmunity = "boolean",
	Repair = "integer",
	RogueLore = "integer",
	Runecrafting = "integer",
	ShacklesOfPainImmunity = "boolean",
	ShadowResistance = "integer",
	Shield = "integer",
	ShockedImmunity = "boolean",
	Sight = "integer",
	SingleHanded = "integer",
	SleepingImmunity = "boolean",
	SlippingImmunity = "boolean",
	SlowedImmunity = "boolean",
	Sneaking = "integer",
	Sourcery = "integer",
	SPCostBoost = "integer",
	StepsType = "integer",
	Strength = "integer",
	StunContact = "boolean",
	StunImmunity = "boolean",
	SuffocatingImmunity = "boolean",
	Sulfurology = "integer",
	Summoning = "integer",
	SummonLifelinkModifier = "integer",
	TauntedImmunity = "boolean",
	Telekinesis = "integer",
	Thievery = "integer",
	ThrownImmunity = "boolean",
	Torch = "boolean",
	TwoHanded = "integer",
	Unbreakable = "boolean",
	Unrepairable = "boolean",
	Unstorable = "boolean",
	Vitality = "integer",
	VitalityBoost = "integer",
	VitalityMastery = "integer",
	Wand = "integer",
	WarmImmunity = "boolean",
	WarriorLore = "integer",
	WaterResistance = "integer",
	WaterSpecialist = "integer",
	WeakImmunity = "boolean",
	WebImmunity = "boolean",
	Weight = "integer",
	WetImmunity = "boolean",
	Willpower = "integer",
	Wits = "integer",
}

local characterTalents = {
	TALENT_ActionPoints = "boolean",
	TALENT_ActionPoints2 = "boolean",
	TALENT_AirSpells = "boolean",
	TALENT_Ambidextrous = "boolean",
	TALENT_AnimalEmpathy = "boolean",
	TALENT_AttackOfOpportunity = "boolean",
	TALENT_AvoidDetection = "boolean",
	TALENT_Awareness = "boolean",
	TALENT_Backstab = "boolean",
	TALENT_BeastMaster = "boolean",
	TALENT_Bully = "boolean",
	TALENT_Carry = "boolean",
	TALENT_ChanceToHitMelee = "boolean",
	TALENT_ChanceToHitRanged = "boolean",
	TALENT_Charm = "boolean",
	TALENT_Courageous = "boolean",
	TALENT_Criticals = "boolean",
	TALENT_Damage = "boolean",
	TALENT_DeathfogResistant = "boolean",
	TALENT_Demon = "boolean",
	TALENT_DualWieldingDodging = "boolean",
	TALENT_Durability = "boolean",
	TALENT_Dwarf_Sneaking = "boolean",
	TALENT_Dwarf_Sturdy = "boolean",
	TALENT_EarthSpells = "boolean",
	TALENT_ElementalAffinity = "boolean",
	TALENT_Elementalist = "boolean",
	TALENT_ElementalRanger = "boolean",
	TALENT_Elf_CorpseEating = "boolean",
	TALENT_Elf_Lore = "boolean",
	TALENT_Escapist = "boolean",
	TALENT_Executioner = "boolean",
	TALENT_ExpGain = "boolean",
	TALENT_ExtraSkillPoints = "boolean",
	TALENT_ExtraStatPoints = "boolean",
	TALENT_FaroutDude = "boolean",
	TALENT_FireSpells = "boolean",
	TALENT_FiveStarRestaurant = "boolean",
	TALENT_Flanking = "boolean",
	TALENT_FolkDancer = "boolean",
	TALENT_Gladiator = "boolean",
	TALENT_GoldenMage = "boolean",
	TALENT_GreedyVessel = "boolean",
	TALENT_Haymaker = "boolean",
	TALENT_Human_Civil = "boolean",
	TALENT_Human_Inventive = "boolean",
	TALENT_IceKing = "boolean",
	TALENT_IncreasedArmor = "boolean",
	TALENT_Indomitable = "boolean",
	TALENT_Initiative = "boolean",
	TALENT_Intimidate = "boolean",
	TALENT_InventoryAccess = "boolean",
	TALENT_ItemCreation = "boolean",
	TALENT_ItemMovement = "boolean",
	TALENT_Jitterbug = "boolean",
	TALENT_Kickstarter = "boolean",
	TALENT_Leech = "boolean",
	TALENT_LightningRod = "boolean",
	TALENT_LightStep = "boolean",
	TALENT_LivingArmor = "boolean",
	TALENT_Lizard_Persuasion = "boolean",
	TALENT_Lizard_Resistance = "boolean",
	TALENT_Lockpick = "boolean",
	TALENT_LoneWolf = "boolean",
	TALENT_Luck = "boolean",
	TALENT_MagicCycles = "boolean",
	TALENT_MasterThief = "boolean",
	TALENT_Memory = "boolean",
	TALENT_MrKnowItAll = "boolean",
	TALENT_NaturalConductor = "boolean",
	TALENT_NoAttackOfOpportunity = "boolean",
	--TALENT_None = "boolean",
	TALENT_PainDrinker = "boolean",
	TALENT_Perfectionist = "boolean",
	TALENT_Politician = "boolean",
	TALENT_Quest_GhostTree = "boolean",
	TALENT_Quest_Rooted = "boolean",
	TALENT_Quest_SpidersKiss_Int = "boolean",
	TALENT_Quest_SpidersKiss_Null = "boolean",
	TALENT_Quest_SpidersKiss_Per = "boolean",
	TALENT_Quest_SpidersKiss_Str = "boolean",
	TALENT_Quest_TradeSecrets = "boolean",
	TALENT_QuickStep = "boolean",
	TALENT_Rager = "boolean",
	TALENT_Raistlin = "boolean",
	TALENT_RangerLoreArrowRecover = "boolean",
	TALENT_RangerLoreEvasionBonus = "boolean",
	TALENT_RangerLoreRangedAPBonus = "boolean",
	TALENT_Reason = "boolean",
	TALENT_Repair = "boolean",
	TALENT_ResistDead = "boolean",
	TALENT_ResistFear = "boolean",
	TALENT_ResistKnockdown = "boolean",
	TALENT_ResistPoison = "boolean",
	TALENT_ResistSilence = "boolean",
	TALENT_ResistStun = "boolean",
	TALENT_ResurrectExtraHealth = "boolean",
	TALENT_ResurrectToFullHealth = "boolean",
	TALENT_RogueLoreDaggerAPBonus = "boolean",
	TALENT_RogueLoreDaggerBackStab = "boolean",
	TALENT_RogueLoreGrenadePrecision = "boolean",
	TALENT_RogueLoreHoldResistance = "boolean",
	TALENT_RogueLoreMovementBonus = "boolean",
	TALENT_Sadist = "boolean",
	TALENT_Scientist = "boolean",
	TALENT_Sight = "boolean",
	TALENT_Soulcatcher = "boolean",
	TALENT_Sourcerer = "boolean",
	TALENT_SpillNoBlood = "boolean",
	TALENT_StandYourGround = "boolean",
	TALENT_Stench = "boolean",
	TALENT_SurpriseAttack = "boolean",
	TALENT_Throwing = "boolean",
	TALENT_Torturer = "boolean",
	TALENT_Trade = "boolean",
	TALENT_Unstable = "boolean",
	TALENT_ViolentMagic = "boolean",
	TALENT_Vitality = "boolean",
	TALENT_WalkItOff = "boolean",
	TALENT_WandCharge = "boolean",
	TALENT_WarriorLoreGrenadeRange = "boolean",
	TALENT_WarriorLoreNaturalArmor = "boolean",
	TALENT_WarriorLoreNaturalHealth = "boolean",
	TALENT_WarriorLoreNaturalResistance = "boolean",
	TALENT_WaterSpells = "boolean",
	TALENT_WeatherProof = "boolean",
	TALENT_WhatARush = "boolean",
	TALENT_WildMag = "boolean",
	TALENT_Zombie = "boolean",
}

local _CharacterDynamicStatProperties = {
	"APCostBoost",
	"APMaximum",
	"APRecovery",
	"APStart",
	"Accuracy",
	"AcidImmunity",
	"AirResistance",
	"AirSpecialist",
	"Armor",
	"ArmorBoost",
	"ArmorBoostGrowthPerLevel",
	"Arrow",
	"Barter",
	"BleedingImmunity",
	"BlessedImmunity",
	"BlindImmunity",
	"Bodybuilding",
	"BonusWeapon",
	"BonusWeaponDamageMultiplier",
	"Brewmaster",
	"BurnContact",
	"BurnImmunity",
	"ChanceToHitBoost",
	"Charm",
	"CharmImmunity",
	"ChickenImmunity",
	"ChillContact",
	"ChilledImmunity",
	"ClairvoyantImmunity",
	"Constitution",
	"CorrosiveResistance",
	"Crafting",
	"CrippledImmunity",
	"CriticalChance",
	"CursedImmunity",
	"CustomResistance",
	"DamageBoost",
	"DamageBoostGrowthPerLevel",
	"DecayingImmunity",
	"DeflectProjectiles",
	"DisarmedImmunity",
	"DiseasedImmunity",
	"Dodge",
	"DrunkImmunity",
	"DualWielding",
	"EarthResistance",
	"EarthSpecialist",
	"EnragedImmunity",
	"EntangledContact",
	"FOV",
	"FearImmunity",
	"Finesse",
	"FireResistance",
	"FireSpecialist",
	"Floating",
	"FreezeContact",
	"FreezeImmunity",
	"Gain",
	"Grounded",
	"HastedImmunity",
	"Hearing",
	"IgnoreClouds",
	"IgnoreCursedOil",
	"InfectiousDiseasedImmunity",
	"Initiative",
	"Intelligence",
	"Intimidate",
	"InvisibilityImmunity",
	"KnockdownImmunity",
	"Leadership",
	"Level",
	"LifeSteal",
	"LootableWhenEquipped",
	"Loremaster",
	"LoseDurabilityOnCharacterHit",
	"Luck",
	"MadnessImmunity",
	"MagicArmor",
	"MagicArmorBoost",
	"MagicArmorBoostGrowthPerLevel",
	"MagicArmorMastery",
	"MagicPoints",
	"MagicResistance",
	"MagicalSulfur",
	"MaxResistance",
	"MaxSummons",
	"Memory",
	"Movement",
	"MovementSpeedBoost",
	"MuteImmunity",
	"Necromancy",
	"PainReflection",
	"Perseverance",
	"Persuasion",
	"PetrifiedImmunity",
	"PhysicalArmorMastery",
	"PhysicalResistance",
	"Pickpocket",
	"PickpocketableWhenEquipped",
	"PiercingResistance",
	"PoisonContact",
	"PoisonImmunity",
	"PoisonResistance",
	"Polymorph",
	"ProtectFromSummon",
	"RangeBoost",
	"Ranged",
	"RangerLore",
	"Reason",
	"Reflexes",
	"RegeneratingImmunity",
	"Repair",
	"RogueLore",
	"Runecrafting",
	"SPCostBoost",
	"Sentinel",
	"ShacklesOfPainImmunity",
	"ShadowResistance",
	"Shield",
	"ShockedImmunity",
	"Sight",
	"SingleHanded",
	"SleepingImmunity",
	"SlippingImmunity",
	"SlowedImmunity",
	"Sneaking",
	"Sourcery",
	"StepsType",
	"Strength",
	"StunContact",
	"StunImmunity",
	"SuffocatingImmunity",
	"Sulfurology",
	"SummonLifelinkModifier",
	"Summoning",
	"TALENT_ActionPoints",
	"TALENT_ActionPoints2",
	"TALENT_AirSpells",
	"TALENT_Ambidextrous",
	"TALENT_AnimalEmpathy",
	"TALENT_AttackOfOpportunity",
	"TALENT_AvoidDetection",
	"TALENT_Awareness",
	"TALENT_Backstab",
	"TALENT_BeastMaster",
	"TALENT_Bully",
	"TALENT_Carry",
	"TALENT_ChanceToHitMelee",
	"TALENT_ChanceToHitRanged",
	"TALENT_Charm",
	"TALENT_Courageous",
	"TALENT_Criticals",
	"TALENT_Damage",
	"TALENT_DeathfogResistant",
	"TALENT_Demon",
	"TALENT_DualWieldingDodging",
	"TALENT_Durability",
	"TALENT_Dwarf_Sneaking",
	"TALENT_Dwarf_Sturdy",
	"TALENT_EarthSpells",
	"TALENT_ElementalAffinity",
	"TALENT_ElementalRanger",
	"TALENT_Elementalist",
	"TALENT_Elf_CorpseEating",
	"TALENT_Elf_Lore",
	"TALENT_Escapist",
	"TALENT_Executioner",
	"TALENT_ExpGain",
	"TALENT_ExtraSkillPoints",
	"TALENT_ExtraStatPoints",
	"TALENT_FaroutDude",
	"TALENT_FireSpells",
	"TALENT_FiveStarRestaurant",
	"TALENT_Flanking",
	"TALENT_FolkDancer",
	"TALENT_Gladiator",
	"TALENT_GoldenMage",
	"TALENT_GreedyVessel",
	"TALENT_Haymaker",
	"TALENT_Human_Civil",
	"TALENT_Human_Inventive",
	"TALENT_IceKing",
	"TALENT_IncreasedArmor",
	"TALENT_Indomitable",
	"TALENT_Initiative",
	"TALENT_Intimidate",
	"TALENT_InventoryAccess",
	"TALENT_ItemCreation",
	"TALENT_ItemMovement",
	"TALENT_Jitterbug",
	"TALENT_Kickstarter",
	"TALENT_Leech",
	"TALENT_LightStep",
	"TALENT_LightningRod",
	"TALENT_LivingArmor",
	"TALENT_Lizard_Persuasion",
	"TALENT_Lizard_Resistance",
	"TALENT_Lockpick",
	"TALENT_LoneWolf",
	"TALENT_Luck",
	"TALENT_MagicCycles",
	"TALENT_MasterThief",
	"TALENT_Max",
	"TALENT_Memory",
	"TALENT_MrKnowItAll",
	"TALENT_NaturalConductor",
	"TALENT_NoAttackOfOpportunity",
	"TALENT_None",
	"TALENT_PainDrinker",
	"TALENT_Perfectionist",
	"TALENT_Politician",
	"TALENT_Quest_GhostTree",
	"TALENT_Quest_Rooted",
	"TALENT_Quest_SpidersKiss_Int",
	"TALENT_Quest_SpidersKiss_Null",
	"TALENT_Quest_SpidersKiss_Per",
	"TALENT_Quest_SpidersKiss_Str",
	"TALENT_Quest_TradeSecrets",
	"TALENT_QuickStep",
	"TALENT_Rager",
	"TALENT_Raistlin",
	"TALENT_RangerLoreArrowRecover",
	"TALENT_RangerLoreEvasionBonus",
	"TALENT_RangerLoreRangedAPBonus",
	"TALENT_Reason",
	"TALENT_Repair",
	"TALENT_ResistDead",
	"TALENT_ResistFear",
	"TALENT_ResistKnockdown",
	"TALENT_ResistPoison",
	"TALENT_ResistSilence",
	"TALENT_ResistStun",
	"TALENT_ResurrectExtraHealth",
	"TALENT_ResurrectToFullHealth",
	"TALENT_RogueLoreDaggerAPBonus",
	"TALENT_RogueLoreDaggerBackStab",
	"TALENT_RogueLoreGrenadePrecision",
	"TALENT_RogueLoreHoldResistance",
	"TALENT_RogueLoreMovementBonus",
	"TALENT_Sadist",
	"TALENT_Scientist",
	"TALENT_Sight",
	"TALENT_Soulcatcher",
	"TALENT_Sourcerer",
	"TALENT_SpillNoBlood",
	"TALENT_StandYourGround",
	"TALENT_Stench",
	"TALENT_SurpriseAttack",
	"TALENT_Throwing",
	"TALENT_Torturer",
	"TALENT_Trade",
	"TALENT_Unstable",
	"TALENT_ViolentMagic",
	"TALENT_Vitality",
	"TALENT_WalkItOff",
	"TALENT_WandCharge",
	"TALENT_WarriorLoreGrenadeRange",
	"TALENT_WarriorLoreNaturalArmor",
	"TALENT_WarriorLoreNaturalHealth",
	"TALENT_WarriorLoreNaturalResistance",
	"TALENT_WaterSpells",
	"TALENT_WeatherProof",
	"TALENT_WhatARush",
	"TALENT_WildMag",
	"TALENT_Zombie",
	"TauntedImmunity",
	"Telekinesis",
	"Thievery",
	"ThrownImmunity",
	"Torch",
	"TranslationKey",
	"TwoHanded",
	"Unbreakable",
	"Unrepairable",
	"Unstorable",
	"Vitality",
	"VitalityBoost",
	"VitalityMastery",
	"Wand",
	"WarmImmunity",
	"WarriorLore",
	"WaterResistance",
	"WaterSpecialist",
	"WeakImmunity",
	"WebImmunity",
	"Weight",
	"WetImmunity",
	"Willpower",
	"Wits",
}

local _EmptyCharacterDynamicStats = {
	["APCostBoost"] = 0,
	["APMaximum"] = 0,
	["APRecovery"] = 0,
	["APStart"] = 0,
	["Accuracy"] = 0,
	["AcidImmunity"] = false,
	["AirResistance"] = 0,
	["AirSpecialist"] = 0,
	["Armor"] = 0,
	["ArmorBoost"] = 0,
	["ArmorBoostGrowthPerLevel"] = 0,
	["Arrow"] = false,
	["Barter"] = 0,
	["BleedingImmunity"] = false,
	["BlessedImmunity"] = false,
	["BlindImmunity"] = false,
	["Bodybuilding"] = 0,
	["BonusWeapon"] = "",
	["BonusWeaponDamageMultiplier"] = 0,
	["Brewmaster"] = 0,
	["BurnContact"] = false,
	["BurnImmunity"] = false,
	["ChanceToHitBoost"] = 0,
	["Charm"] = 0,
	["CharmImmunity"] = false,
	["ChickenImmunity"] = false,
	["ChillContact"] = false,
	["ChilledImmunity"] = false,
	["ClairvoyantImmunity"] = false,
	["Constitution"] = 0,
	["CorrosiveResistance"] = 0,
	["Crafting"] = 0,
	["CrippledImmunity"] = false,
	["CriticalChance"] = 0,
	["CursedImmunity"] = false,
	["CustomResistance"] = 0,
	["DamageBoost"] = 0,
	["DamageBoostGrowthPerLevel"] = 0,
	["DecayingImmunity"] = false,
	["DeflectProjectiles"] = false,
	["DisarmedImmunity"] = false,
	["DiseasedImmunity"] = false,
	["Dodge"] = 0,
	["DrunkImmunity"] = false,
	["DualWielding"] = 0,
	["EarthResistance"] = 0,
	["EarthSpecialist"] = 0,
	["EnragedImmunity"] = false,
	["EntangledContact"] = false,
	["FOV"] = 0,
	["FearImmunity"] = false,
	["Finesse"] = 0,
	["FireResistance"] = 0,
	["FireSpecialist"] = 0,
	["Floating"] = false,
	["FreezeContact"] = false,
	["FreezeImmunity"] = false,
	["Gain"] = 0,
	["Grounded"] = false,
	["HastedImmunity"] = false,
	["Hearing"] = 0,
	["IgnoreClouds"] = false,
	["IgnoreCursedOil"] = false,
	["InfectiousDiseasedImmunity"] = false,
	["Initiative"] = 0,
	["Intelligence"] = 0,
	["Intimidate"] = 0,
	["InvisibilityImmunity"] = false,
	["KnockdownImmunity"] = false,
	["Leadership"] = 0,
	["Level"] = 0,
	["LifeSteal"] = 0,
	["LootableWhenEquipped"] = false,
	["Loremaster"] = 0,
	["LoseDurabilityOnCharacterHit"] = false,
	["Luck"] = 0,
	["MadnessImmunity"] = false,
	["MagicArmor"] = 0,
	["MagicArmorBoost"] = 0,
	["MagicArmorBoostGrowthPerLevel"] = 0,
	["MagicArmorMastery"] = 0,
	["MagicPoints"] = 0,
	["MagicResistance"] = 0,
	["MagicalSulfur"] = false,
	["MaxResistance"] = 0,
	["MaxSummons"] = 0,
	["Memory"] = 0,
	["Movement"] = 0,
	["MovementSpeedBoost"] = 0,
	["MuteImmunity"] = false,
	["Necromancy"] = 0,
	["PainReflection"] = 0,
	["Perseverance"] = 0,
	["Persuasion"] = 0,
	["PetrifiedImmunity"] = false,
	["PhysicalArmorMastery"] = 0,
	["PhysicalResistance"] = 0,
	["Pickpocket"] = 0,
	["PickpocketableWhenEquipped"] = false,
	["PiercingResistance"] = 0,
	["PoisonContact"] = false,
	["PoisonImmunity"] = false,
	["PoisonResistance"] = 0,
	["Polymorph"] = 0,
	["ProtectFromSummon"] = false,
	["RangeBoost"] = 0,
	["Ranged"] = 0,
	["RangerLore"] = 0,
	["Reason"] = 0,
	["Reflexes"] = 0,
	["RegeneratingImmunity"] = false,
	["Repair"] = 0,
	["RogueLore"] = 0,
	["Runecrafting"] = 0,
	["SPCostBoost"] = 0,
	["Sentinel"] = 0,
	["ShacklesOfPainImmunity"] = false,
	["ShadowResistance"] = 0,
	["Shield"] = 0,
	["ShockedImmunity"] = false,
	["Sight"] = 0,
	["SingleHanded"] = 0,
	["SleepingImmunity"] = false,
	["SlippingImmunity"] = false,
	["SlowedImmunity"] = false,
	["Sneaking"] = 0,
	["Sourcery"] = 0,
	["StepsType"] = 0,
	["Strength"] = 0,
	["StunContact"] = false,
	["StunImmunity"] = false,
	["SuffocatingImmunity"] = false,
	["Sulfurology"] = 0,
	["SummonLifelinkModifier"] = 0,
	["Summoning"] = 0,
	["TALENT_ActionPoints"] = false,
	["TALENT_ActionPoints2"] = false,
	["TALENT_AirSpells"] = false,
	["TALENT_Ambidextrous"] = false,
	["TALENT_AnimalEmpathy"] = false,
	["TALENT_AttackOfOpportunity"] = false,
	["TALENT_AvoidDetection"] = false,
	["TALENT_Awareness"] = false,
	["TALENT_Backstab"] = false,
	["TALENT_BeastMaster"] = false,
	["TALENT_Bully"] = false,
	["TALENT_Carry"] = false,
	["TALENT_ChanceToHitMelee"] = false,
	["TALENT_ChanceToHitRanged"] = false,
	["TALENT_Charm"] = false,
	["TALENT_Courageous"] = false,
	["TALENT_Criticals"] = false,
	["TALENT_Damage"] = false,
	["TALENT_DeathfogResistant"] = false,
	["TALENT_Demon"] = false,
	["TALENT_DualWieldingDodging"] = false,
	["TALENT_Durability"] = false,
	["TALENT_Dwarf_Sneaking"] = false,
	["TALENT_Dwarf_Sturdy"] = false,
	["TALENT_EarthSpells"] = false,
	["TALENT_ElementalAffinity"] = false,
	["TALENT_ElementalRanger"] = false,
	["TALENT_Elementalist"] = false,
	["TALENT_Elf_CorpseEating"] = false,
	["TALENT_Elf_Lore"] = false,
	["TALENT_Escapist"] = false,
	["TALENT_Executioner"] = false,
	["TALENT_ExpGain"] = false,
	["TALENT_ExtraSkillPoints"] = false,
	["TALENT_ExtraStatPoints"] = false,
	["TALENT_FaroutDude"] = false,
	["TALENT_FireSpells"] = false,
	["TALENT_FiveStarRestaurant"] = false,
	["TALENT_Flanking"] = false,
	["TALENT_FolkDancer"] = false,
	["TALENT_Gladiator"] = false,
	["TALENT_GoldenMage"] = false,
	["TALENT_GreedyVessel"] = false,
	["TALENT_Haymaker"] = false,
	["TALENT_Human_Civil"] = false,
	["TALENT_Human_Inventive"] = false,
	["TALENT_IceKing"] = false,
	["TALENT_IncreasedArmor"] = false,
	["TALENT_Indomitable"] = false,
	["TALENT_Initiative"] = false,
	["TALENT_Intimidate"] = false,
	["TALENT_InventoryAccess"] = false,
	["TALENT_ItemCreation"] = false,
	["TALENT_ItemMovement"] = false,
	["TALENT_Jitterbug"] = false,
	["TALENT_Kickstarter"] = false,
	["TALENT_Leech"] = false,
	["TALENT_LightStep"] = false,
	["TALENT_LightningRod"] = false,
	["TALENT_LivingArmor"] = false,
	["TALENT_Lizard_Persuasion"] = false,
	["TALENT_Lizard_Resistance"] = false,
	["TALENT_Lockpick"] = false,
	["TALENT_LoneWolf"] = false,
	["TALENT_Luck"] = false,
	["TALENT_MagicCycles"] = false,
	["TALENT_MasterThief"] = false,
	["TALENT_Max"] = false,
	["TALENT_Memory"] = false,
	["TALENT_MrKnowItAll"] = false,
	["TALENT_NaturalConductor"] = false,
	["TALENT_NoAttackOfOpportunity"] = false,
	["TALENT_None"] = false,
	["TALENT_PainDrinker"] = false,
	["TALENT_Perfectionist"] = false,
	["TALENT_Politician"] = false,
	["TALENT_Quest_GhostTree"] = false,
	["TALENT_Quest_Rooted"] = false,
	["TALENT_Quest_SpidersKiss_Int"] = false,
	["TALENT_Quest_SpidersKiss_Null"] = false,
	["TALENT_Quest_SpidersKiss_Per"] = false,
	["TALENT_Quest_SpidersKiss_Str"] = false,
	["TALENT_Quest_TradeSecrets"] = false,
	["TALENT_QuickStep"] = false,
	["TALENT_Rager"] = false,
	["TALENT_Raistlin"] = false,
	["TALENT_RangerLoreArrowRecover"] = false,
	["TALENT_RangerLoreEvasionBonus"] = false,
	["TALENT_RangerLoreRangedAPBonus"] = false,
	["TALENT_Reason"] = false,
	["TALENT_Repair"] = false,
	["TALENT_ResistDead"] = false,
	["TALENT_ResistFear"] = false,
	["TALENT_ResistKnockdown"] = false,
	["TALENT_ResistPoison"] = false,
	["TALENT_ResistSilence"] = false,
	["TALENT_ResistStun"] = false,
	["TALENT_ResurrectExtraHealth"] = false,
	["TALENT_ResurrectToFullHealth"] = false,
	["TALENT_RogueLoreDaggerAPBonus"] = false,
	["TALENT_RogueLoreDaggerBackStab"] = false,
	["TALENT_RogueLoreGrenadePrecision"] = false,
	["TALENT_RogueLoreHoldResistance"] = false,
	["TALENT_RogueLoreMovementBonus"] = false,
	["TALENT_Sadist"] = false,
	["TALENT_Scientist"] = false,
	["TALENT_Sight"] = false,
	["TALENT_Soulcatcher"] = false,
	["TALENT_Sourcerer"] = false,
	["TALENT_SpillNoBlood"] = false,
	["TALENT_StandYourGround"] = false,
	["TALENT_Stench"] = false,
	["TALENT_SurpriseAttack"] = false,
	["TALENT_Throwing"] = false,
	["TALENT_Torturer"] = false,
	["TALENT_Trade"] = false,
	["TALENT_Unstable"] = false,
	["TALENT_ViolentMagic"] = false,
	["TALENT_Vitality"] = false,
	["TALENT_WalkItOff"] = false,
	["TALENT_WandCharge"] = false,
	["TALENT_WarriorLoreGrenadeRange"] = false,
	["TALENT_WarriorLoreNaturalArmor"] = false,
	["TALENT_WarriorLoreNaturalHealth"] = false,
	["TALENT_WarriorLoreNaturalResistance"] = false,
	["TALENT_WaterSpells"] = false,
	["TALENT_WeatherProof"] = false,
	["TALENT_WhatARush"] = false,
	["TALENT_WildMag"] = false,
	["TALENT_Zombie"] = false,
	["TauntedImmunity"] = false,
	["Telekinesis"] = 0,
	["Thievery"] = 0,
	["ThrownImmunity"] = false,
	["Torch"] = false,
	["TranslationKey"] = "",
	["TwoHanded"] = 0,
	["Unbreakable"] = false,
	["Unrepairable"] = false,
	["Unstorable"] = false,
	["Vitality"] = 0,
	["VitalityBoost"] = 0,
	["VitalityMastery"] = 0,
	["Wand"] = 0,
	["WarmImmunity"] = false,
	["WarriorLore"] = 0,
	["WaterResistance"] = 0,
	["WaterSpecialist"] = 0,
	["WeakImmunity"] = false,
	["WebImmunity"] = false,
	["Weight"] = 0,
	["WetImmunity"] = false,
	["Willpower"] = 0,
	["Wits"] = 0,
}

---@param stat string
---@param mainhand StatItemDynamic|nil
---@param offhand StatItemDynamic|nil
function GameHelpers.Ext.CreateStatCharacterTable(stat, mainhand, offhand)
	if stat == nil then
		stat = "_Hero"
	end
	local data = {
		DynamicStats = {
			TableHelpers.Clone(_EmptyCharacterDynamicStats),
			TableHelpers.Clone(_EmptyCharacterDynamicStats),
			TableHelpers.Clone(_EmptyCharacterDynamicStats),
			TableHelpers.Clone(_EmptyCharacterDynamicStats),
			TableHelpers.Clone(_EmptyCharacterDynamicStats),
			TableHelpers.Clone(_EmptyCharacterDynamicStats),
			TableHelpers.Clone(_EmptyCharacterDynamicStats),
		}
	}

	local baseValue = GameHelpers.GetExtraData("AttributeBaseValue", 10)
	local statObject = Ext.Stats.Get(stat, nil, false)
	if statObject then
		for i,attribute in pairs(characterStatAttributes) do
			local value = statObject[attribute]
			if value ~= nil then
				if Data.Attribute[attribute] then
					data.DynamicStats[1][attribute] = baseValue + value
				else
					data.DynamicStats[1][attribute] = value
				end
			end
		end
	else
		for _,attribute in Data.Attribute:Get() do
			data.DynamicStats[1][attribute] = baseValue
		end
	end

	for prop,t in pairs(characterStatProperties) do
		if data.DynamicStats[1][prop] == nil then
			if t == "boolean" then
				data[prop] = false
			elseif t == "number" then
				data[prop] = 0.0
			elseif t == "integer" then
				data[prop] = 0
			elseif t == "string" then
				data[prop] = ""
			end
		else
			data[prop] = data.DynamicStats[1][prop]
		end
	end
	data.MainWeapon = mainhand
	data.OffHandWeapon = offhand
	return data
end

local _WEAPON_STAT_ATTRIBUTES = {
	"AccuracyBoost",
	"Act part",
	"Act",
	"Air",
	"AirSpecialist",
	"AnimType",
	"APMaximum",
	"APRecovery",
	"APStart",
	"AttackAPCost",
	"Barter",
	"Boosts",
	"ChanceToHitBoost",
	"Charges",
	"CleaveAngle",
	"CleavePercentage",
	"ComboCategory",
	"ConstitutionBoost",
	"CriticalChance",
	"CriticalDamage",
	"Damage Range",
	"Damage Type",
	"Damage",
	"DamageBoost",
	"DamageFromBase",
	"DodgeBoost",
	"DualWielding",
	"Durability",
	"DurabilityDegradeSpeed",
	"Earth",
	"EarthSpecialist",
	"FinesseBoost",
	"Fire",
	"FireSpecialist",
	"Flags",
	"Handedness",
	"HearingBoost",
	"IgnoreVisionBlock",
	"Initiative",
	"IntelligenceBoost",
	"InventoryTab",
	"IsTwoHanded",
	"ItemColor",
	"ItemGroup",
	"Leadership",
	"LifeSteal",
	"Loremaster",
	"Luck",
	"MagicPointsBoost",
	"MaxAmount",
	"MaxCharges",
	"MaxLevel",
	"MaxSummons",
	"MemoryBoost",
	"MinAmount",
	"MinLevel",
	"ModifierType",
	"Movement",
	"Necromancy",
	"NeedsIdentification",
	"ObjectCategory",
	"PainReflection",
	"Perseverance",
	"Persuasion",
	"Physical",
	"Piercing",
	"Poison",
	"Polymorph",
	"Priority",
	"Projectile",
	"Ranged",
	"RangerLore",
	"Reflection",
	"Repair",
	"Requirements",
	"RogueLore",
	"RuneSlots_V1",
	"RuneSlots",
	"SightBoost",
	"SingleHanded",
	"Skills",
	"Slot",
	"Sneaking",
	"Sourcery",
	"StrengthBoost",
	"Summoning",
	"Tags",
	"Talents",
	"Telekinesis",
	"Thievery",
	"TwoHanded",
	"Unique",
	"Value",
	"VitalityBoost",
	"WarriorLore",
	"Water",
	"WaterSpecialist",
	"WeaponRange",
	"WeaponType",
	"Weight",
	"WitsBoost",
}

---@param stat string
---@param level integer
---@param attribute string|nil
---@param weaponType string|nil
---@param damageFromBaseBoost integer|nil
---@param isBoostStat boolean|nil
---@param baseWeaponDamage number|nil
---@return CDivinityStatsItem
function GameHelpers.Ext.CreateWeaponTable(stat,level,attribute,weaponType,damageFromBaseBoost,isBoostStat,baseWeaponDamage)
	local weapon = {}
	weapon.ItemType = "Weapon"
	weapon.Name = stat
	level = level or 1
	local statObject = Ext.Stats.Get(stat, math.max(level, 1), false) --[[@as StatEntryWeapon]]
	if statObject == nil then
		--fprint(LOGLEVEL.ERROR, "[GameHelpers.Ext.CreateWeaponTable] Failed to get stat for id (%s)", stat)
		error(string.format("[GameHelpers.Ext.CreateWeaponTable] Failed to get stat for id (%s)", stat), 2)
	end
	if attribute ~= nil then
		weapon.Requirements = {
			{
				Requirement = attribute,
				Param = 0,
				Not = false
			}
		}
	else
		weapon.Requirements = statObject.Requirements
	end
	local weaponStat = {Name = stat}
	for i,v in pairs(_WEAPON_STAT_ATTRIBUTES) do
		weaponStat[v] = statObject[v]
	end
	weapon["ModifierType"] = weaponStat["ModifierType"]
	weapon["IsTwoHanded"] = weaponStat["IsTwoHanded"]
	weapon["WeaponType"] = weaponStat["WeaponType"]
	if damageFromBaseBoost ~= nil and damageFromBaseBoost > 0 then
		weaponStat.DamageFromBase = weaponStat.DamageFromBase + damageFromBaseBoost
	end
	local baseDamage = 0
	if baseWeaponDamage ~= nil then
		baseDamage = baseWeaponDamage
	else
		baseDamage = statObject.Damage
	end
	local damageRange = (statObject["Damage Range"] * 0.005) * baseDamage
	weaponStat.MinDamage = Ext.Utils.Round(baseDamage - damageRange)
	weaponStat.MaxDamage = Ext.Utils.Round(baseDamage + damageRange)
	weaponStat.DamageType = weaponStat["Damage Type"]
	weaponStat.StatsType = "Weapon"
	if weaponType ~= nil then
		weapon.WeaponType = weaponType
		weaponStat.WeaponType = weaponType
	end
	weaponStat.Requirements = weapon.Requirements
	weapon.DynamicStats = {weaponStat}
	weapon.ExtraProperties = statObject.ExtraProperties
	if not isBoostStat then
		local boostsString = statObject.Boosts
		if boostsString ~= nil and boostsString ~= "" then
			local boosts = StringHelpers.Split(boostsString, ";")
			for i,boostStat in pairs(boosts) do
				if boostStat ~= nil and boostStat ~= "" then
					local boostWeaponStat = GameHelpers.Ext.CreateWeaponTable(boostStat, level, attribute, weaponType, nil, true, baseDamage)
					if boostWeaponStat ~= nil then
						table.insert(weapon.DynamicStats, boostWeaponStat.DynamicStats[1])
					end
				end
			end
		end
	end
	return weapon
end

local _GameMathSkillAttributes = {
	"Ability",
	--"ActionPoints",
	--"Cooldown",
	"Damage Multiplier",
	"Damage Range",
	"Damage",
	"DamageType",
	"DeathType",
	"Distance Damage Multiplier",
	"IsEnemySkill",
	"IsMelee",
	"Level",
	"Requirement",
	--"Magic Cost",
	--"Memory Cost",
	"OverrideMinAP",
	"OverrideSkillLevel",
	--"Range",
	"SkillType",
	"Stealth Damage Multiplier",
	--"Tier",
	"UseCharacterStats",
	"UseWeaponDamage",
	"UseWeaponProperties",
	"SkillProperties",
}

local _SkillAttributes = {
	["SkillType"] = "FixedString",
	["Level"] = "ConstantInt",
	["Ability"] = "SkillAbility",
	["Element"] = "SkillElement",
	["Requirement"] = "SkillRequirement",
	["Requirements"] = "Requirements",
	["DisplayName"] = "FixedString",
	["DisplayNameRef"] = "FixedString",
	["Description"] = "FixedString",
	["DescriptionRef"] = "FixedString",
	["StatsDescription"] = "FixedString",
	["StatsDescriptionRef"] = "FixedString",
	["StatsDescriptionParams"] = "FixedString",
	["Icon"] = "FixedString",
	["FXScale"] = "ConstantInt",
	["PrepareAnimationInit"] = "FixedString",
	["PrepareAnimationLoop"] = "FixedString",
	["PrepareEffect"] = "FixedString",
	["PrepareEffectBone"] = "FixedString",
	["CastAnimation"] = "FixedString",
	["CastTextEvent"] = "FixedString",
	["CastAnimationCheck"] = "CastCheckType",
	["CastEffect"] = "FixedString",
	["CastEffectTextEvent"] = "FixedString",
	["TargetCastEffect"] = "FixedString",
	["TargetHitEffect"] = "FixedString",
	["TargetEffect"] = "FixedString",
	["SourceTargetEffect"] = "FixedString",
	["TargetTargetEffect"] = "FixedString",
	["LandingEffect"] = "FixedString",
	["ImpactEffect"] = "FixedString",
	["MaleImpactEffects"] = "FixedString",
	["FemaleImpactEffects"] = "FixedString",
	["OnHitEffect"] = "FixedString",
	["SelectedCharacterEffect"] = "FixedString",
	["SelectedObjectEffect"] = "FixedString",
	["SelectedPositionEffect"] = "FixedString",
	["DisappearEffect"] = "FixedString",
	["ReappearEffect"] = "FixedString",
	["ReappearEffectTextEvent"] = "FixedString",
	["RainEffect"] = "FixedString",
	["StormEffect"] = "FixedString",
	["FlyEffect"] = "FixedString",
	["SpatterEffect"] = "FixedString",
	["ShieldMaterial"] = "FixedString",
	["ShieldEffect"] = "FixedString",
	["ContinueEffect"] = "FixedString",
	["SkillEffect"] = "FixedString",
	["Template"] = "FixedString",
	["TemplateCheck"] = "CastCheckType",
	["TemplateOverride"] = "FixedString",
	["TemplateAdvanced"] = "FixedString",
	["Totem"] = "YesNo",
	["Template1"] = "FixedString",
	["Template2"] = "FixedString",
	["Template3"] = "FixedString",
	["WeaponBones"] = "FixedString",
	["TeleportSelf"] = "YesNo",
	["CanTargetCharacters"] = "YesNo",
	["CanTargetItems"] = "YesNo",
	["CanTargetTerrain"] = "YesNo",
	["ForceTarget"] = "YesNo",
	["TargetProjectiles"] = "YesNo",
	["UseCharacterStats"] = "YesNo",
	["UseWeaponDamage"] = "YesNo",
	["UseWeaponProperties"] = "YesNo",
	["SingleSource"] = "YesNo",
	["ContinueOnKill"] = "YesNo",
	["Autocast"] = "YesNo",
	["AmountOfTargets"] = "ConstantInt",
	["AutoAim"] = "YesNo",
	["AddWeaponRange"] = "YesNo",
	["Memory Cost"] = "ConstantInt",
	["Magic Cost"] = "ConstantInt",
	["ActionPoints"] = "ConstantInt",
	["Cooldown"] = "ConstantInt",
	["CooldownReduction"] = "ConstantInt",
	["ChargeDuration"] = "ConstantInt",
	["CastDelay"] = "ConstantInt",
	["Offset"] = "ConstantInt",
	["Lifetime"] = "ConstantInt",
	["Duration"] = "Qualifier",
	["TargetRadius"] = "ConstantInt",
	["ExplodeRadius"] = "ConstantInt",
	["AreaRadius"] = "ConstantInt",
	["HitRadius"] = "ConstantInt",
	["RadiusMax"] = "ConstantInt",
	["Range"] = "ConstantInt",
	["MaxDistance"] = "ConstantInt",
	["Angle"] = "ConstantInt",
	["TravelSpeed"] = "ConstantInt",
	["Acceleration"] = "ConstantInt",
	["Height"] = "ConstantInt",
	["Damage"] = "DamageSourceType",
	["Damage Multiplier"] = "ConstantInt",
	["Damage Range"] = "ConstantInt",
	["DamageType"] = "Damage Type",
	["DamageMultiplier"] = "PreciseQualifier",
	["DeathType"] = "Death Type",
	["BonusDamage"] = "Qualifier",
	["Chance To Hit Multiplier"] = "ConstantInt",
	["HitPointsPercent"] = "ConstantInt",
	["MinHitsPerTurn"] = "ConstantInt",
	["MaxHitsPerTurn"] = "ConstantInt",
	["HitDelay"] = "ConstantInt",
	["MaxAttacks"] = "ConstantInt",
	["NextAttackChance"] = "ConstantInt",
	["NextAttackChanceDivider"] = "ConstantInt",
	["EndPosRadius"] = "ConstantInt",
	["JumpDelay"] = "ConstantInt",
	["TeleportDelay"] = "ConstantInt",
	["PointsMaxOffset"] = "ConstantInt",
	["RandomPoints"] = "ConstantInt",
	["ChanceToPierce"] = "ConstantInt",
	["MaxPierceCount"] = "ConstantInt",
	["MaxForkCount"] = "ConstantInt",
	["ForkLevels"] = "ConstantInt",
	["ForkChance"] = "ConstantInt",
	["HealAmount"] = "PreciseQualifier",
	["StatusClearChance"] = "ConstantInt",
	["SurfaceType"] = "Surface Type",
	["SurfaceLifetime"] = "ConstantInt",
	["SurfaceStatusChance"] = "ConstantInt",
	--["SurfaceTileCollision"] = "SurfaceCollisionFlags",
	["SurfaceGrowInterval"] = "ConstantInt",
	["SurfaceGrowStep"] = "ConstantInt",
	["SurfaceRadius"] = "ConstantInt",
	["TotalSurfaceCells"] = "ConstantInt",
	["SurfaceMinSpawnRadius"] = "ConstantInt",
	["MinSurfaces"] = "ConstantInt",
	["MaxSurfaces"] = "ConstantInt",
	["MinSurfaceSize"] = "ConstantInt",
	["MaxSurfaceSize"] = "ConstantInt",
	["GrowSpeed"] = "ConstantInt",
	--["GrowOnSurface"] = "SurfaceCollisionFlags",
	["GrowTimeout"] = "ConstantInt",
	["SkillBoost"] = "FixedString",
	--["SkillAttributeFlags"] = "AttributeFlags",
	["SkillProperties"] = "Properties",
	["CleanseStatuses"] = "FixedString",
	["AoEConditions"] = "Conditions",
	["TargetConditions"] = "Conditions",
	["ForkingConditions"] = "Conditions",
	["CycleConditions"] = "Conditions",
	["ShockWaveDuration"] = "ConstantInt",
	["TeleportTextEvent"] = "FixedString",
	["SummonEffect"] = "FixedString",
	["ProjectileCount"] = "ConstantInt",
	["ProjectileDelay"] = "ConstantInt",
	["StrikeCount"] = "ConstantInt",
	["StrikeDelay"] = "ConstantInt",
	["PreviewStrikeHits"] = "YesNo",
	["SummonLevel"] = "ConstantInt",
	["Damage On Jump"] = "YesNo",
	["Damage On Landing"] = "YesNo",
	["StartTextEvent"] = "FixedString",
	["StopTextEvent"] = "FixedString",
	["Healing Multiplier"] = "ConstantInt",
	["Atmosphere"] = "AtmosphereType",
	["ConsequencesStartTime"] = "ConstantInt",
	["ConsequencesDuration"] = "ConstantInt",
	["HealthBarColor"] = "ConstantInt",
	["Skillbook"] = "FixedString",
	["PreviewImpactEffect"] = "FixedString",
	["IgnoreVisionBlock"] = "YesNo",
	["HealEffectId"] = "FixedString",
	["AddRangeFromAbility"] = "Ability",
	["DivideDamage"] = "YesNo",
	["OverrideMinAP"] = "YesNo",
	["OverrideSkillLevel"] = "YesNo",
	["Tier"] = "SkillTier",
	["GrenadeBone"] = "FixedString",
	["GrenadeProjectile"] = "FixedString",
	["GrenadePath"] = "FixedString",
	["MovingObject"] = "FixedString",
	["SpawnObject"] = "FixedString",
	["SpawnEffect"] = "FixedString",
	["SpawnFXOverridesImpactFX"] = "YesNo",
	["SpawnLifetime"] = "ConstantInt",
	["ProjectileTerrainOffset"] = "YesNo",
	["ProjectileType"] = "ProjectileType",
	["HitEffect"] = "FixedString",
	["PushDistance"] = "ConstantInt",
	["ForceMove"] = "YesNo",
	["Stealth"] = "YesNo",
	["Distribution"] = "ProjectileDistribution",
	["Shuffle"] = "YesNo",
	["PushPullEffect"] = "FixedString",
	["Stealth Damage Multiplier"] = "ConstantInt",
	["Distance Damage Multiplier"] = "ConstantInt",
	["BackStart"] = "ConstantInt",
	["FrontOffset"] = "ConstantInt",
	["TargetGroundEffect"] = "FixedString",
	["PositionEffect"] = "FixedString",
	["BeamEffect"] = "FixedString",
	["PreviewEffect"] = "FixedString",
	["CastSelfAnimation"] = "FixedString",
	["IgnoreCursed"] = "YesNo",
	["IsEnemySkill"] = "YesNo",
	["DomeEffect"] = "FixedString",
	["AuraSelf"] = "FixedString",
	["AuraAllies"] = "FixedString",
	["AuraEnemies"] = "FixedString",
	["AuraNeutrals"] = "FixedString",
	["AuraItems"] = "FixedString",
	["AIFlags"] = "AIFlags",
	["Shape"] = "FixedString",
	["Base"] = "ConstantInt",
	["AiCalculationSkillOverride"] = "FixedString",
	["TeleportSurface"] = "YesNo",
	["ProjectileSkills"] = "FixedString",
	["SummonCount"] = "ConstantInt",
	["LinkTeleports"] = "YesNo",
	["TeleportsUseCount"] = "ConstantInt",
	["HeightOffset"] = "ConstantInt",
	["ForGameMaster"] = "YesNo",
	["IsMelee"] = "YesNo",
	["MemorizationRequirements"] = "MemorizationRequirements",
	["IgnoreSilence"] = "YesNo",
	["IgnoreHeight"] = "YesNo",
}


if _EXTVERSION < 56 then
	_SkillAttributes.TargetConditions = nil
	_SkillAttributes.CycleConditions = nil
	_SkillAttributes.AoEConditions = nil
end

---@param skillName string
---@param useWeaponDamage boolean|nil Overrides the UseWeaponDamage with true/false if set.
---@param isForGameMath boolean|nil If true, only attributes used in Game.Math functions are assigned.
---@return StatEntrySkillData
function GameHelpers.Ext.CreateSkillTable(skillName, useWeaponDamage, isForGameMath)
	if skillName ~= nil and skillName ~= "" then
		local hasValidEntry = false
		---@type StatEntrySkillData
		local skill = {Name = skillName, AlwaysBackstab = false}
		if isForGameMath then
			for _,k in pairs(_GameMathSkillAttributes) do
				skill[k] = GameHelpers.Stats.GetAttribute(skillName, k)
				if not hasValidEntry and skill[k] ~= nil then
					hasValidEntry = true
				end
			end
		else
			local stat = Ext.Stats.Get(skillName, nil, false)
			if stat then
				hasValidEntry = true
				for k,_ in pairs(_SkillAttributes) do
					skill[k] = stat[k]
				end
			end
		end
		if not hasValidEntry then
			-- Skill doesn't exist?
			return nil
		end
		if useWeaponDamage ~= nil then
			skill.UseWeaponDamage = useWeaponDamage and "Yes" or "No"
		end
		---@type StatPropertyStatus[]
		local skillProperties = GameHelpers.Stats.GetSkillProperties(skillName)
		if skillProperties ~= nil then
			for _,tbl in pairs(skillProperties) do
				if tbl.Action == "AlwaysBackstab" then
					skill.AlwaysBackstab = true
				end
			end
		end
		skill.IsTable = true
		return skill
	end
	return nil
end

local RuneAttributes = {
	"RuneEffectWeapon",
	"RuneEffectUpperbody",
	"RuneEffectAmulet",
}

---@param item StatItem
---@return StatItemDynamic,string
function GameHelpers.Ext.GetRuneBoosts(item)
	local boosts = {}
	if item ~= nil then
		for i=3,5,1 do
			local boost = item.DynamicStats[i]
			if boost ~= nil and boost.BoostName ~= "" then
				local runeEntry = {
					Name = boost.BoostName,
					Boosts = {}
				}
				table.insert(boosts, runeEntry)
				for i,attribute in pairs(RuneAttributes) do
					runeEntry.Boosts[attribute] = ""
					local boostStat = GameHelpers.Stats.GetAttribute(boost.BoostName, attribute)
					if boostStat ~= nil then
						runeEntry.Boosts[attribute] = boostStat
					end
				end
			end
		end
	end
	return boosts
end

---@param projectile EsvProjectile
function GameHelpers.Ext.ProjectileToTable(projectile)
	if projectile == nil then
		return {}
	end
	return {
		Type = "EsvProjectile",
		RootTemplate = {
			--ProjectileTemplate
			Type = "ProjectileTemplate",
			LifeTime = projectile.RootTemplate.LifeTime,
			Speed = projectile.RootTemplate.Speed,
			Acceleration = projectile.RootTemplate.Acceleration,
			CastBone = projectile.RootTemplate.CastBone,
			ImpactFX = projectile.RootTemplate.ImpactFX,
			TrailFX = projectile.RootTemplate.TrailFX,
			-- DestroyTrailFXOnImpact = projectile.RootTemplate.DestroyTrailFXOnImpact,
			BeamFX = projectile.RootTemplate.BeamFX,
			-- PreviewPathMaterial = projectile.RootTemplate.PreviewPathMaterial,
			-- PreviewPathImpactFX = projectile.RootTemplate.PreviewPathImpactFX,
			-- PreviewPathRadius = projectile.RootTemplate.PreviewPathRadius,
			-- ImpactFXSize = projectile.RootTemplate.ImpactFXSize,
			-- RotateImpact = projectile.RootTemplate.RotateImpact,
			-- IgnoreRoof = projectile.RootTemplate.IgnoreRoof,
			-- DetachBeam = projectile.RootTemplate.DetachBeam,
			-- NeedsArrowImpactSFX = projectile.RootTemplate.NeedsArrowImpactSFX,
			ProjectilePath = projectile.RootTemplate.ProjectilePath,
			-- PathShift = projectile.RootTemplate.PathShift,
			-- PathRadius = projectile.RootTemplate.PathRadius,
			-- PathMinArcDist = projectile.RootTemplate.PathMinArcDist,
			-- PathMaxArcDist = projectile.RootTemplate.PathMaxArcDist,
			-- PathRepeat = projectile.RootTemplate.PathRepeat,
			-- EoCGameObjectTemplate
			Id = projectile.RootTemplate.Id,
			Name = projectile.RootTemplate.Name,
			TemplateName = GameHelpers.GetTemplate(projectile),
			-- IsGlobal = projectile.RootTemplate.IsGlobal,
			-- IsDeleted = projectile.RootTemplate.IsDeleted,
			-- LevelName = projectile.RootTemplate.LevelName,
			-- ModFolder = projectile.RootTemplate.ModFolder,
			-- GroupID = projectile.RootTemplate.GroupID,
			VisualTemplate = projectile.RootTemplate.VisualTemplate,
			-- PhysicsTemplate = projectile.RootTemplate.PhysicsTemplate,
			-- CastShadow = projectile.RootTemplate.CastShadow,
			-- ReceiveDecal = projectile.RootTemplate.ReceiveDecal,
			-- AllowReceiveDecalWhenAnimated = projectile.RootTemplate.AllowReceiveDecalWhenAnimated,
			-- IsReflecting = projectile.RootTemplate.IsReflecting,
			-- IsShadowProxy = projectile.RootTemplate.IsShadowProxy,
			-- RenderChannel = projectile.RootTemplate.RenderChannel,
			-- CameraOffset = projectile.RootTemplate.CameraOffset,
			-- HasParentModRelation = projectile.RootTemplate.HasParentModRelation,
			-- HasGameplayValue = projectile.RootTemplate.HasGameplayValue,
			-- AIBoundsRadius = projectile.RootTemplate.AIBoundsRadius,
			-- AIBoundsHeight = projectile.RootTemplate.AIBoundsHeight,
			-- DisplayName = projectile.RootTemplate.DisplayName,
			-- Opacity = projectile.RootTemplate.Opacity,
			-- Fadeable = projectile.RootTemplate.Fadeable,
			-- FadeIn = projectile.RootTemplate.FadeIn,
			-- SeeThrough = projectile.RootTemplate.SeeThrough,
			-- FadeGroup = projectile.RootTemplate.FadeGroup,
			-- GameMasterSpawnSection = projectile.RootTemplate.GameMasterSpawnSection,
			-- GameMasterSpawnSubSection = projectile.RootTemplate.GameMasterSpawnSubSection,
		},
		Handle = projectile.Handle,
		NetID = projectile.NetID,
		MyGuid = projectile.MyGuid,
		CasterHandle = projectile.CasterHandle,
		SourceHandle = projectile.SourceHandle,
		TargetObjectHandle = projectile.TargetObjectHandle,
		HitObjectHandle = projectile.HitObjectHandle,
		SourcePosition = projectile.SourcePosition,
		TargetPosition = projectile.TargetPosition,
		DamageType = projectile.DamageType,
		DamageSourceType = projectile.DamageSourceType,
		LifeTime = projectile.LifeTime,
		HitInterpolation = projectile.HitInterpolation,
		ExplodeRadius0 = projectile.ExplodeRadius0,
		ExplodeRadius1 = projectile.ExplodeRadius1,
		DeathType = projectile.DeathType,
		SkillId = projectile.SkillId,
		WeaponHandle = projectile.WeaponHandle,
		MovingEffectHandle = projectile.MovingEffectHandle,
		SpawnEffect = projectile.SpawnEffect,
		SpawnFXOverridesImpactFX = projectile.SpawnFXOverridesImpactFX,
		EffectHandle = projectile.EffectHandle,
		RequestDelete = projectile.RequestDelete,
		Launched = projectile.Launched,
		IsTrap = projectile.IsTrap,
		UseCharacterStats = projectile.UseCharacterStats,
		ReduceDurability = projectile.ReduceDurability,
		AlwaysDamage = projectile.AlwaysDamage,
		ForceTarget = projectile.ForceTarget,
		IsFromItem = projectile.IsFromItem,
		DivideDamage = projectile.DivideDamage,
		IgnoreRoof = projectile.IgnoreRoof,
		CanDeflect = projectile.CanDeflect,
		IgnoreObjects = projectile.IgnoreObjects,
		CleanseStatuses = projectile.CleanseStatuses,
		StatusClearChance = projectile.StatusClearChance,
		Position = projectile.Position,
		PrevPosition = projectile.PrevPosition,
		Velocity = projectile.Velocity,
		Scale = projectile.Scale,
		CurrentLevel = projectile.CurrentLevel,
	}
end

local simpleTypes = {
	number = true,
	integer = true,
	string = true,
	boolean = true,
	["number[]"] = true,
	["string[]"] = true,
}

local function copyValuesFromRef(target, source, refTable, objId)
	if not refTable then
		return
	end
	for k,t in pairs(refTable) do
		if simpleTypes[t] then
			target[k] = source[k]
		elseif t == "function" then
			local meta = getmetatable(source)
			target[k] = function(self, ...)
				local obj = source
				if obj == nil then
					if meta == "esv::item" or meta == "ecl::item" then
						obj = GameHelpers.GetItem(objId)
					elseif meta == "CDivinityStats_Item" then
						obj = GameHelpers.GetItem(objId).Stats
					end
				end
				if obj ~= nil then
					local b,result = pcall(obj[k], obj, ...)
					if b then
						return result
					else
						Ext.Utils.PrintError(result)
					end
				end
			end
		else
			local metaName = getmetatable(source[k])
			local ref2 = DebugHelpers.userDataProps[metaName]
			if ref2 then
				target[k] = {}
				copyValuesFromRef(target[k], source[k], ref2,objId)
			end
		end
	end
end

---@param item ItemParam
function GameHelpers.Ext.CreateItemTable(item)
	local itemTable = {
		IsCopy = true
	}
	item = GameHelpers.GetItem(item)
	if item then
		if Ext.IsServer() then
			local refTable = DebugHelpers.userDataProps["esv::Item"]
			copyValuesFromRef(itemTable, item, refTable, item.MyGuid)
		else
			local refTable = DebugHelpers.userDataProps["ecl::Item"]
			copyValuesFromRef(itemTable, item, refTable, item.NetID)
		end
	end
	return itemTable
end

---@param obj ObjectParam
function GameHelpers.Ext.ObjectIsStatItem(obj)
	if _type(obj) == "userdata" then
		local meta = getmetatable(obj)
		return meta == Data.ExtenderClass.StatItem or meta == Data.ExtenderClass.StatItemArmor
	end
	return false
end

---@param obj ObjectParam
function GameHelpers.Ext.ObjectIsItem(obj)
	local t = _type(obj)
	if t == "userdata" then
		local meta = getmetatable(obj)
		return meta == Data.ExtenderClass.EsvItem or meta == Data.ExtenderClass.EclItem
	elseif t == "string" or t == "number" then
		if obj == StringHelpers.NULL_UUID then
			return false
		end
		local item = GameHelpers.GetItem(obj)
		if item then
			return true,item
		end
	end
	return false
end

---@param obj ObjectParam|nil
function GameHelpers.Ext.ObjectIsCharacter(obj)
	local t = _type(obj)
	if t == "userdata" then
		local meta = getmetatable(obj)
		return meta == Data.ExtenderClass.EsvCharacter or meta == Data.ExtenderClass.EclCharacter
	elseif t == "string" or t == "number" then
		if obj == StringHelpers.NULL_UUID then
			return false
		end
		local char = GameHelpers.GetCharacter(obj)
		if char then
			return true,char
		end
	end
	return false
end

---@param obj ObjectParam
function GameHelpers.Ext.ObjectIsStatCharacter(obj)
	if _type(obj) == "userdata" then
		return getmetatable(obj) == Data.ExtenderClass.StatCharacter
	end
	return false
end

---@param obj ItemParam
---@return string
function GameHelpers.Ext.GetItemStatName(obj)
	local t = _type(obj)
	if t == "string" or t == "number" then
		if obj == StringHelpers.NULL_UUID then
			return false
		end
		local item = GameHelpers.GetItem(obj)
		if item then
			return item.StatsId
		end
	elseif t == "userdata" then
		if GameHelpers.Ext.ObjectIsItem(obj) then
			return obj.StatsId
		elseif GameHelpers.Ext.ObjectIsStatItem(obj) then
			return obj.Name
		end
	end
	return nil
end

---@param obj userdata
---@param typeName string
---@param meta string|nil Optional metatable to pass in, to skip fetching it manually.
---@return boolean
function GameHelpers.Ext.UserDataIsType(obj, typeName, meta)
	return (meta or getmetatable(obj)) == typeName
end

---@param obj ObjectParam
function GameHelpers.Ext.ObjectIsAnyType(obj)
	return (GameHelpers.Ext.ObjectIsCharacter(obj)
	or GameHelpers.Ext.ObjectIsItem(obj)
	or GameHelpers.Ext.ObjectIsStatCharacter(obj)
	or GameHelpers.Ext.ObjectIsStatItem(obj))
end

local _objectTypes = {
	["esv::Character"] = true,
	["ecl::Character"] = true,
	["esv::Item"] = true,
	["ecl::Item"] = true,
}

---Returns true if the object is a character or item.
---@param obj ObjectParam
---@return boolean
function GameHelpers.Ext.IsObjectType(obj)
	return _objectTypes[Ext.Types.GetObjectType(obj)] == true
end

local _CachedTypeChecks = {}

local function _StoreTypeCheck(typeName, member, b)
	if _CachedTypeChecks[typeName] == nil then
		_CachedTypeChecks[typeName] = {}
	end
	_CachedTypeChecks[typeName][member] = b
end

local function _HasTypeCheck(typeName, member)
	if _CachedTypeChecks[typeName] ~= nil then
		return _CachedTypeChecks[typeName][member] == true
	end
	return false
end

---Returns true if the object is a character or item.
---@param object userdata
---@param memberName string
---@return boolean
function GameHelpers.Ext.TypeHasMember(object, memberName)
	local typeName = Ext.Types.GetObjectType(object)
	if _HasTypeCheck(typeName, memberName) then
		return true
	end
	local typeData = Ext.Types.GetTypeInfo(typeName)
	if typeData then
		if typeData.Members[memberName] ~= nil then
			_StoreTypeCheck(typeName, memberName, true)
			return true
		end
		local parent = typeData.ParentType
		while parent ~= nil do
			if parent.Members[memberName] then
				_StoreTypeCheck(typeName, memberName, true)
				return true
			end
			parent = parent.ParentType
		end
	end
	return false
end