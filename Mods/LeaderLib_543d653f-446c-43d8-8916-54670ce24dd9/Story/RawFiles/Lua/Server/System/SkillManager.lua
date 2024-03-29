---A temporary table used to store data for a skill, including targets / skill information.
---@type table<string,SkillEventData>
local skillEventDataTable = {}

---@private
SkillManager.SkillEventDataTable = skillEventDataTable

---A temporary table used to store data for a skill, including targets / skill information.
---@type table<string,SkillEventData>
local skillEventDataTable = {}

local _CreateSkillEventTable = SkillManager._Internal.CreateSkillEventTable
local _GetSkillSourceItem = SkillManager._Internal.GetSkillSourceItem
local _lastUsedSkillItems = SkillManager._Internal.LastUsedSkillItems

---@alias LeaderLibSkillListenerDataType string|"boolean"|"StatEntrySkillData"|"HitData"|"ProjectileHitData"|"SkillEventData"|"EsvShootProjectileRequest"

---@alias LeaderLibSkillListenerCallback fun(skill:string, char:string, state:SKILL_STATE, data:SkillEventData|HitData|ProjectileHitData|StatEntrySkillData|boolean, dataType:LeaderLibSkillListenerDataType)

local _EXTVERSION = Ext.Utils.Version()

local _IgnoreStateForDeprecated = {
	[SKILL_STATE.GETAPCOST] = true,
	[SKILL_STATE.GETDAMAGE] = true,
}

---@param e OnSkillStateAllEventArgs
local function _IsOldState(e)
	return _IgnoreStateForDeprecated[e.State] ~= true
end

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
			SkillManager.EnableForAllSkills(true)
			Events.OnSkillState:Subscribe(function (e)
				callback(e.Skill, e.CharacterGUID, e.State, e.Data, e.DataType)
			end, {MatchArgs=_IsOldState})
		else
			SkillManager.SetSkillEnabled(skill, true)
			Events.OnSkillState:Subscribe(function (e)
				callback(e.Skill, e.CharacterGUID, e.State, e.Data, e.DataType)
			end, {MatchArgs=function (e)
				return e.Skill == skill and _IsOldState(e)
			end})
		end

		if Vars.Initialized then
			Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaSkillListeners_Enabled", "LeaderLib")
			Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaEventListeners_Enabled", "LeaderLib")
		else
			Vars.PostLoadEnableLuaListeners = true
		end
	elseif t == "table" then
		for i,v in pairs(skill) do
			---@diagnostic disable-next-line
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
			---@diagnostic disable-next-line
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
		if Vars.DebugMode and printWarning and Osi.CharacterIsPlayer(uuid) == 1 then
			fprint(LOGLEVEL.WARNING, "[LeaderLib:OnSkillCast] No skill data for character (%s) and skill (%s) Context(%s)", uuid, skill, printContext or "")
		end
		data = Classes.SkillEventData:Create(uuid, skill, skillType, skillAbility)
		skillDataHolder[uuid] = data
	end
	if data then
		_PV.SkillData[uuid] = data:Serialize()
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
	_PV.IsPreparingSkill[uuid] = nil
	_PV.SkillData[uuid] = nil
end

function StoreSkillEventData(char, skill, skillType, skillAbility, ...)
	if SkillManager.IsSkillEnabled(skill) then
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

Events.Osiris.CanUseItem:Subscribe(function(e)
	local skills,data = GameHelpers.Item.GetUseActionSkills(e.Item, false, false)
	if data.IsConsumable and skills[1] then
		local statsId = GameHelpers.Item.GetItemStat(e.Item)
		local template = GameHelpers.GetTemplate(e.Item)
		_lastUsedSkillItems[e.CharacterGUID] = {
			Item = e.ItemGUID,
			Skills = skills,
			StatsId = statsId,
			Template = template,
			DisplayName = GameHelpers.GetDisplayName(e.Item)
		}
		Timer.Cancel("LeaderLib_SkillManager_RemoveLastUsedSkillItem", e.Character)
	end
end)

