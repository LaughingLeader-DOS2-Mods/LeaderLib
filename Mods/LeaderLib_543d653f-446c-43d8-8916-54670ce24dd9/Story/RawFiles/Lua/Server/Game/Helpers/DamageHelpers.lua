if GameHelpers.Damage == nil then
	GameHelpers.Damage = {}
end

---Reduce damage by a percentage (ex. 0.5)
---@param target string
---@param attacker string
---@param handle integer
---@param reduction number The amount to reduce the damage by, i.e. 0.5
---@param isHitHandle boolean Whether the handle is a hit or status handle.
---@return boolean
local function ReduceDamage(target, attacker, handle, reduction, isHitHandle)
	--PrintDebug("[LeaderLib_GameMechanics.lua:ReduceDamage] Reducing damage to ("..tostring(reduction)..") of total. Handle("..tostring(handle).."). Target("..tostring(target)..") Attacker("..tostring(attacker)..") IsHit("..tostring(is_hit)..")")
	local success = false
    for i,damageType in Data.DamageTypes:Get() do
        local damage = nil
        if not isHitHandle then
            damage = NRD_HitStatusGetDamage(target, handle, damageType)
        else
            damage = NRD_HitGetDamage(handle, damageType)
        end
        if damage ~= nil and damage > 0 then
            --local reduced_damage = math.max(math.ceil(damage * reduction), 1)
            --NRD_HitStatusClearDamage(target, handle, v)
            local reduced_damage = (damage * reduction) * -1
            if not isHitHandle then
                NRD_HitStatusAddDamage(target, handle, damageType, reduced_damage)
            else
                NRD_HitAddDamage(handle, damageType, reduced_damage)
            end
			success = true
        end
	end
	return success
end

GameHelpers.ReduceDamage = ReduceDamage

---Reduce damage by a percentage (ex. 0.5)
---@param target string
---@param attacker string
---@param handle_param integer
---@param reduction_perc number
---@param is_hit_param integer
---@return boolean
local function ReduceDamage_Call(target, attacker, handle_param, reduction_perc, is_hit_param)
    local handle = Common.SafeguardParam(handle_param, "integer", nil)
    if handle == nil then error("[LeaderLib_GameMechanics.lua:ReduceDamage] Handle is null! Skipping.") end
    local reduction = Common.SafeguardParam(reduction_perc, "number", 0.5)
    return ReduceDamage(target, attacker, handle, reduction, is_hit_param == 1)
end

Ext.NewCall(ReduceDamage_Call, "LeaderLib_Hit_ReduceDamage", "(GUIDSTRING)_Target, (GUIDSTRING)_Attacker, (INTEGER64)_Handle, (REAL)_Percentage, (INTEGER)_IsHitHandle")

---Increase damage by a percentage (0.5).
---@param target string
---@param attacker string
---@param handle_param integer
---@param increase_perc number
---@param is_hit_param integer
---@return boolean
local function IncreaseDamage(target, attacker, handle_param, increase_perc, is_hit_param)
    local handle = Common.SafeguardParam(handle_param, "number", nil)
    if handle == nil then error("[LeaderLib_GameMechanics.lua:IncreaseDamage] Handle is null! Skipping.") end
    local increase_amount = Common.SafeguardParam(increase_perc, "number", 0.5)
    local is_hit = Common.SafeguardParam(is_hit_param, "number", 0)
	Log("[LeaderLib_GameMechanics.lua:IncreaseDamage] Increasing damage by ("..tostring(increase_amount).."). Handle("..tostring(handle).."). Target("..tostring(target)..") Attacker("..tostring(attacker)..") IsHit("..tostring(is_hit)..")")
	local success = false
    for i,damageType in Data.DamageTypes:Get() do
        local damage = nil
        if is_hit == 0 then
            damage = NRD_HitStatusGetDamage(target, handle, damageType)
        else
            damage = NRD_HitGetDamage(handle, damageType)
        end
        if damage ~= nil and damage > 0 then
            --local increased_damage = damage + math.ceil(damage * increase_amount)
            --NRD_HitStatusClearDamage(target, handle, damageType)
            local increased_damage = math.ceil(damage * increase_amount)
            if is_hit == 0 then
                NRD_HitStatusAddDamage(target, handle, damageType, increased_damage)
            else
                NRD_HitAddDamage(handle, damageType, increased_damage)
            end
			Log("[LeaderLib_GameMechanics.lua:IncreaseDamage] Increasing damage: "..tostring(damage).." => "..tostring(damage + increased_damage).." for type: "..damageType)
			success = true
        end
	end
	return success
