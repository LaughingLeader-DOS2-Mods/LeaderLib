local _EXTVERSION = Ext.Utils.Version()

local _type = type
local _pairs = pairs
local _xpcall = xpcall

local _SGetUUID = StringHelpers.GetUUID
local _GetObject = GameHelpers.TryGetObject
local _GetObjectFromHandle = GameHelpers.GetObjectFromHandle
local _GetGameObject = Ext.Entity.GetGameObject
local _GetStatus = Ext.Entity.GetStatus
local _GetStatusType = GameHelpers.Status.GetStatusType
local _IsValidHandle = GameHelpers.IsValidHandle

---@alias StatusEventID string
---|"BeforeAttempt" # NRD_OnStatusAttempt
---|"Attempt" # CharacterStatusAttempt/ItemStatusAttempt
---|"Applied" # CharacterStatusApplied/ItemStatusChange
---|"GetEnterChance" # StatusGetEnterChance
---|"BeforeDelete" # Ext.Events.BeforeStatusDelete
---|"Removed" # CharacterStatusRemoved/ItemStatusRemoved

---Automatically set to true after GameStarted.
---This is a local variable, instead of a key in _INTERNAL, so the BeforeStatusDelete listener doesn't need to parse a table within a table for every status firing the event.
local _canBlockDeletion = false
local _canInvokeListeners = false

---@type ServerGameState
local _STATE = ""
local _ValidStates = {
	Running = true,
	Paused = true,
	GameMasterPause = true,
}

Ext.Events.GameStateChanged:Subscribe(function (e)
	_STATE = tostring(e.ToState)
	_canInvokeListeners = _ValidStates[_STATE] == true
	if not _ValidStates[_STATE] then
		_canBlockDeletion = false
	elseif not _canBlockDeletion then
		_canBlockDeletion = Vars.IsEditorMode or (SharedData.RegionData.State == REGIONSTATE.GAME and SharedData.RegionData.LevelType == LEVELTYPE.GAME)
	end
end)

Ext.Events.ResetCompleted:Subscribe(function (e)
	_canInvokeListeners = _ValidStates[tostring(Ext.Server.GetGameState())] == true
end)

if StatusManager == nil then
	StatusManager = {}
end
Managers.Status = StatusManager

---Allow BeforeAttempt and Attempt events to invoke on dead characters. Only specific engine statuses can apply to corpses, so this is normally ignored.
StatusManager.AllowDead = false

---@class StatusManagerInternals
---@field CanBlockDeletion boolean Whether the StatusManager can block status deletion in BeforeStatusDelete, for active permanent statuses.
local _INTERNAL = {
	EnabledStatuses = {
		---@type table<string, boolean>
		All = {},
		---@type table<string, boolean>
		BeforeAttempt = {},
		---@type table<string, boolean>
		Attempt = {},
		---@type table<string, boolean>
		Applied = {},
		---@type table<string, boolean>
		GetEnterChance = {},
		---@type table<string, boolean>
		BeforeDelete = {},
		---@type table<string, boolean>
		Removed = {},
	},
	EnableAll = {Status = false, Event = false}
}

local _enableAllMeta = {
	__index = function (_,k)
		if k == "All" then
			return true
		end
	end
}

for k,v in pairs(_INTERNAL.EnabledStatuses) do
	setmetatable(v, _enableAllMeta)
end

StatusManager._Internal = _INTERNAL

local _DisablingStatuses = {
	Initialized = false,
	---@type table<string, {IsDisabling:boolean, IsLoseControl:boolean}>
	Statuses = {
		CHARMED = {IsDisabling = false, IsLoseControl = true}
	},
}

_INTERNAL.DisablingStatuses = _DisablingStatuses

function _DisablingStatuses.UpdateStatuses()
	local statuses = {}
	--Preserves statuses mods may have added manually.
	for statusId,data in _pairs(_DisablingStatuses.Statuses) do
		statuses[statusId] = data
	end
	_DisablingStatuses.Statuses = {}
	for v in GameHelpers.Stats.GetStats("StatusData", true) do
		---@cast v -string
		local isDisabling,isLoseControl = GameHelpers.Status.IsDisablingStatus(v.Name, true, v)
		if isDisabling or isLoseControl then
			_DisablingStatuses.Statuses[v.Name] = {IsDisabling = isDisabling, IsLoseControl = isLoseControl}
		end
		if string.find(v.Name, "DUMMY") then
			Vars.DisableDummyStatusRedirection[v.Name] = true
		end
	end
	for name,data in pairs(statuses) do
		if not _DisablingStatuses.Statuses[name] then
			_DisablingStatuses.Statuses[name] = {IsDisablingStatus = data.IsDisabling == true, IsLoseControl = data.IsLoseControl == true}
		end
	end
	_DisablingStatuses.Initialized = true
end

Ext.Events.SessionLoaded:Subscribe(function()
	_DisablingStatuses.UpdateStatuses()
end)

StatusManager.Register = {}

local _INTERNALREG = {}
StatusManager.Subscribe = _INTERNALREG

