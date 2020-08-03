---@type MessageData
local MessageData = Classes.MessageData

Ext.RegisterNetListener("LeaderLib_EnableFeature", function(channel, id)
	Features[id] = true
end)

Ext.RegisterNetListener("LeaderLib_DisableFeature", function(channel, id)
	Features[id] = false
end)

Ext.RegisterNetListener("LeaderLib_SyncFeatures", function(call, featuresString)
	Ext.Print("[LeaderLib] Synced Features", featuresString)
	Features = Ext.JsonParse(featuresString)
end)

Ext.RegisterNetListener("LeaderLib_SyncScale", function(call, dataStr)
	local data = MessageData:CreateFromString(dataStr)
	if data.Params.UUID and data.Params.Scale ~= nil then
		local character = Ext.GetCharacter(data.Params.UUID)
		if character ~= nil then
			character:SetScale(data.Params.Scale)
		end
	end
end)