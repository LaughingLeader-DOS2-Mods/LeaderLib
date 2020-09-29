Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, username, profileId)
	if Ext.GetGameState() == "Running" then
		if GlobalGetFlag("LeaderLib_AutoUnlockInventoryInMultiplayer") == 1 then
			IterateUsers("Iterators_LeaderLib_UI_UnlockPartyInventory")
		end
		SettingsManager.SyncAllSettings(id)

		local host = CharacterGetHostCharacter()
		local uuid = GetCurrentCharacter(id)
		if uuid ~= nil then
			if not StringHelpers.IsNullOrEmpty(uuid) and host ~= uuid and not Ext.PlayerHasExtender(uuid) then
				OpenMessageBox(uuid, "LeaderLib_MessageBox_ExtenderNotInstalled_Client")
				local text = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
				OpenMessageBox(host, text)
				--local hostText = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
				--GameHelpers.UI.ShowMessageBox(hostText, host, 0, GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageTitle"))
			end
		end
	end
end)

Ext.RegisterOsirisListener("UserEvent", 2, "after", function(id, event)
	if event == "Iterators_LeaderLib_UI_UnlockPartyInventory" then
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

Ext.RegisterOsirisListener("CharacterReservedUserIDChanged", 3, "after", function(char, old, new)
	if Ext.GetGameState() == "Running" and CharacterIsControlled(char) == 1 then
		if not Ext.PlayerHasExtender(char) then
			local host = CharacterGetHostCharacter()
			local username = GetUserName(new) or tostring(new)
			local text = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
			OpenMessageBox(char, "LeaderLib_MessageBox_ExtenderNotInstalled_Client")
			OpenMessageBox(host, text)
		end
	end
end)

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
	Ext.BroadcastMessage("LeaderLib_SyncFeatures", Ext.JsonStringify(Features), nil)
end)