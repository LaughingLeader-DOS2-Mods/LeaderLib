local _EXTVERSION = Ext.Version()

local _type = type
local _pairs = pairs
local _xpcall = xpcall

local _SGetUUID = StringHelpers.GetUUID
local _GetObject = GameHelpers.TryGetObject
local _GetGameObject = Ext.GetGameObject
local _GetStatus = Ext.GetStatus
if _EXTVERSION >= 56 then
	_GetStatus = Ext.Entity.GetStatus
	_GetGameObject = Ext.Entity.GetGameObject
end
local _GetStatusType = GameHelpers.Status.GetStatusType
local _IsValidHandle = GameHelpers.IsValidHandle

if StatusManager == nil then
	StatusManager = {}
end

---Allow BeforeAttempt and Attempt events to invoke on dead characters. Only specific engine statuses can apply to corpses, so this is normally ignored.
StatusManager.AllowDead = false

---@alias StatusEventID string
---|"BeforeAttempt" # NRD_OnStatusAttempt
---|"Attempt" # CharacterStatusAttempt/ItemStatusAttempt
---|"Applied" # CharacterStatusApplied/ItemStatusChange
---|"BeforeDelete" # Ext.Events.BeforeStatusDelete
---|"Removed" # CharacterStatusRemoved/ItemStatusRemoved

---Automatically set to true after GameStarted.
---This is a local variable, instead of a key in _INTERNAL, so the BeforeStatusDelete listener doesn't need to parse a table within a table for every status firing the event.
local _canBlockDeletion = false

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
	end
	for name,data in pairs(statuses) do
		if not _DisablingStatuses.Statuses[name] then
			_DisablingStatuses.Statuses[name] = {IsDisablingStatus = data.IsDisabling == true, IsLoseControl = data.IsLoseControl == true}
		end
	end
	_DisablingStatuses.Initialized = true
end

Ext.RegisterListener("SessionLoaded", function()
	_DisablingStatuses.UpdateStatuses()
end)

StatusManager.Register = {}

local _INTERNALREG = {}
StatusManager.Subscribe = _INTERNALREG

---@param status string|string[]
---@param callback fun(e:OnStatusEventArgs)
---@param priority integer|nil
---@param statusEvent StatusEventID|nil
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
---@param priority integer|nil
---@return integer|integer[] index
function _INTERNALREG.BeforeAttempt(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "BeforeAttempt")
end

---@param status string|string[]
---@param callback fun(e:OnStatusAttemptEventArgs)
---@param priority integer|nil
---@return integer|integer[] index
function _INTERNALREG.Attempt(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "Attempt")
end

---@param status string|string[]
---@param callback fun(e:OnStatusAppliedEventArgs)
---@param priority integer|nil
---@return integer|integer[] index
function _INTERNALREG.Applied(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "Applied")
end

---@param status string|string[]
---@param callback fun(e:OnStatusRemovedEventArgs)
---@param priority integer|nil
---@return integer|integer[] index
function _INTERNALREG.Removed(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "Removed")
end

---@param status string|string[]
---@param callback fun(e:OnStatusRemovedEventArgs)
---@param priority integer|nil
---@return integer|integer[] index
function _INTERNALREG.BeforeDelete(status, callback, priority)
	return _INTERNALREG.All(status, callback, priority, "Removed")
end

---@alias LeaderLibStatusType string
---|"DISABLE" # Any status that returns true with GameHelpers.Status.IsDisablingStatus.
---|"LOSE_CONTROL" # Any status with IsLoseControl set to "Yes".
---|"DISABLE|LOSE_CONTROL" # Any status that has IsDisabling or IsLoseControl true in the status event.
---|StatStatusType

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusEventArgs) The function to call when this status event occurs
---@param priority integer|nil Optional listener priority
---@param statusEvent StatusEventID|nil The status event
---@param secondaryStatusType StatStatusType|nil If statusType is a special value, such as "DISABLE", filter the match further by this type
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
---@param priority integer|nil Optional listener priority
---@param secondaryStatusType StatStatusType|nil If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.BeforeAttemptType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "BeforeAttempt", secondaryStatusType)
end

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusAttemptEventArgs) The function to call when this status event occurs
---@param priority integer|nil Optional listener priority
---@param secondaryStatusType StatStatusType|nil If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.AttemptType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "Attempt", secondaryStatusType)
end

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusAppliedEventArgs) The function to call when this status event occurs
---@param priority integer|nil Optional listener priority
---@param secondaryStatusType StatStatusType|nil If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.AppliedType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "Applied", secondaryStatusType)
end

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusBeforeDeleteEventArgs) The function to call when this status event occurs
---@param priority integer|nil Optional listener priority
---@param secondaryStatusType StatStatusType|nil If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.BeforeDeleteType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "BeforeDelete", secondaryStatusType)
end

