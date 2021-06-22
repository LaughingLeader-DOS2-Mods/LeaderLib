if GameHelpers.Status == nil then
	GameHelpers.Status = {}
end

local isClient = Ext.IsClient()

local StatusToType = {
	ACTIVE_DEFENSE = "ACTIVE_DEFENSE",
	ADRENALINE = "ADRENALINE",
	AOO = "AOO",
	BOOST = "BOOST",
	CHANNELING = "CHANNELING",
	CHARMED = "CHARMED",
	CLEAN = "CLEAN",
	CLIMBING = "CLIMBING",
	COMBAT = "COMBAT",
	COMBUSTION = "COMBUSTION",
	CONSTRAINED = "CONSTRAINED",
	CONSUME = "CONSUME",
	DAMAGE = "DAMAGE",
	DARK_AVENGER = "DARK_AVENGER",
	DECAYING_TOUCH = "DECAYING_TOUCH",
	DRAIN = "DRAIN",
	DYING = "DYING",
	EFFECT = "EFFECT",
	ENCUMBERED = "ENCUMBERED",
	EXPLODE = "EXPLODE",
	FLANKED = "FLANKED",
	FLOATING = "FLOATING",
	FORCE_MOVE = "FORCE_MOVE",
	HIT = "HIT",
	IDENTIFY = "IDENTIFY",
	INCAPACITATED = "INCAPACITATED",
	INFECTIOUS_DISEASED = "INFECTIOUS_DISEASED",
	INFUSED = "INFUSED",
	INSURFACE = "INSURFACE",
	LEADERSHIP = "LEADERSHIP",
	LINGERING_WOUNDS = "LINGERING_WOUNDS",
	LYING = "LYING",
	MATERIAL = "MATERIAL",
	OVERPOWER = "OVERPOWER",
	POLYMORPHED = "POLYMORPHED",
	REMORSE = "REMORSE",
	REPAIR = "REPAIR",
	ROTATE = "ROTATE",
	SHACKLES_OF_PAIN = "SHACKLES_OF_PAIN",
	SHACKLES_OF_PAIN_CASTER = "SHACKLES_OF_PAIN_CASTER",
	SITTING = "SITTING",
	SMELLY = "SMELLY",
	SNEAKING = "SNEAKING",
	SOURCE_MUTED = "SOURCE_MUTED",
	SPARK = "SPARK",
	SPIRIT = "SPIRIT",
	SPIRIT_VISION = "SPIRIT_VISION",
	STANCE = "STANCE",
	STORY_FROZEN = "STORY_FROZEN",
	SUMMONING = "SUMMONING",
	TELEPORT_FALLING = "TELEPORT_FALLING",
	THROWN = "THROWN",
	TUTORIAL_BED = "TUTORIAL_BED",
	UNHEALABLE = "UNHEALABLE",
	UNLOCK = "UNLOCK",
	UNSHEATHED = "UNSHEATHED",
	WIND_WALKER = "WIND_WALKER",
}

---@param statusId string
---@return string
function GameHelpers.Status.GetStatusType(statusId)
	if StatusToType[statusId] then
		return StatusToType[statusId]
	end
	if not isClient then
		return GetStatusType(statusId)
	elseif not Data.EngineStatus[statusId] then
		local stat = Ext.GetStat(statusId)
		if stat then
			return stat.StatusType
		end
	end
	return ""
end

