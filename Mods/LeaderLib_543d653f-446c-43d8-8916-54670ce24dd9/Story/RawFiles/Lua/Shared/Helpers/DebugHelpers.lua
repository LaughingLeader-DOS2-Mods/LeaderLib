if DebugHelpers == nil then
	DebugHelpers = {}
end

local _EXTVERSION = Ext.Utils.Version()
local _ISCLIENT = Ext.IsClient()
local _type = type

local userDataProps = {}

local EsvItemProps = {
	Activated = "boolean",
	Amount = "integer",
	Armor = "integer",
	CanBeMoved = "boolean",
	CanBePickedUp = "boolean",
	CanConsume = "boolean",
	CanShootThrough = "boolean",
	CanUse = "boolean",
	CurrentLevel = "string",
	CustomBookContent = "string",
	CustomDescription = "string",
	CustomDisplayName = "string",
	Destroy = "boolean",
	Destroyed = "boolean",
	DisplayName = "string",
	DoorFlag = "boolean",
	Floating = "boolean",
	ForceSync = "boolean",
	ForceSynch = "boolean",
	FreezeGravity = "boolean",
	Frozen = "boolean",
	Global = "boolean",
	GMFolding = "boolean",
	GoldValueOverwrite = "integer",
	Handle = "ObjectHandle",
	InteractionDisabled = "boolean",
	InUseByCharacterHandle = "ObjectHandle",
	InventoryHandle = "ObjectHandle",
	IsDoor = "boolean",
	IsKey = "boolean",
	IsLadder = "boolean",
	IsSurfaceBlocker = "boolean",
	IsSurfaceCloudBlocker = "boolean",
	ItemType = "string",
	Key = "string",
	LevelOverride = "integer",
	LoadedTemplate = "boolean",
	LockLevel = "integer",
	NoCover = "boolean",
	MyGuid = "string",
	OffStage = "boolean",
	OwnerHandle = "ObjectHandle",
	ParentInventoryHandle = "ObjectHandle",
	PinnedContainer = "boolean",
	PositionChanged = "boolean",
	RootTemplate = "ItemTemplate",
	Scale = "number",
	Slot = "integer",
	SourceContainer = "boolean",
	Stats = "StatItem",
	StatsId = "string",
	Sticky = "boolean",
	StoryItem = "boolean",
	Summon = "boolean",
	TeleportOnUse = "boolean",
	Totem = "boolean",
	TreasureGenerated = "boolean",
	TreasureLevel = "integer",
	UnEquipLocked = "boolean",
	UnsoldGenerated = "boolean",
	UseRemotely = "boolean",
	Vitality = "integer",
	WalkOn = "boolean",
	WalkThrough = "boolean",
	WeightValueOverwrite = "integer",
	WorldPos = "table",
}

local EclItemProps = {
	BaseWeightOverwrite = "integer",
	CurrentLevel = "string",
	DisplayName = "string",
	GoldValueOverride = "integer",
	Handle = "ObjectHandle",
	ItemColorOverride = "integer",
	ItemType = "string",
	KeyName = "string",
	Level = "integer",
	MyGuid = "string",
	NetID = "integer",
	RootTemplate = "ItemTemplate",
	Scale = "number",
	Stats = "StatItem",
	StatsId = "string",
	Weight = "integer",
	WorldPos = "table",
}

local CDivinityStats_Item = {
	--ArmorBoost = "integer",
	--AttackAPCost = "integer",
	--Blocking = "integer",
	--Boosts = "string",
	--CleaveAngle = "integer",
	--CleavePercentage = "integer",
	--CriticalDamage = "integer",
	--Damage = "integer",
	--DamageBoost = "integer",
	--DamageFromBase = "integer",
	--DamageTypeOverwrite = "string",
	--Handedness = "string",
	--IgnoreVisionBlock = "string",
	--LifeSteal = "integer",
	--MagicArmorBoost = "integer",
	--Projectile = "string",
	AccuracyBoost = "integer",
	Act = "string",
	Air = "integer",
	AirSpecialist = "integer",
	AnimType = "integer",
	APMaximum = "integer",
	APRecovery = "integer",
	APStart = "integer",
	Barter = "integer",
	ChanceToHitBoost = "integer",
	Charges = "integer",
	ComboCategory = "string",
	ConstitutionBoost = "string",
	CriticalChance = "integer",
	DodgeBoost = "integer",
	DualWielding = "integer",
	Durability = "integer",
	DurabilityCounter = "integer",
	DurabilityDegradeSpeed = "string",
	DynamicStats = "StatItemDynamic",
	Earth = "integer",
	EarthSpecialist = "integer",
	ExtraProperties = "StatProperty",
	FinesseBoost = "string",
	Fire = "integer",
	FireSpecialist = "integer",
	Flags = "string",
	HasModifiedSkills = "boolean",
	HearingBoost = "string",
	Initiative = "integer",
	InstanceId = "integer",
	IntelligenceBoost = "string",
	InventoryTab = "string",
	IsIdentified = "integer",
	IsTwoHanded = "boolean",
	ItemColor = "string",
	ItemGroup = "string",
	ItemSlot = "string",
	ItemType = "string",
	ItemTypeReal = "string",
	Leadership = "integer",
	Level = "integer",
	Loremaster = "integer",
	Luck = "integer",
	MagicPointsBoost = "string",
	MaxAmount = "integer",
	MaxCharges = "integer",
	MaxLevel = "integer",
	MaxSummons = "integer",
	MemoryBoost = "string",
	MinAmount = "integer",
	MinLevel = "integer",
	ModifierType = "string",
	Movement = "integer",
	Name = "string",
	Necromancy = "integer",
	NeedsIdentification = "string",
	ObjectCategory = "string",
	PainReflection = "integer",
	Perseverance = "integer",
	Persuasion = "integer",
	Physical = "integer",
	Piercing = "integer",
	Poison = "integer",
	Polymorph = "integer",
	Priority = "integer",
	Ranged = "integer",
	RangerLore = "integer",
	Reflection = "string",
	Repair = "integer",
	Requirements = "StatRequirement",
	RogueLore = "integer",
	RuneSlots = "integer",
	RuneSlots_V1 = "integer",
	ShouldSyncStats = "boolean",
	SightBoost = "string",
	SingleHanded = "integer",
	Skills = "string",
	Slot = "string",
	Sneaking = "integer",
	Sourcery = "integer",
	StrengthBoost = "string",
	Summoning = "integer",
	Tags = "string",
	Talents = "string",
	Telekinesis = "integer",
	Thievery = "integer",
	TwoHanded = "integer",
	Unique = "integer",
	Using = "string",
	Value = "integer",
	VitalityBoost = "integer",
	WarriorLore = "integer",
	Water = "integer",
	WaterSpecialist = "integer",
	WeaponRange = "integer",
	WeaponType = "string",
	Weight = "integer",
	WitsBoost = "string",
}