---@param status string|string[]
---@param callback fun(e:OnStatusEventArgs)
---@param priority? integer
---@param statusEvent? StatusEventID
---@return integer|integer[] index
function _INTERNALREG.All(status, callback, priority, statusEvent)
	local t = _type(status)
	if t == "string" then
		if not statusEvent or not Vars.StatusEvent[statusEvent] then
			return Events.OnStatus:Subscribe(callback, {MatchArgs={StatusId=status}, Priority=priority})
		else
			return Events.OnStatus:Subscribe(callback, {MatchArgs={StatusId=status, StatusEvent=statusEvent}, Priority=priority})
		end
	elseif t == "table" then
		local indexes = {}
		for k,v in pairs(status) do
			indexes[#indexes+1] = _INTERNALREG.All(v, callback, priority, statusEvent)
		end
		return indexes
	else
		ferror("status(%s) param is not a valid type(%s)", status, t)
	end
end

---@param status string|string[]
---@param callback fun(e:OnStatusBeforeAttemptEventArgs)
---@param priority? integer
---@return integer|integer[] index
function _INTERNALREG.BeforeAttempt(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "BeforeAttempt")
end

---@param status string|string[]
---@param callback fun(e:OnStatusAttemptEventArgs)
---@param priority? integer
---@return integer|integer[] index
function _INTERNALREG.Attempt(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "Attempt")
end

---@param status string|string[]
---@param callback fun(e:OnStatusAppliedEventArgs)
---@param priority? integer
---@return integer|integer[] index
function _INTERNALREG.Applied(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "Applied")
end

---@param status string|string[]
---@param callback fun(e:OnStatusGetEnterChanceEventArgs)
---@param priority? integer
---@return integer|integer[] index
function _INTERNALREG.GetEnterChance(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "GetEnterChance")
end

---@param status string|string[]
---@param callback fun(e:OnStatusRemovedEventArgs)
---@param priority? integer
---@return integer|integer[] index
function _INTERNALREG.Removed(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "Removed")
end

---@param status string|string[]
---@param callback fun(e:OnStatusBeforeDeleteEventArgs)
---@param priority? integer
---@return integer|integer[] index
function _INTERNALREG.BeforeDelete(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "BeforeDelete")
end

---@alias LeaderLibStatusType string
---|"DISABLE" # Any status that returns true with GameHelpers.Status.IsDisablingStatus.
---|"LOSE_CONTROL" # Any status with IsLoseControl set to "Yes".
---|"DISABLE|LOSE_CONTROL" # Any status that has IsDisabling or IsLoseControl true in the status event.
---|StatStatusType

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusEventArgs) The function to call when this status event occurs
---@param priority? integer Optional listener priority
---@param statusEvent? StatusEventID The status event
---@param secondaryStatusType? StatStatusType If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.AllType(statusType, callback, priority, statusEvent, secondaryStatusType)
	local t = _type(statusType)
	if t == "string" then
		local matchArgs = nil
		if statusType == "DISABLE" then
			matchArgs = {IsDisabling=true, StatusEvent=statusEvent}
		elseif statusType == "LOSE_CONTROL" then
			matchArgs = {IsLoseControl=true, StatusEvent=statusEvent}
		elseif statusType == "DISABLE|LOSE_CONTROL" then
			---@param args OnStatusEventArgs
			matchArgs = function(args)
				if args.IsLoseControl == true or args.IsDisabling == true then
					local statusTypeMatch = not secondaryStatusType or args.StatusType == secondaryStatusType
					if statusEvent then
						return args.StatusEvent == statusEvent and statusTypeMatch
					else
						return statusTypeMatch
					end
				end
				return false
			end
		else
			matchArgs = {StatusType=statusType, StatusEvent=statusEvent}
		end
		return Events.OnStatus:Subscribe(callback, {MatchArgs=matchArgs, Priority=priority})
	elseif t == "table" then
		local indexes = {}
		for _,v in pairs(statusType) do
			indexes[#indexes+1] = _INTERNALREG.AllType(v, callback, priority, statusEvent, secondaryStatusType)
		end
		return indexes
	else
		ferror("status(%s) param is not a valid type(%s)", statusType, t)
	end
end

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusBeforeAttemptEventArgs) The function to call when this status event occurs
---@param priority? integer Optional listener priority
---@param secondaryStatusType? StatStatusType If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.BeforeAttemptType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "BeforeAttempt", secondaryStatusType)
end

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusAttemptEventArgs) The function to call when this status event occurs
---@param priority? integer Optional listener priority
---@param secondaryStatusType? StatStatusType If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.AttemptType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "Attempt", secondaryStatusType)
end

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusAppliedEventArgs) The function to call when this status event occurs
---@param priority? integer Optional listener priority
---@param secondaryStatusType? StatStatusType If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.AppliedType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "Applied", secondaryStatusType)
end

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusGetEnterChanceEventArgs) The function to call when this status event occurs
---@param priority? integer Optional listener priority
---@param secondaryStatusType? StatStatusType If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.GetEnterChanceType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "GetEnterChance", secondaryStatusType)
end

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusBeforeDeleteEventArgs) The function to call when this status event occurs
---@param priority? integer Optional listener priority
---@param secondaryStatusType? StatStatusType If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.BeforeDeleteType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "BeforeDelete", secondaryStatusType)
end

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusRemovedEventArgs) The function to call when this status event occurs
---@param priority? integer Optional listener priority
---@param secondaryStatusType? StatStatusType If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.RemovedType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "Removed", secondaryStatusType)
end

---If false is returned, the status will be blocked.
---@alias StatusManagerBeforeStatusAttemptCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID):boolean|nil
---@alias StatusManagerAttemptCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID)
---@alias StatusManagerAppliedCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID)
---Source is usually nil unless specifically tracked before the status is removed.
---@alias StatusManagerRemovedCallback fun(target:EsvCharacter|EsvItem, status:string, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID)

---@param callback function
local function CreateCallbackWrapper(callback)
	---@param e OnStatusEventArgs
	local callbackWrapper = function(e)
		callback(e.Target, e.Status or e.StatusId, e.Source, e.StatusType, e.StatusEvent)
	end
	return callbackWrapper
end

---@param status string|string[]
---@param callback StatusManagerBeforeStatusAttemptCallback If false is returned, the status will be blocked.
function StatusManager.Register.BeforeAttempt(status, callback, ...)
	local t = _type(status)
	if t == "table" then
		for i,v in _pairs(status) do
			StatusManager.Register.BeforeAttempt(v, callback, ...)
		end
	elseif t == "string" then
		local params = {...}

		---@param e OnStatusBeforeAttemptEventArgs
		local callbackWrapper = function(e)
			local b,result = _xpcall(callback, debug.traceback, e.Target, e.Status or e.StatusId, e.Source, e.StatusType, e.StatusEvent)
			if not b then
				error(result, 2)
			else
				if result == true then
					e.PreventApply = true
				elseif result == true then
					e.PreventApply = false
				end
			end
		end
		_INTERNALREG.BeforeAttempt(status, callbackWrapper)
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.BeforeAttempt] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---@param status string|string[]
---@param callback StatusManagerAttemptCallback
function StatusManager.Register.Attempt(status, callback)
	local t = _type(status)
	if t == "table" then
		for i,v in _pairs(status) do
			StatusManager.Register.Attempt(v, callback)
		end
	elseif t == "string" then
		_INTERNALREG.Attempt(status, CreateCallbackWrapper(callback))
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Attempt] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---@param status string|string[]
---@param callback StatusManagerAppliedCallback
---@vararg SerializableValue
function StatusManager.Register.Applied(status, callback)
	local t = _type(status)
	if t == "table" then
		for i,v in _pairs(status) do
			StatusManager.Register.Applied(v, callback)
		end
	elseif t == "string" then
		_INTERNALREG.Applied(status, CreateCallbackWrapper(callback))
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Applied] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---@param status string|string[]
---@param callback StatusManagerRemovedCallback
function StatusManager.Register.Removed(status, callback)
	local t = _type(status)
	if t == "table" then
		for i,v in _pairs(status) do
			StatusManager.Register.Removed(v, callback)
		end
	elseif t == "string" then
		_INTERNALREG.Removed(status, CreateCallbackWrapper(callback))
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Removed] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---Register a status listener for every state of a status.
---@param status string|string[]
---@param callback StatusManagerBeforeStatusAttemptCallback|StatusManagerAttemptCallback|StatusManagerRemovedCallback|StatusManagerAppliedCallback
function StatusManager.Register.All(status, callback, ...)
	local t = _type(status)
	if t == "table" then
		for i,v in _pairs(status) do
			StatusManager.Register.All(v, callback, ...)
		end
	elseif t == "string" then
		StatusManager.Register.BeforeAttempt(status, callback, ...)
		StatusManager.Register.Attempt(status, callback, ...)
		StatusManager.Register.Applied(status, callback, ...)
		StatusManager.Register.Removed(status, callback, ...)
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.All] Invalid type for status param(%s) value (%s)", t, status)
	end
