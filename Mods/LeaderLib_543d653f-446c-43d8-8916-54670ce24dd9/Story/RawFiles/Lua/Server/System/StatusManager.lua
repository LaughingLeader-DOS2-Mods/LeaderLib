if StatusManager == nil then
	StatusManager = {}
end

StatusManager._Internal = {
	---Set to true after GameStarted
	CanBlockDeletion = false
}

StatusManager.Register = {}

---If false is returned, the status will be blocked.
---@alias StatusManagerBeforeStatusAttemptCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID):boolean
---@alias StatusManagerAttemptCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID):void
---@alias StatusManagerRemovedCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID):void
---@alias StatusManagerAppliedCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID):void

---@param eventType string
---@param callback function
local function CreateCallbackWrapper(eventType, callback, ...)
	local params = {...}
	local callbackWrapper = function(target, status, source, statusType)
		local status = Ext.GetStatus(target, NRD_StatusGetHandle(target, status)) or status
		local target = GameHelpers.TryGetObject(target, true)
		local source = GameHelpers.TryGetObject(source, true)
		local b,err = xpcall(callback, debug.traceback, target, status, source, statusType, eventType, table.unpack(params))
		if not b then
			error(err, 2)
		end
	end
	return callbackWrapper
end

---@param status string|string[]
---@param callback StatusManagerBeforeStatusAttemptCallback If false is returned, the status will be blocked.
function StatusManager.Register.BeforeAttempt(status, callback, ...)
	local t = type(status)
	if t == "table" then
		for i,v in pairs(status) do
			StatusManager.Register.BeforeAttempt(v, callback, ...)
		end
	elseif t == "string" then
		local params = {...}

		---@param target EsvGameObject
		---@param status EsvStatus
		---@param source EsvGameObject
		local callbackWrapper = function(target, status, source, handle, statusType)
			local b,result = xpcall(callback, debug.traceback, target, status, source, statusType, Vars.StatusEvent.BeforeAttempt, table.unpack(params))
			if not b then
				error(result, 2)
			elseif result then
				NRD_StatusPreventApply(target.MyGuid, handle, 1)
			end
		end
		RegisterStatusListener(Vars.StatusEvent.BeforeAttempt, status, callbackWrapper)
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.BeforeAttempt] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---@param status string|string[]
---@param callback StatusManagerAttemptCallback
function StatusManager.Register.Attempt(status, callback, ...)
	local t = type(status)
	if t == "table" then
		for i,v in pairs(status) do
			StatusManager.Register.Attempt(v, callback, ...)
		end
	elseif t == "string" then
		local callbackWrapper = CreateCallbackWrapper(Vars.StatusEvent.Attempt, callback, ...)
		RegisterStatusListener(Vars.StatusEvent.Attempt, status, callbackWrapper)
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Attempt] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---@param status string|string[]
---@param callback StatusManagerAppliedCallback
function StatusManager.Register.Applied(status, callback, ...)
	local t = type(status)
	if t == "table" then
		for i,v in pairs(status) do
			StatusManager.Register.Applied(v, callback, ...)
		end
	elseif t == "string" then
		local callbackWrapper = CreateCallbackWrapper(Vars.StatusEvent.Applied, callback, ...)
		RegisterStatusListener(Vars.StatusEvent.Applied, status, callbackWrapper)
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Applied] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---@param status string|string[]
---@param callback StatusManagerRemovedCallback
function StatusManager.Register.Removed(status, callback, ...)
	local t = type(status)
	if t == "table" then
		for i,v in pairs(status) do
			StatusManager.Register.Removed(v, callback, ...)
		end
	elseif t == "string" then
		local callbackWrapper = CreateCallbackWrapper(Vars.StatusEvent.Removed, callback, ...)
		RegisterStatusListener(Vars.StatusEvent.Removed, status, callbackWrapper)
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Removed] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---Register a status listener for every state of a status.
---@param status string|string[]
---@param callback StatusManagerBeforeStatusAttemptCallback|StatusManagerAttemptCallback|StatusManagerRemovedCallback|StatusManagerAppliedCallback
function StatusManager.Register.All(status, callback, ...)
	local t = type(status)
	if t == "table" then
		for i,v in pairs(status) do
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
	---@param statusType string|string[]
	---@param callback StatusManagerBeforeStatusAttemptCallback If false is returned, the status will be blocked.
	BeforeAttempt = function(statusType, callback)
		local t = type(statusType)
		if t == "table" then
			for i,v in pairs(statusType) do
				StatusManager.Register.Type.BeforeAttempt(v, callback)
			end
		elseif t == "string" then
			---@param target EsvGameObject
			---@param statusType EsvStatus
			---@param source EsvGameObject
			local callbackWrapper = function(target, statusType, source, handle, statusType)
				local b,result = xpcall(callback, debug.traceback, target, statusType, source, statusType, Vars.StatusEvent.BeforeAttempt)
				if not b then
					error(result, 2)
				elseif result then
					NRD_StatusPreventApply(target.MyGuid, handle, 1)
				end
			end
			RegisterStatusTypeListener(Vars.StatusEvent.BeforeAttempt, statusType, callbackWrapper)
		else
			fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Type.BeforeAttempt] Invalid type for statusType param(%s) value (%s)", t, statusType)
		end
	end,

	---@param statusType string|string[]
	---@param callback StatusManagerAttemptCallback
	Attempt = function(statusType, callback)
		local t = type(statusType)
		if t == "table" then
			for i,v in pairs(statusType) do
				StatusManager.Register.Attempt(v, callback)
			end
		elseif t == "string" then
			local callbackWrapper = CreateCallbackWrapper(Vars.StatusEvent.Attempt, callback)
			RegisterStatusTypeListener(Vars.StatusEvent.Attempt, statusType, callbackWrapper)
		else
			fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Type.Attempt] Invalid type for statusType param(%s) value (%s)", t, statusType)
		end
	end,

	---@param statusType string|string[]
	---@param callback StatusManagerAppliedCallback
	Applied = function(statusType, callback)
		local t = type(statusType)
		if t == "table" then
			for i,v in pairs(statusType) do
				StatusManager.Register.Applied(v, callback)
			end
		elseif t == "string" then
			local callbackWrapper = CreateCallbackWrapper(Vars.StatusEvent.Applied, callback)
			RegisterStatusTypeListener(Vars.StatusEvent.Applied, statusType, callbackWrapper)
		else
			fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Type.Applied] Invalid type for statusType param(%s) value (%s)", t, statusType)
		end
	end,

	---@param statusType string|string[]
	---@param callback StatusManagerRemovedCallback
	Removed = function(statusType, callback)
		local t = type(statusType)
		if t == "table" then
			for i,v in pairs(statusType) do
				StatusManager.Register.Removed(v, callback)
			end
		elseif t == "string" then
			local callbackWrapper = CreateCallbackWrapper(Vars.StatusEvent.Removed, callback)
			RegisterStatusTypeListener(Vars.StatusEvent.Removed, statusType, callbackWrapper)
		else
			fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Type.Attempt] Invalid type for statusType param(%s) value (%s)", t, statusType)
		end
	end,

	---Register a statusType listener for every state of a statusType.
	---@param statusType string|string[]
	---@param callback StatusManagerBeforeStatusAttemptCallback|StatusManagerAttemptCallback|StatusManagerRemovedCallback|StatusManagerAppliedCallback
	All = function(statusType, callback)
		local t = type(statusType)
		if t == "table" then
			for i,v in pairs(statusType) do
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

