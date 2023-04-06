if GameHelpers.Status == nil then
	GameHelpers.Status = {}
end

Ext.Osiris.NewQuery(GameHelpers.Status.HasStatusType, "LeaderLib_Ext_QRY_HasStatusType", "[in](GUIDSTRING)_Object, [in](STRING)_StatusType, [out](INTEGER)_Bool")

---@param status EsvStatus
---@param target EsvCharacter|nil
---@param source EsvCharacter|nil
---@return boolean
function GameHelpers.Status.IsFromEnemy(status, target, source)
	target = target or GameHelpers.TryGetObject(status.TargetHandle)
	source = source or (status.StatusSourceHandle ~= nil and GameHelpers.TryGetObject(status.StatusSourceHandle) or nil)
	if target ~= nil and source ~= nil then
		return GameHelpers.Character.IsEnemy(target, source)
	end
	return false
end

---Set an active status' duration, or apply if if applyIfMissing is not false.
---@param obj ObjectParam
---@param statusId string
---@param duration number
---@param allInstances boolean|nil
---@param applyIfMissing boolean|nil
---@param extendDuration boolean|nil If true, the current duration is added to the duration value set, instead of replacing it.
---@param source ObjectParam|nil
---@return boolean
function GameHelpers.Status.SetDuration(obj, statusId, duration, allInstances, applyIfMissing, extendDuration, source)
	local object = GameHelpers.TryGetObject(obj)
	if not object then
		fprint(LOGLEVEL.WARNING, "[GameHelpers.Status.SetDuration] Failed to get object from (%s)", obj)
		return false
	end
	if not GameHelpers.Status.IsActive(object, statusId) then
		if applyIfMissing ~= false then
			GameHelpers.Status.Apply(object, statusId, duration, false, source or object)
			return true
		end
		return false
	elseif object.GetStatusObjects then
		local success = false
		if allInstances == true then
			for _,status in pairs(object:GetStatusObjects()) do
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
			local status = object:GetStatus(statusId)
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
	return false
end

---Set an active status' turns, or apply if if applyIfMissing is not false.
---@param obj ObjectParam
---@param statusId string
---@param turns integer
---@param allInstances boolean|nil
---@param applyIfMissing boolean|nil
---@param extendDuration boolean|nil If true, the current duration is added to the duration value set, instead of replacing it.
---@param source ObjectParam|nil
---@return boolean
function GameHelpers.Status.SetTurns(obj, statusId, turns, allInstances, applyIfMissing, extendDuration, source)
	return GameHelpers.Status.SetDuration(obj, statusId, turns*6, allInstances, applyIfMissing, extendDuration, source)
end

---Extend an active status' duration, or apply if if applyIfMissing is not false.
---@param obj ObjectParam
---@param statusId string
---@param addDuration number
---@param allInstances boolean|nil
---@param applyIfMissing boolean|nil
---@param source ObjectParam|nil
---@return boolean
function GameHelpers.Status.ExtendDuration(obj, statusId, addDuration, allInstances, applyIfMissing, source)
	return GameHelpers.Status.SetDuration(obj, statusId, addDuration, allInstances, applyIfMissing, true, source)
end

---Set an active status' turns, or apply if if applyIfMissing is not false.
---@param obj ObjectParam
---@param statusId string
---@param addTurns integer
---@param allInstances boolean|nil
---@param applyIfMissing boolean|nil
---@param source ObjectParam|nil
---@return boolean
function GameHelpers.Status.ExtendTurns(obj, statusId, addTurns, allInstances, applyIfMissing, source)
	return GameHelpers.Status.SetDuration(obj, statusId, addTurns*6, allInstances, applyIfMissing, true, source)
end

