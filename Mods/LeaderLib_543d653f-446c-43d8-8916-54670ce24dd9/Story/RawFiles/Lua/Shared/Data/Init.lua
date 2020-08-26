if Data == nil then 
	Data = {}
end

Data.OriginalSkillTiers = {}

local function _pairs(t, var)
	var = var + 1
	local value = t[var]
	if value == nil then return end
	return var, value
end
local function iterateFromZero(t) return _pairs, t, -1 end
local function iterateDefault(t) return _pairs, t, 0 end

local damageTypes = {
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
}
Data.DamageTypes = setmetatable({},{__index = damageTypes})
function Data.DamageTypes:Get()
	return iterateFromZero(self)
end

Data.DamageTypeEnums = {
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
}

Data.DamageTypeToResistance = {
	--None = "PureResistance", -- Special LeaderLib Addition
	Physical = "PhysicalResistance",
	Piercing = "PiercingResistance",
	--Corrosive = "CorrosiveResistance",
	--Magic = "MagicResistance",
	--Chaos = "ChaosResistance",-- Special LeaderLib Addition
	Air = "AirResistance",
	Earth = "EarthResistance",
	Fire = "FireResistance",
	Poison = "PoisonResistance",
	--Shadow = "ShadowResistance", -- Technically Tenebrium
	Water = "WaterResistance",
}

Data.DamageTypeToResistanceWithExtras = {
	None = "PureResistance", -- Special LeaderLib Addition
	Physical = "PhysicalResistance",
	Piercing = "PiercingResistance",
	Corrosive = "CorrosiveResistance",
	Magic = "MagicResistance",
	Chaos = "ChaosResistance",-- Special LeaderLib Addition
	Air = "AirResistance",
	Earth = "EarthResistance",
	Fire = "FireResistance",
	Poison = "PoisonResistance",
	Shadow = "ShadowResistance", -- Technically Tenebrium
	Water = "WaterResistance",
}

Data.DamageTypes = setmetatable({},{__index = damageTypes})
function Data.DamageTypes:Get()
	return iterateFromZero(self)
end

---@alias ItemSlot "Weapon"|"Shield"|"Helmet"|"Breast"|"Gloves"|"Leggings"|"Boots"|"Belt"|"Amulet"|"Ring"|"Ring2"|"Wings"|"Horns"|"Overhead"

local slots = {
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
}
Data.EquipmentSlots = setmetatable({},{__index = slots})
function Data.EquipmentSlots:Get()
	return iterateFromZero(self)
end

local visibleEquipmentSlots = {
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
}
Data.VisibleEquipmentSlots = setmetatable({},{__index = visibleEquipmentSlots})
function Data.VisibleEquipmentSlots:Get()
	return iterateFromZero(self)
end

--- Enums for every ability in the game.
---@type table<string,integer>
Data.AbilityEnum = {
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
}
local abilityValues = {}
for name,i in pairs(Data.AbilityEnum) do
	abilityValues[i] = name
end

---@type table<integer,string>
Data.Ability = setmetatable({},{__index = abilityValues})
function Data.Ability:Get()
	return iterateFromZero(self)
end

local attributes = {
	[0] = "Strength",
	"Finesse",
	"Intelligence",
	"Constitution",
	"Memory",
	"Wits"
}
Data.Attribute = setmetatable({},{__index = attributes})
function Data.Attribute:Get()
	return iterateFromZero(self)
end