local potionProperties = {
	--Hearing = true,
	--Reflection = true,
	AccuracyBoost = true,
	ActionPoints = true,
	AirResistance = true,
	AirSpecialist = true,
	APCostBoost = false, -- Higher = more AP cost, making this negative
	APMaximum = true,
	APRecovery = true,
	APStart = true,
	Armor = true,
	ArmorBoost = true,
	Barter = true,
	ChanceToHitBoost = true,
	Constitution = "Penalty PreciseQualifier",
	CriticalChance = true,
	DamageBoost = true,
	DodgeBoost = true,
	DualWielding = true,
	EarthResistance = true,
	EarthSpecialist = true,
	Finesse = "Penalty PreciseQualifier",
	FireResistance = true,
	FireSpecialist = true,
	Initiative = true,
	Intelligence = "Penalty PreciseQualifier",
	Leadership = true,
	LifeSteal = true,
	Loremaster = true,
	Luck = true,
	MagicArmor = true,
	MagicArmorBoost = true,
	MagicPoints = true,
	Memory = "Penalty PreciseQualifier",
	Movement = true,
	MovementSpeedBoost = true,
	Necromancy = true,
	PainReflection = true,
	Perseverance = true,
	Persuasion = true,
	PhysicalResistance = true,
	PiercingResistance = true,
	PoisonResistance = true,
	Polymorph = true,
	RangeBoost = true,
	Ranged = true,
	RangerLore = true,
	Repair = true,
	RogueLore = true,
	Sight = true,
	SingleHanded = true,
	Sneaking = true,
	Sourcery = true,
	SPCostBoost = false, -- Higher = more SP cost, making this negative
	Strength = "Penalty PreciseQualifier",
	Summoning = true,
	Telekinesis = true,
	Thievery = true,
	TwoHanded = true,
	Vitality = true,
	VitalityBoost = true,
	VitalityPercentage = true,
	WarriorLore = true,
	WaterResistance = true,
	WaterSpecialist = true,
	Wits = "Penalty PreciseQualifier",
}

---@param stat StatEntryPotion|table
local function IsHarmfulPotion(stat)
	for k,b in pairs(potionProperties) do
		local value = stat[k]
		local t = type(value)
		if t == "number" then
			if (b == true and value < 0) or (b == false and value > 0) then
				return true
			end
		elseif t == "string" then
			if value ~= "None" and string.find(b, "Qualifier") then
				local realValue = tonumber(value)
				if realValue and realValue < 0 then
					return true
				end
			end
		end
	end
	return false
end

