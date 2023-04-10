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
	Ext.Osiris.RegisterListener(name, arity, "after", function (...)
		local b,data = xpcall(getArgs, debug.traceback, ...)
		if not b then
			fprint(LOGLEVEL.ERROR, "[Events.Osiris.%s] Failed to get args:\n%s", name, data)
			return
		end
		Events.Osiris[name]:Invoke(data)
	end)
	return Classes.SubscribableEvent:Create("Osiris." .. name)
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