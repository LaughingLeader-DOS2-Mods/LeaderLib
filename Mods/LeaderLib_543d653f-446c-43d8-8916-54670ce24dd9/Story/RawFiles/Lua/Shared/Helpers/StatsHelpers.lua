if GameHelpers.Stats == nil then
	GameHelpers.Stats = {}
end

local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()
local _type = type

local _GetStatsManager = function ()
	if _EXTVERSION >= 59 then
		return Ext.Stats.GetStatsManager()
	end
	return nil
end

--- @param stat string
--- @param match string
--- @return boolean
function GameHelpers.Stats.HasParent(stat, match)
	local parent = GameHelpers.Stats.GetAttribute(stat, "Using")
	if parent ~= nil and parent ~= "" then
		if parent == match then
			return true
		else
			return GameHelpers.Stats.HasParent(parent, match)
		end
	end
	return false
end

--- @param stat string
--- @param findParent string
--- @param attribute string
--- @return boolean
function GameHelpers.Stats.HasParentAttributeValue(stat, findParent, attribute)
	local parent = GameHelpers.Stats.GetAttribute(stat, "Using")
	if parent ~= nil and parent ~= "" then
		if parent == findParent then
			return GameHelpers.Stats.GetAttribute(stat, attribute) == GameHelpers.Stats.GetAttribute(parent, attribute)
		else
			return GameHelpers.Stats.HasParentAttributeValue(parent, findParent, attribute)
		end
	end
	return false
end

local RuneAttributes = {
	"RuneEffectWeapon",
	"RuneEffectUpperbody",
	"RuneEffectAmulet",
}

---@class RuneBoostAttributes:table
---@field RuneEffectWeapon string
---@field RuneEffectUpperbody string
---@field RuneEffectAmulet string

---@class RuneBoostsTableResult:table
---@field Name string
---@field Boosts RuneBoostAttributes
---@field Slot integer

---@param item StatItem
---@return RuneBoostsTableResult[]
function GameHelpers.Stats.GetRuneBoosts(item)
	---@type RuneBoostsTableResult[]
	local boosts = {}
	if item ~= nil then
		for i=3,5,1 do
			local boost = item.DynamicStats[i]
			if boost ~= nil and boost.BoostName ~= "" then
				---@type RuneBoostsTableResult
				local runeEntry = {
					Name = boost.BoostName,
					Boosts = {},
					Slot = i - 3
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

---@param statName string
---@param attribute string
---@param stat AnyStatProperty|nil
function GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, attribute, stat)
	local stat = stat
	if stat == nil then
		local t = _type(statName)
		if t == "string" then
			stat = Ext.Stats.Get(statName, nil, false)
		elseif t == "userdata" then
			stat = statName
		end
	end
	if stat then
		if stat[attribute] ~= nil then
			return stat[attribute]
		else
			if not StringHelpers.IsNullOrEmpty(stat.Using) then
				return GameHelpers.Stats.GetCurrentOrInheritedProperty(stat.Using, attribute)
			end
		end
	end
	return nil
end

---@param statName string
---@return AnyStatProperty[]
function GameHelpers.Stats.GetSkillProperties(statName)
	return GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, "SkillProperties") or {}
end

---@param statName string
---@return AnyStatProperty[]
function GameHelpers.Stats.GetExtraProperties(statName)
	return GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, "ExtraProperties") or {}
end

---Returns true if the skill applies a HEAL status.
---@param skillId string
---@param healTypes? StatusHealType[] If set, will return true only if the applied statuses matches a provided healing type.
---@return boolean
function GameHelpers.Stats.IsHealingSkill(skillId, healTypes)
	local props = GameHelpers.Stats.GetSkillProperties(skillId)
	if props then
		for _,v in pairs(props) do
			if v.Type == "Status" then
				local statusType = GameHelpers.Status.GetStatusType(v.Action)
				if statusType == "HEAL" or statusType == "HEALING" then
					if not healTypes then
						return true
					else
						local healType = GameHelpers.Stats.GetAttribute(v.Action, "HealStat")
						if Common.TableHasValue(healTypes, healType) then
							return true
						end
					end
				end
			end
		end
	end
	return false
end

---Returns true if the string is an action "skill" (not actually a skill), such as sneaking or unsheathing.
---@param skill string
---@return boolean
function GameHelpers.Stats.IsAction(skill)
    local t = type(skill)
    if t == "table" then
        for _,v in pairs(skill) do
            if Data.ActionSkills[skill] then
                return true
            end
        end
    elseif t == "string" then
        return Data.ActionSkills[skill] ~= nil
    end
    return false
end

GameHelpers.Skill.IsAction = GameHelpers.Stats.IsAction

local meleeTypes = {"Sword", "Club", "Axe", "Staff", "Knife", "Spear"}
local rangeTypes = {"Bow", "Crossbow", "Wand", "Arrow", "Rifle"}

---@param character CharacterObject
---@param req string
---@param param string|integer
---@param b boolean
local function _HasTalent(character, req, param, b)
	local current = character.Stats[req]
	return current ~= b
end

---@param character CharacterObject
---@param req string
---@param param string|integer
---@param b boolean
local function _HasStatValue(character, req, param, b)
	local current = character.Stats[req]
	if _type(current) == "boolean" then
		return current ~= b
	else
		return (current >= param) ~= b
	end