function OnSkillPreparing(char, skillprototype)
	char = StringHelpers.GetUUID(char)
	local skill = GetSkillEntryName(skillprototype)
	local last = _PV.IsPreparingSkill[char]
	if last and last ~= skill then
		SkillManager.OnSkillPreparingCancel(char, "", last, true)
	end

	--(not last or last ~= skill) prevents invoke spam for PCs, since the PrepareSkill fires constantly for them
	if SkillManager.IsSkillEnabled(skill) and (not last or last ~= skill) then
		local skillData = Ext.Stats.Get(skill, nil, false) or {Ability=""}
		local character = GameHelpers.GetCharacter(char)
		_CreateSkillEventTable(skill, character, SKILL_STATE.PREPARE, skillData, "StatEntrySkillData")
		Events.OnSkillState:Invoke(_CreateSkillEventTable(skill, character, SKILL_STATE.PREPARE, skillData, "StatEntrySkillData"))
	end

	-- Clear previous data for this character in case SkillCast never fired (interrupted)
	RemoveCharacterSkillData(char)
	_PV.IsPreparingSkill[char] = skill
end

function SkillManager.OnSkillPreparingCancel(char, skillprototype, skill, skipRemoval)
	skill = skill or StringHelpers.GetSkillEntryName(skillprototype)
	local skillData = Ext.Stats.Get(skill, nil, false) or {Ability=""}
	if SkillManager.IsSkillEnabled(skill) then
		local character = GameHelpers.GetCharacter(char)
		Events.OnSkillState:Invoke(_CreateSkillEventTable(skill, character, SKILL_STATE.CANCEL, skillData, "StatEntrySkillData"))
	end

	_lastUsedSkillItems[char] = nil

	if skipRemoval ~= true then
		SkillManager.RemoveCharacterSkillData(char)
	end
end

-- Fires when CharacterUsedSkill fires. This happens after all the target events.
function OnSkillUsed(char, skill, skillType, skillAbility)
	if Osi.ObjectExists(char) == 0 then
		return
	end
	local uuid = StringHelpers.GetUUID(char)
	if GameHelpers.Stats.IsHealingSkill(skill) then
		_PV.LastUsedHealingSkill[uuid] = skill
		Timer.StartObjectTimer("LeaderLib_ClearLastUsedHealingSkill", uuid, 3000)
	end
	
	if SkillManager.IsSkillEnabled(skill) then
		local data = GetCharacterSkillData(skill, uuid, true, skillType, skillAbility)
		if data then
			local character = GameHelpers.GetCharacter(char)
			if character then
				local eventData = _CreateSkillEventTable(skill, character, SKILL_STATE.USED, data, data.Type)
				if data.TotalTargetObjects == 0 and data.TotalTargetPositions == 0 then
					--Quake doesn't fire any target events, but works like a shout
					if skillType == "quake" then
						data:AddTargetPosition(table.unpack(character.WorldPos))
					elseif skillType == "zone" or skillType == "cone" then
						--The end point of the cone can be considered the target position
						local range = data.SkillData.Range
						local endPos = GameHelpers.Math.GetForwardPosition(character, range)
						data:AddTargetPosition(endPos)
					end
				end
				Events.OnSkillState:Invoke(eventData)
			end
		end
	end
end