end

Ext.NewCall(IncreaseDamage, "LeaderLib_Hit_IncreaseDamage", "(GUIDSTRING)_Target, (GUIDSTRING)_Attacker, (INTEGER64)_Handle, (REAL)_Percentage, (INTEGER)_IsHitHandle")
GameHelpers.IncreaseDamage = IncreaseDamage

---Redirect damage to another target.
---@param target string
---@param defender string
---@param attacker string
---@param handle_param integer
---@param reduction_perc number
---@param is_hit_param integer
---@return boolean
local function RedirectDamage(target, defender, attacker, handle_param, reduction_perc, is_hit_param)
    local handle = Common.SafeguardParam(handle_param, "integer", nil)
    if handle == nil then error("[LeaderLib_GameMechanics.lua:RedirectDamage] Handle is null! Skipping.") end
    local reduction = Common.SafeguardParam(reduction_perc, "number", 0.5)
    local is_hit = Common.SafeguardParam(is_hit_param, "integer", 0)
	Log("[LeaderLib_GameMechanics.lua:RedirectDamage] Reducing damage to ("..tostring(reduction)..") of total. Handle("..tostring(handle).."). Target("..tostring(target)..") Defender("..tostring(defender)..") Attacker("..tostring(attacker)..") IsHit("..tostring(is_hit)..")")
    --if CanRedirectHit(defender, handle, hit_type) then -- Ignore surface, DoT, and reflected damage
    --local hit_type_name = NRD_StatusGetString(defender, handle, "DamageSourceType")
    --local hit_type = NRD_StatusGetInt(defender, handle, "HitType")
    --Log("[LeaderLib_GameMechanics.lua:RedirectDamage] Redirecting damage Handle("..handlestr.."). Blocker(",target,") Target(",defender,") Attacker(",attacker,")")
    local redirected_hit = NRD_HitPrepare(target, attacker)
    local damageRedirected = false

    for i,damageType in Data.DamageTypes:Get() do
        local damage = nil
        if is_hit == 0 then
            damage = NRD_HitStatusGetDamage(defender, handle, damageType)
        else
            damage = NRD_HitGetDamage(handle, damageType)
        end
        if damage ~= nil and damage > 0 then
            local reduced_damage = math.max(math.ceil(damage * reduction), 1)
            --NRD_HitStatusClearDamage(defender, handle, damageType)
            local removed_damage = damage * -1
            if is_hit == 0 then
                NRD_HitStatusAddDamage(defender, handle, damageType, removed_damage)
            else
                NRD_HitAddDamage(handle, damageType, removed_damage)
            end
            NRD_HitAddDamage(redirected_hit, damageType, reduced_damage)
            Log("[LeaderLib_GameMechanics.lua:RedirectDamage] Redirected damage: "..tostring(damage).." => "..tostring(reduced_damage).." for type: "..damageType)
            damageRedirected = true
        end
    end

    if damageRedirected then
        local is_crit = 0
        if is_hit == 0 then
            is_crit = NRD_StatusGetInt(defender, handle, "CriticalHit") == 1
        else
            is_crit = NRD_HitGetInt(handle, "CriticalHit") == 1
        end
        if is_crit then
            NRD_HitSetInt(redirected_hit, "CriticalRoll", 1);
        else
            NRD_HitSetInt(redirected_hit, "CriticalRoll", 2);
        end
        NRD_HitSetInt(redirected_hit, "SimulateHit", 1);
        NRD_HitSetInt(redirected_hit, "HitType", 6);
        NRD_HitSetInt(redirected_hit, "Hit", 1);
        NRD_HitSetInt(redirected_hit, "NoHitRoll", 1);
        NRD_HitExecute(redirected_hit);
	end
	return damageRedirected;
end

