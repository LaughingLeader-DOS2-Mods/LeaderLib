if not GameHelpers.Hit then
	GameHelpers.Hit = {}
end

local _EXTVERSION = Ext.Utils.Version()

---Returns true if a hit isn't Dodged, Missed, or Blocked.
---Pass in an object if this is a status.
---@param target string
---@param handle integer
---@param is_hit integer|boolean
---@return boolean
function GameHelpers.HitSucceeded(target, handle, is_hit)
	if is_hit == 1 or is_hit == true then
		return Osi.NRD_HitGetInt(handle, "Dodged") == 0 and Osi.NRD_HitGetInt(handle, "Missed") == 0 and Osi.NRD_HitGetInt(handle, "Blocked") == 0
	else
		return Osi.NRD_StatusGetInt(target, handle, "Dodged") == 0 and Osi.NRD_StatusGetInt(target, handle, "Missed") == 0 and Osi.NRD_StatusGetInt(target, handle, "Blocked") == 0
	end
end

--Ext.NewQuery(HitSucceeded, "LeaderLib_Ext_QRY_HitSucceeded", "[in](GUIDSTRING)_Target, [in](INTEGER64)_Handle, [in](INTEGER)_IsHitType, [out](INTEGER)_Bool")

-- HitReason
-- // 0 - ASAttacks
-- // 1 - Character::ApplyDamage, StatusDying, ExecPropertyDamage, StatusDamage
-- // 2 - AI hit test
-- // 3 - Explode, Projectile Skill Hit
-- // 4 - Trap
-- // 5 - InSurface
-- // 6 - SetHP, osi::ApplyDamage, StatusConsume

local unarmedHitMatchProperties = {
	DamageType = 0,
	DamagedMagicArmor = 0,
	Equipment = 0,
	DeathType = 0,
	Bleeding = 0,
	DamagedPhysicalArmor = 0,
	PropagatedFromOwner = 0,
	-- NoWeapon doesn't set HitWithWeapon until after preparation
	HitWithWeapon = 0,
	Surface = 0,
	NoEvents = 0,
	Hit = 0,
	Poisoned = 0,
	--CounterAttack = 0,
	--ProcWindWalker = 1,
	NoDamageOnOwner = 0,
	Burning = 0,
	--DamagedVitality = 0,
	--LifeSteal = 0,
	--ArmorAbsorption = 0,
	--AttackDirection = 0,
	Missed = 0,
	--CriticalHit = 0,
	--Backstab = 0,
	Reflection = 0,
	DoT = 0,
	Dodged = 0,
	--DontCreateBloodSurface = 0,
	FromSetHP = 0,
	FromShacklesOfPain = 0,
	Blocked = 0,
}

---Returns true if the hit is an unarmed hit. This is for an actual hit handle during NRD_OnPrepareHit.
---@param hitHandle integer
---@return boolean
function GameHelpers.Hit.IsPreparedUnarmedHit(hitHandle)
	for prop,val in pairs(unarmedHitMatchProperties) do
		if Osi.NRD_HitGetInt(hitHandle, prop) ~= val then
			return false
		end
	end
	return true
end

---Returns true if a hit is from a basic attack.
---@param target string
---@param handle integer
---@param is_hit integer|boolean Whether the handle is for a hit or hit status.
---@param allowSkills boolean|nil
---@param source string|nil
---@return boolean
function GameHelpers.HitWithWeapon(target, handle, is_hit, allowSkills, source)
	if handle == nil or handle == -1 then
		return false
	end
	if is_hit == 1 or is_hit == true then
		local hitType = Osi.NRD_HitGetInt(handle, "HitType")
		local hitWithWeapon = Osi.NRD_HitGetInt(handle, "HitWithWeapon") == 1
		return (hitType == 0) and hitWithWeapon
	else
		local hitReason = Osi.NRD_StatusGetInt(target, handle, "HitReason")
		local hitWithWeapon = Osi.NRD_StatusGetInt(target, handle, "HitWithWeapon") == 1
		if hitReason == 0 and hitWithWeapon then
			return true
		end
		local sourceType = Osi.NRD_StatusGetInt(target, handle, "DamageSourceType")
		
		if hitReason ~= nil and sourceType ~= nil then
			local hitReasonFromWeapon = hitReason <= 1
			local hitWithWeapon = sourceType == 6 or sourceType == 7
			local hasWeaponHandle = not StringHelpers.IsNullOrEmpty(Osi.NRD_StatusGetGuidString(target, handle, "WeaponHandle"))
			if allowSkills == true then
				local skillprototype = Osi.NRD_StatusGetString(target, handle, "SkillId")
				if skillprototype ~= "" and skillprototype ~= nil then
					local skill = GetSkillEntryName(skillprototype)
					hitReasonFromWeapon = GameHelpers.Stats.GetAttribute(skill, "UseWeaponDamage") == "Yes" and (hitReason <= 1 or hitReason == 3)
					if hitReasonFromWeapon then
						hasWeaponHandle = true
					end
					--GameHelpers.Stats.GetAttribute(skill, "UseWeaponProperties") == "Yes"
				end
			end
			return (hitReasonFromWeapon and hitWithWeapon) and hasWeaponHandle
		end
		return false
	end
