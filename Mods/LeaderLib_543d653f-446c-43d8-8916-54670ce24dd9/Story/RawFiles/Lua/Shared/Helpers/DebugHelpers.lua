if DebugHelpers == nil then
	DebugHelpers = {}
end

local EsvItemProps = {
	Handle = "ObjectHandle",
	RootTemplate = "ItemTemplate",
	WorldPos = "number[]",
	CurrentLevel = "string",
	Scale = "number",
	CustomDisplayName = "string",
	CustomDescription = "string",
	CustomBookContent = "string",
	StatsId = "string",
	InventoryHandle = "ObjectHandle",
	ParentInventoryHandle = "ObjectHandle",
	Slot = "integer",
	Amount = "integer",
	Vitality = "integer",
	Armor = "integer",
	InUseByCharacterHandle = "ObjectHandle",
	Key = "string",
	LockLevel = "integer",
	OwnerHandle = "ObjectHandle",
	ItemType = "string",
	GoldValueOverwrite = "integer",
	WeightValueOverwrite = "integer",
	TreasureLevel = "integer",
	LevelOverride = "integer",
	ForceSynch = "boolean",
	DisplayName = "string",
	Activated = "boolean",
	OffStage = "boolean",
	CanBePickedUp = "boolean",
	CanBeMoved = "boolean",
	WalkOn = "boolean",
	WalkThrough = "boolean",
	NoCover = "boolean",
	CanShootThrough = "boolean",
	CanUse = "boolean",
	InteractionDisabled = "boolean",
	Destroyed = "boolean",
	LoadedTemplate = "boolean",
	IsDoor = "boolean",
	StoryItem = "boolean",
	Summon = "boolean",
	FreezeGravity = "boolean",
	ForceSync = "boolean",
	IsLadder = "boolean",
	PositionChanged = "boolean",
	Totem = "boolean",
	Destroy = "boolean",
	GMFolding = "boolean",
	Sticky = "boolean",
	DoorFlag = "boolean",
	Floating = "boolean",
	IsSurfaceBlocker = "boolean",
	IsSurfaceCloudBlocker = "boolean",
	SourceContainer = "boolean",
	Frozen = "boolean",
	TeleportOnUse = "boolean",
	PinnedContainer = "boolean",
	UnsoldGenerated = "boolean",
	IsKey = "boolean",
	Global = "boolean",
	CanConsume = "boolean",
	TreasureGenerated = "boolean",
	UnEquipLocked = "boolean",
	UseRemotely = "boolean",
	Stats = "StatItem"
}

local CDivinityStats_Item = {
	Level = "integer",
	Name = "string",
	InstanceId = "integer",
	ItemType = "string",
	ItemSlot = "string",
	WeaponType = "string",
	AnimType = "integer",
	WeaponRange = "integer",
	IsIdentified = "integer",
	IsTwoHanded = "boolean",
	ShouldSyncStats = "boolean",
	HasModifiedSkills = "boolean",
	Skills = "string",
	DamageTypeOverwrite = "string",
	Durability = "integer",
	DurabilityCounter = "integer",
	ItemTypeReal = "string",
	MaxCharges = "integer",
	Charges = "integer",
	DynamicStats = "StatItemDynamic",
	Using = "string",
	Damage = "integer",
	Act = "string",
	Handedness = "string",
	DamageBoost = "integer",
	DamageFromBase = "integer",
	CriticalDamage = "integer",
	CriticalChance = "integer",
	Movement = "integer",
	Initiative = "integer",
	Requirements = "StatRequirement",
	Slot = "string",
	DurabilityDegradeSpeed = "string",
	Value = "integer",
	ModifierType = "string",
	Projectile = "string",
	StrengthBoost = "string",
	FinesseBoost = "string",
	IntelligenceBoost = "string",
	ConstitutionBoost = "string",
	MemoryBoost = "string",
	WitsBoost = "string",
	SingleHanded = "integer",
	TwoHanded = "integer",
	Ranged = "integer",
	DualWielding = "integer",
	RogueLore = "integer",
	WarriorLore = "integer",
	RangerLore = "integer",
	FireSpecialist = "integer",
	WaterSpecialist = "integer",
	AirSpecialist = "integer",
	EarthSpecialist = "integer",
	Sourcery = "integer",
	Necromancy = "integer",
	Polymorph = "integer",
	Summoning = "integer",
	Leadership = "integer",
	PainReflection = "integer",
	Perseverance = "integer",
	Telekinesis = "integer",
	Sneaking = "integer",
	Thievery = "integer",
	Loremaster = "integer",
	Repair = "integer",
	Barter = "integer",
	Persuasion = "integer",
	Luck = "integer",
	Fire = "integer",
	Earth = "integer",
	Water = "integer",
	Air = "integer",
	Poison = "integer",
	Physical = "integer",
	Piercing = "integer",
	SightBoost = "string",
	HearingBoost = "string",
	VitalityBoost = "integer",
	MagicPointsBoost = "string",
	ChanceToHitBoost = "integer",
	APMaximum = "integer",
	APStart = "integer",
	APRecovery = "integer",
	AccuracyBoost = "integer",
	DodgeBoost = "integer",
	Weight = "integer",
	AttackAPCost = "integer",
	ComboCategory = "string",
	Flags = "string",
	Boosts = "string",
	InventoryTab = "string",
	Reflection = "string",
	ItemGroup = "string",
	ObjectCategory = "string",
	MinAmount = "integer",
	MaxAmount = "integer",
	Priority = "integer",
	Unique = "integer",
	MinLevel = "integer",
	MaxLevel = "integer",
	ItemColor = "string",
	MaxSummons = "integer",
	RuneSlots = "integer",
	RuneSlots_V1 = "integer",
	NeedsIdentification = "string",
	LifeSteal = "integer",
	CleavePercentage = "integer",
	CleaveAngle = "integer",
	Talents = "string",
	IgnoreVisionBlock = "string",
	Tags = "string",
	ArmorBoost = "integer",
	MagicArmorBoost = "integer",
	Blocking = "integer",
	ExtraProperties = "StatProperty",
}