---Applies statuses in order of the table supplied. Use this for tiered statuses (i.e. MYMOD_POWERLEVEL1, MYMOD_POWERLEVEL2).
---@param obj ObjectParam
---@param statusTable string[] An array of tiered statuses (must be ipairs-friendly via regular integer indexes).
---@param duration number The status duration. Defaults to -1.0 for a regular permanent status.
---@param force boolean|nil Whether to force the status to apply.
---@param source ObjectParam|nil The source of the status. Defaults to the target object.
---@param makePermanent boolean|nil Make the resulting status permanent (block removal / restore on death).
---@return integer nextTier
---@return integer lastTier
function GameHelpers.Status.ApplyTieredStatus(obj, statusTable, duration, force, source, makePermanent)
	local object = GameHelpers.TryGetObject(obj)
	local source = source or object
	local maxTier = #statusTable
	local maxStatus = statusTable[maxTier]
	-- We're at the max tier, so skip the iteration
	if GameHelpers.Status.IsActive(object, maxStatus) then
		-- Refreshing the status duration
		if duration and duration > 0 then
			GameHelpers.Status.SetDuration(object, maxStatus, duration, true, false)
		end
		return maxTier,maxTier
	end
	maxTier = maxTier - 1
	local lastTier = 1
	local tier = 1
	for i=1,maxTier do
		local status = statusTable[i]
		if GameHelpers.Status.IsActive(object, status) then
			lastTier = tier
			tier = i+1
			break
		end
	end
	local status = statusTable[tier]
	if status ~= nil then
		if force == nil then
			force = true
		end
		if not makePermanent then
			GameHelpers.Status.Apply(object, status, duration and duration or -1.0, force, source)
		else
			StatusManager.RemovePermanentStatus(object, statusTable)
			StatusManager.ApplyPermanentStatus(object, status, source)
		end
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
	if Osi.HasActiveStatus(obj, maxStatus) == 1 then
		return maxStatus,maxTier,maxTier
	end
	maxTier = maxTier - 1
	local lastTier = 1
	local tier = 1
	for i=1,maxTier do
		local status = statusTable[i]
		if Osi.HasActiveStatus(obj, status) == 1 then
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
			Osi.RemoveStatus(obj.MyGuid, status.StatusId)
		end
	end
end

---@param target string
---@param status string
---@param duration number
---@param force boolean
---@param source string
---@param properties table<string,any>|EsvStatus|nil An optional table of properties to set on the EsvStatus.
local function FinallyApplyStatus(target, status, duration, force, source, properties)
	if source == nil then
		source = StringHelpers.NULL_UUID
	end
	local isInstantEffect = false
	if duration == 0 and GameHelpers.Status.GetStatusType(status) == "EFFECT" then
		--EFFECT types need a duration for attributes like BeamEffect to work
		duration = 0.1
		isInstantEffect = true
	end
	local statusObject = Ext.PrepareStatus(target, status, duration)
	if not statusObject then
		fprint(LOGLEVEL.ERROR, "[LeaderLib:FinallyApplyStatus] Failed to create status (%s). Does the stat exist?", status)
		return
	end
	local targetObj = GameHelpers.TryGetObject(target)
	local sourceObj = nil
	if not StringHelpers.IsNullOrEmpty(source) then
		sourceObj = GameHelpers.TryGetObject(source)
		if sourceObj then
			statusObject.StatusSourceHandle = sourceObj.Handle
			if status == "AOO" then
				statusObject.SourceHandle = sourceObj.Handle
				if sourceObj.HasOwner then
					statusObject.PartnerHandle = sourceObj.OwnerHandle
				end
			end
		end
	end
	if duration == -2 then
		statusObject.KeepAlive = true
	end
	if force == true then
		statusObject.ForceStatus = true
	end
	if status == "AOO" then
		--TODO PartnerHandle?
		statusObject.ShowOverhead = true
		statusObject.ActivateAoOBoost = true
	end
	if properties then
		for k,v in pairs(properties) do
			statusObject[k] = v
		end
	end
	-- if isInstantEffect then
	-- 	statusObject.StartTimer = 0
	-- 	statusObject.TurnTimer = 0
	-- end
	Ext.ApplyStatus(statusObject)
end

---@alias GameHelpers.Status.Remove.CanApplyCallback fun(target:string, source:string, statusId:string, targetIsItem:boolean):boolean

