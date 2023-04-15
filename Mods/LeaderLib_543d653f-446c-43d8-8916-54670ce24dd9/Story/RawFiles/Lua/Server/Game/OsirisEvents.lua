if Events.Osiris == nil then
	Events.Osiris = {}
end

local _GetGUID = StringHelpers.GetUUID
local function _SingleGuidEvent(guid)
	return {
		Character = GameHelpers.GetCharacter(guid),
		CharacterGUID = _GetGUID(guid)
	}
end

---@class OsirisCharacterEventArgs
---@field Character EsvCharacter|
---@field CharacterGUID Guid The character MyGuid, for easier matching.

---@param name string
---@param getArgs fun(...:OsirisValue):table
local function _CreateOsirisEventWrapper(name, getArgs)
	local arity = Data.OsirisEvents[name]
	local registeredListener = false
	local event = Classes.SubscribableEvent:Create("Osiris." .. name, {OnSubscribe = function (_)
		if not registeredListener then
			registeredListener = true
			Ext.Osiris.RegisterListener(name, arity, "after", function (...)
				local b,data = xpcall(getArgs, debug.traceback, ...)
				if not b then
					fprint(LOGLEVEL.ERROR, "[Events.Osiris.%s] Failed to get args:\n%s", name, data)
					return
				end
				Events.Osiris[name]:Invoke(data)
			end)
		end
	end})
	return event
end

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Template:Guid}>
Events.Osiris.ObjectTransformed = _CreateOsirisEventWrapper("ObjectTransformed", function (guid, template)
	return {
		Character = GameHelpers.GetCharacter(guid),
		CharacterGUID = _GetGUID(guid),
		Template = _GetGUID(template)
	}
end)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Race:string}>
Events.Osiris.CharacterPolymorphedInto = _CreateOsirisEventWrapper("CharacterPolymorphedInto", function (guid, race)
	return {
		Character = GameHelpers.GetCharacter(guid),
		CharacterGUID = _GetGUID(guid),
		Race = race
	}
end)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterStoppedPolymorph = _CreateOsirisEventWrapper("CharacterStoppedPolymorph", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterJoinedParty = _CreateOsirisEventWrapper("CharacterJoinedParty", _SingleGuidEvent)
Events.Osiris.CharacterLeftParty = _CreateOsirisEventWrapper("CharacterLeftParty", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Percentage:integer}>
Events.Osiris.CharacterVitalityChanged = _CreateOsirisEventWrapper("CharacterVitalityChanged", function (guid, percentage)
	return {
		Character = GameHelpers.GetCharacter(guid),
		CharacterGUID = _GetGUID(guid),
		Percentage = percentage
	}
end)

---@type LeaderLibSubscribableEvent<{CombatID:integer}>
Events.Osiris.CombatStarted = _CreateOsirisEventWrapper("CombatStarted", function (combatID) return {CombatID = combatID} end)
---@type LeaderLibSubscribableEvent<{CombatID:integer}>
Events.Osiris.CombatEnded = _CreateOsirisEventWrapper("CombatEnded", function (combatID) return {CombatID = combatID} end)
---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, CombatID:integer, Round:integer}>
Events.Osiris.CombatRoundStarted = _CreateOsirisEventWrapper("CombatRoundStarted", function (combatID, round)
	return {
		CombatID = combatID,
		Round = round
	}
end)


---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, CombatID:integer}>
Events.Osiris.ObjectEnteredCombat = _CreateOsirisEventWrapper("ObjectEnteredCombat", function (guid, combatID)
	return {
		Character = GameHelpers.GetCharacter(guid),
		CharacterGUID = _GetGUID(guid),
		CombatID = combatID
	}
end)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, CombatID:integer}>
Events.Osiris.ObjectLeftCombat = _CreateOsirisEventWrapper("ObjectLeftCombat", function (guid, combatID)
	return {
		Character = GameHelpers.GetCharacter(guid),
		CharacterGUID = _GetGUID(guid),
		CombatID = combatID
	}
end)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, CombatID:integer}>
Events.Osiris.ObjectReadyInCombat = _CreateOsirisEventWrapper("ObjectReadyInCombat", function (guid, combatID)
	return {
		Character = GameHelpers.GetCharacter(guid),
		CharacterGUID = _GetGUID(guid),
		CombatID = combatID
	}
end)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, OldcombatID:integer, CombatID:integer}>
Events.Osiris.ObjectSwitchedCombat = _CreateOsirisEventWrapper("ObjectSwitchedCombat", function (guid, oldcombatID, combatID)
	return {
		Character = GameHelpers.GetCharacter(guid),
		CharacterGUID = _GetGUID(guid),
		OldcombatID = oldcombatID,
		CombatID = combatID,
	}
end)