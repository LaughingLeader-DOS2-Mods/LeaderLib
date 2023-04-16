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

local function _AnyObjectDoesNotExist(...)
	local params = {...}
	local len = #params
	for i=1,len do
		if Osi.ObjectExists(params[i]) == 0 then
			return true
		end
	end
	return false
end

---@class OsirisCharacterEventArgs
---@field Character EsvCharacter
---@field CharacterGUID Guid The character MyGuid, for easier matching.

---@class OsirisCharacterItemEventArgs
---@field Character EsvCharacter
---@field CharacterGUID Guid The character MyGuid, for easier matching.
---@field Item EsvItem
---@field ItemGUID Guid The Item MyGuid, for easier matching.
---@field StatsId string The item StatsId

---@class OsirisProcBlockEventArgs:OsirisCharacterItemEventArgs
---@field PreventAction fun(e:OsirisProcBlockEventArgs)

---@param name string
---@param getArgs fun(...:OsirisValue):table|boolean
local function _CreateOsirisEventWrapper(name, getArgs)
	local arity = Data.OsirisEvents[name]
	local registeredListener = false
	local event = Classes.SubscribableEvent:Create("Osiris." .. name, {OnSubscribe = function (_)
		if not registeredListener then
			registeredListener = true
			Ext.Osiris.RegisterListener(name, arity, "after", function (...)
				local b,data = xpcall(getArgs, debug.traceback, ...)
				if data == false then -- object doesn't exist etc
					return
				end
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

---@param name string
---@param getArgs fun(...:OsirisValue):table|boolean
local function _CreateOsirisProcWrapper(name, arity, getArgs)
	local registeredListener = false
	local event = Classes.SubscribableEvent:Create("Osiris." .. name, {OnSubscribe = function (_)
		if not registeredListener then
			registeredListener = true
			Ext.Osiris.RegisterListener(name, arity, "after", function (...)
				local b,data = xpcall(getArgs, debug.traceback, ...)
				if data == false then return end
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

---@param name string
---@param getArgs fun(...:OsirisValue):table
---@param blockAction fun(e:OsirisCharacterItemEventArgs)
local function _CreateOsirisProcBlockWrapper(name, getArgs, blockAction)
	local registeredListener = false
	local event = Classes.SubscribableEvent:Create("Osiris." .. name, {OnSubscribe = function (_)
		if not registeredListener then
			registeredListener = true
			Ext.Osiris.RegisterListener(name, 2, "before", function (...)
				local b,data = xpcall(getArgs, debug.traceback, ...)
				if data == false then return end
				if not b then
					fprint(LOGLEVEL.ERROR, "[Events.Osiris.%s] Failed to get args:\n%s", name, data)
					return
				end
				data.PreventAction = function ()
					blockAction(data)
				end
				Events.Osiris[name]:Invoke(data)
			end)
		end
	end})
	return event
end

---@type LeaderLibSubscribableEvent<{Object:EsvCharacter|EsvItem, ObjectGUID:Guid, TemplateGUID:Guid, Template:CharacterTemplate|ItemTemplate}>
Events.Osiris.ObjectTransformed = _CreateOsirisEventWrapper("ObjectTransformed", function (guid, template)
	return {
		Object = GameHelpers.TryGetObject(guid),
		ObjectGUID = _GetGUID(guid),
		TemplateGUID = _GetGUID(template),
		Template = Ext.Template.GetTemplate(template),
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

--#region Single Character param events

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterStoppedPolymorph = _CreateOsirisEventWrapper("CharacterStoppedPolymorph", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterJoinedParty = _CreateOsirisEventWrapper("CharacterJoinedParty", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterLeftParty = _CreateOsirisEventWrapper("CharacterLeftParty", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.FleeCombat = _CreateOsirisEventWrapper("FleeCombat", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterUsedLadder = _CreateOsirisEventWrapper("CharacterUsedLadder", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterMadePlayer = _CreateOsirisEventWrapper("CharacterMadePlayer", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterAddedToGroup = _CreateOsirisEventWrapper("CharacterAddedToGroup", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterDetachedFromGroup = _CreateOsirisEventWrapper("CharacterDetachedFromGroup", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterUsedSourcePoint = _CreateOsirisEventWrapper("CharacterUsedSourcePoint", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterLoadedInPreset = _CreateOsirisEventWrapper("CharacterLoadedInPreset", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterRequestsHomestead = _CreateOsirisEventWrapper("CharacterRequestsHomestead", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterPickpocketExit = _CreateOsirisEventWrapper("CharacterPickpocketExit", _SingleGuidEvent)

---@type LeaderLibSubscribableEvent<OsirisCharacterEventArgs>
Events.Osiris.CharacterCreationFinished = _CreateOsirisEventWrapper("CharacterCreationFinished", _SingleGuidEvent)

--#endregion

---@class OsirisCharacterLootedCharacterCorpseEventArgs
---@field Player EsvCharacter
---@field PlayerGUID Guid
---@field Corpse EsvCharacter
---@field CorpseGUID Guid
---@field Inventory EsvInventory The corpse's inventory.

---@type LeaderLibSubscribableEvent<OsirisCharacterLootedCharacterCorpseEventArgs>
Events.Osiris.CharacterLootedCharacterCorpse = _CreateOsirisEventWrapper("CharacterLootedCharacterCorpse", function (playerGUID, corpseGUID)
	local corpse = GameHelpers.GetCharacter(corpseGUID, "EsvCharacter")
	return {
		Player = GameHelpers.GetCharacter(playerGUID),
		PlayerGUID = _GetGUID(playerGUID),
		Corpse = corpse,
		CorpseGUID = _GetGUID(corpseGUID),
		Inventory = corpse and Ext.Entity.GetInventory(corpse.InventoryHandle)
	}
end)

---@class OsirisItemTemplateOpeningEventArgs
---@field Character EsvCharacter
---@field CharacterGUID Guid
---@field Item EsvItem
---@field ItemGUID Guid
---@field Inventory EsvInventory|nil The item's inventory, if it's a container.
---@field TemplateGUID Guid
---@field Template ItemTemplate

---@type LeaderLibSubscribableEvent<OsirisItemTemplateOpeningEventArgs>
Events.Osiris.ItemTemplateOpening = _CreateOsirisEventWrapper("ItemTemplateOpening", function (templateGUID, itemGUID, charGUID)
	local item = GameHelpers.GetItem(itemGUID)
	return {
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Item = item,
		ItemGUID = _GetGUID(itemGUID),
		Template = Ext.Template.GetTemplate(templateGUID),
		TemplateGUID = _GetGUID(templateGUID),
		Inventory = item and Ext.Entity.GetInventory(item.InventoryHandle)
	}
end)

---@type LeaderLibSubscribableEvent<{LevelName:string, Level:EsvLevel}>
Events.Osiris.CharacterCreationStarted = _CreateOsirisEventWrapper("CharacterCreationStarted", function(level) return {LevelName=level, Level=Ext.Entity.GetCurrentLevel()} end)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Percentage:integer}>
Events.Osiris.CharacterVitalityChanged = _CreateOsirisEventWrapper("CharacterVitalityChanged", function (guid, percentage)
	return {
		Character = GameHelpers.GetCharacter(guid),
		CharacterGUID = _GetGUID(guid),
		Percentage = percentage
	}
end)

--#region Combat

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

--#endregion

---@see Events.CharacterUsedItem
---@type LeaderLibSubscribableEvent<OsirisCharacterItemEventArgs>
Events.Osiris.CharacterUsedItem = _CreateOsirisEventWrapper("CharacterUsedItem", function (charGUID, itemGUID)
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
	local item = GameHelpers.GetItem(itemGUID)
	return {
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Item = item,
		ItemGUID = _GetGUID(itemGUID),
		StatsId = GameHelpers.Item.GetItemStat(item),
	}
end)

---@see Events.CharacterUsedItem
---@type LeaderLibSubscribableEvent<OsirisCharacterItemEventArgs>
Events.Osiris.CharacterUsedItemFailed = _CreateOsirisEventWrapper("CharacterUsedItemFailed", function (charGUID, itemGUID)
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
	local item = GameHelpers.GetItem(itemGUID)
	return {
		StatsId = GameHelpers.Item.GetItemStat(item),
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Item = item,
		ItemGUID = _GetGUID(itemGUID),
	}
end)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Item:EsvItem, ItemGUID:Guid, Template:ItemTemplate, TemplateGUID:Guid}>
Events.Osiris.CharacterUsedItemTemplate = _CreateOsirisEventWrapper("CharacterUsedItemTemplate", function (charGUID, templateGUID, itemGUID)
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
	local item = GameHelpers.GetItem(itemGUID)
	return {
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Item = item,
		ItemGUID = _GetGUID(itemGUID),
		Template = Ext.Template.GetTemplate(templateGUID),
		TemplateGUID = _GetGUID(templateGUID),
		StatsId = GameHelpers.Item.GetItemStat(item),
	}
end)

--#region Item Requests (_CRIME_CrimeTriggers)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Item:EsvItem, ItemGUID:Guid, RequestID:integer}>
Events.Osiris.CanUseItem = _CreateOsirisEventWrapper("CanUseItem", function (charGUID, itemGUID, requestID)
	return {
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Item = GameHelpers.GetItem(itemGUID),
		ItemGUID = _GetGUID(itemGUID),
		RequestID = requestID,
	}
end)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Item:EsvItem, ItemGUID:Guid, RequestID:integer}>
Events.Osiris.CanLockpickItem = _CreateOsirisEventWrapper("CanLockpickItem", function (charGUID, itemGUID, requestID)
	return {
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Item = GameHelpers.GetItem(itemGUID),
		ItemGUID = _GetGUID(itemGUID),
		RequestID = requestID,
	}
end)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Item:EsvItem, ItemGUID:Guid, RequestID:integer}>
Events.Osiris.CanMoveItem = _CreateOsirisEventWrapper("CanMoveItem", function (charGUID, itemGUID, requestID)
	return {
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Item = GameHelpers.GetItem(itemGUID),
		ItemGUID = _GetGUID(itemGUID),
		RequestID = requestID,
	}
end)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Item:EsvItem, ItemGUID:Guid, RequestID:integer}>
Events.Osiris.CanPickupItem = _CreateOsirisEventWrapper("CanPickupItem", function (charGUID, itemGUID, requestID)
	return {
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Item = GameHelpers.GetItem(itemGUID),
		ItemGUID = _GetGUID(itemGUID),
		RequestID = requestID,
	}
end)

---@type LeaderLibSubscribableEvent<OsirisProcBlockEventArgs>
Events.Osiris.ProcBlockUseOfItem = _CreateOsirisProcBlockWrapper("ProcBlockUseOfItem", function (charGUID, itemGUID)
	local item = GameHelpers.GetItem(itemGUID)
	return {
		StatsId = GameHelpers.Item.GetItemStat(item),
		Item = item,
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		ItemGUID = _GetGUID(itemGUID)
	}
end, function (e)
	Osi.DB_CustomUseItemResponse(e.CharacterGUID, e.ItemGUID, 0)
end)

---@type LeaderLibSubscribableEvent<OsirisProcBlockEventArgs>
Events.Osiris.ProcBlockMoveOfItem = _CreateOsirisProcBlockWrapper("ProcBlockMoveOfItem", function (charGUID, itemGUID)
	local item = GameHelpers.GetItem(itemGUID)
	return {
		StatsId = GameHelpers.Item.GetItemStat(item),
		Item = item,
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		ItemGUID = _GetGUID(itemGUID)
	}
end, function (e)
	Osi.DB_CustomMoveItemResponse(e.CharacterGUID, e.ItemGUID, 0)
end)

---@type LeaderLibSubscribableEvent<OsirisProcBlockEventArgs>
Events.Osiris.ProcBlockPickupOfItem = _CreateOsirisProcBlockWrapper("ProcBlockPickupOfItem", function (charGUID, itemGUID)
	local item = GameHelpers.GetItem(itemGUID)
	return {
		StatsId = GameHelpers.Item.GetItemStat(item),
		Item = item,
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		ItemGUID = _GetGUID(itemGUID)
	}
end, function (e)
	Osi.DB_CustomPickupItemResponse(e.CharacterGUID, e.ItemGUID, 0)
end)

---@type LeaderLibSubscribableEvent<OsirisProcBlockEventArgs>
Events.Osiris.ProcBlockLockpickItem = _CreateOsirisProcBlockWrapper("ProcBlockLockpickItem", function (charGUID, itemGUID)
	local item = GameHelpers.GetItem(itemGUID)
	return {
		StatsId = GameHelpers.Item.GetItemStat(item),
		Item = item,
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		ItemGUID = _GetGUID(itemGUID)
	}
end, function (e)
	Osi.DB_CustomLockpickItemResponse(e.CharacterGUID, e.ItemGUID, 0)
end)

--#endregion

--#region Dialog

---@class OsirisDialogBaseEventArgs
---@field Dialog string
---@field InstanceID integer
---@field Category string
---@field TotalPlayers integer
---@field TotalNPCs integer
---@field Players EsvCharacter[] All of the player speakers in this dialog, if any.
---@field NPCs ServerObject[] All of the NPC speakers in this dialog, if any.
---@field Player EsvCharacter|nil The first player speaker, if any.
---@field NPC EsvCharacter|EsvItem|nil The first NPC speaker, if any.
---@field SetVariable OsirisDialogBaseEventArgsVariableFunctions
---@field SetInstanceVariable OsirisDialogBaseEventArgsVariableFunctions

---@class OsirisDialogBaseEventArgsVariableFunctions
---@field String fun(id:string, value:string)
---@field FixedString fun(id:string, value:FixedString)
---@field TranslatedString fun(id:string, handle:string, fallback:string)
---@field Int fun(id:string, value:integer)
---@field Float fun(id:string, value:number)

local function _SetupDialogEventData(dialog, instanceID)
	local data = { Dialog = dialog, InstanceID = instanceID}
	---@cast data OsirisDialogBaseEventArgs

	data.Category = Osi.DialogGetCategory(data.InstanceID) or ""

	data.SetVariable = {
		String = function(id, value) Osi.DialogSetVariableString(dialog, id, value) end,
		FixedString = function(id, value) Osi.DialogSetVariableFixedString(dialog, id, value) end,
		TranslatedString = function(id, handle, ref) Osi.DialogSetVariableTranslatedString(dialog, id, handle, ref) end,
		Int = function(id, value) Osi.DialogSetVariableInt(dialog, id, value) end,
		Float = function(id, value) Osi.DialogSetVariableFloat(dialog, id, value) end,
	}

	data.SetInstanceVariable = {
		String = function(id, value) Osi.DialogSetVariableStringForInstance(instanceID, id, value) end,
		FixedString = function(id, value) Osi.DialogSetVariableFixedStringForInstance(instanceID, id, value) end,
		TranslatedString = function(id, handle, ref) Osi.DialogSetVariableTranslatedStringForInstance(instanceID, id, handle, ref) end,
		Int = function(id, value) Osi.DialogSetVariableIntForInstance(instanceID, id, value) end,
		Float = function(id, value) Osi.DialogSetVariableFloatForInstance(instanceID, id, value) end,
	}

	data.Players = {}
	data.NPCs = {}

	local numPlayers = Osi.DialogGetNumberOfInvolvedPlayers(instanceID) or 0
	local numNPCs = Osi.DialogGetNumberOfInvolvedNPCs(instanceID) or 0

	data.TotalPlayers = numPlayers
	data.TotalNPCs = numNPCs

	if numPlayers > 0 then
		for i=1,numPlayers do
			local guid = Osi.DialogGetInvolvedPlayer(instanceID, i)
			if not StringHelpers.IsNullOrEmpty(guid) then
				local character = GameHelpers.GetCharacter(guid)
				data.Players[i] = character
			end
		end
		data.Player = data.Players[1]
	end

	if numNPCs > 0 then
		for i=1,numNPCs do
			local guid = Osi.DialogGetInvolvedNPC(instanceID, i)
			if not StringHelpers.IsNullOrEmpty(guid) then
				local object = GameHelpers.TryGetObject(guid)
				data.NPCs[i] = object
			end
		end
		data.NPC = data.NPCs[1]
	end

	return data
end

---@param name string
---@param setAdditionalArgs? fun(data:OsirisDialogBaseEventArgs, ...:OsirisValue)
---@return LeaderLibSubscribableEvent<OsirisDialogBaseEventArgs>
local function _CreateOsirisDialogEventWrapper(name, setAdditionalArgs)
	local arity = Data.OsirisEvents[name]
	local registeredListener = false
	local event = Classes.SubscribableEvent:Create("Osiris." .. name, {OnSubscribe = function (_)
		if not registeredListener then
			registeredListener = true
			Ext.Osiris.RegisterListener(name, arity, "after", function (...)
				local b,data = xpcall(_SetupDialogEventData, debug.traceback, ...) --[[@as OsirisDialogBaseEventArgs]]
				if not b then
					fprint(LOGLEVEL.ERROR, "[Events.Osiris.%s] Failed to get args:\n%s", name, data)
					return
				end

				if setAdditionalArgs then
					pcall(setAdditionalArgs, data, ...)
				end
				
				Events.Osiris[name]:Invoke(data)
			end)
		end
	end})
	return event
end

Events.Osiris.AutomatedDialogStarted = _CreateOsirisDialogEventWrapper("AutomatedDialogStarted")
Events.Osiris.AutomatedDialogEnded = _CreateOsirisDialogEventWrapper("AutomatedDialogEnded")
Events.Osiris.AutomatedDialogRequestFailed = _CreateOsirisDialogEventWrapper("AutomatedDialogRequestFailed")
Events.Osiris.DialogStarted = _CreateOsirisDialogEventWrapper("DialogStarted")
Events.Osiris.DialogEnded = _CreateOsirisDialogEventWrapper("DialogEnded")
Events.Osiris.DialogRequestFailed = _CreateOsirisDialogEventWrapper("DialogRequestFailed")
Events.Osiris.DualDialogStart = _CreateOsirisDialogEventWrapper("DualDialogStart")

---@class OsirisChildDialogRequestedEventArgs:OsirisDialogBaseEventArgs
---@field TargetInstanceID integer
---@field TargetDialog OsirisDialogBaseEventArgs

local function _SetTargetDialog(data, dialog, instanceID, targetInstanceID)
	---@cast data OsirisChildDialogRequestedEventArgs
	data.TargetInstanceID = targetInstanceID
	local db = Osi.DB_DialogName:Get(nil,targetInstanceID)
	if db then
		local targetDialogName = db[1]
		local b,targetDialogData = xpcall(_SetupDialogEventData, targetDialogName, targetInstanceID) --[[@as OsirisDialogBaseEventArgs]]
		if not b then
			fprint(LOGLEVEL.ERROR, "[Events.Osiris.ChildDialogRequested] Failed to get target dialog:\n%s", data)
		else
			data.TargetDialog = targetDialogData
		end
	end
end

---@type LeaderLibSubscribableEvent<OsirisChildDialogRequestedEventArgs>
Events.Osiris.ChildDialogRequested = _CreateOsirisDialogEventWrapper("ChildDialogRequested", _SetTargetDialog)
---@type LeaderLibSubscribableEvent<OsirisChildDialogRequestedEventArgs>
Events.Osiris.DualDialogRequested = _CreateOsirisDialogEventWrapper("DualDialogRequested", _SetTargetDialog)

--#endregion