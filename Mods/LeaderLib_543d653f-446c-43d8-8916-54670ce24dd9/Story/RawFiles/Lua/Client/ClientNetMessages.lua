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