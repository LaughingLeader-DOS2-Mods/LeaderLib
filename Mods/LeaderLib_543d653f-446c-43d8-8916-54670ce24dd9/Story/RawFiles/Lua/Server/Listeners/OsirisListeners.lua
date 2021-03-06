local function SendMissingExtenderMessage(uuid)
	local character = Ext.GetCharacter(uuid)
	if character and character.UserID ~= character.ReservedUserID and character.IsPlayer and CharacterIsControlled(uuid) == 1 then
		return Ext.PlayerHasExtender(uuid)
	end
	return false
end

Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, username, profileId)
	if Ext.GetGameState() == "Running" then
		if GlobalGetFlag("LeaderLib_AutoUnlockInventoryInMultiplayer") == 1 then
			IterateUsers("Iterators_LeaderLib_UI_UnlockPartyInventory")
		end
		SettingsManager.SyncAllSettings(id)

		local host = CharacterGetHostCharacter()
		local uuid = GetCurrentCharacter(id)
		if not StringHelpers.IsNullOrEmpty(uuid) and host ~= uuid and SendMissingExtenderMessage(uuid) then
			OpenMessageBox(uuid, "LeaderLib_MessageBox_ExtenderNotInstalled_Client")
			local text = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
			OpenMessageBox(host, text)
			--local hostText = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
			--GameHelpers.UI.ShowMessageBox(hostText, host, 0, GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageTitle"))
		end
	end
end)

Ext.RegisterOsirisListener("UserEvent", 2, "after", function(id, event)
	if event == "Iterators_LeaderLib_UI_UnlockPartyInventory" and SharedData.RegionData.LevelType == LEVELTYPE.GAME then
		local playersDB = Osi.DB_IsPlayer:Get(nil)
		if playersDB ~= nil and #playersDB > 0 then
			local players = {}
			for i,v in pairs(playersDB) do
				table.insert(players, GetUUID(v[1]))
			end
			Ext.PostMessageToUser(id, "LeaderLib_UnlockCharacterInventory", Ext.JsonStringify(players))
		end
	end
end)

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
	Ext.BroadcastMessage("LeaderLib_SyncFeatures", Ext.JsonStringify(Features), nil)
	MonitoredCharacterData:Update(region)
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

for i=1,16 do
	Ext.RegisterOsirisListener("LeaderLog_Log", i, "before", OnLog)
end

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