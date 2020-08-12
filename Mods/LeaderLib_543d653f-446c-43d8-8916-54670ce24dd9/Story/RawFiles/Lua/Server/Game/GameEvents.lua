local function OnInitialized()
	Vars.Initialized = true

	pcall(LoadGameSettings)

	if Vars.PostLoadEnableLuaListeners then
		print("**********************Enabling Lua listeners in Osiris*****************")
		Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_LuaSkillListeners")
		Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_LuaEventListeners")
		Vars.PostLoadEnableLuaListeners = false
	end

	if Ext.Version() < 50 then
		Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_HitEvents")
	end

	if #Listeners.Initialized > 0 then
		for i,callback in ipairs(Listeners.Initialized) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("[LeaderLib:OnInitialized] Error calling function for 'Initialized':\n", err)
			end
		end
	end

	if Ext.GetGameState() == "Running" then
		SettingsManager.SyncAllSettings()
		IterateUsers("Iterators_LeaderLib_SetClientCharacter")
	end
end

function OnInitialized_CheckGameState()
	if Ext.GetGameState() == "Running" then
		if not Vars.Initialized then
			OnInitialized()
		else
			SettingsManager.SyncAllSettings()
			IterateUsers("Iterators_LeaderLib_SetClientCharacter")
		end
	else
		if Ext.IsDeveloperMode() then
			Ext.PrintWarning("[LeaderLib:OnInitialized_CheckGameState] Game State:", Ext.GetGameState())
		end
		TimerCancel("Timers_LeaderLib_Initialized_CheckGameState")
		TimerLaunch("Timers_LeaderLib_Initialized_CheckGameState", 500)
	end
end

Ext.RegisterListener("GameStateChanged", function(from, to)
	if Ext.IsDeveloperMode() then
		Ext.Print(string.format("[LeaderLib:GameStateChanged] %s => %s", from, to))
	end
	if to == "Running" and Ext.OsirisIsCallable() then
		if not Vars.Initialized then
			OnInitialized()
		else
			SettingsManager.SyncAllSettings()
			IterateUsers("Iterators_LeaderLib_SetClientCharacter")
		end
	end
end)

function OnLeaderLibInitialized()
	if not Vars.Initialized then
		if Ext.GetGameState() == "Running" then
			OnInitialized()
		else
			OnInitialized_CheckGameState()
		end
	end
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