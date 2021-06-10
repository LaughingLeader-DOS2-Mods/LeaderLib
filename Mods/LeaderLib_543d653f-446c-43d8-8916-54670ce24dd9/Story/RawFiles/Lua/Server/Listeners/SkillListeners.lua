if SkillSystem == nil then
	SkillSystem = {}
end

local ignoreSkill = {}

--- Gets the base skill from a skill.
--- @param skill string The skill entry to check.
--- @return string The base skill, if any, otherwise the skill that was passed in.
function SkillSystem.GetBaseSkill(skill, match)
	if skill ~= nil then
		local checkParent = true
		if match ~= nil and match ~= "" and not string.find(skill, match) then
			checkParent = false
		end
		if checkParent then
			local skill = Ext.StatGetAttribute(skill, "Using")
			if skill ~= nil then
				return SkillSystem.GetBaseSkill(skill, match)
			end
		end
	end
	return skill
end

local function GetListeners(skill)
	local parsingAllTable = false
	local listeners = SkillListeners[skill]
	if listeners == nil then
		listeners = SkillListeners["All"] 
		parsingAllTable = true
	end
	if listeners then
		local i = 0
		local count = #listeners
		return function ()
			i = i + 1
			if not parsingAllTable and i == count+1 then
				if SkillListeners["All"] ~= nil then
					listeners = SkillListeners["All"] 
					i = 1
					count = #listeners
					parsingAllTable = true
				end
			end

			if i <= count then
				return listeners[i]
			end
		end
	end
	return function() end
end

---A temporary table used to store data for a skill, including targets / skill information.
---@type table<string,SkillEventData>
local skillEventDataTable = {}

---@return SkillEventData
local function GetCharacterSkillData(skill, uuid, createIfMissing, skillType, skillAbility, printWarning, printContext)
	---@type SkillEventData
	local data = nil
	local skillDataHolder = skillEventDataTable[skill]
	if skillDataHolder ~= nil then
		data = skillDataHolder[uuid]
	elseif createIfMissing == true then
		skillDataHolder = {}
		skillEventDataTable[skill] = skillDataHolder
	end

	if data == nil and createIfMissing == true then
		if Vars.DebugMode and printWarning and CharacterIsPlayer(uuid) == 1 then
			fprint(LOGLEVEL.WARNING, "[LeaderLib:OnSkillCast] No skill data for character (%s) and skill (%s) Context(%s)", uuid, skill, printContext or "")
		end
		data = Classes.SkillEventData:Create(uuid, skill, skillType, skillAbility)
		skillDataHolder[uuid] = data
	end
	PersistentVars.SkillData[uuid] = data:Serialize()
	return data
end

function SkillSystem.LoadSaveData()
	if PersistentVars.SkillData then
		for uuid,tbl in pairs(PersistentVars.SkillData) do
			if ObjectExists(uuid) == 1 and not StringHelpers.IsNullOrWhitespace(tbl.Skill) and NRD_StatExists(tbl.Skill) then
				local data = Classes.SkillEventData:Create(uuid, "", "", "")
				data:LoadFromSave(tbl)
				if skillEventDataTable[data.Skill] == nil then
					skillEventDataTable[data.Skill] = {}
				end
				skillEventDataTable[data.Skill][uuid] = data
			else
				PersistentVars.SkillData[uuid] = nil
			end
		end
	end
end

local function RemoveCharacterSkillData(uuid, skill)
	if skill ~= nil then
		local skillDataHolder = skillEventDataTable[skill]
		if skillDataHolder ~= nil then
			skillDataHolder[uuid] = nil
		end
	else
		-- Remove everything for this character
		for skill,data in pairs(skillEventDataTable) do
			if data[uuid] ~= nil then
				data[uuid] = nil
			end
		end
	end
	PersistentVars.IsPreparingSkill[uuid] = nil
	PersistentVars.SkillData[uuid] = nil
end

