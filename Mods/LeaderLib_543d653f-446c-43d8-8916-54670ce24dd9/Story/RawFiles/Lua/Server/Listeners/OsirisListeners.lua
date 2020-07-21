if Ext.Version() >= 50 then
	Ext.RegisterOsirisListener("UserConnected", 3, "after", function(id, username, profileId)
		local host = CharacterGetHostCharacter()
		local uuid = GetCurrentCharacter(id)
		if host ~= uuid then
			print("UserConnected", id, username, profileId, uuid)
			if uuid ~= nil and not Ext.PlayerHasExtender(uuid) then
				OpenMessageBox(uuid, "LeaderLib_MessageBox_ExtenderNotInstalled_Client")

				local hostText = GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageText"):gsub("%[1%]", username)
				GameHelpers.ShowMessageBox(hostText, host, 0, GameHelpers.GetStringKeyText("LeaderLib_MessageBox_ExtenderNotInstalled_HostMessageTitle"))
			end
		end
	end)
	-- Ext.RegisterOsirisListener("CharacterReservedUserIDChanged", 3, "after", function(uuid, old, userId)
	-- 	print("CharacterReservedUserIDChanged", uuid, old, userId, Ext.PlayerHasExtender(uuid))
	-- 	if uuid ~= nil and not Ext.PlayerHasExtender(uuid) then
	-- 		OpenMessageBox(uuid, "LeaderLib_MessageBox_ExtenderNotInstalled")
	-- 	end
	-- end)
end