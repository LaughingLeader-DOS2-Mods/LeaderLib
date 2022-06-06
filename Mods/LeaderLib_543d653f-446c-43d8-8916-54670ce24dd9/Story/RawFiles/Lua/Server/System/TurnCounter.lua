if TurnCounter == nil then
	---@class LeaderLibTurnCounterSystem
	TurnCounter = {}
end

TurnCounter.DefaultTimerSpeed = 6000
TurnCounter.CombatMinDistance = 6.0

---@class TURNCOUNTER_MODE
TurnCounter.Mode = {
	Decrement = "decrement",
	Increment = "increment"
}

local _INTERNAL = {}

TurnCounter._Internal = _INTERNAL

---@class TurnCounterData:table
---@field ID string
---@field Turns integer
---@field TargetTurns integer By default, 0 in decrement mode.
---@field Combat integer
---@field OutOfCombatSpeed ?integer
---@field CombatOnly ?boolean If true, turn counting will only occur in combat.
---@field CountSkipDisabled ?boolean If true, turn counting will not count a turn ending if it was skipped. Otherwise, turn delays count towards the total.
---@field Position number[]|nil
---@field Target string|nil An optional target for this counter. If set then only their turn ending will count the timer down.
---@field Infinite boolean
---@field Mode TURNCOUNTER_MODE
---@field Data table Optional data to store in PersistentVars, such as a UUID.

function _INTERNAL.CleanupData(uniqueId)
	PersistentVars.TurnCounterData[uniqueId] = nil
end

---@param id string Identifier for this countdown.
---@param turns integer How many turns to count.
---@param targetTurns integer The target turns when the counting should be complete, such as 0 in decrement mode.
---@param mode TURNCOUNTER_MODE
---@param combat integer The combat id or character to get the combat id from.
---@param params TurnCounterData|nil
function TurnCounter.CreateTurnCounter(id, turns, targetTurns, mode, combat, params)
	local t = type(combat)
	if t == "string" then
		local cid = CombatGetIDForCharacter(combat)
		if cid then
			combat = cid
		end
	elseif t == "table" and not (params and params.Position) then
		if not params then
			params = {}
		end
		params.Position = combat
		combat = nil
	end
	local uniqueId = string.format("%s%s%s", id, Ext.MonotonicTime(), Ext.Random(9999))
	---@type TurnCounterData
	local tbl = {
		ID = id,
		Turns = turns,
		TargetTurns = targetTurns,
		Combat = combat or -1,
		Mode = mode,
		Infinite = false
		--OutOfCombatSpeed = 6000
	}
	if params then
		params = TableHelpers.SanitizeTable(params, nil, true)
		for k,v in pairs(params) do
			tbl[k] = v
		end
	end
	PersistentVars.TurnCounterData[uniqueId] = tbl
	if not GameHelpers.IsActiveCombat(combat) then
		local speed = tbl.OutOfCombatSpeed or TurnCounter.DefaultTimerSpeed
		StartTimer(uniqueId, speed)
	end
	_INTERNAL.Started(tbl, uniqueId)
end

---@param id string Identifier for this countdown.
---@param combatOrTarget integer|UUID|number[]|nil If specified, only turn counters with this specific combat ID, target, or position will be cleared.
function TurnCounter.ClearTurnCounter(id, combatOrTarget)
	for uniqueId,data in pairs(PersistentVars.TurnCounterData) do
		if data.ID == id then
			if combatOrTarget ~= nil then
				local t = type(combatOrTarget)
				if t == "number" then
					if data.Combat == combatOrTarget then
						PersistentVars.TurnCounterData[uniqueId] = nil
					end
				elseif t == "table" and data.Position == combatOrTarget then
					PersistentVars.TurnCounterData[uniqueId] = nil
				elseif data.Target == combatOrTarget then
					PersistentVars.TurnCounterData[uniqueId] = nil
				end
			else
				PersistentVars.TurnCounterData[uniqueId] = nil
			end
		end
	end
end

---@param id string Identifier for this countdown.
---@param turns integer How many turns to count down for.
---@param combat integer The combat id or character to get the combat id from.
---@param params TurnCounterData|nil
function TurnCounter.CountDown(id, turns, combat, params)
	TurnCounter.CreateTurnCounter(id, turns, 0,  TurnCounter.Mode.Decrement, combat, params)