function OnSkillCast(char, skill, skillType, skillAbility)
	local uuid = StringHelpers.GetUUID(char)
	if SkillManager.IsSkillEnabled(skill) then
		--Some skills may not fire any target events, like MultiStrike, so create the data if it doesn't exist.
		---@type SkillEventData
		local data = GetCharacterSkillData(skill, uuid, true, skillType, skillAbility, Vars.DebugMode, "OnSkillCast")
		if data ~= nil then
			local character = GameHelpers.GetCharacter(char)
			if character then
				local eventData = _CreateSkillEventTable(skill, character, SKILL_STATE.CAST, data, data.Type)
				if data.TotalTargetObjects == 0 and data.TotalTargetPositions == 0 then
					--Quake doesn't fire any target events, but works like a shout
					if skillType == "quake" then
						data:AddTargetPosition(table.unpack(character.WorldPos))
					elseif skillType == "zone" or skillType == "cone" then
						--The end point of the cone can be considered the target position
						local range = data.SkillData.Range
						local endPos = GameHelpers.Math.GetForwardPosition(character, range)
						data:AddTargetPosition(endPos)
					end
				end
				Events.OnSkillState:Invoke(eventData)
			end
			data:Clear()
		end
	end
	RemoveCharacterSkillData(uuid, skill)
	Timer.StartObjectTimer("LeaderLib_SkillManager_RemoveLastUsedSkillItem", uuid, 5000, {Skill=skill})
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
	if Osi.ObjectExists(target) == 0 then
		return true
	end
	if Osi.IsTagged(target, "MovingObject") == 1 then
		return true
	elseif Osi.ObjectIsCharacter(target) == 1 and Osi.LeaderLib_Helper_QRY_IgnoreCharacter(target) == true then
		return true
	elseif Osi.ObjectIsItem(target) == 1 and Osi.LeaderLib_Helper_QRY_IgnoreItem(target) == true then
		return true
	end
	return false
end

--- @param skillId string
--- @param target EsvCharacter|EsvItem
--- @param source EsvCharacter|EsvItem
--- @param damage integer
--- @param hit StatsHitDamageInfo
--- @param context EsvPendingHit
--- @param hitStatus EsvStatusHit
--- @param data HitData|ProjectileHitData
function OnSkillHit(skillId, target, source, damage, hit, context, hitStatus, data)
	if not IgnoreHitTarget(target.MyGuid) and SkillManager.IsSkillEnabled(skillId) then
		Events.OnSkillState:Invoke(_CreateSkillEventTable(skillId, source, SKILL_STATE.HIT, data, data.Type))
		---@diagnostic disable-next-line
		InvokeListenerCallbacks(Listeners.OnSkillHit, source.MyGuid, skillId, SKILL_STATE.HIT, data)
	end
end

Ext.Events.ProjectileHit:Subscribe(function (e)
	if Ext.Utils.IsValidHandle(e.Projectile.CasterHandle) then
		local projectile = e.Projectile
		local skill = GetSkillEntryName(projectile.SkillId)
		if not StringHelpers.IsNullOrEmpty(projectile.SkillId) and SkillManager.IsSkillEnabled(skill) then
			local caster = GameHelpers.TryGetObject(projectile.CasterHandle)
			if caster then
				local uuid = caster.MyGuid
				local target = e.HitObject and e.HitObject.MyGuid or ""
				---@type ProjectileHitData
				local data = Classes.ProjectileHitData:Create(target, uuid, projectile, e.Position, skill)
				Events.OnSkillState:Invoke(_CreateSkillEventTable(skill, caster, SKILL_STATE.PROJECTILEHIT, data, data.Type))
				---@diagnostic disable-next-line
				InvokeListenerCallbacks(Listeners.OnSkillHit, uuid, skill, SKILL_STATE.PROJECTILEHIT, data, data.Type)
			end
		end
	end
end, {Priority=0})

Ext.Events.BeforeShootProjectile:Subscribe(function (e)
	if Ext.Utils.IsValidHandle(e.Projectile.Caster) then
		local projectile = e.Projectile
		local skill = GetSkillEntryName(projectile.SkillId)
		if not StringHelpers.IsNullOrEmpty(skill) and SkillManager.IsSkillEnabled(skill) then
			--request.Source could be a grenade, instead of the actual character
			local caster =  GameHelpers.TryGetObject(projectile.Caster)
			if caster then
				Events.OnSkillState:Invoke(_CreateSkillEventTable(skill, caster, SKILL_STATE.BEFORESHOOT, projectile, "EsvShootProjectileRequest"))
			end
		end
	end
end, {Priority=0})