function StoreSkillEventData(char, skill, skillType, skillAbility, ...)
	local listeners = SkillListeners[skill]
	if listeners ~= nil or SkillListeners["All"] ~= nil then
		local uuid = StringHelpers.GetUUID(char)
		local eventParams = {...}
		---@type SkillEventData
		local data = GetCharacterSkillData(skill, uuid, true, skillType, skillAbility)
		if eventParams ~= nil then
			if #eventParams == 1 and not StringHelpers.IsNullOrEmpty(eventParams[1]) then
				data:AddTargetObject(eventParams[1])
			elseif #eventParams >= 3 then -- Position
				local x,y,z = table.unpack(eventParams)
				if x ~= nil and y ~= nil and z ~= nil then
					data:AddTargetPosition(x,y,z)
				end
			end
		end
	end
end

-- Example: Finding the base skill of an enemy skill
-- GetBaseSkill(skill, "Enemy")

function OnSkillPreparing(char, skillprototype)
	char = StringHelpers.GetUUID(char)
	local skill = string.gsub(skillprototype, "_%-?%d+$", "")
	-- if CharacterIsControlled(char) == 0 then
	-- 	Osi.LeaderLib_LuaSkillListeners_IgnorePrototype(char, skillprototype, skill)
	-- end
	local last = PersistentVars.IsPreparingSkill[char]
	if last and last ~= skill then
		SkillSystem.OnSkillPreparingCancel(char, "", last, true)
	end

	if not last or last ~= skill then
		for callback in GetListeners(skill) do
			--PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillPreparing] char(",char,") skillprototype(",skillprototype,") skill(",skill,")")
			local status,err = xpcall(callback, debug.traceback, skill, char, SKILL_STATE.PREPARE)
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end

	-- Clear previous data for this character in case SkillCast never fired (interrupted)
	RemoveCharacterSkillData(char)
	PersistentVars.IsPreparingSkill[char] = skill
end

function SkillSystem.OnSkillPreparingCancel(char, skillprototype, skill, skipRemoval)
	skill = skill or string.gsub(skillprototype, "_%-?%d+$", "")
	for callback in GetListeners(skill) do
		--PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillPreparing] char(",char,") skillprototype(",skillprototype,") skill(",skill,")")
		local status,err = xpcall(callback, debug.traceback, skill, char, SKILL_STATE.CANCEL)
		if not status then
			Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
		end
	end

	if skipRemoval ~= true then
		RemoveCharacterSkillData(char)
	end
end

function SkillSystem.CheckPreparingState(uuid)
	local last = PersistentVars.IsPreparingSkill[uuid]
	if last then
		local action = NRD_CharacterGetCurrentAction(uuid) or ""
		local skill = string.gsub(NRD_ActionStateGetString(uuid, "SkillId") or "", "_%-?%d+$", "")
		if StringHelpers.IsNullOrEmpty(skill) or (action ~= "PrepareSkill" and action ~= "UseSkill") or skill ~= last then
			SkillSystem.OnSkillPreparingCancel(uuid, "", last)
		end
	end
end

--When the ActionCancel button is pressed.
Ext.RegisterNetListener("LeaderLib_Input_OnActionCancel", function(cmd, payload)
	if not StringHelpers.IsNullOrEmpty(payload) then
		local netid = tonumber(payload)
		local character = Ext.GetCharacter(netid)
		if character then
			local action = NRD_CharacterGetCurrentAction(character.MyGuid) or ""
			if action == "PrepareSkill" then
				local skillPrototype = NRD_ActionStateGetString(character.MyGuid, "SkillId")
				if not StringHelpers.IsNullOrEmpty(skillPrototype) then
					SkillSystem.OnSkillPreparingCancel(character.MyGuid, skillPrototype)
				end
			end
		end
	end
end)

--When the active skill on hotBar or bottomBar_c is cleared
Ext.RegisterNetListener("LeaderLib_OnActiveSkillCleared", function(cmd, uuid)
	if not StringHelpers.IsNullOrEmpty(uuid) then
		StartOneshotTimer("Timers_LeaderLib_OnActiveSkillCleared", 50, function()
			SkillSystem.CheckPreparingState(uuid)
		end)
	end
end)

