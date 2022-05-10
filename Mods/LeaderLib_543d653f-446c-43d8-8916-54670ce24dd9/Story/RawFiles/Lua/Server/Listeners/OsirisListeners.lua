local function SendMissingExtenderMessage(uuid)
	local character = Ext.GetCharacter(uuid)
	if character and character.UserID ~= character.ReservedUserID and character.IsPlayer and CharacterIsControlled(uuid) == 1 then
		return Ext.PlayerHasExtender(uuid)
	end
	return false
end

Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, username, profileId)
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

Ext.RegisterOsirisListener("UserDisconnected", 3, "after", function(id, username, profileId)
	Vars.Users[profileId] = nil
end)

Ext.RegisterOsirisListener("UserEvent", 2, "after", function(id, event)
	if event == "Iterators_LeaderLib_UI_UnlockPartyInventory" and GameHelpers.IsLevelType(LEVELTYPE.GAME) then
		GameHelpers.Net.PostToUser(id, "LeaderLib_UnlockCharacterInventory")
	end
end)

-- Ext.RegisterOsirisListener("CharacterAddToCharacterCreation", 3, "after", function(uuid, respec, success)
-- 	if success == 1 then
-- 		Timer.StartOneshot("", 1, function()
-- 			Ext.PostMessageToClient(uuid, "LeaderLib_CCStarted", Ext.GetCharacter(uuid).NetID)
-- 		end)
-- 	end
-- end)

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
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
			Ext.Print(string.format("[LeaderLib:Log(%s)] %s", logType, msg))
		end
	end
end

-- if Vars.DebugMode then
-- 	for i=1,16 do
-- 		Ext.RegisterOsirisListener("LeaderLog_Log", i, "before", OnLog)
-- 	end
-- end

local function GlobalFlagChanged(flag, enabled)
	local flagListeners = Listeners.GlobalFlagChanged[flag]
	if flagListeners then
		InvokeListenerCallbacks(flagListeners, flag, enabled)
	end
end

Ext.RegisterOsirisListener("GlobalFlagSet", 1, "after", function(flag)
	GlobalFlagChanged(flag, true)
end)

Ext.RegisterOsirisListener("GlobalFlagCleared", 1, "after", function(flag)
	GlobalFlagChanged(flag, false)
end)

local function OnObjectDying(obj)
	if not Ext.GetGameState() == "Running" then
		return
	end
	obj = StringHelpers.GetUUID(obj)
	local isSummon = false
	local owner = nil
	local summon = ObjectExists(obj) == 1 and GameHelpers.TryGetObject(obj) or nil
	for ownerId,tbl in pairs(PersistentVars.Summons) do
		for i,uuid in pairs(tbl) do
			if uuid == obj then
				owner = GameHelpers.TryGetObject(ownerId)
				table.remove(tbl, i)
				isSummon = true
			end
		end
		if #tbl == 0 then
			PersistentVars.Summons[ownerId] = nil
		end
	end
	if isSummon then
		InvokeListenerCallbacks(Listeners.OnSummonChanged, summon or obj, owner, true, ObjectIsItem(obj) == 1)
	end
end

Ext.RegisterOsirisListener("CharacterPrecogDying", Data.OsirisEvents.CharacterPrecogDying, "before", OnObjectDying)
Ext.RegisterOsirisListener("ItemDestroying", Data.OsirisEvents.ItemDestroying, "before", OnObjectDying)

local function OnObjectEvent(event, ...)
	InvokeListenerCallbacks(Listeners.ObjectEvent[event], ...)
	if event ~= "All" then
		InvokeListenerCallbacks(Listeners.ObjectEvent.All, ...)
	end
end

Ext.RegisterOsirisListener("StoryEvent", Data.OsirisEvents.StoryEvent, "before", function(object, event)
	OnObjectEvent(event, StringHelpers.GetUUID(object))
end)

Ext.RegisterOsirisListener("CharacterCharacterEvent", Data.OsirisEvents.CharacterCharacterEvent, "before", function(obj1, obj2, event)
	OnObjectEvent(event, StringHelpers.GetUUID(obj1), StringHelpers.GetUUID(obj2))
end)

Ext.RegisterOsirisListener("CharacterItemEvent", Data.OsirisEvents.CharacterItemEvent, "before", function(obj1, obj2, event)
	OnObjectEvent(event, StringHelpers.GetUUID(obj1), StringHelpers.GetUUID(obj2))
end)

---@param item EsvItem
RegisterProtectedExtenderListener("TreasureItemGenerated", function(item)
	InvokeListenerCallbacks(Listeners.TreasureItemGenerated, item, item and item.StatsId or "")
end)

---Called from LeaderLib_21_GS_Statuses.txt
---@param uuid string
function OnCharacterResurrected(uuid)
	local character = GameHelpers.GetCharacter(uuid)
	if character then
		Events.CharacterResurrected:Invoke(character)
		GameHelpers.Net.Broadcast("LeaderLib_Client_CharacterResurrected", character.NetID)
	end
end