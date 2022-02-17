if GameHelpers.Stats == nil then
	GameHelpers.Stats = {}
end

local isClient = Ext.IsClient()

--- @param stat string
--- @param match string
--- @return boolean
function GameHelpers.Stats.HasParent(stat, match)
	local parent = Ext.StatGetAttribute(stat, "Using")
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
	local parent = Ext.StatGetAttribute(stat, "Using")
	if parent ~= nil and parent ~= "" then
		if parent == findParent then
			return Ext.StatGetAttribute(stat, attribute) == Ext.StatGetAttribute(parent, attribute)
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

function GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, attribute)
	---@type StatEntrySkillData
	local stat = nil
	local t = type(statName)
	if t == "string" then
		stat = Ext.GetStat(statName)
	elseif t == "userdata" then
		stat = statName
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
---@return StatProperty[]
function GameHelpers.Stats.GetSkillProperties(statName)
	return GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, "SkillProperties") or {}
end

---@param statName string
---@return StatProperty[]
function GameHelpers.Stats.GetExtraProperties(statName)
	return GameHelpers.Stats.GetCurrentOrInheritedProperty(statName, "ExtraProperties") or {}
end

---Returns true if the skill applies a HEAL status.
---@param skillId string
---@param healTypes HealType[] If set, will return true only if the applied statuses matches a provided healing type.
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
						local healType = Ext.StatGetAttribute(v.Action, "HealStat")
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

local meleeTypes = {"Sword", "Club", "Axe", "Staff", "Knife", "Spear"}
local rangeTypes = {"Bow", "Crossbow", "Wand", "Arrow", "Rifle"}

local HasStatValue = function (character, req, param, b)
	local current = character.Stats[req]
	if type(current) == "boolean" then
		return current ~= b
	else
		return (current >= param) ~= b
	end
end

