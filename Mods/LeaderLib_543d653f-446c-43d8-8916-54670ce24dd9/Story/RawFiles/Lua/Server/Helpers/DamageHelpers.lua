if GameHelpers.Damage == nil then
	GameHelpers.Damage = {}
end

local _EXTVERSION = Ext.Utils.Version()

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
---@param handle integer|ObjectHandle The hit or status handle.
---@param damageIncrease number The percentage to increase damage by. 0.5 = 50%, 2.0 = 200%.
---@param isHitType boolean Whether the handle is from a STATUS or a HIT. NRD_OnPrepareHit uses hit handles, while NRD_OnHit uses status handles.
---@return boolean
local function IncreaseDamage(target, attacker, handle, damageIncrease, isHitType)
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
    handle = Common.SafeguardParam(handle, "integer", nil)
    if handle then
        IncreaseDamage(target, attacker, handle, amount, is_hit_param == 1)
    end
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
        GameHelpers.Damage.RedirectDamage(target, defender, attacker, handle, reduction, isHit)
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
    or skill.Requirement == SkillRequirement.RifleWeapon
    or skill.Requirement == SkillRequirement.ArrowWeapon
    then
        return HitType.Ranged
    end
    return hitType
end

GameHelpers.GetSkillHitType = GetSkillHitType

---@deprecated
---@param skill string
---@param attacker string|StatCharacter
---@param target string|StatCharacter
---@param handle integer|nil
---@param noRandomization boolean|nil
---@param forceCrit boolean|nil
---@param alwaysHit boolean|nil
function GameHelpers.Damage.CalculateSkillDamage(skill, attacker, target, handle, noRandomization, forceCrit, alwaysHit)
    if type(attacker) == "string" then
        attacker = GameHelpers.GetCharacter(attacker).Stats
    end
    if type(target) == "string" then
        target = GameHelpers.GetCharacter(target).Stats
    end

    local skillData = GameHelpers.Ext.CreateSkillTable(skill, nil, true)

    local damageList, deathType = Game.Math.GetSkillDamage(skillData, attacker, 0, GameHelpers.Status.IsSneakingOrInvisible(attacker.MyGuid), attacker.Position, target.Position, attacker.Level, noRandomization or false, nil, nil)

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
        Handled = false,
        SkillProperties = skillData.SkillProperties
    }

    if _EXTVERSION >= 56 then
        for k,v in pairs(Game.Math.HitFlag) do
            hit[k] = false
        end
        hit.Hit = true
    end
    
    local hitType = GetSkillHitType(skill)
    local criticalRoll = "Roll"
    if forceCrit == true then
        criticalRoll = "Critical"
    elseif forceCrit == false then
        criticalRoll = "NotCritical"
    end

    local backstab = false
    for _,v in pairs(GameHelpers.Stats.GetSkillProperties(skill)) do
        if v.Action == "AlwaysBackstab" then
            backstab = true
            break
        end
    end

    local result = HitOverrides._ComputeCharacterHitFunction(target, attacker, attacker.MainWeapon, damageList, hitType, alwaysHit or false, false, hit, backstab, highGroundFlag, criticalRoll)
    
end

---Applies hit request flags to a hit status.
---@param hit HitRequest
---@param target string|StatCharacter
---@param handle integer
function GameHelpers.Damage.ApplyHitRequestFlags(hit, target, handle)
    if _EXTVERSION < 56 then
        for flag,num in pairs(Game.Math.HitFlag) do
            if hit.EffectFlags & num ~= 0 then
                NRD_StatusSetInt(target, handle, flag, 1)
            else
                NRD_StatusSetInt(target, handle, flag, 0)
            end
        end
    else
        for flag,num in pairs(Game.Math.HitFlag) do
            if hit[flag] == true then
                NRD_StatusSetInt(target, handle, flag, 1)
            else
                NRD_StatusSetInt(target, handle, flag, 0)
            end
        end
    end
end

