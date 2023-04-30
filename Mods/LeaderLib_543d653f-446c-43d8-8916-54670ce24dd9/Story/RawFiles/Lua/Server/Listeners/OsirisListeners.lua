local function SendMissingExtenderMessage(uuid)
	local character = GameHelpers.GetCharacter(uuid)
	if character and character.UserID ~= character.ReservedUserID and character.IsPlayer and Osi.CharacterIsControlled(uuid) == 1 then
		return Ext.Net.PlayerHasExtender(uuid)
	end
	return false
end

Ext.Osiris.RegisterListener("UserConnected", 3, "after", function(id, username, profileId)
	Vars.Users[profileId] = {ID = id, Name=username}
	if Ext.GetGameState() == "Running" then
		if GameHelpers.IsLevelType(LEVELTYPE.GAME) and Osi.GlobalGetFlag("LeaderLib_AutoUnlockInventoryInMultiplayer") == 1 then
			Timer.Start("LeaderLib_UnlockCharacterInventories", 1500)
		end
		local host = StringHelpers.GetUUID(Osi.CharacterGetHostCharacter())
		local uuid = StringHelpers.GetUUID(Osi.GetCurrentCharacter(id))
		if not StringHelpers.IsNullOrEmpty(uuid)
		and not StringHelpers.IsNullOrEmpty(host)
		and host ~= uuid then
			SettingsManager.SyncAllSettings(id)
			if SendMissingExtenderMessage(uuid) then
				Osi.OpenMessageBox(uuid, "LeaderLib_MessageBox_ExtenderNotInstalled_Client")
				local text = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
				Osi.OpenMessageBox(host, text)
				--local hostText = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
				--GameHelpers.UI.ShowMessageBox(hostText, host, 0, GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageTitle"))
			end
		end
	end
end)

Ext.Osiris.RegisterListener("UserDisconnected", 3, "after", function(id, username, profileId)
	Vars.Users[profileId] = nil
end)

Ext.Osiris.RegisterListener("UserEvent", 2, "after", function(id, event)
	if event == "Iterators_LeaderLib_UI_UnlockPartyInventory" and GameHelpers.IsLevelType(LEVELTYPE.GAME) then
		GameHelpers.Net.PostToUser(id, "LeaderLib_UnlockCharacterInventory")
	end
end)

Ext.Osiris.RegisterListener("GameStarted", 2, "after", function(region, isEditorMode)
	Vars.IsEditorMode = isEditorMode
	GameHelpers.Net.Broadcast("LeaderLib_SyncFeatures", Common.JsonStringify(Features))
end)

Ext.Osiris.RegisterListener("GlobalFlagSet", 1, "after", function(flag)
	Events.GlobalFlagChanged:Invoke({Flag=flag, Enabled=true})
end)

Ext.Osiris.RegisterListener("GlobalFlagCleared", 1, "after", function(flag)
	Events.GlobalFlagChanged:Invoke({Flag=flag, Enabled=false})
end)

local function _SanitizeSummonsData()
	local summonData = {}
	for ownerGUID,tbl in pairs(_PV.Summons) do
		if Osi.ObjectExists(ownerGUID) == 1 then
			local totalSummons = 0
			local summons = {}
			for _,guid in pairs(tbl) do
				if Osi.ObjectExists(guid) == 1 then
					totalSummons = totalSummons + 1
					summons[totalSummons] = guid
				end
			end
			if totalSummons > 0 then
				summonData[ownerGUID] = summons
			end
		end
	end
	_PV.Summons = summonData
end

GameHelpers._INTERNAL.SanitizeSummonsData = _SanitizeSummonsData

local function OnObjectDying(obj)
	if not Ext.GetGameState() == "Running" then
		return
	end
	local summonGUID = StringHelpers.GetUUID(obj)
	obj = StringHelpers.GetUUID(obj)
	local isSummon = false
	local owner = nil
	local ownerGUID = nil
	local target = GameHelpers.TryGetObject(obj)
	for guid,summons in pairs(_PV.Summons) do
		for i,summon in pairs(summons) do
			if summon == summonGUID then
				owner = GameHelpers.TryGetObject(guid)
				if owner then
					ownerGUID = owner.MyGuid
				end
				isSummon = true
			end
		end
	end
	if isSummon then
		local isItem = target and GameHelpers.Ext.ObjectIsItem(target) or false
		Events.SummonChanged:Invoke({
			Summon=target or summonGUID,
			SummonGUID=summonGUID,
			Owner=owner,
			OwnerGUID=ownerGUID,
			IsDying=true,
			IsItem=isItem
		}, true)
		_SanitizeSummonsData()
	end
	if target and GameHelpers.Ext.ObjectIsCharacter(target) then
		Events.CharacterDied:Invoke({
			Character = target,
			CharacterGUID = target.MyGuid,
			IsPlayer = GameHelpers.Character.IsPlayer(target),
			State = "BeforeDying",
			StateIndex = Vars.CharacterDiedState.BeforeDying,
		})
	end
end

Ext.Osiris.RegisterListener("CharacterPrecogDying", 1, "before", OnObjectDying)
Ext.Osiris.RegisterListener("ItemDestroying", 1, "before", OnObjectDying)

RegisterProtectedOsirisListener("CharacterDying", 1, "before", function (characterGUID)
	local target = GameHelpers.GetCharacter(characterGUID)
	if target then
		Events.CharacterDied:Invoke({
			Character = target,
			CharacterGUID = target.MyGuid,
			IsPlayer = GameHelpers.Character.IsPlayer(target),
			State = "Dying",
			StateIndex = Vars.CharacterDiedState.Dying,
		})
	end
end)

RegisterProtectedOsirisListener("CharacterDied", 1, "before", function (characterGUID)
	local target = GameHelpers.GetCharacter(characterGUID)
	if target then
		Events.CharacterDied:Invoke({
			Character = target,
			CharacterGUID = target.MyGuid,
			IsPlayer = GameHelpers.Character.IsPlayer(target),
			State = "Died",
			StateIndex = Vars.CharacterDiedState.Died,
		})
	end
end)

local function OnObjectEvent(eventType, event, obj1, obj2)
	if obj1 and Osi.ObjectExists(obj1) == 1 then
		obj1 = GameHelpers.TryGetObject(obj1) or obj1
	end
	if obj2 and Osi.ObjectExists(obj2) == 1 then
		obj2 = GameHelpers.TryGetObject(obj2) or obj2
	end
	Events.ObjectEvent:Invoke({
		Event = event,
		EventType = eventType,
		Objects = {obj1,obj2},
		ObjectGUID1 = GameHelpers.GetUUID(obj1),
		ObjectGUID2 = GameHelpers.GetUUID(obj2)
	})
end

Ext.Osiris.RegisterListener("StoryEvent", Data.OsirisEvents.StoryEvent, "before", function(object, event)
	OnObjectEvent("StoryEvent", event, StringHelpers.GetUUID(object))
end)

Ext.Osiris.RegisterListener("CharacterCharacterEvent", Data.OsirisEvents.CharacterCharacterEvent, "before", function(obj1, obj2, event)
	OnObjectEvent("CharacterCharacterEvent", event, StringHelpers.GetUUID(obj1), StringHelpers.GetUUID(obj2))
end)

Ext.Osiris.RegisterListener("CharacterItemEvent", Data.OsirisEvents.CharacterItemEvent, "before", function(obj1, obj2, event)
	OnObjectEvent("CharacterItemEvent", event, StringHelpers.GetUUID(obj1), StringHelpers.GetUUID(obj2))
end)

---Called from LeaderLib_21_GS_Statuses.txt
---@param uuid string
function OnCharacterResurrected(uuid)
	local character = GameHelpers.GetCharacter(uuid)
	if character then
		Events.CharacterResurrected:Invoke({Character=character, CharacterGUID = character.MyGuid, IsPlayer = GameHelpers.Character.IsPlayer(character)})
	end
end

Ext.Osiris.RegisterListener("CharacterUsedItem", 2, "before", function (characterGUID, itemGUID)
	if Osi.ObjectExists(itemGUID) == 0 or Osi.ObjectExists(characterGUID) == 0 then
		return
	end
	characterGUID = StringHelpers.GetUUID(characterGUID)
	itemGUID = StringHelpers.GetUUID(itemGUID)
	local character = GameHelpers.GetCharacter(characterGUID)
	local item = GameHelpers.GetItem(itemGUID)
	Events.CharacterUsedItem:Invoke({
		Character = character,
		CharacterGUID = characterGUID,
		Item = item,
		ItemGUID = itemGUID,
		Template = item and GameHelpers.GetTemplate(item) or "",
		StatsId = GameHelpers.Item.GetItemStat(item),
		Success = true,
	})
end)

Ext.Osiris.RegisterListener("CharacterUsedItemFailed", 2, "before", function (characterGUID, itemGUID)
	if Osi.ObjectExists(itemGUID) == 0 or Osi.ObjectExists(characterGUID) == 0 then
		return
	end
	characterGUID = StringHelpers.GetUUID(characterGUID)
	itemGUID = StringHelpers.GetUUID(itemGUID)
	local character = GameHelpers.GetCharacter(characterGUID)
	local item = GameHelpers.GetItem(itemGUID)
	Events.CharacterUsedItem:Invoke({
		Character = character,
		CharacterGUID = characterGUID,
		Item = item,
		ItemGUID = itemGUID,
		Template = item and GameHelpers.GetTemplate(item) or "",
		StatsId = GameHelpers.Item.GetItemStat(item),
		Success = false,
	})
end)

local _RuneAccessorySlot = {
	Amulet = true,
	Ring = true,
	Ring2 = true,
	Belt = true,
}

---@param item EsvItem
---@param runeStat StatEntryObject
local function _GetRuneBoost(item, runeStat)
	local activeBoostStat = ""
	local activeBoostStatAttribute = ""
	if item.Stats then
		if item.Stats.ItemType == "Weapon" then
			activeBoostStatAttribute = "RuneEffectWeapon"
		elseif item.Stats.ItemType == "Armor" then
			if _RuneAccessorySlot[item.Stats.ItemSlot] then
				activeBoostStatAttribute = "RuneEffectAmulet"
			else
				activeBoostStatAttribute = "RuneEffectUpperbody"
			end
		end
	end
	if runeStat then
		activeBoostStat = runeStat[activeBoostStatAttribute] or ""
	end

	return not StringHelpers.IsNullOrWhitespace(activeBoostStat) and Ext.Stats.Get(activeBoostStat, nil, false), activeBoostStat, activeBoostStatAttribute
end

Ext.Osiris.RegisterListener("RuneInserted", 4, "before", function (characterGUID, itemGUID, runeTemplate, slot)
	characterGUID = StringHelpers.GetUUID(characterGUID)
	itemGUID = StringHelpers.GetUUID(itemGUID)
	runeTemplate = StringHelpers.GetUUID(runeTemplate)
	local character = GameHelpers.GetCharacter(characterGUID)
	local item = GameHelpers.GetItem(itemGUID)
	local template = Ext.Template.GetRootTemplate(runeTemplate)--[[@as ItemTemplate]]
	local runeStat = nil
	if template then
		runeStat = Ext.Stats.Get(template.Stats, nil, false)
	end
	local boostStat,boostStatName,boostStatAttribute = _GetRuneBoost(item, runeStat)
	Events.RuneChanged:Invoke({
		Character = character,
		CharacterGUID = characterGUID,
		Item = item,
		ItemGUID = itemGUID,
		RuneTemplateGUID = runeTemplate,
		RuneTemplate = template,
		RuneStat = runeStat,
		RuneSlot = slot,
		Inserted = true,
		BoostStat = boostStat,
		BoostStatID = boostStatName,
		BoostStatAttribute = boostStatAttribute,
	})
end)

Ext.Osiris.RegisterListener("RuneRemoved", 4, "after", function (characterGUID, itemGUID, runeGUID, slot)
	characterGUID = StringHelpers.GetUUID(characterGUID)
	itemGUID = StringHelpers.GetUUID(itemGUID)
	runeGUID = StringHelpers.GetUUID(runeGUID)
	local character = GameHelpers.GetCharacter(characterGUID)
	local item = GameHelpers.GetItem(itemGUID)
	local rune = GameHelpers.GetItem(runeGUID)
	local runeTemplate,templateGUID = GameHelpers.GetTemplate(rune, true)--[[@as ItemTemplate]]
	local runeStatEntry = rune.StatsFromName and rune.StatsFromName.StatsEntry or nil
	local boostStat,boostStatName,boostStatAttribute = _GetRuneBoost(item, runeStatEntry)
	Events.RuneChanged:Invoke({
		Character = character,
		CharacterGUID = characterGUID,
		Item = item,
		ItemGUID = itemGUID,
		RuneTemplate = runeTemplate,
		RuneTemplateGUID = templateGUID,
		RuneStat = runeStatEntry,
		RuneSlot = slot,
		Inserted = false,
		BoostStat = boostStat,
		BoostStatID = boostStatName,
		BoostStatAttribute = boostStatAttribute,
	})
end)