---Applies a status to a target, or targets around a position.
---@param target ObjectParam|number[]|nil Target object or a position, if a radius is provided.
---@param status string|string[]
---@param duration number|nil
---@param force boolean|nil
---@param source ObjectParam|nil Optional source. Defaults to NULL_00000000-0000-0000-0000-000000000000.
---@param radius number|nil
---@param canTargetItems boolean|nil
---@param canApplyCallback GameHelpers.Status.Remove.CanApplyCallback|nil An optional function to use when attempting to apply a status in a radius.
---@param statusOpts {StatsMultiplier:number}|nil Optional fields to set on the prepared status before it's applied, such as StatsMultiplier.
function GameHelpers.Status.Apply(target, status, duration, force, source, radius, canTargetItems, canApplyCallback, statusOpts)
	if not duration then
		duration = 6.0
		local stat = Ext.Stats.Get(status, nil, false)
		if stat then
			local potion = stat.StatsId
			if not StringHelpers.IsNullOrWhitespace(potion) then
				if string.find(potion, ";") then
					for m in string.gmatch(potion, "[%a%d_]+,") do
						local potionStat = Ext.Stats.Get(string.sub(m, 1, #m-1), nil, false)
						if potionStat then
							local potionDuration = potionStat.Duration
							if potionDuration and potionDuration > duration then
								duration = potionDuration * 6.0
							end
						end
					end
				else
					local potionStat = Ext.Stats.Get(potion, nil, false)
					if potionStat then
						local potionDuration = potionStat.Duration
						if potionDuration then
							duration = potionDuration * 6.0
						end
					end
				end
			end
		end
	end
	if force == nil then
		force = false
	elseif force == 1 then
	elseif force == 0 then
		force = false
	end
	local t = type(status)
	if t == "string" then
		source = GameHelpers.GetUUID(source, true)
		local targetType = type(target)
		if targetType ~= "table" then
			target = GameHelpers.GetUUID(target)
			if target and GameHelpers.ObjectExists(target) then
				FinallyApplyStatus(target, status, duration, force, source, statusOpts)
			end
		else
			radius = radius or 1.0
			local statusType = GameHelpers.Status.GetStatusType(status)
			local x,y,z = table.unpack(target)
			if not x or not y or not z then
				error(string.format("No valid position set (%s). Failed to apply status (%s)", Lib.inspect(target), status), 2)
			end
			for _,v in pairs(Ext.Entity.GetCharacterGuidsAroundPosition(x,y,z,radius)) do
				if v ~= source then
					if canApplyCallback then
						local b,result = pcall(canApplyCallback, v, source, status, false)
						if b and result == true then
							FinallyApplyStatus(v, status, duration, force, source, statusOpts)
						end
					else
						FinallyApplyStatus(v, status, duration, force, source, statusOpts)
					end
				end
			end
			if canTargetItems and (statusType ~= "CHARMED" and statusType ~= "DAMAGE_ON_MOVE") then
				for _,v in pairs(Ext.Entity.GetItemGuidsAroundPosition(x,y,z,radius)) do
					if v ~= source then
						if canApplyCallback then
							local b,result = pcall(canApplyCallback, v, source, status, true)
							if b and result == true then
								FinallyApplyStatus(v, status, duration, force, source, statusOpts)
							end
						else
							FinallyApplyStatus(v, status, duration, force, source, statusOpts)
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

---@alias GameHelpers.Status.Remove.CanRemoveCallback fun(target:string, statusId:string, targetIsItem:boolean):boolean

---Removed a status from a target, or targets around a position.
---@param target ObjectParam|number[] Either an item/character related value, an array of characters/items, or a position array.
---@param status string|string[] A status or array of statuses to remove.
---@param radius number|nil If target is a position array, this is the radius to look for target objects.
---@param canTargetItems boolean|nil If true, items can be targeted by the positional search as well.
---@param canRemoveCallback GameHelpers.Status.Remove.CanRemoveCallback|nil An optional condition function to call when attempting to remove a status from objects found in a radius around a target.
function GameHelpers.Status.Remove(target, status, radius, canTargetItems, canRemoveCallback)
	local t = type(target)
	if t == "table" then
		local targetTableType = type(target[1])
		if targetTableType == "number" then
			local x,y,z = table.unpack(target)
			if not x or not y or not z then
				error(string.format("No valid position set (%s). Failed to remove status (%s)", Lib.inspect(target), status), 2)
			end
			local success = false
			for _,v in pairs(Ext.Entity.GetCharacterGuidsAroundPosition(x,y,z,radius)) do
				if canRemoveCallback then
					local b,result = pcall(canRemoveCallback, v, status, false)
					if b and result == true then
						Osi.RemoveStatus(v, status)
						success = true
					end
				else
					Osi.RemoveStatus(v, status)
					success = true
				end
			end
			if canTargetItems then
				for _,v in pairs(Ext.Entity.GetItemGuidsAroundPosition(x,y,z,radius)) do
					if canRemoveCallback then
						local b,result = pcall(canRemoveCallback, v, status, true)
						if b and result == true then
							Osi.RemoveStatus(v, status)
							success = true
						end
					else
						Osi.RemoveStatus(v, status)
						success = true
					end
				end
			end
			return success
		elseif targetTableType == "string" or targetTableType == "userdata" then
			--Table of string targets?
			local success = false
			for i,v in pairs(target) do
				if GameHelpers.Status.Remove(v, status) then
					success = true
				end
			end
			return success
		end
	elseif t == "string" or t == "userdata" then
		target = GameHelpers.GetUUID(target)
		if target then
			local t2 = type(status)
			if t2 == "string" then
				Osi.RemoveStatus(target, status)
				return true
			elseif t2 == "table" then
				for k,v in pairs(status) do
					GameHelpers.Status.Remove(target, v)
				end
				return true
			end
		end
	end
	return false
end