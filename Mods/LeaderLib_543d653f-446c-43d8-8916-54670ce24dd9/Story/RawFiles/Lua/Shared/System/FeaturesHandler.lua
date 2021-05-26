local function OnFeatureEnabled(id)
	InvokeListenerCallbacks(Listeners.FeatureEnabled, id)
end

local function OnFeatureDisabled(id)
	InvokeListenerCallbacks(Listeners.FeatureDisabled, id)
end

function EnableFeature(id, val)
	if val == nil then
		val = true
	end
	if Features[id] ~= val then
		Features[id] = val
		OnFeatureEnabled(id)
		if Ext.IsServer() and Ext.GetGameState() == "Running" then
			Ext.BroadcastMessage("LeaderLib_EnableFeature", id, nil)
		end
	end
end

function DisableFeature(id, val)
	if val == nil then
		val = false
	end
	if Features[id] == val then
		Features[id] = val
		OnFeatureDisabled(id)
		if Ext.IsServer() and Ext.GetGameState() == "Running" then
			Ext.BroadcastMessage("LeaderLib_DisableFeature", id, nil)
		end
	end
end