end

StatusManager.Register.Type = {
	---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
	---@param callback StatusManagerBeforeStatusAttemptCallback If false is returned, the status will be blocked.
	BeforeAttempt = function(statusType, callback)
		local t = _type(statusType)
		if t == "table" then
			for i,v in _pairs(statusType) do
				StatusManager.Register.Type.BeforeAttempt(v, callback)
			end
		elseif t == "string" then
			---@param e OnStatusBeforeAttemptEventArgs
			local callbackWrapper = function(e)
				local b,result = _xpcall(callback, debug.traceback, e.Target, e.Status or e.StatusId, e.Source, e.StatusType, e.StatusEvent)
				if not b then
					error(result, 2)
				else
					if result == true then
						e.PreventApply = true
					elseif result == true then
						e.PreventApply = false
					end
				end
			end
			_INTERNALREG.BeforeAttemptType(statusType, callbackWrapper)
		else
			fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Type.BeforeAttempt] Invalid type for statusType param(%s) value (%s)", t, statusType)
		end
	end,

	---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
	---@param callback StatusManagerAttemptCallback
	Attempt = function(statusType, callback)
		local t = _type(statusType)
		if t == "table" then
			for i,v in _pairs(statusType) do
				StatusManager.Register.Type.Attempt(v, callback)
			end
		elseif t == "string" then
			_INTERNALREG.Attempt(statusType, CreateCallbackWrapper(callback))
		else
			fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Type.Attempt] Invalid type for statusType param(%s) value (%s)", t, statusType)
		end
	end,

	---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
	---@param callback StatusManagerAppliedCallback
	Applied = function(statusType, callback)
		local t = _type(statusType)
		if t == "table" then
			for i,v in _pairs(statusType) do
				StatusManager.Register.Type.Applied(v, callback)
			end
		elseif t == "string" then
			_INTERNALREG.AppliedType(statusType, CreateCallbackWrapper(callback))
		else
			fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Type.Applied] Invalid type for statusType param(%s) value (%s)", t, statusType)
		end
	end,

	---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
	---@param callback StatusManagerRemovedCallback
	Removed = function(statusType, callback)
		local t = _type(statusType)
		if t == "table" then
			for i,v in _pairs(statusType) do
				StatusManager.Register.Type.Removed(v, callback)
			end
		elseif t == "string" then
			_INTERNALREG.RemovedType(statusType, CreateCallbackWrapper(callback))
		else
			fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Type.Attempt] Invalid type for statusType param(%s) value (%s)", t, statusType)
		end
	end,

	---Register a statusType listener for every state of a statusType.
	---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
	---@param callback StatusManagerBeforeStatusAttemptCallback|StatusManagerAttemptCallback|StatusManagerRemovedCallback|StatusManagerAppliedCallback
	All = function(statusType, callback)
		local t = _type(statusType)
		if t == "table" then
			for i,v in _pairs(statusType) do
				StatusManager.Register.Type.All(v, callback)
			end
		elseif t == "string" then
			StatusManager.Register.Type.BeforeAttempt(statusType, callback)
			StatusManager.Register.Type.Attempt(statusType, callback)
			StatusManager.Register.Type.Applied(statusType, callback)
			StatusManager.Register.Type.Removed(statusType, callback)
		else
			fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Type.All] Invalid type for statusType param(%s) value (%s)", t, statusType)
		end
	end
}

---@param target ObjectParam
---@param status string|string[]
---@return boolean isActive
---@return string|nil statusID
function StatusManager.IsPermanentStatusActive(target, status)
	local GUID = GameHelpers.GetUUID(target)
	fassert(GUID ~= nil, "Target parameter type (%s) is invalid. An EsvCharacter, EsvItem, UUID, or NetID should be provided.", target)
	if _PV.ActivePermanentStatuses[GUID] then
		local t = _type(status)
		if t == "table" then
			for i=1,#status do
				if _PV.ActivePermanentStatuses[GUID][status[i]] ~= nil then
					return true,status[i]
				end
			end
			return false
		elseif t == "string" then
			if _PV.ActivePermanentStatuses[GUID][status] ~= nil then
				return true,status
			end
		else
			error(string.format("Invalid status param (%s) type(%s)", status, t), 2)
		end
	end

	return false,nil
end

---@param target ObjectParam
---@param status string
---@param enabled boolean
---@param source? ObjectParam A source to use when applying the status, if any. Defaults to the target.
function _INTERNAL.SetPermanentStatus(target, status, enabled, source)
	local GUID = GameHelpers.GetUUID(target)
	local statusIsActive = GameHelpers.Status.IsActive(target, status)
	if not enabled then
		local changed = false
		if _PV.ActivePermanentStatuses[GUID] then
			changed = _PV.ActivePermanentStatuses[GUID][status] ~= nil
			_PV.ActivePermanentStatuses[GUID][status] = nil
			if Common.TableLength(_PV.ActivePermanentStatuses[GUID], true) == 0 then
				_PV.ActivePermanentStatuses[GUID] = nil
				changed = true
			end
		end
		if changed then
			GameHelpers.Net.Broadcast("LeaderLib_UpdatePermanentStatuses", {Target=GameHelpers.GetNetID(target), StatusId = status, Enabled = false})
		end

		if statusIsActive then
			GameHelpers.Status.Remove(target, status)
			statusIsActive = false
		end
	else
		local changed = false
		if _PV.ActivePermanentStatuses[GUID] == nil then
			_PV.ActivePermanentStatuses[GUID] = {}
			changed = true
		end
		changed = changed or _PV.ActivePermanentStatuses[GUID][status] == nil
		local sourceId = source and GameHelpers.GetUUID(source) or GUID
		_PV.ActivePermanentStatuses[GUID][status] = sourceId
		if changed then
			GameHelpers.Net.Broadcast("LeaderLib_UpdatePermanentStatuses", {Target=GameHelpers.GetNetID(target), StatusId = status, Enabled = true})
		end
		if not statusIsActive then
			--fassert(_type(status) == "string" and GameHelpers.Stats.Exists(status), "Status (%s) does not exist.", status)
			GameHelpers.Status.Apply(target, status, -1.0, true, sourceId or GUID)
			statusIsActive = true
		end
	end
	return statusIsActive