---@param skill StatEntrySkillData
---@param attacker StatCharacter
---@param target StatCharacter
---@param isFromItem boolean
---@param stealthed boolean
---@param attackerPos number[]
---@param targetPos number[]
---@param level integer
---@param noRandomization boolean
---@param mainWeapon StatItem  Optional mainhand weapon to use in place of the attacker's.
---@param offHandWeapon StatItem   Optional offhand weapon to use in place of the attacker's.
---@return DamageList damageList
---@return DeathType deathType
local function GetSkillDamageWithTarget(skill, attacker, target, isFromItem, stealthed, attackerPos, targetPos, level, noRandomization, mainWeapon, offHandWeapon)
    if attacker ~= nil and level < 0 then
        level = attacker.Level
    end

    local damageMultiplier = skill['Damage Multiplier'] * 0.01
    local damageMultipliers = Game.Math.GetDamageMultipliers(skill, stealthed, attackerPos, targetPos)
    local skillDamageType = nil

    if level == 0 then
        level = skill.OverrideSkillLevel
        if level == 0 then
            level = skill.Level
        end
    end

    local damageList = Ext.Stats.NewDamageList()

    if damageMultiplier <= 0 then
        return
    end

    if skill.UseWeaponDamage == "Yes" then
        local damageType = skill.DamageType
        if damageType == "None" or damageType == "Sentinel" then
            damageType = nil
        end

        local weapon = mainWeapon or attacker.MainWeapon
        local offHand = offHandWeapon or attacker.OffHandWeapon

        if weapon ~= nil then
            local mainDmgs = Game.Math.CalculateWeaponDamage(attacker, weapon, noRandomization)
            mainDmgs:Multiply(damageMultipliers)
            if damageType ~= nil then
                mainDmgs:ConvertDamageType(damageType)
            end
            damageList:Merge(mainDmgs)
        end

        if offHand ~= nil and Game.Math.IsRangedWeapon(weapon) == Game.Math.IsRangedWeapon(offHand) then
            local offHandDmgs = Game.Math.CalculateWeaponDamage(attacker, offHand, noRandomization)
            offHandDmgs:Multiply(damageMultipliers)
            if damageType ~= nil then
                offHandDmgs:ConvertDamageType(damageType)
                skillDamageType = damageType
            end
            damageList:Merge(offHandDmgs)
        end

        damageList:AggregateSameTypeDamages()
    else
        local damageType = skill.DamageType

        local baseDamage = Game.Math.CalculateBaseDamage(skill.Damage, attacker, target, level)
        local damageRange = skill['Damage Range']
        local randomMultiplier
        if noRandomization then
            randomMultiplier = 0.0
        else
            randomMultiplier = 1.0 + (Ext.Random(0, damageRange) - damageRange/2) * 0.01
        end

        local attrDamageScale
        local skillDamage = skill.Damage
        if skillDamage == "BaseLevelDamage" or skillDamage == "AverageLevelDamge" or skillDamage == "MonsterWeaponDamage" then
            attrDamageScale = Game.Math.GetSkillAttributeDamageScale(skill, attacker)
        else
            attrDamageScale = 1.0
        end

        local damageBoost
        if attacker ~= nil then
            damageBoost = attacker.DamageBoost / 100.0 + 1.0
        else
            damageBoost = 1.0
        end
        
        local finalDamage = baseDamage * randomMultiplier * attrDamageScale * damageMultipliers
        finalDamage = math.max(Ext.Round(finalDamage), 1)
        finalDamage = math.ceil(finalDamage * damageBoost)
        damageList:Add(damageType, finalDamage)

        if attacker ~= nil then
            Game.Math.ApplyDamageBoosts(attacker, damageList)
        end
    end

    local deathType = skill.DeathType
    if deathType == "None" then
        if skill.UseWeaponDamage == "Yes" then
            deathType = Game.Math.GetDamageListDeathType(damageList)
        else
            if skillDamageType == nil then
                skillDamageType = skill.DamageType
            end

            deathType = Game.Math.DamageTypeToDeathType(skillDamageType)
        end
    end

    return damageList, deathType
end

local defaultHitFlags = {
    Hit = true,
}

