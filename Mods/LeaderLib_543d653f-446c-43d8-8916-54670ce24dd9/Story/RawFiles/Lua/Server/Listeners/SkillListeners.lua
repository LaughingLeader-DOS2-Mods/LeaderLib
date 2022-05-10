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
	local skill = GetSkillEntryName(skillprototype)
	-- if CharacterIsControlled(char) == 0 then
	-- 	Osi.LeaderLib_LuaSkillListeners_IgnorePrototype(char, skillprototype, skill)
	-- end
	local last = PersistentVars.IsPreparingSkill[char]
	if last and last ~= skill then
		SkillManager.OnSkillPreparingCancel(char, "", last, true)
	end

	if not last or last ~= skill then
		local skillData = Ext.GetStat(skill)
		for callback in SkillManager.GetListeners(skill) do
			--PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillPreparing] char(",char,") skillprototype(",skillprototype,") skill(",skill,")")
			local status,err = xpcall(callback, debug.traceback, skill, char, SKILL_STATE.PREPARE, skillData, "StatEntrySkillData")
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end

	-- Clear previous data for this character in case SkillCast never fired (interrupted)
	RemoveCharacterSkillData(char)
	PersistentVars.IsPreparingSkill[char] = skill
end

-- Fires when CharacterUsedSkill fires. This happens after all the target events.
function OnSkillUsed(char, skill, skillType, skillAbility)
	-- if skill ~= nil then
	-- 	Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char, skill)
	-- else
	-- 	Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char)
	-- end
	local uuid = StringHelpers.GetUUID(char)

	if GameHelpers.Stats.IsHealingSkill(skill) then
		PersistentVars.LastUsedHealingSkill[uuid] = skill
		Timer.StartObjectTimer("LeaderLib_ClearLastUsedHealingSkill", uuid, 3000)
	end
	
	local data = GetCharacterSkillData(skill, uuid, true, skillType, skillAbility)
	if data then
		--Quake doesn't fire any target events, but works like a shout
		if skillType == "quake" then
			local x,y,z = GetPosition(char)
			data:AddTargetPosition(x,y,z)
		end
		local status,err = nil,nil
		for callback in SkillManager.GetListeners(skill) do
			if Vars.DebugMode then
				--PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillUsed] char(",char,") skill(",skill,") data(",data:ToString(),")")
				--PrintDebug("params(",Common.JsonStringify({...}),")")
			end
			status,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.USED, data, data.Type)
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
		for callback in SkillManager.GetListeners(skill) do
			local b,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.CAST, data, data.Type)
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

--- @param skillId string
--- @param target EsvCharacter|EsvItem
--- @param source EsvCharacter|EsvItem
--- @param damage integer
--- @param hit HitRequest
--- @param context HitContext
--- @param hitStatus EsvStatusHit
--- @param data HitData|ProjectileHitData
function OnSkillHit(skillId, target, source, damage, hit, context, hitStatus, data)
	if not IgnoreHitTarget(target.MyGuid) then
		for callback in SkillManager.GetListeners(skillId) do
			local b,err = xpcall(callback, debug.traceback, skillId, source.MyGuid, SKILL_STATE.HIT, data, data.Type)
			if not b then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
		InvokeListenerCallbacks(Listeners.OnSkillHit, source.MyGuid, skillId, SKILL_STATE.HIT, data)
	end
end

---@param projectile EsvProjectile
---@param hitObject EsvGameObject
---@param position number[]
RegisterProtectedExtenderListener("ProjectileHit", function (projectile, hitObject, position)
	if not StringHelpers.IsNullOrEmpty(projectile.SkillId) then
		local skill = GetSkillEntryName(projectile.SkillId)
		if projectile.CasterHandle ~= nil then
			local object = Ext.GetGameObject(projectile.CasterHandle)
			local uuid = (object ~= nil and object.MyGuid) or ""
			local target = hitObject ~= nil and hitObject.MyGuid or ""
			---@type ProjectileHitData
			local data = Classes.ProjectileHitData:Create(target, uuid, projectile, position, skill)
			for callback in SkillManager.GetListeners(skill) do
				local b,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.PROJECTILEHIT, data, data.Type)
				if not b then
					Ext.PrintError("[LeaderLib:SkillListeners:ProjectileHit] Error invoking function:\n", err)
				end
			end
			InvokeListenerCallbacks(Listeners.OnSkillHit, uuid, skill, SKILL_STATE.PROJECTILEHIT, data, data.Type)
		end
	end
end)

---@param request EsvShootProjectileRequest
RegisterProtectedExtenderListener("BeforeShootProjectile", function (request)
	local skill = GetSkillEntryName(request.SkillId)
	if not StringHelpers.IsNullOrEmpty(skill) and request.Source then
		local object = Ext.GetGameObject(request.Source)
		if object then
			for callback in SkillManager.GetListeners(skill) do
				local b,err = xpcall(callback, debug.traceback, skill, object.MyGuid, SKILL_STATE.BEFORESHOOT, request, "EsvShootProjectileRequest")
				if not b then
					Ext.PrintError("[LeaderLib:SkillListeners:BeforeShootProjectile] Error invoking function:\n", err)
				end
			end
			InvokeListenerCallbacks(Listeners.OnSkillHit, object.MyGuid, skill, SKILL_STATE.BEFORESHOOT, request, "EsvShootProjectileRequest")
		end
	end
end)

---@param projectile EsvProjectile
RegisterProtectedExtenderListener("ShootProjectile", function (projectile)
	local skill = GetSkillEntryName(projectile.SkillId)
	if not StringHelpers.IsNullOrEmpty(skill) and projectile.CasterHandle then
		local object = Ext.GetGameObject(projectile.CasterHandle)
		if object then
			for callback in SkillManager.GetListeners(skill) do
				local b,err = xpcall(callback, debug.traceback, skill, object.MyGuid, SKILL_STATE.SHOOTPROJECTILE, projectile, "EsvProjectile")
				if not b then
					Ext.PrintError("[LeaderLib:SkillListeners:BeforeShootProjectile] Error invoking function:\n", err)
				end
			end
			InvokeListenerCallbacks(Listeners.OnSkillHit, object.MyGuid, skill, SKILL_STATE.SHOOTPROJECTILE, projectile, "EsvProjectile")
		end
	end
end)

RegisterProtectedOsirisListener("SkillAdded", Data.OsirisEvents.SkillAdded, "after", function(uuid, skill, learned)
	uuid = StringHelpers.GetUUID(uuid)
	learned = learned == 1 and true or false
	for callback in SkillManager.GetListeners(skill) do
		local b,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.LEARNED, learned, "boolean")
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
	for callback in SkillManager.GetListeners(skill) do
		local b,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.MEMORIZED, learned, "boolean")
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
	for callback in SkillManager.GetListeners(skill) do
		local b,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.UNMEMORIZED, learned, "boolean")
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