end

-- local DamageSourceTypeToInt = {
--     None = 0,
--     SurfaceMove = 1,
--     SurfaceCreate = 2,
--     SurfaceStatus = 3,
--     StatusEnter = 4,
--     StatusTick = 5,
--     Attack = 6,
--     Offhand = 7,
--     GM = 8,
-- }

---@param hitType string|integer|HitContext
---@param toInteger boolean|nil
---@param t string|nil The variable type for hitType, usually passed along automatically.
---@return string|integer
function GameHelpers.Hit.GetHitType(hitType, toInteger, t)
	if hitType then
		t = t or type(hitType)
		if t == "userdata" then
			if GameHelpers.Ext.UserDataIsType(hitType, Data.ExtenderClass.HitContext) then
				hitType = hitType.HitType
				t = "string"
			end
		elseif t == "table" and hitType.HitType then
			hitType = hitType.HitType
			t = type(hitType)
		end
		if t == "string" then
			if not toInteger then
				return hitType
			end
			return Data.HitType[hitType]
		elseif t == "number" then
			if not toInteger then
				return Data.HitType[hitType]
			end
			return hitType
		end
	end
	return nil
end

local WeaponHitProperties = {
	HitType = {
		Melee = true,
		Magic = true,
		Ranged = true,
	},
	DamageSourceType = {
		Attack = true,
		Offhand = true
	},
	SkillHitType = {
		Melee = true,
		Magic = true,
		WeaponDamage = true,
	}
}

---Returns true if a hit is from a basic attack or weapon skill, if a skill is provided.
---@param hit HitContext
---@param skill StatEntrySkillData|nil
---@param hitStatus EsvStatusHit|nil
---@param hitType HitTypeValues|integer|nil
---@return boolean
function GameHelpers.Hit.IsFromWeapon(hit, skill, hitStatus, hitType)
	if not hitType and hit ~= nil then
		hitType = GameHelpers.Hit.GetHitType(hit)
	end

	if skill then
		return skill.UseWeaponDamage == "Yes" and WeaponHitProperties.SkillHitType[hitType] == true
	else
		if hitStatus then
			if WeaponHitProperties.DamageSourceType[hitStatus.DamageSourceType] == true and WeaponHitProperties.HitType[hitType] then
				return GameHelpers.IsValidHandle(hitStatus.WeaponHandle)
			end
		elseif hitType == "Melee" then
			return true
		end
	end

	return false
end

---Returns true if a hit is from a basic attack or weapon skill, if a skill is provided.
---@param hitType HitTypeValues
---@param damageSourceType string
---@param weaponHandle userdata|nil
---@param skill StatEntrySkillData|nil
---@return boolean
function GameHelpers.Hit.TypesAreFromWeapon(hitType, damageSourceType, weaponHandle, skill)
	if skill then
		return skill.UseWeaponDamage == "Yes" and WeaponHitProperties.SkillHitType[hitType] == true
	else
		if WeaponHitProperties.DamageSourceType[damageSourceType] == true and WeaponHitProperties.HitType[hitType] then
			return GameHelpers.IsValidHandle(weaponHandle)
		end
	end

	return false
end

---Returns true if a hit is from the source directly (not from a surface, DoT etc).
---@param hit EsvStatusHit|HitContext
---@return boolean
function GameHelpers.Hit.IsDirect(hit)
	if not hit then
		return false
	end
	local t = type(hit)
	if t == "userdata" then
		local meta = getmetatable(hit)
		if GameHelpers.Ext.UserDataIsType(hit, Data.ExtenderClass.EsvStatusHit, meta) then
			if hit.HitReason == "ASAttack" then
				return true
			end
			local damageSourceType = Ext.Stats.EnumLabelToIndex(hit.DamageSourceType, "DamageSourceType")
			return damageSourceType == 0 or damageSourceType == 6 or damageSourceType == 7
		elseif GameHelpers.Ext.UserDataIsType(hit, Data.ExtenderClass.HitContext, meta) then
			return Data.HitType[hit.HitType] < 4
		end
	end
	if t == "string" then
		local hitType = GameHelpers.Hit.GetHitType(hit, true)
		if hitType >= 4 then
			return false
		end
	elseif t == "number" then
		return hit < 4
	end
	return false
end

---Returns true if a hit isn't Dodged, Missed, or Blocked.
---@param hit StatsHitDamageInfo|EsvStatusHit
---@return boolean
function GameHelpers.Hit.Succeeded(hit)
	if GameHelpers.Ext.UserDataIsType(hit, Data.ExtenderClass.EsvStatusHit) then
		---@cast hit EsvStatusHit
		hit = hit.Hit
	end
	if not hit then
		return false
	end
	if hit.Dodged or hit.Missed or hit.Blocked then
		return false
	end
	return true