-- Fires when CharacterUsedSkill fires. This happens after all the target events.
function OnSkillUsed(char, skill, skillType, skillAbility)
	-- if skill ~= nil then
	-- 	Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char, skill)
	-- else
	-- 	Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char)
	-- end
	local uuid = StringHelpers.GetUUID(char)
	local data = GetCharacterSkillData(skill, uuid, true, skillType, skillAbility)
	if data then
		--Quake doesn't fire any target events, but works like a shout
		if skillType == "quake" then
			data:AddTargetPosition(GetPosition(char))
		end
		local status,err = nil,nil
		for callback in GetListeners(skill) do
			if Vars.DebugMode then
				--PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillUsed] char(",char,") skill(",skill,") data(",data:ToString(),")")
				--PrintDebug("params(",Ext.JsonStringify({...}),")")
			end
			status,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.USED, data)
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end
end

function OnSkillCast(char, skill, skilLType, skillAbility)
	local uuid = StringHelpers.GetUUID(char)
	--Some skills may not fire any target events, like MultiStrike, so create the data if it doesn't exist.
	---@type SkillEventData
	local data = GetCharacterSkillData(skill, uuid, true, skilLType, skillAbility, Vars.DebugMode, "OnSkillCast")
	if data ~= nil then
		for callback in GetListeners(skill) do
			local b,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.CAST, data)
			if not b then
				Ext.PrintError("[LeaderLib:SkillListeners:OnSkillCast] Error invoking function:\n", err)
			end
		end
		data:Clear()
		RemoveCharacterSkillData(uuid, skill)
	end
end

local function IgnoreHitTarget(target)
	if IsTagged(target, "MovingObject") == 1 then
		return true
	elseif ObjectIsCharacter(target) == 1 and Osi.LeaderLib_Helper_QRY_IgnoreCharacter(target) == true then
		return true
	elseif ObjectIsItem(target) == 1 and Osi.LeaderLib_Helper_QRY_IgnoreItem(target) == true then
		return true
	end
	return false
end

--- @param skill StatEntrySkillData
--- @param target EsvCharacter|EsvItem
--- @param source EsvCharacter|EsvItem
--- @param damage integer
--- @param hit HitRequest
--- @param context HitContext
--- @param hitStatus EsvStatusHit
function OnSkillHit(skill, target, source, damage, hit, context, hitStatus, data)
	if not IgnoreHitTarget(target.MyGuid) then
		for callback in GetListeners(skill.Name) do
			local b,err = xpcall(callback, debug.traceback, skill.Name, source.MyGuid, SKILL_STATE.HIT, data)
			if not b then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
		InvokeListenerCallbacks(Listeners.OnSkillHit, source.MyGuid, skill.Name, SKILL_STATE.HIT, data)

		if Features.ApplyBonusWeaponStatuses == true then
			local canApplyStatuses = target and skill.UseWeaponProperties == "Yes"
			if canApplyStatuses then
				for i,status in pairs(source:GetStatuses()) do
					local potion = nil
					if type(status) ~= "string" and status.StatusId ~= nil then
						status = status.StatusId
					end
					if Data.EngineStatus[status] ~= true then
						potion = Ext.StatGetAttribute(status, "StatsId")
						if potion ~= nil and potion ~= "" then
							local bonusWeapon = Ext.StatGetAttribute(potion, "BonusWeapon")
							if bonusWeapon ~= nil and bonusWeapon ~= "" then
								local extraProps = GameHelpers.Stats.GetExtraProperties(bonusWeapon)
								if extraProps and #extraProps > 0 then
									GameHelpers.ApplyProperties(source, target, extraProps)
								end
							end
						end
					end
				end
			end
		end
	end
end

---@param projectile EsvProjectile
---@param hitObject EsvGameObject
---@param position number[]
Ext.RegisterListener("ProjectileHit", function (projectile, hitObject, position)
	if not StringHelpers.IsNullOrEmpty(projectile.SkillId) then
		local skill = GetSkillEntryName(projectile.SkillId)
		if projectile.CasterHandle ~= nil then
			local object = Ext.GetGameObject(projectile.CasterHandle)
			local uuid = (object ~= nil and object.MyGuid) or ""
			local target = hitObject ~= nil and hitObject.MyGuid or ""
			---@type ProjectileHitData
			local data = Classes.ProjectileHitData:Create(target, uuid, projectile, position, skill)
			for callback in GetListeners(skill) do
				local b,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.PROJECTILEHIT, data)
				if not b then
					Ext.PrintError("[LeaderLib:SkillListeners:ProjectileHit] Error invoking function:\n", err)
				end
			end
			InvokeListenerCallbacks(Listeners.OnSkillHit, uuid, skill, SKILL_STATE.PROJECTILEHIT, data)
		end
	end
