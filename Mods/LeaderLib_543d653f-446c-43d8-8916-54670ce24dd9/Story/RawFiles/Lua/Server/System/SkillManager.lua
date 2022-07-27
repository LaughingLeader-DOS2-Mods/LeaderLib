if SkillManager == nil then
	---@class LeaderLibSkillManager
	SkillManager = {}
end

Managers.Skill = SkillManager

---A temporary table used to store data for a skill, including targets / skill information.
---@type table<string,SkillEventData>
local skillEventDataTable = {}

---@private
SkillManager.SkillEventDataTable = skillEventDataTable

---A temporary table used to store data for a skill, including targets / skill information.
---@type table<string,SkillEventData>
local skillEventDataTable = {}

local _enabledSkills = {}

function SkillManager.EnableForAllSkills(enabled)
	if enabled ~= false then
		_enabledSkills.All = true
	else
		_enabledSkills.All = false
	end
end

---@alias LeaderLibSkillListenerDataType string|"boolean"|"StatEntrySkillData"|"HitData"|"ProjectileHitData"|"SkillEventData"|"EsvShootProjectileRequest"

---@alias LeaderLibSkillListenerCallback fun(skill:string, char:string, state:SKILL_STATE, data:SkillEventData|HitData|ProjectileHitData|StatEntrySkillData|boolean, dataType:LeaderLibSkillListenerDataType)

local _EXTVERSION = Ext.Version()

---Registers a function to call when skill events fire for a skill or table of skills.
---@param skill string|string[]
---@param callback LeaderLibSkillListenerCallback
---@deprecated
---@see SkillEventData#ForEach
---@see HitData#Success
---@see ProjectileHitData#Projectile
function RegisterSkillListener(skill, callback)
	local t = type(skill)
	if t == "string" then
		if StringHelpers.Equals(skill, "All", true) then
			_enabledSkills.All = true
			Events.OnSkillState:Subscribe(function (e)
				callback(e:Unpack())
			end)
		else
			_enabledSkills[skill] = true
			Events.OnSkillState:Subscribe(function (e)
				callback(e:Unpack())
			end, {MatchArgs={Skill=skill}})
		end

		if Vars.Initialized then
			Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaSkillListeners_Enabled", "LeaderLib")
			Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaEventListeners_Enabled", "LeaderLib")
		else
			Vars.PostLoadEnableLuaListeners = true
		end
	elseif t == "table" then
		for i,v in pairs(skill) do
			RegisterSkillListener(v, callback)
		end
	end
end

--- Removed a function from the listeners table.
---@param skill string
---@param callback function
---@deprecated
function RemoveSkillListener(skill, callback)
	local t = type(skill)
	if t == "string" then
		Events.OnSkillState:Unsubscribe(callback, {Skill=skill})
	elseif t == "table" then
		for i,v in pairs(skill) do
			RemoveSkillListener(v, callback)
		end
	elseif type(callback) == "function" then
		Events.OnSkillState:Unsubscribe(callback)
	end
end

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
	if data then
		PersistentVars.SkillData[uuid] = data:Serialize()
	end
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
	if _enabledSkills[skill] or _enabledSkills["All"] then
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

local _lastUsedSkillItems = {}

---@param character EsvCharacter
---@param skill string
---@param returnStoredtemData boolean|nil Returns the last item data as a table, if the item no longer exists.
local function _GetSkillSourceItem(character, skill, returnStoredtemData)
	if not character then
		return nil
	end
	local sourceItem = nil
	if _EXTVERSION >= 56 and GameHelpers.Ext.ObjectIsCharacter(character) then
		if character.SkillManager.CurrentSkillState and Ext.Utils.IsValidHandle(character.SkillManager.CurrentSkillState.SourceItemHandle) then
			sourceItem = GameHelpers.GetItem(character.SkillManager.CurrentSkillState.SourceItemHandle)
		end
	end
	if sourceItem == nil then
		local lastItemData = _lastUsedSkillItems[character.MyGuid]
		if lastItemData then
			if StringHelpers.Contains(lastItemData.Skills, skill) then
				if returnStoredtemData == true then
					sourceItem = {
						RootTemplate = lastItemData.Template,
						StatsId = lastItemData.StatsId,
						DisplayName = lastItemData.DisplayName
					}
					if _EXTVERSION >= 56 then
						sourceItem.RootTemplate = Ext.Template.GetTemplate(lastItemData.Template)
					end
				elseif ObjectExists(lastItemData.Item) == 1 then
					sourceItem = GameHelpers.GetItem(lastItemData.Item)			
				end
			end
		end
	end
	return sourceItem