Ext.Events.ShootProjectile:Subscribe(function(e)
	if Ext.Utils.IsValidHandle(e.Projectile.CasterHandle) then
		local projectile = e.Projectile
		local skill = GetSkillEntryName(projectile.SkillId)
		if not StringHelpers.IsNullOrEmpty(skill) and SkillManager.IsSkillEnabled(skill) then
			local caster = GameHelpers.TryGetObject(projectile.CasterHandle)
			if caster then
				Events.OnSkillState:Invoke(_CreateSkillEventTable(skill, caster, SKILL_STATE.SHOOTPROJECTILE, projectile, "EsvProjectile"))
			end
		end
	end
end, {Priority=0})

RegisterProtectedOsirisListener("SkillAdded", Data.OsirisEvents.SkillAdded, "after", function(uuid, skill, learnedINT)
	if Osi.ObjectExists(uuid) == 0 then
		return
	end
	uuid = StringHelpers.GetUUID(uuid)
	if SkillManager.IsSkillEnabled(skill) then
		local character = GameHelpers.GetCharacter(uuid)
		if character then
			local sourceItem = _GetSkillSourceItem(character, skill, true)
			if sourceItem then
				--This item is probably going to be deleted, so it's safe to clear immediately
				Timer.Cancel("LeaderLib_SkillManager_RemoveLastUsedSkillItem", character)
				_lastUsedSkillItems[uuid] = nil
			end
			local learned = false
			local memorized = false
			local skillInfo = character:GetSkillInfo(skill)
			if skillInfo then
				learned = skillInfo.IsLearned or #skillInfo.CauseList > 0
				memorized = skillInfo.IsActivated or #skillInfo.CauseList > 0
			end
			local data = _CreateSkillEventTable(skill, character, SKILL_STATE.LEARNED, learned, "boolean")
			data.Learned = learned
			data.Memorized = memorized
			Events.OnSkillState:Invoke(data)
		end
	end
end)

RegisterProtectedOsirisListener("SkillActivated", Data.OsirisEvents.SkillActivated, "after", function(uuid, skill)
	if Osi.ObjectExists(uuid) == 0 then
		return
	end
	uuid = StringHelpers.GetUUID(uuid)
	local character = GameHelpers.GetCharacter(uuid)
	if character then
		local learned = false
		local memorized = false
		local skillInfo = character:GetSkillInfo(skill)
		if skillInfo then
			learned = skillInfo.IsLearned or #skillInfo.CauseList > 0
			memorized = skillInfo.IsActivated or #skillInfo.CauseList > 0
		end
		if SkillManager.IsSkillEnabled(skill) then
			local data = _CreateSkillEventTable(skill, character, SKILL_STATE.MEMORIZED, true, "boolean")
			data.Learned = learned
			data.Memorized = memorized
			Events.OnSkillState:Invoke(data)
		end
	end
end)

RegisterProtectedOsirisListener("SkillDeactivated", Data.OsirisEvents.SkillDeactivated, "before", function(uuid, skill)
	if Osi.ObjectExists(uuid) == 0 then
		return
	end
	uuid = StringHelpers.GetUUID(uuid)
	local learned = false
	local character = GameHelpers.GetCharacter(uuid)
	if character then
		local skillInfo = character:GetSkillInfo(skill)
		if skillInfo then
			learned = skillInfo.IsLearned or skillInfo.ZeroMemory
		end
		if SkillManager.IsSkillEnabled(skill) then
			local data = _CreateSkillEventTable(skill, character, SKILL_STATE.UNMEMORIZED, false, "boolean")
			data.Learned = learned
			Events.OnSkillState:Invoke(data)
			if not learned then
				data = _CreateSkillEventTable(skill, character, SKILL_STATE.LEARNED, false, "boolean")
				data.Memorized = false
				Events.OnSkillState:Invoke(data)
			end
		end
	end
end)

RegisterProtectedOsirisListener("NRD_OnActionStateEnter", 2, "after", function(char, state)
	if state == "PrepareSkill" and Osi.ObjectExists(char) == 1 then
		local skillprototype = Osi.NRD_ActionStateGetString(char, "SkillId")
		if not StringHelpers.IsNullOrEmpty(skillprototype) then
			OnSkillPreparing(char, skillprototype)
		end
	end
end)