Ext.NewCall(RedirectDamage, "LeaderLib_Hit_RedirectDamage", "(GUIDSTRING)_Target, (GUIDSTRING)_Defender, (GUIDSTRING)_Attacker, (INTEGER64)_Handle, (REAL)_Percentage, (INTEGER)_IsHitHandle")

GameHelpers.RedirectDamage = RedirectDamage

local HitType = {
    Melee = "Melee",
    Magic = "Magic",
    Ranged = "Ranged",
    WeaponDamage = "WeaponDamage",
    Surface = "Surface",
    DoT = "DoT",
    Reflected = "Reflected",
}

local SkillRequirement = {
    MeleeWeapon = "MeleeWeapon",
    RangedWeapon = "RangedWeapon",
    StaffWeapon = "StaffWeapon",
    DaggerWeapon = "DaggerWeapon",
    ShieldWeapon = "ShieldWeapon",
    RifleWeapon = "RifleWeapon",
    ArrowWeapon = "ArrowWeapon",
}

---@param skill StatEntrySkillData
---@return string
local function GetSkillHitType(skill)
    local hitType = HitType.Magic
    if skill.UseWeaponDamage == "Yes" then
        hitType = HitType.WeaponDamage
    end
    if skill.UseCharacterStats ~= "Yes" then
        return hitType
    end
    if skill.Requirement == SkillRequirement.MeleeWeapon
    or skill.Requirement == SkillRequirement.DaggerWeapon
    or skill.Requirement == SkillRequirement.ShieldWeapon
    --or skill.Requirement == SkillRequirement.StaffWeapon -- Not used? :(
    then
        return HitType.Melee
    end
    if skill.Requirement == SkillRequirement.RangedWeapon
    or skill.Requirement == SkillRequirement.ArrowWeapon
    or skill.Requirement == SkillRequirement.RifleWeapon then
        return HitType.Ranged
    end
    return hitType
end

---@param skill string
---@param attacker string|StatCharacter
---@param target string|StatCharacter
---@param handle integer
---@param noRandomization boolean
---@param forceCrit boolean
---@param alwaysHit boolean
function GameHelpers.Damage.CalculateSkillDamage(skill, attacker, target, handle, noRandomization, forceCrit, alwaysHit)
    if type(attacker) == "string" then
        attacker = Ext.GetCharacter(attacker).Stats
    end
    if type(target) == "string" then
        target = Ext.GetCharacter(target).Stats
    end

    local skillData = GameHelpers.Ext.CreateSkillTable(skill)

    local damageList, deathType = Game.Math.GetSkillDamage(skillData, attacker, 0, GameHelpers.Status.IsSneakingOrInvisible(attacker.MyGuid), attacker.Position, target.Position, attacker.Level, noRandomization or false)

    local highGroundFlag = ""
    if attacker.Character.WorldPos[1] > target.Character.WorldPos[1] then
        highGroundFlag = "HighGround"
    elseif attacker.Character.WorldPos[1] < target.Character.WorldPos[1] then
        highGroundFlag = "LowGround"
    end

    ---@type HitRequest
    local hit = {
        Equipment = 0,
        TotalDamageDone = 0,
        DamageDealt = 0,
        DeathType = deathType,
        AttackDirection = 0,
        ArmorAbsorption = 0,
        LifeSteal = 0,
        EffectFlags = 0,
        HitWithWeapon = skillData.UseWeaponDamage == "Yes",
        DamageList = damageList,
    }

    local hitType = GetSkillHitType(skill)
    local criticalRoll = "Roll"
    if forceCrit == true then
        criticalRoll = "Critical"
    elseif forceCrit == false then
        criticalRoll = "NotCritical"
    end

    return Game.Math.ComputeCharacterHit(target, attacker, attacker.MainWeapon, damageList, hitType, alwaysHit or false, false, hit, skill.AlwaysBackstab, highGroundFlag, criticalRoll)
end

---Applies hit request flags to a hit status.
---@param hit HitRequest
---@param target string|StatCharacter
---@param handle integer
function GameHelpers.Damage.ApplyHitRequestFlags(hit, target, handle)
    for flag,num in pairs(Game.Math.HitFlag) do
        if hit.EffectFlags & num ~= 0 then
            NRD_StatusSetInt(target, handle, flag, 1)
        else
            NRD_StatusSetInt(target, handle, flag, 0)
        end
    end
end