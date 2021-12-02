if StatusManager == nil then
	StatusManager = {}
end
StatusManager.Register = {}

---If false is returned, the status will be blocked.
---@alias StatusManagerBeforeStatusAttemptCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID):bool

---@param status string|string[]
---@param callback StatusManagerBeforeStatusAttemptCallback If false is returned, the status will be blocked.
function StatusManager.Register.BeforeAttempt(status, callback)
	local t = type(status)
	if t == "table" then
		for i,v in pairs(status) do
			StatusManager.Register.BeforeAttempt(v, callback)
		end
	elseif t == "string" then
		---@param target EsvGameObject
		---@param status EsvStatus
		local callbackWrapper = function(target, status, source, handle, statusType)
			local b,result = xpcall(callback, debug.traceback, target, status, source, statusType, Vars.StatusEvent.BeforeAttempt)
			if not b then
				error(result, 2)
			elseif result then
				NRD_StatusPreventApply(target.MyGuid, status.StatusId, handle, 1)
			end
		end
		RegisterStatusListener("BeforeAttempt", status, callbackWrapper)
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.BeforeAttempt] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---@alias StatusManagerAttemptCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID):void

---@param status string|string[]
---@param callback StatusManagerAttemptCallback
function StatusManager.Register.Attempt(status, callback)
	local t = type(status)
	if t == "table" then
		for i,v in pairs(status) do
			StatusManager.Register.Attempt(v, callback)
		end
	elseif t == "string" then
		local callbackWrapper = function(target, status, source, statusType)
			status = Ext.GetStatus(target, NRD_StatusGetHandle(target, status)) or status
			target = GameHelpers.TryGetObject(target, true)
			source = GameHelpers.TryGetObject(source, true)
			local b,err = xpcall(callback, debug.traceback, target, status, source, statusType, Vars.StatusEvent.Attempt)
			if not b then
				error(err, 2)
			end
		end
		RegisterStatusListener("Attempt", status, callbackWrapper)
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Attempt] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---@alias StatusManagerAppliedCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID):void

---@param status string|string[]
---@param callback StatusManagerAppliedCallback
function StatusManager.Register.Applied(status, callback)
	local t = type(status)
	if t == "table" then
		for i,v in pairs(status) do
			StatusManager.Register.Applied(v, callback)
		end
	elseif t == "string" then
		local callbackWrapper = function(target, status, source, statusType)
			status = Ext.GetStatus(target, NRD_StatusGetHandle(target, status)) or status
			target = GameHelpers.TryGetObject(target, true)
			source = GameHelpers.TryGetObject(source, true)
			local b,err = xpcall(callback, debug.traceback, target, status, source, statusType, Vars.StatusEvent.Applied)
			if not b then
				error(err, 2)
			end
		end
		RegisterStatusListener("Applied", status, callbackWrapper)
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Attempt] Invalid type for status param(%s) value (%s)", t, status)
	end
end

---@alias StatusManagerRemovedCallback fun(target:EsvCharacter|EsvItem, status:EsvStatus, source:EsvCharacter|EsvItem|nil, statusType:string, statusEvent:StatusEventID):void

---@param status string|string[]
---@param callback StatusManagerRemovedCallback
function StatusManager.Register.Removed(status, callback)
	local t = type(status)
	if t == "table" then
		for i,v in pairs(status) do
			StatusManager.Register.Removed(v, callback)
		end
	elseif t == "string" then
		local callbackWrapper = function(target, status, source, statusType)
			status = Ext.GetStatus(target, NRD_StatusGetHandle(target, status)) or status
			target = GameHelpers.TryGetObject(target, true)
			source = GameHelpers.TryGetObject(source, true)
			local b,err = xpcall(callback, debug.traceback, target, status, source, statusType, Vars.StatusEvent.Removed)
			if not b then
				error(err, 2)
			end
		end
		RegisterStatusListener("Removed", status, callbackWrapper)
	else
		fprint(LOGLEVEL.ERROR, "[StatusManager.Register.Attempt] Invalid type for status param(%s) value (%s)", t, status)
	end
end