local function CanOverrideLeaveActionStatus(status)
	for i,prefix in pairs(Vars.LeaveActionData.Prefixes) do
		if string.find(status, prefix) then
			return true
		end
	end
	return false
end

-- LeaveAction damage is delayed after its first application in combat, due to a forced half second wait for the status object to be removed.
-- Instead, for WeaponEx statuses, we'll explode it with the extender, but keep LeaveAction in the status for compatibility,
-- so other mods can change the projectiles used.
local function OverrideLeaveActionStatuses()
	if #Vars.LeaveActionData.Prefixes > 0 then
		for i,stat in pairs(Ext.GetStatEntries("StatusData")) do
			if CanOverrideLeaveActionStatus(stat) then
				local leaveActionSkill = Ext.StatGetAttribute(stat, "LeaveAction")
				if leaveActionSkill == "" then
					local savedSkill = Osi.DB_LeaderLib_LeaveAction_StatusToSkill:Get(stat, nil)
					if savedSkill ~= nil and #savedSkill > 0 then
						leaveActionSkill = savedSkill[1][2]
						if leaveActionSkill ~= nil and leaveActionSkill ~= "" then
							Vars.LeaveActionData.Statuses[stat] = leaveActionSkill
							Vars.LeaveActionData.Total = Vars.LeaveActionData.Total + 1
						end
					end
				else
					Vars.LeaveActionData.Statuses[stat] = leaveActionSkill
					Vars.LeaveActionData.Total = Vars.LeaveActionData.Total + 1
					local statObj = Ext.GetStat(stat)
					statObj.LeaveAction = ""
					Ext.SyncStat(stat, false)
				end
			end
		end

		PrintDebug("[LeaderLib:OverrideLeaveActionStatuses] Saved statuses to the Vars.LeaveActionData table.")
		--PrintDebug(Ext.JsonStringify(Vars.LeaveActionData))
	end
end

local function InvokeOnInitializedCallbacks(region)
	region = region or ""
	InvokeListenerCallbacks(Listeners.Initialized, region)
	Osi.LeaderLib_LoadingDone(region)
end

local function OnInitialized(region, isRunning)
	GameHelpers.Data.SetGameMode()

	local status,err = xpcall(OverrideLeaveActionStatuses, debug.traceback)
	if not status then
		Ext.PrintError(err)
	end

	Vars.Initialized = true
	pcall(function()
		if not LoadGlobalSettings() then
			SaveGlobalSettings()
		end
		LoadGameSettings()
		if GameSettings.Settings.SurfaceSettings.PoisonDoesNotIgnite == true and GameSettings.Settings.EnableDeveloperTests == true then
			GameHelpers.Surface.UpdateRules()
		end
	end)

	if Vars.PostLoadEnableLuaListeners or TotalSkillListeners > 0 then
		print("**********************Enabling Lua listeners in Osiris*****************")
		Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaSkillListeners_Enabled", "LeaderLib")
		Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaEventListeners_Enabled", "LeaderLib")
		Vars.PostLoadEnableLuaListeners = false
	end

	if isRunning == true or Ext.GetGameState() == "Running" then
		if region == nil then
			local db = Osi.DB_CurrentLevel:Get(nil)
			if db ~= nil then
				region = db[1][1] or ""
			end
		end
		InvokeOnInitializedCallbacks(region)
		SettingsManager.SyncAllSettings()
		if GlobalGetFlag("LeaderLib_AutoUnlockInventoryInMultiplayer") == 1 then
			IterateUsers("Iterators_LeaderLib_UI_UnlockPartyInventory")
		end
	end
end

function OnInitialized_CheckGameState(region)
	if Ext.GetGameState() == "Running" then
		if not Vars.Initialized then
			OnInitialized(region, true)
		else
			SettingsManager.SyncAllSettings()
			InvokeOnInitializedCallbacks(region)
		end
	else
		if Vars.DebugMode then
			Ext.PrintWarning("[LeaderLib:OnInitialized_CheckGameState] Game State:", Ext.GetGameState())
		end
		TimerCancel("Timers_LeaderLib_Initialized_CheckGameState")
		TimerLaunch("Timers_LeaderLib_Initialized_CheckGameState", 500)
	end
end

Ext.RegisterListener("GameStateChanged", function(from, to)
	if Vars.DebugMode then
		Ext.Print(string.format("[LeaderLib:GameStateChanged] %s => %s", from, to))
	end
	if to == "Running" and Ext.OsirisIsCallable() then
		if not Vars.Initialized then
			OnInitialized("", true)
		elseif from ~= "Paused" then
			SettingsManager.SyncAllSettings()
		end
	end
end)

function OnLeaderLibInitialized(region)
	if not Vars.Initialized then
		if Ext.GetGameState() == "Running" then
			OnInitialized(region, true)
		else
			OnInitialized_CheckGameState(region)
		end
	elseif Ext.GetGameState() == "Running" then
		InvokeOnInitializedCallbacks(region)
	end
end

function OnLuaReset()
	pcall(function()
		local fileStr = Ext.LoadFile("LeaderLib_Debug_PersistentVars.json")
		if fileStr ~= nil then
			local varData = Common.JsonParse(fileStr)
			if varData ~= nil then
				for name,data in pairs(varData) do
					if Mods[name] ~= nil and Mods[name].PersistentVars ~= nil then
						for k,v in pairs(data) do
							Mods[name].PersistentVars[k] = v
						end
					end
				end
			end
		end
	end)
	local region = Osi.DB_CurrentLevel:Get(nil)[1][1]
	GameHelpers.Data.SetRegion(region)
	GameHelpers.Data.SetGameMode()
	OnInitialized(region, true)
	InvokeListenerCallbacks(Listeners.LuaReset, region)
	IterateUsers("LeaderLib_StoreUserData")
	Ext.BroadcastMessage("LeaderLib_Client_InvokeLuaResetListeners", region)
end