-- This table is indexed by coroutine and simply contains the time at which the coroutine
-- should be woken up.
local WAITING_ON_TIME = {}
local WAITING_ON_MOVE = {}
-- Keep track of how long the game has been running.
local CURRENT_TIME = 0

local savedStates = {}

local function wait(ms, id)
	if id and savedStates[id] == true then
		return
	end
    -- Grab a reference to the current running coroutine.
    local co = coroutine.running()

    -- If co is nil, that means we're on the main process, which isn't a coroutine and can't yield
    assert(co ~= nil, "The main thread cannot wait!")

    -- Store the coroutine and its wakeup time in the WAITING_ON_TIME table
    local wakeupTime = CURRENT_TIME + ms
    WAITING_ON_TIME[co] = wakeupTime

    -- And suspend the process
    return coroutine.yield(co)
end

local function moveToPosition(obj, id, x, y, z, running)
	if running == nil then
		running = true
	end
	local co = coroutine.running()
	if WAITING_ON_MOVE[id] == nil then
		WAITING_ON_MOVE[id] = {}
	end
	WAITING_ON_MOVE[id][obj] = co

	CharacterMoveToPosition(obj, x, y, z, running, id)
	return coroutine.yield(co)
end

Ext.RegisterOsirisListener("StoryEvent", 2, "after", function(obj, event)
	local waiting = WAITING_ON_MOVE[event]
	if waiting then
		local obj = StringHelpers.GetUUID(obj)
		local co = waiting[obj]
		if co then
			waiting[obj] = nil
			coroutine.resume(co)
		end
		local length = Common.TableLength(waiting, true)
		if length == 0 then
			WAITING_ON_MOVE[event] = nil
		end
	end
end)

local function wakeUpWaitingThreads(dt)
    -- This function should be called once per game logic update with the amount of time
    -- that has passed since it was last called
    CURRENT_TIME = CURRENT_TIME + dt

    -- First, grab a list of the threads that need to be woken up. They'll need to be removed
    -- from the WAITING_ON_TIME table which we don't want to try and do while we're iterating
    -- through that table, hence the list.
    local threadsToWake = {}
    for co, wakeupTime in pairs(WAITING_ON_TIME) do
        if wakeupTime < CURRENT_TIME then
            table.insert(threadsToWake, co)
        end
    end

    -- Now wake them all up.
    for _, co in ipairs(threadsToWake) do
        WAITING_ON_TIME[co] = nil -- Setting a field to nil removes it from the table
        coroutine.resume(co)
    end
end

local function runProcess(func)
    -- This function is just a quick wrapper to start a coroutine.
    local co = coroutine.create(func)
    return coroutine.resume(co)
end

Timer.Subscribe("LeaderLib_CoroutineLoop", function()
	wakeUpWaitingThreads(250)
	Timer.Start("LeaderLib_CoroutineLoop", 250)
end)

Ext.RegisterConsoleCommand("coroutinetest", function(cmd)
	Timer.Start("LeaderLib_CoroutineLoop", 250)
	runProcess(function ()
		local startTime = Ext.MonotonicTime()
		fprint(LOGLEVEL.TRACE, "Hello world. I will now astound you by waiting for 2 seconds.", Ext.MonotonicTime())
		wait(2000)
		fprint(LOGLEVEL.TRACE, "Haha! I did it! [%s]", Ext.MonotonicTime() - startTime)
		local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
		local x,y,z = table.unpack(GameHelpers.Math.GetForwardPosition(host, 3.0))
		fprint(LOGLEVEL.TRACE, "Moving to (%s;%s;%s)", x, y, z)
		moveToPosition(host, "LeaderLib_CoroutineMove", x, y, z, true)
		fprint(LOGLEVEL.TRACE, "Move done! (%s)", StringHelpers.Join(";", GameHelpers.Math.GetPosition(host)))
		Timer.Cancel("LeaderLib_CoroutineLoop")
	end)
end)