local type = type
local pairs = pairs

---@alias LeaderLibProgressionDataRequirementType "Tag"|"Template"
---@alias LeaderLibProgressionDataTargetType "Character"|"Item"|"Any"

---@class LeaderLibProgressionDataBoostAttributeEntry
---@field Type "Attribute"
---@field Attribute FixedString
---@field Value SerializableValue

---@class LeaderLibProgressionDataBoostStatEntry
---@field Type "Stat"
---@field ID FixedString

---@alias LeaderLibProgressionDataAnyBoostEntry LeaderLibProgressionDataBoostAttributeEntry|LeaderLibProgressionDataBoostStatEntry

---@class LeaderLibProgressionDataBoostGroup
---@field Level integer
---@field Entries LeaderLibProgressionDataAnyBoostEntry[]

---@class LeaderLibProgressionDataRequirement
---@field Type LeaderLibProgressionDataRequirementType
---@field Value string

---@class LeaderLibProgressionDataParams
---@field TargetType LeaderLibProgressionDataTargetType The target object type to alter with permanent boosts. Defaults to "Item".
---@field Requirements LeaderLibProgressionDataRequirement[]
---@field Boosts table<integer, LeaderLibProgressionDataBoostGroup> Level -> Group
---@field CanAddBoostsCallback fun(self:LeaderLibProgressionData, target:CharacterObject|ItemObject, level:integer, owner:CharacterObject|ItemObject|nil):boolean A callback to manually control whether a target can receive boosts.

---@class LeaderLibProgressionData:LeaderLibProgressionDataParams
---@operator call:LeaderLibProgressionDataInstance
local ProgressionData = {
	Type = "ProgressionData"
}

setmetatable(ProgressionData, {
	__call = function (_, ...)
		return ProgressionData:Create(...)
	end
})

---@class LeaderLibProgressionDataInstance:LeaderLibProgressionData
---@field private Create function

---@param params LeaderLibProgressionDataParams
---@return LeaderLibProgressionDataInstance
function ProgressionData:Create(params)
	---@type LeaderLibProgressionDataParams
	local this = {
		Requirements = {},
		Boosts = {},
		TargetType = "Item",
	}
	if type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, {
		__index = ProgressionData
	})
	return this
end

---@param level integer
---@param statId FixedString
---@return LeaderLibProgressionDataInstance
function ProgressionData:AddStatBoost(level, statId)
	local group = self.Boosts[level]
	if group == nil then
		group = {Level = level, Entries = {}}
		self.Boosts[level] = group
	end
	group.Entries[#group.Entries+1] = {
		Type = "Stat",
		ID = statId
	}
	return self
end

---@param level integer
---@param statId FixedString
---@param modifierType ModifierListType
---@return LeaderLibProgressionDataInstance
function ProgressionData:AddDeltaModBoost(level, statId, modifierType)
	local group = self.Boosts[level]
	if group == nil then
		group = {Level = level, Entries = {}}
		self.Boosts[level] = group
	end
	local deltamod = Ext.Stats.DeltaMod.GetLegacy(statId, modifierType)
	if deltamod then
		for _,v in pairs(deltamod.Boosts) do
			group.Entries[#group.Entries+1] = {
				Type = "Stat",
				ID = v.Boost
			}
		end
	end
	return self
end

---@param level integer
---@param attribute FixedString
---@param value SerializableValue
---@return LeaderLibProgressionDataInstance
function ProgressionData:AddAttributeBoost(level, attribute, value)
	local group = self.Boosts[level]
	if group == nil then
		group = {Level = level, Entries = {}}
		self.Boosts[level] = group
	end
	group.Entries[#group.Entries+1] = {
		Type = "Attribute",
		Attribute = attribute,
		Value = value,
	}
	return self
end

