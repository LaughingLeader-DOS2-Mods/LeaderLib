Ext.RegisterNetListener("LeaderLib_ModMenu_FlagChanged", function(cmd, payload)
	local data = Common.JsonParse(payload)
	if data.FlagType == "Global" then
		if data.Enabled then
			Osi.GlobalSetFlag(data.ID)
		else
			Osi.GlobalClearFlag(data.ID)
		end
	elseif data.FlagType == "User" then
		local character = Osi.GetCurrentCharacter(data.User) or Osi.CharacterGetHostCharacter()
		if data.Enabled then
			Osi.UserSetFlag(character, data.ID, 0)
		else
			Osi.UserClearFlag(character, data.ID, 0)
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

			Events.ModSettingsSynced:Invoke({UUID=uuid, Settings=settings})
		end
	end
	SaveGlobalSettings()
	SettingsManager.SyncGlobalSettings()
end)