end

---Applies permanent status. The given status will be blocked from deletion.
---@param target ObjectParam
---@param status string|string[]
---@param source? ObjectParam A source to use when applying the status, if any. Defaults to the target.
---@return boolean isActive Returns whether the permanent status is active or not.
function StatusManager.ApplyPermanentStatus(target, status, source)
	local t = _type(status)
	if t == "table" then
		local success = false
		for i=1,#status do
			if StatusManager.ApplyPermanentStatus(target, status[i]) then
				success = true
			end
		end
		return success
	elseif t == "string" then
		return _INTERNAL.SetPermanentStatus(target, status, true, source)
	else
		error(string.format("Invalid status param (%s) type(%s)", status, t), 2)
	end
end

---Remove a registered permanent status for the given character.
---@param target ObjectParam
---@param status string|string[]
function StatusManager.RemovePermanentStatus(target, status)
	local t = _type(status)
	if t == "table" then
		local success = false
		for i=1,#status do
			if StatusManager.RemovePermanentStatus(target, status[i]) then
				success = true
			end
		end
		return success
	elseif t == "string" then
		return _INTERNAL.SetPermanentStatus(target, status, false)
	else
		error(string.format("Invalid status param (%s) type(%s)", status, t), 2)
	end
end

---Removed all registered permanent statuses for the given character.
---@param target ObjectParam
function StatusManager.RemoveAllPermanentStatuses(target)
	local GUID = GameHelpers.GetUUID(target)
	if GUID and _PV.ActivePermanentStatuses then
		local statuses = _PV.ActivePermanentStatuses[GUID]
		if statuses then
			target = GameHelpers.GetCharacter(target)
			if target then
				for id,source in _pairs(statuses) do
					local duration = GameHelpers.Status.GetDuration(target, id)
					if duration == -1 then
						GameHelpers.Status.Remove(GUID, id)
					end
				end
			end
			_PV.ActivePermanentStatuses[GUID] = nil
			GameHelpers.Net.Broadcast("LeaderLib_RemovePermanentStatuses", GameHelpers.GetNetID(target))
		end
	end
end

---Makes a permanent status active or not, depending on if it's active already. The given status will be blocked from deletion.
---@param target ObjectParam
---@param status string
---@param source? ObjectParam A source to use when applying the status, if any. Defaults to the target.
---@return boolean isActive Returns whether the permanent status is active or not.
function StatusManager.TogglePermanentStatus(target, status, source)
	return _INTERNAL.SetPermanentStatus(target, status, not StatusManager.IsPermanentStatusActive(target, status), source)
end

---@class ExtenderBeforeStatusDeleteEventParams
---@field Status EsvStatus
---@field PreventAction fun(self:ExtenderBeforeStatusDeleteEventParams)

---@param e ExtenderBeforeStatusDeleteEventParams
local function OnBeforeStatusDelete(e)
	local target = _GetObjectFromHandle(e.Status.TargetHandle, "EsvCharacter")
	if not target then
		return true
	end
	local targetGUID = target.MyGuid
	local statusType = e.Status.StatusType

	local source = _GetObjectFromHandle(e.Status.StatusSourceHandle, "EsvCharacter")
	local sourceGUID = StringHelpers.NULL_UUID

	if source then
		sourceGUID = source.MyGuid
	end

	local isDisabling = false
	local isLoseControl = false

	local disablingData = _DisablingStatuses.Statuses[e.Status.StatusId]
	if disablingData then
		isDisabling = disablingData.IsDisabling == true
		isLoseControl = disablingData.IsLoseControl == true
	end

	---@type SubscribableEventInvokeResult<OnStatusBeforeDeleteEventArgs>
	local result = Events.OnStatus:Invoke({
		Target = target,
		Source = source,
		TargetGUID = targetGUID,
		SourceGUID = sourceGUID,
		Status = e.Status,
		StatusId = e.Status.StatusId,
		StatusEvent = "BeforeDelete",
		StatusType = statusType,
		PreventDelete = false,
		IsDisabling = isDisabling,
		IsLoseControl = isLoseControl
	})

	if result.ResultCode ~= "Error" and result.Args.PreventDelete == true then
		e:PreventAction()
	end

	return false
end

---@param e ExtenderBeforeStatusDeleteEventParams
Ext.Events.BeforeStatusDelete:Subscribe(function (e)
	if _canInvokeListeners and _IsValidHandle(e.Status.TargetHandle) then
		local skipped = OnBeforeStatusDelete(e)
		if not skipped and _canBlockDeletion and not e.ActionPrevented and e.Status.LifeTime == -1 then
			local target = _GetObjectFromHandle(e.Status.TargetHandle, "EsvCharacter")
			if target ~= nil and StatusManager.IsPermanentStatusActive(target.MyGuid, e.Status.StatusId) and not GameHelpers.ObjectIsDead(target) then
				e:PreventAction()
			end
		end
	end
end)

---Removes data for objects that no longer exist
---@param checkObjectExistance? boolean
function _INTERNAL.SanityCheckData(checkObjectExistance)
	local updateData = {}
	local doReplaceData = false
	for guid,statuses in _pairs(_PV.ActivePermanentStatuses) do
		local exists = GameHelpers.ObjectExists(guid)
		if not checkObjectExistance or exists then
			local statusData = {}
			local doUpdateStatusData = false
			for id,source in _pairs(statuses) do
				if GameHelpers.Stats.Exists(id, "StatusData") then
					statusData[id] = source
					doUpdateStatusData = true
				end
			end 
			if doUpdateStatusData then
				updateData[guid] = statusData
				doReplaceData = true
			end
		elseif not exists then
			doReplaceData = true
		end
	end
	if doReplaceData then
		_PV.ActivePermanentStatuses = updateData
	end
