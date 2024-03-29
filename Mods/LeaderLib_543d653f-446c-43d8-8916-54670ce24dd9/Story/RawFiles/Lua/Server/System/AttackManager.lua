local _INTERNAL = {}

---@class LeaderLibAttackManager
AttackManager = {
	_Internal = _INTERNAL,
	---@type table<string,boolean>
	EnabledTags = {}
}

Managers.Attack = AttackManager

---@alias DeprecatedBasicAttackOnStartCallback fun(attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], targetIsObject:boolean)
---@alias DeprecatedBasicAttackOnHitCallback fun(attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], data:HitData|DamageList, targetIsObject:boolean, skill:StatEntrySkillData)
---@alias DeprecatedBasicAttackOnWeaponTagHitCallback fun(tag:string, attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], data:HitData, targetIsObject:boolean, skill:StatEntrySkillData)
---@alias DeprecatedBasicAttackOnWeaponTypeHitCallback fun(weaponType:string, attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], data:HitData, targetIsObject:boolean, skill:StatEntrySkillData)

AttackManager.OnStart = {
	---@deprecated
	---@param callback DeprecatedBasicAttackOnStartCallback|DeprecatedBasicAttackOnStartCallback[]
	---@param allowSkills? boolean
	---@param priority? integer Optional priority to assign to this callback.
	Register = function(callback, allowSkills, priority)
		Events.OnBasicAttackStart:Subscribe(function (e)
			callback(e.Attacker, e.Target, e.TargetIsObject)
		end, {Priority=priority})
	end
}

AttackManager.OnHit = {
	---@deprecated
	---@param callback DeprecatedBasicAttackOnHitCallback|DeprecatedBasicAttackOnHitCallback[]
	---@param allowSkills? boolean
	---@param priority? integer Optional priority to assign to this callback.
	Register = function(callback, allowSkills, priority)
		if not allowSkills then
			Events.OnWeaponHit:Subscribe(function (e)
				if not e.SkillData then
					callback(e.Attacker, e.Target, e.Data, e.TargetIsObject, e.SkillData)
				end
			end, {Priority=priority})
		else
			Events.OnWeaponHit:Subscribe(function (e)
				callback(e.Attacker, e.Target, e.Data, e.TargetIsObject, e.SkillData)
			end, {Priority=priority})
		end
	end
}
AttackManager.OnWeaponTagHit = {
	---@deprecated
	---Register a listener that fires when a hit occurs with a specific weapon tag.
	---@param tag string|string[]
	---@param callback DeprecatedBasicAttackOnWeaponTagHitCallback
	---@param allowSkills? boolean
	---@param priority? integer Optional priority to assign to this callback.
	Register = function(tag, callback, allowSkills, priority)
		local t = type(tag)
		if t == "table" then
			for k,v in pairs(tag) do
				---@diagnostic disable-next-line
				AttackManager.OnWeaponTagHit.Register(v, callback, allowSkills, priority) 
			end
		elseif t == "string" then
			AttackManager.EnabledTags[tag] = true
			if not allowSkills then
				Events.OnWeaponTagHit:Subscribe(function (e)
					if not e.SkillData then
						callback(e.Tag, e.Attacker, e.Target, e.Data, e.TargetIsObject, e.SkillData)
					end
				end, {Priority=priority, MatchArgs={Tag=tag}})
			else
				Events.OnWeaponTagHit:Subscribe(function (e)
					callback(e.Tag, e.Attacker, e.Target, e.Data, e.TargetIsObject, e.SkillData)
				end, {Priority=priority, MatchArgs={Tag=tag}})
			end
		end
	end
}
AttackManager.OnWeaponTypeHit = {
	---@deprecated
	---Register a listener that fires when a hit occurs with a specific weapon type.
	---@param weaponType string|string[]
	---@param callback DeprecatedBasicAttackOnWeaponTypeHitCallback
	---@param allowSkills? boolean
	---@param priority integer Optional priority to assign to this callback.
	Register = function(weaponType, callback, allowSkills, priority)
		if type(priority) ~= "number" then
			priority = 99
		end
		local t = type(weaponType)
		if t == "table" then
			for k,v in pairs(weaponType) do 
				---@diagnostic disable-next-line
				AttackManager.OnWeaponTypeHit.Register(v, callback, allowSkills, priority) 
			end
		elseif t == "string" then
			if not allowSkills then
				Events.OnWeaponTypeHit:Subscribe(function (e)
					if not e.SkillData then
						callback(e.WeaponType, e.Attacker, e.Target, e.Data, e.TargetIsObject, e.SkillData)
					end
				end, {Priority=priority, MatchArgs={WeaponType=weaponType}})
			else
				Events.OnWeaponTypeHit:Subscribe(function (e)
					callback(e.WeaponType, e.Attacker, e.Target, e.Data, e.TargetIsObject, e.SkillData)
				end, {Priority=priority, MatchArgs={WeaponType=weaponType}})
			end
		end
	end
}

