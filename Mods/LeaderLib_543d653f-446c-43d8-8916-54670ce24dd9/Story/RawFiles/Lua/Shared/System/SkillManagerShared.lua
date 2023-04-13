local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()

local _enabledSkills = SkillManager._Internal.EnabledSkills
local _lastUsedSkillItems = SkillManager._Internal.LastUsedSkillItems

function SkillManager.SetSkillEnabled(skill, b)
	local current = _enabledSkills[skill] or 0
	if b then
		current = current + 1
	else
		current = math.max(0, current - 1)
	end
	_enabledSkills[skill] = current
end

function SkillManager.EnableForAllSkills(enabled)
	SkillManager.SetSkillEnabled("All", enabled == true)
end

function SkillManager.IsSkillEnabled(skill)
	local all = _enabledSkills.All or 0
	if all > 0 then
		return true
	end
	local current = _enabledSkills[skill] or 0
	return current > 0
end

---@param character EsvCharacter
---@param skill string
---@param returnStoredtemData boolean|nil Returns the last item data as a table, if the item no longer exists.
local function _GetSkillSourceItem(character, skill, returnStoredtemData)
	if not character then
		return nil
	end
	local sourceItem = nil
	if GameHelpers.Ext.ObjectIsCharacter(character) then
		if not _ISCLIENT then
			if character.SkillManager.CurrentSkillState
			and Ext.Utils.IsValidHandle(character.SkillManager.CurrentSkillState.SourceItemHandle)
			then
				sourceItem = GameHelpers.GetItem(character.SkillManager.CurrentSkillState.SourceItemHandle)
			end
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
					sourceItem.RootTemplate = Ext.Template.GetTemplate(lastItemData.Template)
				elseif GameHelpers.ObjectExists(lastItemData.Item) then
					sourceItem = GameHelpers.GetItem(lastItemData.Item)			
				end
			end
		end
	end
	return sourceItem
end

local _ActionMachineSkillStates = {
	[SKILL_STATE.PREPARE] = true,
	[SKILL_STATE.USED] = true,
	[SKILL_STATE.CAST] = true,
}

