if GameHelpers.Ext == nil then
	GameHelpers.Ext = {}
end

local isClient = Ext.IsClient
local _EXTVERSION = Ext.Version()

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
	"Flags",
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

function GameHelpers.Ext.CreateStatCharacterTable(stat, mainhand, offhand)
	if stat == nil then
		stat = "_Hero"
	end
	local data = {}
	for i,attribute in pairs(characterStatAttributes) do
		local value = Ext.StatGetAttribute(stat, attribute)
		if value ~= nil then
			data[attribute] = value
		end
	end
	for prop,t in pairs(characterStatProperties) do
		if data[prop] == nil then
			if t == "boolean" then
				data[prop] = false
			elseif t == "number" then
				data[prop] = 0.0
			elseif t == "integer" then
				data[prop] = 0
			elseif t == "string" then
				data[prop] = ""
			end
		end
	end
	for talent,t in pairs(characterTalents) do
		data[talent] = false
	end
	data.MainWeapon = mainhand
	data.OffHandWeapon = offhand
	return data
end


local weaponStatAttributes = {
	"ModifierType",
	"Damage",
	"DamageFromBase",
	"Damage Range",
	"Damage Type",
	"DamageBoost",
	"CriticalDamage",
	"CriticalChance",
	"IsTwoHanded",
	"WeaponType",
}

---@param stat string
---@param level integer
---@param attribute string
---@param weaponType string
---@param damageFromBaseBoost integer|nil
---@param isBoostStat boolean|nil
---@param baseWeaponDamage number|nil
---@param rarity string|nil
---@return StatItem
function GameHelpers.Ext.CreateWeaponTable(stat,level,attribute,weaponType,damageFromBaseBoost,isBoostStat,baseWeaponDamage,rarity)
	local weapon = {}
	weapon.ItemType = "Weapon"
	weapon.Name = stat
	local statObject = Ext.GetStat(stat)
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
	for i,v in pairs(weaponStatAttributes) do
		weaponStat[v] = statObject[v]
	end
	weapon["ModifierType"] = weaponStat["ModifierType"]
	weapon["IsTwoHanded"] = weaponStat["IsTwoHanded"]
	weapon["WeaponType"] = weaponStat["WeaponType"]
	if damageFromBaseBoost ~= nil and damageFromBaseBoost > 0 then
		weaponStat.DamageFromBase = weaponStat.DamageFromBase + damageFromBaseBoost
	end
	local damage = 0
	if baseWeaponDamage ~= nil then
		damage = baseWeaponDamage
	else
		damage = Game.Math.GetLevelScaledWeaponDamage(level)
	end
	local baseDamage = damage * (weaponStat.DamageFromBase * 0.01)
	local range = baseDamage * (weaponStat["Damage Range"] * 0.01)
	weaponStat.MinDamage = Ext.Round(baseDamage - (range/2))
	weaponStat.MaxDamage = Ext.Round(baseDamage + (range/2))
	weaponStat.DamageType = weaponStat["Damage Type"]
	weaponStat.StatsType = "Weapon"
	if weaponType ~= nil then
		weapon.WeaponType = weaponType
		weaponStat.WeaponType = weaponType
	end
	weaponStat.Requirements = weapon.Requirements
	weapon.DynamicStats = {weaponStat}
	if _EXTVERSION >= 56 then
		weapon.ExtraProperties = statObject.ExtraProperties
	end
	if not isBoostStat then
		local boostsString = statObject.Boosts
		if boostsString ~= nil and boostsString ~= "" then
			local boosts = StringHelpers.Split(boostsString, ";")
			for i,boostStat in pairs(boosts) do
				if boostStat ~= nil and boostStat ~= "" then
					local boostWeaponStat = GameHelpers.Ext.CreateWeaponTable(boostStat, level, attribute, weaponType, nil, true, damage)
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
				skill[k] = Ext.StatGetAttribute(skillName, k)
				if not hasValidEntry and skill[k] ~= nil then
					hasValidEntry = true
				end
			end
		else
			if _EXTVERSION >= 56 then
				local stat = Ext.GetStat(skillName)
				if stat then
					hasValidEntry = true
					for k,_ in pairs(_SkillAttributes) do
						skill[k] = stat[k]
					end
				end
			else
				for k,_ in pairs(_SkillAttributes) do
					skill[k] = Ext.StatGetAttribute(skillName, k)
					if not hasValidEntry and skill[k] ~= nil then
						hasValidEntry = true
					end
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
					local boostStat = Ext.StatGetAttribute(boost.BoostName, attribute)
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
			TemplateName = projectile.RootTemplate.TemplateName,
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
						obj = Ext.GetItem(objId)
					elseif meta == "CDivinityStats_Item" then
						obj = Ext.GetItem(objId).Stats
					end
				end
				if obj ~= nil then
					local b,result = pcall(obj[k], obj, ...)
					if b then
						return result
					else
						Ext.PrintError(result)
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

function GameHelpers.Ext.CreateItemTable(item)
	local itemTable = {}
	if type(item) == "string" then
		item = Ext.GetItem(item)
		if item then
			if Ext.IsServer() then
				local refTable = DebugHelpers.userDataProps["esv::Item"]
				copyValuesFromRef(itemTable, item, refTable, item.MyGuid)
			else
				local refTable = DebugHelpers.userDataProps["ecl::Item"]
				copyValuesFromRef(itemTable, item, refTable, item.NetID)
			end
		end
	end
	return itemTable
end


function GameHelpers.Ext.ObjectIsStatItem(obj)
	if type(obj) == "userdata" then
		local meta = getmetatable(obj)
		return meta == Data.ExtenderClass.StatItem or meta == Data.ExtenderClass.StatItemArmor
	end
	return false
end

function GameHelpers.Ext.ObjectIsItem(obj)
	local t = type(obj)
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

---@param obj EsvGameObject|EclGameObject|UUID
function GameHelpers.Ext.ObjectIsCharacter(obj)
	local t = type(obj)
	if t == "userdata" then
		local meta = getmetatable(obj)
		return meta == Data.ExtenderClass.EsvCharacter or meta == Data.ExtenderClass.EclCharacter
	elseif t == "string" or t == "number" then
		if obj == StringHelpers.NULL_UUID then
			return false
		end
		if not isClient and Ext.OsirisIsCallable() then
			return ObjectIsCharacter(obj) == 1
		end
	end
	if t == "string" or t == "number" then
		local char = GameHelpers.GetCharacter(obj)
		if char then
			return true,char
		end
	end
	return false
end

function GameHelpers.Ext.ObjectIsStatCharacter(obj)
	if type(obj) == "userdata" then
		return getmetatable(obj) == Data.ExtenderClass.StatCharacter
	end
	return false
end

---@param obj EsvItem|EclItem|StatItem
---@return string
function GameHelpers.Ext.GetItemStatName(obj)
	local t = type(obj)
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