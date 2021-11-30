if GameHelpers.Status == nil then
	GameHelpers.Status = {}
end

---Returns true if the object is sneaking or has an INVISIBLE type status.
---@param obj string
---@return boolean
function GameHelpers.Status.IsSneakingOrInvisible(obj)
    if HasActiveStatus(obj, "SNEAKING") == 1 or HasActiveStatus(obj, "INVISIBLE") == 1 or NRD_ObjectHasStatusType(obj, "INVISIBLE") == 1 then
        return true
    end
    return false
end

Ext.NewQuery(GameHelpers.Status.IsSneakingOrInvisible, "LeaderLib_Ext_QRY_IsSneakingOrInvisible", "[in](GUIDSTRING)_Object, [out](INTEGER)_Bool")

---Returns true if the object has a status with a specific type.
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
	elseif not StringHelpers.IsNullOrWhitespace(statusType) then
		if HasActiveStatus(obj, statusType) == 1 or NRD_ObjectHasStatusType(obj, statusType) == 1 then
			return true
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
			if Data.EngineStatus[status.StatusId] ~= true then
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

---@param status string
---@param checkForLoseControl boolean
---@return boolean
function GameHelpers.Status.IsDisablingStatus(status, checkForLoseControl)
	local statusType = GameHelpers.Status.GetStatusType(status)
	if statusType == "KNOCKED_DOWN" or statusType == "INCAPACITATED" then
		return true
	end
	if checkForLoseControl == true then
		if status == "CHARMED" then
			return true
		end
		if not Data.EngineStatus[status] then
			local stat = Ext.GetStat(status)
			if stat and stat.LoseControl == "Yes" then
				return true
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
		if Data.EngineStatus[status.StatusId] ~= true then
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
---@param extendDuration boolean|nil If true, the current duration is added to the duration value set, instead of replacing it.
---@return boolean
function GameHelpers.Status.SetDuration(obj, statusId, duration, allInstances, applyIfMissing, extendDuration)
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
							if not extendDuration then
								status.CurrentLifeTime = duration
								status.LifeTime = duration
							else
								status.CurrentLifeTime = status.CurrentLifeTime + duration
								status.LifeTime = status.LifeTime + duration
							end
							status.RequestClientSync = true
							success = true
						end
					end
				else
					local status = character:GetStatus(statusId)
					if status ~= nil then
						if not extendDuration then
							status.CurrentLifeTime = duration
							status.LifeTime = duration
						else
							status.CurrentLifeTime = status.CurrentLifeTime + duration
							status.LifeTime = status.LifeTime + duration
						end
						status.RequestClientSync = true
						success = true
					end
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

---Extend an active status' duration, or apply if if applyIfMissing is not false.
---@param obj string
---@param statusId string
---@param addDuration number
---@param allInstances boolean|nil
---@param applyIfMissing boolean|nil
---@return boolean
function GameHelpers.Status.ExtendDuration(obj, statusId, addDuration, allInstances, applyIfMissing)
	return GameHelpers.Status.SetDuration(obj, statusId, addDuration, allInstances, applyIfMissing, true)
end

---Set an active status' turns, or apply if if applyIfMissing is not false.
---@param obj string
---@param statusId string
---@param addTurns integer
---@param allInstances boolean|nil
---@param applyIfMissing boolean|nil
---@return boolean
function GameHelpers.Status.ExtendTurns(obj, statusId, addTurns, allInstances, applyIfMissing)
	return GameHelpers.Status.SetDuration(obj, statusId, addTurns*6, allInstances, applyIfMissing, true)
end

---Applies statuses in order of the table supplied. Use this for tiered statuses (i.e. MYMOD_POWERLEVEL1, MYMOD_POWERLEVEL2).
---@param obj UUID|EsvCharacter|EsvItem
---@param statusTable string[] An array of tiered statuses (must be ipairs-friendly via regular integer indexes).
---@param duration number The status duration. Defaults to -1.0 for a regular permanent status.
---@param force boolean|nil Whether to force the status to apply.
---@param source string|nil The source of the status. Defaults to the target object.
---@return integer,integer Returns the next tier / last tier.
function GameHelpers.Status.ApplyTieredStatus(obj, statusTable, duration, force, source)
	local obj = GameHelpers.GetUUID(obj)
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

