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
	PROJECTILEHIT = "PROJECTILEHIT",
}

Ext.Require("Shared/Data/ResistancePenetrationTags.lua")
Ext.Require("Shared/Data/LocalizedText.lua")

Data.EngineStatus = {
	ACTIVE_DEFENSE = true,
	ADRENALINE = true,
	AOO = true,
	BLIND = true,
	BOOST = true,
	CHALLENGE = true,
	CHANNELING = true,
	CHARMED = true,
	CLEAN = true,
	CLIMBING = true,
	COMBAT = true,
	COMBUSTION = true,
	CONSTRAINED = true,
	CONSUME = true,
	DAMAGE = true,
	DAMAGE_ON_MOVE = true,
	DARK_AVENGER = true,
	DEACTIVATED = true,
	DECAYING_TOUCH = true,
	DEMONIC_BARGAIN = true,
	DISARMED = true,
	DRAIN = true,
	DYING = true,
	EFFECT = true,
	ENCUMBERED = true,
	EXPLODE = true,
	EXTRA_TURN = true,
	FEAR = true,
	FLANKED = true,
	FLOATING = true,
	FORCE_MOVE = true,
	GUARDIAN_ANGEL = true,
	HEAL = true,
	HEAL_SHARING = true,
	HEAL_SHARING_CASTER = true,
	HEALING = true,
	HIT = true,
	IDENTIFY = true,
	INCAPACITATED = true,
	INFECTIOUS_DISEASED = true,
	INFUSED = true,
	INSURFACE = true,
	INVISIBLE = true,
	KNOCKED_DOWN = true,
	LEADERSHIP = true,
	LINGERING_WOUNDS = true,
	LYING = true,
	MATERIAL = true,
	MUTED = true,
	OVERPOWER = true,
	PLAY_DEAD = true,
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
}

---Statuses ignored by default in status listeners
---If a mod registers a callback for one of these, it will no longer be ignored in listeners.
Data.IgnoredStatus = {
	ACTIVE_DEFENSE = true,
	--ADRENALINE = true,
	AOO = true,
	--BLIND = true,
	BOOST = true,
	CHALLENGE = true,
	CHANNELING = true,
	--CHARMED = true,
	CLEAN = true,
	CLIMBING = true,
	COMBAT = true,
	COMBUSTION = true,
	CONSTRAINED = true,
	CONSUME = true,
	DAMAGE = true,
	DAMAGE_ON_MOVE = true,
	DARK_AVENGER = true,
	DEACTIVATED = true,
	--DECAYING_TOUCH = true,
	DEMONIC_BARGAIN = true,
	DISARMED = true,
	DRAIN = true,
	DYING = true,
	EFFECT = true,
	ENCUMBERED = true,
	EXPLODE = true,
	EXTRA_TURN = true,
	--FEAR = true,
	FLANKED = true,
	--FLOATING = true,
	FORCE_MOVE = true,
	--GUARDIAN_ANGEL = true,
	HEAL = true,
	HEAL_SHARING = true,
	HEAL_SHARING_CASTER = true,
	HEALING = true,
	HIT = true,
	IDENTIFY = true,
	INCAPACITATED = true,
	INFECTIOUS_DISEASED = true,
	INFUSED = true,
	INSURFACE = true,
	--INVISIBLE = true,
	--KNOCKED_DOWN = true,
	LEADERSHIP = true,
	LINGERING_WOUNDS = true,
	LYING = true,
	MATERIAL = true,
	--MUTED = true,
	OVERPOWER = true,
	PLAY_DEAD = true,
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
	POST_MAGIC_CONTROL = true,
	POST_PHYS_CONTROL = true,
}
for i,v in pairs(Data.EngineStatus) do
	Data.IgnoredStatus[v] = true
end

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

Data.UIType = {
	actionProgression = 0,
	bottomBar_c = 59,
	campaignManager = 124,
	characterCreation = 3,
	characterCreation_c = 4,
	characterSheet = 119,
	chatLog = 6,
	combatLog = 7,
	containerInventory = 37,
	contextMenu = 10, -- or 11
	connectionMenu = 33,
	craftPanel_c = 84,
	dummyOverhead = 15,
	enemyHealthBar = 42,
	equipmentPanel_c = 64,
	examine = 104,
	examine_c = 67,
	fullScreenHUD = 100,
	formation = 130,
	gameMenu = 19,
	giftBagsMenu = 146,
	giftBagContent = 147,
	GMMetadataBox = 109,
	hotBar = 40,
	journal = 22,
	loadingScreen = 23,
	mainMenu = 28,
	minimap = 30,
	mouseIcon = 31,
	msgBox = 29,
	msgBox_c = 75,
	notification = 36,
	overhead = 5,
	optionsInput = 13,
	optionsSettings = 45, -- Can also be 1 (Audio tab) or 17 (Gameplay tab)
	partyInventory = 116,
	partyInventory_c = 142,
	partyManagement_c = 82,
	playerInfo = 38,
	reward = 136,
	reward_c = 137,
	saveLoad = 39,
	skills = 41,
	statsPanel_c = 63,
	statusConsole = 117,
	textDisplay = 43,
	tooltip = 44,
	trade = 46,
	trade_c = 73,
	tutorialBox = 55,
	uiCraft = 102,
	uiFade = 16,
	waypoints = 47,
	worldTooltip = 48,
}

Data.ArmorType = {
	None = "None",
	Cloth = "Cloth",
	Leather = "Leather",
	Mail = "Male",
	Plate = "Plate",
	Robe = "Robe"
}