local CDivinityStats_Equipment_Attributes = {
	AccuracyBoost = "integer",
	AirResistance = "integer",
	APRecovery = "integer",
	ArmorBoost = "integer",
	ArmorValue = "integer",
	AttackAPCost = "integer",
	Blocking = "integer",
	Bodybuilding = "integer",
	BoostName = "string",
	ChanceToHitBoost = "integer",
	CleaveAngle = "integer",
	CleavePercentage = "integer",
	ConstitutionBoost = "integer",
	CorrosiveResistance = "integer",
	CriticalChance = "integer",
	CriticalDamage = "integer",
	--CustomResistance = "integer",
	DamageBoost = "integer",
	--DamageFromBase = "integer",
	--DamageType = "integer",
	DodgeBoost = "integer",
	Durability = "integer",
	DurabilityDegradeSpeed = "integer",
	EarthResistance = "integer",
	FinesseBoost = "integer",
	FireResistance = "integer",
	HearingBoost = "integer",
	Initiative = "integer",
	IntelligenceBoost = "integer",
	ItemColor = "string",
	LifeSteal = "integer",
	MagicArmorBoost = "integer",
	MagicArmorValue = "integer",
	MagicResistance = "integer",
	MaxAP = "integer",
	-- MinDamage = "integer",
	-- MaxDamage = "integer",
	MaxSummons = "integer",
	MemoryBoost = "integer",
	ModifierType = "integer",
	Movement = "integer",
	MovementSpeedBoost = "integer",
	ObjectInstanceName = "string",
	PhysicalResistance = "integer",
	PiercingResistance = "integer",
	PoisonResistance = "integer",
	RuneSlots = "integer",
	RuneSlots_V1 = "integer",
	ShadowResistance = "integer",
	SightBoost = "integer",
	Skills = "string",
	SourcePointsBoost = "integer",
	StartAP = "integer",
	StatsType = "string",
	StrengthBoost = "integer",
	Value = "integer",
	VitalityBoost = "integer",
	WaterResistance = "integer",
	WeaponRange = "integer",
	Weight = "integer",
	Willpower = "integer",
	WitsBoost = "integer",
}

local CDivinityStats_Weapon_Attributes = {
	AccuracyBoost = "integer",
	APRecovery = "integer",
	AttackAPCost = "integer",
	Bodybuilding = "integer",
	BoostName = "string",
	ChanceToHitBoost = "integer",
	CleaveAngle = "integer",
	CleavePercentage = "integer",
	ConstitutionBoost = "integer",
	CriticalChance = "integer",
	CriticalDamage = "integer",
	DamageBoost = "integer",
	DamageFromBase = "integer",
	DamageType = "integer",
	DodgeBoost = "integer",
	Durability = "integer",
	DurabilityDegradeSpeed = "integer",
	FinesseBoost = "integer",
	HearingBoost = "integer",
	Initiative = "integer",
	IntelligenceBoost = "integer",
	ItemColor = "string",
	LifeSteal = "integer",
	MaxAP = "integer",
	MaxDamage = "integer",
	MaxSummons = "integer",
	MemoryBoost = "integer",
	MinDamage = "integer",
	ModifierType = "integer",
	Movement = "integer",
	MovementSpeedBoost = "integer",
	ObjectInstanceName = "string",
	RuneSlots = "integer",
	RuneSlots_V1 = "integer",
	SightBoost = "integer",
	Skills = "string",
	SourcePointsBoost = "integer",
	StartAP = "integer",
	StatsType = "string",
	StrengthBoost = "integer",
	Value = "integer",
	VitalityBoost = "integer",
	WeaponRange = "integer",
	Weight = "integer",
	Willpower = "integer",
	WitsBoost = "integer",
}

local EsvCharacterProps = {
	RootTemplate = "CharacterTemplate",
	PlayerCustomData = "PlayerCustomData",
	Stats = "StatCharacter",
	DisplayName = "string",
	Handle = "ObjectHandle",
	NetID = "integer",
	MyGuid = "string",
	WorldPos = "number",
	CurrentLevel = "string",
	Scale = "number",
	AnimationOverride = "string",
	WalkSpeedOverride = "number",
	RunSpeedOverride = "number",
	NeedsUpdateCount = "integer",
	ScriptForceUpdateCount = "integer",
	ForceSynchCount = "integer",
	InventoryHandle = "ObjectHandle",
	SkillBeingPrepared = "string",
	LifeTime = "number",
	TurnTimer = "number",
	TriggerTrapsTimer = "number",
	UserID = "integer",
	ReservedUserID = "integer",
	OwnerHandle = "ObjectHandle",
	FollowCharacterHandle = "ObjectHandle",
	SpiritCharacterHandle = "ObjectHandle",
	CorpseCharacterHandle = "ObjectHandle",
	PartialAP = "number",
	AnimType = "integer",
	DelayDeathCount = "integer",
	AnimationSetOverride = "string",
	OriginalTransformDisplayName = "string",
	PartyHandle = "ObjectHandle",
	CustomTradeTreasure = "string",
	IsAlarmed = "boolean",
	CrimeWarningsEnabled = "boolean",
	CrimeInterrogationEnabled = "boolean",
	MovingCasterHandle = "ObjectHandle",
	Archetype = "string",
	EquipmentColor = "string",
	ProjectileTemplate = "string",
	ReadyCheckBlocked = "boolean",
	CorpseLootable = "boolean",
	CustomBloodSurface = "string",
	PreviousLevel = "string",
	IsPlayer = "boolean",
	Multiplayer = "boolean",
	InParty = "boolean",
	HostControl = "boolean",
	Activated = "boolean",
	OffStage = "boolean",
	Dead = "boolean",
	HasOwner = "boolean",
	InDialog = "boolean",
	Summon = "boolean",
	CannotDie = "boolean",
	CharacterControl = "boolean",
	Loaded = "boolean",
	InArena = "boolean",
	CharacterCreationFinished = "boolean",
	Floating = "boolean",
	SpotSneakers = "boolean",
	Temporary = "boolean",
	WalkThrough = "boolean",
	CoverAmount = "boolean",
	CanShootThrough = "boolean",
	PartyFollower = "boolean",
	Totem = "boolean",
	NoRotate = "boolean",
	Deactivated = "boolean",
	IsHuge = "boolean",
	MadePlayer = "boolean",
	LevelTransitionPending = "boolean",
	RegisteredForAutomatedDialog = "boolean",
	Global = "boolean",
	HasOsirisDialog = "boolean",
	HasDefaultDialog = "boolean",
	TreasureGeneratedForTrader = "boolean",
	Trader = "boolean",
	Resurrected = "boolean",
	IsPet = "boolean",
	IsSpectating = "boolean",
	NoReptuationEffects = "boolean",
	HasWalkSpeedOverride = "boolean",
	HasRunSpeedOverride = "boolean",
	IsGameMaster = "boolean",
	IsPossessed = "boolean",
	ManuallyLeveled = "boolean",
}

