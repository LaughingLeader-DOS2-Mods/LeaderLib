if Events.Osiris == nil then
	Events.Osiris = {}
end

local _ObjectExists = GameHelpers.ObjectExists
local _GetGUID = StringHelpers.GetUUID
local function _SingleGuidEvent(guid)
	local data = {}
	if StringHelpers.IsNullOrEmpty(guid) then
		data.CharacterGUID = StringHelpers.NULL_UUID
		return data
	elseif Osi.ObjectExists(guid) then
		data.Character = GameHelpers.GetCharacter(guid)
	end
	data.CharacterGUID = _GetGUID(guid)
	return data
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

---@class OsirisItemEventArgs
---@field Item EsvItem
---@field ItemGUID Guid The Item MyGuid, for easier matching.
---@field StatsId string The item StatsId

---@class OsirisCharacterItemEventArgs
---@field Character EsvCharacter
---@field CharacterGUID Guid The character MyGuid, for easier matching.
---@field Item EsvItem
---@field ItemGUID Guid The Item MyGuid, for easier matching.
---@field StatsId string The item StatsId

---@class OsirisProcBlockEventArgs:OsirisCharacterItemEventArgs
---@field PreventAction fun(e:OsirisProcBlockEventArgs)

---@class OsirisCharacterTriggerEventArgs
---@field Character EsvCharacter
---@field CharacterGUID Guid
---@field Trigger Trigger
---@field TriggerGUID Guid