-- Ext.Osiris.RegisterListener("NRD_OnActionStateExit", Data.OsirisEvents.NRD_OnActionStateExit, "after", function(char, state)
-- 	if state == "PrepareSkill" then
-- 		local skillprototype = NRD_ActionStateGetString(char, "SkillId")
-- 		if skillprototype ~= nil and skillprototype ~= "" then
-- 			OnSkillPreparing(char, skillprototype)
-- 		end
-- 	end
-- end)

-- Ext.Osiris.RegisterListener("CharacterUsedSkillOnTarget", 5, "after", function(char, target, skill, skilltype, element)
-- 	StoreSkillEventData(char, skill, skilltype, element, target)
-- end)

-- Ext.Osiris.RegisterListener("CharacterUsedSkillAtPosition", 7, "after", function(char, x, y, z, skill, skilltype, element)
-- 	StoreSkillEventData(char, skill, skilltype, element, x, y, z)
-- end)

-- Ext.Osiris.RegisterListener("CharacterUsedSkillOnZoneWithTarget", 5, "after", function(char, target, skill, skilltype, element)
-- 	StoreSkillEventData(char, skill, skilltype, element, target)
-- end)

-- Ext.Osiris.RegisterListener("CharacterUsedSkill", 4, "after", function(char, skill, skilltype, element)
-- 	OnSkillUsed(char, skill, skilltype, element)
-- end)

