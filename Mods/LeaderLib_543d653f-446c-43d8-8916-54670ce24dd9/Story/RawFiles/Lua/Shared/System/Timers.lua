if Timer == nil then
	Timer = {}
end

local IsClient = Ext.IsClient()

local function TryStartTimer(timerName, delay, data)
	if not IsClient then
		if #data > 0 then
			Timer.StoreData(timerName, data)
		end
		--PrintDebug("[LeaderLib_Timers.lua:TryStartTimer] ", Common.Dump(Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Get(nil,nil)))
		TimerCancel(timerName)
		TimerLaunch(timerName, delay)
	end
end

---[SERVER]
---Starts an Osiris timer with optional data to include in the callback. Only strings, numbers, and booleans are accepted for optional parameters.
---@param timerName string
---@param delay integer
---@vararg string|number|boolean
function Timer.Start(timerName, delay, ...)
	if not IsClient then
		local b,err = xpcall(TryStartTimer, debug.traceback, timerName, delay, {...})
		if not b then
			Ext.PrintError("[LeaderLib:StartTimer] Error starting timer:\n", err)
		end
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
		timerName = string.format("Timers_LeaderLib_%s%s", Ext.MonotonicTime(), Ext.Random())
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
		Osi.LeaderLib_Timers_Internal_StoreLuaData(timerName, timerName)
		TimerCancel(timerName)
		TimerLaunch(timerName, delay)
	else
		UIExtensions.StartTimer(timerName, delay, callback)
	end
	return true
end

StartOneshotTimer = Timer.StartOneshot

---Cancels an Osiris timer with a variable amount of UUIDs (or none).
---@param event string
function Timer.Cancel(event, ...)
	if not IsClient then
		local timerName = event
		local uuids = {...}
		local paramCount = GetParamsCount(uuids)
		local entry = nil
		if paramCount >= 1 then
			timerName = event..uuids[1]
			entry = Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Get(nil, event, uuids[1])
			--PrintDebug("[LeaderLib:CancelTimer] DB: ", Ext.JsonStringify(entry))
			if entry ~= nil and #entry > 0 then
				timerName = entry[1][1]
				if timerName ~= nil then
					Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Delete(timerName, event, uuids[1])
				end
			end
		elseif paramCount >= 2 then
			timerName = event..uuids[1]..uuids[2]
			entry = Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Get(nil, event, uuids[1], uuids[2])
			if entry ~= nil and #entry > 0 then
				--PrintDebug("[LeaderLib:CancelTimer] DB: ", Ext.JsonStringify(entry))
				timerName = entry[1][1]
				if timerName ~= nil then
					Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Delete(timerName, event, uuids[1], uuids[2])
				end
			end
		else
			Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Delete(timerName, event)
		end
		--PrintDebug("[LeaderLib:CancelTimer] Canceling timer: ", timerName)
		if timerName ~= nil then
			TimerCancel(timerName)
		end
		if OneshotTimerData[event] ~= nil then
			OneshotTimerData[event] = nil
		end
	else
		--UIExtensions.RemoveTimerCallback(event)
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

---@alias TimerObjectParam string|EsvCharacter|EsvItem|nil
---@alias TimerCallback fun(timerName:string, obj1:TimerObjectParam, obj2:TimerObjectParam):void

---@param name string|string[]|TimerCallback Timer name or the callback if a ganeric listener.
---@param callback TimerCallback
---@param fetchGameObjects boolean If true, any UUIDs passed into the timer callback are transformed into EsvCharacter/EsvItem.
function Timer.RegisterListener(name, callback, fetchGameObjects)
	local t = type(name)
	if t == "string" then
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

	local function InvokeTimerListeners(tbl, timerName, data)
		if data then
			InvokeListenerCallbacks(tbl, timerName, table.unpack(data))
		else
			InvokeListenerCallbacks(tbl, timerName)
		end
	end

	local function OnTimerFinished(timerName)
		local data = PersistentVars.TimerData[timerName]
		if data then
			for i=1,#data do
				local timerData = Lib.smallfolk.loads(data[i])
				if OneshotTimerData[timerName] ~= nil then
					InvokeTimerListeners(OneshotTimerData[timerName], timerName, timerData)
					OneshotTimerData[timerName] = nil
				end
				InvokeTimerListeners(Listeners.TimerFinished, timerName, timerData)
				InvokeTimerListeners(Listeners.NamedTimerFinished[timerName], timerName, timerData)
			end
			PersistentVars.TimerData[timerName] = nil
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