end

Events.RegionChanged:Subscribe(function (e)
	_canBlockDeletion = e.State == REGIONSTATE.GAME and e.LevelType == LEVELTYPE.GAME
end)

local function _TryReapply(uuid, statuses)
	local target = _GetObject(uuid)
	if target then
		for id,source in _pairs(statuses) do
			if not GameHelpers.Status.IsActive(target, id) then
				GameHelpers.Status.Apply(target, id, -1, true, source)
			end
		end
		return true
	end
	return false
end

function _INTERNAL.ReapplyPermanentStatuses()
	if _PV.ActivePermanentStatuses then
		local updateData = {}
		local doReplaceData = false
		for uuid,statuses in _pairs(_PV.ActivePermanentStatuses) do
			local _,b = pcall(_TryReapply, uuid, statuses)
			if b then
				updateData[uuid] = statuses
			else
				doReplaceData = true
			end
		end
		if doReplaceData then
			_PV.ActivePermanentStatuses = updateData
		end
	end
end

Events.PersistentVarsLoaded:Subscribe(function ()
	_INTERNAL.SanityCheckData(true)
	_INTERNAL.ReapplyPermanentStatuses()
end)

function _INTERNAL.SyncData(userID)
	local data = {}
	local hasData = false
	if _PV.ActivePermanentStatuses then
		for uuid,statuses in _pairs(_PV.ActivePermanentStatuses) do
			if GameHelpers.ObjectExists(uuid) then
				local netid = GameHelpers.GetNetID(uuid)
				if netid then
					data[netid] = {}
					for id,source in _pairs(statuses) do
						data[netid][id] = true
						hasData = true
					end
				end
			end
		end
	end
	if hasData then
		if userID then
			GameHelpers.Net.PostToUser(userID, "LeaderLib_UpdateAllPermanentStatuses", data)
		else
			GameHelpers.Net.Broadcast("LeaderLib_UpdateAllPermanentStatuses", data)
		end
	end
end

Events.SyncData:Subscribe(function (e)
	_INTERNAL.SyncData(e.UserID)
end)

---@param character EsvCharacter
---@param refreshStatBoosts? boolean If true, active statuses with stat boosts will be re-applied.
function StatusManager.ReapplyPermanentStatusesForCharacter(character, refreshStatBoosts)
	character = GameHelpers.GetCharacter(character, "EsvCharacter")
	assert(character ~= nil, "An EsvCharacter, NetID, or UUID is required")
	local permanentStatuses = _PV.ActivePermanentStatuses[character.MyGuid]
	if permanentStatuses then
		for id,source in _pairs(permanentStatuses) do
			if not GameHelpers.Status.IsActive(character, id) or (refreshStatBoosts and GameHelpers.Status.HasStatBoosts(id)) then
				GameHelpers.Status.Apply(character, id, -1, true, source)
				GameHelpers.Net.Broadcast("LeaderLib_UpdatePermanentStatuses", {Target=character.NetID, StatusId = id, Enabled = true})
			end
		end
	end
end

Events.CharacterLeveledUp:Subscribe(function(e)
	if _PV.ActivePermanentStatuses[e.Character.MyGuid] ~= nil then
		Timer.StartObjectTimer("LeaderLib_StatusManager_ReapplyPermanentStatuses", e.Character, 1000, {RefreshBoosts=true})
	end
end)

Timer.Subscribe("LeaderLib_StatusManager_ReapplyPermanentStatuses", function (e)
	if e.Data.Object then
		StatusManager.ReapplyPermanentStatusesForCharacter(e.Data.Object, e.Data.RefreshBoosts == true)
	end
end)

Events.CharacterResurrected:Subscribe(function(e)
	StatusManager.ReapplyPermanentStatusesForCharacter(e.Character)
end)

--#region Status Events

local function IsRegistered(status, statusEvent)
	if _INTERNAL.EnabledStatuses.All[status] then
		return true
	end
	return _INTERNAL.EnabledStatuses[statusEvent][status] == true
end

local function IgnoreStatus(status, statusEvent)
	if IsRegistered(status, statusEvent) then
		return false
	end
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

local _DEAD_ALLOWED_STATUS = {
	HIT = true,
	DYING = true,
	TELEPORT_FALLING = true,
	COMBAT = true,
	STORY_FROZEN = true,
	BOOST = true,
	UNSHEATHED = true,
	LYING = true,
	ROTATE = true,
	EXPLODE = true,
	DRAIN = true,
	LINGERING_WOUNDS = true,
	CHALLENGE = true,
}

local function IgnoreDead(target, status)
	if StatusManager.AllowDead then
		return false
	end
	if GameHelpers.ObjectIsDead(target) and not _DEAD_ALLOWED_STATUS[status] then
		return true
	end
	return false
end