---@param skill string
---@param character EsvCharacter|EclCharacter
---@param stateID SKILL_STATE
---@param data any
---@param dataType string
local function _CreateSkillEventTable(skill, character, stateID, data, dataType)
	local skillData = Ext.Stats.Get(skill, nil, false)
	if not skillData then
		skillData = {Ability = "", SkillType = ""}
	end
	local eventData = {
		Character = character,
		CharacterGUID = character.MyGuid,
		Skill = skill,
		State = stateID,
		Data = data,
		DataType = dataType,
		SourceItem = _GetSkillSourceItem(character, skill),
		Ability = skillData.Ability,
		---@type SkillType
		SkillType = skillData.SkillType,
	}
	if _EXTVERSION >= 59 and character and _ActionMachineSkillStates[stateID] then
		if character.ActionMachine and character.ActionMachine.Layers then
			for _,v in pairs(character.ActionMachine.Layers) do
				local action = v.State
				if action then
					if action.Type == "UseSkill" then
						---@cast data SkillEventData
						---@cast action EsvASUseSkill
						if StringHelpers.GetSkillEntryName(action.Skill.SkillId) == skill then
							eventData.Action = action
							local state = action.Skill
							if eventData.SkillType == "Dome" then
								---@cast state EsvSkillStateDome
								data:Clear()
								data:AddTargetPosition(state.Position)
							elseif eventData.SkillType == "Jump" then
								---@cast state EsvSkillStateJump
								data:Clear()
								data:AddTargetPosition(state.Position)
							elseif eventData.SkillType == "MultiStrike" then
								---@cast state EsvSkillStateMultiStrike
								data:Clear()
								for _,handle in pairs(state.Targets) do
									local object = GameHelpers.GetObjectFromHandle(handle)
									if object then
										data:AddTargetObject(object.MyGuid)
									end
								end
								data:AddTargetPosition(state.EndPosition)
							elseif eventData.SkillType == "Path" then
								---@cast state EsvSkillStatePath
								data:Clear()
								data:AddTargetPosition(state.StartPosition)
								for _,pos in pairs(state.Path) do
									data:AddTargetPosition(pos)
								end
							elseif eventData.SkillType == "Projectile" then
								---@cast state EsvSkillStateProjectile
								data:Clear()
								for _,ptarget in pairs(state.Targets) do
									local object = GameHelpers.GetObjectFromHandle(ptarget.TargetHandle)
									if object then
										data:AddTargetObject(object.MyGuid)
									else
										if not GameHelpers.Math.IsDefaultPositionOrNil(ptarget.TargetPosition) then
											data:AddTargetPosition(ptarget.TargetPosition)
										end
									end
								end
							elseif eventData.SkillType == "ProjectileStrike" then
								---@cast state EsvSkillStateProjectileStrike
								data:Clear()
								data.PrimaryTargetPosition = state.SteeringTargetPosition
								for _,ptarget in pairs(state.Targets) do
									local object = GameHelpers.GetObjectFromHandle(ptarget.Target)
									if object then
										data:AddTargetObject(object.MyGuid)
									else
										if not GameHelpers.Math.IsDefaultPositionOrNil(ptarget.TargetPosition) then
											data:AddTargetPosition(ptarget.TargetPosition)
										elseif not GameHelpers.Math.IsDefaultPositionOrNil(ptarget.TargetPosition2) then
											data:AddTargetPosition(ptarget.TargetPosition2)
										end
									end
								end
							elseif eventData.SkillType == "Quake" then
							elseif eventData.SkillType == "Rain" then
								---@cast state EsvSkillStateRain
								data:Clear()
								data:AddTargetPosition(state.TargetPosition)
							elseif eventData.SkillType == "Rush" then
								---@cast state EsvSkillStateRush
								data:Clear()
								data.PrimaryTargetPosition = state.TargetPosition
								for _,handle in pairs(state.DamagedTargets) do
									local object = GameHelpers.GetObjectFromHandle(handle)
									if object then
										data:AddTargetObject(object.MyGuid)
									end
								end
								data:AddTargetPosition(state.StartPosition)
								data:AddTargetPosition(state.TargetPosition)
								local target = GameHelpers.GetObjectFromHandle(state.TargetHandle)
								if target then
									data:AddTargetObject(target.MyGuid)
								end
							elseif eventData.SkillType == "Shout" then
								---@cast state EsvSkillStateShout
								data:Clear()
								data:AddTargetPosition(state.Position)
							elseif eventData.SkillType == "SkillHeal" then
								---@cast state EsvSkillStateHeal
								local object = GameHelpers.GetObjectFromHandle(state.TargetHandle)
								if object then
									data:Clear()
									data:AddTargetObject(object.MyGuid)
								end
							elseif eventData.SkillType == "Storm" then
								---@cast state EsvSkillStateStorm
								data:Clear()
								data:AddTargetPosition(state.Position)
							elseif eventData.SkillType == "Summon" then
								---@cast state EsvSkillStateSummon
								data:Clear()
								for _,pos in pairs(state.SummonPositions) do
									data:AddTargetPosition(pos)
								end
							elseif eventData.SkillType == "Target" then
								---@cast state EsvSkillStateTarget
								data.PrimaryTargetPosition = state.TargetPosition
								local target = GameHelpers.GetObjectFromHandle(state.TargetHandle)
								if target then
									data:AddTargetObject(target.MyGuid)
								end
							elseif eventData.SkillType == "Teleportation" then
								---@cast state EsvSkillStateTeleportation
								data:Clear()
								data.PrimaryTargetPosition = state.TargetPosition
								data:AddTargetPosition(state.SourcePosition)
								data:AddTargetPosition(state.TargetPosition)
								local target = GameHelpers.GetObjectFromHandle(state.TargetHandle)
								if target then
									data:AddTargetObject(target.MyGuid)
								end
							elseif eventData.SkillType == "Tornado" then
								---@cast state EsvSkillStateTornado
								data:Clear()
								data:AddTargetPosition(state.Position)
							elseif eventData.SkillType == "Wall" then
								---@cast state EsvSkillStateWall
								data:Clear()
								data:AddTargetPosition(state.StartPosition)
								data:AddTargetPosition(state.EndPosition)
							elseif eventData.SkillType == "Zone" then
								---@cast state EsvSkillStateZone
								data:Clear()
								data:AddTargetPosition(state.TargetPosition)
								for _,handle in pairs(state.Targets) do
									local object = GameHelpers.GetObjectFromHandle(handle)
									if object then
										data:AddTargetObject(object.MyGuid)
									end
								end
							end
							return eventData
						end
					elseif action.Type == "PrepareSkill" then
						---@cast action EsvASPrepareSkill
						if StringHelpers.GetSkillEntryName(action.SkillId) == skill then
							eventData.Action = action
							return eventData
						end
					end
				end
			end
		end
	end
	return eventData
end