---@type table<string, fun(character:EclCharacter, req:string, param:string, b:boolean):boolean>
local RequirementFunctions = {
	--None = HasStatValue,
	Level = HasStatValue,
	Strength = HasStatValue,
	Finesse = HasStatValue,
	Intelligence = HasStatValue,
	Constitution = HasStatValue,
	Memory = HasStatValue,
	Wits = HasStatValue,
	WarriorLore = HasStatValue,
	RangerLore = HasStatValue,
	RogueLore = HasStatValue,
	SingleHanded = HasStatValue,
	TwoHanded = HasStatValue,
	PainReflection = HasStatValue,
	Ranged = HasStatValue,
	Shield = HasStatValue,
	Reflexes = HasStatValue,
	PhysicalArmorMastery = HasStatValue,
	MagicArmorMastery = HasStatValue,
	Vitality = HasStatValue,
	Sourcery = HasStatValue,
	Telekinesis = HasStatValue,
	FireSpecialist = HasStatValue,
	WaterSpecialist = HasStatValue,
	AirSpecialist = HasStatValue,
	EarthSpecialist = HasStatValue,
	Necromancy = HasStatValue,
	Summoning = HasStatValue,
	Polymorph = HasStatValue,
	Repair = HasStatValue,
	Sneaking = HasStatValue,
	Pickpocket = HasStatValue,
	Thievery = HasStatValue,
	Loremaster = HasStatValue,
	Crafting = HasStatValue,
	Barter = HasStatValue,
	Charm = HasStatValue,
	Intimidate = HasStatValue,
	Reason = HasStatValue,
	Persuasion = HasStatValue,
	Leadership = HasStatValue,
	Luck = HasStatValue,
	DualWielding = HasStatValue,
	Wand = HasStatValue,
	Perseverance = HasStatValue,
	TALENT_ItemMovement = HasStatValue,
	TALENT_ItemCreation = HasStatValue,
	TALENT_Flanking = HasStatValue,
	TALENT_AttackOfOpportunity = HasStatValue,
	TALENT_Backstab = HasStatValue,
	TALENT_Trade = HasStatValue,
	TALENT_Lockpick = HasStatValue,
	TALENT_ChanceToHitRanged = HasStatValue,
	TALENT_ChanceToHitMelee = HasStatValue,
	TALENT_Damage = HasStatValue,
	TALENT_ActionPoints = HasStatValue,
	TALENT_ActionPoints2 = HasStatValue,
	TALENT_Criticals = HasStatValue,
	TALENT_IncreasedArmor = HasStatValue,
	TALENT_Sight = HasStatValue,
	TALENT_ResistFear = HasStatValue,
	TALENT_ResistKnockdown = HasStatValue,
	TALENT_ResistStun = HasStatValue,
	TALENT_ResistPoison = HasStatValue,
	TALENT_ResistSilence = HasStatValue,
	TALENT_ResistDead = HasStatValue,
	TALENT_Carry = HasStatValue,
	TALENT_Kinetics = HasStatValue,
	TALENT_Repair = HasStatValue,
	TALENT_ExpGain = HasStatValue,
	TALENT_ExtraStatPoints = HasStatValue,
	TALENT_ExtraSkillPoints = HasStatValue,
	TALENT_Durability = HasStatValue,
	TALENT_Awareness = HasStatValue,
	TALENT_Vitality = HasStatValue,
	TALENT_FireSpells = HasStatValue,
	TALENT_WaterSpells = HasStatValue,
	TALENT_AirSpells = HasStatValue,
	TALENT_EarthSpells = HasStatValue,
	TALENT_Charm = HasStatValue,
	TALENT_Intimidate = HasStatValue,
	TALENT_Reason = HasStatValue,
	TALENT_Luck = HasStatValue,
	TALENT_Initiative = HasStatValue,
	TALENT_InventoryAccess = HasStatValue,
	TALENT_AvoidDetection = HasStatValue,
	TALENT_AnimalEmpathy = HasStatValue,
	TALENT_Escapist = HasStatValue,
	TALENT_StandYourGround = HasStatValue,
	TALENT_SurpriseAttack = HasStatValue,
	TALENT_LightStep = HasStatValue,
	TALENT_ResurrectToFullHealth = HasStatValue,
	TALENT_Scientist = HasStatValue,
	TALENT_Raistlin = HasStatValue,
	TALENT_MrKnowItAll = HasStatValue,
	TALENT_WhatARush = HasStatValue,
	TALENT_FaroutDude = HasStatValue,
	TALENT_Leech = HasStatValue,
	TALENT_ElementalAffinity = HasStatValue,
	TALENT_FiveStarRestaurant = HasStatValue,
	TALENT_Bully = HasStatValue,
	TALENT_ElementalRanger = HasStatValue,
	TALENT_LightningRod = HasStatValue,
	TALENT_Politician = HasStatValue,
	TALENT_WeatherProof = HasStatValue,
	TALENT_LoneWolf = HasStatValue,
	TALENT_Zombie = HasStatValue,
	TALENT_Demon = HasStatValue,
	TALENT_IceKing = HasStatValue,
	TALENT_Courageous = HasStatValue,
	TALENT_GoldenMage = HasStatValue,
	TALENT_WalkItOff = HasStatValue,
	TALENT_FolkDancer = HasStatValue,
	TALENT_SpillNoBlood = HasStatValue,
	TALENT_Stench = HasStatValue,
	TALENT_Kickstarter = HasStatValue,
	TALENT_WarriorLoreNaturalArmor = HasStatValue,
	TALENT_WarriorLoreNaturalHealth = HasStatValue,
	TALENT_WarriorLoreNaturalResistance = HasStatValue,
	TALENT_RangerLoreArrowRecover = HasStatValue,
	TALENT_RangerLoreEvasionBonus = HasStatValue,
	TALENT_RangerLoreRangedAPBonus = HasStatValue,
	TALENT_RogueLoreDaggerAPBonus = HasStatValue,
	TALENT_RogueLoreDaggerBackStab = HasStatValue,
	TALENT_RogueLoreMovementBonus = HasStatValue,
	TALENT_RogueLoreHoldResistance = HasStatValue,
	TALENT_NoAttackOfOpportunity = HasStatValue,
	TALENT_WarriorLoreGrenadeRange = HasStatValue,
	TALENT_RogueLoreGrenadePrecision = HasStatValue,
	TALENT_ExtraWandCharge = HasStatValue,
	TALENT_DualWieldingDodging = HasStatValue,
	TALENT_Human_Civil = HasStatValue,
	TALENT_Human_Inventive = HasStatValue,
	TALENT_Dwarf_Sneaking = HasStatValue,
	TALENT_Dwarf_Sturdy = HasStatValue,
	TALENT_Elf_CorpseEater = HasStatValue,
	TALENT_Elf_Lore = HasStatValue,
	TALENT_Lizard_Persuasion = HasStatValue,
	TALENT_Lizard_Resistance = HasStatValue,
	TALENT_Perfectionist = HasStatValue,
	TALENT_Executioner = HasStatValue,
	TALENT_QuickStep = HasStatValue,
	TALENT_ViolentMagic = HasStatValue,
	TALENT_Memory = HasStatValue,
	TALENT_LivingArmor = HasStatValue,
	TALENT_Torturer = HasStatValue,
	TALENT_Ambidextrous = HasStatValue,
	TALENT_Unstable = HasStatValue,
	TALENT_Sourcerer = HasStatValue,
	-- TRAIT_Forgiving = HasStatValue,
	-- TRAIT_Vindictive = HasStatValue,
	-- TRAIT_Bold = HasStatValue,
	-- TRAIT_Timid = HasStatValue,
	-- TRAIT_Altruistic = HasStatValue,
	-- TRAIT_Egotistical = HasStatValue,
	-- TRAIT_Independent = HasStatValue,
	-- TRAIT_Obedient = HasStatValue,
	-- TRAIT_Pragmatic = HasStatValue,
	-- TRAIT_Romantic = HasStatValue,
	-- TRAIT_Spiritual = HasStatValue,
	-- TRAIT_Materialistic = HasStatValue,
	-- TRAIT_Righteous = HasStatValue,
	-- TRAIT_Renegade = HasStatValue,
	-- TRAIT_Blunt = HasStatValue,
	-- TRAIT_Considerate = HasStatValue,
	-- TRAIT_Compassionate = HasStatValue,
	-- TRAIT_Heartless = HasStatValue,
	Combat = function (character, req, param, b)
		local isInCombat = character:GetStatus("COMBAT") ~= nil
		return isInCombat ~= b
	end,
	-- MinKarma = HasStatValue,
	-- MaxKarma = HasStatValue,
	---@param character EclCharacter
	Immobile = function (character, req, param, b)
		local totalMoveRange = 0
		local totalMoveSpeedBoost = 0
		--for i,v in pairs(character.Stats.DynamicStats) do
		local length = #character.Stats.DynamicStats
		for i=1,length do
			local v = character.Stats.DynamicStats[i]
			totalMoveRange = totalMoveRange + v.Movement
			totalMoveSpeedBoost = totalMoveSpeedBoost + v.MovementSpeedBoost
		end
		if totalMoveSpeedBoost == 0 then
			totalMoveSpeedBoost = 1
		end
		local isImmobile = (totalMoveRange * totalMoveSpeedBoost) <= 0
		return isImmobile ~= b
	end,
	Tag = function (character, req, param, b)
		return character:HasTag(param) ~= b
	end,
}

