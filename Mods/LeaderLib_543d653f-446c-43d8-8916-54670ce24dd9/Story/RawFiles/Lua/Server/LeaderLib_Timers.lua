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
	Ext.Print("TryStartTimer: ", event, delay, LeaderLib.Common.Dump(uuids), paramCount)
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
	TimerCancel(timerName)
	TimerLaunch(timerName, delay)
end

---Starts an Osiris timer with a variable amount of UUIDs (or none).
---@param event string
---@param delay integer
function LeaderLib_Ext_StartTimer(event, delay, ...)
	Ext.Print("LeaderLib_Ext_StartTimer: ", event, delay, LeaderLib.Common.Dump({...}))
	local status,err = xpcall(TryStartTimer, debug.traceback, event, delay, {...})
	if not status then
		Ext.PrintError("Error starting timer:\n", err)
	end
end

function LeaderLib_Ext_TimerFinished(event, ...)
	if #LeaderLib.Listeners.TimerFinished > 0 then
		for i,callback in ipairs(LeaderLib.Listeners.TimerFinished) do
			local status,err = xpcall(callback, debug.traceback, event, ...)
			if not status then
				Ext.PrintError("Error sending timer finished event:\n", err)
			end
		end
	end
end