--- @param attacker EsvCharacter|EsvItem
--- @param target EsvCharacter|EsvItem|number[]
--- @param targetIsObject boolean
--- @param data HitData|DamageList
--- @param skill? StatEntrySkillData
function _INTERNAL.InvokeWeaponEvents(attacker, target, targetIsObject, data, skill)
	local _tags = GameHelpers.GetAllTags(attacker, true, true)
	for tag,_ in pairs(AttackManager.EnabledTags) do
		if _tags[tag] then
			Events.OnWeaponTagHit:Invoke({
				Tag = tag,
				Attacker = attacker,
				AttackerGUID = attacker.MyGuid,
				Target = target,
				TargetGUID = targetIsObject and target.MyGuid or "",
				TargetIsObject = targetIsObject,
				Data = data,
				Skill = skill and skill.Name or nil,
				SkillData = skill
			})
		end
	end
	local weaponTypes = {}
	if attacker.Stats.MainWeapon then
		weaponTypes[attacker.Stats.MainWeapon.WeaponType] = true
	end
	if attacker.Stats.OffHandWeapon then
		weaponTypes[attacker.Stats.OffHandWeapon.WeaponType] = true
	end
	for weaponType,_ in pairs(weaponTypes) do
		Events.OnWeaponTypeHit:Invoke({
			WeaponType = weaponType,
			Attacker = attacker,
			Target = target,
			TargetIsObject = targetIsObject,
			Data = data,
			Skill = skill and skill.Name or nil,
			SkillData = skill
		})
	end
end

--- @param isFromHit boolean
--- @param attacker EsvCharacter|EsvItem
--- @param target EsvCharacter|EsvItem|number[]
--- @param data HitData|DamageList
--- @param skill? StatEntrySkillData
function AttackManager.InvokeOnHit(isFromHit, attacker, target, data, skill)
	local targetIsObject = type(target) == "userdata"
	local isFromSkill = skill ~= nil
	--fprint(LOGLEVEL.DEFAULT, "[AttackManager.InvokeOnHit] skill(%s) HitType(%s) DamageSourceType(%s) WeaponHandle(%s)", skill and skill.Name or "", GameHelpers.Hit.GetHitType(data.HitContext), data.HitStatus.DamageSourceType, data.HitStatus.WeaponHandle)
	Events.OnWeaponHit:Invoke({
		Attacker = attacker,
		Target = target,
		TargetIsObject = targetIsObject,
		Data = data,
		Skill = isFromSkill and skill.Name or nil,
		SkillData = skill
	})
	if GameHelpers.Ext.ObjectIsCharacter(attacker) then
		_INTERNAL.InvokeWeaponEvents(attacker, target, targetIsObject, data, skill)
	end
end

Ext.Events.GroundHit:Subscribe(function (e)
	--Also fires when a projectile hits the ground (exploding projectiles too!), so we need this table entry
	if e.Caster and _PV.StartAttackPosition[e.Caster.MyGuid] then
		_PV.StartAttackPosition[e.Caster.MyGuid] = nil
		local data = {Type="DamageList", DamageList = e.DamageList}
		Events.OnWeaponHit:Invoke({
			Attacker = e.Caster,
			Target = e.Position,
			TargetIsObject = false,
			Data = data
		})
		_INTERNAL.InvokeWeaponEvents(e.Caster, e.Position, false, data, nil)
	end
end)