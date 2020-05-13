---Returns true if a hit isn't Dodged, Missed, or Blocked.
---Pass in an object if this is a status.
---@param target string
---@param handle integer
---@param is_hit integer
---@return boolean
local function HitSucceeded(target, handle, is_hit)
    if is_hit == 1 or is_hit == true then
        return NRD_HitGetInt(handle, "Dodged") == 0 and NRD_HitGetInt(handle, "Missed") == 0 and NRD_HitGetInt(handle, "Blocked") == 0
    else
        return NRD_StatusGetInt(target, handle, "Dodged") == 0 and NRD_StatusGetInt(target, handle, "Missed") == 0 and NRD_StatusGetInt(target, handle, "Blocked") == 0
    end
end

--Ext.NewQuery(HitSucceeded, "LeaderLib_Ext_QRY_HitSucceeded", "[in](GUIDSTRING)_Target, [in](INTEGER64)_Handle, [in](INTEGER)_IsHitType, [out](INTEGER)_Bool")

-- HitReason
-- // 0 - ASAttack
-- // 1 - Character::ApplyDamage, StatusDying, ExecPropertyDamage, StatusDamage
-- // 2 - AI hit test
-- // 3 - Explode
-- // 4 - Trap
-- // 5 - InSurface
-- // 6 - SetHP, osi::ApplyDamage, StatusConsume

---Returns true if a hit is from a weapon.
---@param target string
---@param handle integer
---@param is_hit integer
---@return boolean
local function HitWithWeapon(target, handle, is_hit)
    if is_hit == 1 or is_hit == true then
        local hitType = NRD_HitGetInt(handle, "HitType")
        local hitWithWeapon = NRD_HitGetInt(handle, "HitWithWeapon") == 1
        return (hitType == 0) and hitWithWeapon
    else
        local hitReason = NRD_StatusGetInt(target, handle, "HitReason")
        local weaponHandle = NRD_StatusGetGuidString(target, handle, "WeaponHandle")
        local sourceType = NRD_StatusGetInt(target, handle, "DamageSourceType")
        local hitWithWeapon = sourceType == 6 or sourceType == 7
        return (hitReason <= 1 and hitWithWeapon) and (weaponHandle ~= nil and weaponHandle ~= "NULL_00000000-0000-0000-0000-000000000000")
    end
end

--Ext.NewQuery(HitWithWeapon, "LeaderLib_Ext_QRY_HitWithWeapon", "[in](GUIDSTRING)_Target, [in](INTEGER64)_Handle, [in](INTEGER)_IsHitType, [out](INTEGER)_Bool")

Game.HitSucceeded = HitSucceeded
Game.HitWithWeapon = HitWithWeapon