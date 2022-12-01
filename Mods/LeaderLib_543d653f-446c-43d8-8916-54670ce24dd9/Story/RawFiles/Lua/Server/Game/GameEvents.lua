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
		for i,stat in pairs(Ext.Stats.GetStats("StatusData")) do
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
					local statObj = Ext.Stats.Get(stat, nil, false)
					if statObj then
						statObj.LeaveAction = ""
						Ext.Stats.Sync(stat, false)
					end
				end
			end
		end

		fprint(LOGLEVEL.TRACE, "[LeaderLib:OverrideLeaveActionStatuses] Saved statuses to the Vars.LeaveActionData table.")
		--fprint(LOGLEVEL.TRACE, Common.JsonStringify(Vars.LeaveActionData))
	end
end

local _EventsInitializedKeyOrder = {"Region"}

local function InvokeOnInitializedCallbacks(region)
	region = region or ""
	LoadPersistentVars()
	Events.Initialized:Invoke({Region=region})
	Osi.LeaderLib_LoadingDone(region)

	if SceneManager then
		SceneManager.Load()
	end

	if _PV.ScaleOverride then
		for uuid,scale in pairs(_PV.ScaleOverride) do
			if ObjectExists(uuid) == 1 then
				GameHelpers.SetScale(uuid, scale, false)
			end
		end
	end

	if _PV.Summons then
		for uuid,tbl in pairs(_PV.Summons) do
			if ObjectExists(uuid) == 0 then
				_PV.Summons[uuid] = nil
			else
				for i,v in pairs(tbl) do
					if ObjectExists(v) == 0 then
						table.remove(tbl, i)
					end
				end
				if #tbl == 0 then
					_PV.Summons[uuid] = nil
				end
			end
		end
	end
end

local function OnInitialized(region, isRunning)
	Vars.Initialized = true
	GameHelpers.Data.SetGameMode()
	region = region or SharedData.RegionData.Current
	if region == nil and _OSIRIS() then
		local db = Osi.DB_CurrentLevel:Get(nil)
		if db ~= nil then
			region = db[1][1] or ""
		end
	end

	if not Vars.InitializedLeaveActionWorkarounds then
		local status,err = xpcall(OverrideLeaveActionStatuses, debug.traceback)
		if not status then
			Ext.Utils.PrintError(err)
		else
			Vars.InitializedLeaveActionWorkarounds = true
		end
	end

	pcall(function()
		if not LoadGlobalSettings() then
			SaveGlobalSettings()
		end
		local settings = GameSettingsManager.GetSettings()
		if settings.SurfaceSettings.PoisonDoesNotIgnite == true and settings.EnableDeveloperTests == true then
			GameHelpers.Surface.UpdateRules()
		end
	end)

	if Vars.PostLoadEnableLuaListeners or Events.OnSkillState.First ~= nil then
		Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaSkillListeners_Enabled", "LeaderLib")
		Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaEventListeners_Enabled", "LeaderLib")
		Vars.PostLoadEnableLuaListeners = false
	end

	if isRunning == true or Ext.GetGameState() == "Running" then
		InvokeOnInitializedCallbacks(region)
		if GlobalGetFlag("LeaderLib_AutoUnlockInventoryInMultiplayer") == 1
		and GameHelpers.IsLevelType(LEVELTYPE.GAME) then
			Timer.Start("LeaderLib_UnlockCharacterInventories", 10000)
		end
	end
end

Events.RegionChanged:Subscribe(function (e)
	if e.LevelType == LEVELTYPE.GAME and e.State == REGIONSTATE.GAME then
		OnInitialized(e.Region)
	end
end)

Ext.Events.GameStateChanged:Subscribe(function (e)
	if e.ToState == "Running" and e.FromState == "Sync" then
		SettingsManager.SyncAllSettings(nil, true)
	end
end)

local function DebugLoadPersistentVars()
	local varData = GameHelpers.IO.LoadJsonFile("LeaderLib_Debug_PersistentVars.json")
	if varData ~= nil then
		if varData._PrintSettings then
			for k,v in pairs(varData._PrintSettings) do
				Vars.Print[k] = v
			end
			varData._PrintSettings = nil
		end
		if varData._CommandSettings then
			for k,v in pairs(varData._CommandSettings) do
				Vars.Commands[k] = v
			end
			varData._CommandSettings = nil
		end
		for name,data in pairs(varData) do
			if Mods[name] ~= nil and Mods[name].PersistentVars ~= nil then
				for k,v in pairs(data) do
					Mods[name].PersistentVars[k] = v
				end
			end
		end
	end
end

function OnLuaReset()
	Vars.Initialized = false
	local region = Osi.DB_CurrentLevel:Get(nil)[1][1]
	GameHelpers.Data.SetRegion(region)
	GameHelpers.Data.SetGameMode()
	pcall(DebugLoadPersistentVars)
	if IsCharacterCreationLevel(region) == 1 then
		SkipTutorial.Initialize()
	end
	IterateUsers("LeaderLib_StoreUserData")
	Vars.LeaderDebugMode = GameHelpers.IO.LoadFile("LeaderDebug") ~= nil
	Events.LuaReset:Invoke({Region=region})
	GameHelpers.Net.Broadcast("LeaderLib_Client_SyncDebugVars", {PrintSettings=Vars.Print, CommandSettings = Vars.Commands})
	if Debug and Vars.DebugMode then
		Debug.SetCooldownMode(Vars.Commands.CooldownsDisabled == true)
	end
end

Ext.Events.ResetCompleted:Subscribe(function ()
	if _OSIRIS() and GlobalGetFlag("LeaderLib_ResettingLua") == 0 then
		OnLuaReset()
	end
end)