---Removes harmful statuses by checking their type and potion stat values.
---@param obj EsvCharacter|EsvItem
---@param ignorePermanent boolean|nil Ignore permanent statuses.
function GameHelpers.Status.RemoveHarmful(obj, ignorePermanent)
	for _,status in pairs(obj:GetStatusObjects()) do
		if ignorePermanent and status.CurrentLifeTime == -1 then
			-- skip
		elseif GameHelpers.Status.IsHarmful(status.StatusId) then
			RemoveStatus(obj.MyGuid, status.StatusId)
		end
	end
end

---@param target string
---@param status string
---@param duration number
---@param force boolean
---@param source string
local function FinallyApplyStatus(target, status, duration, force, source)
	if source == nil then
		source = StringHelpers.NULL_UUID
	end
	if duration == -2 then
		local statusObject = Ext.PrepareStatus(target, status, duration)
		if not StringHelpers.IsNullOrEmpty(source) then
			local sourceObj = GameHelpers.TryGetObject(source)
			if sourceObj then
				statusObject.StatusSourceHandle = sourceObj.Handle
			end
		end
		statusObject.KeepAlive = true
		if force == true then
			statusObject.ForceStatus = true
		end
		Ext.ApplyStatus(statusObject)
	else
		ApplyStatus(target, status, duration, force == true and 1 or 0, source)
	end
end

---Applies a status to a target, or targets around a position.
---@param target EsvGameObject|UUID|number|number[]|nil
---@param status string|string[]
---@param duration number|nil
---@param force boolean|nil
---@param source EsvGameObject|UUID|number|nil
---@param radius number|nil
---@param canTargetItems boolean|nil
---@param canApplyCallback fun(target:string, source:string, statusId:string, targetIsItem:boolean):boolean|nil An optional function to use when attempting to apply a status in a radius.
function GameHelpers.Status.Apply(target, status, duration, force, source, radius, canTargetItems, canApplyCallback)
	if not duration then
		duration = 6.0
		local potion = Ext.StatGetAttribute(status, "StatsId")
		if not StringHelpers.IsNullOrWhitespace(potion) then
			if string.find(potion, ";") then
				for m in string.gmatch(potion, "[%a%d_]+,") do
					local potionDuration = Ext.StatGetAttribute(string.sub(m, 1, #m-1), "Duration")
					if potionDuration and potionDuration > duration then
						duration = potionDuration * 6.0
					end
				end
			else
				local potionDuration = Ext.StatGetAttribute(potion, "Duration")
				if potionDuration and potionDuration > 0 then
					duration = potionDuration * 6.0
				end
			end
		end
	end
	if force == nil then
		force = false
	end
	local t = type(status)
	if t == "string" then
		source = GameHelpers.GetUUID(source, true)
		local targetType = type(target)
		if targetType ~= "table" then
			target = GameHelpers.GetUUID(target)
			if target then
				FinallyApplyStatus(target, status, duration, force, source)
			end
		else
			radius = radius or 1.0
			local statusType = GetStatusType(status)
			local x,y,z = table.unpack(target)
			if not x or not y or not z then
				error(string.format("No valid position set (%s). Failed to apply status (%s)", Lib.inspect(target), status), 2)
			end
			for _,v in pairs(Ext.GetCharactersAroundPosition(x,y,z,radius)) do
				if v ~= source then
					if canApplyCallback then
						local b,result = pcall(canApplyCallback, v, source, status, false)
						if b and result == true then
							FinallyApplyStatus(v, status, duration, force, source)
						end
					else
						FinallyApplyStatus(v, status, duration, force, source)
					end
				end
			end
			if canTargetItems and (statusType ~= "CHARMED" and statusType ~= "DAMAGE_ON_MOVE") then
				for _,v in pairs(Ext.GetItemsAroundPosition(x,y,z,radius)) do
					if v ~= source then
						if canApplyCallback then
							local b,result = pcall(canApplyCallback, v, source, status, true)
							if b and result == true then
								FinallyApplyStatus(v, status, duration, force, source)
							end
						else
							FinallyApplyStatus(v, status, duration, force, source)
						end
					end
				end
			end
		end
	elseif t == "table" then
		for i=1,#status do
			GameHelpers.Status.Apply(target, status[i], duration, force, source, radius, canTargetItems)
		end
	end
end

---@param character EsvGameObject|string
---@param statusId boolean
---@return boolean
function GameHelpers.Status.IsActive(object, statusId)
	local uuid = GameHelpers.GetUUID(object)
	if uuid then
		return HasActiveStatus(uuid, statusId) == 1
	end
	return false
end