end)

RegisterProtectedOsirisListener("SkillAdded", Data.OsirisEvents.SkillAdded, "after", function(uuid, skill, learned)
	uuid = StringHelpers.GetUUID(uuid)
	learned = learned == 1 and true or false 
	for callback in GetListeners(skill) do
		local b,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.LEARNED, learned)
		if not b then
			Ext.PrintError("[LeaderLib:SkillListeners:SkillAdded] Error invoking function:\n", err)
		end
	end
end)

RegisterProtectedOsirisListener("SkillActivated", Data.OsirisEvents.SkillActivated, "after", function(uuid, skill)
	uuid = StringHelpers.GetUUID(uuid)
	local learned = false
	local character = Ext.GetCharacter(uuid)
	if character then
		local skillInfo = character:GetSkillInfo(skill)
		if skillInfo then
			learned = skillInfo.IsLearned or skillInfo.ZeroMemory
		end
	end
	for callback in GetListeners(skill) do
		local b,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.MEMORIZED, learned)
		if not b then
			Ext.PrintError("[LeaderLib:SkillListeners:SkillActivated] Error invoking function:\n", err)
		end
	end
end)

RegisterProtectedOsirisListener("SkillDeactivated", Data.OsirisEvents.SkillDeactivated, "before", function(uuid, skill)
	if ObjectExists(uuid) == 0 then
		return
	end
	uuid = StringHelpers.GetUUID(uuid)
	local learned = false
	local character = Ext.GetCharacter(uuid)
	if character then
		local skillInfo = character:GetSkillInfo(skill)
		if skillInfo then
			learned = skillInfo.IsLearned or skillInfo.ZeroMemory
		end
	end
	for callback in GetListeners(skill) do
		local b,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.UNMEMORIZED, learned)
		if not b then
			Ext.PrintError("[LeaderLib:SkillListeners:SkillDeactivated] Error invoking function:\n", err)
		end
	end
end)

-- Ext.RegisterOsirisListener("NRD_OnActionStateEnter", Data.OsirisEvents.NRD_OnActionStateEnter, "after", function(char, state)
-- 	if state == "PrepareSkill" then
-- 		local skillprototype = NRD_ActionStateGetString(char, "SkillId")
-- 		if skillprototype ~= nil and skillprototype ~= "" then
-- 			OnSkillPreparing(char, skillprototype)
-- 		end
-- 	end
-- end)

-- Ext.RegisterOsirisListener("NRD_OnActionStateExit", Data.OsirisEvents.NRD_OnActionStateExit, "after", function(char, state)
-- 	if state == "PrepareSkill" then
-- 		local skillprototype = NRD_ActionStateGetString(char, "SkillId")
-- 		if skillprototype ~= nil and skillprototype ~= "" then
-- 			OnSkillPreparing(char, skillprototype)
-- 		end
-- 	end
-- end)

-- Ext.RegisterOsirisListener("CharacterUsedSkillOnTarget", 5, "after", function(char, target, skill, skilltype, element)
-- 	StoreSkillEventData(char, skill, skilltype, element, target)
-- end)

-- Ext.RegisterOsirisListener("CharacterUsedSkillAtPosition", 7, "after", function(char, x, y, z, skill, skilltype, element)
-- 	StoreSkillEventData(char, skill, skilltype, element, x, y, z)
-- end)

-- Ext.RegisterOsirisListener("CharacterUsedSkillOnZoneWithTarget", 5, "after", function(char, target, skill, skilltype, element)
-- 	StoreSkillEventData(char, skill, skilltype, element, target)
-- end)

-- Ext.RegisterOsirisListener("CharacterUsedSkill", 4, "after", function(char, skill, skilltype, element)
-- 	OnSkillUsed(char, skill, skilltype, element)
-- end)

-- Ext.RegisterOsirisListener("SkillCast", 4, "after", function(char, skill, skilltype, element)
-- 	SkillCast(char, skill, skilltype, element)
-- end)