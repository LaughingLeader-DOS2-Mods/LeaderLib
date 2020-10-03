if GameHelpers.Ext == nil then
	GameHelpers.Ext = {}
end

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
---@param damageFromBaseBoost integer
---@return StatItem
function GameHelpers.Ext.CreateWeaponTable(stat,level,attribute,weaponType,damageFromBaseBoost,isBoostStat,baseWeaponDamage)
	local weapon = {}
	weapon.ItemType = "Weapon"
	weapon.Name = stat
	if attribute ~= nil then
		weapon.Requirements = {
			{
				Requirement = attribute,
				Param = 0,
				Not = false
			}
		}
	else
		weapon.Requirements = Ext.StatGetAttribute(stat, "Requirements")
	end
	local weaponStat = {Name = stat}
	for i,v in pairs(weaponStatAttributes) do
		weaponStat[v] = Ext.StatGetAttribute(stat, v)
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
	if not isBoostStat then
		local boostsString = Ext.StatGetAttribute(stat, "Boosts")
		if boostsString ~= nil and boostsString ~= "" then
			local boosts = StringHelpers.Split(boostsString, ";")
			for i,boostStat in pairs(boosts) do
				if boostStat ~= nil and boostStat ~= "" then
					local boostWeaponStat = CreateWeaponTable(boostStat, level, attribute, weaponType, nil, true, damage)
					if boostWeaponStat ~= nil then
						table.insert(weapon.DynamicStats, boostWeaponStat.DynamicStats[1])
					end
				end
			end
		end
	end
	return weapon
end

local skillAttributes = {
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

---@param skillName string
---@param useWeaponDamage boolean
---@return StatEntrySkillData
function GameHelpers.Ext.CreateSkillTable(skillName, useWeaponDamage)
	if skillName ~= nil and skillName ~= "" then
		local hasValidEntry = false
		---@type StatEntrySkillData
		local skill = {Name = skillName, AlwaysBackstab = false}
		for i,v in pairs(skillAttributes) do
			local val = Ext.StatGetAttribute(skillName, v)
			if val ~= nil then
				hasValidEntry = true
			end
			skill[v] = val
		end
		if not hasValidEntry then
			-- Skill doesn't exist?
			return nil
		end
		if useWeaponDamage == true then skill["UseWeaponDamage"] = "Yes" end
		if skill.SkillProperties ~= nil then
			for _,tbl in pairs(skill.SkillProperties) do
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