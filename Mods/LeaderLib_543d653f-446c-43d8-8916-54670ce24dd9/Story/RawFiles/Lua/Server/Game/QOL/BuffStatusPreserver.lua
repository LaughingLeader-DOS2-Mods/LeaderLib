if BuffStatusPreserver == nil then
	BuffStatusPreserver = {}
end

local _testingEnabled = false

BuffStatusPreserver.Enabled = function()
	if _testingEnabled then
		return true
	end
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
	if skipCheck or (not IgnoreStatus(status.StatusId)
	and status.CurrentLifeTime > 0
	and GameHelpers.Status.IsBeneficial(status.StatusId, true, BuffStatusPreserver.IgnoredStatusTypes)) then
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
---@param statusId string|string[]
function BuffStatusPreserver.ClearSavedStatus(character, statusId)
	if type(statusId) == "table" then
		for _,v in pairs(statusId) do	
			BuffStatusPreserver.ClearSavedStatus(character, v)
		end
	else
		local GUID = GameHelpers.GetUUID(character)
		if GUID and PersistentVars.BuffStatuses[GUID] then
			PersistentVars.BuffStatuses[GUID][statusId] = nil
		end
	end
end

---@param character EsvCharacter
function BuffStatusPreserver.PreserveAllStatuses(character)
	if not BuffStatusPreserver.Enabled() then return end
	local character = GameHelpers.GetCharacter(character)
	if not character then
		return false
	end
	for _,status in pairs(character:GetStatusObjects()) do
		local statusType = GameHelpers.Status.GetStatusType(status.StatusId)
		if statusType == "CONSUME" then
			BuffStatusPreserver.PreserveStatus(character, status)
		end
	end
end

---@param obj UUID
---@param combatId integer
function BuffStatusPreserver.OnLeftCombat(obj, combatId)
	if not BuffStatusPreserver.Enabled() then return end
	if GameHelpers.ObjectExists(obj) and GameHelpers.Character.IsPlayerOrPartyMember(obj) then
		local player = GameHelpers.GetCharacter(obj)
		if player then
			BuffStatusPreserver.PreserveAllStatuses(player)
		end
	end
end

---@param obj UUID
---@param combatId integer
function BuffStatusPreserver.OnEnteredCombat(obj, combatId)
	local GUID = GameHelpers.GetUUID(obj)
	local data = PersistentVars.BuffStatuses[GUID]
	if data then
		local character = GameHelpers.GetCharacter(GUID)
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
		PersistentVars.BuffStatuses[GUID] = nil
	end
end

---@param target EsvCharacter|EsvItem
---@param status EsvStatus
---@param source EsvCharacter|EsvItem|nil Optional source of the status.
---@param statusType string
---@param statusEvent StatusEventID
function BuffStatusPreserver.OnStatusApplied(target, status, source, statusType, statusEvent)
	if not BuffStatusPreserver.Enabled() then return end
	if GameHelpers.Ext.ObjectIsCharacter(target)
	and not GameHelpers.Character.IsInCombat(target)
	and GameHelpers.Character.IsPlayerOrPartyMember(target) then
		local GUID = GameHelpers.GetUUID(target)
		if GUID then
			local data = BuffStatusPreserver.NextBuffStatus[GUID]
			if data and data[status.StatusId] then
				BuffStatusPreserver.NextBuffStatus[GUID][status] = nil
				BuffStatusPreserver.PreserveStatus(target, status, true)
			end
		end
	end
end

--Only preserve beneficial statuses applied by skills.
function BuffStatusPreserver.OnSkillUsed(caster, skill, skillType, skillElement)
	if not BuffStatusPreserver.Enabled() then return end
	local GUID = GameHelpers.GetUUID(caster)
	if GUID and not GameHelpers.Character.IsInCombat(GUID) and GameHelpers.Character.IsPlayerOrPartyMember(GUID) then
		---@type StatProperty[]
		local props = GameHelpers.Stats.GetSkillProperties(skill)
		if props then
			for i,v in pairs(props) do
				if v.Type == "Status"
				and not IgnoreStatus(v.Action)
				and GameHelpers.Status.IsBeneficial(v.Action, true, BuffStatusPreserver.IgnoredStatusTypes) then
					if BuffStatusPreserver.NextBuffStatus[GUID] == nil then
						BuffStatusPreserver.NextBuffStatus[GUID] = {}
					end
					BuffStatusPreserver.NextBuffStatus[GUID][v.Action] = true
				end
			end
		end
	end
	if _testingEnabled then
		Testing.EmitSignal("BUFFSTATUSPRESERVER_SkillUsed")
	end