---@param name string
---@param getArgs fun(...:OsirisValue):table|boolean
---@param eventStage? OsirisEventType
local function _CreateOsirisEventWrapper(name, getArgs, eventStage)
	local arity = Data.OsirisEvents[name]
	local registeredListener = false
	local event = Classes.SubscribableEvent:Create("Osiris." .. name, {OnSubscribe = function (_)
		if not registeredListener then
			registeredListener = true
			Ext.Osiris.RegisterListener(name, arity, eventStage or "after", function (...)
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

---@param name string
---@param getArgs? fun(...:OsirisValue):table
---@param eventStage? OsirisEventType
local function _CreateCharacterItemEventWrapper(name, getArgs, eventStage)
	local event = _CreateOsirisEventWrapper(name, function (charGUID, itemGUID)
		if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
		local item = GameHelpers.GetItem(itemGUID)
		local data = {
			Character = GameHelpers.GetCharacter(charGUID),
			CharacterGUID = _GetGUID(charGUID),
			Item = item,
			ItemGUID = _GetGUID(itemGUID),
			StatsId = GameHelpers.Item.GetItemStat(item),
		}
		if getArgs then
			local tblExtras = getArgs(charGUID, itemGUID)
			if tblExtras then
				TableHelpers.AddOrUpdate(data, tblExtras)
			end
		end
		return data
	end, eventStage)
	return event
end

---@param name string
---@param getArgs? fun(...:OsirisValue):table
---@param eventStage? OsirisEventType
local function _CreateItemCharacterEventWrapper(name, getArgs, eventStage)
	local event = _CreateOsirisEventWrapper(name, function (itemGUID, charGUID)
		if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
		local item = GameHelpers.GetItem(itemGUID)
		local data = {
			Character = GameHelpers.GetCharacter(charGUID),
			CharacterGUID = _GetGUID(charGUID),
			Item = item,
			ItemGUID = _GetGUID(itemGUID),
			StatsId = GameHelpers.Item.GetItemStat(item),
		}
		if getArgs then
			local tblExtras = getArgs(charGUID, itemGUID)
			if tblExtras then
				TableHelpers.AddOrUpdate(data, tblExtras)
			end
		end
		return data
	end, eventStage)
	return event
end

---@param name string
---@param getArgs? fun(...:OsirisValue):table
---@param eventStage? OsirisEventType
---@return LeaderLibSubscribableEvent<OsirisItemEventArgs>
local function _CreateItemEventWrapper(name, getArgs, eventStage)
	local event = _CreateOsirisEventWrapper(name, function (itemGUID, ...)
		if _AnyObjectDoesNotExist(itemGUID) then return false end
		local item = GameHelpers.GetItem(itemGUID)
		local data = {
			Item = item,
			ItemGUID = _GetGUID(itemGUID),
			StatsId = GameHelpers.Item.GetItemStat(item),
		}
		if getArgs then
			local tblExtras = getArgs(itemGUID, ...)
			if tblExtras then
				TableHelpers.AddOrUpdate(data, tblExtras)
			end
		end
		return data
	end, eventStage)
	return event
end

---@type LeaderLibSubscribableEvent<{Object:EsvCharacter|EsvItem, ObjectGUID:Guid, ObjectType:"Character"|"Item", TemplateGUID:Guid, Template:CharacterTemplate|ItemTemplate}>
Events.Osiris.ObjectTransformed = _CreateOsirisEventWrapper("ObjectTransformed", function (guid, template)
	if not _ObjectExists(guid) then return false end
	return {
		Object = GameHelpers.TryGetObject(guid),
		ObjectGUID = _GetGUID(guid),
		ObjectType = Osi.ObjectIsCharacter(guid) == 1 and "Character" or "Item",
		TemplateGUID = _GetGUID(template),
		Template = Ext.Template.GetTemplate(template),
	}
end)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Race:string}>
Events.Osiris.CharacterPolymorphedInto = _CreateOsirisEventWrapper("CharacterPolymorphedInto", function (guid, race)
	if not _ObjectExists(guid) then return false end
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

---@class OsirisProcHandleMagicMirrorResultEventArgs
---@field Character EsvCharacter
---@field CharacterGUID Guid
---@field Success boolean Whether the player was added to the respec mirror.

---Called when a character is added to a respec mirror (or attempts it).
---@type LeaderLibSubscribableEvent<OsirisProcHandleMagicMirrorResultEventArgs>
Events.Osiris.ProcHandleMagicMirrorResult = _CreateOsirisEventWrapper("PROC_HandleMagicMirrorResult", function (playerGUID, result)
	local data = {}
	data.CharacterGUID = _GetGUID(playerGUID)
	data.Character = GameHelpers.GetCharacter(playerGUID)
	data.Success = result ~= 0
	return data
end)

---@class OsirisProcHomesteadTeleportAfterMirrorEventArgs
---@field Character EsvCharacter
---@field CharacterGUID Guid
---@field Mirror EsvItem
---@field MirrorGUID Guid
---@field Trigger EsvEocPointTrigger
---@field TriggerGUID Guid

---Called when a character is teleported after leaving the respec mirror.
---@type LeaderLibSubscribableEvent<OsirisProcHomesteadTeleportAfterMirrorEventArgs>
Events.Osiris.ProcHomesteadTeleportAfterMirror = _CreateOsirisEventWrapper("Proc_HomesteadTeleportAfterMirror", function (playerGUID, mirrorGUID, triggerGUID)
	local data = {}
	data.MirrorGUID = _GetGUID(mirrorGUID)
	data.CharacterGUID = _GetGUID(playerGUID)
	data.TriggerGUID = _GetGUID(triggerGUID)
	data.Character = GameHelpers.GetCharacter(playerGUID)
	data.Mirror = GameHelpers.GetItem(mirrorGUID)
	data.Trigger = Ext.Entity.GetTrigger(triggerGUID)
	return data
end)

--#endregion

---@class OsirisCharacterLootedCharacterCorpseEventArgs
---@field Player EsvCharacter
---@field PlayerGUID Guid
---@field Corpse EsvCharacter
---@field CorpseGUID Guid
---@field Inventory EsvInventory The corpse's inventory.

---@type LeaderLibSubscribableEvent<OsirisCharacterLootedCharacterCorpseEventArgs>
Events.Osiris.CharacterLootedCharacterCorpse = _CreateOsirisEventWrapper("CharacterLootedCharacterCorpse", function (playerGUID, corpseGUID)
	if _AnyObjectDoesNotExist(playerGUID, corpseGUID) then return false end
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
	if _AnyObjectDoesNotExist(itemGUID, charGUID) then return false end
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
	if not _ObjectExists(guid) then return false end
	return {
		Character = GameHelpers.GetCharacter(guid),
		CharacterGUID = _GetGUID(guid),
		Percentage = percentage
	}
end)

--#region Combat

---@class OsirisCombatObjectEventArgs
---@field Object EsvCharacter|EsvItem
---@field ObjectGUID Guid
---@field ObjectType "Character"|"Item"
---@field CombatID integer
---@field Combat EsvCombat
---@field CombatTeam EsvCombatTeam
---@field CombatComponent EsvCombatComponent

local function _CombatMetaIndex(tbl, k)
	local combatid = rawget(tbl, "CombatID")
	--These are properties that we can skip actually setting until a callback tries to access it
	if k == "Combat" then
		local combat = Ext.Entity.GetCombat(combatid)
		if combat then
			rawset(tbl, "Combat", combat)
			return combat
		end
	elseif k == "CombatTeam" then
		local combat = Ext.Entity.GetCombat(combatid)
		if combat then
			rawset(tbl, "Combat", combat)
			local object = rawget(tbl, "Object")
			for _,v in pairs(combat:GetAllTeams()) do
				if v.Character == object or v.Item == object then
					rawset(tbl, "CombatTeam", v)
					return v
				end
			end
		end
	elseif k == "CombatComponent" then
		local object = rawget(tbl, "Object")
		local component = GameHelpers.Combat.GetCombatComponent(object)
		if component then
			rawset(tbl, "CombatComponent", component)
			return component
		end
	end
end

local function _SingleObjectCombatEvent(guid, id)
	if Osi.ObjectExists(guid) == 0 then
		return false
	end
	local object = GameHelpers.TryGetObject(guid, "EsvCharacter")
	local combatid = id or GameHelpers.Combat.GetID(object)
	local evt = {
		Object = object,
		ObjectGUID = _GetGUID(guid),
		CombatID = combatid,
		ObjectType = GameHelpers.Ext.ObjectIsCharacter(object) and "Character" or "Item"
	}
	setmetatable(evt, {__index = _CombatMetaIndex})
	return evt
end

---@param name string
---@return LeaderLibSubscribableEvent<OsirisCombatObjectEventArgs>
local function _CreateOsirisCombatEventWrapper(name)
	return _CreateOsirisEventWrapper(name, _SingleObjectCombatEvent)
end

Events.Osiris.ObjectTurnStarted = _CreateOsirisCombatEventWrapper("ObjectTurnStarted")
---@see Events.OnTurnEnded
Events.Osiris.ObjectTurnEnded = _CreateOsirisCombatEventWrapper("ObjectTurnEnded")
Events.Osiris.ObjectEnteredCombat = _CreateOsirisCombatEventWrapper("ObjectEnteredCombat")
Events.Osiris.ObjectReadyInCombat = _CreateOsirisCombatEventWrapper("ObjectReadyInCombat")
---@see Events.OnTurnEnded
Events.Osiris.ObjectLeftCombat = _CreateOsirisCombatEventWrapper("ObjectLeftCombat")

---@class OsirisObjectSwitchedCombatEventArgs:OsirisCombatObjectEventArgs
---@field OldCombatID integer
---@field OldCombat EsvCombat|nil

---@type LeaderLibSubscribableEvent<OsirisObjectSwitchedCombatEventArgs>
Events.Osiris.ObjectSwitchedCombat = _CreateOsirisEventWrapper("ObjectSwitchedCombat", function (guid, oldcombatID, combatID)
	if Osi.ObjectExists(guid) == 0 then
		return false
	end
	local object = GameHelpers.TryGetObject(guid, "EsvCharacter")
	local evt = {
		Object = object,
		ObjectGUID = _GetGUID(guid),
		ObjectType = GameHelpers.Ext.ObjectIsCharacter(object) and "Character" or "Item",
		CombatID = combatID,
		OldCombatID = oldcombatID,
		OldCombat = Ext.Entity.GetCombat(oldcombatID)
	}
	setmetatable(evt, {__index = _CombatMetaIndex})
	return evt
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

--#endregion

--#region Item Events


---@class OsirisCharacterUsedItemEventArgs:OsirisCharacterItemEventArgs

---@see Events.CharacterUsedItem
---@type LeaderLibSubscribableEvent<OsirisCharacterUsedItemEventArgs>
Events.Osiris.CharacterUsedItem = _CreateCharacterItemEventWrapper("CharacterUsedItem")

---@class OsirisCharacterUsedItemFailedEventArgs:OsirisCharacterItemEventArgs

---@see Events.CharacterUsedItem
---@type LeaderLibSubscribableEvent<OsirisCharacterUsedItemFailedEventArgs>
Events.Osiris.CharacterUsedItemFailed = _CreateCharacterItemEventWrapper("CharacterUsedItemFailed")

---@class OsirisCharacterUsedItemTemplateEventArgs:OsirisCharacterItemEventArgs
---@field Template ItemTemplate
---@field TemplateGUID Guid

---@type LeaderLibSubscribableEvent<OsirisCharacterUsedItemTemplateEventArgs>
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


---@class OsirisItemEquippedEventArgs:OsirisCharacterItemEventArgs

---@type LeaderLibSubscribableEvent<OsirisItemEquippedEventArgs>
Events.Osiris.ItemEquipped = _CreateItemCharacterEventWrapper("ItemEquipped")

---@class OsirisItemUnEquippedEventArgs:OsirisCharacterItemEventArgs

---@type LeaderLibSubscribableEvent<OsirisItemUnEquippedEventArgs>
Events.Osiris.ItemUnEquipped = _CreateItemCharacterEventWrapper("ItemUnEquipped")

---@class OsirisItemUnEquipFailedEventArgs:OsirisCharacterItemEventArgs

---@type LeaderLibSubscribableEvent<OsirisItemUnEquipFailedEventArgs>
Events.Osiris.ItemUnEquipFailed = _CreateItemCharacterEventWrapper("ItemUnEquipFailed")

---@class OsirisItemAddedToCharacterEventArgs:OsirisCharacterItemEventArgs

---@type LeaderLibSubscribableEvent<OsirisItemAddedToCharacterEventArgs>
Events.Osiris.ItemAddedToCharacter = _CreateItemCharacterEventWrapper("ItemAddedToCharacter")

---@class OsirisItemRemovedFromCharacterEventArgs:OsirisCharacterItemEventArgs

---@type LeaderLibSubscribableEvent<OsirisItemRemovedFromCharacterEventArgs>
Events.Osiris.ItemRemovedFromCharacter = _CreateItemCharacterEventWrapper("ItemRemovedFromCharacter")

local function _GetItemContainerEventArgs(itemGUID, containerGUID)
	if _AnyObjectDoesNotExist(itemGUID, containerGUID) then return false end
	local item = GameHelpers.GetItem(itemGUID)
	return {
		Item = item,
		ItemGUID = _GetGUID(itemGUID),
		StatsId = GameHelpers.Item.GetItemStat(item),
		Container = GameHelpers.GetItem(containerGUID),
		ContainerGUID = _GetGUID(containerGUID),
	}
end

---@class OsirisItemSendToHomesteadEventEventArgs:OsirisCharacterItemEventArgs

---@type LeaderLibSubscribableEvent<OsirisItemSendToHomesteadEventEventArgs>
Events.Osiris.ItemSendToHomesteadEvent = _CreateCharacterItemEventWrapper("ItemSendToHomesteadEvent")

---@class OsirisItemRemovedFromContainerEventArgs
---@field Item EsvItem
---@field ItemGUID Guid
---@field StatsId string The item StatsId
---@field Container EsvItem
---@field ContainerGUID Guid

---@type LeaderLibSubscribableEvent<OsirisItemRemovedFromContainerEventArgs>
Events.Osiris.ItemRemovedFromContainer = _CreateOsirisEventWrapper("ItemRemovedFromContainer", _GetItemContainerEventArgs)

---@class OsirisItemAddedToContainerEventArgs:OsirisItemRemovedFromContainerEventArgs

---@type LeaderLibSubscribableEvent<OsirisItemAddedToContainerEventArgs>
Events.Osiris.ItemAddedToContainer = _CreateOsirisEventWrapper("ItemAddedToContainer", _GetItemContainerEventArgs)

Events.Osiris.ItemClosed = _CreateItemEventWrapper("ItemClosed")
Events.Osiris.ItemDropped = _CreateItemEventWrapper("ItemDropped")
Events.Osiris.ItemDestroying = _CreateItemEventWrapper("ItemDestroying")
Events.Osiris.ItemGhostRevealed = _CreateItemEventWrapper("ItemGhostRevealed")
Events.Osiris.ItemMoved = _CreateItemEventWrapper("ItemMoved")
Events.Osiris.ItemOpened = _CreateItemEventWrapper("ItemOpened")
Events.Osiris.ItemReceivedDamage = _CreateItemEventWrapper("ItemReceivedDamage")

---@class OsirisItemDestroyedEventArgs
---@field ItemGUID Guid

---@type LeaderLibSubscribableEvent<OsirisItemDestroyedEventArgs>
Events.Osiris.ItemDestroyed = _CreateOsirisEventWrapper("ItemDestroyed", function (itemGUID) return {ItemGUID = _GetGUID(itemGUID),} end)

---@class OsirisItemCreatedAtTriggerEventArgs:OsirisItemEventArgs
---@field Trigger Trigger
---@field TriggerGUID Guid
---@field Template ItemTemplate
---@field TemplateGUID Guid

---@type LeaderLibSubscribableEvent<OsirisItemCreatedAtTriggerEventArgs>
Events.Osiris.ItemCreatedAtTrigger = _CreateOsirisEventWrapper("ItemCreatedAtTrigger", function (triggerGUID, templateGUID, itemGUID)
	if _AnyObjectDoesNotExist(itemGUID) then return false end
	local item = GameHelpers.GetItem(itemGUID)
	return {
		Trigger = Ext.Entity.GetTrigger(triggerGUID),
		TriggerGUID = _GetGUID(triggerGUID),
		Template = Ext.Template.GetTemplate(templateGUID),
		TemplateGUID = _GetGUID(templateGUID),
		Item = item,
		ItemGUID = _GetGUID(itemGUID),
		StatsId = GameHelpers.Item.GetItemStat(item),
	}
end)

---@class OsirisItemDisplayTextEndedEventArgs:OsirisItemEventArgs
---@field Text string

---@type LeaderLibSubscribableEvent<OsirisItemDisplayTextEndedEventArgs>
Events.Osiris.ItemDisplayTextEnded = _CreateOsirisEventWrapper("ItemDisplayTextEnded", function (itemGUID, text)
	if _AnyObjectDoesNotExist(itemGUID) then return false end
	local item = GameHelpers.GetItem(itemGUID)
	return {
		Item = item,
		ItemGUID = _GetGUID(itemGUID),
		StatsId = GameHelpers.Item.GetItemStat(item),
		Text = text,
	}
end)

local function _GetItemRegionArgs(itemGUID, region)
	if _AnyObjectDoesNotExist(itemGUID) then return false end
	local item = GameHelpers.GetItem(itemGUID)
	local data = {
		Item = item,
		ItemGUID = _GetGUID(itemGUID),
		StatsId = GameHelpers.Item.GetItemStat(item),
		Region = region
	}
	setmetatable(data, {
		__index = function (tbl, k)
			if k == "Level" then
				local level = Ext.Server.GetLevelManager().Levels[region]
				rawset(tbl, k, level)
				return level
			end
		end
	})
	return data
end

---@class OsirisItemEnteredRegionEventArgs:OsirisItemEventArgs
---@field Region string
---@field Level EsvLevel

---@type LeaderLibSubscribableEvent<OsirisItemEnteredRegionEventArgs>
Events.Osiris.ItemEnteredRegion = _CreateOsirisEventWrapper("ItemEnteredRegion", _GetItemRegionArgs)

---@class OsirisItemLeftRegionEventArgs:OsirisItemEnteredRegionEventArgs

---@type LeaderLibSubscribableEvent<OsirisItemEnteredRegionEventArgs>
Events.Osiris.ItemLeftRegion = _CreateOsirisEventWrapper("ItemLeftRegion", _GetItemRegionArgs)

--#endregion

--#region Pickpocketing


---@class OsirisRequestPickpocketEventArgs
---@field Player EsvCharacter
---@field PlayerGUID Guid
---@field Target EsvCharacter
---@field TargetGUID Guid
---@field AllowAction fun(self:OsirisRequestPickpocketEventArgs) Force the request to succeed via `Osi.StartPickpocket`.
---@field PreventAction fun(self:OsirisRequestPickpocketEventArgs) Deny the request via.

---@type LeaderLibSubscribableEvent<OsirisRequestPickpocketEventArgs>
Events.Osiris.RequestPickpocket = _CreateOsirisEventWrapper("RequestPickpocket", function (playerGUID, targetGUID)
	if _AnyObjectDoesNotExist(playerGUID, targetGUID) then return false end
	local player = GameHelpers.GetCharacter(playerGUID)
	local target = GameHelpers.GetCharacter(targetGUID)
	return {
		Player = player,
		PlayerGUID = _GetGUID(playerGUID),
		Target = target,
		TargetGUID = _GetGUID(targetGUID),
		AllowAction = function ()
			if Ext.Utils.GetGameMode() ~= "Campaign" then
				if not GameHelpers.Character.IsPlayerOrPartyMember(target) then
					Osi.GenTradeItems(playerGUID, targetGUID)
				end
			end
			Osi.StartPickpocket(playerGUID, targetGUID, 1)
		end,
		PreventAction = function ()
			--The _CRIME_CrimeTriggers script doesn't run in GM mode
			if Ext.Utils.GetGameMode() ~= "Campaign" then
				Osi.StartPickpocket(playerGUID, targetGUID, 0)
			else
				Osi.DB_PickpocketingBlocked(1)
			end
		end
	}
end, "before")

---@class OsirisCharacterPickpocketSuccessEventArgs
---@field Player EsvCharacter
---@field PlayerGUID Guid
---@field Target EsvCharacter
---@field TargetGUID Guid
---@field Item EsvItem
---@field ItemGUID Guid
---@field Amount integer

---@type LeaderLibSubscribableEvent<OsirisCharacterPickpocketSuccessEventArgs>
Events.Osiris.CharacterPickpocketSuccess = _CreateOsirisEventWrapper("CharacterPickpocketSuccess", function (playerGUID, targetGUID, itemGUID, amount)
	if _AnyObjectDoesNotExist(playerGUID, targetGUID, itemGUID) then return false end
	local player = GameHelpers.GetCharacter(playerGUID)
	local target = GameHelpers.GetCharacter(targetGUID)
	local item = GameHelpers.GetItem(itemGUID)
	return {
		Player = player,
		PlayerGUID = _GetGUID(playerGUID),
		Target = target,
		TargetGUID = _GetGUID(targetGUID),
		Item = item,
		ItemGUID = _GetGUID(itemGUID),
		Amount = amount
	}
end)

---@class OsirisCharacterPickpocketFailedEventArgs
---@field Player EsvCharacter
---@field PlayerGUID Guid
---@field Target EsvCharacter
---@field TargetGUID Guid
---@field PreventAction fun(self:OsirisCharacterPickpocketFailedEventArgs) Prevent the crimes script from creating a crime.

---@type LeaderLibSubscribableEvent<OsirisCharacterPickpocketFailedEventArgs>
Events.Osiris.CharacterPickpocketFailed = _CreateOsirisEventWrapper("CharacterPickpocketFailed", function (playerGUID, targetGUID)
	if _AnyObjectDoesNotExist(playerGUID, targetGUID) then return false end
	local player = GameHelpers.GetCharacter(playerGUID)
	local target = GameHelpers.GetCharacter(targetGUID)
	return {
		Player = player,
		PlayerGUID = _GetGUID(playerGUID),
		Target = target,
		TargetGUID = _GetGUID(targetGUID),
		PreventAction = function ()
			if Ext.Utils.GetGameMode() == "Campaign" then
				Osi.DB_PickpocketingBlocked(1)
			end
		end
	}
end, "before")

--#endregion

--#region Requests (_CRIME_CrimeTriggers)

---@type LeaderLibSubscribableEvent<{Character:EsvCharacter, CharacterGUID:Guid, Item:EsvItem, ItemGUID:Guid, RequestID:integer}>
Events.Osiris.CanUseItem = _CreateOsirisEventWrapper("CanUseItem", function (charGUID, itemGUID, requestID)
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
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
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
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
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
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
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
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
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
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
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
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
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
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
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
	local item = GameHelpers.GetItem(itemGUID)
	return {
		Item = item,
		ItemGUID = _GetGUID(itemGUID),
		StatsId = GameHelpers.Item.GetItemStat(item),
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
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

--#region Crimes

---@class OsirisCrimeIsRegisteredEventArgs
---@field Target EsvCharacter
---@field TargetGUID Guid
---@field CrimeType CrimeType
---@field CrimeID integer
---@field Evidence ServerObject
---@field EvidenceGUID Guid
---@field Criminals EsvCharacter[]
---@field CriminalGUIDs Guid[]
---@field TotalCriminals integer

---@type LeaderLibSubscribableEvent<OsirisCrimeIsRegisteredEventArgs>
Events.Osiris.CrimeIsRegistered = _CreateOsirisEventWrapper("CrimeIsRegistered", function (targetGUID, crimeType, crimeID, evidenceGUID, ...)
	if not _ObjectExists(targetGUID) then return false end
	local criminalGUIDs = {}
	local criminals = {}
	local totalCriminals = 0
	for i,v in pairs({...}) do
		if not StringHelpers.IsNullOrEmpty(v) then
			totalCriminals = totalCriminals + 1
			criminalGUIDs[totalCriminals] = _GetGUID(v)
			criminals[totalCriminals] = GameHelpers.GetCharacter(v)
		end
	end
	local target = GameHelpers.GetCharacter(targetGUID)
	---@type OsirisCrimeIsRegisteredEventArgs
	return {
		Target = target,
		TargetGUID = _GetGUID(targetGUID),
		CrimeType = crimeType,
		CrimeID = crimeID,
		Evidence = GameHelpers.TryGetObject(evidenceGUID),
		EvidenceGUID = _GetGUID(evidenceGUID),
		CriminalGUIDs = criminalGUIDs,
		Criminals = criminals,
		TotalCriminals = totalCriminals
	}
end, "before")

--#endregion

--#region Tags

---@class OsirisObjectTagEventArgs
---@field Object ServerObject
---@field ObjectGUID Guid
---@field ObjectType "Character"|"Item"
---@field Tag string
---@field AllTags table<string, boolean> All of the object's tags, including tags found on equipped items, in tag -> boolean format. Only fetched when initially accessed.

local function _ObjectTagIndexMeta(tbl, k)
	if k == "AllTags" then
		local object = rawget(tbl, "Object")
		if object then
			local tags = GameHelpers.GetAllTags(object, true, true)
			rawset(tbl, "AllTags", tags)
			return tags
		end
	end
end

local _ObjectTagEventMeta = {__index = _ObjectTagIndexMeta}

---@type LeaderLibSubscribableEvent<OsirisObjectTagEventArgs>
Events.Osiris.ObjectWasTagged = _CreateOsirisEventWrapper("ObjectWasTagged", function (guid, tag)
	if not _ObjectExists(guid) then return false end
	local object = GameHelpers.TryGetObject(guid)
	local evt = {
		Object = object,
		ObjectGUID = _GetGUID(guid),
		Tag = tag,
		ObjectType = GameHelpers.Ext.ObjectIsCharacter(object) and "Character" or "Item"
	}
	setmetatable(evt, _ObjectTagEventMeta)
	return evt
end)

---@type LeaderLibSubscribableEvent<OsirisObjectTagEventArgs>
Events.Osiris.ObjectLostTag = _CreateOsirisEventWrapper("ObjectLostTag", function (guid, tag)
	if not _ObjectExists(guid) then return false end
	local object = GameHelpers.TryGetObject(guid)
	local evt = {
		Object = object,
		ObjectGUID = _GetGUID(guid),
		ObjectType = GameHelpers.Ext.ObjectIsCharacter(object) and "Character" or "Item",
		Tag = tag,
	}
	setmetatable(evt, _ObjectTagEventMeta)
	return evt
end)

--#endregion

--#region Teleportation Events

---@param triggerGUID Guid
---@return string|nil id
---@return string|nil itemGUID
local function _GetWaypointFromTrigger(triggerGUID)
	local db = Osi.DB_WaypointInfo:Get(nil, triggerGUID, nil)
	if db and db[1] then
		local itemGUID,_,id = table.unpack(db[1])
		return id,_GetGUID(itemGUID)
	end
end

---@class OsirisCharacterTeleportByItemEventArgs:OsirisCharacterTriggerEventArgs
---@field Item EsvItem
---@field ItemGUID Guid

---@type LeaderLibSubscribableEvent<OsirisCharacterTeleportByItemEventArgs>
Events.Osiris.CharacterTeleportByItem = _CreateOsirisEventWrapper("CharacterTeleportByItem", function (charGUID, itemGUID, triggerGUID)
	if _AnyObjectDoesNotExist(charGUID, itemGUID) then return false end
	return {
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Item = GameHelpers.GetItem(itemGUID),
		ItemGUID = _GetGUID(itemGUID),
		Trigger = Ext.Entity.GetTrigger(triggerGUID),
		TriggerGUID = _GetGUID(triggerGUID),
	}
end)

---@class OsirisCharacterTeleportToFleeWaypointEventArgs:OsirisCharacterTriggerEventArgs
---@field WaypointID string
---@field WaypointItem EsvItem|nil
---@field WaypointItemGUID Guid|nil

---@type LeaderLibSubscribableEvent<OsirisCharacterTeleportToFleeWaypointEventArgs>
Events.Osiris.CharacterTeleportToFleeWaypoint = _CreateOsirisEventWrapper("CharacterTeleportToFleeWaypoint", function (charGUID, triggerGUID)
	if not _ObjectExists(charGUID) then return false end
	local data = {
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Trigger = Ext.Entity.GetTrigger(triggerGUID),
		TriggerGUID = _GetGUID(triggerGUID),
		WaypointID = "",
	}
	local waypoint,itemGUID = _GetWaypointFromTrigger(triggerGUID)
	if waypoint then
		data.WaypointID = waypoint
		data.WaypointItemGUID = itemGUID
		data.WaypointItem = GameHelpers.GetItem(itemGUID)
	end
	return data
end)

---@class OsirisCharacterTeleportToWaypointEventArgs:OsirisCharacterTeleportToFleeWaypointEventArgs

---@type LeaderLibSubscribableEvent<OsirisCharacterTeleportToWaypointEventArgs>
Events.Osiris.CharacterTeleportToWaypoint = _CreateOsirisEventWrapper("CharacterTeleportToWaypoint", function (charGUID, triggerGUID)
	if not _ObjectExists(charGUID) then return false end
	local data = {
		Character = GameHelpers.GetCharacter(charGUID),
		CharacterGUID = _GetGUID(charGUID),
		Trigger = Ext.Entity.GetTrigger(triggerGUID),
		TriggerGUID = _GetGUID(triggerGUID),
		WaypointID = "",
	}
	local waypoint,itemGUID = _GetWaypointFromTrigger(triggerGUID)
	if waypoint then
		data.WaypointID = waypoint
		data.WaypointItemGUID = itemGUID
		data.WaypointItem = GameHelpers.GetItem(itemGUID)
	end
	return data
end)

---@class OsirisCharacterTeleportToPyramidEventArgs:OsirisCharacterItemEventArgs

---@type LeaderLibSubscribableEvent<OsirisCharacterTeleportToPyramidEventArgs>
Events.Osiris.CharacterTeleportToPyramid = _CreateCharacterItemEventWrapper("CharacterTeleportToPyramid")

--#endregion