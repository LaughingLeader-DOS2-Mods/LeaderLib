--- Registers a function to call when a specific Lua LeaderLib event fires.
---@param event string OnPrepareHit|OnHit|CharacterSheetPointChanged|CharacterBasePointsChanged|TimerFinished|FeatureEnabled|FeatureDisabled|Initialized|ModuleResume|SessionLoaded
---@param callback function
function RegisterListener(event, callback)
	if Listeners[event] ~= nil then
		table.insert(Listeners[event], callback)
	else
		error("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
	end
end

--- Registers a function to call when a specific Lua LeaderLib event fires for specific mods.
--- Events: Registered|Updated
---@param event string
---@param uuid string
---@param callback function
function RegisterModListener(event, uuid, callback)
	if ModListeners[event] ~= nil then
		ModListeners[event][uuid] = callback
	else
		error("[LeaderLib__Main.lua:RegisterListener] Event ("..tostring(event)..") is not a valid LeaderLib listener event!")
	end
end

--- Registers a function to call when a specific skill's events fire.
---@param skill string
---@param callback function
function RegisterSkillListener(skill, callback)
	if SkillListeners[skill] == nil then
		SkillListeners[skill] = {}
	else
		-- for i,v in pairs(SkillListeners[skill]) do
		-- 	if v == callback then
		-- 		return
		-- 	end
		-- end
	end
	table.insert(SkillListeners[skill], callback)

	if Vars.Initialized then
		if GlobalGetFlag("LeaderLib_LuaSkillListeners_Enabled") == 0 then
			Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_LuaSkillListeners")
			Osi.LeaderLib_ActivateGoal("LeaderLib_19_TS_LuaEventListeners")
		end
	else
		Vars.PostLoadEnableLuaListeners = true
	end
end

--- Removed a function from the listeners table.
---@param skill string
---@param callback function
function RemoveSkillListener(skill, callback)
	if SkillListeners[skill] ~= nil then
		for i,v in pairs(SkillListeners[skill]) do
			if v == callback then
				table.remove(SkillListeners[skill], i)
				break
			end
		end
	end
end

Ext.RegisterListener("SessionLoading", function()
	for i,status in pairs(Ext.GetStatEntries("StatusData")) do
		local statusType = Ext.StatGetAttribute(status, "StatusType")
		if statusType ~= nil and statusType ~= "" then
			local statusTypeTable = StatusTypes[statusType]
			if statusTypeTable ~= nil then
				statusTypeTable[status] = true
				--PrintDebug("[LeaderLib__Main.lua:LeaderLib_Shared_SessionLoading] Added Status ("..status..") to StatusType table ("..statusType..").")
			end
		end
	end

	if Ext.IsServer() then
		if PersistentVars["OriginalSkillTiers"] ~= nil then
			Data.OriginalSkillTiers = PersistentVars["OriginalSkillTiers"]
		end
	end
end)

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
		local total = 0
		for i,stat in pairs(Ext.GetStatEntries("StatusData")) do
			if CanOverrideLeaveActionStatus(stat) then
				local leaveActionSkill = Ext.StatGetAttribute(stat, "LeaveAction")
				if not StringHelpers.IsNullOrEmpty(leaveActionSkill) then
					local statObj = Ext.GetStat(stat)
					statObj.LeaveAction = ""
					Ext.SyncStat(stat, false)
					Vars.LeaveActionData.Statuses[stat] = leaveActionSkill
					Vars.LeaveActionData.Total = Vars.LeaveActionData.Total + 1
				end
			end
		end
		LeaderLib.PrintDebug("[WeaponExpansion:OverrideLeaveActionStatuses] Registered ("..tostring(Vars.LeaveActionData.Total)..") statuses to the Vars.LeaveActionData.Statuses table.")
		LeaderLib.PrintDebug(Ext.JsonStringify(Vars.LeaveActionData))
	end
end

Ext.RegisterListener("SessionLoaded", function()
	OverrideLeaveActionStatuses()
	local count = #TranslatedStringEntries
	if TranslatedStringEntries ~= nil and count > 0 then
		for i,v in pairs(TranslatedStringEntries) do
			if v == nil then
				table.remove(TranslatedStringEntries, i)
			else
				local status,err = xpcall(function()
					v:Update()
				end, debug.traceback)
				if not status then
					print("[LeaderLib:SessionLoaded] Error updating TranslatedString entry:")
					print(err)
				end
			end
		end
		PrintDebug(string.format("[LeaderLib_Shared_SessionLoaded] Updated %s TranslatedString entries.", count))
	end
end)