userDataProps.CDivinityStats_Character = {
--- Properties from PropertyMap
	Level = "integer",
	Name = "string",
	AIFlags = "integer",
	CurrentVitality = "integer",
	CurrentArmor = "integer",
	CurrentMagicArmor = "integer",
	ArmorAfterHitCooldownMultiplier = "integer",
	MagicArmorAfterHitCooldownMultiplier = "integer",
	MPStart = "integer",
	CurrentAP = "integer",
	BonusActionPoints = "integer",
	Experience = "integer",
	Reputation = "integer",
	Flanked = "integer",
	Karma = "integer",
	MaxResistance = "integer",
	HasTwoHandedWeapon = "integer",
	IsIncapacitatedRefCount = "integer",
	MaxVitality = "integer",
	BaseMaxVitality = "integer",
	MaxArmor = "integer",
	BaseMaxArmor = "integer",
	MaxMagicArmor = "integer",
	BaseMaxMagicArmor = "integer",
	Sight = "number",
	BaseSight = "number",
	MaxSummons = "integer",
	BaseMaxSummons = "integer",
	MaxMpOverride = "integer",
--- StatCharacterFlags
	IsPlayer = "boolean",
	InParty = "boolean",
	IsSneaking = "boolean",
	Invisible = "boolean",
	Blind = "boolean",
	DrinkedPotion = "boolean",
	EquipmentValidated = "boolean",
--- Properties from CDivinityStats_Character::GetStat
	PhysicalResistance = "integer",
	PiercingResistance = "integer",
	CorrosiveResistance = "integer",
	MagicResistance = "integer",
--- Base properties from CDivinityStats_Character::GetStat
	BasePhysicalResistance = "integer",
	BasePiercingResistance = "integer",
	BaseCorrosiveResistance = "integer",
	BaseMagicResistance = "integer",
--- Properties from CharacterStatsGetters::GetStat
	MaxMp = "integer",
	APStart = "integer",
	APRecovery = "integer",
	APMaximum = "integer",
	Strength = "integer",
	Finesse = "integer",
	Intelligence = "integer",
	Constitution = "integer",
	Memory = "integer",
	Wits = "integer",
	Accuracy = "integer", -- Crashes in v55
	Dodge = "integer",
	CriticalChance = "integer",
	FireResistance = "integer",
	EarthResistance = "integer",
	WaterResistance = "integer",
	AirResistance = "integer",
	PoisonResistance = "integer",
	ShadowResistance = "integer",
	CustomResistance = "integer",
	LifeSteal = "integer",
	Hearing = "integer",
	Movement = "integer",
	Initiative = "integer",
	BlockChance = "integer",
	ChanceToHitBoost = "integer",
--- Base properties from CharacterStatsGetters::GetStat
	--BaseMaxMp = "integer", -- Broken, crashes the game
	BaseAPStart = "integer",
	BaseAPRecovery = "integer",
	BaseAPMaximum = "integer",
	BaseStrength = "integer",
	BaseFinesse = "integer",
	BaseIntelligence = "integer",
	BaseConstitution = "integer",
	BaseMemory = "integer",
	BaseWits = "integer",
	BaseAccuracy = "integer",
	BaseDodge = "integer",
	BaseCriticalChance = "integer",
	BaseFireResistance = "integer",
	BaseEarthResistance = "integer",
	BaseWaterResistance = "integer",
	BaseAirResistance = "integer",
	BasePoisonResistance = "integer",
	BaseShadowResistance = "integer",
	BaseCustomResistance = "integer",
	BaseLifeSteal = "integer",
	BaseHearing = "integer",
	BaseMovement = "integer",
	BaseInitiative = "integer",
	BaseBlockChance = "integer",
	BaseChanceToHitBoost = "integer",
--- Properties from CharacterFetchStat
	DynamicStats = "StatCharacterDynamic[]",
	MainWeapon = "StatItem",
	OffHandWeapon = "StatItem",
	DamageBoost = "integer",
	Character = "EsvCharacter",
	Rotation = "number[]",
	Position = "number[]",
	MyGuid = "string",
	NetID = "integer",
}

