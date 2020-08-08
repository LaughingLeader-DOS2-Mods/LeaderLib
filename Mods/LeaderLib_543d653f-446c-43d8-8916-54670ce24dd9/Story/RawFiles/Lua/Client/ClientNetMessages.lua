---@type MessageData
local MessageData = Classes.MessageData

Ext.RegisterNetListener("LeaderLib_EnableFeature", function(channel, id)
	Features[id] = true
end)

Ext.RegisterNetListener("LeaderLib_DisableFeature", function(channel, id)
	Features[id] = false
end)

Ext.RegisterNetListener("LeaderLib_SyncFeatures", function(call, dataString)
	Features = Ext.JsonParse(dataString)
end)

Ext.RegisterNetListener("LeaderLib_SyncGlobalSettings", function(call, dataString)
	GlobalSettings = Ext.JsonParse(dataString)
end)

Ext.RegisterNetListener("LeaderLib_SyncAllSettings", function(call, dataString)
	local data = Ext.JsonParse(dataString)
	if data.Features ~= nil then Features = data.Features end
	if data.GlobalSettings ~= nil then GlobalSettings = data.GlobalSettings end
	if data.GameSettings ~= nil then GameSettings = data.GameSettings end
	if #Listeners.ModSettingsLoaded > 0 then
		for i,callback in ipairs(Listeners.ModSettingsLoaded) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("[LeaderLib_SyncAllSettings] Error invoking callback for ModSettingsLoaded:")
				Ext.PrintError(err)
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_SyncScale", function(call, dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data.Params.UUID and data.Params.Scale ~= nil then
		if data.Params.IsItem == true then
			local item = Ext.GetItem(data.Params.UUID)
			if item ~= nil then
				item:SetScale(data.Params.Scale)
			end
		else
			local character = Ext.GetCharacter(data.Params.UUID)
			if character ~= nil then
				character:SetScale(data.Params.Scale)
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_SetClientCharacter", function(call, uuid)
	UI.ClientCharacter = uuid
end)