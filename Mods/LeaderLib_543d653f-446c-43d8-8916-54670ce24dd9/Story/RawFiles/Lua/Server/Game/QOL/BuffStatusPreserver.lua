if BuffStatusPreserver == nil then
	BuffStatusPreserver = {}
end
BuffStatusPreserver.Enabled = false
if Vars.DebugMode then
	BuffStatusPreserver.Enabled = true
end
local self = BuffStatusPreserver

---@param potion StatEntryPotion
local function IsBuffPotion(potion)
	if potion.IsFood == "Yes" or potion.IsConsumable == "Yes" then
		return false
	end
	return GameHelpers.Status.IsBeneficialPotion(potion)
end

---@param character EsvCharacter
---@param status EsvStatus
function BuffStatusPreserver.PreserveStatus(character, status)
	if status.CurrentLifeTime > 0 and GameHelpers.Status.IsBeneficial(status.StatusId, true) then
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

function BuffStatusPreserver.OnEnteredCombat(obj, id)
	if not self.Enabled then return end
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
		local character = Ext.GetCharacter(target)
		self.PreserveStatus(character, character:GetStatus(status))
	end
end

Ext.RegisterOsirisListener("ObjectLeftCombat", 2, "after", BuffStatusPreserver.OnLeftCombat)
Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", BuffStatusPreserver.OnEnteredCombat)
RegisterStatusTypeListener(Vars.StatusEvent.Applied, "CONSUME", BuffStatusPreserver.OnStatusApplied)