userDataProps.CharacterDynamicStat = {
	--StatBase
	FreezeImmunity = "boolean",
	BurnImmunity = "boolean",
	StunImmunity = "boolean",
	PoisonImmunity = "boolean",
	CharmImmunity = "boolean",
	FearImmunity = "boolean",
	KnockdownImmunity = "boolean",
	MuteImmunity = "boolean",
	ChilledImmunity = "boolean",
	WarmImmunity = "boolean",
	WetImmunity = "boolean",
	BleedingImmunity = "boolean",
	CrippledImmunity = "boolean",
	BlindImmunity = "boolean",
	CursedImmunity = "boolean",
	WeakImmunity = "boolean",
	SlowedImmunity = "boolean",
	DiseasedImmunity = "boolean",
	InfectiousDiseasedImmunity = "boolean",
	PetrifiedImmunity = "boolean",
	DrunkImmunity = "boolean",
	SlippingImmunity = "boolean",
	FreezeContact = "boolean",
	BurnContact = "boolean",
	StunContact = "boolean",
	PoisonContact = "boolean",
	ChillContact = "boolean",
	Torch = "boolean",
	Arrow = "boolean",
	Unbreakable = "boolean",
	Unrepairable = "boolean",
	Unstorable = "boolean",
	Grounded = "boolean",
	HastedImmunity = "boolean",
	TauntedImmunity = "boolean",
	SleepingImmunity = "boolean",
	AcidImmunity = "boolean",
	SuffocatingImmunity = "boolean",
	RegeneratingImmunity = "boolean",
	DisarmedImmunity = "boolean",
	DecayingImmunity = "boolean",
	ClairvoyantImmunity = "boolean",
	EnragedImmunity = "boolean",
	BlessedImmunity = "boolean",
	ProtectFromSummon = "boolean",
	Floating = "boolean",
	DeflectProjectiles = "boolean",
	IgnoreClouds = "boolean",
	MadnessImmunity = "boolean",
	ChickenImmunity = "boolean",
	IgnoreCursedOil = "boolean",
	ShockedImmunity = "boolean",
	WebImmunity = "boolean",
	LootableWhenEquipped = "boolean",
	PickpocketableWhenEquipped = "boolean",
	LoseDurabilityOnCharacterHit = "boolean",
	EntangledContact = "boolean",
	ShacklesOfPainImmunity = "boolean",
	MagicalSulfur = "boolean",
	ThrownImmunity = "boolean",
	InvisibilityImmunity = "boolean",
	TALENT_None = "boolean",
	TALENT_ItemMovement = "boolean",
	TALENT_ItemCreation = "boolean",
	TALENT_Flanking = "boolean",
	TALENT_AttackOfOpportunity = "boolean",
	TALENT_Backstab = "boolean",
	TALENT_Trade = "boolean",
	TALENT_Lockpick = "boolean",
	TALENT_ChanceToHitRanged = "boolean",
	TALENT_ChanceToHitMelee = "boolean",
	TALENT_Damage = "boolean",
	TALENT_ActionPoints = "boolean",
	TALENT_ActionPoints2 = "boolean",
	TALENT_Criticals = "boolean",
	TALENT_IncreasedArmor = "boolean",
	TALENT_Sight = "boolean",
	TALENT_ResistFear = "boolean",
	TALENT_ResistKnockdown = "boolean",
	TALENT_ResistStun = "boolean",
	TALENT_ResistPoison = "boolean",
	TALENT_ResistSilence = "boolean",
	TALENT_ResistDead = "boolean",
	TALENT_Carry = "boolean",
	TALENT_Throwing = "boolean",
	TALENT_Repair = "boolean",
	TALENT_ExpGain = "boolean",
	TALENT_ExtraStatPoints = "boolean",
	TALENT_ExtraSkillPoints = "boolean",
	TALENT_Durability = "boolean",
	TALENT_Awareness = "boolean",
	TALENT_Vitality = "boolean",
	TALENT_FireSpells = "boolean",
	TALENT_WaterSpells = "boolean",
	TALENT_AirSpells = "boolean",
	TALENT_EarthSpells = "boolean",
	TALENT_Charm = "boolean",
	TALENT_Intimidate = "boolean",
	TALENT_Reason = "boolean",
	TALENT_Luck = "boolean",
	TALENT_Initiative = "boolean",
	TALENT_InventoryAccess = "boolean",
	TALENT_AvoidDetection = "boolean",
	TALENT_AnimalEmpathy = "boolean",
	TALENT_Escapist = "boolean",
	TALENT_StandYourGround = "boolean",
	TALENT_SurpriseAttack = "boolean",
	TALENT_LightStep = "boolean",
	TALENT_ResurrectToFullHealth = "boolean",
	TALENT_Scientist = "boolean",
	TALENT_Raistlin = "boolean",
	TALENT_MrKnowItAll = "boolean",
	TALENT_WhatARush = "boolean",
	TALENT_FaroutDude = "boolean",
	TALENT_Leech = "boolean",
	TALENT_ElementalAffinity = "boolean",
	TALENT_FiveStarRestaurant = "boolean",
	TALENT_Bully = "boolean",
	TALENT_ElementalRanger = "boolean",
	TALENT_LightningRod = "boolean",
	TALENT_Politician = "boolean",
	TALENT_WeatherProof = "boolean",
	TALENT_LoneWolf = "boolean",
	TALENT_Zombie = "boolean",
	TALENT_Demon = "boolean",
	TALENT_IceKing = "boolean",
	TALENT_Courageous = "boolean",
	TALENT_GoldenMage = "boolean",
	TALENT_WalkItOff = "boolean",
	TALENT_FolkDancer = "boolean",
	TALENT_SpillNoBlood = "boolean",
	TALENT_Stench = "boolean",
	TALENT_Kickstarter = "boolean",
	TALENT_WarriorLoreNaturalArmor = "boolean",
	TALENT_WarriorLoreNaturalHealth = "boolean",
	TALENT_WarriorLoreNaturalResistance = "boolean",
	TALENT_RangerLoreArrowRecover = "boolean",
	TALENT_RangerLoreEvasionBonus = "boolean",
	TALENT_RangerLoreRangedAPBonus = "boolean",
	TALENT_RogueLoreDaggerAPBonus = "boolean",
	TALENT_RogueLoreDaggerBackStab = "boolean",
	TALENT_RogueLoreMovementBonus = "boolean",
	TALENT_RogueLoreHoldResistance = "boolean",
	TALENT_NoAttackOfOpportunity = "boolean",
	TALENT_WarriorLoreGrenadeRange = "boolean",
	TALENT_RogueLoreGrenadePrecision = "boolean",
	TALENT_WandCharge = "boolean",
	TALENT_DualWieldingDodging = "boolean",
	TALENT_Human_Inventive = "boolean",
	TALENT_Human_Civil = "boolean",
	TALENT_Elf_Lore = "boolean",
	TALENT_Elf_CorpseEating = "boolean",
	TALENT_Dwarf_Sturdy = "boolean",
	TALENT_Dwarf_Sneaking = "boolean",
	TALENT_Lizard_Resistance = "boolean",
	TALENT_Lizard_Persuasion = "boolean",
	TALENT_Perfectionist = "boolean",
	TALENT_Executioner = "boolean",
	TALENT_ViolentMagic = "boolean",
	TALENT_QuickStep = "boolean",
	TALENT_Quest_SpidersKiss_Str = "boolean",
	TALENT_Quest_SpidersKiss_Int = "boolean",
	TALENT_Quest_SpidersKiss_Per = "boolean",
	TALENT_Quest_SpidersKiss_Null = "boolean",
	TALENT_Memory = "boolean",
	TALENT_Quest_TradeSecrets = "boolean",
	TALENT_Quest_GhostTree = "boolean",
	TALENT_BeastMaster = "boolean",
	TALENT_LivingArmor = "boolean",
	TALENT_Torturer = "boolean",
	TALENT_Ambidextrous = "boolean",
	TALENT_Unstable = "boolean",
	TALENT_ResurrectExtraHealth = "boolean",
	TALENT_NaturalConductor = "boolean",
	TALENT_Quest_Rooted = "boolean",
	TALENT_PainDrinker = "boolean",
	TALENT_DeathfogResistant = "boolean",
	TALENT_Sourcerer = "boolean",
	TALENT_Rager = "boolean",
	TALENT_Elementalist = "boolean",
	TALENT_Sadist = "boolean",
	TALENT_Haymaker = "boolean",
	TALENT_Gladiator = "boolean",
	TALENT_Indomitable = "boolean",
	TALENT_WildMag = "boolean",
	TALENT_Jitterbug = "boolean",
	TALENT_Soulcatcher = "boolean",
	TALENT_MasterThief = "boolean",
	TALENT_GreedyVessel = "boolean",
	TALENT_MagicCycles = "boolean",
	WarriorLore = "integer",
	RangerLore = "integer",
	RogueLore = "integer",
	SingleHanded = "integer",
	TwoHanded = "integer",
	PainReflection = "integer",
	Ranged = "integer",
	Shield = "integer",
	Reflexes = "integer",
	PhysicalArmorMastery = "integer",
	MagicArmorMastery = "integer",
	VitalityMastery = "integer",
	Sourcery = "integer",
	FireSpecialist = "integer",
	WaterSpecialist = "integer",
	AirSpecialist = "integer",
	EarthSpecialist = "integer",
	Necromancy = "integer",
	Summoning = "integer",
	Polymorph = "integer",
	Telekinesis = "integer",
	Repair = "integer",
	Sneaking = "integer",
	Pickpocket = "integer",
	Thievery = "integer",
	Loremaster = "integer",
	Crafting = "integer",
	Barter = "integer",
	Charm = "integer",
	Intimidate = "integer",
	Reason = "integer",
	Persuasion = "integer",
	Leadership = "integer",
	Luck = "integer",
	DualWielding = "integer",
	Wand = "integer",
	Perseverance = "integer",
	Runecrafting = "integer",
	Brewmaster = "integer",
	Sulfurology = "integer",
	-- StatCharacterDynamic
	-- Properties from PropertyMap
	SummonLifelinkModifier = "integer",
	Strength = "integer",
	Memory = "integer",
	Intelligence = "integer",
	Movement = "integer",
	MovementSpeedBoost = "integer",
	Finesse = "integer",
	Wits = "integer",
	Constitution = "integer",
	FireResistance = "integer",
	EarthResistance = "integer",
	WaterResistance = "integer",
	AirResistance = "integer",
	PoisonResistance = "integer",
	ShadowResistance = "integer",
	Willpower = "integer",
	Bodybuilding = "integer",
	PiercingResistance = "integer",
	PhysicalResistance = "integer",
	CorrosiveResistance = "integer",
	MagicResistance = "integer",
	CustomResistance = "integer",
	Sight = "integer",
	Hearing = "integer",
	FOV = "integer",
	APMaximum = "integer",
	APStart = "integer",
	APRecovery = "integer",
	CriticalChance = "integer",
	Initiative = "integer",
	Vitality = "integer",
	VitalityBoost = "integer",
	MagicPoints = "integer",
	Level = "integer",
	Gain = "integer",
	Armor = "integer",
	MagicArmor = "integer",
	ArmorBoost = "integer",
	MagicArmorBoost = "integer",
	ArmorBoostGrowthPerLevel = "integer",
	MagicArmorBoostGrowthPerLevel = "integer",
	DamageBoost = "integer",
	DamageBoostGrowthPerLevel = "integer",
	Accuracy = "integer",
	Dodge = "integer",
	MaxResistance = "integer",
	LifeSteal = "integer",
	Weight = "integer",
	ChanceToHitBoost = "integer",
	RangeBoost = "integer",
	APCostBoost = "integer",
	SPCostBoost = "integer",
	MaxSummons = "integer",
	BonusWeaponDamageMultiplier = "integer",
	TranslationKey = "integer",
	BonusWeapon = "integer",
	StepsType = "integer",
}