end

if _EXTVERSION >= 56 then
	Ext.RegisterOsirisListener("CanUseItem", 3, "after", function(charGUID, itemGUID, requestId)
		if ObjectExists(charGUID) == 1 and ObjectExists(itemGUID) == 1 then
			local skills,data = GameHelpers.Item.GetUseActionSkills(itemGUID, false, false)
			if data.IsConsumable and skills[1] then
				charGUID = StringHelpers.GetUUID(charGUID)
				itemGUID = StringHelpers.GetUUID(itemGUID)
				local item = GameHelpers.GetItem(itemGUID)
				local statsId = GameHelpers.Item.GetItemStat(item)
				local template = GameHelpers.GetTemplate(item)
				_lastUsedSkillItems[charGUID] = {
					Item = itemGUID,
					Skills = skills,
					StatsId = statsId,
					Template = template,
					DisplayName = item.DisplayName
				}
				Timer.Cancel("LeaderLib_SkillManager_RemoveLastUsedSkillItem", charGUID)
			end
		end
	end)
end

function OnSkillPreparing(char, skillprototype)
	char = StringHelpers.GetUUID(char)
	local skill = GetSkillEntryName(skillprototype)
	local last = PersistentVars.IsPreparingSkill[char]
	if last and last ~= skill then
		SkillManager.OnSkillPreparingCancel(char, "", last, true)
	end

	--(not last or last ~= skill) prevents invoke spam for PCs, since the PrepareSkill fires constantly for them
	if (_enabledSkills[skill] or _enabledSkills.All) and (not last or last ~= skill) then
		local skillData = Ext.GetStat(skill)
		local caster = GameHelpers.GetCharacter(char)
		Events.OnSkillState:Invoke({
			Character = caster,
			Skill = skill,
			State = SKILL_STATE.PREPARE,
			Data = skillData,
			DataType = "StatEntrySkillData",
			SourceItem = _GetSkillSourceItem(caster, skill),
		})
	end

	-- Clear previous data for this character in case SkillCast never fired (interrupted)
	RemoveCharacterSkillData(char)
	PersistentVars.IsPreparingSkill[char] = skill
end

function SkillManager.OnSkillPreparingCancel(char, skillprototype, skill, skipRemoval)
	skill = skill or StringHelpers.GetSkillEntryName(skillprototype)
	local skillData = Ext.GetStat(skill)
	if (_enabledSkills[skill] or _enabledSkills.All) then
		local character = GameHelpers.GetCharacter(char)
		Events.OnSkillState:Invoke({
			Character = character,
			Skill = skill,
			State = SKILL_STATE.CANCEL,
			Data = skillData,
			DataType = "StatEntrySkillData",
			SourceItem = _GetSkillSourceItem(character, skill)
		})
	end

	_lastUsedSkillItems[char] = nil

	if skipRemoval ~= true then
		SkillManager.RemoveCharacterSkillData(char)
	end
end

-- Fires when CharacterUsedSkill fires. This happens after all the target events.
function OnSkillUsed(char, skill, skillType, skillAbility)
	if ObjectExists(char) == 0 then
		return
	end
	local uuid = StringHelpers.GetUUID(char)
	if GameHelpers.Stats.IsHealingSkill(skill) then
		PersistentVars.LastUsedHealingSkill[uuid] = skill
		Timer.StartObjectTimer("LeaderLib_ClearLastUsedHealingSkill", uuid, 3000)
	end
	
	if (_enabledSkills[skill] or _enabledSkills.All) then
		local data = GetCharacterSkillData(skill, uuid, true, skillType, skillAbility)
		if data then
			local caster = GameHelpers.GetCharacter(char)
			--Quake doesn't fire any target events, but works like a shout
			if skillType == "quake" then
				data:AddTargetPosition(table.unpack(caster.WorldPos))
			end
			Events.OnSkillState:Invoke({
				Character = caster,
				Skill = skill,
				State = SKILL_STATE.USED,
				Data = data,
				DataType = data.Type,
				SourceItem = _GetSkillSourceItem(caster, skill),
			})
		end
	end
end