end

---@param character CharacterObject
---@param req string
---@param param string
---@param b boolean
local function _PlayerHasTrait(character, req, param, b)
	local traitID = string.gsub(req, "TRAIT_", "")
	local traitValue = character.PlayerUpgrade.Traits[Data.Traits[traitID]]
	local current = traitValue == 1 and true or false
	return current ~= b
end

Vars.RequirementFunctions.Level = _HasStatValue
Vars.RequirementFunctions.Strength = _HasStatValue
Vars.RequirementFunctions.Finesse = _HasStatValue
Vars.RequirementFunctions.Intelligence = _HasStatValue
Vars.RequirementFunctions.Constitution = _HasStatValue
Vars.RequirementFunctions.Memory = _HasStatValue
Vars.RequirementFunctions.Wits = _HasStatValue
Vars.RequirementFunctions.WarriorLore = _HasStatValue
Vars.RequirementFunctions.RangerLore = _HasStatValue
Vars.RequirementFunctions.RogueLore = _HasStatValue
Vars.RequirementFunctions.SingleHanded = _HasStatValue
Vars.RequirementFunctions.TwoHanded = _HasStatValue
Vars.RequirementFunctions.PainReflection = _HasStatValue
Vars.RequirementFunctions.Ranged = _HasStatValue
Vars.RequirementFunctions.Shield = _HasStatValue
Vars.RequirementFunctions.Reflexes = _HasStatValue
Vars.RequirementFunctions.PhysicalArmorMastery = _HasStatValue
Vars.RequirementFunctions.MagicArmorMastery = _HasStatValue
Vars.RequirementFunctions.Vitality = _HasStatValue
Vars.RequirementFunctions.Sourcery = _HasStatValue
Vars.RequirementFunctions.Telekinesis = _HasStatValue
Vars.RequirementFunctions.FireSpecialist = _HasStatValue
Vars.RequirementFunctions.WaterSpecialist = _HasStatValue
Vars.RequirementFunctions.AirSpecialist = _HasStatValue
Vars.RequirementFunctions.EarthSpecialist = _HasStatValue
Vars.RequirementFunctions.Necromancy = _HasStatValue
Vars.RequirementFunctions.Summoning = _HasStatValue
Vars.RequirementFunctions.Polymorph = _HasStatValue
Vars.RequirementFunctions.Repair = _HasStatValue
Vars.RequirementFunctions.Sneaking = _HasStatValue
Vars.RequirementFunctions.Pickpocket = _HasStatValue
Vars.RequirementFunctions.Thievery = _HasStatValue
Vars.RequirementFunctions.Loremaster = _HasStatValue
Vars.RequirementFunctions.Crafting = _HasStatValue
Vars.RequirementFunctions.Barter = _HasStatValue
Vars.RequirementFunctions.Charm = _HasStatValue
Vars.RequirementFunctions.Intimidate = _HasStatValue
Vars.RequirementFunctions.Reason = _HasStatValue
Vars.RequirementFunctions.Persuasion = _HasStatValue
Vars.RequirementFunctions.Leadership = _HasStatValue
Vars.RequirementFunctions.Luck = _HasStatValue
Vars.RequirementFunctions.DualWielding = _HasStatValue
Vars.RequirementFunctions.Wand = _HasStatValue
Vars.RequirementFunctions.Perseverance = _HasStatValue
Vars.RequirementFunctions.TALENT_ItemMovement = _HasTalent
Vars.RequirementFunctions.TALENT_ItemCreation = _HasTalent
Vars.RequirementFunctions.TALENT_Flanking = _HasTalent
Vars.RequirementFunctions.TALENT_AttackOfOpportunity = _HasTalent
Vars.RequirementFunctions.TALENT_Backstab = _HasTalent
Vars.RequirementFunctions.TALENT_Trade = _HasTalent
Vars.RequirementFunctions.TALENT_Lockpick = _HasTalent
Vars.RequirementFunctions.TALENT_ChanceToHitRanged = _HasTalent
Vars.RequirementFunctions.TALENT_ChanceToHitMelee = _HasTalent
Vars.RequirementFunctions.TALENT_Damage = _HasTalent
Vars.RequirementFunctions.TALENT_ActionPoints = _HasTalent
Vars.RequirementFunctions.TALENT_ActionPoints2 = _HasTalent
Vars.RequirementFunctions.TALENT_Criticals = _HasTalent
Vars.RequirementFunctions.TALENT_IncreasedArmor = _HasTalent
Vars.RequirementFunctions.TALENT_Sight = _HasTalent
Vars.RequirementFunctions.TALENT_ResistFear = _HasTalent
Vars.RequirementFunctions.TALENT_ResistKnockdown = _HasTalent
Vars.RequirementFunctions.TALENT_ResistStun = _HasTalent
Vars.RequirementFunctions.TALENT_ResistPoison = _HasTalent
Vars.RequirementFunctions.TALENT_ResistSilence = _HasTalent
Vars.RequirementFunctions.TALENT_ResistDead = _HasTalent
Vars.RequirementFunctions.TALENT_Carry = _HasTalent
Vars.RequirementFunctions.TALENT_Kinetics = _HasTalent
Vars.RequirementFunctions.TALENT_Repair = _HasTalent
Vars.RequirementFunctions.TALENT_ExpGain = _HasTalent
Vars.RequirementFunctions.TALENT_ExtraStatPoints = _HasTalent
Vars.RequirementFunctions.TALENT_ExtraSkillPoints = _HasTalent
Vars.RequirementFunctions.TALENT_Durability = _HasTalent
Vars.RequirementFunctions.TALENT_Awareness = _HasTalent
Vars.RequirementFunctions.TALENT_Vitality = _HasTalent
Vars.RequirementFunctions.TALENT_FireSpells = _HasTalent
Vars.RequirementFunctions.TALENT_WaterSpells = _HasTalent
Vars.RequirementFunctions.TALENT_AirSpells = _HasTalent
Vars.RequirementFunctions.TALENT_EarthSpells = _HasTalent
Vars.RequirementFunctions.TALENT_Charm = _HasTalent
Vars.RequirementFunctions.TALENT_Intimidate = _HasTalent
Vars.RequirementFunctions.TALENT_Reason = _HasTalent
Vars.RequirementFunctions.TALENT_Luck = _HasTalent
Vars.RequirementFunctions.TALENT_Initiative = _HasTalent
Vars.RequirementFunctions.TALENT_InventoryAccess = _HasTalent
Vars.RequirementFunctions.TALENT_AvoidDetection = _HasTalent
Vars.RequirementFunctions.TALENT_AnimalEmpathy = _HasTalent
Vars.RequirementFunctions.TALENT_Escapist = _HasTalent
Vars.RequirementFunctions.TALENT_StandYourGround = _HasTalent
Vars.RequirementFunctions.TALENT_SurpriseAttack = _HasTalent
Vars.RequirementFunctions.TALENT_LightStep = _HasTalent
Vars.RequirementFunctions.TALENT_ResurrectToFullHealth = _HasTalent
Vars.RequirementFunctions.TALENT_Scientist = _HasTalent
Vars.RequirementFunctions.TALENT_Raistlin = _HasTalent
Vars.RequirementFunctions.TALENT_MrKnowItAll = _HasTalent
Vars.RequirementFunctions.TALENT_WhatARush = _HasTalent
Vars.RequirementFunctions.TALENT_FaroutDude = _HasTalent
Vars.RequirementFunctions.TALENT_Leech = _HasTalent
Vars.RequirementFunctions.TALENT_ElementalAffinity = _HasTalent
Vars.RequirementFunctions.TALENT_FiveStarRestaurant = _HasTalent
Vars.RequirementFunctions.TALENT_Bully = _HasTalent
Vars.RequirementFunctions.TALENT_ElementalRanger = _HasTalent
Vars.RequirementFunctions.TALENT_LightningRod = _HasTalent
Vars.RequirementFunctions.TALENT_Politician = _HasTalent
Vars.RequirementFunctions.TALENT_WeatherProof = _HasTalent
Vars.RequirementFunctions.TALENT_LoneWolf = _HasTalent
Vars.RequirementFunctions.TALENT_Zombie = _HasTalent
Vars.RequirementFunctions.TALENT_Demon = _HasTalent
Vars.RequirementFunctions.TALENT_IceKing = _HasTalent
Vars.RequirementFunctions.TALENT_Courageous = _HasTalent
Vars.RequirementFunctions.TALENT_GoldenMage = _HasTalent
Vars.RequirementFunctions.TALENT_WalkItOff = _HasTalent
Vars.RequirementFunctions.TALENT_FolkDancer = _HasTalent
Vars.RequirementFunctions.TALENT_SpillNoBlood = _HasTalent
Vars.RequirementFunctions.TALENT_Stench = _HasTalent
Vars.RequirementFunctions.TALENT_Kickstarter = _HasTalent
Vars.RequirementFunctions.TALENT_WarriorLoreNaturalArmor = _HasTalent
Vars.RequirementFunctions.TALENT_WarriorLoreNaturalHealth = _HasTalent
Vars.RequirementFunctions.TALENT_WarriorLoreNaturalResistance = _HasTalent
Vars.RequirementFunctions.TALENT_RangerLoreArrowRecover = _HasTalent
Vars.RequirementFunctions.TALENT_RangerLoreEvasionBonus = _HasTalent
Vars.RequirementFunctions.TALENT_RangerLoreRangedAPBonus = _HasTalent
Vars.RequirementFunctions.TALENT_RogueLoreDaggerAPBonus = _HasTalent
Vars.RequirementFunctions.TALENT_RogueLoreDaggerBackStab = _HasTalent
Vars.RequirementFunctions.TALENT_RogueLoreMovementBonus = _HasTalent
Vars.RequirementFunctions.TALENT_RogueLoreHoldResistance = _HasTalent
Vars.RequirementFunctions.TALENT_NoAttackOfOpportunity = _HasTalent
Vars.RequirementFunctions.TALENT_WarriorLoreGrenadeRange = _HasTalent
Vars.RequirementFunctions.TALENT_RogueLoreGrenadePrecision = _HasTalent
Vars.RequirementFunctions.TALENT_ExtraWandCharge = _HasTalent
Vars.RequirementFunctions.TALENT_DualWieldingDodging = _HasTalent
Vars.RequirementFunctions.TALENT_Human_Civil = _HasTalent
Vars.RequirementFunctions.TALENT_Human_Inventive = _HasTalent
Vars.RequirementFunctions.TALENT_Dwarf_Sneaking = _HasTalent
Vars.RequirementFunctions.TALENT_Dwarf_Sturdy = _HasTalent
Vars.RequirementFunctions.TALENT_Elf_CorpseEater = _HasTalent
Vars.RequirementFunctions.TALENT_Elf_Lore = _HasTalent
Vars.RequirementFunctions.TALENT_Lizard_Persuasion = _HasTalent
Vars.RequirementFunctions.TALENT_Lizard_Resistance = _HasTalent
Vars.RequirementFunctions.TALENT_Perfectionist = _HasTalent
Vars.RequirementFunctions.TALENT_Executioner = _HasTalent
Vars.RequirementFunctions.TALENT_QuickStep = _HasTalent
Vars.RequirementFunctions.TALENT_ViolentMagic = _HasTalent
Vars.RequirementFunctions.TALENT_Memory = _HasTalent
Vars.RequirementFunctions.TALENT_LivingArmor = _HasTalent
Vars.RequirementFunctions.TALENT_Torturer = _HasTalent
Vars.RequirementFunctions.TALENT_Ambidextrous = _HasTalent
Vars.RequirementFunctions.TALENT_Unstable = _HasTalent
Vars.RequirementFunctions.TALENT_Sourcerer = _HasTalent
Vars.RequirementFunctions.TRAIT_Forgiving = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Vindictive = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Bold = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Timid = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Altruistic = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Egotistical = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Independent = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Obedient = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Pragmatic = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Romantic = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Spiritual = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Materialistic = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Righteous = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Renegade = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Blunt = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Considerate = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Compassionate = _PlayerHasTrait
Vars.RequirementFunctions.TRAIT_Heartless = _PlayerHasTrait

