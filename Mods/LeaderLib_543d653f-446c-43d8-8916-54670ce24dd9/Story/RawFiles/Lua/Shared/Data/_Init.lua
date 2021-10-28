if Data == nil then 
	Data = {}
end

local function CreateEnum(target)
	local integers = {}
	local names = {}
	local startIndex = 1
	for k,v in pairs(target) do
		if type(k) == "string" then
			if v == 0 then startIndex = 0 end
			names[v] = k
		else
			if k == 0 then startIndex = 0 end
			integers[k] = v
		end
	end
	setmetatable(target, {
		__call = function(tbl, v)
			local t = type(v)
			if t == "number" or t == "string" then
				return target[v]
			end
		end,
		__newindex = function() end,
		__index = function() end,
		__pairs = function(tbl)
			local i = startIndex
			local function iter(tbl)
				local name = names[i]
				local v = target[name]
				if v ~= nil then
					i = i + 1
					return name,v
				end
			end
			return iter, tbl, names[i]
		end,
		__ipairs = function(tbl)
			local i = startIndex
			local function iter(tbl,i)
				local v = target[integers[i]]
				if v ~= nil then
					i = i + 1
					return integers[1],v
				end
			end
			return iter, tbl, integers[1]
		end
	})
end

Ext.Require("Shared/Data/Colors.lua")

Data.OriginalSkillTiers = {}
---@type table<string,bool>
Data.ObjectStats = {}
--Valid items with a Stats table can still have an empty StatsId for some reason.
--Data.ObjectStats = {[""] = true}

local function _pairs(t, var)
	var = var + 1
	local value = t[var]
	if value == nil then return end
	return var, value
end
local function iterateFromZero(t) return _pairs, t, -1 end
local function iterateDefault(t) return _pairs, t, 0 end

---@alias DAMAGE_TYPE string|'"None"'|'"Physical"'|'"Piercing"'|'"Corrosive"'|'"Magic"'|'"Chaos"'|'"Fire"'|'"Air"'|'"Water"'|'"Earth"'|'"Poison"'|'"Shadow"'

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

CreateEnum(Data.DamageTypeEnums)

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

---@alias ItemSlot '"Weapon"'|'"Shield"'|'"Helmet"'|'"Breast"'|'"Gloves"'|'"Leggings"'|'"Boots"'|'"Belt"'|'"Amulet"'|'"Ring"'|'"Ring2"'|'"Wings"'|'"Horns"'|'"Overhead"'|'"Sentintel"'

Data.EquipmentSlots = {
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
	[11]="Wings",
	[12]="Horns",
	[13]="Overhead",
	[14]="Sentinel"
}

function Data.EquipmentSlots:Get()
	return iterateFromZero(self)
end