local talents = {
	"ItemMovement",
	"ItemCreation",
	"Flanking",
	"AttackOfOpportunity",
	"Backstab",
	"Trade",
	"Lockpick",
	"ChanceToHitRanged",
	"ChanceToHitMelee",
	"Damage",
	"ActionPoints",
	"ActionPoints2",
	"Criticals",
	"IncreasedArmor",
	"Sight",
	"ResistFear",
	"ResistKnockdown",
	"ResistStun",
	"ResistPoison",
	"ResistSilence",
	"ResistDead",
	"Carry",
	"Throwing",
	"Repair",
	"ExpGain",
	"ExtraStatPoints",
	"ExtraSkillPoints",
	"Durability",
	"Awareness",
	"Vitality",
	"FireSpells",
	"WaterSpells",
	"AirSpells",
	"EarthSpells",
	"Charm",
	"Intimidate",
	"Reason",
	"Luck",
	"Initiative",
	"InventoryAccess",
	"AvoidDetection",
	"AnimalEmpathy",
	"Escapist",
	"StandYourGround",
	"SurpriseAttack",
	"LightStep",
	"ResurrectToFullHealth",
	"Scientist",
	"Raistlin",
	"MrKnowItAll",
	"WhatARush",
	"FaroutDude",
	"Leech",
	"ElementalAffinity",
	"FiveStarRestaurant",
	"Bully",
	"ElementalRanger",
	"LightningRod",
	"Politician",
	"WeatherProof",
	"LoneWolf",
	"Zombie",
	"Demon",
	"IceKing",
	"Courageous",
	"GoldenMage",
	"WalkItOff",
	"FolkDancer",
	"SpillNoBlood",
	"Stench",
	"Kickstarter",
	"WarriorLoreNaturalArmor",
	"WarriorLoreNaturalHealth",
	"WarriorLoreNaturalResistance",
	"RangerLoreArrowRecover",
	"RangerLoreEvasionBonus",
	"RangerLoreRangedAPBonus",
	"RogueLoreDaggerAPBonus",
	"RogueLoreDaggerBackStab",
	"RogueLoreMovementBonus",
	"RogueLoreHoldResistance",
	"NoAttackOfOpportunity",
	"WarriorLoreGrenadeRange",
	"RogueLoreGrenadePrecision",
	"WandCharge",
	"DualWieldingDodging",
	"Human_Inventive",
	"Human_Civil",
	"Elf_Lore",
	"Elf_CorpseEating",
	"Dwarf_Sturdy",
	"Dwarf_Sneaking",
	"Lizard_Resistance",
	"Lizard_Persuasion",
	"Perfectionist",
	"Executioner",
	"ViolentMagic",
	"QuickStep",
	"Quest_SpidersKiss_Str",
	"Quest_SpidersKiss_Int",
	"Quest_SpidersKiss_Per",
	"Quest_SpidersKiss_Null",
	"Memory",
	"Quest_TradeSecrets",
	"Quest_GhostTree",
	"BeastMaster",
	"LivingArmor",
	"Torturer",
	"Ambidextrous",
	"Unstable",
	"ResurrectExtraHealth",
	"NaturalConductor",
	"Quest_Rooted",
	"PainDrinker",
	"DeathfogResistant",
	"Sourcerer",
	"Rager",
	"Elementalist",
	"Sadist",
	"Haymaker",
	"Gladiator",
	"Indomitable",
	"WildMag",
	"Jitterbug",
	"Soulcatcher",
	"MasterThief",
	"GreedyVessel",
	"MagicCycles",
}
Data.Talents = setmetatable({},{__index = talents})
function Data.Talents:Get()
	return iterateDefault(self)
end

---@type table<string,integer>
Data.TalentEnum = {}
for i,talent in Data.Talents:Get() do
	Data.TalentEnum[talent] = i
end

Data.ItemRarities = {
	"Common",
	"Unique",
	"Uncommon",
	"Rare",
	"Epic",
	"Legendary",
	"Divine",
}

Data.RarityEnum = {
	Common = 0,
	Unique = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Divine = 6,
}

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

---@class SKILL_STATE
SKILL_STATE = {
	PREPARE = "PREPARE",
	USED = "USED",
	CAST = "CAST",
	HIT = "HIT",
}

Ext.Require("Shared/Data/ResistancePenetrationTags.lua")
Ext.Require("Shared/Data/BasePresets.lua")

---@param group string Start|Act2|Preview
---@param id string The preset's ClassType value.
---@param data PresetData
function Data.AddPreset(group, id, data)
	if Data.Presets[group] == nil then
		Data.Presets[group] = {}
	end
	Data.Presets[group][id] = data
end

Data.EngineStatus = {
	CLIMBING = true,
	COMBAT = true,
	DYING = true,
	ENCUMBERED = true,
	EXPLODE = true,
	FLANKED = true,
	HEALING = true,
	HIT = true,
	INSURFACE = true,
	LEADERSHIP = true,
	LYING = true,
	MATERIAL = true,
	POST_MAGIC_CONTROL = true,
	POST_PHYS_CONTROL = true,
	ROTATE = true,
	SHACKLES_OF_PAIN_CASTER = true,
	SITTING = true,
	SMELLY = true,
	SNEAKING = true,
	SOURCE_MUTED = true,
	SPIRIT = true,
	SPIRIT_VISION = true,
	SUMMONING = true,
	TELEPORT_FALLING = true,
	THROWN = true,
	TUTORIAL_BED = true,
	UNSHEATHED = true,
}