---@type fun(character:CharacterObject, req:string, param:integer, b:boolean):boolean
Vars.RequirementFunctions.Combat = function (character, req, param, b)
	local isInCombat = character:GetStatus("COMBAT") ~= nil
	return isInCombat ~= b
end

---@type fun(character:CharacterObject, req:string, param:integer, b:boolean):boolean
Vars.RequirementFunctions.MinKarma = function (character, req, param, b)
	return character.Stats.Karma >= param
end

---@type fun(character:CharacterObject, req:string, param:integer, b:boolean):boolean
Vars.RequirementFunctions.MaxKarma = function (character, req, param, b)
	return character.Stats.Karma <= param
end

---@type fun(character:CharacterObject, req:string, param:string, b:boolean):boolean
Vars.RequirementFunctions.Immobile = function (character, req, param, b)
	return GameHelpers.Character.IsImmobile(character) ~= b
end

---@type fun(character:CharacterObject, req:string, param:string, b:boolean):boolean
Vars.RequirementFunctions.Tag = function (character, req, param, b)
	return character:HasTag(param) ~= b
end

---@alias CharacterHasRequirementsFailureReason string
---| "Combat" # Character not in combat
---| "AP" # Not enough ActionPoints (CurrentAP)
---| "SP" # Not enough Source Points (MPStart)
---| "SkillRequirement" # The required weapon type isn't equipped.
---| "Requirements" # One of the Requirements conditions failed (Tag, Ability/Attribute, etc)
---| "MemorizationRequirements" # One of the MemorizationRequirements conditions failed (Tag, Ability/Attribute, etc)