SkillManager._Internal.CreateSkillEventTable = _CreateSkillEventTable
SkillManager._Internal.GetSkillSourceItem = _GetSkillSourceItem

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.GETAPCOST event.  
---🔨🔧**Server/Client**🔧🔨  
---@param skill string|string[]
---@param callback fun(e:OnSkillStateGetAPCostEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[]|nil index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.GetAPCost(skill, callback, priority, once)
	local t = type(skill)
	if t == "table" then
		local indexes = {}
		for _,v in pairs(skill) do
			local index = SkillManager.Register.GetAPCost(v, callback, priority, once)
			if index then
				indexes[#indexes+1] = index
			end
		end
		return indexes
	elseif t == "string" then
		if GameHelpers.Stats.IsAction(skill) then
			fprint(LOGLEVEL.WARNING, "[SkillManager.Register.GetAPCost] Skill (%s) is a hotbar action, and not an actual skill. Skipping.", skill)
			return nil
		end
		local opts = {Priority = priority, Once=once, MatchArgs={State=SKILL_STATE.GETAPCOST}}
		if not StringHelpers.Equals(skill, "All", true) then
			SkillManager.SetSkillEnabled(skill, true)
			opts.MatchArgs.Skill=skill
		else
			SkillManager.EnableForAllSkills(true)
		end
		return Events.OnSkillState:Subscribe(callback, opts)
	end
end

Ext.Events.GetSkillAPCost:Subscribe(function (e)
	local skill = StringHelpers.GetSkillEntryName(e.Skill.SkillId)
	if SkillManager.IsSkillEnabled(skill) then
		local character = nil
		if e.Character then
			character = e.Character.Character
		else
			if _ISCLIENT then
				character = Client:GetCharacter()
			else
				character = GameHelpers.Character.GetHost()
			end
		end
		local data = _CreateSkillEventTable(skill, character, SKILL_STATE.GETAPCOST, e, "userdata")
		Events.OnSkillState:Invoke(data)
	end
end, {Priority=0})

---Registers a function to call when a specific skill or array of skills has a SKILL_STATE.GETDAMAGE event.  
---This is called for the actual damage (`Ext.Events.GetSkillDamage`), and for `Damage` param tooltips (`Ext.Events.SkillGetDescriptionParam`).  
---Check `e.IsTooltip` to determine what to set `e.Result` to.  
---🔨🔧**Server/Client**🔧🔨  
---@param skill string|string[]
---@param callback fun(e:OnSkillStateGetDamageEventArgs)
---@param priority integer|nil Optional listener priority
---@param once boolean|nil If true, the listener will fire once, and then get removed. Use with onlySkillState to ensure it only fires for the specific state.
---@return integer|integer[]|nil index Subscription index(s), which can be used to unsubscribe.
function SkillManager.Register.GetDamage(skill, callback, priority, once)
	local t = type(skill)
	if t == "table" then
		local indexes = {}
		for _,v in pairs(skill) do
			local index = SkillManager.Register.GetDamage(v, callback, priority, once)
			if index then
				indexes[#indexes+1] = index
			end
		end
		return indexes
	elseif t == "string" then
		if GameHelpers.Stats.IsAction(skill) then
			fprint(LOGLEVEL.WARNING, "[SkillManager.Register.GetDamage] Skill (%s) is a hotbar action, and not an actual skill. Skipping.", skill)
			return nil
		end
		local opts = {Priority = priority, Once=once, MatchArgs={State=SKILL_STATE.GETDAMAGE}}
		if not StringHelpers.Equals(skill, "All", true) then
			SkillManager.SetSkillEnabled(skill, true)
			opts.MatchArgs.Skill=skill
		else
			SkillManager.EnableForAllSkills(true)
		end
		return Events.OnSkillState:Subscribe(callback, opts)
	end
end

Ext.Events.GetSkillDamage:Subscribe(function (e)
	local skill = StringHelpers.GetSkillEntryName(e.Skill.SkillId)
	if SkillManager.IsSkillEnabled(skill) then
		local character = nil
		if GameHelpers.Ext.ObjectIsStatCharacter(e.Attacker) then
			character = e.Attacker.Character
		end
		local data = _CreateSkillEventTable(skill, character, SKILL_STATE.GETDAMAGE, e, "userdata") --[[@as OnSkillStateGetDamageAmountEventArgs]]
		data.IsTooltip = false
		---@type SubscribableEventInvokeResult<OnSkillStateGetDamageAmountEventArgs>
		local invokeResult = Events.OnSkillState:Invoke(data)
		if invokeResult.ResultCode ~= "Error" then
			local damageList = invokeResult.Args.Result
			if invokeResult.Results then
				for i=1,#invokeResult.Results do
					local b = invokeResult.Results[i]
					if type(b) == "StatsDamagePairList" then
						damageList = b
					end
				end
			end
			if damageList ~= nil then
				e.DamageList:CopyFrom(damageList)
			end
		end
	end
end, {Priority=0})

if _ISCLIENT then
	Ext.Events.SkillGetDescriptionParam:Subscribe(function (e)
		if e.Params[1] == "Damage" then
			local skill = StringHelpers.GetSkillEntryName(e.Skill.SkillId)
			if SkillManager.IsSkillEnabled(skill) then
				local character = nil
				if e.Character then
					character = e.Character.Character
				end
				local data = _CreateSkillEventTable(skill, character, SKILL_STATE.GETDAMAGE, e, "userdata") --[[@as OnSkillStateGetDamageTextEventArgs]]
				data.IsTooltip = true
				---@type SubscribableEventInvokeResult<OnSkillStateGetDamageTextEventArgs>
				local invokeResult = Events.OnSkillState:Invoke(data)
				if invokeResult.ResultCode ~= "Error" then
					local damageRange = invokeResult.Args.Result
					if invokeResult.Results then
						for i=1,#invokeResult.Results do
							local b = invokeResult.Results[i]
							if type(b) == "table" then
								damageRange = b
							end
						end
					end
					if damageRange ~= nil then
						e.Description = GameHelpers.Tooltip.FormatDamageRange(damageRange)
					end
				end
			end
		end
	end, {Priority=0})
end