function OnSkillCast(char, skill, skilLType, skillAbility)
	local uuid = StringHelpers.GetUUID(char)
	if (_enabledSkills[skill] or _enabledSkills.All) then
		--Some skills may not fire any target events, like MultiStrike, so create the data if it doesn't exist.
		---@type SkillEventData
		local data = GetCharacterSkillData(skill, uuid, true, skilLType, skillAbility, Vars.DebugMode, "OnSkillCast")
		if data ~= nil then
			local character = GameHelpers.GetCharacter(char)
			if character then
				Events.OnSkillState:Invoke({
					Character = character,
					Skill = skill,
					State = SKILL_STATE.CAST,
					Data = data,
					DataType = data.Type,
					SourceItem = _GetSkillSourceItem(character, skill)
				})
			end
			data:Clear()
		end
	end
	RemoveCharacterSkillData(uuid, skill)
	Timer.StartObjectTimer("LeaderLib_SkillManager_RemoveLastUsedSkillItem", uuid, 5000, {Skill = skill})
end

Timer.Subscribe("LeaderLib_SkillManager_RemoveLastUsedSkillItem", function (e)
	if e.Data.UUID and e.Data.Skill then
		local lastItemData = _lastUsedSkillItems[e.Data.UUID]
		if lastItemData then
			if StringHelpers.Contains(lastItemData.Skills, e.Data.Skill) then
				_lastUsedSkillItems[e.Data.UUID] = nil
			end
		end
	end
end)

local function IgnoreHitTarget(target)
	if ObjectExists(target) == 0 then
		return true
	end
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
	if not IgnoreHitTarget(target.MyGuid) and (_enabledSkills[skillId] or _enabledSkills.All) then
		Events.OnSkillState:Invoke({
			Character = source,
			Skill = skillId,
			State = SKILL_STATE.HIT,
			Data = data,
			DataType = data.Type,
			SourceItem = _GetSkillSourceItem(source, skillId)
		})
	end
	InvokeListenerCallbacks(Listeners.OnSkillHit, source.MyGuid, skillId, SKILL_STATE.HIT, data)
end

---@param projectile EsvProjectile
---@param hitObject EsvGameObject
---@param position number[]
RegisterProtectedExtenderListener("ProjectileHit", function (projectile, hitObject, position)
	if not StringHelpers.IsNullOrEmpty(projectile.SkillId) then
		local skill = GetSkillEntryName(projectile.SkillId)
		if projectile.CasterHandle ~= nil and (_enabledSkills[skill] or _enabledSkills.All) then
			local object = Ext.GetGameObject(projectile.CasterHandle)
			if object then
				local uuid = object.MyGuid
				local target = hitObject ~= nil and hitObject.MyGuid or ""
				---@type ProjectileHitData
				local data = Classes.ProjectileHitData:Create(target, uuid, projectile, position, skill)
				Events.OnSkillState:Invoke({
					Character = object,
					Skill = skill,
					State = SKILL_STATE.PROJECTILEHIT,
					Data = data,
					DataType = data.Type,
					SourceItem = _GetSkillSourceItem(object, skill)
				})
				InvokeListenerCallbacks(Listeners.OnSkillHit, uuid, skill, SKILL_STATE.PROJECTILEHIT, data, data.Type)
			end
		end
	end
end)

---@param request EsvShootProjectileRequest
RegisterProtectedExtenderListener("BeforeShootProjectile", function (request)
	local skill = GetSkillEntryName(request.SkillId)
	if not StringHelpers.IsNullOrEmpty(skill) and request.Caster and (_enabledSkills[skill] or _enabledSkills.All) then
		--request.Source could be a grenade, instead of the actual caster
		local object = Ext.GetGameObject(request.Caster)
		if object then
			Events.OnSkillState:Invoke({
				Character = object,
				Skill = skill,
				State = SKILL_STATE.BEFORESHOOT,
				Data = request,
				DataType = "EsvShootProjectileRequest",
				SourceItem = _GetSkillSourceItem(object, skill)
			})
			InvokeListenerCallbacks(Listeners.OnSkillHit, object.MyGuid, skill, SKILL_STATE.BEFORESHOOT, request, "EsvShootProjectileRequest")
		end
	end
end)

---@param projectile EsvProjectile
RegisterProtectedExtenderListener("ShootProjectile", function (projectile)
	local skill = GetSkillEntryName(projectile.SkillId)
	if not StringHelpers.IsNullOrEmpty(skill) and projectile.CasterHandle and (_enabledSkills[skill] or _enabledSkills.All) then
		local object = Ext.GetGameObject(projectile.CasterHandle)
		if object then
			Events.OnSkillState:Invoke({
				Character = object,
				Skill = skill,
				State = SKILL_STATE.SHOOTPROJECTILE,
				Data = projectile,
				DataType = "EsvProjectile",
				SourceItem = _GetSkillSourceItem(object, skill)
			})
			
			InvokeListenerCallbacks(Listeners.OnSkillHit, object.MyGuid, skill, SKILL_STATE.SHOOTPROJECTILE, projectile, "EsvProjectile")
		end
	end
end)