---@param char EsvCharacter|EclCharacter
---@param statId string|StatRequirement[] A skill/item stat, or the Requirements table itself.
---@return boolean hasRequirements
---@return CharacterHasRequirementsFailureReason|nil requirementsFailedReason # The initial reason the requirements aren't met.
function GameHelpers.Stats.CharacterHasRequirements(char, statId)
	local character = GameHelpers.GetCharacter(char, "EsvCharacter")
	fassert(character ~= nil, "Failed to get character from %s", char)
	local requirements = nil
	local stat = nil
	if type(statId) == "table" then
		requirements = statId
	else
		if GameHelpers.Stats.IsAction(statId) then
			return true
		end
		stat = Ext.Stats.Get(statId, nil, false) --[[@as StatEntrySkillData]]
		fassert(stat ~= nil, "Failed to get stat from %s", statId)
		if stat and stat.Requirements then
			requirements = stat.Requirements
		end
	end
	local isInCombat = character:GetStatus("COMBAT") ~= nil
	if requirements then
		for _,req in pairs(requirements) do
			if req.Requirement == "Combat" then
				if isInCombat == req.Not then
					return false,"Combat"
				end
			else
				local callback = Vars.RequirementFunctions[req.Requirement]
				if callback then
					local result = callback(character, req.Requirement, req.Param, req.Not == true)
					if result == false then
						return false,"Requirements"
					end
				end
			end
		end
	end

	if stat then
		if GameHelpers.Stats.IsStatType(statId, "SkillData") then
			---@cast stat StatEntrySkillData
			local items = {GameHelpers.Character.GetEquippedWeapons(character)}
			if stat.Requirement == Data.SkillRequirement.MeleeWeapon then
				if not GameHelpers.Item.IsWeaponType(items, meleeTypes) then
					return false,"SkillRequirement"
				end
			elseif stat.Requirement == Data.SkillRequirement.DaggerWeapon then
				if not GameHelpers.Item.IsWeaponType(items, "Dagger") then
					return false,"SkillRequirement"
				end
			elseif stat.Requirement == Data.SkillRequirement.ShieldWeapon then
				if items[2] == nil or items[2].Stats.ItemType ~= "Shield" then
					return false,"SkillRequirement"
				end
			elseif stat.Requirement == Data.SkillRequirement.StaffWeapon then
				if not GameHelpers.Item.IsWeaponType(items, "Staff") then
					return false,"SkillRequirement"
				end
			elseif stat.Requirement == Data.SkillRequirement.RangedWeapon then
				if not GameHelpers.Item.IsWeaponType(items, rangeTypes) then
					return false,"SkillRequirement"
				end
			elseif stat.Requirement == Data.SkillRequirement.ArrowWeapon then
				if not GameHelpers.Item.IsWeaponType(items, "Arrow") then
					return false,"SkillRequirement"
				end
			elseif stat.Requirement == Data.SkillRequirement.RifleWeapon then
				if not GameHelpers.Item.IsWeaponType(items, "Rifle") then
					return false,"SkillRequirement"
				end
			end

			local sourceCost = stat["Magic Cost"] or 0
			if sourceCost > 0 then
				if character.Stats.MPStart < sourceCost then
					return false,"SP"
				end
			end

			if isInCombat then
				local apCost = stat.ActionPoints or 0
				if apCost > 0 and character.Stats.CurrentAP < apCost then
					return false,"AP"
				end
			end

			--GM's don't have to deal with memorization requirements
			if GameHelpers.Character.IsGameMaster(character) or not GameHelpers.Character.IsPlayer(character) then
				return true
			end

			for _,req in pairs(stat.MemorizationRequirements) do
				if req.Requirement == "Combat" then
					if isInCombat == req.Not then
						return false,"Combat"
					end
				else
					local callback = Vars.RequirementFunctions[req.Requirement]
					if callback then
						local result = callback(character, req.Requirement, req.Param, req.Not)
						if result == false then
							return false,"MemorizationRequirements"
						end
					end
				end
			end
		elseif isInCombat and (GameHelpers.Stats.IsStatType(statId, "Object") or GameHelpers.Stats.IsStatType(statId, "Potion")) then
			---@cast stat StatEntryPotion
			local apCost = stat.UseAPCost or 0
			if apCost > 0 and character.Stats.CurrentAP < apCost then
				return false,"AP"
			end
		end
	end
	return true
