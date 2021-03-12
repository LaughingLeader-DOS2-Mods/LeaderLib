if GameHelpers.Status == nil then
	GameHelpers.Status = {}
end

---Returns true if the object is sneaking or has an INVISIBLE type status.
---@param obj string
---@return boolean
function GameHelpers.Status.IsSneakingOrInvisible(obj)
    if HasActiveStatus(obj, "SNEAKING") == 1 or HasActiveStatus(obj, "INVISIBLE") == 1 then
        return true
	else
		local invisibleTable = StatusTypes["INVISIBLE"]
		if invisibleTable ~= nil then
			for status,b in pairs(invisibleTable) do
				if HasActiveStatus(obj, status) == 1 then
					return true
				end
			end
		end
    end
    return false
end

Ext.NewQuery(GameHelpers.Status.IsSneakingOrInvisible, "LeaderLib_Ext_QRY_IsSneakingOrInvisible", "[in](GUIDSTRING)_Object, [out](INTEGER)_Bool")

---Returns true if the object has a tracked type status.
---Current tracked types: ACTIVE_DEFENSE, BLIND, CHARMED, DAMAGE_ON_MOVE, DISARMED, INCAPACITATED, INVISIBLE, KNOCKED_DOWN, MUTED, POLYMORPHED
---@param obj string
---@param statusType string
---@return boolean
local function ObjectHasStatusType(obj, statusType)
	if type(statusType) == "table" then
		for i,v in pairs(statusType) do
			local check = string.upper(v)
			if HasActiveStatus(obj, check) == 1 or NRD_ObjectHasStatusType(obj, check) == 1 then
				return true
			end
		end
	else
		if statusType ~= nil and statusType ~= "" then
			statusType = string.upper(statusType)
			if HasActiveStatus(obj, statusType) == 1 or NRD_ObjectHasStatusType(obj, statusType) == 1 then
				return true
			else
				local statusTypeTable = StatusTypes[statusType]
				if statusTypeTable ~= nil then
					for status,b in pairs(statusTypeTable) do
						if HasActiveStatus(obj, status) == 1 then
							return true
						end
					end
				else
					return HasActiveStatus(obj, statusType) == 1 or NRD_ObjectHasStatusType(obj, statusType) == 1
				end
			end
		end
	end
    return false
end

GameHelpers.Status.HasStatusType = ObjectHasStatusType

Ext.NewQuery(ObjectHasStatusType, "LeaderLib_Ext_QRY_HasStatusType", "[in](GUIDSTRING)_Object, [in](STRING)_StatusType, [out](INTEGER)_Bool")

---@param status EsvStatus
---@param target EsvCharacter|nil
---@param source EsvCharacter|nil
---@return boolean
function GameHelpers.Status.IsFromEnemy(status, target, source)
	target = target or Ext.GetGameObject(status.TargetHandle)
	source = source or (status.StatusSourceHandle ~= nil and Ext.GetGameObject(status.StatusSourceHandle) or nil)
	if target ~= nil and source ~= nil then
		return CharacterIsEnemy(target.MyGuid, source.MyGuid) == 1
	end
	return false
end

---Returns true if the character is disabled by a status.
---@param character EsvCharacter|string
---@param checkForLoseControl boolean
---@return boolean
function GameHelpers.Status.IsDisabled(character, checkForLoseControl)
	if type(character) == "string" then
		character = Ext.GetCharacter(character)
	end
	if character == nil then
		return false
	end
	if ObjectHasStatusType(character.MyGuid, {"KNOCKED_DOWN", "INCAPACITATED"}) then
		return true
	elseif checkForLoseControl == true then -- LoseControl on items is a good way to crash
		for _,status in pairs(character:GetStatusObjects()) do
			if status.StatusId == "CHARMED" then
				return GameHelpers.Status.IsFromEnemy(status, character)
			end
			if Data.EngineStatus(status.StatusId) ~= true then
				local stat = Ext.GetStat(status.StatusId)
				if stat and stat.LoseControl == "Yes" then
					if GameHelpers.Status.IsFromEnemy(status, character) then
						return true
					end
				end
			end
		end
	end
	return false
end



---Returns true if the object is affected by a "LoseControl" status.
---@param character EsvCharacter|string
---@param onlyFromEnemy boolean|nil Only return true if the source of a status is from an enemy.
---@return boolean
function GameHelpers.Status.CharacterLostControl(character, onlyFromEnemy)
	if type(character) == "string" then
		character = Ext.GetCharacter(character)
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
		if Data.EngineStatus(status.StatusId) ~= true then
			local stat = Ext.GetStat(status.StatusId)
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