Ext.Events.BeforeStatusApply:Subscribe(function (e)
	if not _IsValidHandle(e.Status.TargetHandle) then
		return
	end
	if e.Status.StatusId == "LEADERLIB_RECALC" and e.Status.LifeTime ~= 0 then
		e.Status.CurrentLifeTime = 0
		e.Status.LifeTime = 0
		e.Status.RequestClientSync = true
		e:StopPropagation()
		return
	end

	local target = _GetObjectFromHandle(e.Status.TargetHandle, "EsvCharacter")
	if not target then return end
	local source = _GetObjectFromHandle(e.Status.StatusSourceHandle, "EsvCharacter")

	local targetGUID = target.MyGuid
	local sourceGUID = source and source.MyGuid or StringHelpers.NULL_UUID

	local isCharacter = GameHelpers.Ext.ObjectIsCharacter(target)
	local isItem = not isCharacter and GameHelpers.Ext.ObjectIsItem(target)

	local status = e.Status
	local statusID = status.StatusId

	if statusID == "EXPLODE" and Features.FixExplode and not GameHelpers.ObjectIsDead(target) then
		e.PreventStatusApply = true
		e:StopPropagation()
		local projectileSkill = e.Status.Projectile
		if not StringHelpers.IsNullOrEmpty(projectileSkill) then
			if string.sub(projectileSkill, 1, 10) == "Projectile" then
				GameHelpers.Skill.Explode(target, projectileSkill, source)
			else
				GameHelpers.Damage.ApplySkillDamage(source, target, projectileSkill)
			end
		end
		return
	end

	if statusID == "DYING" and isCharacter then
		Events.CharacterDied:Invoke({
			Character = target,
			CharacterGUID = targetGUID,
			IsPlayer = GameHelpers.Character.IsPlayer(target),
			State = "StatusBeforeAttempt",
			StateIndex = Vars.CharacterDiedState.StatusBeforeAttempt,
		})
	end

	if IgnoreDead(target, statusID) then
		return
	end
	local statusType = status.StatusType
	if isItem and (statusID == "MADNESS" or statusType == "DAMAGE_ON_MOVE") then
		e.PreventStatusApply = true
		e:StopPropagation()
		return
	end

	if not IgnoreStatus(statusID, "BeforeAttempt") then
		local preventApply = false

		local settings = SettingsManager.GetMod(ModuleUUID, false, false)

		--Make Unhealable block all heals
		if target:GetStatus("UNHEALABLE")
		and ((statusType == "HEAL" or statusType == "HEALING") and status.HealAmount > 0)
		and settings.Global:FlagEquals("LeaderLib_UnhealableFix_Enabled", true) then
			e.PreventStatusApply = true
			preventApply = true
		end

		if source then
			local canRedirect = redirectStatusId[statusID] or redirectStatusType[statusType]
			if canRedirect and source.Summon and _IsValidHandle(source.OwnerHandle) and GameHelpers.Ext.ObjectIsItem(source) then
				--Set the source of statuses summoned items apply to their caster owner character.
				local owner =  _GetObject(source.OwnerHandle)
				if owner then
					status.StatusSourceHandle = owner.Handle
					source = owner
					sourceGUID = owner.MyGuid
				end
			elseif source:HasTag("LeaderLib_Dummy") and Vars.DisableDummyStatusRedirection[statusID] ~= true then
				--Redirect the source of statuses applied by dummies to their owners
				local owner = Osi.GetVarObject(sourceGUID, "LeaderLib_Dummy_Owner")
				if not StringHelpers.IsNullOrEmpty(owner) and Osi.ObjectExists(owner) == 1 then
					owner = _GetObject(owner)
					if owner then
						status.StatusSourceHandle = owner.Handle
						source = owner
						sourceGUID = owner.MyGuid
					end
				end
			end
		end

		local isDisabling = false
		local isLoseControl = false

		local disablingData = _DisablingStatuses.Statuses[statusID]
		if disablingData then
			isDisabling = disablingData.IsDisabling == true
			isLoseControl = disablingData.IsLoseControl == true
		end

		---@type SubscribableEventInvokeResult<OnStatusBeforeAttemptEventArgs>
		local result = Events.OnStatus:Invoke({
			Target = target,
			Source = source,
			Status = status or statusID,
			TargetGUID = targetGUID,
			SourceGUID = sourceGUID,
			StatusId = statusID,
			StatusEvent = "BeforeAttempt",
			StatusType = statusType,
			PreventApply = preventApply,
			IsDisabling = isDisabling,
			IsLoseControl = isLoseControl
		})
		if result.ResultCode ~= "Error" and result.Args.PreventApply ~= nil then
			e.PreventStatusApply = result.Args.PreventApply == true
		end
	end
end, {Priority=200})

local function OnStatusAttempt(targetGUID,statusID,sourceGUID)
	local target = _GetObject(targetGUID)
	local source = _GetObject(sourceGUID)
	
	if not target then
		return
	end
	
	local statusType = _GetStatusType(statusID)

	local statusObject = nil

	if target.StatusMachine then
		--Get the last status first, since it's more likely to be the attempted one
		local len = #target.StatusMachine.Statuses
		for i=len,1,-1 do
			local v = target.StatusMachine.Statuses[i]
			if v and v.StatusId == statusID then
				statusObject = v
				break
			end
		end
	end

	local isDisabling = false
	local isLoseControl = false

	local disablingData = _DisablingStatuses.Statuses[statusID]
	if disablingData then
		isDisabling = disablingData.IsDisabling == true
		isLoseControl = disablingData.IsLoseControl == true
	end

	Events.OnStatus:Invoke({
		Target = target,
		Source = source,
		TargetGUID = targetGUID,
		SourceGUID = sourceGUID,
		Status = statusObject or statusID,
		StatusId = statusID,
		StatusEvent = "Attempt",
		StatusType = statusType,
		IsDisabling = isDisabling,
		IsLoseControl = isLoseControl
	})
end

--SetVarFixedString("702becec-f2c1-44b2-b7ab-c247f8da97ac", "LeaderLib_RemoveStatusInfluence_ID", "WARM"); SetStoryEvent("702becec-f2c1-44b2-b7ab-c247f8da97ac", "LeaderLib_Commands_RemoveStatusInfluence")

local function ParseStatusAttempt(targetGUID,statusID,sourceGUID,skip)
	if not skip and Osi.ObjectExists(targetGUID) == 0 then
		return
	end
	if not _canInvokeListeners or IgnoreDead(targetGUID, statusID) then
		return
	end
	if not IgnoreStatus(statusID, "Attempt") then
		targetGUID = _SGetUUID(targetGUID)
		sourceGUID = _SGetUUID(sourceGUID)
		OnStatusAttempt(targetGUID, statusID, sourceGUID)
	end
end

RegisterProtectedOsirisListener("CharacterStatusAttempt", 3, "after", function (targetGUID, statusID, sourceGUID)
	if Osi.ObjectExists(targetGUID) == 0 then
		return
	end
	if statusID == "DYING" then
		local target = GameHelpers.GetCharacter(targetGUID)
		if target then
			Events.CharacterDied:Invoke({
				Character = target,
				CharacterGUID = target.MyGuid,
				IsPlayer = GameHelpers.Character.IsPlayer(target),
				State = "StatusAttempt",
				StateIndex = Vars.CharacterDiedState.StatusAttempt,
			})
		end
	end
	ParseStatusAttempt(targetGUID, statusID, sourceGUID, true)
end)
RegisterProtectedOsirisListener("ItemStatusAttempt", 3, "after", ParseStatusAttempt)

local function TrackStatusSource(target, status, source)
	if _PV.StatusSource[status] == nil then
		_PV.StatusSource[status] = {}
	end
	_PV.StatusSource[status][target] = source
end

local function GetStatusSource(target, status)
	if _PV.StatusSource[status] ~= nil then
		return _PV.StatusSource[status][target]
	end
	return nil
end

