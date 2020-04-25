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
	LeaderLib.Print("[LeaderLib_Timers.lua:TryStartTimer] ", event, delay, LeaderLib.Common.Dump(uuids), paramCount)
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
function StartTimer(event, delay, ...)
	--LeaderLib.Print("LeaderLib:StartTimer: ", event, delay, LeaderLib.Common.Dump({...}))
	local status,err = xpcall(TryStartTimer, debug.traceback, event, delay, {...})
	if not status then
		Ext.PrintError("[LeaderLib:StartTimer] Error starting timer:\n", err)
	end
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
		LeaderLib.Print("[LeaderLib:CancelTimer] DB: ", Ext.JsonStringify(entry))
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
			LeaderLib.Print("[LeaderLib:CancelTimer] DB: ", Ext.JsonStringify(entry))
			timerName = entry[1][1]
			if timerName ~= nil then
				Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Delete(timerName, event, uuids[1], uuids[2])
			end
		end
	else
		Osi.DB_LeaderLib_Helper_Temp_LuaTimer:Delete(timerName, event)
	end
	LeaderLib.Print("[LeaderLib:CancelTimer] Canceling timer: ", timerName)
	if timerName ~= nil then
		TimerCancel(timerName)
	end
end

function TimerFinished(event, ...)
	if #LeaderLib.Listeners.TimerFinished > 0 then
		for i,callback in ipairs(LeaderLib.Listeners.TimerFinished) do
			local status,err = xpcall(callback, debug.traceback, event, ...)
			if not status then
				Ext.PrintError("[LeaderLib:CancelTimer] Error sending timer finished event:\n", err)
			end
		end
	end
end