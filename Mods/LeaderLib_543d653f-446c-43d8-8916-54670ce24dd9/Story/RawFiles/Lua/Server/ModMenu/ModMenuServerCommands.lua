Ext.RegisterNetListener("LeaderLib_ModMenu_FlagChanged", function(cmd, payload)
	local data = Ext.JsonParse(payload)
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
	local data = Ext.JsonParse(payload)
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
		end
	end
	SaveGlobalSettings()
	SettingsManager.SyncGlobalSettings()
end)

Ext.RegisterNetListener("LeaderLib_ModMenu_CreateSidebarButton", function(cmd, payload)
	local id = tonumber(payload)
	Ext.PostMessageToUser(id, "LeaderLib_ModMenu_CreateMenuButton", "")
end)

Ext.RegisterNetListener("LeaderLib_ModMenu_CreateMenuButtonAfterDelay", function(cmd, payload)
	local id = tonumber(payload)
	if Ext.GetGameState() == "Paused" then
		Ext.PostMessageToUser(id, "LeaderLib_ModMenu_CreateMenuButton", "")
	else
		StartOneshotTimer("Timers_LeaderLib_ModMenu_CreateSidebarButton", 1, function()
			Ext.PostMessageToUser(id, "LeaderLib_ModMenu_CreateMenuButton", "")
		end)
	end
end)

Ext.RegisterNetListener("LeaderLib_ModMenu_SendParseUpdateArrayMethod", function(cmd, payload)
	local id = tonumber(payload)
	Ext.PostMessageToUser(id, "LeaderLib_ModMenu_RunParseUpdateArrayMethod", "")
end)

Ext.RegisterNetListener("LeaderLib_ModMenu_RequestOpen", function(cmd, payload)
	local id = tonumber(payload)
	LoadGlobalSettings()
	SettingsManager.SyncGlobalSettings()
	Ext.PostMessageToUser(id, "LeaderLib_ModMenu_Open", "")
end)