local function IsHarmfulStatsId(statsId)
	if not StringHelpers.IsNullOrWhitespace(statsId) then
		if string.find(statsId, ";") then
			for m in string.gmatch(statsId, "[%a%d_]+,") do
				local statName = string.sub(m, 1, #m-1)
				local stat = Ext.GetStat(statName)
				if stat and IsHarmfulPotion(stat) then
					return true
				end
			end
		else
			local stat = Ext.GetStat(statsId)
			if stat and IsHarmfulPotion(stat) then
				return true
			end
		end
	end
	return false
end

---Checks if a potion has any negative attributes.
---@param stat string|StatEntryPotion|table
---@return boolean
function GameHelpers.Status.IsHarmfulPotion(stat)
	if type(stat) == "string" then
		return IsHarmfulStatsId(stat)
	else
		return IsHarmfulPotion(stat)
	end
end

---@param statusId string
---@param checkDamageEvent boolean|nil Checks the DamageEvent attribute, and returns false if it's "None".
---@return boolean
function GameHelpers.Status.StatusDealsDamage(statusId, checkDamageEvent)
	if Data.EngineStatus[statusId] then
		return false
	end
	if checkDamageEvent == true then
		local damageEvent = Ext.StatGetAttribute(statusId, "DamageEvent")
		if damageEvent == "None" then
			return false
		end
	end
	local damageStats = Ext.StatGetAttribute(statusId, "DamageStats")
	if not StringHelpers.IsNullOrWhitespace(damageStats) then
		---@type StatEntryWeapon
		local weapon = Ext.GetStat(damageStats)
		if weapon and weapon.DamageFromBase > 0 then
			return true
		end
	end
	return false
end

local harmfulStatusTypes = {
	--DAMAGE = true,
	--DAMAGE_ON_MOVE = true,
	CHARMED = true,
	CONSTRAINED = true,
	DECAYING_TOUCH = true,
	FLANKED = true,
	INCAPACITATED = true,
	INFECTIOUS_DISEASED = true,
	KNOCKED_DOWN = true,
	SHACKLES_OF_PAIN = true,
	SHACKLES_OF_PAIN_CASTER = true,
	UNHEALABLE = true,
}

---A status is harmful if it deals damage, is a specific type (KNOCKED_DOWN etc), or has negative potion attributes.
---@param statusId string
function GameHelpers.Status.IsHarmful(statusId)
	local statusType = GameHelpers.Status.GetStatusType(statusId)
	if harmfulStatusTypes[statusType] == true or ((statusType == "DAMAGE" or statusType == "DAMAGE_ON_MOVE") and GameHelpers.Status.StatusDealsDamage(statusId)) then
		return true
	elseif statusType ~= "EFFECT" and not Data.IgnoredStatus[statusId] then
		local statsId = Ext.StatGetAttribute(statusId, "StatsId")
		if not StringHelpers.IsNullOrWhitespace(statsId) and IsHarmfulStatsId(statsId) then
			return true
		end
	end
	return false
end

local beneficialStatusTypes = {
	ACTIVE_DEFENSE = true,
	ADRENALINE = true,
	BOOST = true,
	EXTRA_TURN = true,
	FLOATING = true,
	GUARDIAN_ANGEL = true,
	HEAL = true,
	HEAL_SHARING = true,
	HEAL_SHARING_CASTER = true,
	HEALING = true,
	INVISIBLE = true,
	LEADERSHIP = true,
	PLAY_DEAD = true,
	STANCE = true,
	WIND_WALKER = true,
}

---@param stat StatEntryPotion|table
local function IsBeneficialPotion(stat, ignoreItemPotions)
	if ignoreItemPotions == true and stat.IsFood == "Yes" or stat.IsConsumable == "Yes" then
		return false
	end
	for k,b in pairs(potionProperties) do
		local value = stat[k]
		local t = type(value)
		if t == "number" then
			if (b == true and value > 0) or (b == false and value < 0) then
				return true
			end
		elseif t == "string" then
			if value ~= "None" and string.find(b, "Qualifier") then
				local realValue = tonumber(value)
				if realValue and realValue > 0 then
					return true
				end
			end
		end
	end
	return false
end

local function IsBeneficialStatsId(statsId, ignoreItemPotions)
	if not StringHelpers.IsNullOrWhitespace(statsId) then
		if string.find(statsId, ";") then
			for m in string.gmatch(statsId, "[%a%d_]+,") do
				local statName = string.sub(m, 1, #m-1)
				local stat = Ext.GetStat(statName)
				if stat and IsBeneficialPotion(stat, ignoreItemPotions) then
					return true
				end
			end
		else
			local stat = Ext.GetStat(statsId)
			if stat and IsBeneficialPotion(stat, ignoreItemPotions) then
				return true
			end
		end
	end
	return false
end

---Checks if a potion has any negative attributes.
---@param stat string|StatEntryPotion|table
---@param ignoreItemPotions boolean|nil Ignore potions with IsFood or IsConsumable.
---@return boolean
function GameHelpers.Status.IsBeneficialPotion(stat, ignoreItemPotions)
	if type(stat) == "string" then
		return IsBeneficialStatsId(stat, ignoreItemPotions)
	else
		return IsBeneficialPotion(stat, ignoreItemPotions)
	end
end

---A status is beneficial if it grants bonuses or is a beneficial type (FLOATING, ACTIVE_DEFENSE, HEAL etc).
---@param statusId string
---@param ignoreItemPotions boolean|nil Ignore potions with IsFood or IsConsumable.
function GameHelpers.Status.IsBeneficial(statusId, ignoreItemPotions)
	local statusType = GameHelpers.Status.GetStatusType(statusId)
	if beneficialStatusTypes[statusType] == true then
		return true
	elseif statusType ~= "EFFECT" and not Data.IgnoredStatus[statusId] then
		local statsId = Ext.StatGetAttribute(statusId, "StatsId")
		if not StringHelpers.IsNullOrWhitespace(statsId) and IsBeneficialStatsId(statsId, ignoreItemPotions) then
			return true
		end
	end
	return false
end