local function OnFeatureEnabled(id)
	InvokeListenerCallbacks(Listeners.FeatureEnabled, id)
end

local function OnFeatureDisabled(id)
	InvokeListenerCallbacks(Listeners.FeatureDisabled, id)
end

---@param id string
function EnableFeature(id)
	if Features[id] ~= true then
		Features[id] = true
		OnFeatureEnabled(id)
		if Ext.IsServer() and Ext.GetGameState() == "Running" then
			GameHelpers.Net.Broadcast("LeaderLib_EnableFeature", id)
		end
	end
end

---@param id string
function DisableFeature(id)
	if Features[id] ~= false then
		Features[id] = false
		OnFeatureDisabled(id)
		if Ext.IsServer() and Ext.GetGameState() == "Running" then
			GameHelpers.Net.Broadcast("LeaderLib_DisableFeature", id)
		end
	end
end