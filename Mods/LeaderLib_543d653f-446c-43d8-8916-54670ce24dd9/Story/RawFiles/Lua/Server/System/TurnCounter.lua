if TurnCounter == nil then
	---@class LeaderLibTurnCounterSystem
	TurnCounter = {}
end

Managers.TurnCounter = TurnCounter

TurnCounter.DefaultTimerSpeed = 6000
TurnCounter.CombatMinDistance = 6.0

---@enum TURNCOUNTER_MODE
TurnCounter.Mode = {
	Decrement = "decrement",
	Increment = "increment"
}

local _INTERNAL = {}

TurnCounter._Internal = _INTERNAL

---@class TurnCounterData
---@field ID string
---@field Turns integer
---@field TargetTurns integer By default, 0 in decrement mode.
---@field Combat integer
---@field RoundOnly boolean Only count rounds, not turns.
---@field OutOfCombatSpeed integer
---@field CombatOnly boolean If true, turn counting will only occur in combat.
---@field CountSkipDisabled boolean If true, turn counting will not count a turn ending if it was skipped. Otherwise, turn delays count towards the total.
---@field ClearOnDeath boolean If the Target is an object, this turn counter will be cleared if they die.
---@field Position number[]
---@field Region string The level this turn counter was created in.
---@field Target Guid An optional target for this counter. If set then only their turn ending will count the timer down.
---@field TargetObject EsvCharacter|EsvItem|nil If Target is set, this is the object version of it.
---@field Infinite boolean If true, this counter will count until stopped, or if the counter is cleared (target death if ClearOnDeath is set). 
---@field Mode TURNCOUNTER_MODE
---@field Extra table Optional extra data to store in PersistentVars, such as `{Source=source.MyGuid}`.

function _INTERNAL.CleanupData(uniqueId)
	_PV.TurnCounterData[uniqueId] = nil
	Timer.Cancel(uniqueId)
end

---The combat id, character to get the combat id from / use as a target, or a position.
---@alias TurnCounterTargetParamType integer|CharacterParam|vec3

---@param id string Identifier for this countdown.
---@param turns integer How many turns to count.
---@param targetTurns integer The target turns when the counting should be complete, such as 0 in decrement mode.
---@param mode TURNCOUNTER_MODE
---@param target TurnCounterTargetParamType The combat id or character to get the combat id from.
---@param params? TurnCounterData
function TurnCounter.CreateTurnCounter(id, turns, targetTurns, mode, target, params)
	params = params or {}
	local t = type(target)
	local combatID = -1
	if t == "string" or GameHelpers.Ext.IsObjectType(target) then
		local cid = GameHelpers.Combat.GetID(target)
		if cid then
			combatID = cid
		end
		local object = GameHelpers.TryGetObject(target)
		if object then
			target = object.MyGuid
		end
	elseif t == "table" and not params.Position then
		params.Position = target
		target = nil
	elseif t == "number" then
		combatID = target
		target = nil
	end
	local uniqueId = string.format("%s%s%s", id, Ext.Utils.MonotonicTime(), Ext.Utils.Random(9999))
	---@type TurnCounterData
	local tbl = {
		ID = id,
		Turns = turns,
		TargetTurns = targetTurns,
		Combat = combatID,
		Mode = mode,
		Target = target,
		Infinite = false,
		Extra = {},
		--OutOfCombatSpeed = 6000
	}
	if type(params) == "table" then
		for k,v in pairs(params) do
			tbl[k] = v
		end
	end
	tbl.Region = SharedData.RegionData.Current
	_PV.TurnCounterData[uniqueId] = TableHelpers.SanitizeTable(tbl, nil, true)
	if not GameHelpers.IsActiveCombat(combatID) and tbl.CombatOnly ~= true then
		local speed = tbl.OutOfCombatSpeed or TurnCounter.DefaultTimerSpeed
		Timer.Start(uniqueId, speed)
	end
	_INTERNAL.Started(tbl, uniqueId)
end

---@param id string Identifier for this countdown.
---@param combatOrTarget? integer|CharacterParam|number[] If specified, only turn counters with this specific combat ID, target, or position will be cleared.
function TurnCounter.ClearTurnCounter(id, combatOrTarget)
	for uniqueId,data in pairs(_PV.TurnCounterData) do
		if data.ID == id then
			if combatOrTarget ~= nil then
				local t = type(combatOrTarget)
				if t == "number" then
					if data.Combat == combatOrTarget then
						_INTERNAL.CleanupData(uniqueId)
					end
				elseif t == "table" and GameHelpers.Math.PositionsEqual(data.Position, combatOrTarget) then
					_INTERNAL.CleanupData(uniqueId)
				else
					local GUID = GameHelpers.GetUUID(combatOrTarget)
					if GUID and GUID == data.Target then
						_INTERNAL.CleanupData(uniqueId)
					end
				end
			else
				_INTERNAL.CleanupData(uniqueId)
			end
		end
	end
end