end

---@param id string Identifier for this countdown.
---@param turns integer How many turns to count down for.
---@param combat integer The combat id or character to get the combat id from.
---@param params TurnCounterData|nil
function TurnCounter.CountUp(id, turns, combat, params)
	TurnCounter.CreateTurnCounter(id, 0, turns, TurnCounter.Mode.Increment, combat, params)
end

---@param id string|string[]|nil
---@param callback fun(e:OnTurnCounterEventArgs|SubscribableEventArgs)
function TurnCounter.Subscribe(id, callback)
	local t = type(id)
	if t == "table" then
		for _,v in pairs(id) do
			TurnCounter.Subscribe(v, callback)
		end
	elseif t == "string" then
		if StringHelpers.Equals(id, "All", true, true) then
			Events.OnTurnCounter:Subscribe(callback)
		else
			Events.OnTurnCounter:Subscribe(callback, {MatchArgs={ID=id}})
		end
	else
		Ext.PrintWarning("[TurnCounter.Subscribe] Registering a generic turn counter listener since id is nil. Consider using \"All\" instead.")
		Events.OnTurnCounter:Subscribe(callback)
	end
end

---@alias TurnCounterCallback fun(id:string, turn:integer, lastTurn:integer, finished:boolean, data:TurnCounterData):void

---@deprecated
---@see LeaderLibTurnCounterSystem#Subscribe
---@param id string|string[]|nil
---@param callback TurnCounterCallback
function TurnCounter.RegisterListener(id, callback)
	local t = type(id)
	if t == "table" then
		for _,v in pairs(id) do
			TurnCounter.RegisterListener(v, callback)
		end
	elseif t == "string" then
		if StringHelpers.Equals(id, "All", true, true) then
			RegisterListener("OnTurnCounter", callback)
		else
			RegisterListener("OnNamedTurnCounter", id, callback)
		end
	else
		Ext.PrintWarning("[TurnCounter.RegisterListener] Registering a generic turn counter listener since id is nil. Consider using \"All\" instead.")
		RegisterListener("OnTurnCounter", callback)
	end
end

---@param data TurnCounterData
---@param uniqueId string
function _INTERNAL.Started(data, uniqueId)
	Events.OnTurnCounter:Invoke({
		ID = data.ID,	
		Turn = data.Turns,
		LastTurn = data.Turns,
		Finished = false,
		Data = data,
	})
end

---@param data TurnCounterData
---@param uniqueId string
---@param lastTurn integer
function _INTERNAL.CountdownDone(data, uniqueId, lastTurn)
	Events.OnTurnCounter:Invoke({
		ID = data.ID,	
		Turn = data.Turns,
		LastTurn = data.Turns,
		Finished = true,
		Data = data,
	})
	_INTERNAL.CleanupData(uniqueId)
end

---@param uuid UUID
---@param id string The id to use in the callback.
function _INTERNAL.ListenForTurnEnding(uuid, id)
	if PersistentVars.WaitForTurnEnding[uuid] == nil then
		PersistentVars.WaitForTurnEnding[uuid] = {}
	end
	PersistentVars.WaitForTurnEnding[uuid][id] = true
end

---@param uuid UUID
function _INTERNAL.InvokeTurnEndedListeners(uuid)
	if PersistentVars.WaitForTurnEnding[uuid] then
		for id,b in pairs(PersistentVars.WaitForTurnEnding[uuid]) do
			if b then
				InvokeListenerCallbacks(Listeners.OnTurnEnded[id], uuid, id)
				InvokeListenerCallbacks(Listeners.OnTurnEnded.All, uuid, id)
			end
		end
		PersistentVars.WaitForTurnEnding[uuid] = nil
	end
end

