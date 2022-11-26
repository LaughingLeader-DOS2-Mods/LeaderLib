---@class LeaderLibTimerSystem
Timer = {
	IgnoredTimers = {
		LeaderLib_v55_Tick = true,
		Timers_LeaderLib_Debug_LuaReset = true,
		Timers_LeaderLib_Debug_ResetLua = true,
	}
}

local _ISCLIENT = Ext.IsClient()
local type = type
local _mt = Ext.Utils.MonotonicTime

Timer.TimerData = {}
Timer.TimerNameMap = {}

---@type WaitForTickData[]
local _waitForTick = {}

if not _ISCLIENT then
	setmetatable(Timer.TimerData, {
		__index = function (_,k)
			if not Vars.PersistentVarsLoaded then 
				return nil
			end
			return _PV.TimerData[k]
		end,
		__newindex = function (tbl,timerName,v)
			if not Vars.PersistentVarsLoaded then 
				rawset(tbl,timerName,v)
				return
			end
			_PV.TimerData[timerName] = v
		end
	})
	setmetatable(Timer.TimerNameMap, {
		__index = function (_,k) 
			if not Vars.PersistentVarsLoaded then 
				return nil
			end
			return _PV.TimerNameMap[k]
		end,
		__newindex = function (tbl,timerName,v)
			if not Vars.PersistentVarsLoaded then 
				rawset(tbl,timerName,v)
				return
			end
			if _PV.TimerNameMap then
				_PV.TimerNameMap[timerName] = v
			end
		end
	})
else
	local _ClientData = {
		TimerNameMap = {},
		TimerData = {},
	}
	setmetatable(Timer.TimerData, {
		__index = _ClientData.TimerData,
		__newindex = function (_,timerName,v)
			_ClientData.TimerData[timerName] = v
		end
	})
	setmetatable(Timer.TimerNameMap, {
		__index = _ClientData.TimerNameMap,
		__newindex = function (_,timerName,v)
			_ClientData.TimerNameMap[timerName] = v
		end
	})
end

local _INTERNAL = {}
Timer._Internal = _INTERNAL

function _INTERNAL.StoreData(timerName, data)
	if not Timer.TimerData[timerName] then
		Timer.TimerData[timerName] = {}
	end
	table.insert(Timer.TimerData[timerName], Lib.smallfolk.dumps(data))
end

function _INTERNAL.StoreUniqueTimerName(uniqueTimerName, generalTimerName, data)
	Timer.TimerNameMap[uniqueTimerName] = generalTimerName
	--Clear previous, in case the timer is being restarted
	Timer.TimerData[uniqueTimerName] = nil
	_INTERNAL.StoreData(uniqueTimerName, data)
end

function _INTERNAL.ClearData(timerName)
	Timer.TimerData[timerName] = nil
	Timer.TimerNameMap[timerName] = nil
end

function _INTERNAL.ClearObjectData(timerName, object)
	local uuid = GameHelpers.GetUUID(object)
	if uuid then
		local uniqueTimerName = string.format("%s%s", timerName, uuid)
		_INTERNAL.ClearData(uniqueTimerName)
	end
end

local _TimerLaunch = function (id, delay)
	if _OSIRIS() then
		TimerLaunch(id, delay)
	elseif Ext.Server.GetGameState() == "Running" then
		Ext.OnNextTick(function (e)
			if _OSIRIS() then
				TimerLaunch(id, delay)
			end
		end)
	end
end

local _TimerCancel = function (id)
	if _OSIRIS() then
		TimerCancel(id)
	elseif Ext.Server.GetGameState() == "Running" then
		Ext.OnNextTick(function (e)
			if _OSIRIS() then
				TimerCancel(id)
			end
		end)
	end
end

---@param timerName string
---@param delay integer
local function _StartTimer(timerName, delay)
	if not _ISCLIENT then
		_TimerCancel(timerName)
		_TimerLaunch(timerName, delay)
	else
		local resetTickTime = false
		local len = #_waitForTick
		if len > 0 then
			for i=1,len do
				local v = _waitForTick[i]
				if v and v.ID == timerName then
					v.TargetTime = _mt() + delay
					v.Delay = delay
					resetTickTime = true
				end
			end
		end
		if not resetTickTime then
			_waitForTick[len+1] = {
				ID = timerName,
				TargetTime = _mt() + delay,
				Delay = delay
			}
		end
		--UIExtensions.StartTimer(timerName, delay, flashCallback)
	end
	return true
end

