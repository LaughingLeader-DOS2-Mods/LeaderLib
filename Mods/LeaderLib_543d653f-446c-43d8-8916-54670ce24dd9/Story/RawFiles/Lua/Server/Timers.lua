local function GetParamsCount(tbl)
	local count = 0
	for i,v in pairs(tbl) do
		count = count + 1
	end
	return count
end

local function TryStartTimer(event, delay, uuids)
	local timerName = event
	local paramCount = GetParamsCount(uuids)
	--PrintDebug("[LeaderLib_Timers.lua:TryStartTimer] ", event, delay, Common.Dump(uuids), paramCount)
	if uuids == nil or paramCount == 0 then
		Osi.LeaderLib_Timers_Internal_StoreLuaData(timerName, event)
	else
		if paramCount == 1 then
			timerName = event..uuids[1]
			Osi.LeaderLib_Timers_Internal_StoreLuaData(timerName, event, uuids[1])
		elseif paramCount >= 2 then
			timerName = event..uuids[1]..uuids[2]
			Osi.LeaderLib_Timers_Internal_StoreLuaData(timerName, event, uuids[1], uuids[2])
		end
	end
	--PrintDebug("[LeaderLib_Timers.lua:TryStartTimer] ", Common.Dump(Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Get(nil,nil)))
	TimerCancel(timerName)
	TimerLaunch(timerName, delay)
end

---Starts an Osiris timer with a variable amount of UUIDs (or none).
---@param event string
---@param delay integer
---@vararg string
function StartTimer(event, delay, ...)
	-- if Vars.DebugMode then
	-- 	fprint(LOGLEVEL.TRACE, "LeaderLib:StartTimer(%s, %s, %s)", event, delay, Common.Dump({...}))
	-- end
	local b,err = xpcall(TryStartTimer, debug.traceback, event, delay, {...})
	if not b then
		Ext.PrintError("[LeaderLib:StartTimer] Error starting timer:\n", err)
	end
end
local OneshotTimerData = {}

--- Starts an Osiris timer with a callback function to run when the timer is finished.
--- Not save safe since functions can't really be saved.
---@param timerName string
---@param delay integer
---@param callback function
function StartOneshotTimer(timerName, delay, callback)
	if StringHelpers.IsNullOrEmpty(timerName) then
		timerName = string.format("Timers_LeaderLib_%s%s", Ext.MonotonicTime(), Ext.Random())
	end
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
	return true
end

---Cancels an Osiris timer with a variable amount of UUIDs (or none).
---@param event string
function CancelTimer(event, ...)
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
end

function OnTimerFinished(event, ...)
	--PrintDebug("[LeaderLib_Timers.lua:TimerFinished] ", event, Common.Dump({...}))
	if OneshotTimerData[event] ~= nil then
		for i,callback in pairs(OneshotTimerData[event]) do
			local b,err = xpcall(callback, debug.traceback, event, ...)
			if not b then
				Ext.PrintError("[LeaderLib:CancelTimer] Error calling oneshot timer callback:\n", err)
			end
		end
		OneshotTimerData[event] = nil
	end
	InvokeListenerCallbacks(Listeners.TimerFinished, event, ...)
	InvokeListenerCallbacks(Listeners.NamedTimerFinished[event], event, ...)
end

local function OnProcObjectTimerFinished(object, timerName)
	object = StringHelpers.GetUUID(object)
	local listeners = Listeners.ProcObjectTimerFinished[timerName]
	if listeners then
		InvokeListenerCallbacks(listeners, object, timerName)
	end
	local allListeners = Listeners.ProcObjectTimerFinished["all"]
	if allListeners then
		InvokeListenerCallbacks(allListeners, object, timerName)
	end
end

Ext.RegisterOsirisListener("ProcObjectTimerFinished", 2, "after", OnProcObjectTimerFinished)