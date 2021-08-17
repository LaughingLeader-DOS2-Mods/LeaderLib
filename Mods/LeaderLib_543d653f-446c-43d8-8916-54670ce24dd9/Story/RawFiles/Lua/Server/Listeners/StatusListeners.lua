---@alias BeforeStatusAttemptCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, handle:integer, statusType:string):void
---@alias StatusEventCallback fun(target:string, status:string, source:string|nil, statusType:string):void
---@alias StatusEventID string|'"BeforeAttempt"'|'"Attempt"'|'"Applied"'|'"Removed"'

---Values for the RegisterStatusListener event parameter.
---@class StatusEventValues
---@field BeforeAttempt StatusEventID BeforeAttempt, NRD_OnStatusAttempt
---@field Attempt StatusEventID Attempt, CharacterStatusAttempt/ItemStatusAttempt
---@field Applied StatusEventID Applied, CharacterStatusApplied/ItemStatusChange
---@field Removed StatusEventID Removed, CharacterStatusRemoved/ItemStatusRemoved
Vars.StatusEvent = {
	BeforeAttempt = "BeforeAttempt",
	Attempt = "Attempt",
	Applied = "Applied",
	Removed = "Removed",
}

StatusListeners = {
	---@type table<string, BeforeStatusAttemptCallback[]>
	[Vars.StatusEvent.BeforeAttempt] = {},
	---@type table<string, StatusEventCallback[]>
	[Vars.StatusEvent.Attempt] = {},
	---@type table<string, StatusEventCallback[]>
	[Vars.StatusEvent.Applied] = {},
	---@type table<string, StatusEventCallback[]>
	[Vars.StatusEvent.Removed] = {},
}

StatusTypeListeners = {
	---@type table<string, BeforeStatusAttemptCallback[]>
	[Vars.StatusEvent.BeforeAttempt] = {},
	---@type table<string, StatusEventCallback[]>
	[Vars.StatusEvent.Attempt] = {},
	---@type table<string, StatusEventCallback[]>
	[Vars.StatusEvent.Applied] = {},
	---@type table<string, StatusEventCallback[]>
	[Vars.StatusEvent.Removed] = {},
}

---If a mod registers a listener for an ignored status (such as HIT), it will be added to this table to allow callbacks to run for that status.
---@type table<string,boolean>
Vars.RegisteredIgnoredStatus = {}

---@param event StatusEventID BeforeAttempt, Attempt, Applied, Removed
---@param status string|string[] A status id or status type.
---@param callback StatusEventCallback
function RegisterStatusListener(event, status, callback)
    local statusEventHolder = StatusListeners[event]
	if statusEventHolder then
        if type(status) == "table" then
			for i,v in pairs(status) do
				RegisterStatusListener(event, v, callback)
            end
        else
            if StringHelpers.Equals(status, "All", true) then
                status = "All"
            elseif Data.IgnoredStatus[status] == true then
                Vars.RegisteredIgnoredStatus[status] = true
            end
            if statusEventHolder[status] == nil then
                statusEventHolder[status] = {}
            end
            table.insert(statusEventHolder[status], callback)
        end
    else
		error(string.format("%s is not a valid status event!", event), 2)
	end
end

---@param event StatusEventID
---@param status string
---@param callback StatusEventCallback
---@param removeAll boolean|nil
function RemoveStatusListener(event, status, callback, removeAll)
    local statusEventHolder = StatusListeners[event]
    if statusEventHolder then
        local tbl = statusEventHolder[status]
        if tbl then
            if removeAll ~= true then
                for i,v in pairs(tbl) do
                    if v == callback then
                        table.remove(tbl, i)
                    end
                end
            else
                statusEventHolder[status] = nil
            end
        end
    end
end