---@param data TurnCounterData
---@param uniqueId string
function _INTERNAL.TickTurn(data, uniqueId)
	local last = data.Turns
	if data.Mode ~= TurnCounter.Mode.Increment then
		data.Turns = data.Turns - 1
		if not data.Infinite and data.Turns <= data.TargetTurns then
			_INTERNAL.CountdownDone(data, uniqueId, last)
			return true
		end
	else
		data.Turns = data.Turns + 1
		if not data.Infinite and data.Turns >= data.TargetTurns then
			_INTERNAL.CountdownDone(data, uniqueId, last)
			return true
		end
	end
	Events.OnTurnCounter:Invoke({
		ID = data.ID,	
		Turn = data.Turns,
		LastTurn = last,
		Finished = false,
		Data = data,
	})
	return false
end

local justSkippedTurn = {}

---@private
function _INTERNAL.OnTurnEnded(uuid)
	if justSkippedTurn[uuid] then
		justSkippedTurn[uuid] = nil
		return false
	end
	_INTERNAL.InvokeTurnEndedListeners(uuid)
	local id = CombatGetIDForCharacter(uuid)
	if id then
		for uniqueId,data in pairs(PersistentVars.TurnCounterData) do
			if data.Combat == id and (not data.Target or data.Target == uuid) then
				_INTERNAL.TickTurn(data, uniqueId)
			end
		end
	end
end

---@private
function _INTERNAL.OnTurnSkipped(uuid)
	local id = CombatGetIDForCharacter(uuid)
	if id then
		for uniqueId,data in pairs(PersistentVars.TurnCounterData) do
			if data.Combat == id and data.CountSkipDisabled then
				justSkippedTurn[uuid] = true
			end
		end
	end
end

---@private
function TurnCounter.OnTimerFinished(uniqueId)
	local data = PersistentVars.TurnCounterData[uniqueId]
	if data then
		if not _INTERNAL.TickTurn(data, uniqueId) then
			if not GameHelpers.IsActiveCombat(data.Combat) and not data.CombatOnly then
				Timer.Start(uniqueId, data.OutOfCombatSpeed or TurnCounter.DefaultTimerSpeed)
			end
		end
	end
end

---@private
function _INTERNAL.OnCombatStarted(id)
	local characters = GameHelpers.GetCombatCharacters(id)
	for uniqueId,data in pairs(PersistentVars.TurnCounterData) do
		if data.Combat and data.Combat == id then
			Timer.Cancel(uniqueId)
		else
			local pos = nil
			if data.Position then
				pos = data.Position
			elseif data.Target then
				pos = GameHelpers.Math.GetPosition(data.Target)
			end
			if pos and characters then
				for i,v in pairs(characters) do
					if GameHelpers.Math.GetDistance(pos, v.WorldPos) <= TurnCounter.CombatMinDistance then
						data.Combat = id
						Timer.Cancel(uniqueId)
						break
					end
				end
			end
		end
	end
end

---@private
function _INTERNAL.OnCombatEnded(id)
	for uniqueId,data in pairs(PersistentVars.TurnCounterData) do
		if data.Combat == id then
			data.Combat = nil
			if not data.CombatOnly then
				Timer.Start(uniqueId, data.OutOfCombatSpeed or TurnCounter.DefaultTimerSpeed)
			end
		end
	end
end

---@private
function _INTERNAL.OnLeftCombat(uuid, id)
	_INTERNAL.InvokeTurnEndedListeners(uuid)
end

RegisterProtectedOsirisListener("CombatStarted", Data.OsirisEvents.CombatStarted, "after", _INTERNAL.OnCombatStarted)
RegisterProtectedOsirisListener("CombatEnded", Data.OsirisEvents.CombatEnded, "after", _INTERNAL.OnCombatEnded)
RegisterProtectedOsirisListener("ObjectTurnEnded", Data.OsirisEvents.ObjectTurnEnded, "after", function(uuid) _INTERNAL.OnTurnEnded(StringHelpers.GetUUID(uuid)) end)
RegisterProtectedOsirisListener("CharacterGuarded", Data.OsirisEvents.CharacterGuarded, "after", function(uuid) _INTERNAL.OnTurnSkipped(StringHelpers.GetUUID(uuid)) end)
RegisterProtectedOsirisListener("ObjectLeftCombat", Data.OsirisEvents.ObjectLeftCombat, "after", function(uuid, id) _INTERNAL.OnLeftCombat(StringHelpers.GetUUID(uuid), id) end)