---Starts a timer with optional data to include in the callback. Only serializable types are accepted for optional parameters.
---@param timerName string
---@param delay integer
---@vararg string|number|boolean|table Optional variable arguments that will be sent to the timer finished callback.
function Timer.Start(timerName, delay, ...)
	local data = {...}
	if #data > 0 then
		_INTERNAL.StoreData(timerName, data)
	end
	_StartTimer(timerName, delay)
end

local _OneshotTimerIndexes = {}
_INTERNAL._OneshotTimerIndexes = _OneshotTimerIndexes

function _INTERNAL.ClearOneshotSubscriptions(timerName, skipAlteringTickTable)
	local indexes = _OneshotTimerIndexes[timerName]
	if indexes then
		for _,index in pairs(indexes) do
			Events.TimerFinished:Unsubscribe(index)
		end
		_OneshotTimerIndexes[timerName] = nil
		if _ISCLIENT and skipAlteringTickTable ~= true then
			local len = #_waitForTick
			if len > 0 then
				local _nextWait = {}
				for i=1,len do
					local data = _waitForTick[i]
					if data and data.ID ~= timerName then
						_nextWait[#_nextWait+1] = data
					end
				end
				_waitForTick = _nextWait
			end
		end
	end
end

--- Starts an Osiris timer with a callback function to run when the timer is finished.
--- Not save safe since functions can't really be saved.
---@param timerName string
---@param delay integer
---@param callback fun(e:TimerFinishedEventArgs)
---@param stopPrevious boolean|nil Stop any previous timers with the same name.
---@return integer index Returns the subscription callback index.
function Timer.StartOneshot(timerName, delay, callback, stopPrevious)
	delay = delay or 0
	if delay <= 0 then
		callback({ID=timerName, StopPropagation=function()end})
		return -1
	end
	if StringHelpers.IsNullOrEmpty(timerName) then
		timerName = string.format("LeaderLib_%s%s", _mt(), Ext.Random(0,999999))
	end
	if stopPrevious then
		Timer.Cancel(timerName)
	end
	local index = Events.TimerFinished:Subscribe(callback, {
		Once=true,
		MatchArgs={ID=timerName}
	})
	if _OneshotTimerIndexes[timerName] == nil then
		_OneshotTimerIndexes[timerName] = {}
	end
	local tbl = _OneshotTimerIndexes[timerName]
	tbl[#tbl+1] = index
	_StartTimer(timerName, delay)
	return index
end

---Cancels a timer, with an optional UUID for object timers.
---@param timerName string
---@param object ObjectParam|nil
function Timer.Cancel(timerName, object)
	_INTERNAL.ClearOneshotSubscriptions(timerName)
	if not _ISCLIENT then
		if object ~= nil then
			local uuid = GameHelpers.GetUUID(object)
			if uuid then
				local uniqueTimerName = string.format("%s%s", timerName, uuid)
				_INTERNAL.ClearData(uniqueTimerName)
				_TimerCancel(uniqueTimerName)
			end
		end
		_TimerCancel(timerName)
	else
		UIExtensions.RemoveTimerCallback(timerName)
	end
	_INTERNAL.ClearData(timerName)
end

---Subscribe a callback for a timer name, or an array of timer names.
---@param name string|string[]
---@param callback fun(e:TimerFinishedEventArgs)
---@param once boolean|nil If true, the callback is only invoked once, and then the listener is removed.
---@param priority integer|nil Priority value for the listener. Higher priorities run first.
---@return integer|integer[] subscriptionIndex
function Timer.Subscribe(name, callback, once, priority)
	local t = type(name)
	if t == "string" then
		return Events.TimerFinished:Subscribe(callback, {MatchArgs={ID=name}, Priority=priority, Once=once})
	elseif t == "table" then
		local results = {}
		for _,v in pairs(name) do
			local index = Timer.Subscribe(v, callback)
			if index then
				results[#results+1] = index
			end
		end
		return results
	else
		--fprint(LOGLEVEL.WARNING, "[Timer.Subscribe] name(%s) is not a valid timer name. Should be a string or table of strings.", name)
		error(string.format("[Timer.Subscribe] name(%s) is not a valid timer name. Should be a string or table of strings.", name), 2)
	end
	return nil
end

--Support for older listeners where the callback params were (timerName, uuid|data)
local function CreateDeprecatedWrapper(callback)
	---@param e TimerFinishedEventArgs
	local wrapper = function(e)
		if e.Data.UUID then
			local uuid = e.Data.UUID
			if type(e.Data.Params) == "table" then
				callback(e.ID, uuid, table.unpack(e.Data.Params))
			else
				local params = TableHelpers.Clone(e.Data)
				params.Object = nil
				params.UUID = nil
				callback(e.ID, uuid, table.unpack(params))
			end
		else
			if e.Data.Params then
				callback(e.ID, table.unpack(e.Data.Params))
			else
				callback(e.ID, table.unpack(e.Data))
			end
		end
	end
	return wrapper
end

Timer._Internal.CreateDeprecatedWrapper = CreateDeprecatedWrapper

---Supports a variable amount of parameters passed to Timer.Start. Object timers will pass the object UUID as the second paramter.
---@alias DeprecatedTimerCallback fun(timerName:string, ...)

---@deprecated
---@see LeaderLibTimerSystem#Subscribe
---@param name string|string[] Timer name or the callback if a ganeric listener.
---@param callback DeprecatedTimerCallback
function Timer.RegisterListener(name, callback)
	local t = type(name)
	if t == "string" then
		Events.TimerFinished:Subscribe(CreateDeprecatedWrapper(callback), {MatchArgs={ID=name}})
	elseif t == "function" then
		Events.TimerFinished:Subscribe(CreateDeprecatedWrapper(callback))
	elseif t == "table" then
		for _,v in pairs(name) do
			Timer.RegisterListener(v, callback)
		end
	end
end

local function OnTimerFinished(timerName, skipAlteringTickTable)
	if Timer.IgnoredTimers[timerName] then
		return
	end
	local originalTimerName = timerName
	local data = Timer.TimerData[timerName]
	local realTimerName = Timer.TimerNameMap[timerName]

	--Unique timer
	if realTimerName then
		timerName = realTimerName
		Timer.TimerNameMap[timerName] = nil
	end

	--Clear before invoking, in case a callback starts another timer with the same name
	_INTERNAL.ClearData(originalTimerName)

	local invoked = false

	if type(data) == "table" then
		for i=1,#data do
			local entry = data[i]
			local timerData = Lib.smallfolk.loads(entry)
			if timerData then
				if timerData.UUID then
					local uuid = timerData.UUID
					local obj = nil
					setmetatable(timerData, {
						__index = function (_, k)
							if k == "Object" then
								if not obj then
									obj = GameHelpers.TryGetObject(uuid)
								end
								return obj
							end
						end
					})
				end
				Events.TimerFinished:Invoke({ID=timerName, Data=timerData})
			else
				Events.TimerFinished:Invoke({ID=timerName, Data={entry}})
			end
			invoked = true
		end
	else
		if StringHelpers.IsUUID(data) then
			local timerData = {
				UUID = data
			}
			local uuid = timerData.UUID
			setmetatable(timerData, {
				__index = function (_, k)
					if k == "Object" then
						return GameHelpers.TryGetObject(uuid)
					end
				end
			})
			Events.TimerFinished:Invoke({ID=timerName, Data=timerData})
		else
			Events.TimerFinished:Invoke({ID=timerName, Data={data}})
		end
		invoked = true
	end

	if not invoked then
		Events.TimerFinished:Invoke({ID=timerName, Data = {}})
	end

	if not _ISCLIENT then
		TurnCounter.OnTimerFinished(timerName)
	end

	_INTERNAL.ClearOneshotSubscriptions(timerName, skipAlteringTickTable)
end

---Starts an Osiris timer with a unique string variance, with optional data to include in the callback. Only strings, numbers, and booleans are accepted for optional parameters.
---This is similar to an object timer, but you can set the unique string directly.
---@param timerName string The generalized timer name. A unique name will be created using the timer name and object.
---@param uniqueVariance string The string that makes this timer unique, such as a UUID.
---@param delay integer
---@vararg string|number|boolean|table Optional variable arguments that will be sent to the timer finished callback.
function Timer.StartUniqueTimer(timerName, uniqueVariance, delay, ...)
	if uniqueVariance then
		local uniqueTimerName = string.format("%s%s", timerName, uniqueVariance)
		Timer.Cancel(uniqueTimerName)
		local data = {...}
		if #data > 0 then
			if type(data[1]) == "table" and data[2] == nil then
				_INTERNAL.StoreUniqueTimerName(uniqueTimerName, timerName, data[1])
			else
				_INTERNAL.StoreUniqueTimerName(uniqueTimerName, timerName, data)
			end
		else
			_INTERNAL.StoreUniqueTimerName(uniqueTimerName, timerName)
		end
		_StartTimer(uniqueTimerName, delay)
	else
		fprint(LOGLEVEL.WARNING, "[LeaderLib:StartUniqueTimer] A valid uniqueVariance is required. Parameter (%s) is invalid!", uniqueVariance or "nil")
	end
end

---Starts an Osiris timer for an object, with optional data to include in the callback. Only strings, numbers, and booleans are accepted for optional parameters.
---@param timerName string The generalized timer name. A unique name will be created using the timer name and object.
---@param object ObjectParam
---@param delay integer
---@vararg string|number|boolean|table Optional variable arguments that will be sent to the timer finished callback.
function Timer.StartObjectTimer(timerName, object, delay, ...)
	local uuid = GameHelpers.GetUUID(object)
	if uuid then
		local data = {UUID = uuid}
		local params = {...}
		local paramsLength = #params
		if paramsLength > 0 then
			data.Params = {}
			for i=1,paramsLength do
				local entry = params[i]
				if type(entry) == "table" then
					for k,v in pairs(entry) do
						data[k] = v
					end
				else
					data.Params[#data.Params+1] = entry
				end
			end
		end
		Timer.StartUniqueTimer(timerName, uuid, delay, data)
	else
		fprint(LOGLEVEL.WARNING, "[LeaderLib:StartObjectTimer] A valid object with a UUID is required. Parameter (%s) is invalid!", object or "nil")
	end
end

--#region Restarting

---Restart a timer without altering any stored data.
---@param timerName string|string[]
---@param delay integer
function Timer.Restart(timerName, delay)
	local t = type(timerName)
	if t == "string" then
		return _StartTimer(timerName, delay)
	elseif t == "table" then
		local success = false
		for _,v in pairs(timerName) do
			if Timer.Restart(v, delay) then
				success = true
			end
		end
		return success
	else
		fprint(LOGLEVEL.WARNING, "[Timer.Restart] Invalid timerName type (%s) value(%s)", t, timerName)
	end
	return false
end

---@deprecated
---@see LeaderLibTimerSystem#Restart
---@param timerName string
---@param delay integer
function Timer.RestartOneshot(timerName, delay)
	return Timer.Restart(timerName, delay)
end

---Restarts a unique timer without altering stored data.
---@param timerName string The generalized timer name.
---@param uniqueVariance string The string that makes this timer unique, such as a UUID.
---@param delay integer
function Timer.RestartUniqueTimer(timerName, uniqueVariance, delay)
	local uniqueTimerName = string.format("%s%s", timerName, uniqueVariance)
	return Timer.Restart(uniqueTimerName, delay)
end

---Restarts an object timer without altering stored data.
---@param timerName string The generalized timer name. A unique name will be created using the timer name and object.
---@param object ObjectParam
---@param delay integer
function Timer.RestartObjectTimer(timerName, object, delay)
	local uuid = GameHelpers.GetUUID(object)
	if uuid then
		return Timer.RestartUniqueTimer(timerName, uuid, delay)
	else
		fprint(LOGLEVEL.ERROR, "[LeaderLib:Timer.RestartObjectTimer] timerName(%s) object(%s) delay(%s) - Failed to get UUID for object.", timerName, object, delay)
	end
	return false
end
--#endregion

if not _ISCLIENT then
	Ext.Osiris.RegisterListener("TimerFinished", 1, "after", OnTimerFinished)

	local function OnProcObjectTimerFinished(uuid, timerName)
		uuid = StringHelpers.GetUUID(uuid)
		local object = GameHelpers.TryGetObject(uuid)
		Events.TimerFinished:Invoke({ID=timerName, Data={Object=object, UUID=uuid}})
	end
	
	Ext.RegisterOsirisListener("ProcObjectTimerFinished", 2, "after", OnProcObjectTimerFinished)
end

---@class ExtGameTime
---@field Time number
---@field DeltaTime number
---@field Ticks integer

---@class WaitForTickData
---@field ID string
---@field TargetTime integer
---@field Delay integer

if _ISCLIENT then
	---@param e LuaTickEventParams
	local function OnTick(e)
		local length = #_waitForTick
		if length > 0 then
			local time = _mt()
			local _nextWait = {}
			local idx = 1
			for i=1,length do
				local data = _waitForTick[i]
				if data then
					if data.TargetTime <= time then
						OnTimerFinished(data.ID, true)
					else
						_nextWait[idx] = data
						idx = idx + 1
					end
				end
			end
			_waitForTick = _nextWait
		end
	end
	Ext.Events.Tick:Subscribe(OnTick, {Priority=1})
end

--Globals / old API support

---@deprecated
---@see LeaderLibTimerSystem#Start
function StartTimer(timerName, delay, ...)
	Timer.Start(timerName, delay, ...)
end

---@deprecated
---@see LeaderLibTimerSystem#Cancel
function CancelTimer(...)
	Timer.Cancel(...)
end

---@deprecated
---@see LeaderLibTimerSystem#StartOneshot
function StartOneshotTimer(...)
	Timer.StartOneshot(...)
end