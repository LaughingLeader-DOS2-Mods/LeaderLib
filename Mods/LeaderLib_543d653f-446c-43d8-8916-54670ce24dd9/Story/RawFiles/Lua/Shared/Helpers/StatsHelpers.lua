if GameHelpers.Stats == nil then
	GameHelpers.Stats = {}
end

local _ISCLIENT = Ext.IsClient()
local _type = type

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

local meleeTypes = {"Sword", "Club", "Axe", "Staff", "Knife", "Spear"}
local rangeTypes = {"Bow", "Crossbow", "Wand", "Arrow", "Rifle"}

local HasStatValue = function (character, req, param, b)
	local current = character.Stats[req]
	if _type(current) == "boolean" then
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
		return GameHelpers.Character.IsImmobile(character) ~= b
	end,
	Tag = function (character, req, param, b)
		return character:HasTag(param) ~= b
	end,
}

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
        return Data.ActionSkills[skill]
    end
    return false
end

GameHelpers.Skill.IsAction = GameHelpers.Stats.IsAction

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
				local callback = RequirementFunctions[req.Requirement]
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
					local callback = RequirementFunctions[req.Requirement]
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
		id = id.StatusId
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

---Get the total amount of resistance penetration for a character or item.  
---This is a custom attribute added by LeaderLib (i.e. `FireResistancePenetration`).  
---@overload fun(object:ObjectParam):table<DamageType, integer>
---@overload fun(object:ObjectParam, damageType:DamageType):integer
---@param object ObjectParam
---@param damageType DamageType Get the amount for a specific damage type.
---@param skipTagCheck boolean Skip checking for the deprecated resistance pen tags when calculating the amount.
---@return table<DamageType, integer>
function GameHelpers.Stats.GetResistancePenetration(object, damageType, skipTagCheck)
	object = GameHelpers.TryGetObject(object)
	if not object then
		return damageType and 0 or {}
	end
	local taggedPen = not skipTagCheck and _GetTaggedResistancePenetration(object) or {}
	if damageType then
		local attribute = _DamageTypeToResPen[damageType]
		return (object.Stats[attribute] or 0) + (taggedPen[damageType] or 0)
	else
		local results = {}
		for attribute,dType in pairs(Data.ResistancePenetrationAttributes) do
			local amount = object.Stats[attribute] or 0
			if taggedPen[damageType] then
				amount = amount + taggedPen[damageType]
			end
			if amount > 0 then
				results[dType] = amount
			end
		end
		return results
	end
end