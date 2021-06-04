if not GameHelpers.Hit then
    GameHelpers.Hit = {}
end

---Returns true if a hit isn't Dodged, Missed, or Blocked.
---Pass in an object if this is a status.
---@param target string
---@param handle integer
---@param is_hit integer|boolean
---@return boolean
function GameHelpers.HitSucceeded(target, handle, is_hit)
    if is_hit == 1 or is_hit == true then
        return NRD_HitGetInt(handle, "Dodged") == 0 and NRD_HitGetInt(handle, "Missed") == 0 and NRD_HitGetInt(handle, "Blocked") == 0
    else
        return NRD_StatusGetInt(target, handle, "Dodged") == 0 and NRD_StatusGetInt(target, handle, "Missed") == 0 and NRD_StatusGetInt(target, handle, "Blocked") == 0
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
        if NRD_HitGetInt(handle, prop) ~= val then
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
    if handle == nil or handle < 0 then 
        return false
    end
    if is_hit == 1 or is_hit == true then
        local hitType = NRD_HitGetInt(handle, "HitType")
        local hitWithWeapon = NRD_HitGetInt(handle, "HitWithWeapon") == 1
        return (hitType == 0) and hitWithWeapon
    else
        local hitReason = NRD_StatusGetInt(target, handle, "HitReason")
        local hitWithWeapon = NRD_StatusGetInt(target, handle, "HitWithWeapon") == 1
        if hitReason == 0 and hitWithWeapon then
            return true
        end
        local sourceType = NRD_StatusGetInt(target, handle, "DamageSourceType")
        
        if hitReason ~= nil and sourceType ~= nil then
            local hitReasonFromWeapon = hitReason <= 1
            local hitWithWeapon = sourceType == 6 or sourceType == 7
            local hasWeaponHandle = not StringHelpers.IsNullOrEmpty(NRD_StatusGetGuidString(target, handle, "WeaponHandle"))
            if allowSkills == true then
                local skillprototype = NRD_StatusGetString(target, handle, "SkillId")
                if skillprototype ~= "" and skillprototype ~= nil then
                    local skill = string.gsub(skillprototype, "_%-?%d+$", "")
                    hitReasonFromWeapon = Ext.StatGetAttribute(skill, "UseWeaponDamage") == "Yes" and (hitReason <= 1 or hitReason == 3)
                    if hitReasonFromWeapon then
                        hasWeaponHandle = true
                    end
                    --Ext.StatGetAttribute(skill, "UseWeaponProperties") == "Yes"
                end
            end
            return (hitReasonFromWeapon and hitWithWeapon) and hasWeaponHandle
        end
        return false
    end
end

-- local HitReasonToInt = {
--     Melee = 0,
--     Magic = 1,
--     Ranged = 2,
--     WeaponDamage = 3,
--     Surface = 4,
--     DoT = 5,
--     Reflected = 6,
-- }

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

local WeaponHitProperties = {
    HitReason = {
        Melee = true,
        Magic = true,
    },
    DamageSourceType = {
        Attack = true,
        Offhand = true
    }
}

local WeaponSkillHitReason = {
    Melee = true,
    Magic = true,
    WeaponDamage = true,
}

---Returns true if a hit is from a basic attack.
---@param hit EsvStatusHit
---@return boolean
function GameHelpers.Hit.IsFromWeapon(hit, allowSkills)
    if hit == nil then
        return false
    end
    if hit.HitReason == "Melee" then
        return true
    end
    
    if WeaponHitProperties.DamageSourceType[hit.DamageSourceType] == true and hit.HitReason then
        if allowSkills == true then
            if not StringHelpers.IsNullOrEmpty(hit.SkillId) then
                local skill = string.gsub(hit.SkillId, "_%-?%d+$", "")
                if Ext.StatGetAttribute(skill, "UseWeaponDamage") == "Yes" and WeaponSkillHitReason[hit.HitReason] == true then
                    return true
                end
            end
        end
        return WeaponHitProperties.HitReason[hit.HitReason] == true and hit.WeaponHandle ~= nil
    end
    return false
end

local hitFlag = Game.Math.HitFlag

---Returns true if a hit isn't Dodged, Missed, or Blocked.
---@param hit HitRequest
---@return boolean
function GameHelpers.Hit.Succeeded(hit)
    if (hit.EffectFlags & hitFlag.Dodged) ~= 0 then
        return false
    end
    if (hit.EffectFlags & hitFlag.Missed) ~= 0 then
        return false
    end
    if (hit.EffectFlags & hitFlag.Blocked) ~= 0 then
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
    if t == "string" then
        flag = hitFlag[flag]
    elseif t == "table" then
        for i,v in pairs(flag) do
            if GameHelpers.Hit.HasFlag(hit, v) then
                return true
            end 
        end
        return false
    end
    return (hit.EffectFlags & flag) ~= 0
end

---@param hit HitRequest
---@param flag integer|string|table A flag value or key in Game.Math.HitFlags.
---@param b boolean Whether a flag is enabled or disabled.
function GameHelpers.Hit.SetFlag(hit, flag, b)
    if not flag or not hit or not hit.EffectFlags then
        error(string.format("Invalid hit (%s) or flag (%s)", hit, flag), 2)
    end
    local t = type(flag)
    if t == "string" then
        flag = hitFlag[flag]
    elseif t == "table" then
        for i,v in pairs(flag) do
            GameHelpers.Hit.SetFlag(hit, v, b)
        end
        return
    end
    if b then
        hit.EffectFlags = hit.EffectFlags | flag
    else
        hit.EffectFlags = hit.EffectFlags & ~flag
    end
end