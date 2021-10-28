local healingStatusToSkills = {}

local function CalculateHealAmount(healValue, level)
	local averageLevelDamage = Game.Math.GetAverageLevelDamage(level)
	return Ext.Round(healValue * averageLevelDamage * Ext.ExtraData.HealToDamageRatio / 100.0)
end

---@param target EsvCharacter
---@param healStatus EsvStatusHeal
---@return EsvStatusHealing[]
local function GetHealingStatusesForHeal(target, healStatus)
	local statuses = {}
	---@type EsvStatusHealing[]
	local activeStatuses = target:GetStatusObjects()
	for _,status in pairs(activeStatuses) do
		if status.StatusType == "HEALING" then
			if status.HealAmount == healStatus.HealAmount and healStatus.HealType == status.HealStat then
				statuses[#statuses+1] = status
			end
		end
	end
	return statuses
end

Ext.RegisterOsirisListener("NRD_OnHeal", 4, "after", function(target, source, amount, handle)
	---@type EsvStatusHeal
	local healStatus = Ext.GetStatus(target, handle)

	local target = GameHelpers.TryGetObject(target)
	local source = GameHelpers.TryGetObject(source)

	local skill = nil
	local statusId = healStatus.StatusId
	---@type EsvStatusHealing
	local healingSourceStatus = nil

	if source then
		---Getting the HEALING status
		if statusId == "HEAL" and healStatus.HealEffect == "Heal" then
			local statuses = GetHealingStatusesForHeal(target, healStatus)
			if #statuses > 0 then
				healingSourceStatus = statuses[1]
				statusId = healingSourceStatus.StatusId
			end
			-- local healingSourceData = PersistentVars.NextGenericHealStatusSource[target.MyGuid]
			-- if healingSourceData and healingSourceData.Source == source.MyGuid then
			-- 	sourceStatusId = healingSourceData.StatusId
			-- end
		end
		local skills = healingStatusToSkills[statusId]
		local lastUsedSkill = PersistentVars.LastUsedHealingSkill[source.MyGuid]
		if skills and skills[lastUsedSkill] == true then
			skill = lastUsedSkill
			Timer.StartObjectTimer("LeaderLib_ClearLastUsedHealingSkill", source.MyGuid, 500)
		end
	end

	InvokeListenerCallbacks(Listeners.OnHeal, target, source, healStatus, amount, handle, skill, healingSourceStatus)
end)

-- RegisterStatusTypeListener("BeforeAttempt", "HEALING", function(target, status, source, statusType)
-- 	local healingEvent = status.HealingEvent
-- 	PersistentVars.NextGenericHealStatusSource[target.MyGuid] = {
-- 		StatusId = status.StatusId,
-- 		Time = Ext.MonotonicTime(),
-- 		Source = source and source.MyGuid or nil
-- 	}
-- end)

-- RegisterStatusListener("Removed", "HEAL", function(target, status, source, statusType)
-- 	PersistentVars.NextGenericHealStatusSource[target] = nil
-- end)

Timer.RegisterListener("LeaderLib_ClearLastUsedHealingSkill", function(timerName, uuid)
	PersistentVars.LastUsedHealingSkill[uuid] = nil
end)

---Register a listener for when NRD_OnHeal is called. LeaderLib gets the EsvStatusHeal and associated game objects, as well as a skill source, if any.
---@param callback OnHealCallback
function RegisterHealListener(callback)
	RegisterListener("OnHeal", callback)
end

RegisterListener("Initialized", function()
	for _,skillId in pairs(Ext.GetStatEntries("SkillData")) do
		local props = GameHelpers.Stats.GetSkillProperties(skillId)
		if props then
			for _,v in pairs(props) do
				if v.Type == "Status" and v.Action ~= "" and not Data.EngineStatus[v.Action] and v.Action ~= "TryKill" then
					local statusType = GameHelpers.Status.GetStatusType(v.Action)
					if statusType == "HEAL" or statusType == "HEALING" then
						if not healingStatusToSkills[v.Action] then
							healingStatusToSkills[v.Action] = {}
						end
						healingStatusToSkills[v.Action][skillId] = true
					end
				end
			end
		end
	end
end)
-- RegisterHealListener(function(target, source, heal, originalAmount, handle, skill, healingSourceStatus)
-- 	print("OnHeal", Lib.serpent.block({
-- 		target = target.DisplayName,
-- 		source = source and source.DisplayName or "nil",
-- 		heal = heal,
-- 		amount = amount,
-- 		skill = skill or "nil",
-- 		healingSourceStatus = healingSourceStatus,
-- 	}))
-- 	if skill == "Target_FirstAidEnemy" then
-- 		--heal.HealAmount = (heal.HealAmount * 1.5)
-- 		heal.HealAmount = 7
-- 	end
-- end)