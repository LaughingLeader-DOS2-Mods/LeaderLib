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
	ACTIVE_DEFENSE = true,
	BLIND = true,
	CHARMED = true,
	DECAYING_TOUCH = true,
	DISARMED = true,
	EXTRA_TURN = true,
	FEAR = true,
	GUARDIAN_ANGEL = true,
	HEAL = true,
	HEAL_SHARING = true,
	HEAL_SHARING_CASTER = true,
	HEALING = true,
	INCAPACITATED = true,
	INVISIBLE = true,
	KNOCKED_DOWN = true,
	MUTED = true,
	PLAY_DEAD = true,
	POLYMORPHED = true,
	THROWN = true,
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
	if Data.EngineStatus[id] then
		return true
	end
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
	if status.LifeTime > 0 and (skipCheck or not IgnoreStatus(status.StatusId)
	and GameHelpers.Status.IsBeneficial(status.StatusId, true, BuffStatusPreserver.IgnoredStatusTypes)) then
		if not _PV.BuffStatuses[character.MyGuid] then
			_PV.BuffStatuses[character.MyGuid] = {}
		end
		local savedStatusData = _PV.BuffStatuses[character.MyGuid]
		savedStatusData[status.StatusId] = math.ceil(status.LifeTime) -- Set it to the max duration
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
		if GUID and _PV.BuffStatuses[GUID] then
			_PV.BuffStatuses[GUID][statusId] = nil
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
		if statusType == "CONSUME" and not status.KeepAlive then
			BuffStatusPreserver.PreserveStatus(character, status)
		end
	end
end

---@param obj Guid
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

---@param obj Guid
---@param combatId integer
function BuffStatusPreserver.OnEnteredCombat(obj, combatId)
	local GUID = GameHelpers.GetUUID(obj)
	local data = _PV.BuffStatuses[GUID]
	if data then
		local character = GameHelpers.GetCharacter(GUID)
		if character then
			for _,status in pairs(character:GetStatusObjects()) do
				local duration = data[status.StatusId]
				if duration then
					--TODO For some reason, when the status is made non-permanent again, it reduces the turns by 1
					duration = duration + 6.0
					--status.TurnTimer = 0.032444998621941
					status.CurrentLifeTime = duration
					status.LifeTime = duration
					status.IsLifeTimeSet = true
					status.RequestClientSync = true
				end
			end
		end
		_PV.BuffStatuses[GUID] = nil
	end
	BuffStatusPreserver.NextBuffStatus[GUID] = nil
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
				if v.Type == "Status" then
					---@cast v StatPropertyStatus
					if v.Duration > 0 and not IgnoreStatus(v.Action)
					and GameHelpers.Status.IsBeneficial(v.Action, true, BuffStatusPreserver.IgnoredStatusTypes) then
						if BuffStatusPreserver.NextBuffStatus[GUID] == nil then
							BuffStatusPreserver.NextBuffStatus[GUID] = {}
						end
						BuffStatusPreserver.NextBuffStatus[GUID][v.Action] = true
						Timer.Cancel("LeaderLib_BuffStatusPreserver_ClearStatusData", GUID)
						Timer.StartObjectTimer("LeaderLib_BuffStatusPreserver_ClearStatusData", GUID, 2000)
					end
				end
			end
		end
	end
	if _testingEnabled then
		Testing.EmitSignal("BUFFSTATUSPRESERVER_SkillUsed")
	end
end

Timer.Subscribe("LeaderLib_BuffStatusPreserver_ClearStatusData", function (e)
	if e.Data.UUID then
		BuffStatusPreserver.NextBuffStatus[e.Data.UUID] = nil
	end
end)

local _combatLeftEnabled = false
--Ext.Osiris.RegisterListener("ObjectLeftCombat", 2, "after", BuffStatusPreserver.OnLeftCombat)
Ext.Osiris.RegisterListener("ObjectEnteredCombat", 2, "after", BuffStatusPreserver.OnEnteredCombat)
Ext.Osiris.RegisterListener("CharacterUsedSkill", 4, "after", BuffStatusPreserver.OnSkillUsed)

Ext.Events.SessionLoaded:Subscribe(function (e)
	Ext.Events.BeforeStatusApply:Subscribe(function(e)
		if not BuffStatusPreserver.Enabled() or e.PreventStatusApply then return end
		local target = GameHelpers.GetObjectFromHandle(e.Status.TargetHandle, "EsvCharacter") --[[@as EsvCharacter|EsvItem]]
		if not target then return end
		local targetGUID = target.MyGuid
		local source = GameHelpers.GetObjectFromHandle(e.Status.StatusSourceHandle, "EsvCharacter") --[[@as EsvCharacter|EsvItem]]
	
		local data = BuffStatusPreserver.NextBuffStatus[targetGUID]
		if data and data[e.Status.StatusId] then
			BuffStatusPreserver.PreserveStatus(target, e.Status, true)
			Timer.Cancel("LeaderLib_BuffStatusPreserver_ClearStatusData", targetGUID)
			Timer.StartObjectTimer("LeaderLib_BuffStatusPreserver_ClearStatusData", targetGUID, 500)
		elseif source and GameHelpers.Character.IsPlayerOrPartyMember(targetGUID) then -- Allow players to apply permanent buffs to other party members
			local data = BuffStatusPreserver.NextBuffStatus[source.MyGuid]
			if data and data[e.Status.StatusId] then
				BuffStatusPreserver.PreserveStatus(target, e.Status, true)
				Timer.Cancel("LeaderLib_BuffStatusPreserver_ClearStatusData", source.MyGuid)
				Timer.StartObjectTimer("LeaderLib_BuffStatusPreserver_ClearStatusData", source.MyGuid, 500)
			end
		end
	end, {Priority=0})
end)

