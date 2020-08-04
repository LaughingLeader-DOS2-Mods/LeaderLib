Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, username, profileId)
	local host = CharacterGetHostCharacter()
	local uuid = GetCurrentCharacter(id)
	if host ~= uuid then
		if uuid ~= nil and not Ext.PlayerHasExtender(uuid) then
			OpenMessageBox(uuid, "LeaderLib_MessageBox_ExtenderNotInstalled_Client")

			local hostText = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
			GameHelpers.UI.ShowMessageBox(hostText, host, 0, GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageTitle"))
		end
	end

	if GlobalGetFlag("LeaderLib_AutoUnlockInventoryInMultiplayer") == 1 then
		IterateUsers("Iterators_LeaderLib_UI_UnlockPartyInventory")
	end

	SettingsManager.SyncAllSettings(id)
end)

Ext.RegisterOsirisListener("UserEvent", 2, "after", function(id, event)
	if event == "Iterators_LeaderLib_UI_UnlockPartyInventory" then
		local players = Ext.JsonStringify(Osi.DB_IsPlayer:Get(nil))
		Ext.PostMessageToUser(id, "LeaderLib_UnlockCharacterInventory", players)
	end
end)

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
	Ext.BroadcastMessage("LeaderLib_SyncFeatures", Ext.JsonStringify(Features), nil)
end)