end

local _MaxEnumCount = {
	["Penalty PreciseQualifier"] = 202,
	Qualifier = 12
}

---@param value number The amount from a stat, such as the PenaltyPreciseQualifier value.
---@return integer
function GameHelpers.Stats.GetRangedMappedValue(value, maxEnumCount)
	maxEnumCount = maxEnumCount or 202 -- Test value. 202 enum entries for PenaltyPreciseQualifier
	return (100 * value - 100) / (maxEnumCount - 2)
end

local _getEnumIndex = Ext.Stats.EnumLabelToIndex

---Get the scaled 
---@param value number The Penalty PreciseQualifier amount, such as -4 in Stats_Flesh_Sacrifice.
---@param level integer The level to scale the attribute to.
---@return integer
function GameHelpers.Stats.GetScaledAttribute(value, level)
	--Norbyte: note that for enumerations, the value is the enumeration index!
	local enumIndex = _getEnumIndex("Penalty PreciseQualifier", value)
	local rangeMappedValue = GameHelpers.Stats.GetRangedMappedValue(enumIndex, _MaxEnumCount["Penalty PreciseQualifier"])
	local gain = 2 * rangeMappedValue - 100
	local absGain = math.abs(gain)
	--0.75 by default, but the engine uses 1.0 of this key doesn't exist.
	local growth = GameHelpers.GetExtraData("AttributeBoostGrowth", 1.0)
	--math.sign basically
	local gainShift = (gain > 0 and 1) or (gain == 0 and 0) or -1
	local result = gainShift * math.ceil(((absGain/100) * level) * growth)
	return result
end

--Mods.LeaderLib.GameHelpers.Stats.GetScaledAttribute(-4, 1)

local _PotionWithTurnsPattern = "(.+),(%d+)"

---@class ParseStatsIdPotions.PotionResult:{ID:string, Turns:integer}

