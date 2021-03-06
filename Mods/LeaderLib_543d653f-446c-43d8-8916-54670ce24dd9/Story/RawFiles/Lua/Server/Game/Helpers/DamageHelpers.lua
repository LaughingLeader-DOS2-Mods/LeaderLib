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
function GameHelpers.Damage.ReduceDamage(target, attacker, handle, reduction, isHitHandle)
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

-- Legacy
GameHelpers.ReduceDamage = GameHelpers.Damage.ReduceDamage

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
    return GameHelpers.Damage.ReduceDamage(target, attacker, handle, reduction, is_hit_param == 1)
end

Ext.NewCall(ReduceDamage_Call, "LeaderLib_Hit_ReduceDamage", "(GUIDSTRING)_Target, (GUIDSTRING)_Attacker, (INTEGER64)_Handle, (REAL)_Percentage, (INTEGER)_IsHitHandle")

---Increase damage by a percentage (0.5 = 50%). This increases damage for all damage types in the hit.
---@param target string The target object.
---@param attacker string The attacking character.
---@param handle integer The hit or status handle.
---@param damageIncrease number The percentage to increase damage by. 0.5 = 50%, 2.0 = 200%.
---@param isHitType boolean Whether the handle is from a STATUS or a HIT. NRD_OnPrepareHit uses hit handles, while NRD_OnHit uses status handles.
---@return boolean
local function IncreaseDamage(target, attacker, handle, damageIncrease, isHitType)
    handle = Common.SafeguardParam(handle, "number", nil)
    if handle == nil then error("[LeaderLib_GameMechanics.lua:IncreaseDamage] Handle is null! Skipping.") end
    damageIncrease = Common.SafeguardParam(damageIncrease, "number", 0.5)
    local isHit = isHitType == true or isHitType == 1
	local success = false
    for i,damageType in Data.DamageTypes:Get() do
        local damage = nil
        if isHit ~= true then
            damage = NRD_HitStatusGetDamage(target, handle, damageType) or 0
        else
            damage = NRD_HitGetDamage(handle, damageType) or 0
        end
        if damage > 0 then
            --NRD_HitStatusClearDamage(target, handle, damageType)
            local increased_damage = Ext.Round(damage * damageIncrease)
            if increased_damage ~= 0 then
                if isHit ~= true then
                    NRD_HitStatusAddDamage(target, handle, damageType, increased_damage)
                else
                    NRD_HitAddDamage(handle, damageType, increased_damage)
                end
                success = true
            end
        end
	end
	return success
end

local function IncreaseDamage_Call(target, attacker, handle, amount, is_hit_param)
    IncreaseDamage(target, attacker, handle, amount, is_hit_param == 1)
end

Ext.NewCall(IncreaseDamage_Call, "LeaderLib_Hit_IncreaseDamage", "(GUIDSTRING)_Target, (GUIDSTRING)_Attacker, (INTEGER64)_Handle, (REAL)_Percentage, (INTEGER)_IsHitHandle")
GameHelpers.Damage.IncreaseDamage = IncreaseDamage
-- Legacy
GameHelpers.IncreaseDamage = IncreaseDamage