if Ext.Utils.Version() < 56 then
	userDataProps.CDivinityStats_Character.Accuracy = nil
	userDataProps.CharacterDynamicStat.Accuracy = nil
end

local CharacterTemplate = {
	CombatTemplate = "CombatComponentTemplate",
	Icon = "string",
	Stats = "string",
	SkillSet = "string",
	Equipment = "string",
	LightID = "string",
	HitFX = "string",
	DefaultDialog = "string",
	SpeakerGroup = "string",
	GeneratePortrait = "string",
	WalkSpeed = "number",
	RunSpeed = "number",
	ClimbAttachSpeed = "number",
	ClimbLoopSpeed = "number",
	ClimbDetachSpeed = "number",
	CanShootThrough = "boolean",
	WalkThrough = "boolean",
	CanClimbLadders = "boolean",
	IsPlayer = "boolean",
	Floating = "boolean",
	SpotSneakers = "boolean",
	CanOpenDoors = "boolean",
	AvoidTraps = "boolean",
	InfluenceTreasureLevel = "boolean",
	HardcoreOnly = "boolean",
	NotHardcore = "boolean",
	JumpUpLadders = "boolean",
	NoRotate = "boolean",
	IsHuge = "boolean",
	EquipmentClass = "number",
	ExplodedResourceID = "string",
	ExplosionFX = "string",
	VisualSetResourceID = "string",
	VisualSetIndices = "number",
	TrophyID = "string",
	SoundInitEvent = "string",
	SoundAttachBone = "string",
	SoundAttenuation = "number",
	CoverAmount = "number",
	LevelOverride = "number",
	ForceUnsheathSkills = "boolean",
	CanBeTeleported = "boolean",
	ActivationGroupId = "string",
	SoftBodyCollisionTemplate = "string",
	RagdollTemplate = "string",
	DefaultState = "number",
	GhostTemplate = "string",
	IsLootable = "boolean",
	IsEquipmentLootable = "boolean",
	InventoryType = "number",
	IsArenaChampion = "boolean",
	FootstepWeight = "string",
}

local CombatComponentTemplate = {
	Alignment = "string",
	CanFight = "boolean",
	CanJoinCombat = "boolean",
	CombatGroupID = "string",
	IsBoss = "boolean",
	IsInspector = "boolean",
	StartCombatRange = "number",
}