---@param id string Identifier for this countdown.
---@param turns integer How many turns to count down for.
---@param combatOrTarget? TurnCounterTargetParamType The combat id or character to get the combat id from.
---@param params? TurnCounterData
function TurnCounter.CountDown(id, turns, combatOrTarget, params)
	TurnCounter.CreateTurnCounter(id, turns, 0,  TurnCounter.Mode.Decrement, combatOrTarget, params)
end

---@param id string Identifier for this countdown.
---@param turns integer How many turns to count up for.
---@param combatOrTarget? TurnCounterTargetParamType The combat id or character to get the combat id from.
---@param params? TurnCounterData
function TurnCounter.CountUp(id, turns, combatOrTarget, params)
	TurnCounter.CreateTurnCounter(id, 0, turns, TurnCounter.Mode.Increment, combatOrTarget, params)
end

---@param id? string|string[]
---@param callback fun(e:OnTurnCounterEventArgs|LeaderLibSubscribableEventArgs)
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
		Ext.Utils.PrintWarning("[TurnCounter.Subscribe] Registering a generic turn counter listener since id is nil. Consider using \"All\" instead.")
		Events.OnTurnCounter:Subscribe(callback)
	end
end

---@alias TurnCounterCallback fun(id:string, turn:integer, lastTurn:integer, finished:boolean, data:TurnCounterData)

---@diagnostic disable deprecated

---@deprecated
---@see LeaderLibTurnCounterSystem#Subscribe
---@param id? string|string[]
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
		Ext.Utils.PrintWarning("[TurnCounter.RegisterListener] Registering a generic turn counter listener since id is nil. Consider using \"All\" instead.")
		RegisterListener("OnTurnCounter", callback)
	end
end

---@diagnostic enable

---Check if a turn counter is active.
---@param id string|string[] The turn counter ID.
---@param target? ObjectParam|number[] Option target to check turn counters for.
---@return boolean
function TurnCounter.IsActive(id, target)
	if target then
		if type(target) == "table" then
			for uniqueId,data in pairs(_PV.TurnCounterData) do
				if GameHelpers.Math.PositionsEqual(data.Position, target) then
					return true
				end
			end
		else
			local GUID = GameHelpers.GetUUID(target)
			for uniqueId,data in pairs(_PV.TurnCounterData) do
				if data.Target == GUID then
					return true
				end
			end
		end
	else
		for uniqueId,data in pairs(_PV.TurnCounterData) do
			if data.ID == id then
				return true
			end
		end
	end
	return false
end

local function _SetEventMetadata(evt, data)
	setmetatable(evt, {
		__index = function (_,k)
			if k == "TargetObject" then
				return GameHelpers.TryGetObject(data.Target)
			end
		end
	})
	return evt
end

---@param data TurnCounterData
---@param uniqueId string
function _INTERNAL.Started(data, uniqueId)
	Events.OnTurnCounter:Invoke(_SetEventMetadata({
		ID = data.ID,
		Turn = data.Turns,
		LastTurn = data.Turns,
		Finished = false,
		Data = data,
	}, data))
end

---@param data TurnCounterData
---@param uniqueId string
---@param lastTurn integer
function _INTERNAL.CountdownDone(data, uniqueId, lastTurn)
	Events.OnTurnCounter:Invoke(_SetEventMetadata({
		ID = data.ID,
		Turn = data.Turns,
		LastTurn = data.Turns,
		Finished = true,
		Data = data,
	}, data))
	_INTERNAL.CleanupData(uniqueId)
end

---@param obj ObjectParam
---@param id string The id to use in the callback.
function TurnCounter.ListenForTurnEnding(obj, id)
	local GUID = GameHelpers.GetUUID(obj)
	if GUID then
		if _PV.WaitForTurnEnding[GUID] == nil then
			_PV.WaitForTurnEnding[GUID] = {}
		end
		_PV.WaitForTurnEnding[GUID][id] = true
	end
end

---@param obj ObjectParam
function _INTERNAL.InvokeTurnEndedListeners(obj)
	local GUID = GameHelpers.GetUUID(obj)
	local object = GameHelpers.TryGetObject(GUID)
	if GUID and object then
		local fired = false
		if _PV.WaitForTurnEnding[GUID] then
			for id,b in pairs(_PV.WaitForTurnEnding[GUID]) do
				if b then
					fired = true
					Events.OnTurnEnded:Invoke({
						ID = id,
						Object = object,
						ObjectGUID = object.MyGuid
					})
				end
			end
			_PV.WaitForTurnEnding[obj] = nil
		end
		if not fired then
			Events.OnTurnEnded:Invoke({
				ID = "",
				Object = object,
				ObjectGUID = object.MyGuid
			})
		end
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

	Events.OnTurnCounter:Invoke(_SetEventMetadata({
		ID = data.ID,	
		Turn = data.Turns,
		LastTurn = last,
		Finished = false,
		Data = data,
	}, data))
	return false
end

local justSkippedTurn = {}

function _INTERNAL.OnTurnEnded(uuid)
	if justSkippedTurn[uuid] then
		justSkippedTurn[uuid] = nil
		return false
	end
	_INTERNAL.InvokeTurnEndedListeners(uuid)
	local id = GameHelpers.Combat.GetID(uuid)
	if id then
		for uniqueId,data in pairs(_PV.TurnCounterData) do
			if not data.RoundOnly and data.Combat == id and (not data.Target or data.Target == uuid) then
				_INTERNAL.TickTurn(data, uniqueId)
			end
		end
	end
