Ext.RegisterNetListener("LeaderLib_ModMenu_FlagChanged", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data.FlagType == "Global" then
		if data.Enabled then
			GlobalSetFlag(data.ID)
		else
			GlobalClearFlag(data.ID)
		end
	elseif data.FlagType == "User" then
		local character = GetCurrentCharacter(data.User) or CharacterGetHostCharacter()
		if data.Enabled then
			UserSetFlag(character, data.ID, 0)
		else
			UserClearFlag(character, data.ID, 0)
		end
	end
	SaveGlobalSettings()
end)

Ext.RegisterNetListener("LeaderLib_ModMenu_SaveChanges", function(cmd, payload)
	local data = Common.JsonParse(payload)
	for uuid,changes in pairs(data) do
		local settings = GlobalSettings.Mods[uuid]
		if settings ~= nil then
			for i,v in pairs(changes) do
				if v.Type == "FlagData" then
					settings:SetFlag(v.ID, v.Value)
				elseif v.Type == "VariableData" then
					settings:SetVariable(v.ID, v.Value)
				end
			end
			settings:ApplyToGame()

			InvokeListenerCallbacks(Listeners.ModSettingsSynced, uuid, settings)
		end
	end
	SaveGlobalSettings()
	SettingsManager.SyncGlobalSettings()
end)

Ext.RegisterNetListener("LeaderLib_ModMenu_CreateSidebarButton", function(cmd, payload)
	local id = tonumber(payload)
	GameHelpers.Net.PostToUser(id, "LeaderLib_ModMenu_CreateMenuButton", "")
end)

Ext.RegisterNetListener("LeaderLib_ModMenu_RequestOpen", function(cmd, payload)
	local id = tonumber(payload)
	LoadGlobalSettings()
	SettingsManager.SyncGlobalSettings()
	GameHelpers.Net.PostToUser(id, "LeaderLib_ModMenu_Open", "")
end)