---@private
StatusManager.DisablingStatuses = {
	Initialized = false,
	Statuses = {
		"CHARMED"
	},
	IsLoseControl = {
		CHARMED = true
	},
	DeferredListeners = {
		BeforeAttempt = {},
		Attempt = {},
		Applied = {},
		Removed = {}
	},
}

Ext.RegisterListener("SessionLoaded", function()
	StatusManager.DisablingStatuses.UpdateStatuses()
end)

---If false is returned, the status will be blocked.
---@alias StatusManagerBeforeStatusAttemptDisablingStatusCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID, loseControl:boolean):boolean
---@alias StatusManagerAttemptDisablingStatusCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID, loseControl:boolean):void
---@alias StatusManagerRemovedDisablingStatusCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID, loseControl:boolean):void
---@alias StatusManagerAppliedDisablingStatusCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID, loseControl:boolean):void

function StatusManager.DisablingStatuses.RegisterCallback(eventType, callback)
	local registerFunction = StatusManager.Register[eventType]
	for _,status in pairs(StatusManager.DisablingStatuses.Statuses) do
		local loseControl = StatusManager.DisablingStatuses.IsLoseControl[status] == true
		registerFunction(StatusManager.DisablingStatuses.Statuses, callback, loseControl)
	end
end