end

function _INTERNAL.OnTurnSkipped(uuid)
	local id = Osi.CombatGetIDForCharacter(uuid)
	if id then
		for uniqueId,data in pairs(_PV.TurnCounterData) do
			if data.Combat == id and data.CountSkipDisabled then
				justSkippedTurn[uuid] = true
			end
		end
	end
end

function TurnCounter.OnTimerFinished(uniqueId)
	local data = _PV.TurnCounterData[uniqueId]
	if data then
		if not _INTERNAL.TickTurn(data, uniqueId) then
			if not GameHelpers.IsActiveCombat(data.Combat) and not data.CombatOnly then
				Timer.Start(uniqueId, data.OutOfCombatSpeed or TurnCounter.DefaultTimerSpeed)
			end
		end
	end
end

---@param id integer
---@param uniqueId string
---@param data TurnCounterData
---@param characters EsvCharacter[]
local function SetCombatForEntry(id, uniqueId, data, characters)
	if data.Combat and data.Combat == id then
		Timer.Cancel(uniqueId)
	else
		local pos = nil
		if data.Position then
			pos = data.Position
		elseif data.Target then
			local id = GameHelpers.Combat.GetID(data.Target)
			if id == id then
				data.Combat = id
				Timer.Cancel(uniqueId)
				return true
			end
			pos = GameHelpers.Math.GetPosition(data.Target)
		end
		if pos and characters then
			for _,v in pairs(characters) do
				if GameHelpers.Math.GetDistance(pos, v.WorldPos) <= TurnCounter.CombatMinDistance then
					data.Combat = id
					Timer.Cancel(uniqueId)
					return true
				end
			end
		end
	end
end

function _INTERNAL.OnCombatStarted(id)
	local characters = GameHelpers.GetCombatCharacters(id)
	for uniqueId,data in pairs(_PV.TurnCounterData) do
		SetCombatForEntry(id, uniqueId, data, characters)
	end
end

function _INTERNAL.OnCombatEnded(id)
	for uniqueId,data in pairs(_PV.TurnCounterData) do
		if data.Combat == id then
			data.Combat = nil
			if not data.CombatOnly then
				Timer.Start(uniqueId, data.OutOfCombatSpeed or TurnCounter.DefaultTimerSpeed)
			end
		end
	end
end

function _INTERNAL.OnLeftCombat(uuid, id)
	_INTERNAL.InvokeTurnEndedListeners(uuid)
end

function _INTERNAL.OnCharacterDied(uuid)
	for uniqueId,data in pairs(_PV.TurnCounterData) do
		if data.Target == uuid and data.ClearOnDeath then
			_INTERNAL.CleanupData(uniqueId)
		end
	end
end

local _GetUUID = StringHelpers.GetUUID

RegisterProtectedOsirisListener("CombatStarted", 1, "after", _INTERNAL.OnCombatStarted)
RegisterProtectedOsirisListener("CombatEnded", 1, "after", _INTERNAL.OnCombatEnded)
RegisterProtectedOsirisListener("ObjectTurnEnded", 1, "after", function(uuid) _INTERNAL.OnTurnEnded(_GetUUID(uuid)) end)
RegisterProtectedOsirisListener("CharacterGuarded", 1, "before", function(uuid) _INTERNAL.OnTurnSkipped(_GetUUID(uuid)) end)
RegisterProtectedOsirisListener("ObjectLeftCombat", 2, "after", function(uuid, id) _INTERNAL.OnLeftCombat(_GetUUID(uuid), id) end)
RegisterProtectedOsirisListener("CharacterDied", 1, "after", function(uuid) _INTERNAL.OnCharacterDied(_GetUUID(uuid)) end)

Events.Osiris.CombatRoundStarted:Subscribe(function (e)
	for uniqueId,data in pairs(_PV.TurnCounterData) do
		if data.RoundOnly and data.Combat == e.CombatID then
			_INTERNAL.TickTurn(data, uniqueId)
		end
	end
end)

---@param uniqueId string
---@param data TurnCounterData
---@param region string
local function CheckDataForDeletion(uniqueId, data, region)
	local t = type(data.Target)
	if t == "string" then
		if Osi.ObjectExists(data.Target) ~= 1 then
			_INTERNAL.CleanupData(uniqueId)
			return true
		elseif Osi.ObjectIsGlobal(data.Target) == 1 then
			data.Region = region
		end
	end
	if data.Position then
		if data.Region ~= region then
			_INTERNAL.CleanupData(uniqueId)
			return true
		end
	end
	if not data.Target and not data.Position then
		_INTERNAL.CleanupData(uniqueId)
		return true
	end
end

Events.Initialized:Subscribe(function (e)
	local region = e.Region
	--Cleanup turn counters that shouldn't exist
	for uniqueId,data in pairs(_PV.TurnCounterData) do
		CheckDataForDeletion(uniqueId, data, region)
	end
end)