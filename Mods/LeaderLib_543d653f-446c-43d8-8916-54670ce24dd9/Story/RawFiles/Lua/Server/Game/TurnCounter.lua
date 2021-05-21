if TurnCounter == nil then
	TurnCounter = {}
end

TurnCounter.DefaultTimerSpeed = 6000
TurnCounter.CombatMinDistance = 6.0

---@class TURNCOUNTER_MODE
TurnCounter.Mode = {
	Decrement = "decrement",
	Increment = "increment"
}

---@class TurnCounterData:table
---@field ID string
---@field Turns integer
---@field TargetTurns integer By default, 0 in decrement mode.
---@field Combat integer
---@field OutOfCombatSpeed integer|nil
---@field CountSkipDisabled boolean|nil If true, turn counting will not count a turn ending if it was skipped.
---@field Position number[]|nil
---@field Target string|nil An optional target for this counter. If set then only their turn ending will count the timer down.
---@field Mode TURNCOUNTER_MODE
---@field Data table Optional data to store in PersistentVars, such as a UUID.

function TurnCounter.CleanupData(uniqueId)
	PersistentVars.TurnCounterData[uniqueId] = nil
end


---@param id string Identifier for this countdown.
---@param turns integer How many turns to count.
---@param targetTurns integer The target turns, like 0 in decrement mode.
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
		--OutOfCombatSpeed = 6000
	}
	if params then
		params = TableHelpers.SanitizeTable(params)
		for k,v in pairs(params) do
			tbl[k] = v
		end
	end
	PersistentVars.TurnCounterData[uniqueId] = tbl
	if not GameHelpers.IsActiveCombat(combat) then
		local speed = tbl.OutOfCombatSpeed or TurnCounter.DefaultTimerSpeed
		StartTimer(uniqueId, speed)
	end
	TurnCounter.Started(tbl, uniqueId)
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

---@param data TurnCounterData
---@param uniqueId string
function TurnCounter.Started(data, uniqueId)
	InvokeListenerCallbacks(Listeners.OnTurnCounter, data.ID, data.Turns, data.Turns, false, data)
	InvokeListenerCallbacks(Listeners.OnNamedTurnCounter[data.ID], data.ID, data.Turns, data.Turns, false, data)
end

---@param data TurnCounterData
---@param uniqueId string
---@param lastTurn integer
function TurnCounter.CountdownDone(data, uniqueId, lastTurn)
	InvokeListenerCallbacks(Listeners.OnTurnCounter, data.ID, data.Turns, lastTurn, true, data)
	InvokeListenerCallbacks(Listeners.OnNamedTurnCounter[data.ID], data.ID, data.Turns, lastTurn, true, data)
	TurnCounter.CleanupData(uniqueId)
end

---@param data TurnCounterData
---@param uniqueId string
function TurnCounter.TickTurn(data, uniqueId)
	local last = data.Turns
	if data.Mode ~= TurnCounter.Mode.Increment then
		data.Turns = data.Turns - 1
		if data.Turns <= data.TargetTurns then
			TurnCounter.CountdownDone(data, uniqueId, last)
			return true
		end
	else
		data.Turns = data.Turns + 1
		if data.Turns >= data.TargetTurns then
			TurnCounter.CountdownDone(data, uniqueId, last)
			return true
		end
	end
	InvokeListenerCallbacks(Listeners.OnTurnCounter, data.ID, data.Turns, last, false, data)
	InvokeListenerCallbacks(Listeners.OnNamedTurnCounter[data.ID], data.ID, data.Turns, last, false, data)
	return false
end

local justSkippedTurn = {}

function TurnCounter.OnTurnEnded(uuid)
	if justSkippedTurn[uuid] then
		justSkippedTurn[uuid] = nil
		return false
	end
	local id = CombatGetIDForCharacter(uuid)
	if id then
		for uniqueId,data in pairs(PersistentVars.TurnCounterData) do
			if data.Combat == id and not (data.Target or data.Target == uuid) then
				TurnCounter.TickTurn(data, uniqueId)
			end
		end
	end
end

function TurnCounter.OnTurnSkipped(uuid)
	local id = CombatGetIDForCharacter(uuid)
	if id then
		for uniqueId,data in pairs(PersistentVars.TurnCounterData) do
			if data.Combat == id and data.CountSkipDisabled then
				justSkippedTurn[uuid] = true
			end
		end
	end
end

function TurnCounter.OnTimerFinished(uniqueId)
	local data = PersistentVars.TurnCounterData[uniqueId]
	if data then
		if not TurnCounter.TickTurn(data, uniqueId) then
			if not GameHelpers.IsActiveCombat(data.Combat) then
				StartTimer(uniqueId, data.OutOfCombatSpeed or TurnCounter.DefaultTimerSpeed)
			end
		end
	end
end

function TurnCounter.OnCombatStarted(id)
	local characters = GameHelpers.GetCombatCharacters(id)
	for uniqueId,data in pairs(PersistentVars.TurnCounterData) do
		if data.Combat == id then
			CancelTimer(uniqueId)
		elseif data.Position then
			if characters then
				local pos = Classes.Vector3(table.unpack(data.Position))
				for i,v in pairs(characters) do
					local pos2 = Classes.Vector3(table.unpack(v.WorldPos))
					if pos2:Distance(pos) <= TurnCounter.CombatMinDistance then
						data.Combat = id
						CancelTimer(uniqueId)
						break
					end
				end
			end
		end
	end
end

function TurnCounter.OnCombatEnded(id)
	for uniqueId,data in pairs(PersistentVars.TurnCounterData) do
		if data.Combat == id and data.Turns > 0 then
			StartTimer(uniqueId, data.OutOfCombatSpeed or TurnCounter.DefaultTimerSpeed)
		end
	end
end

Ext.RegisterOsirisListener("CombatStarted", Data.OsirisEvents.CombatStarted, "after", TurnCounter.OnCombatStarted)
Ext.RegisterOsirisListener("CombatEnded", Data.OsirisEvents.CombatEnded, "after", TurnCounter.OnCombatEnded)
Ext.RegisterOsirisListener("ObjectTurnEnded", Data.OsirisEvents.ObjectTurnEnded, "after", function(uuid) TurnCounter.OnTurnEnded(StringHelpers.GetUUID(uuid)) end)
Ext.RegisterOsirisListener("CharacterGuarded", Data.OsirisEvents.CharacterGuarded, "after", function(uuid) TurnCounter.OnTurnSkipped(StringHelpers.GetUUID(uuid)) end)