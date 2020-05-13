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

function EnableFeature(id)
	if Features[id] ~= true then
		Features[id] = true
		OnFeatureEnabled(id)
		if Ext.OsirisIsCallable() then
			pcall(function()
				if Osi.DB_LeaderLib_GameStarted(1) ~= nil then
					Ext.BroadcastMessage("LeaderLib_EnableFeature", id, nil)
				end
			end)
		end
	end
end

function DisableFeature(id)
	if Features[id] == true then
		Features[id] = false
		OnFeatureDisabled(id)
		if Ext.OsirisIsCallable() then
			pcall(function()
				if Osi.DB_LeaderLib_GameStarted(1) ~= nil then
					Ext.BroadcastMessage("LeaderLib_DisableFeature", id, nil)
				end
			end)
		end
	end
end