---@alias StatusTypeID string|'"CONSUME"'|'"DAMAGE"'|'"HEAL"'|'"HEALING"'|'"ACTIVE_DEFENSE"'|'"BLIND"'|'"CHALLENGE"'|'"CHARMED"'|'"DAMAGE_ON_MOVE"'|'"DEACTIVATED"'|'"DECAYING_TOUCH"'|'"DEMONIC_BARGAIN"'|'"DISARMED"'|'"EFFECT"'|'"EXTRA_TURN"'|'"FEAR"'|'"FLOATING"'|'"GUARDIAN_ANGEL"'|'"HEAL_SHARING_CASTER"'|'"HEAL_SHARING"'|'"INCAPACITATED"'|'"INVISIBLE"'|'"KNOCKED_DOWN"'|'"MUTED"'|'"PLAY_DEAD"'|'"POLYMORPHED"'|'"SPARK"'|'"STANCE"'

---@param event StatusEventID BeforeAttempt, Attempt, Applied, Removed
---@param statusType StatusTypeID|StatusTypeID[]
---@param callback StatusEventCallback
function RegisterStatusTypeListener(event, statusType, callback)
    local statusEventHolder = StatusTypeListeners[event]
	if statusEventHolder then
        if type(statusType) == "table" then
			for i,v in pairs(statusType) do
				RegisterStatusTypeListener(event, v, callback)
            end
        else
            if StringHelpers.Equals(statusType, "All", true) then
                statusType = "All"
            elseif Data.IgnoredStatus[statusType] == true then
                Vars.RegisteredIgnoredStatus[statusType] = true
            end

            if statusEventHolder[statusType] == nil then
                statusEventHolder[statusType] = {}
            end
            table.insert(statusEventHolder[statusType], callback)
        end
    end
end

---@param event StatusEventID
---@param statusType StatusTypeID|StatusTypeID[]
---@param callback StatusEventCallback
---@param removeAll boolean|nil
function RemoveStatusTypeListener(event, statusType, callback, removeAll)
    local statusEventHolder = StatusTypeListeners[event]
    if statusEventHolder then
        local tbl = statusEventHolder[statusType]
        if tbl then
            if removeAll ~= true then
                for i,v in pairs(tbl) do
                    if v == callback then
                        table.remove(tbl, i)
                    end
                end
            else
                statusEventHolder[statusType] = nil
            end
        end
    end
end

local function IgnoreStatus(status)
	if Data.IgnoredStatus[status] == true and Vars.RegisteredIgnoredStatus[status] ~= true then
		return true
	end
	return false
end

local redirectStatusType = {
	DAMAGE = true,
	DAMAGE_ON_MOVE = true,
	HIT = true,
	CHARMED = true,
}

local redirectStatusId = {
	TAUNTED = true,
	MADNESS = true,
}

local function TryGetStatus(target, handle)
	return Ext.GetStatus(target, handle)
end

local function InvokeStatusListeners(event, status, statusType, ...)
	local statusEventHolder, statusTypeEventHolder = StatusListeners[event], StatusTypeListeners[event]
	InvokeListenerCallbacks(statusEventHolder[status], ...)
	InvokeListenerCallbacks(statusEventHolder.All, ...)
	InvokeListenerCallbacks(statusTypeEventHolder[statusType], ...)
	InvokeListenerCallbacks(statusTypeEventHolder.All, ...)
end

