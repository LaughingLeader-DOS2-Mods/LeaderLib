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

---Returns true if a hit is from a weapon.
---@param target string
---@param handle integer
---@param is_hit integer
---@param allowSkills boolean
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