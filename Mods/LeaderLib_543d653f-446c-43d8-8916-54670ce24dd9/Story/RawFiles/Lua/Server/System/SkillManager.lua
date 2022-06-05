if SkillManager == nil then
	SkillManager = {}
end

---A temporary table used to store data for a skill, including targets / skill information.
---@type table<string,SkillEventData>
local skillEventDataTable = {}

---@private
SkillManager.SkillEventDataTable = skillEventDataTable

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

---@private
---@param skill string
---@return fun():LeaderLibSkillListenerCallback
function SkillManager.GetListeners(skill)
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

function SkillManager.OnSkillPreparingCancel(char, skillprototype, skill, skipRemoval)
	skill = skill or StringHelpers.GetSkillEntryName(skillprototype)
	local skillData = Ext.GetStat(skill)
	for callback in SkillManager.GetListeners(skill) do
		--PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillPreparing] char(",char,") skillprototype(",skillprototype,") skill(",skill,")")
		local status,err = xpcall(callback, debug.traceback, skill, char, SKILL_STATE.CANCEL, skillData, "StatEntrySkillData")
		if not status then
			Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
		end
	end

	if skipRemoval ~= true then
		SkillManager.RemoveCharacterSkillData(char)
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

SkillManager.Register = {}

local _ListenersToRegister = {}
local _SessionInitialized = false
setmetatable(_ListenersToRegister, {__mode =" kv"})

local function SortListenersByPriority(a,b)
	return a.Priority < b.Priority
end

Ext.RegisterListener("SessionLoaded", function ()
	local count = #_ListenersToRegister
	if count > 0 then
		table.sort(_ListenersToRegister, SortListenersByPriority)
		for i=1,count do
			local entry = _ListenersToRegister[i]
			if entry.Callback ~= nil then
				RegisterSkillListener(entry.Skill, entry.Callback)
			end
		end
		_ListenersToRegister = {}
	end
	_SessionInitialized = true
end)