local TriggerTypeProps = {
	TriggerSoundVolume = {
		AmbientSound = "string",
		Occlusion = "number",
		AuxBus1 = "integer",
		AuxBus2 = "integer",
		AuxBus3 = "integer",
		AuxBus4 = "integer",
	},
		TriggerAtmosphere = {
		Atmospheres = "string[]",
		FadeTime = "number",
	}
}

userDataProps["esv::Trigger"] = {
	Handle = "ObjectHandle",
	UUID = "string",
	SyncFlags = "integer",
	Translate = "number[]",
	IsGlobal = "boolean",
	Level = "string",
	--TriggerType = "string",
	TriggerType = function(obj, data, k, printNil)
		local t = obj[k]
		data[k] = t
		local props = TriggerTypeProps[t]
		if props and obj.TriggerData then
			DebugHelpers.ProcessProps(obj.TriggerData, props, data, printNil)
		end
	end,
	--TODO Not supported yet?
	--RootTemplate = "TriggerTemplate",
	--TriggerData = "EsvAtmosphereTriggerData|EsvSoundVolumeTriggerData",
	--Specific trigger type data
}

userDataProps["eoc::ItemTemplate"] = {
	ActivationGroupId = "string",
	AllowSummonTeleport = "boolean",
	AltSpeaker = "string",
	Amount = "number",
	CanBeMoved = "boolean",
	CanBePickedUp = "boolean",
	CanClickThrough = "boolean",
	CanShootThrough = "boolean",
	CombatTemplate = "CombatComponentTemplate",
	CoverAmount = "number",
	DefaultState = "string",
	Description = "string",
	Destroyed = "boolean",
	DropSound = "string",
	EquipSound = "string",
	Floating = "boolean",
	FreezeGravity = "boolean",
	HardcoreOnly = "boolean",
	HitFX = "string",
	Hostile = "boolean",
	Icon = "string",
	InventoryMoveSound = "string",
	IsBlocker = "boolean",
	IsHuge = "boolean",
	IsInteractionDisabled = "boolean",
	IsKey = "boolean",
	IsPinnedContainer = "boolean",
	IsPointerBlocker = "boolean",
	IsPublicDomain = "boolean",
	IsSourceContainer = "boolean",
	IsSurfaceBlocker = "boolean",
	IsSurfaceCloudBlocker = "boolean",
	IsTrap = "boolean",
	IsWall = "boolean",
	Key = "string",
	LevelOverride = "number",
	LockLevel = "number ",
	LoopSound = "string",
	MaxStackAmount = "number",
	MeshProxy = "string",
	NotHardcore = "boolean",
	OnUseDescription = "string",
	Owner = "string",
	PickupSound = "string",
	Race = "number",
	SoundAttachBone = "string",
	SoundAttenuation = "number",
	SoundInitEvent = "string",
	Speaker = "string",
	SpeakerGroup = "string",
	Stats = "string",
	StoryItem = "boolean",
	Tooltip = "number",
	TreasureLevel = "number",
	TreasureOnDestroy = "boolean",
	UnequipSound = "string",
	Unimportant = "boolean",
	UseOnDistance = "boolean",
	UsePartyLevelForTreasureLevel = "boolean",
	UseRemotely = "boolean",
	UseSound = "string",
	Wadable = "boolean",
	WalkOn = "boolean",
	WalkThrough = "boolean",
}

if not _ISCLIENT then
	userDataProps["eoc::ItemTemplate"].ItemDescription = "string"
	userDataProps["eoc::ItemTemplate"].ItemDisplayName = "boolean"
end

userDataProps["esv::Item"] = EsvItemProps
userDataProps["ecl::Item"] = EclItemProps
userDataProps["esv::Character"] = EsvCharacterProps
userDataProps["eoc::CharacterTemplate"] = CharacterTemplate
userDataProps["eoc::CombatComponentTemplate"] = CombatComponentTemplate
userDataProps["CDivinityStats_Item"] = CDivinityStats_Item
userDataProps["CDivinityStats_Equipment_Attributes"] = CDivinityStats_Equipment_Attributes
userDataProps["CDivinityStats_Weapon_Attributes"] = CDivinityStats_Weapon_Attributes
---@param obj DamageList
userDataProps["CDamageList"] = function(obj) 
	--return StringHelpers.Join(";", obj:ToTable(), false, function(i,v) return string.format("DamageType = %s, Amount = %i", v.DamageType, v.Amount) end)
	return obj:ToTable()
end
userDataProps["esv::HStatus"] = {
	--EsvStatus
	--StatusType = "string",
	StatusId = "string",
	CanEnterChance = "integer",
	StartTimer = "number",
	LifeTime = "number",
	CurrentLifeTime = "number",
	TurnTimer = "number",
	Strength = "number",
	StatsMultiplier = "number",
	DamageSourceType = "string",
	StatusHandle = "StatusHandle",
	TargetHandle = "ObjectHandle",
	StatusSourceHandle = "ObjectHandle",
	KeepAlive = "boolean",
	IsOnSourceSurface = "boolean",
	IsFromItem = "boolean",
	Channeled = "boolean",
	IsLifeTimeSet = "boolean",
	InitiateCombat = "boolean",
	Influence = "boolean",
	BringIntoCombat = "boolean",
	IsHostileAct = "boolean",
	IsInvulnerable = "boolean",
	IsResistingDeath = "boolean",
	ForceStatus = "boolean",
	ForceFailStatus = "boolean",
	RequestClientSync = "boolean",
	RequestDelete = "boolean",
	RequestDeleteAtTurnEnd = "boolean",
	Started = "boolean",
	--EsvStatusHit
	Hit = "HitRequest",
	HitByHandle = "ObjectHandle",
	HitWithHandle = "ObjectHandle",
	WeaponHandle = "ObjectHandle",
	HitReason = "string",
	SkillId = "string",
	Interruption = "boolean",
	AllowInterruptAction = "boolean",
	ForceInterrupt = "boolean",
	DecDelayDeathCount = "boolean",
	ImpactPosition = "number[]",
	ImpactOrigin = "number[]",
	ImpactDirection = "number[]",
	--EsvStatusHeal
	EffectTime = "number",
	HealAmount = "integer",
	HealEffect = "string",
	HealEffectId = "string",
	HealType = "string",
	AbsorbSurfaceRange = "integer",
	TargetDependentHeal = "boolean",
	--EsvStatusHealing
	TimeElapsed = "number",
	-- HealAmount = "integer",
	-- HealEffect = "string",
	-- HealEffectId = "string",
	SkipInitialEffect = "boolean",
	HealingEvent = "number",
	HealStat = "string",
	--AbsorbSurfaceRange = "integer",
}

