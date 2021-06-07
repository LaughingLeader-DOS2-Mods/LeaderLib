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
				if StringHelpers.IsNullOrWhitespace(leaveActionSkill) then
					local savedSkill = Osi.DB_LeaderLib_LeaveAction_StatusToSkill:Get(stat, nil)
					if savedSkill and #savedSkill > 0 then
						leaveActionSkill = savedSkill[1][2]
						if not StringHelpers.IsNullOrWhitespace(leaveActionSkill) then
							Vars.LeaveActionData.Statuses[stat] = leaveActionSkill
							Vars.LeaveActionData.Total = Vars.LeaveActionData.Total + 1
						end
					end
				else
					Vars.LeaveActionData.Statuses[stat] = leaveActionSkill
					Vars.LeaveActionData.Total = Vars.LeaveActionData.Total + 1
					Osi.DB_LeaderLib_LeaveAction_StatusToSkill:Delete(stat, nil)
					Osi.DB_LeaderLib_LeaveAction_StatusToSkill(stat, leaveActionSkill)
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
	LoadPersistentVars()
	InvokeListenerCallbacks(Listeners.Initialized, region)
	Osi.LeaderLib_LoadingDone(region)

	if SceneManager then
		SceneManager.Load()
	end

	if PersistentVars.ScaleOverride then
		for uuid,scale in pairs(PersistentVars.ScaleOverride) do
			if ObjectExists(uuid) == 1 then
				GameHelpers.SetScale(uuid, scale, false)
			end
		end
	end

	if PersistentVars.Summons then
		for uuid,tbl in pairs(PersistentVars.Summons) do
			if ObjectExists(uuid) == 0 then
				PersistentVars.Summons[uuid] = nil
			else
				for i,v in pairs(tbl) do
					if ObjectExists(v) == 0 then
						table.remove(tbl, i)
					end
				end
				if #tbl == 0 then
					PersistentVars.Summons[uuid] = nil
				end
			end
		end
	end
end

local function OnInitialized(region, isRunning)
	GameHelpers.Data.SetGameMode()
	region = region or SharedData.RegionData.Current
	if region == nil and Ext.OsirisIsCallable() then
		local db = Osi.DB_CurrentLevel:Get(nil)
		if db ~= nil then
			region = db[1][1] or ""
		end
	end

	local status,err = xpcall(OverrideLeaveActionStatuses, debug.traceback)
	if not status then
		Ext.PrintError(err)
	end

	Vars.Initialized = true
	pcall(function()
		if not LoadGlobalSettings() then
			SaveGlobalSettings()
		end
		GameSettingsManager.Load()
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
	if IsCharacterCreationLevel(region) == 1 then
		SkipTutorial.Initialize()
		SkipTutorial.OnLeaderLibInitialized()
	end
	IterateUsers("LeaderLib_StoreUserData")
	local payload = Ext.JsonStringify({Event="LuaReset", Args={region}})
	Ext.BroadcastMessage("LeaderLib_Client_InvokeListeners", payload)
end