function StatusManager.DisablingStatuses.UpdateStatuses()
	local statuses = {}
	--Preserves statuses mods may have added manually.
	for _,statusId in pairs(StatusManager.DisablingStatuses.Statuses) do
		statuses[statusId] = StatusManager.DisablingStatuses.IsLoseControl[statusId] == true
	end
	for _,v in pairs(Ext.GetStatEntries("StatusData")) do
		local isDisabling,isLoseControl = GameHelpers.Status.IsDisablingStatus(v, true)
		if isDisabling then
			statuses[v] = isLoseControl
		end
	end
	StatusManager.DisablingStatuses.Statuses = {}
	for statusId,isLoseControl in pairs(statuses) do
		StatusManager.DisablingStatuses.Statuses[#StatusManager.DisablingStatuses.Statuses+1] = statusId
		StatusManager.DisablingStatuses.IsLoseControl[statusId] = isLoseControl
	end
	table.sort(StatusManager.DisablingStatuses.Statuses)
	for eventType,listeners in pairs(StatusManager.DisablingStatuses.DeferredListeners) do
		for _,callback in pairs(listeners) do
			StatusManager.DisablingStatuses.RegisterCallback(eventType, callback)
		end
	end
	StatusManager.DisablingStatuses.Initialized = true
end

StatusManager.Register.DisablingStatus = {
	---@param callback StatusManagerBeforeStatusAttemptDisablingStatusCallback If false is returned, the status will be blocked.
	BeforeAttempt = function(callback)
		if StatusManager.DisablingStatuses.Initialized then
			StatusManager.DisablingStatuses.RegisterCallback(Vars.StatusEvent.BeforeAttempt, callback)
		else
			table.insert(StatusManager.DisablingStatuses.DeferredListeners.BeforeAttempt, callback)
		end
	end,

	---@param callback StatusManagerAttemptDisablingStatusCallback
	Attempt = function(callback)
		if StatusManager.DisablingStatuses.Initialized then
			StatusManager.DisablingStatuses.RegisterCallback(Vars.StatusEvent.Attempt, callback)
		else
			table.insert(StatusManager.DisablingStatuses.DeferredListeners.Attempt, callback)
		end
	end,

	---@param callback StatusManagerAppliedDisablingStatusCallback
	Applied = function(callback)
		if StatusManager.DisablingStatuses.Initialized then
			StatusManager.DisablingStatuses.RegisterCallback(Vars.StatusEvent.Applied, callback)
		else
			table.insert(StatusManager.DisablingStatuses.DeferredListeners.Applied, callback)
		end
	end,

	---@param callback StatusManagerRemovedDisablingStatusCallback
	Removed = function(callback)
		if StatusManager.DisablingStatuses.Initialized then
			StatusManager.DisablingStatuses.RegisterCallback(Vars.StatusEvent.Removed, callback)
		else
			table.insert(StatusManager.DisablingStatuses.DeferredListeners.Removed, callback)
		end
	end,

	---Register a listener for every state of a disabling status.
	---@param callback StatusManagerBeforeStatusAttemptDisablingStatusCallback|StatusManagerAttemptDisablingStatusCallback|StatusManagerRemovedDisablingStatusCallback|StatusManagerAppliedDisablingStatusCallback
	All = function(callback)
		StatusManager.Register.DisablingStatus.BeforeAttempt(callback)
		StatusManager.Register.DisablingStatus.Attempt(callback)
		StatusManager.Register.DisablingStatus.Applied(callback)
		StatusManager.Register.DisablingStatus.Removed(callback)
	end
}

---@param target EsvCharacter|EsvItem|UUID|NETID
---@param status string
function StatusManager.IsPermanentStatusActive(target, status)
	local uuid = GameHelpers.GetUUID(target)
	fassert(uuid ~= nil, "Target parameter type (%s) is invalid. An EsvCharacter, EsvItem, UUID, or NetID should be provided.", target)
	if PersistentVars.ActivePermanentStatuses[uuid] then
		return PersistentVars.ActivePermanentStatuses[uuid][status] ~= nil
	end
	return false
end

---@param target EsvCharacter|EsvItem|UUID|NETID
---@param status string
---@param enabled boolean
---@param source EsvCharacter|EsvItem|UUID|NETID|nil A source to use when applying the status, if any. Defaults to the target.
function StatusManager._Internal.SetPermanentStatus(target, status, enabled, source)
	local uuid = GameHelpers.GetUUID(target)
	local statusIsActive = GameHelpers.Status.IsActive(target, status)
	if not enabled then
		PersistentVars.ActivePermanentStatuses[uuid][status] = nil
		if statusIsActive then
			GameHelpers.Status.Remove(target, status)
		end
		if Common.TableLength(PersistentVars.ActivePermanentStatuses[uuid], true) == 0 then
			PersistentVars.ActivePermanentStatuses[uuid] = nil
		end
	else
		if PersistentVars.ActivePermanentStatuses[uuid] == nil then
			PersistentVars.ActivePermanentStatuses[uuid] = {}
		end
		local sourceId = source and GameHelpers.GetUUID(source) or false
		PersistentVars.ActivePermanentStatuses[uuid][status] = sourceId
		if not statusIsActive then
			--fassert(type(status) == "string" and GameHelpers.Stats.Exists(status), "Status (%s) does not exist.", status)
			GameHelpers.Status.Apply(target, status, -1.0, true, source or target)
		end
	end
end

---Removed a registered permanent status for the given character.
---@param target EsvCharacter|EsvItem|UUID|NETID
---@param status string
function StatusManager.RemovePermanentStatus(target, status)
	StatusManager._Internal.SetPermanentStatus(target, status, false)
end

---Applies permanent status. The given status will be blocked from deletion.
---@param target EsvCharacter|EsvItem|UUID|NETID
---@param status string
---@param source EsvCharacter|EsvItem|UUID|NETID|nil A source to use when applying the status, if any. Defaults to the target.
---@return boolean isActive Returns whether the permanent status is active or not.
function StatusManager.ApplyPermanentStatus(target, status, source)
	StatusManager._Internal.SetPermanentStatus(target, status, true, source)
end

---Makes a permanent status active or not, depending on if it's active already. The given status will be blocked from deletion.
---@param target EsvCharacter|EsvItem|UUID|NETID
---@param status string
---@param source EsvCharacter|EsvItem|UUID|NETID|nil A source to use when applying the status, if any. Defaults to the target.
---@return boolean isActive Returns whether the permanent status is active or not.
function StatusManager.TogglePermanentStatus(target, status, source)
	StatusManager._Internal.SetPermanentStatus(target, status, not StatusManager.IsPermanentStatusActive(target, status), source)
end

if Ext.Version() >= 56 then
	Ext.Events.BeforeStatusDelete:Subscribe(function (e)
		if StatusManager._Internal.CanBlockDeletion then
			---@type EsvStatus
			local status = e.Status
			local target = Ext.GetGameObject(status.TargetHandle)
			if target and StatusManager.IsPermanentStatusActive(target.MyGuid, status.StatusId) then
				e:PreventAction()
			end
		end
	end)
end

---@param region string
---@param state REGIONSTATE
---@param levelType LEVELTYPE
RegisterListener("RegionChanged", function (region, state, levelType)
	StatusManager._Internal.CanBlockDeletion = state == REGIONSTATE.GAME and levelType == LEVELTYPE.GAME
end)

RegisterListener("PersistentVarsLoaded", function ()
	for uuid,statuses in pairs(PersistentVars.ActivePermanentStatuses) do
		local target = GameHelpers.TryGetObject(uuid)
		if target then
			for id,source in pairs(statuses) do
				if not GameHelpers.Status.IsActive(target, id) then
					GameHelpers.Status.Apply(target, id, -1, true, source)
				end
			end
		end
	end
end)