local function ClearStatusSource(target, status, source)
	if _PV.StatusSource[status] ~= nil then
		local canRemove = true
		local obj = _GetObject(target)
		if obj then
			local activeStatus = obj:GetStatus(status)
			if activeStatus and _IsValidHandle(activeStatus.StatusSourceHandle) then
				local otherSource = _GetGameObject(activeStatus.StatusSourceHandle)
				if otherSource and otherSource.MyGuid == source then
					canRemove = false
				end
			end
		end
		if canRemove then
			_PV.StatusSource[status][target] = nil
			if not Common.TableHasEntry(_PV.StatusSource[status]) then
				_PV.StatusSource[status] = nil
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

local _destroyingItems = {}

Events.Osiris.ItemDestroying:Subscribe(function (e)
	_destroyingItems[e.ItemGUID] = true
end)

Events.Osiris.ItemDestroyed:Subscribe(function (e)
	_destroyingItems[e.ItemGUID] = nil
end)

local function OnStatusApplied(targetGUID,statusID,sourceGUID)
	local target = _GetObject(targetGUID)
	local source = _GetObject(sourceGUID)
	
	if not target then
		return
	end

	if statusID == "SUMMONING" and target then
		local owner = nil
		if _IsValidHandle(target.OwnerHandle) then
			owner = _GetObject(target.OwnerHandle)
		end
		if owner then
			if not _PV.Summons[owner.MyGuid] then
				_PV.Summons[owner.MyGuid] = {}
			end
			table.insert(_PV.Summons[owner.MyGuid], target.MyGuid)
		end
		local isItem = false
		local isDying = false
		if _destroyingItems[targetGUID] then
			isItem = true
			isDying = true
		else
			isDying = GameHelpers.ObjectIsDead(target)
			isItem = GameHelpers.Ext.ObjectIsItem(target)
		end
		local data = {
			Summon=target, 
			SummonGUID=target.MyGuid,
			Owner=owner,
			OwnerGUID=owner and owner.MyGuid or nil,
			IsDying=isDying,
			IsItem=isItem,
			IsTotem=target.Totem
		}
		Events.SummonChanged:Invoke(data)

		if not isDying then
			local summonHandle = target.Handle
			local ownerHande = owner and owner.Handle or nil
			Timer.StartOneshot("", 25, function (_)
				data.Summon = GameHelpers.GetObjectFromHandle(summonHandle)
				if ownerHande then
					data.Owner = GameHelpers.GetObjectFromHandle(ownerHande)
				else
					data.Owner = nil
				end
				Events.SummonChanged:DoSyncInvoke(data)
			end)
		else
			Events.SummonChanged:DoSyncInvoke(data)
		end
	end
	
	local status = target:GetStatus(statusID)
	if not status then
		return
	end
	local statusType = _GetStatusType(statusID)

	if Vars.LeaveActionData.Total > 0 then
		local skill = Vars.LeaveActionData.Statuses[statusID]
		if skill then
			if status.CurrentLifeTime == 0 then
				GameHelpers.Skill.Explode(target, skill, source)
			elseif not StringHelpers.IsNullOrEmpty(sourceGUID) then
				TrackStatusSource(targetGUID, statusID, sourceGUID)
			end
		end
	end

	local isDisabling = false
	local isLoseControl = false

	local disablingData = _DisablingStatuses.Statuses[statusID]
	if disablingData then
		isDisabling = disablingData.IsDisabling == true
		isLoseControl = disablingData.IsLoseControl == true
	end

	if statusID == "SHOCKWAVE" and Features.PreventShockwaveEndTurn then
		local isActiveTurn,combatComponent = GameHelpers.Combat.IsActiveTurn(target)
		if isActiveTurn and combatComponent.RequestEndTurn and target.Stats.CurrentAP > 0
		and not GameHelpers.Status.HasStatusType(target, {"KNOCKED_DOWN", "INCAPACITATED"}, {SHOCKWAVE=true}) then
			combatComponent.RequestEndTurn = false
		end
	end

	Events.OnStatus:Invoke({
		Target = target,
		Source = source,
		Status = status or statusID,
		TargetGUID = targetGUID,
		SourceGUID = sourceGUID,
		StatusId = statusID,
		StatusEvent = "Applied",
		StatusType = statusType,
		IsDisabling = isDisabling,
		IsLoseControl = isLoseControl
	})

	if forceStatuses[statusID] and target and source then
		GameHelpers.ForceMoveObject(source, target, forceStatuses[status], nil, target.WorldPos)
	end
end

local function ParseStatusApplied(target,status,source,skip)
	if not skip and Osi.ObjectExists(target) == 0 then
		return
	end
	if _canInvokeListeners and not IgnoreStatus(status, "Applied") then
		target = _SGetUUID(target)
		source = _SGetUUID(source)
		OnStatusApplied(target, status, source)
	end
end

local function OnStatusRemoved(targetGUID,statusID,sourceGUID)
	local target = nil
	if Osi.ObjectExists(targetGUID) == 1 then
		target = _GetObject(targetGUID)
	end
	local statusType = _GetStatusType(statusID)
	local source = nil
	if Vars.LeaveActionData.Total > 0 then
		sourceGUID = GetStatusSource(targetGUID, statusID)
		if sourceGUID then
			source = _GetObject(sourceGUID)
			local skill = Vars.LeaveActionData.Statuses[statusID]
			if skill then
				GameHelpers.Skill.Explode(target, skill, source)
			end
		else
			sourceGUID = StringHelpers.NULL_UUID
		end
	end
	ClearStatusSource(targetGUID, statusID)
	local isDisabling = false
	local isLoseControl = false

	local disablingData = _DisablingStatuses.Statuses[statusID]
	if disablingData then
		isDisabling = disablingData.IsDisabling == true
		isLoseControl = disablingData.IsLoseControl == true
	end
	Events.OnStatus:Invoke({
		Target = target,
		Source = source,
		TargetGUID = targetGUID,
		SourceGUID = sourceGUID,
		Status = statusID,
		StatusId = statusID,
		StatusEvent = "Removed",
		StatusType = statusType,
		IsDisabling = isDisabling,
		IsLoseControl = isLoseControl
	})
end

local function ParseStatusRemoved(target,status)
	if _canInvokeListeners and not IgnoreStatus(status, "Removed") then
		target = _SGetUUID(target)
		OnStatusRemoved(target, status)
	end
end

RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", function (targetGUID, statusID, sourceGUID)
	if Osi.ObjectExists(targetGUID) == 0 then
		return
	end
	if statusID == "DYING" then
		local target = GameHelpers.GetCharacter(targetGUID)
		if target then
			Events.CharacterDied:Invoke({
				Character = target,
				CharacterGUID = target.MyGuid,
				IsPlayer = GameHelpers.Character.IsPlayer(target),
				State = "StatusApplied",
				StateIndex = Vars.CharacterDiedState.StatusApplied,
			})
		end
	end
	ParseStatusApplied(targetGUID, statusID, sourceGUID, true)
end)
RegisterProtectedOsirisListener("ItemStatusChange", 3, "after", ParseStatusApplied)
RegisterProtectedOsirisListener("CharacterStatusRemoved", 3, "before", ParseStatusRemoved)
RegisterProtectedOsirisListener("ItemStatusRemoved", 3, "before", ParseStatusRemoved)
--#endregion

setmetatable(_INTERNAL, {
	__index = function (_,k)
		if k == "CanBlockDeletion" then
			return _canBlockDeletion
		end
	end,
	__newindex = function (_,k,v)
		--In case a mod needs to disable this functionality
		if k == "CanBlockDeletion" then
			_canBlockDeletion = v == true
		end
	end
})

--#region Deprecated

---@alias BeforeStatusAttemptCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, handle:integer, statusType:string)
---@alias StatusEventCallback fun(target:string, status:string, source:string|nil, statusType:string)

---@deprecated
---@param event StatusEventID BeforeAttempt, Attempt, Applied, Removed
---@param status string|string[] A status id or status type.
---@param callback StatusEventCallback
function RegisterStatusListener(event, status, callback)
	local t = _type(status)
	if t == "table" then
		for i,v in _pairs(status) do
			---@diagnostic disable-next-line
			RegisterStatusListener(event, v, callback)
		end
	elseif t == "string" then
		if StringHelpers.Equals(status, "All", true) then
			Events.OnStatus:Subscribe(function (e)
				callback(e.TargetGUID, e.StatusId, e.SourceGUID, e.StatusType)
			end, {MatchArgs={StatusId="All", StatusEvent=event}})
			return true
		elseif Data.IgnoredStatus[status] == true then
			Vars.RegisteredIgnoredStatus[status] = true
		end
		Events.OnStatus:Subscribe(function (e)
			callback(e.TargetGUID, e.StatusId, e.SourceGUID, e.StatusType)
		end, {MatchArgs={StatusId=status, StatusEvent=event}})
	else
		error(string.format("%s is not a valid status! _type(%s)", status, t), 2)
	end
end

---@deprecated
---@param event StatusEventID
---@param status string
---@param callback StatusEventCallback
---@param removeAll? boolean
function RemoveStatusListener(event, status, callback, removeAll)
	if removeAll ~= true then
		Events.OnStatus:Unsubscribe(callback, {MatchArgs={StatusId=status, StatusEvent=event}})
	else
		Events.OnStatus:Unsubscribe(nil, {MatchArgs={StatusId=status, StatusEvent=event}})
	end
end

---@deprecated
---@param event StatusEventID BeforeAttempt, Attempt, Applied, Removed
---@param statusType StatStatusType|StatStatusType[]
---@param callback StatusEventCallback
function RegisterStatusTypeListener(event, statusType, callback)
	if _type(statusType) == "table" then
		for i,v in _pairs(statusType) do
			---@diagnostic disable-next-line
			RegisterStatusTypeListener(event, v, callback)
		end
	else
		if StringHelpers.Equals(statusType, "All", true) then
			Events.OnStatus:Subscribe(function (e)
				callback(e.TargetGUID, e.StatusId, e.SourceGUID, e.StatusType)
			end, {StatusType="All", StatusEvent=event})
			return true
		elseif Data.IgnoredStatus[statusType] == true then
			Vars.RegisteredIgnoredStatus[statusType] = true
		end
		Events.OnStatus:Subscribe(function (e)
			callback(e.TargetGUID, e.StatusId, e.SourceGUID, e.StatusType)
		end, {StatusType=statusType, StatusEvent=event})
	end
end

---@deprecated
---@param event StatusEventID
---@param statusType StatStatusType|StatStatusType[]
---@param callback StatusEventCallback
---@param removeAll? boolean
function RemoveStatusTypeListener(event, statusType, callback, removeAll)
	if removeAll ~= true then
		Events.OnStatus:Unsubscribe(callback, {StatusType=statusType, StatusEvent=event})
	else
		Events.OnStatus:Unsubscribe(nil, {StatusType=statusType, StatusEvent=event})
	end
end
--#endregion

Ext.Events.StatusGetEnterChance:Subscribe(function (e)
	if not _IsValidHandle(e.Status.TargetHandle) then
		return
	end
	local target = _GetObjectFromHandle(e.Status.TargetHandle, "EsvCharacter")
	if not target then return end
	local source = _GetObjectFromHandle(e.Status.StatusSourceHandle, "EsvCharacter")

	local targetGUID = target.MyGuid
	local sourceGUID = source and source.MyGuid or StringHelpers.NULL_UUID

	local isCharacter = GameHelpers.Ext.ObjectIsCharacter(target)
	local isItem = not isCharacter and GameHelpers.Ext.ObjectIsItem(target)

	local status = e.Status
	local statusID = status.StatusId
	local statusType = status.StatusType

	if IgnoreDead(target, statusID) then
		return
	end

	if not IgnoreStatus(statusID, "GetEnterChance") then

		local isDisabling = false
		local isLoseControl = false

		local disablingData = _DisablingStatuses.Statuses[statusID]
		if disablingData then
			isDisabling = disablingData.IsDisabling == true
			isLoseControl = disablingData.IsLoseControl == true
		end

		---@type SubscribableEventInvokeResult<OnStatusGetEnterChanceEventArgs>
		local result = Events.OnStatus:Invoke({
			Target = target,
			Source = source,
			Status = status or statusID,
			TargetGUID = targetGUID,
			SourceGUID = sourceGUID,
			StatusId = statusID,
			StatusEvent = "GetEnterChance",
			StatusType = statusType,
			EnterChance = e.EnterChance,
			IsEnterCheck = e.IsEnterCheck,
			Event = e,
			IsDisabling = isDisabling,
			IsLoseControl = isLoseControl
		})
		if result.ResultCode ~= "Error" and e.EnterChance ~= nil then
			e.EnterChance = result.Args.EnterChance
		end
	end
end)