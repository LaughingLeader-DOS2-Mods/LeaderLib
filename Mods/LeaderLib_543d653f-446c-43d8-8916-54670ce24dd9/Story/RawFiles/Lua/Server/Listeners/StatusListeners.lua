local function IgnoreStatus(status)
	if Data.IgnoredStatus[status] == true and Vars.RegisteredIgnoredStatus[status] ~= true then
		return true
	end
	return false
end

---@param statusId string
---@param target EsvCharacter|EsvItem
---@param status EsvStatus
---@param source EsvCharacter|EsvItem
---@param handle integer
local function BeforeStatusAttempt(statusId, target, status, source, handle)
	if source then 
		if ObjectIsItem(source.MyGuid) == 1 then
			--Fix for summoned item applied statuses having no source when they're dead
			--With this, statuses they apply should have their skill caster owner as the source.
			if source.Summon and source.OwnerHandle then
				if status then
					status.StatusSourceHandle = source.OwnerHandle
				else
					local owner = Ext.GetGameObject(source.OwnerHandle)
					if owner then
						NRD_StatusSetGuidString(target.MyGuid, handle, "StatusSourceHandle", owner.MyGuid)
					end
				end
			end
		end
	end
	InvokeListenerCallbacks(StatusListeners.BeforeAttempt[statusId], target, status, source, handle)
	InvokeListenerCallbacks(StatusListeners.BeforeAttempt.All, target, status, source, handle)
end

RegisterProtectedOsirisListener("NRD_OnStatusAttempt", 4, "after", function(target,status,handle,source)
	BeforeStatusAttempt(status, GameHelpers.TryGetObject(target), Ext.GetStatus(target, handle), GameHelpers.TryGetObject(source), handle)
end)

local function OnStatusAttempt(target,status,source)
	target = StringHelpers.GetUUID(target)
	source = StringHelpers.GetUUID(source)
	local callbacks = StatusListeners.Attempt[status]
	if callbacks then
		for i=1,#callbacks do
			local b,err = xpcall(callbacks[i], debug.traceback, target, status, source)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

local function ParseStatusAttempt(target,status,source)
	if not IgnoreStatus(status) then
		OnStatusAttempt(target, status, source)
	end
end

RegisterProtectedOsirisListener("CharacterStatusAttempt", 3, "after", ParseStatusAttempt)
RegisterProtectedOsirisListener("ItemStatusAttempt", 3, "after", ParseStatusAttempt)

local function TrackStatusSource(target, status, source)
	if PersistentVars.StatusSource[status] == nil then
		PersistentVars.StatusSource[status] = {}
	end
	PersistentVars.StatusSource[status][target] = source
end

local function GetStatusSource(target, status)
	if PersistentVars.StatusSource[status] ~= nil then
		return PersistentVars.StatusSource[status][target]
	end
	return nil
end

local function ClearStatusSource(target, status, source)
	if PersistentVars.StatusSource[status] ~= nil then
		local canRemove = true
		if HasActiveStatus(target, status) == 1 then
			local handle = NRD_StatusGetHandle(target, status)
			if handle ~= nil then
				local otherSource = NRD_StatusGetGuidString(char, handle, "StatusSourceHandle")
				if otherSource ~= source then
					canRemove = true
				end
			end
		end
		if canRemove then
			PersistentVars.StatusSource[status][target] = nil
			if not Common.TableHasEntry(PersistentVars.StatusSource[status]) then
				PersistentVars.StatusSource[status] = nil
			end
		end
	end
end

