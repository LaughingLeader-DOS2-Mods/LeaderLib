if BuffStatusPreserver == nil then
	BuffStatusPreserver = {}
end
BuffStatusPreserver.Enabled = function()
	local settings = SettingsManager.GetMod(ModuleUUID, false)
	if settings then
		return settings.Global:FlagEquals("LeaderLib_BuffStatusPreserverEnabled", true)
	end
	return false
end
BuffStatusPreserver.NextBuffStatus = {}

BuffStatusPreserver.IgnoredStatusTypes = {
	HEAL = true,
	HEAL_SHARING = true,
	HEAL_SHARING_CASTER = true,
	HEALING = true,
	INVISIBLE = true,
	EXTRA_TURN = true,
	GUARDIAN_ANGEL = true,
}

BuffStatusPreserver.IgnoredStatuses = {
	APOTHEOSIS = true,
	ASCENDANT = true,
	DOUBLE_DAMAGE = true,
	SOURCE_REPLENISH = true,
	SHED_SKIN = true,
	QUEST = function(id) return string.find(string.lower(id), "quest") ~= nil end,
	STORY = function(id) return string.find(string.lower(id), "story") ~= nil end,
}

local function IgnoreStatus(id)
	local ignored = BuffStatusPreserver.IgnoredStatuses
	if ignored ~= nil then
		if ignored == true or (type(ignored) == "function" and ignored(id))then
			return true
		end
	end
	return false
end

---@param character EsvCharacter
---@param status EsvStatus
function BuffStatusPreserver.PreserveStatus(character, status, skipCheck)
	if not IgnoreStatus(status.StatusId)
	and status.CurrentLifeTime > 0 
	and (skipCheck == true or GameHelpers.Status.IsBeneficial(status.StatusId, true, BuffStatusPreserver.IgnoredStatusTypes)) then
		if not PersistentVars.BuffStatuses[character.MyGuid] then
			PersistentVars.BuffStatuses[character.MyGuid] = {}
		end
		local savedStatusData = PersistentVars.BuffStatuses[character.MyGuid]
		savedStatusData[status.StatusId] = math.ceil(status.CurrentLifeTime)
		status.CurrentLifeTime = -1.0
		status.LifeTime = -1.0
		status.RequestClientSync = true
		if Vars.DebugMode then
			fprint(LOGLEVEL.DEFAULT, "[BuffStatusPreserver.PreserveStatus] Preserving status(%q). Saved Duration (%s)", status.StatusId, savedStatusData[status.StatusId])
		end
	end
end

---@param character EsvCharacter
function BuffStatusPreserver.PreserveAllStatuses(character)
	if not BuffStatusPreserver.Enabled() then return end
	for _,status in pairs(character:GetStatusObjects()) do
		local statusType = GameHelpers.Status.GetStatusType(status.StatusId)
		if statusType == "CONSUME" then
			BuffStatusPreserver.PreserveStatus(character, status)
		end
	end
end

function BuffStatusPreserver.OnLeftCombat(obj, id)
	if not BuffStatusPreserver.Enabled() then return end
	if GameHelpers.Character.IsPlayerOrPartyMember(obj) then
		local player = GameHelpers.GetCharacter(obj)
		if player then
			BuffStatusPreserver.PreserveAllStatuses(player)
		end
	end
end

function BuffStatusPreserver.OnEnteredCombat(obj, combatId)
	local uuid = StringHelpers.GetUUID(obj)
	local data = PersistentVars.BuffStatuses[uuid]
	if data then
		local character = GameHelpers.GetCharacter(uuid)
		if character then
			for id,duration in pairs(data) do
				local status = character:GetStatus(id)
				if status then
					status.CurrentLifeTime = duration
					status.LifeTime = duration
					status.RequestClientSync = true
				end
			end
		end
		PersistentVars.BuffStatuses[uuid] = nil
	end
end

---@param target EsvCharacter|EsvItem
---@param status EsvStatus
---@param source ?EsvCharacter|EsvItem
---@param statusType string
---@param statusEvent StatusEventID
function BuffStatusPreserver.OnStatusApplied(target, status, source, statusType, statusEvent)
	if not BuffStatusPreserver.Enabled() then return end
	if GameHelpers.Ext.ObjectIsCharacter(target)
	and not GameHelpers.Character.IsInCombat(target)
	and GameHelpers.Character.IsPlayerOrPartyMember(target) then
		local data = BuffStatusPreserver.NextBuffStatus[target.MyGuid]
		if data and data[status.StatusId] then
			BuffStatusPreserver.NextBuffStatus[target.MyGuid][status] = nil
			BuffStatusPreserver.PreserveStatus(target, status, true)
		end
	end
end

--Only preserve beneficial statuses applied by skills.
function BuffStatusPreserver.OnSkillUsed(caster, skill, skillType, skillElement)
	if not BuffStatusPreserver.Enabled() then return end
	if CharacterIsInCombat(caster) == 0 and GameHelpers.Character.IsPlayerOrPartyMember(caster) then
		caster = StringHelpers.GetUUID(caster)
		---@type StatProperty[]
		local props = GameHelpers.Stats.GetSkillProperties(skill)
		if props then
			for i,v in pairs(props) do
				if v.Type == "Status"
				and not IgnoreStatus(v.Action)
				and GameHelpers.Status.IsBeneficial(v.Action, true, BuffStatusPreserver.IgnoredStatusTypes) then
					if BuffStatusPreserver.NextBuffStatus[caster] == nil then
						BuffStatusPreserver.NextBuffStatus[caster] = {}
					end
					BuffStatusPreserver.NextBuffStatus[caster][v.Action] = true
				end
			end
		end
	end
end

--Ext.RegisterOsirisListener("ObjectLeftCombat", 2, "after", BuffStatusPreserver.OnLeftCombat)
Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", BuffStatusPreserver.OnEnteredCombat)
Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "after", BuffStatusPreserver.OnSkillUsed)
StatusManager.Register.Type.Applied("CONSUME", BuffStatusPreserver.OnStatusApplied)

---@private
function BuffStatusPreserver.Disable()
	if PersistentVars.BuffStatuses then
		for uuid,data in pairs(PersistentVars.BuffStatuses) do
			BuffStatusPreserver.OnEnteredCombat(uuid, 0)
		end
	end
end