local CDivinityStats_Equipment_Attributes = {
	Durability = "integer",
	DurabilityDegradeSpeed = "integer",
	StrengthBoost = "integer",
	FinesseBoost = "integer",
	IntelligenceBoost = "integer",
	ConstitutionBoost = "integer",
	MemoryBoost = "integer",
	WitsBoost = "integer",
	SightBoost = "integer",
	HearingBoost = "integer",
	VitalityBoost = "integer",
	SourcePointsBoost = "integer",
	MaxAP = "integer",
	StartAP = "integer",
	APRecovery = "integer",
	AccuracyBoost = "integer",
	DodgeBoost = "integer",
	LifeSteal = "integer",
	CriticalChance = "integer",
	ChanceToHitBoost = "integer",
	MovementSpeedBoost = "integer",
	RuneSlots = "integer",
	RuneSlots_V1 = "integer",
	FireResistance = "integer",
	AirResistance = "integer",
	WaterResistance = "integer",
	EarthResistance = "integer",
	PoisonResistance = "integer",
	ShadowResistance = "integer",
	PiercingResistance = "integer",
	CorrosiveResistance = "integer",
	PhysicalResistance = "integer",
	MagicResistance = "integer",
	CustomResistance = "integer",
	Movement = "integer",
	Initiative = "integer",
	Willpower = "integer",
	Bodybuilding = "integer",
	MaxSummons = "integer",
	Value = "integer",
	Weight = "integer",
	Skills = "string",
	ItemColor = "string",
	ModifierType = "integer",
	ObjectInstanceName = "string",
	BoostName = "string",
	StatsType = "string",
	DamageType = "integer",
	MinDamage = "integer",
	MaxDamage = "integer",
	DamageBoost = "integer",
	DamageFromBase = "integer",
	CriticalDamage = "integer",
	WeaponRange = "integer",
	CleaveAngle = "integer",
	CleavePercentage = "integer",
	AttackAPCost = "integer",
	ArmorValue = "integer",
	ArmorBoost = "integer",
	MagicArmorValue = "integer",
	MagicArmorBoost = "integer",
	Blocking = "integer",
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

local userDataProps = {
	["esv::Item"] = EsvItemProps,
	["esv::Character"] = EsvCharacterProps,
	["eoc::CharacterTemplate"] = CharacterTemplate,
	["eoc::CombatComponentTemplate"] = CombatComponentTemplate,
	["CDivinityStats_Item"] = CDivinityStats_Item,
	["CDivinityStats_Equipment_Attributes"] = CDivinityStats_Equipment_Attributes,
}

function DebugHelpers.TraceUserData(obj)
	local meta = getmetatable(obj)
	local props = userDataProps[meta]
	if props then
		local data = {}
		for k,v in pairs(props) do
			local value = obj[k]
			if value ~= nil then
				if props == userDataProps.CDivinityStats_Equipment_Attributes and ((type(value) == "number" and value == 0) or (type(value) == "string" and value == "None" or value == "")) then
					-- skip
				else
					data[k] = value
				end
			else
				data[k] = string.format("nil (%s)", v)
			end
		end
		return Lib.inspect(data)
	else
		if meta then
			return tostring(meta)
		else
			return tostring(obj)
		end
	end
end