---@param statusType LeaderLibStatusType|LeaderLibStatusType[] Status type(s) to register the callback for
---@param callback fun(e:OnStatusRemovedEventArgs) The function to call when this status event occurs
---@param priority integer|nil Optional listener priority
---@param secondaryStatusType StatStatusType|nil If statusType is a special value, such as "DISABLE", filter the match further by this type
---@return integer|integer[] index
function _INTERNALREG.RemovedType(statusType, callback, priority, secondaryStatusType)
	return _INTERNALREG.AllType(statusType, callback, priority, "Removed", secondaryStatusType)
end

---If false is returned, the status will be blocked.
---@alias StatusManagerBeforeStatusAttemptCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID):boolean
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

---@param target CharacterParam
---@param status string
function StatusManager.IsPermanentStatusActive(target, status)
	local GUID = GameHelpers.GetUUID(target)
	fassert(GUID ~= nil, "Target parameter type (%s) is invalid. An EsvCharacter, EsvItem, UUID, or NetID should be provided.", target)
	if PersistentVars.ActivePermanentStatuses[GUID] then
		return PersistentVars.ActivePermanentStatuses[GUID][status] ~= nil
	end
	return false
end

---@param target CharacterParam
---@param status string
---@param enabled boolean
---@param source CharacterParam|nil A source to use when applying the status, if any. Defaults to the target.
function _INTERNAL.SetPermanentStatus(target, status, enabled, source)
	local GUID = GameHelpers.GetUUID(target)
	local statusIsActive = GameHelpers.Status.IsActive(target, status)
	if not enabled then
		if PersistentVars.ActivePermanentStatuses[GUID] then
			PersistentVars.ActivePermanentStatuses[GUID][status] = nil
			if Common.TableLength(PersistentVars.ActivePermanentStatuses[GUID], true) == 0 then
				PersistentVars.ActivePermanentStatuses[GUID] = nil
			end
		end

		if statusIsActive then
			GameHelpers.Status.Remove(target, status)
		end
	else
		if PersistentVars.ActivePermanentStatuses[GUID] == nil then
			PersistentVars.ActivePermanentStatuses[GUID] = {}
		end
		local sourceId = source and GameHelpers.GetUUID(source) or false
		PersistentVars.ActivePermanentStatuses[GUID][status] = sourceId
		if not statusIsActive then
			--fassert(_type(status) == "string" and GameHelpers.Stats.Exists(status), "Status (%s) does not exist.", status)
			GameHelpers.Status.Apply(target, status, -1.0, true, source or target)
		end
	end
end

---Applies permanent status. The given status will be blocked from deletion.
---@param target CharacterParam
---@param status string
---@param source CharacterParam|nil A source to use when applying the status, if any. Defaults to the target.
---@return boolean isActive Returns whether the permanent status is active or not.
function StatusManager.ApplyPermanentStatus(target, status, source)
	_INTERNAL.SetPermanentStatus(target, status, true, source)
end

---Remove a registered permanent status for the given character.
---@param target CharacterParam
---@param status string
function StatusManager.RemovePermanentStatus(target, status)
	_INTERNAL.SetPermanentStatus(target, status, false)
end

---Removed all registered permanent statuses for the given character.
---@param target CharacterParam
function StatusManager.RemoveAllPermanentStatuses(target)
	local GUID = GameHelpers.GetUUID(target)
	if GUID and PersistentVars.ActivePermanentStatuses then
		local statuses = PersistentVars.ActivePermanentStatuses[GUID]
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
			PersistentVars.ActivePermanentStatuses[GUID] = nil
		end
	end
end

---Makes a permanent status active or not, depending on if it's active already. The given status will be blocked from deletion.
---@param target CharacterParam
---@param status string
---@param source CharacterParam|nil A source to use when applying the status, if any. Defaults to the target.
---@return boolean isActive Returns whether the permanent status is active or not.
function StatusManager.TogglePermanentStatus(target, status, source)
	_INTERNAL.SetPermanentStatus(target, status, not StatusManager.IsPermanentStatusActive(target, status), source)