userDataProps["esv::Status"] = {
	StatusType = "string",
	StatusId = "string",
	CanEnterChance = "integer",
	StartTimer = "number",
	LifeTime = "number",
	CurrentLifeTime = "number",
	TurnTimer = "number",
	Strength = "number",
	StatsMultiplier = "number",
	DamageSourceType = "string",
	StatusHandle = "StatusHandle",
	TargetHandle = "ObjectHandle",
	StatusSourceHandle = "ObjectHandle",
	KeepAlive = "boolean",
	IsOnSourceSurface = "boolean",
	IsFromItem = "boolean",
	Channeled = "boolean",
	IsLifeTimeSet = "boolean",
	InitiateCombat = "boolean",
	Influence = "boolean",
	BringIntoCombat = "boolean",
	IsHostileAct = "boolean",
	IsInvulnerable = "boolean",
	IsResistingDeath = "boolean",
	ForceStatus = "boolean",
	ForceFailStatus = "boolean",
	RequestClientSync = "boolean",
	RequestDelete = "boolean",
	RequestDeleteAtTurnEnd = "boolean",
	Started = "boolean",
	SpecificStatusProperties = function(obj, data, k, printNil)
		if obj.StatusType == "CONSUME" then
			local props = {
				--- EsvStatusConsumeBase
				ResetAllCooldowns = "boolean",
				ResetOncePerCombat = "boolean",
				ScaleWithVitality = "boolean",
				LoseControl = "boolean",
				ApplyStatusOnTick = "string",
				EffectTime = "number",
				StatsId = "string",
				StackId = "string",
				OriginalWeaponStatsId = "string",
				OverrideWeaponStatsId = "string",
				OverrideWeaponHandle = "ObjectHandle",
				SavingThrow = "integer",
				SourceDirection = "number",
				Turn = "integer",
				HealEffectOverride = "string",
				Poisoned = "boolean",
			}
			DebugHelpers.ProcessProps(obj, props, data, printNil)
		end
	end,
}

userDataProps["esv::Projectile"] = {
	RootTemplate = "ProjectileTemplate",
	Handle = "ObjectHandle",
	NetID = "integer",
	MyGuid = "string",
	CasterHandle = "ObjectHandle",
	SourceHandle = "ObjectHandle",
	TargetObjectHandle = "ObjectHandle",
	HitObjectHandle = "ObjectHandle",
	SourcePosition = "number[]",
	TargetPosition = "number[]",
	DamageType = "string",
	DamageSourceType = "string",
	LifeTime = "number",
	HitInterpolation = "integer",
	ExplodeRadius0 = "number",
	ExplodeRadius1 = "number",
	DeathType = "string",
	SkillId = "string",
	WeaponHandle = "ObjectHandle",
	MovingEffectHandle = "ObjectHandle",
	SpawnEffect = "string",
	SpawnFXOverridesImpactFX = "boolean",
	EffectHandle = "string",
	RequestDelete = "boolean",
	Launched = "boolean",
	IsTrap = "boolean",
	UseCharacterStats = "boolean",
	ReduceDurability = "boolean",
	AlwaysDamage = "boolean",
	ForceTarget = "boolean",
	IsFromItem = "boolean",
	DivideDamage = "boolean",
	IgnoreRoof = "boolean",
	CanDeflect = "boolean",
	IgnoreObjects = "boolean",
	CleanseStatuses = "string",
	StatusClearChance = "integer",
	Position = "number[]",
	PrevPosition = "number[]",
	Velocity = "number[]",
	Scale = "number",
	CurrentLevel = "string",
}

userDataProps["esv::ShootProjectileRequest"] = {
	SkillId = "string",
	Caster = "ObjectHandle",
	Source = "ObjectHandle",
	Target = "ObjectHandle",
	StartPosition = "number[]",
	EndPosition = "number[]",
	Random = "integer",
	CasterLevel = "integer",
	IsTrap = "boolean",
	UnknownFlag1 = "boolean",
	CleanseStatuses = "string",
	StatusClearChance = "integer",
	IsFromItem = "boolean",
	IsStealthed = "boolean",
	IgnoreObjects = "boolean",
}

userDataProps["eoc::ProjectileTemplate"] = {
	Id = "string",
	Name = "string",
	TemplateName = "string",
	IsGlobal = "boolean",
	IsDeleted = "boolean",
	LevelName = "string",
	ModFolder = "string",
	GroupID = "string",
	VisualTemplate = "string",
	PhysicsTemplate = "string",
	CastShadow = "boolean",
	ReceiveDecal = "boolean",
	AllowReceiveDecalWhenAnimated = "boolean",
	IsReflecting = "boolean",
	IsShadowProxy = "boolean",
	RenderChannel = "number",
	CameraOffset = "number[]",
	HasParentModRelation = "boolean",
	HasGameplayValue = "boolean",
	--DevComment = "string",
	AIBoundsRadius = "number",
	AIBoundsHeight = "number",
	DisplayName = "string",
	Opacity = "number",
	Fadeable = "boolean",
	FadeIn = "boolean",
	SeeThrough = "boolean",
	FadeGroup = "string",
	GameMasterSpawnSection = "integer",
	GameMasterSpawnSubSection = "string",
	LifeTime = "number",
	Speed = "number",
	Acceleration = "number",
	CastBone = "string",
	ImpactFX = "string",
	TrailFX = "string",
	DestroyTrailFXOnImpact = "boolean",
	BeamFX = "string",
	PreviewPathMaterial = "string",
	PreviewPathImpactFX = "string",
	PreviewPathRadius = "number",
	ImpactFXSize = "number",
	RotateImpact = "boolean",
	IgnoreRoof = "boolean",
	DetachBeam = "boolean",
	NeedsArrowImpactSFX = "boolean",
	ProjectilePath = "boolean",
	PathShift = "string",
	PathRadius = "number",
	PathMinArcDist = "number",
	PathMaxArcDist = "number",
	PathRepeat = "number",
}

userDataProps["CRPGStats_Object"] = function(stat)
	if _OSIRIS() then
		local statType = GameHelpers.Stats.GetStatType(stat.Name)
		local attributeNames = statType and Data.StatAttributes[statType] or nil
		if attributeNames then
			local attributes = {}
			for _,k in pairs(attributeNames) do
				local v = stat[k]
				if v then
					attributes[k] = v
				end
			end
			return attributes
		end
	end
	return stat
