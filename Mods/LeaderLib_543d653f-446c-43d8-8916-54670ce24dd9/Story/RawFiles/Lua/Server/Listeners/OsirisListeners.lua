Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, username, profileId)
	local host = CharacterGetHostCharacter()
	local uuid = GetCurrentCharacter(id)
	if uuid ~= nil then
		if Ext.GetGameState() == "Running" then
			SyncClientData(uuid, id)
			if GlobalGetFlag("LeaderLib_AutoUnlockInventoryInMultiplayer") == 1 then
				IterateUsers("Iterators_LeaderLib_UI_UnlockPartyInventory")
			end
			SettingsManager.SyncAllSettings(id)
		end

		if not StringHelpers.IsNullOrEmpty(uuid) and host ~= uuid and not Ext.PlayerHasExtender(uuid) then
			OpenMessageBox(uuid, "LeaderLib_MessageBox_ExtenderNotInstalled_Client")
			local text = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
			OpenMessageBox(host, text)
			--local hostText = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
			--GameHelpers.UI.ShowMessageBox(hostText, host, 0, GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageTitle"))
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
	elseif event == "Iterators_LeaderLib_SetClientCharacter" then
		local uuid = GetCurrentCharacter(id) or CharacterGetHostCharacter()
		SyncClientData(StringHelpers.GetUUID(uuid), id)
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
		else
			SyncClientData(StringHelpers.GetUUID(char))
		end
	end
end)

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
	Ext.BroadcastMessage("LeaderLib_SyncFeatures", Ext.JsonStringify(Features), nil)
end)

Ext.RegisterOsirisListener("ObjectTurnStarted", 2, "after", function(char, combatid)
	local id = CharacterGetReservedUserID(char)
	if id ~= nil then
		-- For hopefully making sure the delay turn listener stays accurate
		SyncClientData(StringHelpers.GetUUID(char), id)
	end
end)