---Parses a status StatsId, returning the potion stat, or a table of potion stat if it's in the `Stat,Turns;` syntax.
---@param statsId string
---@return string|ParseStatsIdPotions.PotionResult[] potion Returns a single potion, or a table of potions with their ID and Turns specified.
---@return boolean isTable True if the result is a table of potions.
function GameHelpers.Stats.ParseStatsIdPotions(statsId)
	if string.find(statsId, ";") then
		local potions = {}
		for _,entry in pairs(StringHelpers.Split(statsId, ";")) do
			local _,_,potion,turns = string.find(entry, _PotionWithTurnsPattern)
			if potion then
				potions[#potions+1] = {ID=potion, Turns = tonumber(turns)}
			end
		end
		return potions,true
	elseif string.find(statsId, ",") then
		local _,_,potion,turns = string.find(statsId, _PotionWithTurnsPattern)
		if potion then
			return {{ID=potion, Turns = tonumber(turns)}},true
		end
	else
		return statsId,false
	end
end

---Returns the DisplayName (translated) or the DisplayNameRef.
---@param id string
---@param statType StatType|nil
---@param character CharacterParam|nil Optional character to use if this is an action skill (to determine sneak/sheathe text).
---@return string
function GameHelpers.Stats.GetDisplayName(id, statType, character)
	if _type(id) == "userdata" then
		if GameHelpers.Ext.TypeHasMember(id, "StatusId") then
			id = id.StatusId
		else
			id = id.Name
		end
	end
	if Data.ActionSkills[id] then
		if id == "ActionSkillSheathe" or id == "ActionSkillSneak" then
			if character == nil then
				if _ISCLIENT then
					character = Client:GetCharacter()
				elseif Ext.Osiris.IsCallable() then
					character = GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter())
				end
			end
			local tbl = LocalizedText.ActionSkills[id]
			if character then
				if id == "ActionSkillSheathe" then
					if character.FightMode or character:GetStatus("UNSHEATHED") then
						return tbl.On.Value
					else
						return tbl.Off.Value
					end
				elseif id == "ActionSkillSneak" then
					if character:GetStatus("SNEAKING") then
						return tbl.On.Value
					else
						return tbl.Off.Value
					end
				end
			else
				return tbl.Off.Value
			end
		else
			return LocalizedText.ActionSkills[id].Value
		end
	elseif Data.EngineStatus[id] then
		local name = LocalizedText.Status[id]
		if name then
			return name.Value
		end
	elseif not StringHelpers.IsNullOrEmpty(id) and GameHelpers.Stats.Exists(id, statType) then
		local stat = Ext.Stats.Get(id, nil, false)
		return GameHelpers.GetStringKeyText(stat.DisplayName, stat.DisplayNameRef)
	end
	return ""
end

---@overload fun(id:string):Module|nil
---Returns which mod a stat originates from.
---@param id string The stat ID
---@param asDisplayName boolean|nil Return the mod's display name.
---@param ignoreBaseMods boolean|nil Ignore base mods and return nil if matched - Shared, Shared_DOS, DivinityOrigins.
---@return string|nil
function GameHelpers.Stats.GetModInfo(id, asDisplayName, ignoreBaseMods)
	if GameHelpers.Stats.IsAction(id) then
		if ignoreBaseMods and asDisplayName then
			return nil
		end
		return "Shared"
	end
	local stat = Ext.Stats.Get(id, nil, false)
	if stat then
		local modGUID = stat.ModId
		if not StringHelpers.IsNullOrEmpty(modGUID) then
			local mod = Ext.Mod.GetMod(modGUID)
			if mod then
				if asDisplayName then
					if ignoreBaseMods and Vars.GetModInfoIgnoredMods[modGUID] then
						return nil
					end
					local name = GameHelpers.GetTranslatedStringValue(mod.Info.DisplayName, mod.Info.Name)
					return name
				end
				return mod
			end
		end
	end
	return nil
end

---@alias RacePresetColorType "Hair"|"Skin"|"Cloth"
---@alias _GameHelpers_Stats_GetRacePresetColorEntry {ID:integer, Value:integer, Index:integer, Name:string, Handle:string}

---@class _GameHelpers_Stats_GetAllRacePresetColorsResults
---@field Cloth table<string, _GameHelpers_Stats_GetRacePresetColorEntry>
---@field Hair table<string, _GameHelpers_Stats_GetRacePresetColorEntry>
---@field Skin table<string, _GameHelpers_Stats_GetRacePresetColorEntry>

---Get colors for a race preset in dictionary format.  
---@param raceName string
---@param colorType RacePresetColorType|nil Defaults to Skin if not specified.
---@return table<string, _GameHelpers_Stats_GetRacePresetColorEntry>
function GameHelpers.Stats.GetRacePresetColors(raceName, colorType)
	local colors = {}
	local ccStats = Ext.Stats.GetCharacterCreation()
	assert(ccStats ~= nil, "Ext.Stats.GetCharacterCreation() failed")
	colorType = colorType or "Skin"
	---@type CharacterCreationRaceDesc
	local raceData = nil
	for _,v in pairs(ccStats.RacePresets) do
		if v.RaceName == raceName then
			raceData = v
			break
		end
	end
	assert(raceData ~= nil, string.format("Failed to find race preset for name (%s)", raceName))
	local targetColors = raceData.SkinColors
	if colorType == "Cloth" then
		targetColors = raceData.ClothColors
	elseif colorType == "Hair" then
		targetColors = raceData.HairColors
	end
	for i,v in pairs(targetColors) do
		local colorName = GameHelpers.GetTranslatedStringValue(v.ColorName)
		local handle = v.ColorName.Handle.Handle
		local key = handle ~= StringHelpers.UNSET_HANDLE and handle or colorName
		colors[key] = {ID = v.ID, Value = v.Value, Index = i-1, Name = colorName, Handle = handle}
	end
	return colors
end