---Redirect damage to another target.
---@param target string
---@param defender string
---@param attacker string
---@param handle integer
---@param reduction number
---@param isHit boolean
---@return boolean
function GameHelpers.Damage.RedirectDamage(target, defender, attacker, handle, reduction, isHit)
	PrintDebug("[LeaderLib_GameMechanics.lua:RedirectDamage] Reducing damage to ("..tostring(reduction)..") of total. Handle("..tostring(handle).."). Target("..tostring(target)..") Defender("..tostring(defender)..") Attacker("..tostring(attacker)..") IsHit("..tostring(isHit)..")")
    --if CanRedirectHit(defender, handle, hit_type) then -- Ignore surface, DoT, and reflected damage
    --local hit_type_name = NRD_StatusGetString(defender, handle, "DamageSourceType")
    --local hit_type = NRD_StatusGetInt(defender, handle, "HitType")
    --PrintDebug("[LeaderLib_GameMechanics.lua:RedirectDamage] Redirecting damage Handle("..handlestr.."). Blocker(",target,") Target(",defender,") Attacker(",attacker,")")
    local redirected_hit = NRD_HitPrepare(defender, attacker)
    local damageRedirected = false

    for i,damageType in Data.DamageTypes:Get() do
        local damage = nil
        if isHit ~= true then
            damage = NRD_HitStatusGetDamage(target, handle, damageType)
        else
            damage = NRD_HitGetDamage(handle, damageType)
        end
        if damage ~= nil and damage > 0 then
            local reduced_damage = math.max(math.ceil(damage * reduction), 1)
            --NRD_HitStatusClearDamage(defender, handle, damageType)
            local removed_damage = damage * -1
            if isHit ~= true then
                NRD_HitStatusAddDamage(target, handle, damageType, removed_damage)
            else
                NRD_HitAddDamage(handle, damageType, removed_damage)
            end
            NRD_HitAddDamage(redirected_hit, damageType, reduced_damage)
            PrintDebug("[LeaderLib_GameMechanics.lua:RedirectDamage] Redirected damage: "..tostring(damage).." => "..tostring(reduced_damage).." for type: "..damageType)
            damageRedirected = true
        end
    end

    if damageRedirected then
        local is_crit = false
        if isHit ~= true then
            is_crit = NRD_StatusGetInt(defender, handle, "CriticalHit") == 1
        else
            is_crit = NRD_HitGetInt(handle, "CriticalHit") == 1
        end
        if is_crit then
            NRD_HitSetInt(redirected_hit, "CriticalRoll", 1)
        else
            NRD_HitSetInt(redirected_hit, "CriticalRoll", 2)
        end
        NRD_HitSetInt(redirected_hit, "SimulateHit", 1)
        NRD_HitSetInt(redirected_hit, "HitType", 6)
        NRD_HitSetInt(redirected_hit, "Hit", 1)
        NRD_HitSetInt(redirected_hit, "NoHitRoll", 1)
        NRD_HitExecute(redirected_hit)
	end
	return damageRedirected
end

---Redirect damage to another target.
---@param target string
---@param defender string
---@param attacker string
---@param handle_param integer
---@param reduction_perc number
---@param is_hit_param integer
---@return boolean
local function RedirectDamage_Call(target, defender, attacker, handle_param, reduction_perc, is_hit_param)
    local handle = Common.SafeguardParam(handle_param, "integer", nil)
    if handle == nil then 
        error("[LeaderLib_GameMechanics.lua:RedirectDamage] Handle is null! Skipping.") 
    else
        local reduction = Common.SafeguardParam(reduction_perc, "number", 0.5)
        local isHit = is_hit_param == true or (Common.SafeguardParam(is_hit_param, "integer", 0) and is_hit_param == 1)
        GameHelpers.RedirectDamage(target, defender, attacker, handle, reduction, isHit)
    end
end

Ext.NewCall(RedirectDamage_Call, "LeaderLib_Hit_RedirectDamage", "(GUIDSTRING)_Target, (GUIDSTRING)_Defender, (GUIDSTRING)_Attacker, (INTEGER64)_Handle, (REAL)_Percentage, (INTEGER)_IsHitHandle")

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

GameHelpers.GetSkillHitType = GetSkillHitType

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

---@param source EsvCharacter
---@param target string
---@param skill string
---@param hitParams table<string,any>|nil
---@param mainWeapon StatItem|nil
---@param offhandWeapon StatItem|nil
---@param applySkillProperties boolean|nil
---@param getDamageFunction function|nil
function GameHelpers.Damage.ApplySkillDamage(source, target, skill, hitParams, mainWeapon, offhandWeapon, applySkillProperties, getDamageFunction)
    local hit = NRD_HitPrepare(target, source.MyGuid)
    if hitParams ~= nil then
        for k,v in pairs(hitParams) do
            if type(k) == "string" then
                local t = type(v)
                if t == "number" then
                    NRD_HitSetInt(hit, k, v)
                elseif t == "string" then
                    NRD_HitSetString(hit, k, v)
                end
            end
        end
    end

    local skillData = GameHelpers.Ext.CreateSkillTable(skill)
    local pos = source.WorldPos
    local targetPos = table.pack(GetPosition(target))
    local level = source.Stats.Level

    if getDamageFunction == nil then
        getDamageFunction = Game.Math.GetSkillDamage
    end

    local b,damageList,deathType = xpcall(getDamageFunction, debug.traceback, skillData, source.Stats, false, false, pos, targetPos, level, false, mainWeapon, offhandWeapon)

    if not b then
        Ext.PrintError(damageList)
    else
        for _,damage in pairs(damageList:ToTable()) do
            NRD_HitAddDamage(hit, damage.DamageType, damage.Amount)
        end
        if not StringHelpers.IsNullOrEmpty(deathType) then
            NRD_HitSetString(hit, "DeathType", deathType)
        end
        NRD_HitExecute(hit)
    end
end