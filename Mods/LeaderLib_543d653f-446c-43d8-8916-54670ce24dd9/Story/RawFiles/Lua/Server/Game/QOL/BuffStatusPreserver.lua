if BuffStatusPreserver == nil then
	BuffStatusPreserver = {}
end
BuffStatusPreserver.Enabled = false
BuffStatusPreserver.NextBuffStatus = {}
if Vars.DebugMode then
	--BuffStatusPreserver.Enabled = true
end
local self = BuffStatusPreserver

BuffStatusPreserver.IgnoreStatusTypes = {
	HEAL = true,
	HEAL_SHARING = true,
	HEAL_SHARING_CASTER = true,
	HEALING = true,
	INVISIBLE = true,
	EXTRA_TURN = true,
	GUARDIAN_ANGEL = true,
}

---@param character EsvCharacter
---@param status EsvStatus
function BuffStatusPreserver.PreserveStatus(character, status, skipCheck)
	if status.CurrentLifeTime > 0 and (skipCheck == true or GameHelpers.Status.IsBeneficial(status.StatusId, true, self.IgnoreStatusTypes)) then
		if not PersistentVars.BuffStatuses[character.MyGuid] then
			PersistentVars.BuffStatuses[character.MyGuid] = {}
		end
		local savedStatusData = PersistentVars.BuffStatuses[character.MyGuid]
		savedStatusData[status.StatusId] = status.CurrentLifeTime
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
	if not self.Enabled then return end
	for _,status in pairs(character:GetStatusObjects()) do
		local statusType = GameHelpers.Status.GetStatusType(status.StatusId)
		if statusType == "CONSUME" then
			self.PreserveStatus(character, status)
		end
	end
end

function BuffStatusPreserver.OnLeftCombat(obj, id)
	if not self.Enabled then return end
	if GameHelpers.Character.IsPlayerOrPartyMember(obj) then
		self.PreserveAllStatuses(Ext.GetCharacter(obj))
	end
end

function BuffStatusPreserver.OnEnteredCombat(obj, combatId)
	local uuid = StringHelpers.GetUUID(obj)
	local data = PersistentVars.BuffStatuses[uuid]
	if data then
		local character = Ext.GetCharacter(uuid)
		for id,duration in pairs(data) do
			local status = character:GetStatus(id)
			if status then
				status.CurrentLifeTime = duration
				status.LifeTime = duration
				status.RequestClientSync = true
			end
		end
		PersistentVars.BuffStatuses[uuid] = nil
	end
end

function BuffStatusPreserver.OnStatusApplied(target, status, source, statusType)
	if not self.Enabled then return end
	if CharacterIsInCombat(target) == 0 and GameHelpers.Character.IsPlayerOrPartyMember(target) then
		local data = self.NextBuffStatus[target]
		if data and data[status] then
			self.NextBuffStatus[target][status] = nil
			local character = Ext.GetCharacter(target)
			self.PreserveStatus(character, character:GetStatus(status), true)
		end
	end
end

--Only preserve beneficial statuses applied by skills.
function BuffStatusPreserver.OnSkillUsed(caster, skill, skillType, skillElement)
	if not self.Enabled then return end
	if CharacterIsInCombat(caster) == 0 and GameHelpers.Character.IsPlayerOrPartyMember(caster) then
		caster = StringHelpers.GetUUID(caster)
		---@type StatProperty[]
		local props = Ext.StatGetAttribute(skill, "SkillProperties")
		if props then
			for i,v in pairs(props) do
				if v.Type == "Status" and GameHelpers.Status.IsBeneficial(v.Action, true, self.IgnoreStatusTypes) then
					if self.NextBuffStatus[caster] == nil then
						self.NextBuffStatus[caster] = {}
					end
					self.NextBuffStatus[caster][v.Action] = true
				end
			end
		end
	end
end

Ext.RegisterOsirisListener("ObjectLeftCombat", 2, "after", BuffStatusPreserver.OnLeftCombat)
Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", BuffStatusPreserver.OnEnteredCombat)
Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "after", BuffStatusPreserver.OnSkillUsed)
RegisterStatusTypeListener(Vars.StatusEvent.Applied, "CONSUME", BuffStatusPreserver.OnStatusApplied)

function BuffStatusPreserver:SetEnabled(enabled)
	self.Enabled = enabled
	if not enabled then
		if self.PersistentVars.BuffStatuses then
			for uuid,data in pairs(PersistentVars.BuffStatuses) do
				self.OnEnteredCombat(uuid, 0)
			end
		end
	end
end