Data.EquipmentSlotNames = {
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

CreateEnum(Data.EquipmentSlotNames)

local itemslot = {
	[0] = "Helmet",
	"Breast",
	"Leggings",
	"Weapon",
	"Shield",
	"Ring",
	"Belt",
	"Boots",
	"Gloves",
	"Amulet",
	"Ring2",
	"Wings",
	"Horns",
	"Overhead",
}

Data.DeltaModSlotType = setmetatable({},{__index = itemslot})
function Data.DeltaModSlotType:Get()
	return iterateFromZero(self)
end

local visibleEquipmentSlots = {
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
	--Sentinel = 40,
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

Data.AttributeEnum = {
	Strength = 0,
	Finesse = 1,
	Intelligence = 2,
	Constitution = 3,
	Memory = 4,
	Wits = 5
}

local talents = {
	[1] = "ItemMovement",
	[2] = "ItemCreation",
	[3] = "Flanking",
	[4] = "AttackOfOpportunity",
	[5] = "Backstab",
	[6] = "Trade",
	[7] = "Lockpick",
	[8] = "ChanceToHitRanged",
	[9] = "ChanceToHitMelee",
	[10] = "Damage",
	[11] = "ActionPoints",
	[12] = "ActionPoints2",
	[13] = "Criticals",
	[14] = "IncreasedArmor",
	[15] = "Sight",
	[16] = "ResistFear",
	[17] = "ResistKnockdown",
	[18] = "ResistStun",
	[19] = "ResistPoison",
	[20] = "ResistSilence",
	[21] = "ResistDead",
	[22] = "Carry",
	[23] = "Throwing",
	[24] = "Repair",
	[25] = "ExpGain",
	[26] = "ExtraStatPoints",
	[27] = "ExtraSkillPoints",
	[28] = "Durability",
	[29] = "Awareness",
	[30] = "Vitality",
	[31] = "FireSpells",
	[32] = "WaterSpells",
	[33] = "AirSpells",
	[34] = "EarthSpells",
	[35] = "Charm",
	[36] = "Intimidate",
	[37] = "Reason",
	[38] = "Luck",
	[39] = "Initiative",
	[40] = "InventoryAccess",
	[41] = "AvoidDetection",
	[42] = "AnimalEmpathy",
	[43] = "Escapist",
	[44] = "StandYourGround",
	[45] = "SurpriseAttack",
	[46] = "LightStep",
	[47] = "ResurrectToFullHealth",
	[48] = "Scientist",
	[49] = "Raistlin",
	[50] = "MrKnowItAll",
	[51] = "WhatARush",
	[52] = "FaroutDude",
	[53] = "Leech",
	[54] = "ElementalAffinity",
	[55] = "FiveStarRestaurant",
	[56] = "Bully",
	[57] = "ElementalRanger",
	[58] = "LightningRod",
	[59] = "Politician",
	[60] = "WeatherProof",
	[61] = "LoneWolf",
	[62] = "Zombie",
	[63] = "Demon",
	[64] = "IceKing",
	[65] = "Courageous",
	[66] = "GoldenMage",
	[67] = "WalkItOff",
	[68] = "FolkDancer",
	[69] = "SpillNoBlood",
	[70] = "Stench",
	[71] = "Kickstarter",
	[72] = "WarriorLoreNaturalArmor",
	[73] = "WarriorLoreNaturalHealth",
	[74] = "WarriorLoreNaturalResistance",
	[75] = "RangerLoreArrowRecover",
	[76] = "RangerLoreEvasionBonus",
	[77] = "RangerLoreRangedAPBonus",
	[78] = "RogueLoreDaggerAPBonus",
	[79] = "RogueLoreDaggerBackStab",
	[80] = "RogueLoreMovementBonus",
	[81] = "RogueLoreHoldResistance",
	[82] = "NoAttackOfOpportunity",
	[83] = "WarriorLoreGrenadeRange",
	[84] = "RogueLoreGrenadePrecision",
	[85] = "WandCharge",
	[86] = "DualWieldingDodging",
	[87] = "Human_Inventive",
	[88] = "Human_Civil",
	[89] = "Elf_Lore",
	[90] = "Elf_CorpseEating",
	[91] = "Dwarf_Sturdy",
	[92] = "Dwarf_Sneaking",
	[93] = "Lizard_Resistance",
	[94] = "Lizard_Persuasion",
	[95] = "Perfectionist",
	[96] = "Executioner",
	[97] = "ViolentMagic",
	[98] = "QuickStep",
	[99] = "Quest_SpidersKiss_Str",
	[100] = "Quest_SpidersKiss_Int",
	[101] = "Quest_SpidersKiss_Per",
	[102] = "Quest_SpidersKiss_Null",
	[103] = "Memory",
	[104] = "Quest_TradeSecrets",
	[105] = "Quest_GhostTree",
	[106] = "BeastMaster",
	[107] = "LivingArmor",
	[108] = "Torturer",
	[109] = "Ambidextrous",
	[110] = "Unstable",
	[111] = "ResurrectExtraHealth",
	[112] = "NaturalConductor",
	[113] = "Quest_Rooted",
	[114] = "PainDrinker",
	[115] = "DeathfogResistant",
	[116] = "Sourcerer",
	[117] = "Rager",
	[118] = "Elementalist",
	[119] = "Sadist",
	[120] = "Haymaker",
	[121] = "Gladiator",
	[122] = "Indomitable",
	[123] = "WildMag",
	[124] = "Jitterbug",
	[125] = "Soulcatcher",
	[126] = "MasterThief",
	[127] = "GreedyVessel",
	[128] = "MagicCycles",
}

Data.Talents = setmetatable({}, {
	__index = talents,
	__pairs = function() 
		return iterateDefault(talents) 
	end
})

function Data.Talents:Get()
	return iterateDefault(talents)
	--return iterateFromZero(talents)
end

Data.TalentEnum = {
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

Data.ItemRarity = {
	Common = 0,
	Unique = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Divine = 6,
	[0] = "Common",
	[1] = "Unique",
	[2] = "Uncommon",
	[3] = "Rare",
	[4] = "Epic",
	[5] = "Legendary",
	[6] = "Divine",
}

CreateEnum(Data.ItemRarity)

---@class SKILL_STATE
SKILL_STATE = {
	PREPARE = "PREPARE",
	USED = "USED",
	CAST = "CAST",
	HIT = "HIT",
	PROJECTILEHIT = "PROJECTILEHIT",
	CANCEL = "CANCEL", -- When preparing is stopped without casting
	LEARNED = "LEARNED",
	MEMORIZED = "MEMORIZED",
	UNMEMORIZED = "UNMEMORIZED",
}

Ext.Require("Shared/Data/ResistancePenetrationTags.lua")
Ext.Require("Shared/Data/LocalizedText.lua")
Ext.Require("Shared/Data/ValueTypes.lua")
Ext.Require("Shared/Data/ExtenderUserData.lua")

Data.EngineStatus = {
	ACTIVE_DEFENSE = true,
	ADRENALINE = true,
	AOO = true,
	BOOST = true,
	CHANNELING = true,
	CHARMED = true,
	CLEAN = true,
	CLIMBING = true,
	COMBAT = true,
	COMBUSTION = true,
	CONSTRAINED = true,
	CONSUME = true,
	DAMAGE = true,
	DARK_AVENGER = true,
	DECAYING_TOUCH = true,
	DRAIN = true,
	DYING = true,
	EFFECT = true,
	ENCUMBERED = true,
	EXPLODE = true,
	FLANKED = true,
	FLOATING = true,
	FORCE_MOVE = true,
	HIT = true,
	IDENTIFY = true,
	INCAPACITATED = true,
	INFECTIOUS_DISEASED = true,
	INFUSED = true,
	INSURFACE = true,
	LEADERSHIP = true,
	LINGERING_WOUNDS = true,
	LYING = true,
	MATERIAL = true,
	OVERPOWER = true,
	POLYMORPHED = true,
	REMORSE = true,
	REPAIR = true,
	ROTATE = true,
	SHACKLES_OF_PAIN = true,
	SHACKLES_OF_PAIN_CASTER = true,
	SITTING = true,
	SMELLY = true,
	SNEAKING = true,
	SOURCE_MUTED = true,
	SPARK = true,
	SPIRIT = true,
	SPIRIT_VISION = true,
	STANCE = true,
	STORY_FROZEN = true,
	SUMMONING = true,
	TELEPORT_FALLING = true,
	THROWN = true,
	TUTORIAL_BED = true,
	UNHEALABLE = true,
	UNLOCK = true,
	UNSHEATHED = true,
	WIND_WALKER = true,
	--Custom
	LEADERLIB_RECALC = true,
}

setmetatable(Data.EngineStatus, {
	__call = function(status)
		return Data.EngineStatus[status] == true
	end
})

---Statuses ignored by default in status listeners
---If a mod registers a callback for one of these, it will no longer be ignored in listeners.
Data.IgnoredStatus = {}
for k,b in pairs(Data.EngineStatus) do
	Data.IgnoredStatus[k] = true
end
Data.IgnoredStatus.CONSUME = false

Data.Surfaces = {
	["SurfaceNone"] = -1,
	["SurfaceFire"] = 0,
	["SurfaceFireBlessed"] = 1,
	["SurfaceFireCursed"] = 2,
	["SurfaceFirePurified"] = 3,
	["SurfaceWater"] = 4,
	["SurfaceWaterElectrified"] = 5,
	["SurfaceWaterFrozen"] = 6,
	["SurfaceWaterBlessed"] = 7,
	["SurfaceWaterElectrifiedBlessed"] = 8,
	["SurfaceWaterFrozenBlessed"] = 9,
	["SurfaceWaterCursed"] = 10,
	["SurfaceWaterElectrifiedCursed"] = 11,
	["SurfaceWaterFrozenCursed"] = 12,
	["SurfaceWaterPurified"] = 13,
	["SurfaceWaterElectrifiedPurified"] = 14,
	["SurfaceWaterFrozenPurified"] = 15,
	["SurfaceBlood"] = 16,
	["SurfaceBloodElectrified"] = 17,
	["SurfaceBloodFrozen"] = 18,
	["SurfaceBloodBlessed"] = 19,
	["SurfaceBloodElectrifiedBlessed"] = 20,
	["SurfaceBloodFrozenBlessed"] = 21,
	["SurfaceBloodCursed"] = 22,
	["SurfaceBloodElectrifiedCursed"] = 23,
	["SurfaceBloodFrozenCursed"] = 24,
	["SurfaceBloodPurified"] = 25,
	["SurfaceBloodElectrifiedPurified"] = 26,
	["SurfaceBloodFrozenPurified"] = 27,
	["SurfacePoison"] = 28,
	["SurfacePoisonBlessed"] = 29,
	["SurfacePoisonCursed"] = 30,
	["SurfacePoisonPurified"] = 31,
	["SurfaceOil"] = 32,
	["SurfaceOilBlessed"] = 33,
	["SurfaceOilCursed"] = 34,
	["SurfaceOilPurified"] = 35,
	["SurfaceLava"] = 36,
	["SurfaceSource"] = 37,
	["SurfaceWeb"] = 38,
	["SurfaceWebBlessed"] = 39,
	["SurfaceWebCursed"] = 40,
	["SurfaceWebPurified"] = 41,
	["SurfaceDeepwater"] = 42,
	["SurfaceFireCloud"] = 47,
	["SurfaceFireCloudBlessed"] = 48,
	["SurfaceFireCloudCursed"] = 49,
	["SurfaceFireCloudPurified"] = 50,
	["SurfaceWaterCloud"] = 51,
	["SurfaceWaterCloudElectrified"] = 52,
	["SurfaceWaterCloudBlessed"] = 53,
	["SurfaceWaterCloudElectrifiedBlessed"] = 54,
	["SurfaceWaterCloudCursed"] = 55,
	["SurfaceWaterCloudElectrifiedCursed"] = 56,
	["SurfaceWaterCloudPurified"] = 57,
	["SurfaceWaterCloudElectrifiedPurified"] = 58,
	["SurfaceBloodCloud"] = 59,
	["SurfaceBloodCloudElectrified"] = 60,
	["SurfaceBloodCloudBlessed"] = 61,
	["SurfaceBloodCloudElectrifiedBlessed"] = 62,
	["SurfaceBloodCloudCursed"] = 63,
	["SurfaceBloodCloudElectrifiedCursed"] = 64,
	["SurfaceBloodCloudPurified"] = 65,
	["SurfaceBloodCloudElectrifiedPurified"] = 66,
	["SurfacePoisonCloud"] = 67,
	["SurfacePoisonCloudBlessed"] = 68,
	["SurfacePoisonCloudCursed"] = 69,
	["SurfacePoisonCloudPurified"] = 70,
	["SurfaceSmokeCloud"] = 71,
	["SurfaceSmokeCloudBlessed"] = 72,
	["SurfaceSmokeCloudCursed"] = 73,
	["SurfaceSmokeCloudPurified"] = 74,
	["SurfaceExplosionCloud"] = 75,
	["SurfaceFrostCloud"] = 76,
	["SurfaceDeathfogCloud"] = 77,
}

for k,v in pairs(Data.Surfaces) do
	Data.Surfaces[v] = k
end

CreateEnum(Data.Surfaces)

Data.SurfaceChange = {
	[0] = "None",
	[1] = "Ignite",
	[2] = "Melt",
	[3] = "Freeze",
	[4] = "Electrify",
	[5] = "Bless",
	[6] = "Curse",
	[7] = "Condense",
	[8] = "Vaporize",
	[9] = "Bloodify",
	[10] = "Contaminate",
	[11] = "Oilify",
	[12] = "Shatter",
	None = 0,
	Ignite = 1,
	Melt = 2,
	Freeze = 3,
	Electrify = 4,
	Bless = 5,
	Curse = 6,
	Condense = 7,
	Vaporize = 8,
	Bloodify = 9,
	Contaminate = 10,
	Oilify = 11,
	Shatter = 12,
}

CreateEnum(Data.SurfaceChange)

Data.UIType = {
	actionProgression = 0,
	areaInteract_c = 68,
	bottomBar_c = 59,
	buttonLayout_c = 95,
	campaignManager = 124,
	characterCreation = 3,
	characterCreation_c = 4,
	characterSheet = 119,
	chatLog = 6,
	combatLog = 7,
	connectionMenu = 33,
	containerInventory = 37,
	containerInventoryGM = 143,
	contextMenu = 11,
	contextMenu_c = {12, 96},
	craftPanel_c = 84,
	dialog = 14,
	dummyOverhead = 15,
	encounterPanel = 105,
	enemyHealthBar = 42,
	equipmentPanel_c = 64,
	examine = 104,
	examine_c = 67,
	formation = 130,
	fullScreenHUD = 100,
	gameMenu = 19,
	gameMenu_c = 77,
	giftBagContent = 147,
	giftBagsMenu = 146,
	gmInventory = 126,
	GMItemSheet = 107,
	GMMetadataBox = 109,
	GMMinimap = 113,
	GMMoodPanel = 108,
	GMPanelHUD = 120,
	GMRewardPanel = 131,
	GMSkills = 123,
	hotBar = 40,
	inventorySkillPanel_c = 62,
	itemAction = 86,
	itemGenerator = 106,
	journal = 22,
	journal_csp = 140,
	loadingScreen = 23,
	mainMenu = 28,
	mainMenu_c = 87, -- Still mainMenu, but this is used for controllers after clicking "Options" in the gameMenu_c
	minimap = 30,
	minimap_c = 60,
	monstersSelection = 127,
	mouseIcon = 31,
	msgBox = 29,
	msgBox_c = 75,
	notification = 36,
	optionsInput = 13,
	overhead = 5,
	overviewMap = 112,
	partyInventory = 116,
	partyInventory_c = 142,
	partyManagement_c = 82,
	pause = 121,
	peace = 122,
	playerInfo = 38,
	playerInfo_c = 61, --Still playerInfo.swf, but the ID is different.
	possessionBar = 110,
	pyramid = 129,
	reputationPanel = 138,
	reward = 136,
	reward_c = 137,
	roll = 118,
	saveLoad = 39,
	skills = 41,
	statsPanel_c = 63,
	statusConsole = 117,
	statusPanel = 128,
	stickiesPanel = 133,
	sticky = 132,
	surfacePainter = 111,
	textDisplay = 43,
	tooltip = 44,
	trade = 46,
	trade_c = 73,
	tutorialBox = 55,
	tutorialBox_c = 94,
	uiCraft = 102,
	uiFade = 16,
	vignette = 114,
	waypoints = 47,
	worldTooltip = 48,
	contextMenu = { Default = 10, Alt = 11},
	optionsSettings = {
		Default = 45,
		Video = 45,
		Audio = 1,
		Game = 17
	},
	optionsSettings_c = {
		Default = 91,
		Video = 91,
		Audio = 88,
		Game = 89
	},
}

---@type table<integer, string>
Data.UITypeToName = {}

for k,v in pairs(Data.UIType) do
	if type(v) == "table" then
		for _,v2 in pairs(v) do
			Data.UITypeToName[v2] = k
		end
	else
		Data.UITypeToName[v] = k
	end
end

Data.ArmorType = {
	None = "None",
	Cloth = "Cloth",
	Leather = "Leather",
	Mail = "Male",
	Plate = "Plate",
	Robe = "Robe"
}

Data.ActionSkills = {
	ActionSkillSheathe = true,
	ActionSkillSneak = true,
	ActionAttackGround = true,
	ActionSkillFlee = true,
	ActionSkillGuard = true,
}

if Ext.IsServer() then
Data.OsirisEvents = {
	AttackedByObject = 5,
	AutomatedDialogEnded = 2,
	AutomatedDialogRequestFailed = 2,
	AutomatedDialogStarted = 2,
	CameraReachedNode = 5,
	CanCombineItem = 7,
	CanLockpickItem = 3,
	CanMoveItem = 3,
	CanPickupItem = 3,
	CanUseItem = 3,
	CharacterAddedToGroup = 1,
	CharacterAttitudeTowardsPlayerChanged = 3,
	CharacterBaseAbilityChanged = 4,
	CharacterBlockedBy = 3,
	CharacterChangedAlginmentToCharacter = 3,
	CharacterCharacterEvent = 3,
	CharacterCreatedInArena = 2,
	CharacterCreationFinished = 1,
	CharacterCreationStarted = 1,
	CharacterCriticalHitBy = 3,
	CharacterDestroyedItem = 2,
	CharacterDestroyedItemTemplate = 2,
	CharacterDetachedFromGroup = 1,
	CharacterDied = 1,
	CharacterDisplayTextEnded = 2,
	CharacterDying = 1,
	CharacterEnteredRegion = 2,
	CharacterEnteredTrigger = 2,
	CharacterGhostDestroyed = 2,
	CharacterGhostRevealed = 2,
	CharacterGuarded = 1,
	CharacterItemEvent = 3,
	CharacterJoinedParty = 1,
	CharacterKilledBy = 3,
	CharacterLearnedSkill = 2,
	CharacterLeftParty = 1,
	CharacterLeftRegion = 2,
	CharacterLeftTrigger = 2,
	CharacterLeveledUp = 1,
	CharacterLoadedInPreset = 1,
	CharacterLockedTalent = 2,
	CharacterLootedCharacterCorpse = 2,
	CharacterLostSightOfCharacter = 2,
	CharacterMadePlayer = 1,
	CharacterMissedBy = 3,
	CharacterMoveToAndTalkFailed = 3,
	CharacterMoveToAndTalkRequestDialog = 5,
	CharacterMoveToAndTalkRequestDialogFailedEvent = 3,
	CharacterMovedItem = 2,
	CharacterMovedItemTemplate = 2,
	CharacterOnCrimeSensibleActionNotification = 10,
	CharacterPhysicalHitBy = 3,
	CharacterPickpocketEnter = 2,
	CharacterPickpocketExit = 1,
	CharacterPickpocketFailed = 2,
	CharacterPickpocketSuccess = 4,
	CharacterPolymorphedInto = 2,
	CharacterPreMovedItem = 2,
	CharacterPrecogDying = 1,
	CharacterReceivedDamage = 3,
	CharacterRelationChangedTo = 3,
	CharacterRequestsHomestead = 1,
	CharacterReservedUserIDChanged = 3,
	CharacterResurrected = 1,
	CharacterSawCharacter = 2,
	CharacterSawSneakingCharacter = 2,
	CharacterScriptFrameFinished = 2,
	CharacterSelectedAsBestUnavailableFallbackLead = 8,
	CharacterSelectedInCharCreation = 2,
	CharacterSetTemporaryRelationsFailed = 2,
	CharacterStartAttackObject = 3,
	CharacterStartAttackPosition = 5,
	CharacterStartLockpickingItem = 2,
	CharacterStartOriginIntroduction = 3,
	CharacterStatusApplied = 3,
	CharacterStatusAttempt = 3,
	CharacterStatusRemoved = 3,
	CharacterStoleItem = 8,
	CharacterStopOriginIntroduction = 2,
	CharacterStoppedCombiningItems = 6,
	CharacterStoppedLockpickingItem = 2,
	CharacterStoppedPolymorph = 1,
	CharacterStoppedUsingItem = 2,
	CharacterTeleportByItem = 3,
	CharacterTeleportToFleeWaypoint = 2,
	CharacterTeleportToPyramid = 2,
	CharacterTeleportToWaypoint = 2,
	CharacterTeleported = 9,
	CharacterTemplateDied = 1,
	CharacterTemplateKilledByCharacter = 2,
	CharacterTraitChanged = 2,
	CharacterTurnedToGhost = 2,
	CharacterUnlockedRecipe = 2,
	CharacterUnlockedTalent = 2,
	CharacterUsedItem = 2,
	CharacterUsedItemFailed = 2,
	CharacterUsedItemTemplate = 3,
	CharacterUsedLadder = 1,
	CharacterUsedSkill = 4,
	CharacterUsedSkillAtPosition = 7,
	CharacterUsedSkillInTrigger = 5,
	CharacterUsedSkillOnTarget = 5,
	CharacterUsedSkillOnZoneWithTarget = 5,
	CharacterUsedSourcePoint = 1,
	CharacterVitalityChanged = 2,
	CharacterWentOnStage = 2,
	ChildDialogRequested = 3,
	ClearFadeDone = 2,
	CombatEnded = 1,
	CombatRoundStarted = 2,
	CombatStarted = 1,
	CreditsEnded = 0,
	CrimeDisabled = 2,
	CrimeEnabled = 2,
	CrimeInterrogationRequest = 8,
	CrimeIsRegistered = 8,
	CustomBookUIClosed = 2,
	DLCUpdated = 3,
	DialogActorJoined = 3,
	DialogActorLeft = 3,
	DialogEnded = 2,
	DialogRequestFailed = 2,
	DialogStartRequested = 2,
	DialogStarted = 2,
	DifficultyChanged = 1,
	DualDialogRequested = 3,
	DualDialogStart = 2,
	EndGameRequestMovie = 2,
	FadeDone = 2,
	FadeInDone = 2,
	FadeOutDone = 2,
	FleeCombat = 1,
	GMCampaignModeStarted = 1,
	GameBookInterfaceClosed = 2,
	GameEventCleared = 1,
	GameEventSet = 1,
	GameModeStarted = 2,
	GameStarted = 2,
	GlobalFlagCleared = 1,
	GlobalFlagSet = 1,
	HappyWithDeal = 4,
	ItemAddedToCharacter = 2,
	ItemAddedToContainer = 2,
	ItemClosed = 1,
	ItemCreatedAtTrigger = 3,
	ItemDestroyed = 1,
	ItemDestroying = 1,
	ItemDisplayTextEnded = 2,
	ItemDropped = 1,
	ItemEnteredRegion = 2,
	ItemEnteredTrigger = 3,
	ItemEquipped = 2,
	ItemGhostRevealed = 1,
	ItemLeftRegion = 2,
	ItemLeftTrigger = 3,
	ItemMoved = 1,
	ItemMovedFromTo = 4,
	ItemOpened = 1,
	ItemReceivedDamage = 1,
	ItemRemovedFromCharacter = 2,
	ItemRemovedFromContainer = 2,
	ItemSendToHomesteadEvent = 2,
	ItemSetEquipped = 2,
	ItemSetUnEquipped = 2,
	ItemStackedWith = 2,
	ItemStatusAttempt = 3,
	ItemStatusChange = 3,
	ItemStatusRemoved = 3,
	ItemTemplateAddedToCharacter = 3,
	ItemTemplateAddedToContainer = 3,
	ItemTemplateCombinedWithItemTemplate = 7,
	ItemTemplateDestroyed = 2,
	ItemTemplateEnteredTrigger = 5,
	ItemTemplateEquipped = 2,
	ItemTemplateLeftTrigger = 5,
	ItemTemplateMoved = 2,
	ItemTemplateOpening = 3,
	ItemTemplateRemovedFromCharacter = 3,
	ItemTemplateRemovedFromContainer = 3,
	ItemTemplateUnEquipped = 2,
	ItemUnEquipFailed = 2,
	ItemUnEquipped = 2,
	ItemUnlocked = 3,
	ItemWentOnStage = 2,
	ItemsScatteredAt = 3,
	MessageBoxChoiceClosed = 3,
	MessageBoxClosed = 2,
	MessageBoxYesNoClosed = 3,
	MovieFinished = 1,
	MoviePlaylistFinished = 1,
	MysteryUnlocked = 2,
	NRD_ItemDeltaModIteratorEvent = 4,
	NRD_Loop = 3,
	NRD_OnActionStateEnter = 2,
	NRD_OnHeal = 4,
	NRD_OnHit = 4,
	NRD_OnPrepareHit = 4,
	NRD_OnStatusAttempt = 4,
	NRD_SkillIteratorEvent = 5,
	NRD_StatusIteratorEvent = 4,
	ObjectEnteredCombat = 2,
	ObjectFlagCleared = 3,
	ObjectFlagSet = 3,
	ObjectFlagShared = 3,
	ObjectLeftCombat = 2,
	ObjectLostTag = 2,
	ObjectReadyInCombat = 2,
	ObjectSourcePointAddRequest = 3,
	ObjectSwitchedCombat = 3,
	ObjectTransformed = 2,
	ObjectTurnEnded = 1,
	ObjectTurnStarted = 1,
	ObjectWasTagged = 2,
	OnArenaRoundForceEnded = 0,
	OnArenaRoundStarted = 1,
	OnCrimeConfrontationDone = 7,
	OnCrimeMergedWith = 2,
	OnCrimeRemoved = 6,
	OnCrimeResolved = 6,
	OnCrimeSawCriminalInCombat = 3,
	OnCriminalMergedWithCrime = 2,
	OnMutatorEnabledAtTurn = 2,
	OnStageChanged = 2,
	PartyPresetLoaded = 1,
	PersuasionResult = 3,
	PuzzleUIClosed = 3,
	PuzzleUIUsed = 5,
	QuestCategoryChanged = 2,
	QuestShared = 3,
	ReadyCheckFailed = 1,
	ReadyCheckPassed = 1,
	RegionEnded = 1,
	RegionStarted = 1,
	RequestPickpocket = 2,
	RequestTrade = 2,
	RuneInserted = 4,
	RuneRemoved = 4,
	SavegameLoaded = 4,
	SavegameLoading = 4,
	SkillActivated = 2,
	SkillAdded = 3,
	SkillCast = 4,
	SkillDeactivated = 2,
	StoryEvent = 2,
	TeleportRequestMovie = 2,
	TextEventSet = 1,
	TimerFinished = 1,
	TradeEnds = 2,
	TradeGenerationEnded = 1,
	TradeGenerationStarted = 1,
	TutorialBoxClosed = 2,
	UserConnected = 3,
	UserDisconnected = 3,
	UserEvent = 2,
	UserMakeWar = 3,
	VoiceBarkEnded = 2,
	VoiceBarkFailed = 1,
	VoiceBarkStarted = 2,
}
end

Data.LevelExperience = {
	[1] = 0,
	[2] = 2000,
	[3] = 8000,
	[4] = 20000,
	[5] = 40000,
	[6] = 70000,
	[7] = 112000,
	[8] = 168000,
	[9] = 240000,
	[10] = 340000,
	[11] = 479000,
	[12] = 672000,
	[13] = 941000,
	[14] = 1315000,
	[15] = 1834000,
	[16] = 2556000,
	[17] = 3559000,
	[18] = 4954000,
	[19] = 6893000,
	[20] = 9588000,
	[21] = 13334000,
	[22] = 18540000,
	[23] = 25777000,
	[24] = 35836000,
	[25] = 49818000,
	[26] = 69253000,
	[27] = 96268000,
	[28] = 133818000,
	[29] = 186013000,
	[30] = 258564000,
	[31] = 359410000,
	[32] = 499586000,
	[33] = 694430000,
	[34] = 965264000,
	[35] = 1341723000
}

Data.HitReason = {
    Melee = 0,
    Magic = 1,
    Ranged = 2,
    WeaponDamage = 3,
    Surface = 4,
    DoT = 5,
    Reflected = 6,
    [0] = "Melee",
    [1] = "Magic",
    [2] = "Ranged",
    [3] = "WeaponDamage",
    [4] = "Surface",
    [5] = "DoT",
    [6] = "Reflected",
}

CreateEnum(Data.HitReason)

Data.Difficulty = {
	[0] = "Story",
	[1] = "Explorer",
	[2] = "Classic",
	[3] = "Tactician",
	[4] = "Honour",
	Story = 0,
	Explorer = 1,
	Classic = 2,
	Tactician = 3,
	Honour = 4,
}

CreateEnum(Data.Difficulty)