end

DebugHelpers.userDataProps = userDataProps

local function TryGetValue(obj,k,t)
	local value = obj[k]
	local actualType = _type(value)
	if actualType ~= t then
		if actualType == "userdata" then
			local userDataType = Ext.Types.GetObjectType(value)
			if string.find(userDataType, "Array") then
				local tbl = {}
				for i=1,#value do
					tbl[#tbl+1] = value[i]
				end
				return tbl
			end
		end
		return tostring(value)
	end
	return value
end

function DebugHelpers.ProcessProps(obj, props, data, printNil)
	for k,v in pairs(props) do
		if _type(v) == "function" then
			local b,result = pcall(v, obj, data, k, printNil)
			if b and result ~= nil then
				data[k] = result
			end
		else
			if v == "ObjectHandle" or v == "StatusHandle" then
				--data[k] = "ObjectHandle"
				data[k] = tostring(obj[k])
			else
				local b,value = xpcall(TryGetValue, debug.traceback, obj, k, v)
				if b and value ~= nil then
					if props == userDataProps.CDivinityStats_Equipment_Attributes and ((_type(value) == "number" and value == 0) or (_type(value) == "string" and value == "None" or value == "")) then
						-- skip
					else
						data[k] = value
					end
				elseif printNil == true then
					data[k] = string.format("nil (%s)", v)
				end
			end
		end
	end
end

function DebugHelpers.TraceUserData(obj, printNil)
	if obj == nil then
		return "nil"
	end
	local meta = getmetatable(obj)
	local props = userDataProps[meta]
	if props then
		if meta == "CDivinityStats_Equipment_Attributes" and obj.ItemSlot == "Weapon" then
			props = userDataProps.CDivinityStats_Weapon_Attributes
		end
		if _type(props) == "function" then
			local b,result = xpcall(props, debug.traceback, obj)
			if b then
				return result
			else
				Ext.Utils.PrintError(result)
				return "nil"
			end
		else
			local data = {}
			DebugHelpers.ProcessProps(obj, props, data, printNil)
			return Lib.inspect(data)
		end
	else
		if meta then
			return tostring(meta)
		else
			return tostring(obj)
		end
	end
end

function DebugHelpers.TraceUserDataSerpent(obj, opts)
	if obj == nil then
		return "nil"
	end
	if Ext.Utils.IsValidHandle(obj) then
		return tostring(obj)
	end
	local meta = getmetatable(obj)
	local props = userDataProps[meta]
	if meta == "CDivinityStats_Equipment_Attributes" and obj.ItemSlot == "Weapon" then
		props = userDataProps.CDivinityStats_Weapon_Attributes
	end
	if opts and opts.SimplifyUserdata then
		if GameHelpers.Ext.ObjectIsCharacter(obj) or GameHelpers.Ext.ObjectIsItem(obj) then
			props = {}
			if obj.MyGuid then
				props.MyGuid = "string"
			end
			if obj.DisplayName then
				props.DisplayName = function(_obj) return GameHelpers.GetDisplayName(_obj) end
			end
			props.UserdataType = function(_obj) return Ext.Types.GetObjectType(_obj) end
			if obj.NetID then
				props.NetID = "number"
			end
		elseif GameHelpers.Ext.ObjectIsStatCharacter(obj) then
			---@cast obj CDivinityStatsCharacter
			props = {}
			if obj.MyGuid then
				props.MyGuid = "string"
			end
			if obj.Character then
				props.DisplayName = function(_obj) return GameHelpers.GetDisplayName(_obj.Character) end
			end
			props.UserdataType = function(_obj) return Ext.Types.GetObjectType(_obj) end
			if obj.NetID then
				props.NetID = "number"
			end
		elseif GameHelpers.Ext.ObjectIsStatItem(obj) then
			---@cast obj CDivinityStatsItem
			props = {}
			if obj.Name then
				props.Name = "string"
			end
			if obj.DisplayName then
				props.DisplayName = function(_obj) return GameHelpers.GetDisplayName(_obj.DisplayName) end
			end
			props.UserdataType = function(_obj) return Ext.Types.GetObjectType(_obj) end
		elseif meta and string.find(meta, "esv::Status") then
			props = {
				StatusId = "string",
				StatusType = "string",
				CurrentLifeTime = "number",
				LifeTime = "number",
				StatsMultiplier = "number",
			}
			if obj.StatusType == "HEAL" then
				props.HealAmount = "number"
				props.HealEffect = "number"
				props.HealEffectId = "string"
				props.HealType = "number"
				props.TargetDependentHeal = "boolean"
				props.TargetDependentHealAmount = "table"
			elseif obj.StatusType == "HEALING" then
				props.HealAmount = "number"
				props.HealStat = "number"
			end
		else
			props = nil
			meta = obj
		end
	end
	if props then
		if _type(props) == "function" then
			local b,result = xpcall(props, debug.traceback, obj)
			if b then
				return result
			else
				Ext.Utils.PrintError(result)
				return "nil"
			end
		else
			local data = {}
			DebugHelpers.ProcessProps(obj, props, data, false)
			return data
		end
	else
		local data = {
			UserdataType = Ext.Types.GetObjectType(obj)
		}
		local _proccessEntry = nil
		_proccessEntry = function(_d, k,v)
			local t = _type(v)
			if t == "userdata" then
				local userDataType = Ext.Types.GetObjectType(v)
				if string.find(userDataType, "Array") then
					_d[k] = Ext.DumpExport(v)
				else
					local b,result = pcall(DebugHelpers.TraceUserDataSerpent, v, opts)
					if b and result ~= nil then
						_d[k] = result
					end
				end
			elseif t == "table" then
				_d[k] = {}
				for k2,v2 in pairs(v) do
					_proccessEntry(_d[k], k2,v2)
				end
			else
				_d[k] = Ext.DumpExport(v)
			end
		end
		local b = pcall(function()
			for k,v in pairs(obj) do
				if k ~= "AttributeFlags" then
					_proccessEntry(data, k,v)
				end
			end
		end)
		if not b then
			---@type JsonStringifyOptions
			local jsonOpts = {
				Beautify = true,
				StringifyInternalTypes = true,
				IterateUserdata = true,
				AvoidRecursion = true,
			}
			if opts and opts.maxlevel then
				jsonOpts.LimitDepth = opts.maxlevel
				jsonOpts.LimitArrayElements = 3
			end
			data.Data = Ext.Json.Stringify(obj, jsonOpts)
		end
		return data
	end
end