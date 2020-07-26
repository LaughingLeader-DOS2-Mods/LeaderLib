

function OnInitialized()
	Vars.Initialized = true
	if #Listeners.Initialized > 0 then
		for i,callback in ipairs(Listeners.Initialized) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("[LeaderLib:OnInitialized] Error calling function for 'Initialized':\n", err)
			end
		end
	end

	if Vars.PostLoadEnableLuaListeners then
		print("**********************Enabling Lua listeners in Osiris*****************")
		Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_LuaSkillListeners")
		Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_LuaEventListeners")
		Vars.PostLoadEnableLuaListeners = false
	end

	if Ext.Version() < 50 then
		Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_HitEvents")
	end

	Ext.BroadcastMessage("LeaderLib_SyncFeatures", Ext.JsonStringify(Features), nil)
end

function OnLuaReset()
	OnInitialized()
	if #Listeners.LuaReset > 0 then
		for i,callback in ipairs(Listeners.LuaReset) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("[LeaderLib:OnLuaReset] Error calling function for 'LuaReset':\n", err)
			end
		end
	end
end