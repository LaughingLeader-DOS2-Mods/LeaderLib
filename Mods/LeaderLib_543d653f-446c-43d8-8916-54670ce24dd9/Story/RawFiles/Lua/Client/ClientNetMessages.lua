---@type MessageData
local MessageData = Classes.MessageData

Ext.RegisterNetListener("LeaderLib_EnableFeature", function(channel, id)
	Features[id] = true
end)

Ext.RegisterNetListener("LeaderLib_DisableFeature", function(channel, id)
	Features[id] = false
end)

Ext.RegisterNetListener("LeaderLib_SyncFeatures", function(call, featuresString)
	Features = Ext.JsonParse(featuresString)
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