end

--Ext.RegisterOsirisListener("ObjectLeftCombat", 2, "after", BuffStatusPreserver.OnLeftCombat)
Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", BuffStatusPreserver.OnEnteredCombat)
Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "after", BuffStatusPreserver.OnSkillUsed)
StatusManager.Register.Type.Applied("CONSUME", BuffStatusPreserver.OnStatusApplied)

---@private
function BuffStatusPreserver.Disable()
	if PersistentVars.BuffStatuses then
		for GUID,data in pairs(PersistentVars.BuffStatuses) do
			if GameHelpers.ObjectExists(GUID) then
				BuffStatusPreserver.OnEnteredCombat(GUID, 0)
			else
				PersistentVars.BuffStatuses[GUID] = nil
			end
		end
	end
end

if Vars.DebugMode then
	local buffTest = Classes.LuaTest.Create("buffstatuspreserver", {
		---@param self LuaTest
		function(self)
			local host = CharacterGetHostCharacter()
			_testingEnabled = true
			self.Cleanup = function ()
				GameHelpers.Status.Remove(host, "FORTIFIED")
				BuffStatusPreserver.ClearSavedStatus(host, "FORTIFIED")
				_testingEnabled = false
			end
			CharacterUseSkill(host, "Target_EnemyFortify", host, 1, 1, 1)
			self:WaitForSignal("BUFFSTATUSPRESERVER_SkillUsed", 10000)
			self:AssertGotSignal("BUFFSTATUSPRESERVER_SkillUsed")
			self:Wait(5000)
			local duration = GameHelpers.Status.GetDuration(host, "FORTIFIED")
			self:AssertEquals(duration == -1, true, string.format("Failed to make FORTIFIED permanent (%s)", duration))
			return true
		end,
		---@param self LuaTest
		function(self)
			local host = CharacterGetHostCharacter()
			_testingEnabled = true
			local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(host, 6.0)
			local enemy = TemporaryCharacterCreateAtPosition(x, y, z, "13ee7ec6-70c3-4f2c-9145-9a5e85feb7d3", 0)
			self.Cleanup = function ()
				GameHelpers.Status.Remove(host, "FORTIFIED")
				BuffStatusPreserver.ClearSavedStatus(host, "FORTIFIED")
				RemoveTemporaryCharacter(enemy)
				_testingEnabled = false
			end
			SetStoryEvent(enemy, "ClearPeaceReturn")
			CharacterSetReactionPriority(enemy, "StateManager", 0)
			CharacterSetReactionPriority(enemy, "ResetInternalState", 0)
			CharacterSetReactionPriority(enemy, "ReturnToPeacePosition", 0)
			CharacterSetReactionPriority(enemy, "CowerIfNeutralSeeCombat", 0)
			SetTag(enemy, "LeaderLib_TemporaryCharacter")
			self:Wait(250)
			SetFaction(enemy, "PVP_1")
			self:Wait(250)
			CharacterSetTemporaryHostileRelation(host, enemy)
			self:Wait(250)
			EnterCombat(host, enemy)
			self:Wait(50)
			JumpToTurn(host)
			CharacterUseSkill(host, "Target_EnemyFortify", host, 1, 1, 1)
			self:WaitForSignal("BUFFSTATUSPRESERVER_SkillUsed", 10000)
			self:AssertGotSignal("BUFFSTATUSPRESERVER_SkillUsed")
			self:Wait(5000)
			local duration = GameHelpers.Status.GetDuration(host, "FORTIFIED")
			self:AssertEquals(duration > 0, true, string.format("Failed to make FORTIFIED non-permanent in combat (%s)", duration))
			return true
		end,
	},{
		CallCleanupAfterEachTask = true
	})
	Testing.RegisterConsoleCommandTest(buffTest.ID, buffTest, "Test the BuffStatusPreserver QoL feature.")
end