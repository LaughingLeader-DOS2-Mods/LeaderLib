if Data == nil then 
	Data = {}
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

Data.AttributeEnum = {
	Strength = 0,
	Finesse = 1,
	Intelligence = 2,
	Constitution = 3,
	Memory = 4,
	Wit = 5
}

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
	CANCEL = "CANCEL", -- When preparing is stopped without casting
	LEARNED = "LEARNED",
	MEMORIZED = "MEMORIZED",
	UNMEMORIZED = "UNMEMORIZED",
}

Ext.Require("Shared/Data/ResistancePenetrationTags.lua")
Ext.Require("Shared/Data/LocalizedText.lua")

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
}

---Statuses ignored by default in status listeners
---If a mod registers a callback for one of these, it will no longer be ignored in listeners.
Data.IgnoredStatus = {}
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

Data.SurfaceChange = {
	[0] = "None",
	"Ignite",
	"Melt",
	"Freeze",
	"Electrify",
	"Bless",
	"Curse",
	"Condense",
	"Vaporize",
	"Bloodify",
	"Contaminate",
	"Oilify",
	"Shatter",
}

Data.SurfaceChangeEnum = {
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