RegisterProtectedOsirisListener("SkillAdded", Data.OsirisEvents.SkillAdded, "after", function(uuid, skill, learned)
	if ObjectExists(uuid) == 0 then
		return
	end
	uuid = StringHelpers.GetUUID(uuid)
	learned = learned == 1 and true or false
	if (_enabledSkills[skill] or _enabledSkills.All) then
		local character = GameHelpers.GetCharacter(uuid)
		if character then
			local sourceItem = _GetSkillSourceItem(character, skill, true)
			if sourceItem then
				--This item is probably going to be deleted, so it's safe to clear immediately
				Timer.Cancel("LeaderLib_SkillManager_RemoveLastUsedSkillItem", character)
				_lastUsedSkillItems[uuid] = nil
			end
			Events.OnSkillState:Invoke({
				Character = character,
				Skill = skill,
				State = SKILL_STATE.LEARNED,
				Data = learned,
				DataType = "boolean",
				SourceItem = sourceItem
			})
		end
	end
end)

RegisterProtectedOsirisListener("SkillActivated", Data.OsirisEvents.SkillActivated, "after", function(uuid, skill)
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
		if (_enabledSkills[skill] or _enabledSkills.All) then
			Events.OnSkillState:Invoke({
				Character = character,
				Skill = skill,
				State = SKILL_STATE.MEMORIZED,
				Data = learned,
				DataType = "boolean",
				SourceItem = _GetSkillSourceItem(character, skill)
			})
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
		if (_enabledSkills[skill] or _enabledSkills.All) then
			Events.OnSkillState:Invoke({
				Character = character,
				Skill = skill,
				State = SKILL_STATE.UNMEMORIZED,
				Data = learned,
				DataType = "boolean",
				SourceItem = _GetSkillSourceItem(character, skill)
			})
		end
	end
end)

RegisterProtectedOsirisListener("NRD_OnActionStateEnter", 2, "after", function(char, state)
	if state == "PrepareSkill" and ObjectExists(char) == 1 then
		local skillprototype = NRD_ActionStateGetString(char, "SkillId")
		if not StringHelpers.IsNullOrEmpty(skillprototype) then
			OnSkillPreparing(char, skillprototype)
		end
	end
end)

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


---@private
function SkillManager.RemoveCharacterSkillData(uuid, skill)
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

--- Gets the base skill from a skill.
--- @param skill string The skill entry to check.
--- @return string The base skill, if any, otherwise the skill that was passed in.
function SkillManager.GetBaseSkill(skill, match)
	if skill ~= nil then
		local checkParent = true
		if match ~= nil and match ~= "" and not string.find(skill, match) then
			checkParent = false
		end
		if checkParent then
			local skill = Ext.StatGetAttribute(skill, "Using")
			if skill ~= nil then
				return SkillManager.GetBaseSkill(skill, match)
			end
		end
	end
	return skill
end

function SkillManager.LoadSaveData()
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

function SkillManager.CheckPreparingState(uuid)
	local last = PersistentVars.IsPreparingSkill[uuid]
	if last then
		local action = NRD_CharacterGetCurrentAction(uuid) or ""
		local skill = StringHelpers.GetSkillEntryName(NRD_ActionStateGetString(uuid, "SkillId") or "")
		if StringHelpers.IsNullOrEmpty(skill) or (action ~= "PrepareSkill" and action ~= "UseSkill") or skill ~= last then
			SkillManager.OnSkillPreparingCancel(uuid, "", last)
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
					SkillManager.OnSkillPreparingCancel(character.MyGuid, skillPrototype)
				end
			end
		end
	end
end)

--When the active skill on hotBar or bottomBar_c is cleared
Ext.RegisterNetListener("LeaderLib_OnActiveSkillCleared", function(cmd, id)
	if not StringHelpers.IsNullOrWhitespace(id) then
		local character = Ext.GetCharacter(tonumber(id))
		if character then
			Timer.StartOneshot("Timers_LeaderLib_OnActiveSkillCleared", 50, function()
				SkillManager.CheckPreparingState(character.MyGuid)
			end)
		end
	end
end)

