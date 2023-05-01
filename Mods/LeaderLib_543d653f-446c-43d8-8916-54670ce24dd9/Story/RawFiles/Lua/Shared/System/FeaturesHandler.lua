local isClient = Ext.IsClient()

---@param id string
function EnableFeature(id)
	if Features[id] ~= true then
		Features[id] = true
		Events.FeatureChanged:Invoke({ID=id, Enabled = true})
		if not isClient and _GS() == "Running" then
			GameHelpers.Net.Broadcast("LeaderLib_EnableFeature", id)
		end
	end
end

---@param id string
function DisableFeature(id)
	if Features[id] ~= false then
		Features[id] = false
		Events.FeatureChanged:Invoke({ID=id, Enabled = false})
		if not isClient and _GS() == "Running" then
			GameHelpers.Net.Broadcast("LeaderLib_DisableFeature", id)
		end
	end
end

if not isClient then
	Ext.RegisterNetListener("LeaderLib_EnableFeature", function(channel, id)
		Features[id] = true
		Events.FeatureChanged:Invoke({ID=id, Enabled = true})
	end)
	
	Ext.RegisterNetListener("LeaderLib_DisableFeature", function(channel, id)
		Features[id] = false
		Events.FeatureChanged:Invoke({ID=id, Enabled = false})
	end)
end