---Get all colors for a race preset in dictionary format.  
---@param raceName string
---@return _GameHelpers_Stats_GetAllRacePresetColorsResults
function GameHelpers.Stats.GetAllRacePresetColors(raceName)
	local colors = {
		Hair = {},
		Cloth = {},
		Skin = {}
	}
	local ccStats = Ext.Stats.GetCharacterCreation()
	assert(ccStats ~= nil, "Ext.Stats.GetCharacterCreation() failed")
	colorType = colorType or "Skin"
	---@type CharacterCreationRaceDesc
	local raceData = nil
	for _,v in pairs(ccStats.RacePresets) do
		if v.RaceName == raceName then
			raceData = v
			break
		end
	end
	assert(raceData ~= nil, string.format("Failed to find race preset for name (%s)", raceName))
	for i,v in pairs(raceData.SkinColors) do
		local colorName = GameHelpers.GetTranslatedStringValue(v.ColorName)
		local handle = v.ColorName.Handle.Handle
		local key = handle ~= StringHelpers.UNSET_HANDLE and handle or colorName
		colors.Skin[key] = {ID = v.ID, Value = v.Value, Index = i-1, Handle = handle, Name = colorName}
	end
	for i,v in pairs(raceData.ClothColors) do
		local colorName = GameHelpers.GetTranslatedStringValue(v.ColorName)
		local handle = v.ColorName.Handle.Handle
		local key = handle ~= StringHelpers.UNSET_HANDLE and handle or colorName
		colors.Cloth[key] = {ID = v.ID, Value = v.Value, Index = i-1, Handle = handle, Name = colorName}
	end
	for i,v in pairs(raceData.HairColors) do
		local colorName = GameHelpers.GetTranslatedStringValue(v.ColorName)
		local handle = v.ColorName.Handle.Handle
		local key = handle ~= StringHelpers.UNSET_HANDLE and handle or colorName
		colors.Hair[key] = {ID = v.ID, Value = v.Value, Index = i-1, Handle = handle, Name = colorName}
	end
	return colors
end

---Safe way to get a skill's ability.
---@param id string
---@return SkillAbility
function GameHelpers.Stats.GetSkillAbility(id)
	local stat = Ext.Stats.Get(id, nil, false)
	if stat then
		return stat.Ability
	end
	return ""
end

---@generic T:string|number|table|nil
---Safe way to get a stat's attribute. If the stat does not exist, the fallbackValue will be returned instead.
---@param id string
---@param attributeName string
---@param fallbackValue? T
---@param asReference? boolean Get the stat byRef.
---@return T
function GameHelpers.Stats.GetAttribute(id, attributeName, fallbackValue, asReference)
	local stat = Ext.Stats.Get(id, nil, false, asReference == true)
	if stat then
		local value = stat[attributeName]
		if value ~= nil then
			return value
		else
			return fallbackValue
		end
	end
	return fallbackValue
end

---@generic T:string|number|table
---Similar to GameHelpers.Stats.GetAttribute, but runs a function instead of the stat and attribute exists, for when you want to easily make logic run only if the stat exists. 
---@param id string
---@param attributeName string
---@param callback fun(stat:StatEntryType, attribute:string, value:string|number|table):any
---@return boolean success
---@return any result
function GameHelpers.Stats.TryGetAttribute(id, attributeName, callback)
	local stat = Ext.Stats.Get(id, nil, false)
	if stat then
		local value = stat[attributeName]
		if value ~= nil then
			local b,result = xpcall(callback, debug.traceback, stat, attributeName, value)
			if not b then
				Ext.Utils.PrintError(result)
			else
				return true,result
			end
		end
	end
	return false,nil
end

---@param statType ModifierListType
---@param attribute string
---@param sm? StatsRPGStats
---@return boolean
function GameHelpers.Stats.StatTypeHasAttribute(statType, attribute, sm)
	if _EXTVERSION < 59 then return false end
	if not sm then
		sm = Ext.Stats.GetStatsManager()
	end
	if sm then
		local modifier = sm.ModifierLists:GetByName(statType)
		if modifier and modifier.Attributes:GetByName(attribute) ~= nil then
			return true
		end
	end
	return false
end

local _DamageTypeToResPen = {
	Physical = "PhysicalResistancePenetration",
	Piercing = "PiercingResistancePenetration",
	Corrosive = "CorrosiveResistancePenetration",
	Magic = "MagicResistancePenetration",
	Air = "AirResistancePenetration",
	Earth = "EarthResistancePenetration",
	Fire = "FireResistancePenetration",
	Poison = "PoisonResistancePenetration",
	Shadow = "ShadowResistancePenetration",
	Water = "WaterResistancePenetration",
}

---@param object AnyObjectInstanceType
local function _GetTaggedResistancePenetration(object)
	local results = {}
	local tags = GameHelpers.GetAllTags(object, true, true)
	for tag,_ in pairs(tags) do
		---@diagnostic disable-next-line
		local damageType,amount = GameHelpers.ParseResistancePenetrationTag(tag)
		if damageType then
			if results[damageType] == nil then
				results[damageType] = 0
			end
			results[damageType] = results[damageType] + amount
		end
	end
	return results
end

