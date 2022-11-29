if GameHelpers.Status == nil then
	GameHelpers.Status = {}
end

local _ISCLIENT = Ext.IsClient()
local _type = type


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
		if not _ISCLIENT and _OSIRIS() then
			if NRD_StatExists(statusId) then
				statusType = GetStatusType(statusId)
			end
		elseif not Data.EngineStatus[statusId] then
			local stat = Ext.Stats.Get(statusId, nil, false)
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
local function IsBeneficialPotion(stat, ignoreItemPotions)
	if ignoreItemPotions == true and (stat.IsFood == "Yes" or stat.IsConsumable == "Yes") then
		return false
	end
	if not StringHelpers.IsNullOrWhitespace(stat.BonusWeapon) then
		return true
	end
	local totalPositive = 0
	local totalNegative = 0
	for k,b in pairs(potionProperties) do
		local value = stat[k]
		local t = _type(value)
		if t == "number" then
			if (b == true and value > 0) or (b == false and value < 0) then
				--return true
				totalPositive = totalPositive + value
			else
				totalNegative = totalNegative + value
			end
		elseif t == "string" then
			if value ~= "None" and string.find(b, "Qualifier") then
				local realValue = tonumber(value)
				if realValue then
					if realValue > 0 then
						totalPositive = totalPositive + value
					else
						totalNegative = totalNegative + value
					end
				end
			end
		end
	end
	return totalPositive >= math.abs(totalNegative)
end

---@param stat StatEntryPotion|table
local function IsHarmfulPotion(stat, ignoreItemPotions)
	return not IsBeneficialPotion(stat, ignoreItemPotions)
end

local function IsHarmfulStatsId(statsId)
	if not StringHelpers.IsNullOrWhitespace(statsId) then
		local potions,isTable = GameHelpers.Stats.ParseStatsIdPotions(statsId)
		if isTable then
			for _,v in pairs(potions) do
				local stat = Ext.Stats.Get(v.ID, nil, false)
				if stat and IsHarmfulPotion(stat) then
					return true
				end
			end
		else
			local stat = Ext.Stats.Get(potions, nil, false)
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
	if _type(stat) == "string" then
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
		local weapon = Ext.Stats.Get(damageStats, nil, false)
		if weapon and weapon.DamageFromBase > 0 then
			return true
		end
	end
	return false
end

---A status is harmful if it deals damage, is a specific type (KNOCKED_DOWN etc), or has negative potion attributes.
---@param statusId string
function GameHelpers.Status.IsHarmful(statusId)
	local statusType = GameHelpers.Status.GetStatusType(statusId)
	if harmfulStatusTypes[statusType] == true or ((statusType == "DAMAGE" or statusType == "DAMAGE_ON_MOVE") and GameHelpers.Status.StatusDealsDamage(statusId)) then
		return true
	elseif statusType ~= "EFFECT" 
	and not Data.EngineStatus[statusId]
	and not beneficialStatusTypes[statusType]
	then
		local stat = Ext.Stats.Get(statusId, nil, false)
		if stat then
			local statsId = stat.StatsId
			if not StringHelpers.IsNullOrWhitespace(statsId) and IsHarmfulStatsId(statsId) then
				return true
			end
		end
	end
	return false
end

local function IsBeneficialStatsId(statsId, ignoreItemPotions)
	if not StringHelpers.IsNullOrWhitespace(statsId) then
		local potions,isTable = GameHelpers.Stats.ParseStatsIdPotions(statsId)
		if isTable then
			for _,v in pairs(potions) do
				local stat = Ext.Stats.Get(v.ID, nil, false)
				if stat and IsBeneficialPotion(stat, ignoreItemPotions) then
					return true
				end
			end
		else
			local stat = Ext.Stats.Get(potions, nil, false)
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
	if _type(stat) == "string" then
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
	elseif statusType ~= "EFFECT"
	and not Data.EngineStatus[statusId]
	and not harmfulStatusTypes[statusType] then
		local stat = Ext.Stats.Get(statusId, nil, false)
		if stat then
			local statsId = stat.StatsId
			if not StringHelpers.IsNullOrWhitespace(statsId) and IsBeneficialStatsId(statsId, ignoreItemPotions) then
				return true
			end
		end
	end
	return false
end

