if GameHelpers.Status == nil then
	GameHelpers.Status = {}
end

local isClient = Ext.IsClient()

local _statusIdToStatusType = {}
setmetatable(_statusIdToStatusType, {__index = Data.StatusToType})

---@private
GameHelpers.Status.Data = {
	StatusIdToStatusType = _statusIdToStatusType
}

---@param statusId string
---@return string
function GameHelpers.Status.GetStatusType(statusId)
	local statusType = _statusIdToStatusType[statusId]
	if statusType == nil then
		if not isClient and Ext.OsirisIsCallable() then
			if NRD_StatExists(statusId) then
				statusType = GetStatusType(statusId)
			end
		elseif not Data.EngineStatus[statusId] then
			local stat = Ext.GetStat(statusId)
			if stat then
				statusType = stat.StatusType
			end
		end
		_statusIdToStatusType[statusId] = statusType
	end
	return statusType
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
	--ADRENALINE = true,
	--BOOST = true,
	--EXTRA_TURN = true,
	FLOATING = true,
	GUARDIAN_ANGEL = true,
	HEAL = true,
	HEAL_SHARING = true,
	HEAL_SHARING_CASTER = true,
	HEALING = true,
	INVISIBLE = true,
	LEADERSHIP = true,
	--PLAY_DEAD = true,
	STANCE = true,
	WIND_WALKER = true,
}

local healingStatusTypes = {
	HEAL = true,
	HEAL_SHARING = true,
	HEAL_SHARING_CASTER = true,
	HEALING = true,
}

---@param stat StatEntryPotion|table
local function IsBeneficialPotion(stat, ignoreItemPotions)
	if ignoreItemPotions == true and stat.IsFood == "Yes" or stat.IsConsumable == "Yes" then
		return false
	end
	if not StringHelpers.IsNullOrWhitespace(stat.BonusWeapon) then
		return true
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
---@param ignoreStatusTypes table<string,boolean>|nil Status types to ignore.
function GameHelpers.Status.IsBeneficial(statusId, ignoreItemPotions, ignoreStatusTypes)
	local statusType = GameHelpers.Status.GetStatusType(statusId)
	if ignoreStatusTypes and ignoreStatusTypes[statusType] then
		return false
	end
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

---Returns true if the object has any of the given statuses.
---@param object EsvGameObject|UUID|NETID
---@param statusId string|string[]
---@param checkAll boolean If true, only return true if every given status is active.
---@return boolean
function GameHelpers.Status.IsActive(object, statusId, checkAll)
	local uuid = GameHelpers.GetUUID(object)
	if uuid then
		local t = type(statusId)
		if t == "table" then
			local totalActive = 0
			local total = 0
			for _,v in pairs(statusId) do
				total = total + 1
				if GameHelpers.Status.IsActive(uuid, v) then
					if not checkAll then
						return true
					end
					totalActive = totalActive + 1
				end
			end
			return totalActive >= total
		elseif t == "string" then
			if Ext.OsirisIsCallable() then
				return HasActiveStatus(uuid, statusId) == 1
			else
				local target = GameHelpers.TryGetObject(uuid)
				if target and target.GetStatus then
					return target:GetStatus(statusId) ~= nil
				end
			end
		end
	end
	return false
end

---Returns true if the object has a status with a specific type.
---@param object EsvGameObject|UUID|NETID
---@param statusType string|string[]
---@return boolean
function GameHelpers.Status.HasStatusType(object, statusType)
	object = GameHelpers.TryGetObject(object)
	if object and object.GetStatusObjects then
		local t = type(statusType)
		if t == "table" then
			for i,v in pairs(statusType) do
				if GameHelpers.Status.HasStatusType(object, v) then
					return true
				end
			end
		elseif t == "string" and not StringHelpers.IsNullOrWhitespace(statusType) then
			for _,v in pairs(object:GetStatusObjects()) do
				if v.StatusId == statusType or v.StatusType == statusType then
					return true
				end
			end
		end
	end
    return false
end