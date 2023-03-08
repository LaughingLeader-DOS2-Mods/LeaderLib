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
	task.Force = true
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

---@class LeaderLibSabotageOptions
---@field Attacker ObjectParam An optional source character/item to use for the explode damage.
---@field Amount integer The number of explosives to detonate. Defaults to 1.
---@field GridOptions GameHelpers_Grid_GetNearbyObjectsOptions If the target is a position, use these options for finding targets.
local _DefaultSabotageOptions = {
	Amount = 1,
	Radius = 1,
	IsFromItem = false,
	GridOptions = {
		Radius = 1,
		AllowDead = true,
		Relation={Enemy=true},
		IgnoreHeight=false,
		Type="All"
	}
}

---@param target ComponentHandle|ObjectParam|vec3|nil Either a ComponentHandle, object, or position table.
---@param opts? LeaderLibSabotageOptions Optional parameters
---@return integer totalSabotagedItems
function GameHelpers.Action.Sabotage(target, opts)
	---@type LeaderLibSabotageOptions
	local options = type(opts) == "table" and opts or {}
	setmetatable(options, {__index = _DefaultSabotageOptions})

	local attacker = nil
	if opts.Attacker then
		attacker = GameHelpers.TryGetObject(opts.Attacker, "EsvCharacter")
	end

	---Grenade to Skill
	---@type {Item:EsvItem, Skill:FixedString, Position:vec3, HitObject:EsvCharacter|EsvItem}[]
	local grenades = {}
	local len = 0

	if type(target) == "table" and GameHelpers.Math.IsPosition(target) then
		for v in GameHelpers.Grid.GetNearbyObjects(target, opts.GridOptions) do
			local remaining = opts.Amount
			for _,itemGUID in pairs(v:GetInventoryItems()) do
				local item = GameHelpers.GetItem(itemGUID, "EsvItem")
				if item then
					local skills,data = GameHelpers.Item.GetUseActionSkills(item)
					if data.CastsSkill and data.IsConsumable then
						len = len + 1
						grenades[len] = {
							Grenade=item,
							Skill = skills[1],
							Position = v.WorldPos,
							HitObject = v
						}
						grenades[itemGUID] = skills[1]
						remaining = remaining - 1
					end
				end
				if remaining <= 0 then
					break
				end
			end
		end
	else
		local targetObject = GameHelpers.TryGetObject(target)
		fassert(targetObject ~= nil, "Failed to get target from (%s)", target)
	end

	if len > 0 then
		for i=1,len do
			local entry = grenades[i]
			GameHelpers.Skill.Explode(entry.Position, entry.Skill, attacker, {IsFromItem=options.IsFromItem, HitObject=entry.HitObject})
			local amount = entry.Item.Amount
			amount = amount - 1
			if amount > 0 then
				GameHelpers.Item.SetAmount(entry.Item, amount)
			else
				ItemRemove(entry.Item.MyGuid)
			end
		end
	end

	return len
end