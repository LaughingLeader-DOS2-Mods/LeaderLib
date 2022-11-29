local function SendMissingExtenderMessage(uuid)
	local character = GameHelpers.GetCharacter(uuid)
	if character and character.UserID ~= character.ReservedUserID and character.IsPlayer and CharacterIsControlled(uuid) == 1 then
		return Ext.PlayerHasExtender(uuid)
	end
	return false
end

Ext.Osiris.RegisterListener("UserConnected", 3, "after", function(id, username, profileId)
	Vars.Users[profileId] = {ID = id, Name=username}
	if Ext.GetGameState() == "Running" then
		if GameHelpers.IsLevelType(LEVELTYPE.GAME) and GlobalGetFlag("LeaderLib_AutoUnlockInventoryInMultiplayer") == 1 then
			Timer.Start("LeaderLib_UnlockCharacterInventories", 1500)
		end
		local host = StringHelpers.GetUUID(CharacterGetHostCharacter())
		local uuid = StringHelpers.GetUUID(GetCurrentCharacter(id))
		if not StringHelpers.IsNullOrEmpty(uuid)
		and not StringHelpers.IsNullOrEmpty(host)
		and host ~= uuid then
			SettingsManager.SyncAllSettings(id)
			if SendMissingExtenderMessage(uuid) then
				OpenMessageBox(uuid, "LeaderLib_MessageBox_ExtenderNotInstalled_Client")
				local text = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
				OpenMessageBox(host, text)
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

-- Ext.Osiris.RegisterListener("CharacterAddToCharacterCreation", 3, "after", function(uuid, respec, success)
-- 	if success == 1 then
-- 		Timer.StartOneshot("", 1, function()
-- 			Ext.PostMessageToClient(uuid, "LeaderLib_CCStarted", GameHelpers.GetCharacter(uuid).NetID)
-- 		end)
-- 	end
-- end)

Ext.Osiris.RegisterListener("GameStarted", 2, "after", function(region, isEditorMode)
	Vars.IsEditorMode = isEditorMode
	GameHelpers.Net.Broadcast("LeaderLib_SyncFeatures", Common.JsonStringify(Features))
end)

local function OnLog(logType, ...)
	if Osi.LeaderLib_QRY_AnyGoalsAreActive("LeaderLib_00_0_TS_StrictLogCalls", "LeaderLib_00_0_TS_AllLogging") == true then
		return
	end
	if logType == "COMBINE" or Vars.DebugMode or Osi.LeaderLog_QRY_LogTypeEnabled(logType) == true then
		local params = {...}
		local msg = StringHelpers.Join("", params)
		Osi.LeaderLog_Internal_RunString(logType, msg)
		if Vars.DebugMode then
			Ext.Utils.Print(string.format("[LeaderLib:Log(%s)] %s", logType, msg))
		end
	end
end

-- if Vars.DebugMode then
-- 	for i=1,16 do
-- 		Ext.Osiris.RegisterListener("LeaderLog_Log", i, "before", OnLog)
-- 	end
-- end

Ext.Osiris.RegisterListener("GlobalFlagSet", 1, "after", function(flag)
	Events.GlobalFlagChanged:Invoke({Flag=flag, Enabled=true})
end)

Ext.Osiris.RegisterListener("GlobalFlagCleared", 1, "after", function(flag)
	Events.GlobalFlagChanged:Invoke({Flag=flag, Enabled=false})
end)

local function OnObjectDying(obj)
	if not Ext.GetGameState() == "Running" then
		return
	end
	obj = StringHelpers.GetUUID(obj)
	local isSummon = false
	local owner = nil
	local target = ObjectExists(obj) == 1 and GameHelpers.TryGetObject(obj) or nil
	for ownerId,tbl in pairs(_PV.Summons) do
		for i,uuid in pairs(tbl) do
			if uuid == obj then
				owner = GameHelpers.TryGetObject(ownerId)
				table.remove(tbl, i)
				isSummon = true
			end
		end
		if #tbl == 0 then
			_PV.Summons[ownerId] = nil
		end
	end
	if isSummon then
		Events.SummonChanged:Invoke({Summon=target or obj, Owner=owner, IsDying=true, IsItem=ObjectIsItem(obj) == 1})
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
	if obj1 and ObjectExists(obj1) == 1 then
		obj1 = GameHelpers.TryGetObject(obj1) or obj1
	end
	if obj2 and ObjectExists(obj2) == 1 then
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
		Success = true,
	})
end)

Ext.Osiris.RegisterListener("CharacterUsedItemFailed", 2, "before", function (characterGUID, itemGUID)
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
	local template = Ext.Template.GetRootTemplate(runeTemplate)
	local runeStat = Ext.Stats.Get(template.Stats, nil, false)
	local boostStat,boostStatName,boostStatAttribute = _GetRuneBoost(item, runeStat)
	Events.RuneChanged:Invoke({
		Character = character,
		CharacterGUID = characterGUID,
		Item = item,
		ItemGUID = itemGUID,
		RuneTemplate = runeTemplate,
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
	local runeStatEntry = rune.StatsFromName and rune.StatsFromName.StatsEntry or nil
	local boostStat,boostStatName,boostStatAttribute = _GetRuneBoost(item, runeStatEntry)
	Events.RuneChanged:Invoke({
		Character = character,
		CharacterGUID = characterGUID,
		Item = item,
		ItemGUID = itemGUID,
		RuneTemplate = rune and GameHelpers.GetTemplate(rune) or "",
		RuneSlot = slot,
		Inserted = false,
		BoostStat = boostStat,
		BoostStatID = boostStatName,
		BoostStatAttribute = boostStatAttribute,
	})
end)