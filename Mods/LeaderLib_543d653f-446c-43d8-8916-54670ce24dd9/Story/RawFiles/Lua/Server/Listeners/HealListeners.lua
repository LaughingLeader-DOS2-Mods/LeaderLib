Vars.HealingStatusToSkills = {}
Vars.HealingStatusHealEffectIdToStatus = {}

local function CalculateHealAmount(healValue, level)
	local averageLevelDamage = Game.Math.GetAverageLevelDamage(level)
	return Ext.Utils.Round(healValue * averageLevelDamage * Ext.ExtraData.HealToDamageRatio / 100.0)
end

---@param target EsvCharacter
---@param healStatus EsvStatusHeal
---@return EsvStatusHealing[]
local function GetHealingStatusesForHeal(target, healStatus)
	local statuses = {}
	local healingStatusId = Vars.HealingStatusHealEffectIdToStatus[healStatus.HealEffectId]
	for _,status in pairs(target:GetStatusObjects()) do
		if status.StatusType == "HEALING" then
			---@cast status EsvStatusHealing
			if status.StatusId == healingStatusId then
				statuses[#statuses+1] = status
			else
				if healStatus.HealType == status.HealStat and status.HealAmount == healStatus.HealAmount then
					statuses[#statuses+1] = status
				end
			end
		end
	end
	return statuses
end

Ext.Events.StatusGetEnterChance:Subscribe(function(e)
	local chance = e.EnterChance or 100
	if e.IsEnterCheck and chance <= 0 then
		return
	end
	if e.Status.StatusType == "HEAL" or e.Status.StatusType == "HEALING" then
		local target = GameHelpers.GetObjectFromHandle(e.Status.TargetHandle, "EsvCharacter")
		if not target then
			return
		end
		local statusId = e.Status.StatusId
		local statusType = e.Status.StatusType
		local source = GameHelpers.GetObjectFromHandle(e.Status.StatusSourceHandle, "EsvCharacter")
		if source == nil then
			--Applied from Statuses.gameScript, source is nil for these.
			--BonusFromAbility uses the target of the heal, so it uses Perseverance on the target.
			if statusId == "POST_PHYS_CONTROL" or statusId == "POST_MAGIC_CONTROL" then
				source = target
			end
		end

		local skill = nil

		if source then
			local skills = Vars.HealingStatusToSkills[statusId]
			local lastUsedSkill = _PV.LastUsedHealingSkill[source.MyGuid]
			if skills and skills[lastUsedSkill] == true then
				skill = lastUsedSkill
				Timer.StartObjectTimer("LeaderLib_ClearLastUsedHealingSkill", source.MyGuid, 500)
			end
		end

		local healType = ""
		local healEffect = e.Status.HealEffect

		if statusType == "HEAL" then
			healType = e.Status.HealType
		elseif statusType == "HEALING" then
			healType = e.Status.HealStat
		end

		Events.OnHeal:Invoke({
			Target=target,
			TargetGUID=target.MyGuid,
			Source=source,
			SourceGUID=GameHelpers.GetUUID(source),
			Status=e.Status,
			StatusId=statusId,
			StatusType = statusType,
			HealStat = healType,
			HealEffect = healEffect,
			Amount=e.Status.HealAmount,
			Skill=skill,
		})
	end
end, {Priority=0})

--[[ RegisterProtectedOsirisListener("NRD_OnHeal", 4, "after", function(target, source, amount, handle)
	if ObjectExists(target) == 0 then
		return
	end
	---@type EsvStatusHeal
	local healStatus = Ext.Entity.GetStatus(target, handle)

	local target = GameHelpers.TryGetObject(target)
	local source = GameHelpers.TryGetObject(source)

	if source == nil and healStatus then
		--Applied from Statuses.gameScript, source is nil for these.
		--BonusFromAbility uses the target of the heal, so it uses Perseverance on the target.
		if healStatus.StatusId == "POST_PHYS_CONTROL" or healStatus.StatusId == "POST_MAGIC_CONTROL" then
			source = target
		elseif healStatus.StatusSourceHandle then
			source = GameHelpers.TryGetObject(healStatus.StatusSourceHandle)
		end
	end

	local skill = nil
	local statusId = healStatus.StatusId
	---@type EsvStatusHealing
	local healingSourceStatus = nil
	local healingSourceStatusId = nil

	if source then
		---Getting the HEALING status
		if statusId == "HEAL" and (healStatus.HealEffect == "Heal" or healStatus.HealEffect == "Necromantic") then
			local statuses = GetHealingStatusesForHeal(target, healStatus)
			if #statuses > 0 then
				healingSourceStatus = statuses[1]
				statusId = healingSourceStatus.StatusId
				healingSourceStatusId = statusId
			end
			-- local healingSourceData = PersistentVars.NextGenericHealStatusSource[target.MyGuid]
			-- if healingSourceData and healingSourceData.Source == source.MyGuid then
			-- 	sourceStatusId = healingSourceData.StatusId
			-- end
		end
		local skills = Vars.HealingStatusToSkills[statusId]
		local lastUsedSkill = _PV.LastUsedHealingSkill[source.MyGuid]
		if skills and skills[lastUsedSkill] == true then
			skill = lastUsedSkill
			Timer.StartObjectTimer("LeaderLib_ClearLastUsedHealingSkill", source.MyGuid, 500)
		end
	end

	Events.OnHeal:Invoke({
		Target=target,
		TargetGUID=target.MyGuid,
		Source=source,
		SourceGUID=GameHelpers.GetUUID(source),
		Heal=healStatus,
		StatusId=healStatus.StatusId,
		OriginalAmount=amount,
		Handle=handle,
		Skill=skill,
		HealingSourceStatus=healingSourceStatus,
		HealingStatusId=healingSourceStatusId,
	})
end) ]]

Timer.Subscribe("LeaderLib_ClearLastUsedHealingSkill", function(e)
	_PV.LastUsedHealingSkill[e.Data.UUID] = nil
end)

---@private
function ParseHealingStatusToSkills()
	for skillId in GameHelpers.Stats.GetSkills() do
		local props = GameHelpers.Stats.GetSkillProperties(skillId)
		if props then
			for _,v in pairs(props) do
				if v.Type == "Status"
				and not StringHelpers.IsNullOrWhitespace(v.Action)
				and not Data.EngineStatus[v.Action]
				and v.Action ~= "TryKill"
				and GameHelpers.Stats.Exists(v.Action, "StatusData")
				then
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
	local uniqueHealEffectID = {}
	for status in GameHelpers.Stats.GetStatuses(true) do
		if status.StatusType == "HEALING" then
			if not StringHelpers.IsNullOrEmpty(status.HealEffectId) then
				if uniqueHealEffectID[status.HealEffectId] ~= nil then
					uniqueHealEffectID[status.HealEffectId] = false
				else
					uniqueHealEffectID[status.HealEffectId] = status.Name
				end
			end
		elseif status.StatusType == "HEAL" and uniqueHealEffectID[status.HealEffectId] ~= nil then
			uniqueHealEffectID[status.HealEffectId] = false
		end
	end
	for id,b in pairs(uniqueHealEffectID) do
		if b ~= false then
			Vars.HealingStatusHealEffectIdToStatus[id] = b
		end
	end
	Ext.Dump({"Vars.HealingStatusHealEffectIdToStatus", Vars.HealingStatusHealEffectIdToStatus})
end

Ext.Events.SessionLoaded:Subscribe(function()
	ParseHealingStatusToSkills()
end)