---@param value string|string[]
---@param requirementType? LeaderLibProgressionDataRequirementType Defaults to "Tag" if not set.
---@return LeaderLibProgressionDataInstance
function ProgressionData:AddRequirement(value, requirementType)
	requirementType = requirementType or "Tag"
	local t = type(value)
	if t == "string" then
		self.Requirements[#self.Requirements+1] = {Type = requirementType, Value = value}
	elseif t == "table" then
		for _,v in pairs(value) do
			self.Requirements[#self.Requirements+1] = {Type = requirementType, Value = v}
		end
	else
		error(("[ProgressionData:AddRequirement(%s, %s)]Bad requirement value type: (%s)"):format(requirementType, value, t), 2)
	end
	return self
end

---@param target CharacterObject|ItemObject
---@param tags? table<string,boolean> Cached tags
---@param template? string
---@param owner? CharacterObject|ItemObject
---@return boolean
function ProgressionData:CanAddBoosts(target, tags, template, owner)
	local isItem = GameHelpers.Ext.ObjectIsItem(target)
	local level = target.Stats.Level
	if self.CanAddBoostsCallback then
		local b,result = xpcall(self.CanAddBoostsCallback, debug.traceback, self, target, level, owner)
		if not b then
			Ext.Utils.PrintError(result)
		elseif result ~= nil then
			return result == true
		end
	end
	if (isItem and self.TargetType == "Character") or (not isItem and self.TargetType == "Item") then
		return false
	end
	if not template then
		template = GameHelpers.GetTemplate(target, false, true) --[[@as string]]
	end
	if not tags then
		tags = GameHelpers.GetAllTags(target, true, true)
	end
	for i=1,#self.Requirements do
		local req = self.Requirements[i]
		if req.Type == "Tag" then
			if not tags[req.Value] then
				return false
			end
		elseif req.Type == "Template" and template ~= req.Value then
			return false
		end
	end
	return true
end

local _EquipmentBoostAttributesAttributeFlags = {
	["AcidImmunity"] = "boolean",
	["Arrow"] = "boolean",
	["BleedingImmunity"] = "boolean",
	["BlessedImmunity"] = "boolean",
	["BlindImmunity"] = "boolean",
	["BurnContact"] = "boolean",
	["BurnImmunity"] = "boolean",
	["CharmImmunity"] = "boolean",
	["ChickenImmunity"] = "boolean",
	["ChillContact"] = "boolean",
	["ChilledImmunity"] = "boolean",
	["ClairvoyantImmunity"] = "boolean",
	["CrippledImmunity"] = "boolean",
	["CursedImmunity"] = "boolean",
	["DecayingImmunity"] = "boolean",
	["DeflectProjectiles"] = "boolean",
	["DisarmedImmunity"] = "boolean",
	["DiseasedImmunity"] = "boolean",
	["DrunkImmunity"] = "boolean",
	["EnragedImmunity"] = "boolean",
	["EntangledContact"] = "boolean",
	["FearImmunity"] = "boolean",
	["Floating"] = "boolean",
	["FreezeContact"] = "boolean",
	["FreezeImmunity"] = "boolean",
	["Grounded"] = "boolean",
	["HastedImmunity"] = "boolean",
	["IgnoreClouds"] = "boolean",
	["IgnoreCursedOil"] = "boolean",
	["InfectiousDiseasedImmunity"] = "boolean",
	["InvisibilityImmunity"] = "boolean",
	["KnockdownImmunity"] = "boolean",
	["LootableWhenEquipped"] = "boolean",
	["LoseDurabilityOnCharacterHit"] = "boolean",
	["MadnessImmunity"] = "boolean",
	["MagicalSulfur"] = "boolean",
	["MuteImmunity"] = "boolean",
	["PetrifiedImmunity"] = "boolean",
	["PickpocketableWhenEquipped"] = "boolean",
	["PoisonContact"] = "boolean",
	["PoisonImmunity"] = "boolean",
	["ProtectFromSummon"] = "boolean",
	["RegeneratingImmunity"] = "boolean",
	["ShacklesOfPainImmunity"] = "boolean",
	["ShockedImmunity"] = "boolean",
	["SleepingImmunity"] = "boolean",
	["SlippingImmunity"] = "boolean",
	["SlowedImmunity"] = "boolean",
	["StunContact"] = "boolean",
	["StunImmunity"] = "boolean",
	["SuffocatingImmunity"] = "boolean",
	["TauntedImmunity"] = "boolean",
	["ThrownImmunity"] = "boolean",
	["Torch"] = "boolean",
	["Unbreakable"] = "boolean",
	["Unrepairable"] = "boolean",
	["Unstorable"] = "boolean",
	["WarmImmunity"] = "boolean",
	["WeakImmunity"] = "boolean",
	["WebImmunity"] = "boolean",
	["WetImmunity"] = "boolean",
}

local _EquipmentBoostTalentAttributes = {
	["TALENT_ActionPoints"] = "boolean",
	["TALENT_ActionPoints2"] = "boolean",
	["TALENT_AirSpells"] = "boolean",
	["TALENT_Ambidextrous"] = "boolean",
	["TALENT_AnimalEmpathy"] = "boolean",
	["TALENT_AttackOfOpportunity"] = "boolean",
	["TALENT_AvoidDetection"] = "boolean",
	["TALENT_Awareness"] = "boolean",
	["TALENT_Backstab"] = "boolean",
	["TALENT_BeastMaster"] = "boolean",
	["TALENT_Bully"] = "boolean",
	["TALENT_Carry"] = "boolean",
	["TALENT_ChanceToHitMelee"] = "boolean",
	["TALENT_ChanceToHitRanged"] = "boolean",
	["TALENT_Charm"] = "boolean",
	["TALENT_Courageous"] = "boolean",
	["TALENT_Criticals"] = "boolean",
	["TALENT_Damage"] = "boolean",
	["TALENT_DeathfogResistant"] = "boolean",
	["TALENT_Demon"] = "boolean",
	["TALENT_DualWieldingDodging"] = "boolean",
	["TALENT_Durability"] = "boolean",
	["TALENT_Dwarf_Sneaking"] = "boolean",
	["TALENT_Dwarf_Sturdy"] = "boolean",
	["TALENT_EarthSpells"] = "boolean",
	["TALENT_ElementalAffinity"] = "boolean",
	["TALENT_ElementalRanger"] = "boolean",
	["TALENT_Elementalist"] = "boolean",
	["TALENT_Elf_CorpseEating"] = "boolean",
	["TALENT_Elf_Lore"] = "boolean",
	["TALENT_Escapist"] = "boolean",
	["TALENT_Executioner"] = "boolean",
	["TALENT_ExpGain"] = "boolean",
	["TALENT_ExtraSkillPoints"] = "boolean",
	["TALENT_ExtraStatPoints"] = "boolean",
	["TALENT_FaroutDude"] = "boolean",
	["TALENT_FireSpells"] = "boolean",
	["TALENT_FiveStarRestaurant"] = "boolean",
	["TALENT_Flanking"] = "boolean",
	["TALENT_FolkDancer"] = "boolean",
	["TALENT_Gladiator"] = "boolean",
	["TALENT_GoldenMage"] = "boolean",
	["TALENT_GreedyVessel"] = "boolean",
	["TALENT_Haymaker"] = "boolean",
	["TALENT_Human_Civil"] = "boolean",
	["TALENT_Human_Inventive"] = "boolean",
	["TALENT_IceKing"] = "boolean",
	["TALENT_IncreasedArmor"] = "boolean",
	["TALENT_Indomitable"] = "boolean",
	["TALENT_Initiative"] = "boolean",
	["TALENT_Intimidate"] = "boolean",
	["TALENT_InventoryAccess"] = "boolean",
	["TALENT_ItemCreation"] = "boolean",
	["TALENT_ItemMovement"] = "boolean",
	["TALENT_Jitterbug"] = "boolean",
	["TALENT_Kickstarter"] = "boolean",
	["TALENT_Leech"] = "boolean",
	["TALENT_LightStep"] = "boolean",
	["TALENT_LightningRod"] = "boolean",
	["TALENT_LivingArmor"] = "boolean",
	["TALENT_Lizard_Persuasion"] = "boolean",
	["TALENT_Lizard_Resistance"] = "boolean",
	["TALENT_Lockpick"] = "boolean",
	["TALENT_LoneWolf"] = "boolean",
	["TALENT_Luck"] = "boolean",
	["TALENT_MagicCycles"] = "boolean",
	["TALENT_MasterThief"] = "boolean",
	["TALENT_Max"] = "boolean",
	["TALENT_Memory"] = "boolean",
	["TALENT_MrKnowItAll"] = "boolean",
	["TALENT_NaturalConductor"] = "boolean",
	["TALENT_NoAttackOfOpportunity"] = "boolean",
	["TALENT_None"] = "boolean",
	["TALENT_PainDrinker"] = "boolean",
	["TALENT_Perfectionist"] = "boolean",
	["TALENT_Politician"] = "boolean",
	["TALENT_Quest_GhostTree"] = "boolean",
	["TALENT_Quest_Rooted"] = "boolean",
	["TALENT_Quest_SpidersKiss_Int"] = "boolean",
	["TALENT_Quest_SpidersKiss_Null"] = "boolean",
	["TALENT_Quest_SpidersKiss_Per"] = "boolean",
	["TALENT_Quest_SpidersKiss_Str"] = "boolean",
	["TALENT_Quest_TradeSecrets"] = "boolean",
	["TALENT_QuickStep"] = "boolean",
	["TALENT_Rager"] = "boolean",
	["TALENT_Raistlin"] = "boolean",
	["TALENT_RangerLoreArrowRecover"] = "boolean",
	["TALENT_RangerLoreEvasionBonus"] = "boolean",
	["TALENT_RangerLoreRangedAPBonus"] = "boolean",
	["TALENT_Reason"] = "boolean",
	["TALENT_Repair"] = "boolean",
	["TALENT_ResistDead"] = "boolean",
	["TALENT_ResistFear"] = "boolean",
	["TALENT_ResistKnockdown"] = "boolean",
	["TALENT_ResistPoison"] = "boolean",
	["TALENT_ResistSilence"] = "boolean",
	["TALENT_ResistStun"] = "boolean",
	["TALENT_ResurrectExtraHealth"] = "boolean",
	["TALENT_ResurrectToFullHealth"] = "boolean",
	["TALENT_RogueLoreDaggerAPBonus"] = "boolean",
	["TALENT_RogueLoreDaggerBackStab"] = "boolean",
	["TALENT_RogueLoreGrenadePrecision"] = "boolean",
	["TALENT_RogueLoreHoldResistance"] = "boolean",
	["TALENT_RogueLoreMovementBonus"] = "boolean",
	["TALENT_Sadist"] = "boolean",
	["TALENT_Scientist"] = "boolean",
	["TALENT_Sight"] = "boolean",
	["TALENT_Soulcatcher"] = "boolean",
	["TALENT_Sourcerer"] = "boolean",
	["TALENT_SpillNoBlood"] = "boolean",
	["TALENT_StandYourGround"] = "boolean",
	["TALENT_Stench"] = "boolean",
	["TALENT_SurpriseAttack"] = "boolean",
	["TALENT_Throwing"] = "boolean",
	["TALENT_Torturer"] = "boolean",
	["TALENT_Trade"] = "boolean",
	["TALENT_Unstable"] = "boolean",
	["TALENT_ViolentMagic"] = "boolean",
	["TALENT_Vitality"] = "boolean",
	["TALENT_WalkItOff"] = "boolean",
	["TALENT_WandCharge"] = "boolean",
	["TALENT_WarriorLoreGrenadeRange"] = "boolean",
	["TALENT_WarriorLoreNaturalArmor"] = "boolean",
	["TALENT_WarriorLoreNaturalHealth"] = "boolean",
	["TALENT_WarriorLoreNaturalResistance"] = "boolean",
	["TALENT_WaterSpells"] = "boolean",
	["TALENT_WeatherProof"] = "boolean",
	["TALENT_WhatARush"] = "boolean",
	["TALENT_WildMag"] = "boolean",
	["TALENT_Zombie"] = "boolean",
}

local _EquipmentBoostAttributes = {
	--Bodybuilding = "Bodybuilding",
	--BoostName = "string",
	--Brewmaster = "Brewmaster",
	--Charm = "Charm",
	--Crafting = "Crafting",
	--CustomResistance = "number",
	--Intimidate = "Intimidate",
	--ItemColor = "ItemColor",
	--MagicArmorMastery = "MagicArmorMastery",
	--MaxAP = "MaxAP",
	--ModifierType = "string",
	--MovementSpeedBoost = "MovementSpeedBoost",
	--ObjectInstanceName = "string",
	--PhysicalArmorMastery = "PhysicalArmorMastery",
	--Pickpocket = "Pickpocket",
	--Reason = "Reason",
	--Reflexes = "Reflexes",
	--Runecrafting = "Runecrafting",
	--Sentinel = "number",
	--Shield = "Shield",
	--SourcePointsBoost = "SourcePointsBoost",
	--StartAP = "StartAP",
	--StatsType = "string",
	--Sulfurology = "Sulfurology",
	--Value = "Value",
	--VitalityBoost = "VitalityBoost",
	--VitalityMastery = "VitalityMastery",
	--Wand = "Wand",
	--Weight = "Weight",
	--Willpower = "Willpower",
	AccuracyBoost = "AccuracyBoost",
	AirSpecialist = "AirSpecialist",
	APRecovery = "APRecovery",
	Barter = "Barter",
	ChanceToHitBoost = "ChanceToHitBoost",
	ConstitutionBoost = "ConstitutionBoost",
	CriticalChance = "CriticalChance",
	DodgeBoost = "DodgeBoost",
	DualWielding = "DualWielding",
	Durability = "Durability",
	DurabilityDegradeSpeed = "DurabilityDegradeSpeed",
	EarthSpecialist = "EarthSpecialist",
	FinesseBoost = "FinesseBoost",
	FireSpecialist = "FireSpecialist",
	HearingBoost = "HearingBoost",
	Initiative = "Initiative",
	IntelligenceBoost = "IntelligenceBoost",
	Leadership = "Leadership",
	Loremaster = "Loremaster",
	Luck = "Luck",
	MaxSummons = "MaxSummons",
	MemoryBoost = "MemoryBoost",
	Movement = "Movement",
	Necromancy = "Necromancy",
	PainReflection = "PainReflection",
	Perseverance = "Perseverance",
	Persuasion = "Persuasion",
	Polymorph = "Polymorph",
	Ranged = "Ranged",
	RangerLore = "RangerLore",
	Reflection = "Reflection",
	Repair = "Repair",
	RogueLore = "RogueLore",
	RuneSlots = "RuneSlots",
	RuneSlots_V1 = "RuneSlots_V1",
	SightBoost = "SightBoost",
	SingleHanded = "SingleHanded",
	Skills = "Skills",
	Sneaking = "Sneaking",
	Sourcery = "Sourcery",
	StrengthBoost = "StrengthBoost",
	Summoning = "Summoning",
	Telekinesis = "Telekinesis",
	Thievery = "Thievery",
	TwoHanded = "TwoHanded",
	WarriorLore = "WarriorLore",
	WaterSpecialist = "WaterSpecialist",
	WitsBoost = "WitsBoost",
}

local _WeaponBoostAttributes = TableHelpers.AddOrUpdate({
	--DamageType = "Damage Type"
	--MinDamage = "number",
	--MaxDamage = "number",
	DamageBoost = "DamageBoost",
	DamageFromBase = "DamageFromBase",
	CriticalDamage = "CriticalDamage",
	WeaponRange = "WeaponRange",
	CleaveAngle = "CleaveAngle",
	CleavePercentage = "CleavePercentage",
	AttackAPCost = "AttackAPCost",
	--Projectile = "Projectile"
	LifeSteal = "LifeSteal",
}, _EquipmentBoostAttributes)

local _ShieldBoostAttributes = TableHelpers.AddOrUpdate({
	ArmorValue = "Armor Defense Value",
	ArmorBoost = "ArmorBoost",
	MagicArmorValue = "Magic Armor Value",
	MagicArmorBoost = "MagicArmorBoost",
	Blocking = "Blocking",
	--["CorrosiveResistance"] = "number",
	--["MagicResistance"] = "number",
	--["ShadowResistance"] = "number",
	AirResistance = "Air",
	EarthResistance = "Earth",
	FireResistance = "Fire",
	PhysicalResistance = "Physical",
	PiercingResistance = "Piercing",
	PoisonResistance = "Poison",
	WaterResistance = "Water",
}, _EquipmentBoostAttributes)

local _ArmorBoostAttributes = TableHelpers.AddOrUpdate({
	ArmorValue = "Armor Defense Value",
	ArmorBoost = "ArmorBoost",
	MagicArmorValue = "Magic Armor Value",
	MagicArmorBoost = "MagicArmorBoost",
	AirResistance = "Air",
	EarthResistance = "Earth",
	FireResistance = "Fire",
	PhysicalResistance = "Physical",
	PiercingResistance = "Piercing",
	PoisonResistance = "Poison",
	WaterResistance = "Water",
}, _EquipmentBoostAttributes)

local _BoostAttributes = {
	Weapon = _WeaponBoostAttributes,
	Shield = _ShieldBoostAttributes,
	Armor = _ArmorBoostAttributes,
}

---@param value any
local function _IsValueSet(value)
	local t = type(value)
	if t == "string" then
		return not StringHelpers.IsNullOrWhitespace(value) and value ~= "None" and value ~= "No"
	elseif t == "number" then
		return value ~= 0
	end
	return false
end

---@param k string
---@param v boolean
local function _GetSkillFromDictionary(k, v)
	return k
end

---@param target CharacterObject|ItemObject
---@return boolean
function ProgressionData:ApplyBoosts(target)
	local appliedBoosts = false
	local level = target.Stats.Level
	local permanentBoosts = target.Stats.DynamicStats[2]
	local attributes = _BoostAttributes[permanentBoosts.StatsType]
	local statAttributes = Data.StatAttributes[permanentBoosts.StatsType]
	local skills = {}
	for _,group in pairs(self.Boosts) do
		if level >= group.Level then
			for j=1,#group.Entries do
				local boost = group.Entries[j]
				if boost.Type == "Attribute" then
					if boost.Attribute == "Skills" then
						local ids = StringHelpers.Split(boost.Value, ";")
						for _,v in pairs(ids) do
							skills[v] = true
						end
					else
						permanentBoosts[boost.Attribute] = boost.Value
					end
					appliedBoosts = true
				elseif boost.Type == "Stat" then
					local stat = Ext.Stats.Get(boost.ID, level, false, true)
					if stat ~= nil then
						for boostAttribute,statAttribute in pairs(attributes) do
							local value = stat[statAttribute]
							if _IsValueSet(value) then
								if statAttribute == "Skills" then
									local ids = StringHelpers.Split(value, ";")
									for _,v in pairs(ids) do
										skills[v] = true
									end
								else
									permanentBoosts[boostAttribute] = value
								end
								appliedBoosts = true
							end
						end
					else
						fprint(LOGLEVEL.ERROR, "[ProgressionData:ApplyBoosts] Stat (%s) for progression boost was not found.", boost.ID)
					end
				end
			end
		end
	end
	local finalSkills = StringHelpers.Join(";", skills, nil, _GetSkillFromDictionary)
	if not StringHelpers.IsNullOrEmpty(finalSkills) then
		permanentBoosts.Skills = finalSkills
		appliedBoosts = true
	end
	return appliedBoosts
end

Classes.ProgressionData = ProgressionData