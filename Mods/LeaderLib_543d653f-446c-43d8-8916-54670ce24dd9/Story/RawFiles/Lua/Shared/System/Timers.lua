---@class LeaderLibTimerSystem
Timer = {}

local IsClient = Ext.IsClient()
local _EXTVERSION = Ext.Version()

Timer.TimerData = {}
Timer.TimerNameMap = {}

if not IsClient then
	setmetatable(Timer.TimerData, {
		__index = function (_,k) return PersistentVars.TimerData[k] end,
		__newindex = function (_,timerName,v)
			PersistentVars.TimerData[timerName] = v
		end
	})
	setmetatable(Timer.TimerNameMap, {
		__index = function (_,k) return PersistentVars.TimerNameMap[k] end,
		__newindex = function (_,timerName,v)
			PersistentVars.TimerNameMap[timerName] = v
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

---@param timerName string
---@param delay integer
---@param flashCallback function|nil Optional flash callback to invoke for v55 client-side timers.
local function _StartTimer(timerName, delay, flashCallback)
	if not IsClient then
		TimerCancel(timerName)
		TimerLaunch(timerName, delay)
	else
		if _EXTVERSION >= 56 then
			local resetTickTime = false
			for i,v in pairs(Timer.WaitForTick) do
				if v.ID == timerName then
					v.TargetTime = Ext.MonotonicTime() + delay
					v.Delay = delay
					resetTickTime = true
				end
			end
			if not resetTickTime then
				Timer.WaitForTick[#Timer.WaitForTick+1] = {
					ID = timerName,
					TargetTime = Ext.MonotonicTime() + delay,
					Delay = delay
				}
			end
		else
			UIExtensions.StartTimer(timerName, delay, flashCallback)
		end
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

function _INTERNAL.ClearOneshotSubscriptions(timerName)
	local indexes = _OneshotTimerIndexes[timerName]
	if indexes then
		for _,index in pairs(indexes) do
			Events.TimerFinished:Unsubscribe(index)
		end
		_OneshotTimerIndexes[timerName] = nil
	end
end

--- Starts an Osiris timer with a callback function to run when the timer is finished.
--- Not save safe since functions can't really be saved.
---@param timerName string
---@param delay integer
---@param callback fun(e:TimerFinishedEventArgs)
---@return integer index Returns the subscription callback index.
function Timer.StartOneshot(timerName, delay, callback)
	if StringHelpers.IsNullOrEmpty(timerName) then
		timerName = string.format("LeaderLib_%s%s", Ext.MonotonicTime(), Ext.Random())
	end
	local index = Events.TimerFinished:Subscribe(function(e)
		local b,err = xpcall(callback, debug.traceback, e)
		if not b then
			Ext.PrintError(err)
		end
	end, {Once=true, MatchArgs={ID=timerName}})
	if _OneshotTimerIndexes[timerName] == nil then
		_OneshotTimerIndexes[timerName] = {}
	end
	table.insert(_OneshotTimerIndexes[timerName], index)
	_StartTimer(timerName, delay)
	return index
end

---Cancels a timer with an optional UUID for object timers.
---@param timerName string
---@param object UUID|NETID|EsvGameObject|nil
function Timer.Cancel(timerName, object)
	_INTERNAL.ClearOneshotSubscriptions(timerName)
	if not IsClient then
		if object ~= nil then
			local uuid = GameHelpers.GetUUID(object)
			if uuid then
				local uniqueTimerName = string.format("%s%s", timerName, uuid)
				_INTERNAL.ClearData(uniqueTimerName)
			end
		end
		TimerCancel(timerName)
	else
		UIExtensions.RemoveTimerCallback(timerName)
		if _EXTVERSION >= 56 then
			for i,v in pairs(Timer.WaitForTick) do
				if v.ID == timerName then
					table.remove(Timer.WaitForTick, i)
				end
			end
		end
	end
	_INTERNAL.ClearData(timerName)
end

---Subscribe a callback for a timer name, or an array of timer names.
---@param name string|string[]
---@param callback fun(e:TimerFinishedEventArgs)
function Timer.Subscribe(name, callback)
	local t = type(name)
	if t == "string" then
		Events.TimerFinished:Subscribe(callback, {MatchArgs={ID=name}})
	elseif t == "table" then
		for _,v in pairs(name) do
			Timer.Subscribe(v, callback)
		end
	else
		fprint(LOGLEVEL.WARNING, "[Timer.Subscribe] name(%s) is not a valid timer need. Should be a string or table of strings.", name)
	end
end

--Support for older listeners where the callback params were (timerName, uuid|data)
local function CreateDeprecatedWrapper(callback)
	---@param e TimerFinishedEventArgs
	local wrapper = function(e)
		callback(e.ID, table.unpack(e.Data))
	end
	return wrapper
end

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

local function OnTimerFinished(timerName)
	local data = Timer.TimerData[timerName]
	local realTimerName = Timer.TimerNameMap[timerName]

	--Unique timer
	if realTimerName then
		timerName = realTimerName
		Timer.TimerNameMap[timerName] = nil
	end

	--print(timerName, Ext.DumpExport(data))

	if type(data) == "table" then
		for i=1,#data do
			local entry = data[i]
			local timerData = Lib.smallfolk.loads(entry)
			if timerData then
				if timerData.UUID then
					timerData.Object = GameHelpers.TryGetObject(timerData.UUID)
				end
				Events.TimerFinished:Invoke({ID=timerName, Data=timerData})
			else
				Events.TimerFinished:Invoke({ID=timerName, Data={entry}})
			end
		end
	else
		Events.TimerFinished:Invoke({ID=timerName, Data={data}})
	end

	if not IsClient then
		TurnCounter.OnTimerFinished(timerName)
	end

	_INTERNAL.ClearOneshotSubscriptions(timerName)
	Timer.TimerData[timerName] = nil
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
			_INTERNAL.StoreUniqueTimerName(uniqueTimerName, timerName, data)
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
---@param object UUID|NETID|EsvGameObject
---@param delay integer
---@vararg string|number|boolean|table Optional variable arguments that will be sent to the timer finished callback.
function Timer.StartObjectTimer(timerName, object, delay, ...)
	local uuid = GameHelpers.GetUUID(object)
	if uuid then
		Timer.StartUniqueTimer(timerName, uuid, delay, uuid, ...)
	else
		fprint(LOGLEVEL.WARNING, "[LeaderLib:StartObjectTimer] A valid object with a UUID is required. Parameter (%s) is invalid!", object or "nil")
	end
end

--#region Restarting

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

---Restarts a unique timer.
---@param timerName string The generalized timer name.
---@param uniqueVariance string The string that makes this timer unique, such as a UUID.
---@param delay integer
function Timer.RestartUniqueTimer(timerName, uniqueVariance, delay)
	local uniqueTimerName = string.format("%s%s", timerName, uniqueVariance)
	return Timer.Restart(uniqueTimerName, delay)
end

---Restarts an object timer.
---@param timerName string The generalized timer name. A unique name will be created using the timer name and object.
---@param object UUID|NETID|EsvGameObject
---@param delay integer
function Timer.RestartObjectTimer(timerName, object, delay)
	local uuid = GameHelpers.GetUUID(object)
	if uuid then
		return Timer.RestartUniqueTimer(timerName, uuid, delay)
	end
	return false
end
--#endregion

if not IsClient then
	Ext.RegisterOsirisListener("TimerFinished", 1, "after", OnTimerFinished)

	local function OnProcObjectTimerFinished(uuid, timerName)
		uuid = StringHelpers.GetUUID(uuid)
		local object = GameHelpers.TryGetObject(uuid)
		Events.TimerFinished:Invoke({ID=timerName, Data={Object=object, UUID=uuid}})
	end
	
	Ext.RegisterOsirisListener("ProcObjectTimerFinished", 2, "after", OnProcObjectTimerFinished)
end

if _EXTVERSION >= 56 then
	---@class ExtGameTime
	---@field Time number
	---@field DeltaTime number
	---@field Ticks integer

	---@class WaitForTickData
	---@field ID string
	---@field TargetTime integer
	---@field Delay integer
	
	---@private
	---@type WaitForTickData[]
	Timer.WaitForTick = {}

	---@param tickData ExtGameTime
	local function OnTick(tickData)
		local length = #Timer.WaitForTick
		if length > 0 then
			local time = Ext.MonotonicTime()
			for i=1,length do
				local data = Timer.WaitForTick[i]
				if data and data.TargetTime <= time then
					table.remove(Timer.WaitForTick, i)
					OnTimerFinished(data.ID)
				end
			end
		end
	end
	Ext.Events.Tick:Subscribe(function(data) OnTick(data.Time) end)
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