---Checks if a potion stat has any stat boosts.
---@param potionId string
---@return boolean
function GameHelpers.Stats.PotionHasStatBoosts(potionId)
	local potions,isTable = GameHelpers.Stats.ParseStatsIdPotions(potionId)
	if isTable then
		for _,v in pairs(potions) do
			local stat = Ext.Stats.Get(v.ID, nil, false)
			if stat then
				for k,_ in pairs(potionProperties) do
					if stat[k] ~= 0 then
						return true
					end
				end
			end
		end
	else
		local stat = Ext.Stats.Get(potions, nil, false)
		if stat then
			for k,_ in pairs(potionProperties) do
				if stat[k] ~= 0 then
					return true
				end
			end
		end
	end
	return false
end


---Checks if a status has any stat boosts via StatsId.
---@param status string|EsvStatus|EsvStatusConsumeBase
---@return boolean
function GameHelpers.Status.HasStatBoosts(status)
	local t = _type(status)
	if t == "string" then
		local stat = Ext.Stats.Get(status, nil, false)
		if stat and not StringHelpers.IsNullOrWhitespace(stat.StatsId) then
			return GameHelpers.Stats.PotionHasStatBoosts(stat.StatsId)
		end
		return false
	elseif (t == "userdata" or t == "table") and status.StatusId then
		if status.StatsId and GameHelpers.Stats.PotionHasStatBoosts(status.StatsId) then
			return true
		end
		return GameHelpers.Status.HasStatBoosts(status.StatusId)
	end
	ferror("status param (%s) is not a valid type (%s) - Should be a string or an Ecl/EsvStatus", status, t)
end

---Returns true if the object has any of the given statuses.
---@param object ObjectParam
---@param statusId string|string[]
---@param checkAll boolean|nil If true and statusId is a table, only return true if every given status is active.
---@return boolean
function GameHelpers.Status.IsActive(object, statusId, checkAll)
	local uuid = GameHelpers.GetUUID(object)
	if uuid then
		local t = _type(statusId)
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
			if _OSIRIS() then
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

---Returns true if the object has any of the given statuses.
---@param object ObjectParam
---@param statusId string
---@param asTurns boolean|nil Return the duration in turns.
---@return number|integer durationOrTurns
function GameHelpers.Status.GetDuration(object, statusId, asTurns)
	local object = GameHelpers.TryGetObject(object)
	if object then
		local duration = 0
		for _,v in pairs(object:GetStatusObjects()) do
			if v.StatusId == statusId then
				if v.CurrentLifeTime < 0 then
					duration = v.CurrentLifeTime
				elseif duration >= 0 then
					duration = math.max(duration, v.CurrentLifeTime)
				end
			end
		end
		if asTurns then
			Ext.Utils.Round(duration / 6.0)
		else
			return duration
		end
	end
	return 0
end

---Returns true if the object has a status with a specific type.
---@param object ObjectParam
---@param statusType string|string[]
---@return boolean
function GameHelpers.Status.HasStatusType(object, statusType)
	object = GameHelpers.TryGetObject(object)
	if object and object.GetStatusObjects then
		local t = _type(statusType)
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

---@param status string
---@param checkForLoseControl boolean
---@param stat StatEntryStatusData|nil
---@return boolean isDisabling
---@return boolean isLoseControl
function GameHelpers.Status.IsDisablingStatus(status, checkForLoseControl, stat)
	local statusType = GameHelpers.Status.GetStatusType(status)
	if statusType == "KNOCKED_DOWN" or statusType == "INCAPACITATED" then
		return true,false
	end
	if checkForLoseControl == true then
		if status == "CHARMED" then
			return true,true
		end
		if not Data.EngineStatus[status] then
			local stat = stat or Ext.Stats.Get(status, nil, false)
			if stat and stat.LoseControl == "Yes" then
				return true,true
			end
		end
	end
	return false,false
end

---Returns true if the object is affected by a "LoseControl" status.
---@param character EsvCharacter|string
---@param onlyFromEnemy boolean|nil Only return true if the source of a status is from an enemy.
---@return boolean
function GameHelpers.Status.CharacterLostControl(character, onlyFromEnemy)
	if _type(character) == "string" then
		character = GameHelpers.GetCharacter(character)
	end
	if character == nil then
		return false
	end
	for i,status in pairs(character:GetStatusObjects()) do
		if status.StatusId == "CHARMED" then
			if onlyFromEnemy ~= true then
				return true
			else
				return GameHelpers.Status.IsFromEnemy(status, character)
			end
		end
		if Data.EngineStatus[status.StatusId] ~= true then
			local stat = Ext.Stats.Get(status.StatusId, nil, false)
			if stat and stat.LoseControl == "Yes" then
				if onlyFromEnemy ~= true then
					return true
				else
					if GameHelpers.Status.IsFromEnemy(status, character) then
						return true
					end
				end
			end
		end
	end
	return false
end