---@param statusId string
---@param target EsvCharacter|EsvItem
---@param source EsvCharacter|EsvItem
---@param handle integer
local function BeforeStatusAttempt(statusId, target, source, handle, targetId, sourceId)
	local statusType = GameHelpers.Status.GetStatusType(statusId)
	--Crash fix
	if ObjectIsItem(targetId) == 1 and (statusId == "MADNESS" or statusType == "DAMAGE_ON_MOVE") then
		NRD_StatusPreventApply(targetId, handle, 1)
		return
	end
	local b,status = xpcall(TryGetStatus, debug.traceback, targetId, handle)
	if not b then
		if Vars.DebugMode then
			fprint(LOGLEVEL.ERROR, "[LeaderLib:BeforeStatusAttempt] Error getting status (%s) by handle(%s) for target(%s):\n%s", statusId, handle, target.MyGuid, status)
		end
		status = statusId
	end
	if target and source then 
		local canRedirect = redirectStatusId[statusId] or redirectStatusType[statusType]
		if canRedirect and source.Summon and source.OwnerHandle then
			if ObjectIsItem(sourceId) == 1 then
				--Set the source of statuses summoned items apply to their caster owner character.
				if source.Summon and source.OwnerHandle then
					if status then
						status.StatusSourceHandle = source.OwnerHandle
					else
						local owner = Ext.GetGameObject(source.OwnerHandle)
						if owner then
							NRD_StatusSetGuidString(targetId, handle, "StatusSourceHandle", owner.MyGuid)
						end
					end
					if Vars.DebugMode then
						fprint(LOGLEVEL.DEFAULT, "[BeforeStatusAttempt] Redirected status(%s) source from (%s) to owner (%s)", statusId, source.DisplayName, GameHelpers.Character.GetDisplayName(Ext.GetGameObject(source.OwnerHandle)))
					end
				end
			end
		elseif source:HasTag("LeaderLib_Dummy") then
			--Redirect the source of statuses applied by dummies to their owners
			local owner = GetVarObject(sourceId, "LeaderLib_Dummy_Owner")
			if not StringHelpers.IsNullOrEmpty(owner) then
				NRD_StatusSetGuidString(targetId, handle, "StatusSourceHandle", owner)
				if Vars.DebugMode then
					fprint(LOGLEVEL.DEFAULT, "[BeforeStatusAttempt] Redirected status(%s) source from (%s) to owner (%s)", statusId, source.DisplayName, GameHelpers.Character.GetDisplayName(Ext.GetCharacter(owner)))
				end
			end
		end
	end
	target = target or targetId
	source = source or sourceId
	InvokeStatusListeners(Vars.StatusEvent.BeforeAttempt, statusId, statusType, target, status, source, handle, statusType)
end

RegisterProtectedOsirisListener("NRD_OnStatusAttempt", 4, "after", function(target,status,handle,source)
	if not IgnoreStatus(status) then
		target = GameHelpers.GetUUID(target, true)
		source = GameHelpers.GetUUID(source, true)
		BeforeStatusAttempt(status, GameHelpers.TryGetObject(target, true), GameHelpers.TryGetObject(source, true), handle, target, source)
	end
end)

local function OnStatusAttempt(target,status,source)
	target = StringHelpers.GetUUID(target)
	source = StringHelpers.GetUUID(source)
	local statusType = GameHelpers.Status.GetStatusType(status)
	InvokeStatusListeners(Vars.StatusEvent.Attempt, status, statusType, target, status, source, statusType)
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
		---@type EsvCharacter|EsvItem
		local obj = Ext.GetGameObject(target)
		if obj then
			local activeStatus = obj:GetStatus(status)
			if activeStatus and activeStatus.StatusSourceHandle then
				local otherSource = Ext.GetGameObject(activeStatus.StatusSourceHandle)
				if otherSource and otherSource.MyGuid == source then
					canRemove = false
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
	local statusType = GameHelpers.Status.GetStatusType(status)
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
			local turns = GetStatusTurns(target, status) or 0
			if turns == 0 then
				GameHelpers.Skill.Explode(target, skill, source)
			elseif not StringHelpers.IsNullOrEmpty(source) then
				TrackStatusSource(target, status, source)
			end
		end
	end
	InvokeStatusListeners(Vars.StatusEvent.Applied, status, statusType, target, status, source, statusType)
	if forceStatuses[status] and not StringHelpers.IsNullOrEmpty(source) and ObjectIsCharacter(source) == 1 then
		--local distance = tonumber(string.gsub(status, "LEADERLIB_FORCE_PUSH", ""))
		GameHelpers.ForceMoveObject(Ext.GetCharacter(source), Ext.GetGameObject(target), forceStatuses[status])
	end
end

local function OnStatusRemoved(target,status)
	local statusType = GameHelpers.Status.GetStatusType(status)
	local source = nil
	if Vars.LeaveActionData.Total > 0 then
		source = GetStatusSource(target, status)
		if source then
			local skill = Vars.LeaveActionData.Statuses[status]
			if skill then
				GameHelpers.Skill.Explode(target, skill, source)
			end
		end
	end
	ClearStatusSource(target, status)
	if not source then
		source = StringHelpers.NULL_UUID
	end
	InvokeStatusListeners(Vars.StatusEvent.Removed, status, statusType, target, status, source, statusType)
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