end

if Ext.Version() >= 56 then
	---@class ExtenderBeforeStatusDeleteEventParams
	---@field Status EsvStatus
	---@field PreventAction fun(self:ExtenderBeforeStatusDeleteEventParams)

	---@param e ExtenderBeforeStatusDeleteEventParams
	local function OnBeforeStatusDelete(e)
		local target = _GetObject(e.Status.TargetHandle)
		local targetGUID = target.MyGuid
		local statusType = e.Status.StatusType

		local source = nil
		local sourceGUID = StringHelpers.NULL_UUID

		if GameHelpers.IsValidHandle(e.Status.StatusSourceHandle) then
			source = _GetObject(e.Status.StatusSourceHandle)
			if source then
				sourceGUID = GameHelpers.GetUUID(source)
			end
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
	end

	---@param e ExtenderBeforeStatusDeleteEventParams
	Ext.Events.BeforeStatusDelete:Subscribe(function (e)
		if _IsValidHandle(e.Status.TargetHandle) then
			OnBeforeStatusDelete(e)
			if _canBlockDeletion and e.Status.LifeTime == -1 then
				local target = _GetGameObject(e.Status.TargetHandle)
				if target ~= nil
				and StatusManager.IsPermanentStatusActive(target.MyGuid, e.Status.StatusId)
				and not GameHelpers.ObjectIsDead(target) then
					e:PreventAction()
				end
			end
		end
	end)
end

Events.RegionChanged:Subscribe(function (e)
	_canBlockDeletion = e.State == REGIONSTATE.GAME and e.LevelType == LEVELTYPE.GAME
end)

function _INTERNAL.ReapplyPermanentStatuses()
	if PersistentVars.ActivePermanentStatuses then
		for uuid,statuses in _pairs(PersistentVars.ActivePermanentStatuses) do
			local target = _GetObject(uuid)
			if target then
				for id,source in _pairs(statuses) do
					if not GameHelpers.Status.IsActive(target, id) then
						GameHelpers.Status.Apply(target, id, -1, true, source)
					end
				end
			end
		end
	end
end

RegisterListener("PersistentVarsLoaded", function ()
	_INTERNAL.ReapplyPermanentStatuses()
end)

---@param character EsvCharacter
---@param refreshStatBoosts boolean|nil If true, active statuses with stat boosts will be re-applied.
function StatusManager.ReapplyPermanentStatusesForCharacter(character, refreshStatBoosts)
	character = GameHelpers.GetCharacter(character)
	assert(character ~= nil, "An EsvCharacter, NetID, or UUID is required")
	local permanentStatuses = PersistentVars.ActivePermanentStatuses[character.MyGuid]
	if permanentStatuses then
		for id,source in _pairs(permanentStatuses) do
			if not GameHelpers.Status.IsActive(character, id) or (refreshStatBoosts and GameHelpers.Status.HasStatBoosts(id)) then
				GameHelpers.Status.Apply(character, id, -1, true, source)
			end
		end
	end
end