function BuffStatusPreserver.Disable()
	if _PV.BuffStatuses then
		for GUID,data in pairs(_PV.BuffStatuses) do
			if GameHelpers.ObjectExists(GUID) then
				BuffStatusPreserver.OnEnteredCombat(GUID, 0)
			else
				_PV.BuffStatuses[GUID] = nil
			end
		end
	end
end

if Vars.DebugMode then
	local buffTest = Classes.LuaTest:Create("buffstatuspreserver", {
		--[[ ---@param self LuaTest
		function(self)
			--Apply Foritiied out of combat and check that the duration is permanent
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
		end, ]]
		---@param self LuaTest
		function(self)
			--Apply Foritiied out of combat, then enter combat and check that the duration is made non-permanent
			local host = StringHelpers.GetUUID(Osi.CharacterGetHostCharacter())
			_testingEnabled = true
			local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(host, 6.0)
			local enemy = Osi.TemporaryCharacterCreateAtPosition(x, y, z, "13ee7ec6-70c3-4f2c-9145-9a5e85feb7d3", 0)
			self.Cleanup = function ()
				GameHelpers.Status.Remove(host, "FORTIFIED")
				BuffStatusPreserver.ClearSavedStatus(host, "FORTIFIED")
				Osi.RemoveTemporaryCharacter(enemy)
				_testingEnabled = false
			end
			Osi.SetStoryEvent(enemy, "ClearPeaceReturn")
			Osi.CharacterSetReactionPriority(enemy, "StateManager", 0)
			Osi.CharacterSetReactionPriority(enemy, "ResetInternalState", 0)
			Osi.CharacterSetReactionPriority(enemy, "ReturnToPeacePosition", 0)
			Osi.CharacterSetReactionPriority(enemy, "CowerIfNeutralSeeCombat", 0)
			Osi.SetTag(enemy, "LeaderLib_TemporaryCharacter")
			Osi.CharacterUseSkill(host, "Target_EnemyFortify", host, 1, 1, 1)
			self:WaitForSignal("BUFFSTATUSPRESERVER_SkillUsed", 10000)
			self:AssertGotSignal("BUFFSTATUSPRESERVER_SkillUsed")
			self:Wait(3000)
			local duration = GameHelpers.Status.GetDuration(host, "FORTIFIED")
			self:AssertEquals(duration == -1, true, string.format("Failed to make FORTIFIED permanent (%s)", duration))
			local intendedDuration = _PV.BuffStatuses[host].FORTIFIED
			self:Wait(250)
			Osi.SetFaction(enemy, "PVP_1")
			self:Wait(250)
			Osi.CharacterSetTemporaryHostileRelation(host, enemy)
			self:Wait(250)
			Osi.EnterCombat(host, enemy)
			self:Wait(50)
			Osi.JumpToTurn(host)
			self:Wait(500)
			local duration = GameHelpers.Status.GetDuration(host, "FORTIFIED")
			self:AssertEquals(duration >= intendedDuration, true, string.format("Failed to make FORTIFIED (-1 turns) non-permanent (%s) in combat (Resulting duration: %s)", intendedDuration, duration))
			self:Wait(3000)
			return true
		end,
		---@param self LuaTest
		function(self)
			--Apply Foritiied in combat and check that the duration is non-permanent
			local host = Osi.CharacterGetHostCharacter()
			_testingEnabled = true
			local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(host, 6.0)
			local enemy = Osi.TemporaryCharacterCreateAtPosition(x, y, z, "13ee7ec6-70c3-4f2c-9145-9a5e85feb7d3", 0)
			self.Cleanup = function ()
				GameHelpers.Status.Remove(host, "FORTIFIED")
				BuffStatusPreserver.ClearSavedStatus(host, "FORTIFIED")
				Osi.RemoveTemporaryCharacter(enemy)
				_testingEnabled = false
			end
			Osi.SetStoryEvent(enemy, "ClearPeaceReturn")
			Osi.CharacterSetReactionPriority(enemy, "StateManager", 0)
			Osi.CharacterSetReactionPriority(enemy, "ResetInternalState", 0)
			Osi.CharacterSetReactionPriority(enemy, "ReturnToPeacePosition", 0)
			Osi.CharacterSetReactionPriority(enemy, "CowerIfNeutralSeeCombat", 0)
			Osi.SetTag(enemy, "LeaderLib_TemporaryCharacter")
			Osi.SetFaction(enemy, "PVP_1")
			self:Wait(250)
			Osi.CharacterSetTemporaryHostileRelation(host, enemy)
			self:Wait(250)
			Osi.EnterCombat(host, enemy)
			self:Wait(50)
			Osi.JumpToTurn(host)
			self:Wait(500)
			Osi.CharacterUseSkill(host, "Target_EnemyFortify", host, 1, 1, 1)
			self:WaitForSignal("BUFFSTATUSPRESERVER_SkillUsed", 10000)
			self:AssertGotSignal("BUFFSTATUSPRESERVER_SkillUsed")
			self:Wait(5000)
			local duration = GameHelpers.Status.GetDuration(host, "FORTIFIED")
			self:AssertEquals(duration > 0, true, string.format("Failed to make FORTIFIED non-permanent in combat (%s)", duration))
			if _combatLeftEnabled then
				Osi.RemoveTemporaryCharacter(enemy)
				self:Wait(10000)
				local duration = GameHelpers.Status.GetDuration(host, "FORTIFIED")
				self:AssertEquals(duration == -1, true, string.format("Failed to make FORTIFIED permanent after combat ended (%s)", duration))
			end
			return true
		end,
	},{
		CallCleanupAfterEachTask = true
	})
	Testing.RegisterConsoleCommandTest(buffTest.ID, buffTest, "Test the BuffStatusPreserver QoL feature.")
end