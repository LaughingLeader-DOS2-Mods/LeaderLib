Vars.HealingStatusToSkills = {}

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

RegisterProtectedOsirisListener("NRD_OnHeal", 4, "after", function(target, source, amount, handle)
	---@type EsvStatusHeal
	local healStatus = Ext.GetStatus(target, handle)

	local target = GameHelpers.TryGetObject(target)
	local source = GameHelpers.TryGetObject(source)

	if source == nil and healStatus then
		--Applied from Statuses.gameScript, source is nil for these.
		--BonusFromAbility uses the target of the heal, so it uses Perseverance on the target.
		if healStatus.StatusId == "POST_PHYS_CONTROL" or healStatus.StatusId == "POST_MAGIC_CONTROL" then
			source = target
		elseif healStatus.StatusSourceHandle then
			source = Ext.GetGameObject(healStatus.StatusSourceHandle)
		end
	end

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
		local skills = Vars.HealingStatusToSkills[statusId]
		local lastUsedSkill = PersistentVars.LastUsedHealingSkill[source.MyGuid]
		if skills and skills[lastUsedSkill] == true then
			skill = lastUsedSkill
			Timer.StartObjectTimer("LeaderLib_ClearLastUsedHealingSkill", source.MyGuid, 500)
		end
	end

	InvokeListenerCallbacks(Listeners.OnHeal, target, source, healStatus, amount, handle, skill, healingSourceStatus)
end)

Timer.RegisterListener("LeaderLib_ClearLastUsedHealingSkill", function(timerName, uuid)
	PersistentVars.LastUsedHealingSkill[uuid] = nil
end)

---Register a listener for when NRD_OnHeal is called. LeaderLib gets the EsvStatusHeal and associated game objects, as well as a skill source, if any.
---@param callback OnHealCallback
function RegisterHealListener(callback)
	RegisterListener("OnHeal", callback)
end

---@private
function ParseHealingStatusToSkills()
	for skillId in GameHelpers.Stats.GetSkills() do
		local props = GameHelpers.Stats.GetSkillProperties(skillId)
		if props then
			for _,v in pairs(props) do
				if v.Type == "Status" and v.Action ~= "" and not Data.EngineStatus[v.Action] and v.Action ~= "TryKill" then
					local statusType = GameHelpers.Status.GetStatusType(v.Action)
					if statusType == "HEAL" or statusType == "HEALING" then
						if not Vars.HealingStatusToSkills[v.Action] then
							Vars.HealingStatusToSkills[v.Action] = {}
						end
						Vars.HealingStatusToSkills[v.Action][skillId] = true
					end
				end
			end
		end
	end
end

Ext.RegisterListener("SessionLoaded", function()
	ParseHealingStatusToSkills()
end)