---@param character EsvCharacter|EclCharacter
---@param statId string A skill or item stat.
---@return boolean
function GameHelpers.Stats.CharacterHasRequirements(character, statId)
	local stat = Ext.GetStat(statId)
	local isInCombat = character:GetStatus("COMBAT") ~= nil
	if stat and stat.Requirements then
		for _,req in pairs(stat.Requirements) do
			if req.Requirement == "Combat" then
				if isInCombat == req.Not then
					return false
				end
			else
				local callback = RequirementFunctions[req.Requirement]
				if callback then
					local result = callback(character, req.Requirement, req.Param, req.Not)
					if result == false then
						return false
					end
				end
			end
		end

		if GameHelpers.Stats.IsStatType(statId, "SkillData") then
			local items = {character.Stats.MainWeapon, character.Stats.OffHandWeapon}
            if stat.Requirement == Data.SkillRequirement.MeleeWeapon then
                if not GameHelpers.Item.IsWeaponType(items, meleeTypes) then
                    return false
                end
            elseif stat.Requirement == Data.SkillRequirement.DaggerWeapon then
                if not GameHelpers.Item.IsWeaponType(items, "Dagger") then
                    return false
                end
            elseif stat.Requirement == Data.SkillRequirement.ShieldWeapon then
                if character.Stats.OffHandWeapon == nil or character.Stats.OffHandWeapon.ItemType ~= "Shield" then
                    return false
                end
            elseif stat.Requirement == Data.SkillRequirement.StaffWeapon then
                if not GameHelpers.Item.IsWeaponType(items, "Staff") then
                    return false
                end
            elseif stat.Requirement == Data.SkillRequirement.RangedWeapon then
                if not GameHelpers.Item.IsWeaponType(items, rangeTypes) then
                    return false
                end
            elseif stat.Requirement == Data.SkillRequirement.ArrowWeapon then
                if not GameHelpers.Item.IsWeaponType(items, "Arrow") then
                    return false
                end
            elseif stat.Requirement == Data.SkillRequirement.RifleWeapon then
                if not GameHelpers.Item.IsWeaponType(items, "Rifle") then
                    return false
                end
            end
			local sourceCost = stat["Magic Cost"] or 0
			if sourceCost > 0 then
				if character.Stats.MPStart < sourceCost then
					return false
				end
			end
			local apCost = stat.ActionPoints or 0
			if apCost > 0 and isInCombat then
				if character.Stats.CurrentAP < apCost then
					return false
				end
			end

			--GM's don't have to deal with memorization requirements'
			if GameHelpers.Character.IsGameMaster(character) or not GameHelpers.Character.IsPlayer(character) then
				return true
			end

			for _,req in pairs(stat.MemorizationRequirements) do
				if req.Requirement == "Combat" then
					if isInCombat == req.Not then
						return false
					end
				else
					local callback = RequirementFunctions[req.Requirement]
					if callback then
						local result = callback(character, req.Requirement, req.Param, req.Not)
						if result == false then
							return false
						end
					end
				end
			end
		end
		
		return true
	end
	return false
end