end

---Returns true if a hit's effect flags have the supplied flag or table of flags.
---@param hit HitRequest
---@param flag integer|string|table A flag value or key in Game.Math.HitFlags.
---@return boolean
function GameHelpers.Hit.HasFlag(hit, flag)
	if not flag or not hit or not hit.EffectFlags then
		error(string.format("Invalid hit (%s) or flag (%s)", hit, flag), 2)
	end
	local t = type(flag)
	if t == "string" and _EXTVERSION < 56 then
		flag = Game.Math.HitFlag[flag]
	elseif t == "table" then
		for i,v in pairs(flag) do
			if GameHelpers.Hit.HasFlag(hit, v) then
				return true
			end
		end
		return false
	end
	if _EXTVERSION < 56 then
		return (hit.EffectFlags & flag) ~= 0
	else
		return hit[flag] == true
	end
end

--- @alias HitFlagID string | "Burning" | "DontCreateBloodSurface" | "Flanking" | "Missed" | "Backstab" | "Hit" | "CriticalHit" | "FromSetHP" | "NoDamageOnOwner" | "FromShacklesOfPain" | "DoT" | "DamagedVitality" | "PropagatedFromOwner" | "CounterAttack" | "Reflection" | "ProcWindWalker" | "DamagedPhysicalArmor" | "Poisoned" | "Bleeding" | "NoEvents" | "Dodged" | "Blocked" | "Surface" | "DamagedMagicArmor"

---@param hit HitRequest
---@param flag integer|HitFlagID|HitFlagID[] A flag value or key in Game.Math.HitFlags.
---@param b boolean Whether a flag is enabled or disabled.
---@return boolean
function GameHelpers.Hit.SetFlag(hit, flag, b)
	if not flag or not hit or (_EXTVERSION < 56 and not hit.EffectFlags) then
		fprint(LOGLEVEL.ERROR, "[LeaderLib:GameHelpers.Hit.SetFlag] Invalid hit (%s) or flag (%s)", hit, flag)
		return false
	end
	local t = type(flag)
	if t == "string" and _EXTVERSION < 56 then
		flag = Game.Math.HitFlag[flag]
	elseif t == "table" then
		for i,v in pairs(flag) do
			GameHelpers.Hit.SetFlag(hit, v, b)
		end
		return true
	end
	if _EXTVERSION < 56 then
		if b then
			hit.EffectFlags = hit.EffectFlags | flag
		else
			hit.EffectFlags = hit.EffectFlags & ~flag
		end
	else
		hit[flag] = b
	end
	return true
end

---Calculates LifeSteal like Game.Math.ApplyLifeSteal, but with extra options.
--- @param hit HitRequest
--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param hitType string HitType enumeration
--- @param setFlags boolean If true related flags like DontCreateBloodSurface may get set, just like in DoHit.
--- @param allowArmorDamageTypes boolean If true, Magic/Corrosive damage won't be subtracted from the total damage done.
--- @see Game.Math#ApplyLifeSteal
function GameHelpers.Hit.RecalculateLifeSteal(hit, target, attacker, hitType, setFlags, allowArmorDamageTypes)
	if hit.TotalDamageDone > 0 then
		if attacker == nil or hitType == "DoT" or hitType == "Surface" then
			return
		end
		
		local magicDmg = hit.DamageList:GetByType("Magic")
		local corrosiveDmg = hit.DamageList:GetByType("Corrosive")
		local lifesteal = 0
		if not allowArmorDamageTypes then
			lifesteal = hit.TotalDamageDone - hit.ArmorAbsorption - corrosiveDmg - magicDmg
		else
			lifesteal = hit.TotalDamageDone - hit.ArmorAbsorption
		end

		local applyReflectionModifier = false
		if _EXTVERSION < 56 then
			applyReflectionModifier = hit.EffectFlags & (Game.Math.HitFlag.FromShacklesOfPain|Game.Math.HitFlag.NoDamageOnOwner|Game.Math.HitFlag.Reflection) ~= 0
		else
			applyReflectionModifier = hit.FromShacklesOfPain or hit.NoDamageOnOwner or hit.Reflection
		end

		if applyReflectionModifier then
			local modifier = Ext.ExtraData.LifestealFromReflectionModifier
			lifesteal = math.floor(lifesteal * modifier)
		end
	
		if lifesteal > target.CurrentVitality then
			lifesteal = target.CurrentVitality
		end
	
		if lifesteal > 0 then
			hit.LifeSteal = math.max(math.ceil(lifesteal * attacker.LifeSteal / 100), 0)
		end
	elseif setFlags then
		if _EXTVERSION < 56 then
			hit.EffectFlags = hit.EffectFlags | Game.Math.HitFlag.DontCreateBloodSurface
		else
			hit.DontCreateBloodSurface = true
		end
	end
end