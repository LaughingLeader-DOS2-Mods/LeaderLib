

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
		Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_LuaSkillListeners")
		Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_LuaEventListeners")
		Vars.PostLoadEnableLuaListeners = false
	end
end