if Timer == nil then
	Timer = {}
end

local IsClient = Ext.IsClient()

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

---[SERVER]
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
		UIExtensions.StartTimer(timerName, delay, callback)
	end
	return true
end

---@param timerName string
---@param delay integer
function Timer.RestartOneShot(timerName, delay)
	if OneshotTimerData[timerName] then
		TimerCancel(timerName)
		TimerLaunch(timerName, delay)
		return true
	end
	return false
end

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
		--UIExtensions.RemoveTimerCallback(timerName)
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
			tbl[i] = Ext.GetGameObject(tbl[i]) or tbl[i]
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
---@param fetchGameObjects boolean If true, any UUIDs passed into the timer callback are transformed into EsvCharacter/EsvItem.
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

if not IsClient then
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
		Timer.StoreData(uniqueTimerName, data)
	end

	local function InvokeTimerListeners(tbl, timerName, data)
		if type(data) == "table" then
			InvokeListenerCallbacks(tbl, timerName, table.unpack(data))
		else
			InvokeListenerCallbacks(tbl, timerName, data)
		end
	end

	local function OnTimerFinished(timerName)
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