---@class GameHelpersStatsGetResistancePenetrationOptions
---@field SkipTagCheck boolean Skip checking for the deprecated resistance pen tags when calculating the amount.
---@field SkipEquipmentCheck boolean Skip checking equipment stats when tallying up the total res pen.
local _DefaultGameHelpersStatsGetResistancePenetrationOptions = {
	SkipTagCheck = false,
	SkipEquipmentCheck = false,
}

---@param character EsvCharacter
---@param attribute string
---@param sm StatsRPGStats
---@return integer
local function _GetCharacterBoostAmount(character, attribute, sm)
	local amount = 0
	for i=2,#character.Stats.DynamicStats do
		local entry = character.Stats.DynamicStats[i]
		---TODO evaluate boost conditions?
		if entry and not StringHelpers.IsNullOrEmpty(entry.BonusWeapon) then
			amount = amount + GameHelpers.Stats.GetAttribute(entry.BonusWeapon, attribute, 0)
		end
	end
	for _,status in pairs(character:GetStatusObjects()) do
		---@cast status EsvStatusConsumeBase
		if GameHelpers.Ext.TypeHasMember(status, "StatsIds") then
			for _,v in pairs(status.StatsIds) do
				amount = amount + (GameHelpers.Stats.GetAttribute(v.StatsId, attribute, 0) * status.StatsMultiplier)
			end
		end
	end
	return amount
end

---@param item EsvItem
---@param attribute string
---@param sm StatsRPGStats
---@return integer
local function _GetItemBoostAmount(item, attribute, sm)
	local amount = 0
	local statType = item.Stats.ItemType
	local _baseStatBoosts = {}
	if GameHelpers.Stats.StatTypeHasAttribute(statType, "Boosts", sm) then
		local boosts = StringHelpers.Split(item.Stats.StatsEntry.Boosts, ";")
		for _,boostName in pairs(boosts) do
			if not StringHelpers.IsNullOrEmpty(boostName) and GameHelpers.Stats.IsStatType(boostName, statType) then
				_baseStatBoosts[boostName] = true
				amount = amount + GameHelpers.Stats.GetAttribute(boostName, attribute, 0)
			end
		end
	end
	for i=2,#item.Stats.DynamicStats do
		local entry = item.Stats.DynamicStats[i]
		if entry and not StringHelpers.IsNullOrEmpty(entry.BoostName) and not _baseStatBoosts[entry.BoostName] then
			if GameHelpers.Stats.IsStatType(entry.BoostName, statType) then
				amount = amount + GameHelpers.Stats.GetAttribute(entry.BoostName, attribute, 0)
			end
		end
	end
	return amount
end

---Get the total amount of resistance penetration for a character or item.  
---This is a custom attribute added by LeaderLib (i.e. `FireResistancePenetration`).  
---@overload fun(object:ObjectParam):table<DamageType, integer>
---@overload fun(object:ObjectParam, damageType:DamageType):integer
---@param object ObjectParam
---@param damageType DamageType Get the amount for a specific damage type.
---@param opts GameHelpersStatsGetResistancePenetrationOptions
---@param statsManager? StatsRPGStats
---@return table<DamageType, integer>
function GameHelpers.Stats.GetResistancePenetration(object, damageType, opts, statsManager)
	local options = TableHelpers.SetDefaultOptions(opts, _DefaultGameHelpersStatsGetResistancePenetrationOptions)
	local sm = statsManager or _GetStatsManager()
	object = GameHelpers.TryGetObject(object)
	if not object then
		return damageType and 0 or {}
	end
	local taggedPen = not options.SkipTagCheck and _GetTaggedResistancePenetration(object) or {}
	local isCharacter = GameHelpers.Ext.ObjectIsCharacter(object)
	if damageType then
		local attribute = _DamageTypeToResPen[damageType]
		local amount = (object.Stats[attribute] or 0)
		if not isCharacter then
			---@cast object EsvItem
			amount = amount + _GetItemBoostAmount(object, attribute, sm)
		else
			---@cast object EsvCharacter
			amount = amount + _GetCharacterBoostAmount(object, attribute, sm)
		end
		if not options.SkipEquipmentCheck and GameHelpers.Ext.ObjectIsCharacter(object) then
			for item in GameHelpers.Character.GetEquipment(object) do
				local itemPen = GameHelpers.Stats.GetResistancePenetration(item, damageType)
				amount = amount + itemPen
			end
		end
		return amount + (taggedPen[damageType] or 0)
	else
		local results = {}
		for attribute,dType in pairs(Data.ResistancePenetrationAttributes) do
			local amount = object.Stats[attribute] or 0
			if not isCharacter then
				---@cast object EsvItem
				amount = amount + _GetItemBoostAmount(object, attribute, sm)
			else
				---@cast object EsvCharacter
				amount = amount + _GetCharacterBoostAmount(object, attribute, sm)
			end
			if taggedPen[damageType] then
				amount = amount + taggedPen[damageType]
			end
			if amount > 0 then
				results[dType] = amount
			end
		end
		if isCharacter and not options.SkipEquipmentCheck then
			for item in GameHelpers.Character.GetEquipment(object) do
				local itemPen = GameHelpers.Stats.GetResistancePenetration(item, damageType, options, sm)
				for dType,amount in pairs(itemPen) do
					results[dType] = (results[dType] or 0) + amount
				end
			end
		end
		return results
	end
end