Events.CharacterLeveledUp:Subscribe(function(e)
	if PersistentVars.ActivePermanentStatuses[e.Character.MyGuid] ~= nil then
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

RegisterProtectedOsirisListener("NRD_OnStatusAttempt", 4, "after", function(targetGUID,statusID,handle,sourceGUID)
	if IgnoreDead(targetGUID, statusID) then
		return
	end
	local statusType = _GetStatusType(statusID)
	if ObjectIsItem(targetGUID) == 1 and (statusID == "MADNESS" or statusType == "DAMAGE_ON_MOVE") then
		NRD_StatusPreventApply(targetGUID, handle, 1)
		return
	end

	if not IgnoreStatus(statusID, "BeforeAttempt") then
		local target = _GetObject(targetGUID)
		local source = _GetObject(sourceGUID)

		local status = _GetStatus(targetGUID, handle)
		if status == nil then
			return
		end

		local preventApply = false

		--Make Unhealable block all heals
		if target and statusType == "HEAL" or statusType == "HEALING" and status.HealAmount > 0
		and target:GetStatus("UNHEALABLE")
		and SettingsManager.GetMod(ModuleUUID, false, false).Global:FlagEquals("LeaderLib_UnhealableFix_Enabled", true) then
			NRD_StatusPreventApply(targetGUID, handle, 1)
			preventApply = true
		end

		if target and source then 
			local canRedirect = redirectStatusId[statusID] or redirectStatusType[statusType]
			if canRedirect and source.Summon and _IsValidHandle(source.OwnerHandle) then
				if ObjectIsItem(sourceGUID) == 1 then
					--Set the source of statuses summoned items apply to their caster owner character.
					status.StatusSourceHandle = source.OwnerHandle
					source = _GetObject(source.OwnerHandle)
					sourceGUID = GameHelpers.GetUUID(source)
				end
			elseif source:HasTag("LeaderLib_Dummy") then
				--Redirect the source of statuses applied by dummies to their owners
				local owner = GetVarObject(sourceGUID, "LeaderLib_Dummy_Owner")
				if not StringHelpers.IsNullOrEmpty(owner) and ObjectExists(owner) == 1 then
					NRD_StatusSetGuidString(targetGUID, handle, "StatusSourceHandle", owner)
					source = _GetObject(owner)
					sourceGUID = GameHelpers.GetUUID(owner)
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
		if result.ResultCode ~= "Error" and result.Args.PreventApply == true then
			NRD_StatusPreventApply(targetGUID, handle, 1)
		end
	end
end)

local function OnStatusAttempt(targetGUID,statusID,sourceGUID)
	local target = _GetObject(targetGUID)
	local source = _GetObject(sourceGUID)
	
	if not target then
		return
	end
	
	local statusType = _GetStatusType(statusID)

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
		StatusEvent = "Attempt",
		StatusType = statusType,
		IsDisabling = isDisabling,
		IsLoseControl = isLoseControl
	})
end

--SetVarFixedString("702becec-f2c1-44b2-b7ab-c247f8da97ac", "LeaderLib_RemoveStatusInfluence_ID", "WARM"); SetStoryEvent("702becec-f2c1-44b2-b7ab-c247f8da97ac", "LeaderLib_Commands_RemoveStatusInfluence")

local function ParseStatusAttempt(targetGUID,statusID,sourceGUID)
	if IgnoreDead(targetGUID, statusID) then
		return
	end
	if not IgnoreStatus(statusID, "Attempt") then
		targetGUID = _SGetUUID(targetGUID)
		sourceGUID = _SGetUUID(sourceGUID)
		OnStatusAttempt(targetGUID, statusID, sourceGUID)
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

local function OnStatusApplied(targetGUID,statusID,sourceGUID)
	local target = _GetObject(targetGUID)
	local source = _GetObject(sourceGUID)
	
	if not target then
		return
	end
	
	local status = target:GetStatus(statusID)
	if not status then
		return
	end
	local statusType = _GetStatusType(statusID)

	if status == "SUMMONING" and target then
		local owner = nil
		if _IsValidHandle(target.OwnerHandle) then
			owner = _GetObject(target.OwnerHandle)
		end
		if owner then
			if not PersistentVars.Summons[owner.MyGuid] then
				PersistentVars.Summons[owner.MyGuid] = {}
			end
			table.insert(PersistentVars.Summons[owner.MyGuid], target.MyGuid)
		end
		Events.SummonChanged:Invoke({Summon=target, Owner=owner, IsDying=false, IsItem=GameHelpers.Ext.ObjectIsItem(target)})
	end

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

local function ParseStatusApplied(target,status,source)
	if not IgnoreStatus(status, "Applied") then
		target = _SGetUUID(target)
		source = _SGetUUID(source)
		OnStatusApplied(target, status, source)
	end
end

local function OnStatusRemoved(targetGUID,statusID,sourceGUID)
	local target = _GetObject(targetGUID, true)
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
	if not IgnoreStatus(status, "Removed") then
		target = _SGetUUID(target)
		OnStatusRemoved(target, status)
	end
end

RegisterProtectedOsirisListener("CharacterStatusApplied", 3, "after", ParseStatusApplied)
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
---@param removeAll boolean|nil
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
---@param removeAll boolean|nil
function RemoveStatusTypeListener(event, statusType, callback, removeAll)
    if removeAll ~= true then
		Events.OnStatus:Unsubscribe(callback, {StatusType=statusType, StatusEvent=event})
	else
		Events.OnStatus:Unsubscribe(nil, {StatusType=statusType, StatusEvent=event})
	end
end
--#endregion