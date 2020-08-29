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

local function OnInitialized()
	local status,err = xpcall(OverrideLeaveActionStatuses, debug.traceback)
	if not status then
		print(err)
	end
	print("OnInitialized", Ext.JsonStringify(Vars.LeaveActionData))
	Vars.Initialized = true
	pcall(LoadGameSettings)

	if Vars.PostLoadEnableLuaListeners or TotalSkillListeners > 0 then
		print("**********************Enabling Lua listeners in Osiris*****************")
		Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaSkillListeners_Enabled", "LeaderLib")
		Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaEventListeners_Enabled", "LeaderLib")
		Vars.PostLoadEnableLuaListeners = false
	end

	if Ext.Version() < 50 then
		Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_HitEvents")
	end

	if #Listeners.Initialized > 0 then
		for i,callback in pairs(Listeners.Initialized) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("[LeaderLib:OnInitialized] Error calling function for 'Initialized':\n", err)
			end
		end
	end

	if Ext.GetGameState() == "Running" then
		SettingsManager.SyncAllSettings()
		IterateUsers("Iterators_LeaderLib_SetClientCharacter")
		if GlobalGetFlag("LeaderLib_AutoUnlockInventoryInMultiplayer") == 1 then
			IterateUsers("Iterators_LeaderLib_UI_UnlockPartyInventory")
		end
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
	print("OnLuaReset")
	OnInitialized()
	if #Listeners.LuaReset > 0 then
		for i,callback in pairs(Listeners.LuaReset) do
			local status,err = xpcall(callback, debug.traceback)
			if not status then
				Ext.PrintError("[LeaderLib:OnLuaReset] Error calling function for 'LuaReset':\n", err)
			end
		end
	end
end