-- Ext.Osiris.RegisterListener("SkillCast", 4, "after", function(char, skill, skilltype, element)
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
	_PV.IsPreparingSkill[uuid] = nil
	_PV.SkillData[uuid] = nil
end

--- Gets the base skill from a skill.
--- @param skill string The skill entry to check.
--- @return string|nil skill The base skill, if any, otherwise the skill that was passed in.
function SkillManager.GetBaseSkill(skill, match)
	if skill ~= nil then
		local checkParent = true
		if match ~= nil and match ~= "" and not string.find(skill, match) then
			checkParent = false
		end
		if checkParent then
			local stat = Ext.Stats.Get(skill, nil, false)
			if stat and not StringHelpers.IsNullOrEmpty(stat.Using) then
				return SkillManager.GetBaseSkill(stat.Using, match)
			end
		end
	end
	return skill
end

function SkillManager.LoadSaveData()
	if _PV.SkillData then
		for uuid,tbl in pairs(_PV.SkillData) do
			if Osi.ObjectExists(uuid) == 1 and not StringHelpers.IsNullOrWhitespace(tbl.Skill) and GameHelpers.Stats.Exists(tbl.Skill, "SkillData") then
				local data = Classes.SkillEventData:Create(uuid, "", "", "")
				data:LoadFromSave(tbl)
				if skillEventDataTable[data.Skill] == nil then
					skillEventDataTable[data.Skill] = {}
				end
				skillEventDataTable[data.Skill][uuid] = data
			else
				_PV.SkillData[uuid] = nil
			end
		end
	end
end

function SkillManager.CheckPreparingState(uuid)
	local last = _PV.IsPreparingSkill[uuid]
	if last then
		local action = Osi.NRD_CharacterGetCurrentAction(uuid) or ""
		local skill = StringHelpers.GetSkillEntryName(Osi.NRD_ActionStateGetString(uuid, "SkillId") or "")
		if StringHelpers.IsNullOrEmpty(skill) or (action ~= "PrepareSkill" and action ~= "UseSkill") or skill ~= last then
			SkillManager.OnSkillPreparingCancel(uuid, "", last)
		end
	end
end

--When the ActionCancel button is pressed.
Ext.RegisterNetListener("LeaderLib_Input_OnActionCancel", function(cmd, payload)
	if not StringHelpers.IsNullOrEmpty(payload) then
		local netid = tonumber(payload)
		local character = GameHelpers.GetCharacter(netid)
		if character then
			local action = Osi.NRD_CharacterGetCurrentAction(character.MyGuid) or ""
			if action == "PrepareSkill" then
				local skillPrototype = Osi.NRD_ActionStateGetString(character.MyGuid, "SkillId")
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
		local character = GameHelpers.GetCharacter(tonumber(id))
		if character then
			local guid = character.MyGuid
			Timer.StartOneshot("Timers_LeaderLib_OnActiveSkillCleared", 50, function()
				SkillManager.CheckPreparingState(guid)
			end)
		end
	end
end)

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
---@param onlySkillState? SKILL_STATE|SKILL_STATE[] If set, the callback will only fire for specified skill states.
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[]|nil index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.All(skill, callback, onlySkillState, priority, once)
	local t = type(skill)
	if t == "table" then
		local indexes = {}
		for _,v in pairs(skill) do
			if not GameHelpers.Stats.IsAction(v) then
				local index = SkillManager.Register.All(v, callback, onlySkillState, priority, once)
				if index then
					indexes[#indexes+1] = index
				end
			else
				fprint(LOGLEVEL.WARNING, "[SkillManager.Register.All] Skill (%s) is a hotbar action, and not an actual skill. Skipping.", v)
			end
		end
		return indexes
	elseif t == "string" then
		if GameHelpers.Stats.IsAction(skill) then
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
			SkillManager.SetSkillEnabled(skill, true)
			opts.MatchArgs={Skill=skill}
		else
			SkillManager.EnableForAllSkills(true)
		end
		return Events.OnSkillState:Subscribe(callbackWrapper, opts)
	end
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.PREPARE event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStatePrepareEventArgs)
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.Prepare(skill, callback, priority, once)
	return SkillManager.Register.All(skill, callback, SKILL_STATE.PREPARE, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.CANCEL event (when the skill preparation is cancelled).
---@param skill string|string[]
---@param callback fun(e:OnSkillStatePrepareEventArgs)
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.Cancel(skill, callback, priority, once)
	return SkillManager.Register.All(skill, callback, SKILL_STATE.CANCEL, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.USED event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateSkillEventEventArgs)
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.Used(skill, callback, priority, once)
	return SkillManager.Register.All(skill, callback, SKILL_STATE.USED, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.CAST event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateSkillEventEventArgs)
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.Cast(skill, callback, priority, once)
	return SkillManager.Register.All(skill, callback, SKILL_STATE.CAST, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.HIT event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateHitEventArgs)
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.Hit(skill, callback, priority, once)
	return SkillManager.Register.All(skill, callback, SKILL_STATE.HIT, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.BEFORESHOOT event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateBeforeProjectileShootEventArgs)
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.BeforeProjectileShoot(skill, callback, priority, once)
	return SkillManager.Register.All(skill, callback, SKILL_STATE.BEFORESHOOT, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.SHOOTPROJECTILE event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateProjectileShootEventArgs)
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.ProjectileShoot(skill, callback, priority, once)
	return SkillManager.Register.All(skill, callback, SKILL_STATE.SHOOTPROJECTILE, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.PROJECTILEHIT event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateProjectileHitEventArgs)
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.ProjectileHit(skill, callback, priority, once)
	return SkillManager.Register.All(skill, callback, SKILL_STATE.PROJECTILEHIT, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.LEARNED event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateLearnedEventArgs)
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.Learned(skill, callback, priority, once)
	return SkillManager.Register.All(skill, callback, SKILL_STATE.LEARNED, priority, once)
end

local _MemorizationStates = {SKILL_STATE.MEMORIZED, SKILL_STATE.UNMEMORIZED}

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.UNMEMORIZED or SKILL_STATE.MEMORIZED event.
---@param skill string|string[]
---@param callback fun(e:OnSkillStateMemorizedEventArgs)
---@param priority? integer Optional listener priority
---@param once? boolean If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[] index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.MemorizationChanged(skill, callback, priority, once)
	return SkillManager.Register.All(skill, callback, _MemorizationStates, priority, once)
end