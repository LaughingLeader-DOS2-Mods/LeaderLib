if Testing == nil then
	Testing = {}
end

Testing.Results = {}
Testing.CurrentTime = 0
Testing.LastTime = Ext.MonotonicTime()
Testing.Waiting = {}
Testing.Active = false

---@type LuaTest
local LuaTest = Ext.Require("Shared/Debug/LuaTest.lua")

---@param name string
---@param operation LuaTestOperationCallback
---@return LuaTest
function Testing.CreateTest(name, operation)
	return LuaTest:Create(name, operation)
end

function Testing.WriteResults(uuid)
	if Testing.Results[uuid] and #Testing.Results[uuid] > 0 then
		local fileName = string.format("Tests/%s-%s.txt", uuid, Ext.MonotonicTime())
		Ext.SaveFile(fileName, StringHelpers.Join("\n", Testing.Results[uuid], false))
		Ext.Print("Saved test results to", fileName)
		Testing.Results[uuid] = nil
	end
	Testing.Active = false
end

function Testing.OnLoop(dt)
    Testing.CurrentTime = Testing.CurrentTime + dt

    local threadsToWake = {}
    for co,wakeupTime in pairs(Testing.Waiting) do
        if wakeupTime <= Testing.CurrentTime then
            table.insert(threadsToWake, co)
        end
    end

    -- Now wake them all up.
    for _,co in ipairs(threadsToWake) do
        Testing.Waiting[co] = nil -- Setting a field to nil removes it from the table
		if coroutine.status(co) == "suspended" then
        	coroutine.resume(co)
		end
    end
end

if Ext.IsServer() then
	Ext.RegisterListener("SessionLoaded", function()
		Timer.RegisterListener("LeaderLib_TestingSystemLoop", function()
			Testing.OnLoop(Ext.MonotonicTime() - Testing.LastTime)
			Testing.LastTime = Ext.MonotonicTime()
			if Testing.Active then
				StartTimer("LeaderLib_TestingSystemLoop", 250)
			else
				Testing.Waiting = {}
			end
		end)
	end)
end

---@param tbl LuaTest[]
---@param delay integer|nil
function Testing.RunTests(tbl, delay, testingName, ...)
	Testing.Active = true
	StartTimer("LeaderLib_TestingSystemLoop", 250)
	local args = {...}
	local testUUID = string.format("%s", testingName or Ext.MonotonicTime())
	Testing.Results[testUUID] = {}
	local testTextResults = Testing.Results[testUUID]

	local timerLaunchFunc = Ext.IsServer() and Timer.StartOneshot or UIExtensions.StartTimer
	local saveDelay = (#tbl+1) * (delay and delay + 1000 or 2000)
	timerLaunchFunc("Timers_Testing_SaveResults", saveDelay, function() Testing.WriteResults(testUUID) end)

	if delay and delay > 0 then
		local i = 0
		local runNext = nil
		local launchTimer = function(test)
			if test then
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib:Testing.RunTests] Test (%s) complete. Success(%s)", test.Name, test.Success)
			end
			timerLaunchFunc(string.format("LuaTesting_%s", Ext.MonotonicTime()), delay, runNext)
		end
		runNext = function()
			local lastTest = tbl[i]
			if lastTest then
				table.insert(testTextResults, lastTest:GetResultText())
				lastTest:Dispose()
			end
			i = i + 1
			local test = tbl[i]
			if test then
				test.OnComplete = launchTimer
				local co = coroutine.create(function()
					local b,result = xpcall(test.Run, debug.traceback, test, table.unpack(args))
					if not b then
						Ext.PrintError(result)
						launchTimer()
					end
				end)
				coroutine.resume(co)
			else
				Testing.WriteResults(testUUID)
			end
		end
		launchTimer()
	else
		for k,v in pairs(tbl) do
			v:Run()
			table.insert(testTextResults, string.format("%s: %s", v.Name, v.Success == 1 and "Passed" or "Failed"))
			v:Dispose()
		end
		Testing.WriteResults(testUUID)
	end
end