local forceStatuses = {
	LEADERLIB_FORCE_PUSH1 = 1,
	LEADERLIB_FORCE_PUSH2 = 2,
	LEADERLIB_FORCE_PUSH3 = 3,
	LEADERLIB_FORCE_PUSH4 = 4,
	LEADERLIB_FORCE_PUSH5 = 5,
	LEADERLIB_FORCE_PUSH6 = 6,
	LEADERLIB_FORCE_PUSH7 = 7,
	LEADERLIB_FORCE_PUSH8 = 8,
	LEADERLIB_FORCE_PUSH9 = 9,
	LEADERLIB_FORCE_PUSH10 = 10,
	LEADERLIB_FORCE_PUSH11 = 11,
	LEADERLIB_FORCE_PUSH12 = 12,
	LEADERLIB_FORCE_PUSH13 = 13,
	LEADERLIB_FORCE_PUSH14 = 14,
	LEADERLIB_FORCE_PUSH15 = 15,
	LEADERLIB_FORCE_PUSH16 = 16,
	LEADERLIB_FORCE_PUSH17 = 17,
	LEADERLIB_FORCE_PUSH18 = 18,
	LEADERLIB_FORCE_PUSH19 = 19,
	LEADERLIB_FORCE_PUSH20 = 20,
}

local function OnStatusApplied(target,status,source)
	if status == "SUMMONING" then
		local summon = Ext.GetGameObject(target)
		if summon then
			local owner = nil
			if summon.OwnerHandle then
				owner = Ext.GetGameObject(summon.OwnerHandle)
			end
			if owner then
				if not PersistentVars.Summons[owner.MyGuid] then
					PersistentVars.Summons[owner.MyGuid] = {}
				end
				table.insert(PersistentVars.Summons[owner.MyGuid], summon.MyGuid)
			end
			InvokeListenerCallbacks(Listeners.OnSummonChanged, summon, owner, false, ObjectIsItem(target) == 1)
		end
	end
	if Vars.LeaveActionData.Total > 0 then
		local skill = Vars.LeaveActionData.Statuses[status]
		if skill then
			local turns = GetStatusTurns(target, status)
			if not turns or turns == 0 then
				GameHelpers.ExplodeProjectile(source, target, skill)
			elseif not StringHelpers.IsNullOrEmpty(source) then
				TrackStatusSource(target, status, source)
			end
		end
	end
	local callbacks = StatusListeners.Applied[status]
	if callbacks then
		for i=1,#callbacks do
			local b,err = xpcall(callbacks[i], debug.traceback, target, status, source)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
	if forceStatuses[status] and not StringHelpers.IsNullOrEmpty(source) and ObjectIsCharacter(source) == 1 then
		--local distance = tonumber(string.gsub(status, "LEADERLIB_FORCE_PUSH", ""))
		GameHelpers.ForceMoveObject(Ext.GetCharacter(source), Ext.GetGameObject(target), forceStatuses[status])
	end
end

local function OnStatusRemoved(target,status)
	--PrintDebug("OnStatusRemoved", target,status)
	local source = nil
	if Vars.LeaveActionData.Total > 0 then
		source = GetStatusSource(target, status)
		if source ~= nil then
			local skill = Vars.LeaveActionData.Statuses[status]
			if skill ~= nil then
				GameHelpers.ExplodeProjectile(source, target, skill)
			end
			ClearStatusSource(target, status)
		end
	end
	-- if Vars.DebugMode then
	-- 	fprint(LOGLEVEL.TRACE, "[LeaderLib:OnStatusRemoved] (%s, %s, %s)", target, status, source)
	-- end
	local callbacks = StatusListeners.Removed[status]
	if callbacks then
		for i=1,#callbacks do
			local b,err = xpcall(callbacks[i], debug.traceback, target, status, source)
			if not b then
				Ext.PrintError(err)
			end
		end
	end
end

local function ParseStatusApplied(target,status,source)
	if not IgnoreStatus(status) then
		target = StringHelpers.GetUUID(target)
		source = StringHelpers.GetUUID(source)
		OnStatusApplied(target, status, source)
	end
end

local function ParseStatusRemoved(target,status)
	if not IgnoreStatus(status) then
		target = StringHelpers.GetUUID(target)
		OnStatusRemoved(target, status)
	end
end

RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", ParseStatusApplied)
RegisterProtectedOsirisListener("ItemStatusChange", 3, "after", ParseStatusApplied)
RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "after", ParseStatusRemoved)
RegisterProtectedOsirisListener("ItemStatusRemoved", 3, "after", ParseStatusRemoved)