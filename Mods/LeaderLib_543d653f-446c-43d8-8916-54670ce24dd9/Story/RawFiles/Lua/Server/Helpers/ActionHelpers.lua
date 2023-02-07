if GameHelpers.Action == nil then
	GameHelpers.Action = {}
end

---@param attacker CharacterParam
---@param target ComponentHandle|ObjectParam|vec3 Either a ComponentHandle, object, or position table
---@param opts EsvOsirisAttackTask|nil Optional parameters to set on the task
function GameHelpers.Action.Attack(attacker, target, opts)
	local character = GameHelpers.GetCharacter(attacker) --[[@as EsvCharacter]]
	fassert(character ~= nil, "Failed to get attacker character from (%s)", attacker)
	local task = Ext.Action.CreateOsirisTask("Attack", character) --[[@as EsvOsirisAttackTask]]
	local t = type(target)
	if t == "table" then
		task.TargetPos = target
	else
		if GameHelpers.IsValidHandle(target) then
			---@cast target ComponentHandle
			task.Target = target
		else
			local obj = GameHelpers.TryGetObject(target)
			fassert(obj ~= nil, "Failed to get target object from (%s)", target)
			task.Target = obj.Handle
		end
	end
	if type(opts) == "table" then
		for k,v in pairs(opts) do
			task[k] = v
		end
	end
	Ext.Action.QueueOsirisTask(task)
end

---@class GameHelpersActionPlayAnimationOptions:EsvOsirisPlayAnimationTask
---@field FinishedCallback fun(character:EsvCharacter, animation:string) A function to call when the animation is done playing

---@param character CharacterParam
---@param animation FixedString
---@param opts GameHelpersActionPlayAnimationOptions|nil Optional parameters to set on the task
function GameHelpers.Action.PlayAnimation(character, animation, opts)
	assert(type(animation) == "string", "animation param must be a string")
	local character = GameHelpers.GetCharacter(character) --[[@as EsvCharacter]]
	fassert(character ~= nil, "Failed to get attacker character from (%s)", character)

	local task = Ext.Action.CreateOsirisTask("PlayAnimation", character) --[[@as EsvOsirisPlayAnimationTask]]
	task.Animation = animation
	if type(opts) == "table" then
		if opts.FinishedCallback then
			local callback = opts.FinishedCallback
			opts.FinishedCallback = nil
			local eventName = string.format("%s_%s", character.MyGuid, animation)
			task.FinishedEvent = eventName
			Events.ObjectEvent:Subscribe(function (e)
				callback(e.Objects[1], animation)
			end, {Once=true, MatchArgs={Event=eventName, ObjectGUID1=character.MyGuid}})
		end
		for k,v in pairs(opts) do
			task[k] = v
		end
	end
	Ext.Action.QueueOsirisTask(task)
end

---@param caster CharacterParam
---@param skill FixedString
---@param target ComponentHandle|ObjectParam|vec3|nil Either a ComponentHandle, object, or position table. Defaults to the caster if not set.
---@param opts EsvOsirisUseSkillTask|nil Optional parameters to set on the task
function GameHelpers.Action.UseSkill(caster, skill, target, opts)
	local character = GameHelpers.GetCharacter(caster) --[[@as EsvCharacter]]
	fassert(character ~= nil, "Failed to get attacker character from (%s)", caster)
	local task = Ext.Action.CreateOsirisTask("UseSkill", character) --[[@as EsvOsirisUseSkillTask]]
	task.Skill = skill
	task.IgnoreChecks = true
	task.IgnoreHasSkill = true
	task.Force = true
	local t = type(target)
	if t == "table" then
		task.TargetPos = target
	elseif t == "nil" then
		task.Target = character.Handle
	else
		if GameHelpers.IsValidHandle(target) then
			---@cast target ComponentHandle
			task.Target = target
		else
			local obj = GameHelpers.TryGetObject(target, "EsvCharacter")
			fassert(obj ~= nil, "Failed to get target object from (%s)", target)
			task.Target = obj.Handle
		end
	end
	if type(opts) == "table" then
		for k,v in pairs(opts) do
			task[k] = v
		end
	end
	Ext.Action.QueueOsirisTask(task)
end