---@class GameHelpers.Damage.BaseApplyDamageParams
---@field CriticalRoll StatsCriticalRoll|nil Used when computating a character hit. Defaults to "Roll".
---@field HighGroundFlag StatsHighGroundBonus|nil Used when computating a character hit. If not set, this will be determined using the height difference.
---@field HitParams table<string,any>|nil Hit parameters to apply.
---@field MainWeapon CDivinityStatsItem|nil A weapon to use in place of the source's main weapon.
---@field OffhandWeapon CDivinityStatsItem|nil A weapon to use in place of the source's offhand weapon.
---@field HitType HitTypeValues|nil The hit type. Defaults to "Magic".
---@field StatusParams EsvStatusHit|nil Params to set on the hit status

---@class GameHelpers.Damage.ApplySkillDamageParams:GameHelpers.Damage.BaseApplyDamageParams
---@field GetDamageFunction fun(skillData:StatEntrySkillData, attacker:StatCharacter, isFromItem:boolean, stealthed:boolean, attackerPos:number[], targetPos:number[], level:integer, noRandomization:boolean, mainWeapon:StatEntryWeapon|nil, offhandWeapon:StatEntryWeapon|nil):DamageList,string|nil An optional function to use to calculate damage.
---@field ApplySkillProperties boolean|nil
---@field SkillDataParamModifiers StatEntrySkillData|nil
---@field DivideDamageTargets integer|nil If the skill has DivideDamage set, divide the damage between this many targets. Defaults to 1.

---@type GameHelpers.Damage.ApplySkillDamageParams
local _defaultSkillParams = {
    HitType = "Magic"
}

