Timer = {}

local IsClient = Ext.IsClient()
local _EXTVERSION = Ext.Version()

---[SERVER]
---Starts an Osiris timer with optional data to include in the callback. Only strings, numbers, and booleans are accepted for optional parameters.
---@param timerName string
---@param delay integer
---@param ... string|number|boolean Optional variable arguments that will be sent to the timer finished callback.
---@vararg string|number|boolean
function Timer.Start(timerName, delay, ...)
	if not IsClient then
		local data = {...}
		if #data > 0 then
			Timer.StoreData(timerName, data)
		end
		TimerCancel(timerName)
		TimerLaunch(timerName, delay)
	else
		Ext.PrintWarning("[LeaderLib:StartTimer] This function is intended for server-side. Use Timer.StartOneshot on the client!")
	end
end

local OneshotTimerData = {}

---Deprecated @see Timer.Start
StartTimer = Timer.Start

--- Starts an Osiris timer with a callback function to run when the timer is finished.
--- Not save safe since functions can't really be saved.
---@param timerName string
---@param delay integer
---@param callback function
function Timer.StartOneshot(timerName, delay, callback)
	if StringHelpers.IsNullOrEmpty(timerName) then
		timerName = string.format("LeaderLib_%s%s", Ext.MonotonicTime(), Ext.Random())
	end
	if not IsClient then
		if OneshotTimerData[timerName] == nil then
			OneshotTimerData[timerName] = {}
		else
			-- Skip duplicate callbacks
			for i,v in pairs(OneshotTimerData[timerName]) do
				if v == callback then
					TimerCancel(timerName)
					TimerLaunch(timerName, delay)
					return true
				end
			end
		end
		table.insert(OneshotTimerData[timerName], callback)
		TimerCancel(timerName)
		TimerLaunch(timerName, delay)
	else
		if _EXTVERSION >= 56 then
			if OneshotTimerData[timerName] == nil then
				OneshotTimerData[timerName] = {callback}
				Timer.WaitForTick[#Timer.WaitForTick+1] = {
					ID = timerName,
					TargetTime = Ext.MonotonicTime() + delay,
					Delay = delay
				}
			else
				local timerData = OneshotTimerData[timerName]
				local hasWaitForTick = false
				for i=1,#Timer.WaitForTick do
					local v = Timer.WaitForTick[i]
					if v.ID == timerName then
						v.TargetTime = Ext.MonotonicTime() + delay
						hasWaitForTick = true
					end
				end
				if not hasWaitForTick then
					Timer.WaitForTick[#Timer.WaitForTick+1] = {
						ID = timerName,
						TargetTime = Ext.MonotonicTime() + delay,
						Delay = delay
					}
				end
				local alreadyAdded = false
				for i=1,#timerData do
					local v = timerData[i]
					if v == callback then
						alreadyAdded = true
					end
				end
				if not alreadyAdded then
					timerData[#timerData+1] = callback
				end
			end
			
		else
			UIExtensions.StartTimer(timerName, delay, callback)
		end
	end
	return true
end

---@param timerName string
---@param delay integer
function Timer.RestartOneshot(timerName, delay)
	if OneshotTimerData[timerName] then
		if not IsClient then
			TimerCancel(timerName)
			TimerLaunch(timerName, delay)
		elseif _EXTVERSION >= 56 then
			for i,v in pairs(Timer.WaitForTick) do
				if v.ID == timerName then
					v.TargetTime = Ext.MonotonicTime() + (delay or v.Delay)
				end
			end
		end
		return true
	end
	return false
end

--Whoops
---@private
Timer.RestartOneShot = Timer.RestartOneshot
StartOneshotTimer = Timer.StartOneshot

---Cancels a timer with an optional UUID for object timers.
---@param timerName string
---@param object UUID|NETID|EsvGameObject|nil
function Timer.Cancel(timerName, object)
	if not IsClient then
		if object ~= nil then
			local uuid = GameHelpers.GetUUID(object)
			if uuid then
				local uniqueTimerName = string.format("%s%s", timerName, uuid)
				if PersistentVars.TimerNameMap[uniqueTimerName] == timerName then
					PersistentVars.TimerNameMap[uniqueTimerName] = nil
					PersistentVars.TimerData[uniqueTimerName] = nil
					TimerCancel(uniqueTimerName)
				end
			end
		else
			TimerCancel(timerName)
			OneshotTimerData[timerName] = nil
			PersistentVars.TimerNameMap[timerName] = nil
			PersistentVars.TimerData[timerName] = nil
		end
	else
		OneshotTimerData[timerName] = nil
		UIExtensions.RemoveTimerCallback(timerName)
		if _EXTVERSION >= 56 then
			for i,v in pairs(Timer.WaitForTick) do
				if v.ID == timerName then
					table.remove(Timer.WaitForTick, i)
				end
			end
		end
	end
end

CancelTimer = Timer.Cancel

---@private
---Called from Osiris. Deprecated.
---@param event string
---@vararg string
function OnLuaTimerFinished(event, ...) end

local function WrapCallbackObjects(tbl)
	if #tbl == 0 then
		return
	else
		for i=1,#tbl do
			tbl[i] = GameHelpers.TryGetObject(tbl[i]) or tbl[i]
		end
	end
	return table.unpack(tbl)
end

---@alias SerializableValue string|number|boolean
---@alias TimerCallbackObjectParam SerializableValue|EsvCharacter|EsvItem|table<string|integer, SerializableValue>

---A timer callback that returns any variable number of properties.
---@alias TimerCallback fun(timerName:string, ...:TimerCallbackObjectParam):void

---@param name string|string[]|TimerCallback Timer name or the callback if a ganeric listener.
---@param callback TimerCallback
---@param fetchGameObjects boolean|nil If true, any UUIDs passed into the timer callback are transformed into EsvCharacter/EsvItem.
function Timer.RegisterListener(name, callback, fetchGameObjects)
	local t = type(name)
	if t == "string" and not IsClient then
		if not fetchGameObjects then
			RegisterListener("NamedTimerFinished", name, callback)
		else
			RegisterListener("NamedTimerFinished", name, function(timerName, ...)
				callback(timerName, WrapCallbackObjects({...}))
			end)
		end
	elseif t == "function" then
		if not fetchGameObjects then
			RegisterListener("TimerFinished", name, callback)
		else
			RegisterListener("TimerFinished", name, function(timerName, ...)
				callback(timerName, WrapCallbackObjects({...}))
			end)
		end
	elseif t == "table" then
		for _,v in pairs(name) do
			Timer.RegisterListener(v, callback)
		end
	end
end

local function InvokeTimerListeners(tbl, timerName, data)
	if data ~= nil then
		if type(data) == "table" then
			InvokeListenerCallbacks(tbl, timerName, table.unpack(data))
		else
			InvokeListenerCallbacks(tbl, timerName, data)
		end
	else
		InvokeListenerCallbacks(tbl, timerName)
	end
end

local function OnTimerFinished(timerName)
	if not IsClient then
		local data = PersistentVars.TimerData[timerName]
		PersistentVars.TimerData[timerName] = nil
		
		if PersistentVars.TimerNameMap[timerName] then
			local realTimerName = PersistentVars.TimerNameMap[timerName]
			PersistentVars.TimerNameMap[timerName] = nil
			timerName = realTimerName
		end
		if type(data) == "table" then
			for i=1,#data do
				local timerData = Lib.smallfolk.loads(data[i])
				if OneshotTimerData[timerName] ~= nil then
					InvokeTimerListeners(OneshotTimerData[timerName], timerName, timerData)
					OneshotTimerData[timerName] = nil
				end
				InvokeTimerListeners(Listeners.TimerFinished, timerName, timerData)
				InvokeTimerListeners(Listeners.NamedTimerFinished[timerName], timerName, timerData)
			end
		else
			if OneshotTimerData[timerName] ~= nil then
				InvokeTimerListeners(OneshotTimerData[timerName], timerName, data)
				OneshotTimerData[timerName] = nil
			end
			InvokeTimerListeners(Listeners.TimerFinished, timerName, data)
			InvokeTimerListeners(Listeners.NamedTimerFinished[timerName], timerName, data)
		end
	
		TurnCounter.OnTimerFinished(timerName)
	else
		if OneshotTimerData[timerName] ~= nil then
			InvokeTimerListeners(OneshotTimerData[timerName], timerName)
			OneshotTimerData[timerName] = nil
		end
	end
end

if not IsClient then
	---Starts an Osiris timer for an object, with optional data to include in the callback. Only strings, numbers, and booleans are accepted for optional parameters.
	---@param timerName string The generalized timer name. A unique name will be created using the timer name and object.
	---@param object UUID|NETID|EsvGameObject
	---@param delay integer
	---@param ... string|number|boolean Optional variable arguments that will be sent to the timer finished callback.
	---@vararg string|number|boolean|table
	function Timer.StartObjectTimer(timerName, object, delay, ...)
		if not IsClient then
			local uuid = GameHelpers.GetUUID(object)
			if uuid then
				local uniqueTimerName = string.format("%s%s", timerName, uuid)
				local data = {...}
				if #data > 0 then
					Timer.StoreObjectData(uniqueTimerName, timerName, data)
				else
					Timer.StoreObjectData(uniqueTimerName, timerName, uuid)
				end
				TimerCancel(uniqueTimerName)
				TimerLaunch(uniqueTimerName, delay)
			else
				fprint(LOGLEVEL.WARNING, "[LeaderLib:StartObjectTimer] A valid object is required. Parameter (%s) is invalid!", object or "nil")
			end
		else
			Ext.PrintWarning("[LeaderLib:StartObjectTimer] This function is intended for server-side. Use Timer.StartOneshot on the client!")
		end
	end

	---Restarts an object timer.
	---@param timerName string The generalized timer name. A unique name will be created using the timer name and object.
	---@param object UUID|NETID|EsvGameObject
	---@param delay integer
	function Timer.RestartObjectTimer(timerName, object, delay)
		local uuid = GameHelpers.GetUUID(object)
		if uuid then
			local uniqueTimerName = string.format("%s%s", timerName, uuid)
			TimerCancel(uniqueTimerName)
			TimerLaunch(uniqueTimerName, delay)
		end
	end

	---Starts an Osiris timer with a unique string variance, with optional data to include in the callback. Only strings, numbers, and booleans are accepted for optional parameters.
	---This is similar to an object timer, but you can set the unique string directly.
	---@param timerName string The generalized timer name. A unique name will be created using the timer name and object.
	---@param uniqueVariance string The string that makes this timer unique, such as a UUID.
	---@param delay integer
	---@param ... string|number|boolean Optional variable arguments that will be sent to the timer finished callback.
	---@vararg string|number|boolean|table
	function Timer.StartUniqueTimer(timerName, uniqueVariance, delay, ...)
		if not IsClient then
			if uniqueVariance then
				local uniqueTimerName = string.format("%s%s", timerName, uniqueVariance)
				local data = {...}
				if #data > 0 then
					Timer.StoreObjectData(uniqueTimerName, timerName, data)
				else
					Timer.StoreObjectData(uniqueTimerName, timerName)
				end
				TimerCancel(uniqueTimerName)
				TimerLaunch(uniqueTimerName, delay)
			else
				fprint(LOGLEVEL.WARNING, "[LeaderLib:StartUniqueTimer] A valid object is required. Parameter (%s) is invalid!", object or "nil")
			end
		else
			Ext.PrintWarning("[LeaderLib:StartUniqueTimer] This function is intended for server-side. Use Timer.StartOneshot on the client!")
		end
	end

	---Restarts a unique timer.
	---@param timerName string The generalized timer name.
	---@param uniqueVariance string The string that makes this timer unique, such as a UUID.
	---@param delay integer
	function Timer.RestartUniqueTimer(timerName, uniqueVariance, delay)
		local uniqueTimerName = string.format("%s%s", timerName, uniqueVariance)
		TimerCancel(uniqueTimerName)
		TimerLaunch(uniqueTimerName, delay)
	end

	---@private
	function Timer.StoreData(timerName, data)
		if not PersistentVars.TimerData[timerName] then
			PersistentVars.TimerData[timerName] = {}
		end
		table.insert(PersistentVars.TimerData[timerName], Lib.smallfolk.dumps(data))
	end

	---@private
	function Timer.StoreObjectData(uniqueTimerName, generalTimerName, data)
		PersistentVars.TimerNameMap[uniqueTimerName] = generalTimerName
		--Clear previous, in case the timer is being restarted
		PersistentVars.TimerData[uniqueTimerName] = nil
		Timer.StoreData(uniqueTimerName, data)
	end

	---@private
	function Timer.ClearObjectData(timerName, object)
		local uniqueTimerName = string.format("%s%s", timerName, GameHelpers.GetUUID(object))
		if uniqueTimerName then
			PersistentVars.TimerData[uniqueTimerName] = nil
		end
	end

	Ext.RegisterOsirisListener("TimerFinished", 1, "after", OnTimerFinished)

	local function OnProcObjectTimerFinished(object, timerName)
		object = StringHelpers.GetUUID(object)
		InvokeListenerCallbacks(Listeners.ProcObjectTimerFinished[timerName], object, timerName)
		InvokeListenerCallbacks(Listeners.ProcObjectTimerFinished["all"], object, timerName)
		InvokeListenerCallbacks(Listeners.NamedTimerFinished[timerName], timerName, object)
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