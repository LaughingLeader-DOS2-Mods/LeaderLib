local function OnFeatureEnabled(id)
	if #Listeners.FeatureEnabled > 0 then
		for i,callback in ipairs(Listeners.FeatureEnabled) do
			local status,err = xpcall(callback, debug.traceback, id)
			if not status then
				Ext.PrintError("Error calling function for 'FeatureEnabled':\n", err)
			end
		end
	end
end

local function OnFeatureDisabled(id)
	if #Listeners.FeatureDisabled > 0 then
		for i,callback in ipairs(Listeners.FeatureDisabled) do
			local status,err = xpcall(callback, debug.traceback, id)
			if not status then
				Ext.PrintError("Error calling function for 'FeatureDisabled':\n", err)
			end
		end
	end
end

function EnableFeature(id, val)
	if val == nil then
		val = true
	end
	if Features[id] ~= val then
		Features[id] = val
		OnFeatureEnabled(id)
		if Ext.OsirisIsCallable() then
			pcall(function()
				if Osi.DB_LeaderLib_GameStarted:Get(1) ~= nil then
					Ext.BroadcastMessage("LeaderLib_EnableFeature", id, nil)
				end
			end)
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
		if Ext.OsirisIsCallable() then
			pcall(function()
				if Osi.DB_LeaderLib_GameStarted:Get(1) ~= nil then
					Ext.BroadcastMessage("LeaderLib_DisableFeature", id, nil)
				end
			end)
		end
	end
end