---Create a HIT status and apply the corresponding skill parameters.
---@param source CharacterParam
---@param target ObjectParam
---@param skill string
---@param params GameHelpers.Damage.ApplySkillDamageParams|nil
function GameHelpers.Damage.ApplySkillDamage(source, target, skill, params)
    source = GameHelpers.TryGetObject(source)
    fassert(source ~= nil, "Failed to get object for source (%s)", source)
    target = GameHelpers.TryGetObject(target)
    fassert(target ~= nil, "Failed to get object for target (%s)", target)

    params = params or _defaultSkillParams

    local criticalRoll = params.CriticalRoll or "Roll"
    ---@type StatsHighGroundBonus
    local highGroundFlag = params.HighGroundFlag or nil

    ---@type EsvStatusHit
    local hit = Ext.PrepareStatus(target.MyGuid, "HIT", 0.0)

    hit.TargetHandle = target.Handle
    hit.StatusSourceHandle = source.Handle

    local skillData = GameHelpers.Ext.CreateSkillTable(skill, nil, true)
    if params.SkillDataParamModifiers then
        for k,v in pairs(params.SkillDataParamModifiers) do
            skillData[k] = v
        end
    end

    local hitType = GetSkillHitType(skillData)
    hit.SkillId = skill
    hit.ImpactOrigin = source.WorldPos
    hit.ImpactPosition = target.WorldPos
    hit.ImpactDirection = {-target.Stats.Rotation[7],0,-target.Stats.Rotation[9]}
    hit.HitReason = Data.HitReason.ExecPropertyDamage
    hit.Hit.Hit = true
    hit.Hit.DamageType = skillData.DamageType
    hit.Hit.Missed = false
    hit.Hit.Blocked = false
    hit.Hit.Dodged = false
    hit.Hit.NoEvents = true
    hit.ForceInterrupt = false
    hit.ForceStatus = true
    hit.AllowInterruptAction = false
    hit.Interruption = false
    hit.HitByHandle = source.Handle

    if skillData.UseWeaponDamage then
        hit.Hit.HitWithWeapon = true
    end

    local hitParams = params.HitParams or defaultHitFlags
    if hitParams ~= nil then
        for k,v in pairs(hitParams) do
            if k == "HitType" then
                hitType = v
            else
                pcall(function ()
                    hit.Hit[k] = v
                end)
            end
        end
    end

    local pos = source.WorldPos
    local targetPos = target.WorldPos
    local level = source.Stats.Level

    local alwaysBackstab = false
    if skillData.SkillProperties then
        for _,v in pairs(skillData.SkillProperties) do
            if v.Action == "AlwaysBackstab" then
                alwaysBackstab = true
            elseif v.Action == "AlwaysHighGround" then
                --Supersedes any MARKED behavior
                highGroundFlag = "HighGround"
            end
        end
    end

    if highGroundFlag == nil then
        highGroundFlag = GameHelpers.Character.GetHighGroundFlag(source, target)
    end

    ---@type DamageList
    local damageList = nil
    ---@type DeathType
    local deathType = "None"

    if params.GetDamageFunction ~= nil then
        local b,result,result2 = xpcall(params.GetDamageFunction, debug.traceback, skillData, source.Stats, false, false, pos, targetPos, level, false, params.MainWeapon, params.OffhandWeapon)

        if not b then
            Ext.Utils.PrintError(result)
        else
            damageList = result
            deathType = result2
        end
    else
        damageList,deathType = GetSkillDamageWithTarget(skillData, source.Stats, target.Stats, false, false, pos, targetPos, level, false, params.MainWeapon, params.OffhandWeapon)
    end

    if params.ApplySkillProperties then
        Ext.ExecuteSkillPropertiesOnTarget(skill, source.MyGuid, target.MyGuid, targetPos, "Target", false)
        Ext.ExecuteSkillPropertiesOnTarget(skill, source.MyGuid, target.MyGuid, source.WorldPos, Data.PropertyContext.Self | Data.PropertyContext.SelfOnHit, false)
    end

    if damageList then
        if skillData.SkillType == "Projectile" and skillData.DivideDamage == "Yes" and skillData.ProjectileCount and skillData.ProjectileCount > 0 then
            --The engine splits the damage by the ProjectileCount
            local hitCount = math.min(params.DivideDamageTargets or 1, skillData.ProjectileCount)
            
            --Skip doing anything if the damage divider would be 1 anyway
            if hitCount > 0 and hitCount ~= skillData.ProjectileCount then
                local damages = GameHelpers.Damage.DivideDamage(damageList, hitCount)
                --Use the last entry, since it gets the remainder
                damageList = damages[#damages]
            end
        end
        hit.Hit.DamageList:Merge(damageList)
        GameHelpers.Hit.RecalculateLifeSteal(hit.Hit, target.Stats, source.Stats, hitType, true, true)
        if GameHelpers.Ext.ObjectIsCharacter(target) and GameHelpers.Ext.ObjectIsCharacter(source) then
            if HitOverrides._ComputeCharacterHitFunction(target.Stats, source.Stats, source.Stats.MainWeapon, damageList, hitType, false, false, hit.Hit, alwaysBackstab, highGroundFlag, criticalRoll) then
                
            end
        end
        for _,damage in pairs(damageList:ToTable()) do
            hit.Hit.TotalDamageDone = hit.Hit.TotalDamageDone + damage.Amount
            hit.Hit.DamageDealt = hit.Hit.DamageDealt + damage.Amount
            if StringHelpers.IsNullOrEmpty(hit.Hit.DamageType) then
                hit.Hit.DamageType = damage.DamageType
            end
        end
        if not StringHelpers.IsNullOrEmpty(deathType) then
            hit.Hit.DeathType = deathType
        end

        --[[ if params.InvokeSkillHitListeners then
            --TODO Figure out something for EsvPendingHit and HitData, check if StatusHitEnter fires anyway
            ---@type EsvPendingHit
            local context = {
                AttackerHandle = source.Handle,
                CapturedCharacterHit = false,
                CharacterHit = hit.Hit,
                CharacterHitDamageList = hit.Hit.DamageList,
                CharacterHitPointer = hit.Hit,
                CriticalRoll = criticalRoll,
                ForceReduceDurability = false,
                HighGround = highGroundFlag,
                HitType = hitType,
                Id = -1,
                NoHitRoll = false,
                ProcWindWalker = false,
                Status = hit,
                TargetHandle = target.Handle,
                WeaponStats = source.Stats.MainWeapon,
            }
            local hitData = Classes.HitData:Create(target, source, hit, context, hit.Hit, skillData)
            hitData.IsFromApplySkillDamage = true
            OnSkillHit(skill, target, source, hit.Hit.TotalDamageDone, hit.Hit, context, hit, hitData)
        end ]]
        Ext.ApplyStatus(hit)
    end
end

---@alias HitTypeValues string|"Melee"|"Magic"|"Ranged"|"WeaponDamage"|"Surface"|"DoT"|"Reflected"
---@alias DamageEnum string|"BaseLevelDamage"|"AverageLevelDamge"|"MonsterWeaponDamage"|"SourceMaximumVitality"|"SourceMaximumPhysicalArmor"|"SourceMaximumMagicArmor"|"SourceCurrentVitality"|"SourceCurrentPhysicalArmor"|"SourceCurrentMagicArmor"|"SourceShieldPhysicalArmor"|"TargetMaximumVitality"|"TargetMaximumPhysicalArmor"|"TargetMaximumMagicArmor"|"TargetCurrentVitality"|"TargetCurrentPhysicalArmor"|"TargetCurrentMagicArmor"

---@param source EsvCharacter
---@param target EsvCharacter|EclItem
---@param damageEnum DamageEnum|nil
---@param damageType DamageType|nil
---@param damageMultiplier number|nil
---@param damageRange number|nil
---@return DamageList
---@return DeathType
local function GetBasicDamage(source, target, damageEnum, damageType, damageMultiplier, damageRange)
    local attacker = source.Stats
    damageEnum = damageEnum or "AverageLevelDamge"
    damageType = damageType or "Physical"
    damageMultiplier = damageMultiplier or 100
    damageRange = damageRange or 10

    local randomMultiplier = 1.0 + (Ext.Random(0, damageRange) - damageRange/2) * 0.01
    local baseDamage = Game.Math.CalculateBaseDamage(damageEnum, source.Stats, target.Stats, source.Stats.Level)

    local damageList = Ext.Stats.NewDamageList()

    local attrDamageScale = 0
    if damageEnum == "BaseLevelDamage" or damageEnum == "AverageLevelDamge" or damageEnum == "MonsterWeaponDamage" then
        local main = attacker.MainWeapon
        local offHand = attacker.OffHandWeapon
        local primaryAttr = 0
        if offHand ~= nil and Game.Math.IsRangedWeapon(main) == Game.Math.IsRangedWeapon(offHand) then
            primaryAttr = (Game.Math.GetItemRequirementAttribute(attacker, main) + Game.Math.GetItemRequirementAttribute(attacker, offHand)) * 0.5
        else
            primaryAttr = Game.Math.GetItemRequirementAttribute(attacker, main)
        end
        attrDamageScale = 1.0 + Game.Math.ScaledDamageFromPrimaryAttribute(primaryAttr)
    else
        attrDamageScale = 1.0
    end

    local damageBoost = 0
    if attacker ~= nil then
        damageBoost = attacker.DamageBoost / 100.0 + 1.0
    else
        damageBoost = 1.0
    end
    
    local finalDamage = baseDamage * randomMultiplier * attrDamageScale * damageMultiplier
    finalDamage = math.max(Ext.Round(finalDamage), 1)
    finalDamage = math.ceil(finalDamage * damageBoost)
    damageList:Add(damageType, finalDamage)

    if attacker ~= nil then
        Game.Math.ApplyDamageBoosts(attacker, damageList)
    end

    return damageList, (Game.Math.GetDamageListDeathType(damageList) or "None")
end

---@class GameHelpers.Damage.ApplyDamageParams:GameHelpers.Damage.BaseApplyDamageParams
---@field GetDamageFunction fun(source:EsvCharacter, target:EsvCharacter|EsvItem, GameHelpers.Damage.ApplyDamageParams):DamageList,string|nil An optional function to use to calculate damage.
---@field UseWeaponDamage boolean|nil
---@field DamageMultiplier number|nil
---@field DamageRange number|nil
---@field DamageType string|nil
---@field DamageEnum DamageEnum|nil
---@field DamageList StatsDamagePairList|nil Set to provide the direct damage to apply.
---@field DeathType StatsDeathType|nil
---@field FixedAmount integer|nil Skip calculating damage, and just apply a fixed amount instead.

---@type GameHelpers.Damage.ApplyDamageParams
local _defaultParams = {
    HitType = "Magic",
    DamageType = "Physical",
    DamageMultiplier = 1,
    DamageRange = 1,
    DamageEnum = "AverageLevelDamge",
    UseWeaponDamage = false,
    CriticalRoll = "Roll",
}

---Create a HIT status and apply the corresponding skill parameters.
---@param source ObjectParam
---@param target ObjectParam
---@param params GameHelpers.Damage.ApplyDamageParams|nil
function GameHelpers.Damage.ApplyDamage(source, target, params)
    source = GameHelpers.TryGetObject(source)
    fassert(source ~= nil, "Failed to get object for source (%s)", source)
    target = GameHelpers.TryGetObject(target)
    fassert(target ~= nil, "Failed to get object for target (%s)", target)

    params = params or _defaultParams

    local criticalRoll = params.CriticalRoll or _defaultParams.CriticalRoll
    ---@type StatsHighGroundBonus
    local highGroundFlag = params.HighGroundFlag or nil

    local status = Ext.PrepareStatus(target.MyGuid, "HIT", 0.0)
    ---@cast status EsvStatusHit

    status.TargetHandle = target.Handle
    status.StatusSourceHandle = source.Handle

    local hitType = params.HitType or _defaultParams.HitType
    status.ImpactOrigin = source.WorldPos
    status.ImpactPosition = target.WorldPos
    status.ImpactDirection = {-target.Stats.Rotation[7],0,-target.Stats.Rotation[9]}
    status.HitReason = Data.HitReason.ApplyDamage
    status.Hit.Hit = true
    status.Hit.DamageType = params.DamageType or _defaultParams.DamageType
    status.Hit.Missed = false
    status.Hit.Blocked = false
    status.Hit.Dodged = false
    status.Hit.NoEvents = true
    status.ForceInterrupt = false
    status.ForceStatus = true
    status.AllowInterruptAction = false
    status.Interruption = false
    status.HitByHandle = source.Handle

    if params.UseWeaponDamage then
        status.Hit.HitWithWeapon = true
    end

    local hitParams = params.HitParams or defaultHitFlags
    if type(hitParams) == "table" then
        for k,v in pairs(hitParams) do
            if k == "HitType" then
                hitType = v
            else
                pcall(function ()
                    status.Hit[k] = v
                end)
            end
        end
    end

    if type(params.StatusParams) == "table" then
        for k,v in pairs(params.StatusParams) do
            pcall(function ()
                status[k] = v
            end)
        end
    end

    local alwaysBackstab = false

    if highGroundFlag == nil then
        highGroundFlag = GameHelpers.Character.GetHighGroundFlag(source, target)
    end

    ---@type DamageList
    local damageList = nil
    ---@type DeathType
    local deathType = params.DeathType or "None"

    if params.DamageList then
        damageList = Ext.Stats.NewDamageList()
        damageList:CopyFrom(params.DamageList)
    else
        if params.FixedAmount then
            damageList = Ext.Stats.NewDamageList()
            damageList:Add(status.Hit.DamageType, params.FixedAmount)
        else
            if params.GetDamageFunction ~= nil then
                local b,result,result2 = xpcall(params.GetDamageFunction, debug.traceback, source, target, params)
        
                if not b then
                    Ext.Utils.PrintError(result)
                else
                    damageList = result
                    deathType = result2 or deathType or "None"
                end
            else
                damageList,deathType = GetBasicDamage(source, target, params.DamageEnum, params.DamageType, params.DamageMultiplier, params.DamageRange)
            end
        end
    end

    if damageList then
        status.Hit.DamageList:Merge(damageList)
        GameHelpers.Hit.RecalculateLifeSteal(status.Hit, target.Stats, source.Stats, hitType, true, true)
        if GameHelpers.Ext.ObjectIsCharacter(target) and GameHelpers.Ext.ObjectIsCharacter(source) then
            if HitOverrides._ComputeCharacterHitFunction(target.Stats, source.Stats, source.Stats.MainWeapon, damageList, hitType, false, false, status.Hit, alwaysBackstab, highGroundFlag, criticalRoll) then
                if params.FixedAmount then
                    damageList:Clear(status.Hit.DamageType)
                    damageList:Add(status.Hit.DamageType, params.FixedAmount)
                end
            end
        end
        for _,damage in pairs(damageList:ToTable()) do
            status.Hit.TotalDamageDone = status.Hit.TotalDamageDone + damage.Amount
            status.Hit.DamageDealt = status.Hit.DamageDealt + damage.Amount
            if StringHelpers.IsNullOrEmpty(status.Hit.DamageType) then
                status.Hit.DamageType = damage.DamageType
            end
        end
        if not StringHelpers.IsNullOrEmpty(deathType) then
            status.Hit.DeathType = deathType
        end
        Ext.ApplyStatus(status)
    end
end

---@deprecated
---Uses the older NRD_HitPrepare syntax to create a hit using skill properties.
---@param source ObjectParam
---@param target ObjectParam
---@param skill string
---@param hitParams table<string,any>|nil
---@param mainWeapon StatItem|nil
---@param offhandWeapon StatItem|nil
---@param applySkillProperties boolean|nil
---@param getDamageFunction function|nil
---@param skillDataParamModifiers StatEntrySkillData|nil
function GameHelpers.Damage.PrepareApplySkillDamage(source, target, skill, hitParams, mainWeapon, offhandWeapon, applySkillProperties, getDamageFunction, skillDataParamModifiers)
    source = GameHelpers.TryGetObject(source)
    fassert(source ~= nil, "Failed to get object for source (%s)", source)
    target = GameHelpers.TryGetObject(target)
    fassert(target ~= nil, "Failed to get object for target (%s)", target)

    local hit = NRD_HitPrepare(target.MyGuid, source.MyGuid)
    NRD_HitSetInt(hit, "SimulateHit", 1)

    local skillData = GameHelpers.Ext.CreateSkillTable(skill, nil, true)
    if type(skillDataParamModifiers) == "table" then
        for k,v in pairs(skillDataParamModifiers) do
            skillData[k] = v
        end
    end

    local hitType = GetSkillHitType(skillData)
    NRD_HitSetString(hit, "HitType", hitType)

    if skillData.UseWeaponDamage then
        NRD_HitSetInt(hit, "HitWithWeapon", 1)
    end

    hitParams = hitParams or defaultHitFlags
    if hitParams ~= nil then
        for k,v in pairs(hitParams) do
            if type(k) == "string" then
                local t = type(v)
                if t == "number" then
                    NRD_HitSetInt(hit, k, v)
                elseif t == "boolean" then
                    NRD_HitSetInt(hit, k, v and 1 or 0)
                elseif t == "string" then
                    NRD_HitSetString(hit, k, v)
                end
            end
        end
    end

    local pos = source.WorldPos
    local targetPos = target.WorldPos
    local level = source.Stats.Level

    local damageList,deathType = nil,nil

    if getDamageFunction ~= nil then
        local b,result,result2 = xpcall(getDamageFunction, debug.traceback, skillData, source.Stats, false, false, pos, targetPos, level, false, mainWeapon, offhandWeapon)

        if not b then
            Ext.Utils.PrintError(result)
        else
            damageList = result
            deathType = result2
        end
    else
        damageList,deathType = GetSkillDamageWithTarget(skillData, source.Stats, target.Stats, false, false, pos, targetPos, level, false, mainWeapon, offhandWeapon)
    end

    if applySkillProperties then
        Ext.ExecuteSkillPropertiesOnTarget(skill, source.MyGuid, target.MyGuid, targetPos, "Target", false)
        Ext.ExecuteSkillPropertiesOnTarget(skill, source.MyGuid, target.MyGuid, source.WorldPos, Data.PropertyContext.Self | Data.PropertyContext.SelfOnHit, false)
    end

    if damageList then
        for _,damage in pairs(damageList:ToTable()) do
            NRD_HitAddDamage(hit, damage.DamageType, damage.Amount)
        end
        if not StringHelpers.IsNullOrEmpty(deathType) then
            NRD_HitSetString(hit, "DeathType", deathType)
        end
        for k,t in pairs(Classes.HitPrepareData.HIT_ATTRIBUTE) do
            if t == "number" or "boolean" then
                print(k, NRD_HitGetInt(hit, k))
            elseif t == "string" then
                print(k, NRD_HitGetString(hit, k))
            end
        end
        NRD_HitExecute(hit)
    end
end