
local function Net_EnableFeature(channel, id)
	Features[id] = true
end

Ext.RegisterNetListener("LeaderLib_EnableFeature", Net_EnableFeature)

local function Net_DisableFeature(channel, id)
	Features[id] = false
end

Ext.RegisterNetListener("LeaderLib_DisableFeature", Net_DisableFeature)