---Set an active status' duration, or apply if if applyIfMissing is not false.
---@param obj string
---@param statusId string
---@param duration number
---@param allInstances boolean|nil
---@param applyIfMissing boolean|nil
---@return boolean
function GameHelpers.Status.SetDuration(obj, statusId, duration, allInstances, applyIfMissing)
	if HasActiveStatus(obj, statusId) == 0 then
		if applyIfMissing ~= false then
			ApplyStatus(obj, statusId, duration, 0, obj)
			return true
		end
		return false
	else
		if ObjectIsCharacter(obj) == 1 then
			local character = Ext.GetCharacter(obj)
			if character ~= nil then
				local success = false
				if allInstances == true then
					for _,status in pairs(character:GetStatusObjects()) do
						if status.StatusId == statusId then
							status.CurrentLifeTime = duration
							status.LifeTime = duration
							status.RequestClientSync = true
							success = true
						end
					end
				else
					local status = character:GetStatus(statusId)
					if status ~= nil then
						status.CurrentLifeTime = duration
						status.LifeTime = duration
						status.RequestClientSync = true
					end
				end

				if success and character.IsPlayer then
					--GameHelpers.UI.RefreshStatusTurns(obj, statusId, turns)
				end

				return success
			end
		end
	end
	return false
end

---Set an active status' turns, or apply if if applyIfMissing is not false.
---@param obj string
---@param statusId string
---@param turns integer
---@param allInstances boolean|nil
---@param applyIfMissing boolean|nil
---@return boolean
function GameHelpers.Status.SetTurns(obj, statusId, turns, allInstances, applyIfMissing)
	return GameHelpers.Status.SetDuration(obj, statusId, turns*6, allInstances, applyIfMissing)
end

---Applies statuses in order of the table supplied. Use this for tiered statuses (i.e. MYMOD_POWERLEVEL1, MYMOD_POWERLEVEL2).
---@param obj string
---@param statusTable string[] An array of tiered statuses (must be ipairs-friendly via regular integer indexes).
---@param duration number The status duration. Defaults to -1.0 for a regular permanent status.
---@param force boolean|nil Whether to force the status to apply.
---@param source string|nil The source of the status. Defaults to the target object.
---@return integer,integer Returns the next tier / last tier.
function GameHelpers.Status.ApplyTieredStatus(obj, statusTable, duration, force, source)
	local maxTier = #statusTable
	local maxStatus = statusTable[maxTier]
	-- We're at the max tier, so skip the iteration
	if HasActiveStatus(obj, maxStatus) == 1 then
		-- Refreshing the status duration
		if duration and duration > 0 then
			GameHelpers.Status.SetDuration(obj, maxStatus, duration, true, false)
		end
		return maxTier,maxTier
	end
	maxTier = maxTier - 1
	local lastTier = 1
	local tier = 1
	for i=1,maxTier do
		local status = statusTable[i]
		if HasActiveStatus(obj, status) == 1 then
			lastTier = tier
			tier = i+1
			break
		end
	end
	local status = statusTable[tier]
	if status ~= nil then
		--Convoluted way of making force default to 1 if not set, otherwise be 1 or 0 for true/false.
		local doForce = force == true and 1 or force == false and 0 or 1
		ApplyStatus(obj, status, duration and duration or -1.0, doForce, source or obj)
	end
	return tier,lastTier
end

---Similar to GameHelpers.Status.ApplyTieredStatus, except it doesn't apply the status.
---@see GameHelpers.Status.ApplyTieredStatus
---@param obj string
---@param statusTable string[] An array of tiered statuses (must be ipairs-friendly via regular integer indexes).
---@param duration number The status duration. Defaults to -1.0 for a regular permanent status.
---@param force boolean|nil Whether to force the status to apply.
---@param source string|nil The source of the status. Defaults to the target object.
---@return string,integer,integer Returns the next tier's status id, the tier number, and the last tier number.
function GameHelpers.Status.GetNextTieredStatus(obj, statusTable, duration, force, source)
	local maxTier = #statusTable
	local maxStatus = statusTable[maxTier]
	-- We're at the max tier, so skip the iteration
	if HasActiveStatus(obj, maxStatus) == 1 then
		return maxStatus,maxTier,maxTier
	end
	maxTier = maxTier - 1
	local lastTier = 1
	local tier = 1
	for i=1,maxTier do
		local status = statusTable[i]
		if HasActiveStatus(obj, status) == 1 then
			lastTier = tier
			tier = i+1
			break
		end
	end
	local status = statusTable[tier]
	return status,tier,lastTier
end