---@alias SkillManagerAllStateCallback fun(skill:string, caster:EsvCharacter, state:SKILL_STATE, data:SkillEventData|HitData|ProjectileHitData|StatEntrySkillData|EsvProjectile|boolean, dataType:LeaderLibSkillListenerDataType)
---@alias SkillManagerPrepareCallback fun(skill:string, caster:EsvCharacter, state:SKILL_STATE, skill:SkillEventData, dataType:LeaderLibSkillListenerDataType)
---@alias SkillManagerSkillEventCallback fun(skill:string, caster:EsvCharacter, state:SKILL_STATE, data:SkillEventData, dataType:LeaderLibSkillListenerDataType)
---@alias SkillManagerHitCallback fun(skill:string, caster:EsvCharacter, state:SKILL_STATE, data:HitData, dataType:LeaderLibSkillListenerDataType)
---@alias SkillManagerBeforeProjectileShootCallback fun(skill:string, caster:EsvCharacter, state:SKILL_STATE, projectileRequest:EsvShootProjectileRequest, dataType:LeaderLibSkillListenerDataType)
---@alias SkillManagerProjectileShootCallback fun(skill:string, caster:EsvCharacter, state:SKILL_STATE, projectile:EsvProjectile, dataType:LeaderLibSkillListenerDataType)
---@alias SkillManagerProjectileHitCallback fun(skill:string, caster:EsvCharacter, state:SKILL_STATE, data:ProjectileHitData, dataType:LeaderLibSkillListenerDataType)
---@alias SkillManagerMemorizationChangedCallback fun(skill:string, caster:EsvCharacter, state:SKILL_STATE, memorized:boolean, dataType:LeaderLibSkillListenerDataType)
---@alias SkillManagerLearnedCallback fun(skill:string, caster:EsvCharacter, state:SKILL_STATE, learned:boolean, dataType:LeaderLibSkillListenerDataType)

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
---@param callback SkillManagerAllStateCallback
---@param onlySkillState SKILL_STATE|SKILL_STATE[]|nil If set, the callback will only fire for specified skill states.
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
function SkillManager.Register.All(skill, callback, onlySkillState, priority, once)
	---@type LeaderLibSkillListenerCallback
	local callbackWrapper = nil
	if once then
		if not onlySkillState then
			callbackWrapper = function(id, uuid, state, data, dataType)
				local caster = Ext.GetGameObject(uuid)
				local b,err = xpcall(callback, debug.traceback, id, caster, state, data, dataType)
				if not b then
					Ext.PrintError(err)
				end
				RemoveSkillListener(skill, callbackWrapper)
			end
		else
			local matchStateType = type(onlySkillState)
			callbackWrapper = function(id, uuid, state, data, dataType)
				if not SkillStateMatches(state, onlySkillState, matchStateType) then
					return
				end
				local caster = Ext.GetGameObject(uuid)
				local b,err = xpcall(callback, debug.traceback, id, caster, state, data, dataType)
				if not b then
					Ext.PrintError(err)
				end
				RemoveSkillListener(skill, callbackWrapper)
			end
		end
	else
		if not onlySkillState then
			callbackWrapper = function(id, uuid, state, data, dataType)
				local caster = Ext.GetGameObject(uuid)
				local b,err = xpcall(callback, debug.traceback, id, caster, state, data, dataType)
				if not b then
					Ext.PrintError(err)
				end
			end
		else
			local matchStateType = type(onlySkillState)
			callbackWrapper = function(id, uuid, state, data, dataType)
				if not SkillStateMatches(state, onlySkillState, matchStateType) then
					return
				end
				local caster = Ext.GetGameObject(uuid)
				local b,err = xpcall(callback, debug.traceback, id, caster, state, data, dataType)
				if not b then
					Ext.PrintError(err)
				end
			end
		end
	end
	if not _SessionInitialized then
		table.insert(_ListenersToRegister, {
			Callback = callbackWrapper,
			Skill = skill,
			Priority = priority or 100
		})
	else
		--TODO Store priorities somewhere for use later here? Support registering skill listeners after the fact.
		RegisterSkillListener(skill, callbackWrapper)
	end
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.PREPARE event.
---@param skill string|string[]
---@param callback SkillManagerPrepareCallback
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
function SkillManager.Register.Prepare(skill, callback, priority, once)
	SkillManager.Register.All(skill, callback, SKILL_STATE.PREPARE, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.USED event.
---@param skill string|string[]
---@param callback SkillManagerSkillEventCallback
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
function SkillManager.Register.Used(skill, callback, priority, once)
	SkillManager.Register.All(skill, callback, SKILL_STATE.USED, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.CAST event.
---@param skill string|string[]
---@param callback SkillManagerSkillEventCallback
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
function SkillManager.Register.Cast(skill, callback, priority, once)
	SkillManager.Register.All(skill, callback, SKILL_STATE.CAST, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.HIT event.
---@param skill string|string[]
---@param callback SkillManagerHitCallback
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
function SkillManager.Register.Hit(skill, callback, priority, once)
	SkillManager.Register.All(skill, callback, SKILL_STATE.HIT, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.BEFORESHOOT event.
---@param skill string|string[]
---@param callback SkillManagerBeforeProjectileShootCallback
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
function SkillManager.Register.BeforeProjectileShoot(skill, callback, priority, once)
	SkillManager.Register.All(skill, callback, SKILL_STATE.BEFORESHOOT, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.SHOOTPROJECTILE event.
---@param skill string|string[]
---@param callback SkillManagerProjectileShootCallback
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
function SkillManager.Register.ProjectileShoot(skill, callback, priority, once)
	SkillManager.Register.All(skill, callback, SKILL_STATE.SHOOTPROJECTILE, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.PROJECTILEHIT event.
---@param skill string|string[]
---@param callback SkillManagerProjectileHitCallback
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
function SkillManager.Register.ProjectileHit(skill, callback, priority, once)
	SkillManager.Register.All(skill, callback, SKILL_STATE.PROJECTILEHIT, priority, once)
end

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.LEARNED event.
---@param skill string|string[]
---@param callback SkillManagerLearnedCallback
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
function SkillManager.Register.Learned(skill, callback, priority, once)
	SkillManager.Register.All(skill, callback, SKILL_STATE.LEARNED, priority, once)
end

local _MemorizationStates = {SKILL_STATE.MEMORIZED, SKILL_STATE.UNMEMORIZED}

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.UNMEMORIZED or SKILL_STATE.MEMORIZED event.
---@param skill string|string[]
---@param callback SkillManagerMemorizationChangedCallback
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
function SkillManager.Register.MemorizationChanged(skill, callback, priority, once)
	SkillManager.Register.All(skill, callback, _MemorizationStates, priority, once)
end