---@class LeaderLibSkillManagerRegistration
local _REGISTER = {}

---@param state SKILL_STATE
---@param matchState SKILL_STATE|SKILL_STATE[]
---@param matchStateType string
---@return boolean
local function SkillStateMatches(state, matchState, matchStateType)
	if not matchState then
		return true
	end
	if matchStateType == "table" then
		return TableHelpers.HasValue(matchState, state)
	elseif matchStateType == "string" then
		return matchState == state
	end
	return true
end

---Registers a function to call when a specific skill or array of skills has a skill event. This function fires for all skill events unless otherwise specified.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateAllEventArgs)
---@param onlySkillState SKILL_STATE|SKILL_STATE[]|nil If set, the callback will only fire for specified skill states.
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.All(skill, callback, onlySkillState, priority, once)
	local t = type(skill)
	if t == "table" then
		local indexes = {}
		for _,v in pairs(skill) do
			if not Data.ActionSkills[v] then
				local index = _REGISTER.All(v, callback, onlySkillState, priority, once)
				if index then
					indexes[#indexes+1] = index
				end
			else
				fprint(LOGLEVEL.WARNING, "[SkillManager.Register.All] Skill (%s) is a hotbar action, and not an actual skill. Skipping.", v)
			end
		end
		return indexes
	elseif t == "string" then
		if Data.ActionSkills[skill] then
			fprint(LOGLEVEL.WARNING, "[SkillManager.Register.All] Skill (%s) is a hotbar action, and not an actual skill. Skipping.", skill)
			return nil
		end
		local callbackWrapper = nil
		if not onlySkillState then
			callbackWrapper = callback
		else
			local matchStateType = type(onlySkillState)
			---@param e OnSkillStateAllEventArgs
			callbackWrapper = function(e)
				if SkillStateMatches(e.State, onlySkillState, matchStateType) then
					callback(e)
				end
			end
		end
		local opts = {Priority = priority, Once=once}
		if not StringHelpers.Equals(skill, "All", true) then
			_enabledSkills[skill] = true
			opts.MatchArgs={Skill=skill}
		else
			_enabledSkills.All = true
		end
		return Events.OnSkillState:Subscribe(callbackWrapper, opts)
	end
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.PREPARE event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStatePrepareEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.Prepare(skill, callback, priority, once)
	return _REGISTER.All(skill, callback, SKILL_STATE.PREPARE, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.CANCEL event (when the skill preparation is cancelled).
---@param skill string|string[]
---@param callback fun(e:OnSkillStatePrepareEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.Cancel(skill, callback, priority, once)
	return _REGISTER.All(skill, callback, SKILL_STATE.CANCEL, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.USED event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateSkillEventEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.Used(skill, callback, priority, once)
	return _REGISTER.All(skill, callback, SKILL_STATE.USED, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.CAST event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateSkillEventEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.Cast(skill, callback, priority, once)
	return _REGISTER.All(skill, callback, SKILL_STATE.CAST, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.HIT event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateHitEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.Hit(skill, callback, priority, once)
	return _REGISTER.All(skill, callback, SKILL_STATE.HIT, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.BEFORESHOOT event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateBeforeProjectileShootEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.BeforeProjectileShoot(skill, callback, priority, once)
	return _REGISTER.All(skill, callback, SKILL_STATE.BEFORESHOOT, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.SHOOTPROJECTILE event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateProjectileShootEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.ProjectileShoot(skill, callback, priority, once)
	return _REGISTER.All(skill, callback, SKILL_STATE.SHOOTPROJECTILE, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.PROJECTILEHIT event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateProjectileHitEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.ProjectileHit(skill, callback, priority, once)
	return _REGISTER.All(skill, callback, SKILL_STATE.PROJECTILEHIT, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.LEARNED event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateLearnedEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.Learned(skill, callback, priority, once)
	return _REGISTER.All(skill, callback, SKILL_STATE.LEARNED, priority, once)
end

local _MemorizationStates = {SKILL_STATE.MEMORIZED, SKILL_STATE.UNMEMORIZED}

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.UNMEMORIZED or SKILL_STATE.MEMORIZED event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateMemorizedEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function _REGISTER.MemorizationChanged(skill, callback, priority, once)
	return _REGISTER.All(skill, callback, _MemorizationStates, priority, once)
end

SkillManager.Register = _REGISTER