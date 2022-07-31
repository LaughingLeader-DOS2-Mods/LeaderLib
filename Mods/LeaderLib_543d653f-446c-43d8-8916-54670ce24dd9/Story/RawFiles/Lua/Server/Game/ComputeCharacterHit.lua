---@class LeaderLibHitOverrides
HitOverrides = {
    --- The original ositools version
    DoHitOriginal = Game.Math.DoHit,
    DoHitModified = nil, -- We get this in SessionLoaded in a case a mod has overwritten it.
    ApplyDamageCharacterBonusesOriginal = Game.Math.ApplyDamageCharacterBonuses,
    ApplyDamageCharacterBonusesModified = nil
}
--- This script tweaks Game.Math functions to allow lowering resistance with Resistance Penetration tags on items of the attacker.

local _EXTVERSION = Ext.Version()

--region Game.Math functions



--- @param character StatCharacter
--- @param attacker StatCharacter
--- @param damageList DamageList
function HitOverrides.ApplyDamageCharacterBonuses(character, attacker, damageList)
    damageList:AggregateSameTypeDamages()
    local preModifiedDamageList = damageList:ToTable()
    local resistancePenetration = HitOverrides.GetResistancePenetration(character, attacker)

    if HitOverrides.ApplyDamageCharacterBonusesModified ~= nil then
        -- Since a mod has overwritten ApplyDamageCharacterBonuses, let's swap out Game.Math.ApplyHitResistances for HitOverrides.ApplyDamageSkillAbilityBonuses
        -- The reason we're not overriding this in the first place is that Game.Math.ApplyHitResistances doesn't have a reference to the attacker character.
        local funcOriginal = Game.Math.ApplyHitResistances
        Game.Math.ApplyHitResistances = function(c, d)
            HitOverrides.ApplyHitResistances(c, d, resistancePenetration, preModifiedDamageList)
        end
        HitOverrides.ApplyDamageCharacterBonusesModified(character, attacker, damageList)
        -- Reset it back so we don't have other characters benefitting from this specific resistancePenetration table.
        Game.Math.ApplyHitResistances = funcOriginal
    else
        HitOverrides.ApplyHitResistances(character, damageList, resistancePenetration, preModifiedDamageList)
        Game.Math.ApplyDamageSkillAbilityBonuses(damageList, attacker)
    end
 
    Events.ApplyDamageCharacterBonuses:Invoke({
        Target = character,
        Attacker = attacker,
        DamageList = damageList,
        PreModifiedDamageList = preModifiedDamageList,
        ResistancePenetration = resistancePenetration
    })
end

--- @param damageList DamageList
--- @param armor integer
function HitOverrides.ComputeArmorDamage(damageList, armor)
    local damage = damageList:GetByType("Corrosive") + damageList:GetByType("Physical") + damageList:GetByType("Sulfuric")
    return math.min(armor, damage)
end

--- @param damageList DamageList
--- @param magicArmor integer
function HitOverrides.ComputeMagicArmorDamage(damageList, magicArmor)
    local damage = damageList:GetByType("Magic") 
        + damageList:GetByType("Fire") 
        + damageList:GetByType("Water")
        + damageList:GetByType("Air")
        + damageList:GetByType("Earth")
        + damageList:GetByType("Poison")
    return math.min(magicArmor, damage)
end
--endregion

--region Resistance Stuff

local function GetResistanceName(damageType)
    if Data.DamageTypeToResistance[damageType] then
        return Data.DamageTypeToResistance[damageType], true
    end
    return Data.DamageTypeToResistanceWithExtras[damageType], false
end

--- @param character StatCharacter
--- @param damageType string DamageType enumeration
--- @param resistancePenetration integer
function HitOverrides.GetResistance(character, damageType, resistancePenetration)
    local res = 0
    local resName,isRealStat = GetResistanceName(damageType)
    if resName and isRealStat then
        res = character[resName] or 0
    end

    --Workaround for PhysicalResistance in StatCharacter being double what it actually is
    if _EXTVERSION <= 55 and damageType == "Physical" then
        local stat = Ext.Stats.Get(character.Name)
        if stat then
            res = stat.PhysicalResistance
        else
            res = 0
        end
        for i=2,#character.DynamicStats do
            local v = character.DynamicStats[i]
            if v and v.PhysicalResistance then
                res = res + v.PhysicalResistance
            end
        end
    end

	if res > 0 and resistancePenetration ~= nil and resistancePenetration > 0 then
		res = math.max(res - resistancePenetration, 0)
	end
    ---@type SubscribableEventInvokeResult<GetHitResistanceBonusEventArgs>
    local invokeResult = Events.GetHitResistanceBonus:Invoke({
        Target = character,
        DamageType = damageType,
        ResistancePenetration = resistancePenetration,
        CurrentResistanceAmount = res,
        ResistanceName = resName,
    })
    if invokeResult.ResultCode ~= "Error" then
        res = invokeResult.Args.CurrentResistanceAmount

        if invokeResult.Results then
            for i=1,#invokeResult.Results do
                local amount = invokeResult.Results[i]
                if type(amount) == "number" then
                    res = res + amount
                end
            end
        end
    end

    return res
end

--- @param character StatCharacter
--- @param damageList DamageList
--- @param resistancePenetration table<string,integer>
function HitOverrides.ApplyHitResistances(character, damageList, resistancePenetration, preModifiedDamageList)
	for i,damage in pairs(preModifiedDamageList) do
        local resistance = HitOverrides.GetResistance(character, damage.DamageType, resistancePenetration[damage.DamageType])
        local modAmount = math.floor(damage.Amount * -resistance / 100.0)
        damageList:Add(damage.DamageType, modAmount)
    end
end

---@param character StatCharacter
---@param attacker StatCharacter
---@return table<string,integer>
function HitOverrides.GetResistancePenetration(character, attacker)
    --- @type table<string,integer>
    local resistancePenetration = {}

    if attacker ~= nil and attacker.Character ~= nil then
        local _cachedTags = GameHelpers.GetAllTags(attacker.Character, true, true)
        for tag,b in pairs(_cachedTags) do
            local damageType,amount = GameHelpers.ParseResistancePenetrationTag(tag)
            if damageType then
                if resistancePenetration[damageType] == nil then
                    resistancePenetration[damageType] = 0
                end
                resistancePenetration[damageType] = resistancePenetration[damageType] + amount
            end
        end
        -- for damageType,tags in pairs(Data.ResistancePenetrationTags) do
        --     for i,tagEntry in pairs(tags) do
        --         if _cachedTags[tagEntry.Tag] then
        --             if resistancePenetration[damageType] == nil then
        --                 resistancePenetration[damageType] = 0
        --             end
        --             resistancePenetration[damageType] = resistancePenetration[damageType] + tagEntry.Amount
        --         end
        --     end
        -- end
        if GameHelpers.CharacterOrEquipmentHasTag(attacker.Character, "LeaderLib_IgnoreUndeadPoisonResistance") and character.TALENT_Zombie then
            if not resistancePenetration["Poison"] then
                resistancePenetration["Poison"] = 0
            end
            resistancePenetration["Poison"] = resistancePenetration["Poison"] + 200
        end
    end
    return resistancePenetration
end
--endregion

--region Backstabbing

function HitOverrides.WithinMeleeDistance(pos1, pos2)
    return GameHelpers.Math.GetDistance(pos1,pos2) <= (GameSettings.Settings.BackstabSettings.MeleeSpellBackstabMaxDistance or 2.5)
end

---@param weapon StatItem
function HitOverrides.CanBackstabWithTwoHandedWeapon(weapon)
    return (GameSettings.Settings.BackstabSettings.AllowTwoHandedWeapons or not weapon.IsTwoHanded)
end

function HitOverrides.BackstabSpellMechanicsEnabled(attacker, hitType)
    local backstabSettings = GameSettings.Settings.BackstabSettings
    local settings = nil
    if attacker.IsPlayer then
        settings = GameSettings.Settings.BackstabSettings.Player
    else
        settings = GameSettings.Settings.BackstabSettings.NPC
    end
    if settings.SpellsCanBackstab then
        return true
    end
    return false
end

--- @param canBackstab boolean
--- @return boolean,boolean
local function GetCanBackstabFinalResult(canBackstab, target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    local skipPositionCheck = false
    ---@type SubscribableEventInvokeResult<GetCanBackstabEventArgs>
    local invokeResult = Events.GetCanBackstab:Invoke({
        CanBackstab = canBackstab,
        SkipPositionCheck = skipPositionCheck,
        Target = target,
        Attacker = attacker,
        Weapon = weapon,
        DamageList = damageList,
        HitType = hitType,
        Hit = hit,
        NoHitRoll = noHitRoll,
        ForceReduceDurability = forceReduceDurability,
        AlwaysBackstab = alwaysBackstab,
        HighGround = highGroundFlag,
        CriticalRoll = criticalRoll,
    })
    if invokeResult.ResultCode ~= "Error" then
        canBackstab = invokeResult.Args.CanBackstab == true
        skipPositionCheck = invokeResult.Args.SkipPositionCheck == true
        if invokeResult.Results then
            for i=1,#invokeResult.Results do
                local result = invokeResult.Results[i]
                local canBackstabResult = nil
                local skipPositionResult = nil
                if type(result) == "table" then
                    canBackstabResult = result[1]
                    skipPositionResult = result[2]
                else
                    canBackstabResult = result[1]
                end
                if type(canBackstabResult) == "boolean" then
                    canBackstab = canBackstabResult
                end
                if type(skipPositionResult) == "boolean" then
                    skipPositionCheck = skipPositionResult
                end
            end
        end
    end
    return canBackstab,skipPositionCheck
end

--- This parses the GameSettings options for backstab settings, allowing both players and NPCs to backstab with other weapons if the condition is right.
--- Lets the Backstab talent work. Also lets ranged weapons backstab if the game settings option MeleeOnly is disabled.
--- @param attacker StatCharacter
--- @param weapon StatItem
--- @param hitType string
--- @param target StatCharacter
function HitOverrides.CanBackstab(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    local canBackstab = false
    if (weapon ~= nil and weapon.WeaponType == "Knife") then
        canBackstab = true
    end

    -- Enemy Upgrade Overhaul - Backstabber Upgrade
    if Ext.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") and not attacker.IsPlayer and weapon ~= nil and (attacker.TALENT_Backstab or attacker.TALENT_RogueLoreDaggerBackStab) then
        canBackstab = true
    end

    if canBackstab ~= true then
        local settings = nil
        if attacker.IsPlayer then
            settings = GameSettings.Settings.BackstabSettings.Player
        else
            settings = GameSettings.Settings.BackstabSettings.NPC
        end
    
        if settings.Enabled then
            if not settings.TalentRequired or (settings.TalentRequired and (attacker.TALENT_Backstab or attacker.TALENT_RogueLoreDaggerBackStab)) then
                if weapon ~= nil then
                    if not settings.MeleeOnly or (settings.MeleeOnly and not Game.Math.IsRangedWeapon(weapon) and HitOverrides.CanBackstabWithTwoHandedWeapon(weapon)) then
                        canBackstab = true
                    end
                elseif settings.SpellsCanBackstab then
                    if settings.MeleeOnly then
                        canBackstab = hitType == "Melee" or HitOverrides.WithinMeleeDistance(attacker.Position, target.Position)
                    else
                        canBackstab = true
                    end
                end
            end
        end
    end

    return GetCanBackstabFinalResult(canBackstab, attacker, weapon, hitType, target)
end

--endregion

--region SpellsCanCrit
--- @param hit HitRequest
--- @param attacker StatCharacter
--- @param hitType string HitType enumeration
--- @param criticalRoll string CriticalRoll enumeration
function HitOverrides.ShouldApplyCriticalHit(hit, attacker, hitType, criticalRoll)
    if criticalRoll ~= "Roll" then
        return criticalRoll == "Critical"
    end

    if attacker.TALENT_Haymaker then
        return false
    end

    if hitType == "DoT" or hitType == "Surface" then
        return false
    end
    
    local critChance = attacker.CriticalChance
    
    if (Features.SpellsCanCrit or attacker.TALENT_ViolentMagic or GameSettings.Settings.SpellsCanCritWithoutTalent) and hitType == "Magic" then
        critChance = critChance * Ext.ExtraData.TalentViolentMagicCriticalChancePercent * 0.01
        critChance = math.max(critChance, 1)
    else
        if GameHelpers.Hit.HasFlag(hit, "Backstab") then
            return true
        end

        if hitType == "Magic" then
            return false
        end
    end

    return math.random(0, 99) < critChance
end

--- @param weapon StatItem
--- @param character StatCharacter
--- @param criticalMultiplier number
--- @return number
function HitOverrides.GetCriticalHitMultiplier(weapon, character, criticalMultiplier)
	criticalMultiplier = criticalMultiplier or 0
    if weapon.ItemType == "Weapon" then
        for i,stat in pairs(weapon.DynamicStats) do
            criticalMultiplier = criticalMultiplier + stat.CriticalDamage
        end
  
        if character ~= nil then
            local ability = Game.Math.GetWeaponAbility(character, weapon)
            criticalMultiplier = criticalMultiplier + Game.Math.GetAbilityCriticalHitMultiplier(character, ability) + Game.Math.GetAbilityCriticalHitMultiplier(character, "RogueLore")
                
            if character.TALENT_Human_Inventive then
                criticalMultiplier = criticalMultiplier + Ext.ExtraData.TalentHumanCriticalMultiplier
            end
        end
    end
  
    return criticalMultiplier * 0.01
end

--- @param hit HitRequest
--- @param attacker StatCharacter
--- @param damageMultiplier number
--- @param criticalMultiplier number
function HitOverrides.ApplyCriticalHit(hit, attacker, damageMultiplier, criticalMultiplier)
    local mainWeapon = attacker.MainWeapon
    if mainWeapon ~= nil then
        GameHelpers.Hit.SetFlag(hit, "CriticalHit", true)
        damageMultiplier = damageMultiplier + (HitOverrides.GetCriticalHitMultiplier(mainWeapon, attacker, criticalMultiplier) - 1.0)
    end
    return damageMultiplier
end

--- @param hit HitRequest
--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param hitType string HitType enumeration
--- @param criticalRoll string CriticalRoll enumeration
--- @param damageMultiplier number
--- @param criticalMultiplier number
function HitOverrides.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll, damageMultiplier, criticalMultiplier)
    if HitOverrides.ShouldApplyCriticalHit(hit, attacker, hitType, criticalRoll) then
        damageMultiplier = HitOverrides.ApplyCriticalHit(hit, attacker, damageMultiplier, criticalMultiplier)
    end
    return damageMultiplier
end
--endregion

function HitOverrides.ComputeOverridesEnabled()
    if Features.DisableHitOverrides == true then
        return false
    end
    return Features.BackstabCalculation == true
    or Features.SpellsCanCrit == true
    or GameSettings.Settings.SpellsCanCritWithoutTalent == true
    or Features.ResistancePenetration == true
    or Events.ComputeCharacterHit.First ~= nil
end

--- @param hit HitRequest
--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param hitType string HitType enumeration
local function ApplyLifeSteal(hit, target, attacker, hitType)
    if attacker == nil or hitType == "DoT" or hitType == "Surface" then
        return
    end

    local magicDmg = hit.DamageList:GetByType("Magic")
    local corrosiveDmg = hit.DamageList:GetByType("Corrosive")
    local lifesteal = hit.TotalDamageDone - hit.ArmorAbsorption - corrosiveDmg - magicDmg

    if hit.FromShacklesOfPain or hit.NoDamageOnOwner or hit.Reflection then
        local modifier = Ext.ExtraData.LifestealFromReflectionModifier
        lifesteal = math.floor(lifesteal * modifier)
    end

    if lifesteal > target.CurrentVitality then
        lifesteal = target.CurrentVitality
    end

    if lifesteal > 0 then
        hit.LifeSteal = math.max(math.ceil(lifesteal * attacker.LifeSteal / 100), 0)
    end
end

---@param hit HitRequest
---@param damageList DamageList
---@param statusBonusDmgTypes string[]
---@param hitType string
---@param target StatCharacter
---@param attacker StatCharacter
---@param damageMultiplier number
local function DoHitUpdated(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    hit.Hit = true
    damageList:AggregateSameTypeDamages()
    damageList:Multiply(damageMultiplier)

    local totalDamage = 0
    for i,damage in pairs(damageList:ToTable()) do
        totalDamage = totalDamage + damage.Amount
    end

    if totalDamage < 0 then
        damageList:Clear()
    end

    HitOverrides.ApplyDamageCharacterBonuses(target, attacker, damageList)
    damageList:AggregateSameTypeDamages()

    hit.DamageList:CopyFrom(Ext.NewDamageList())

    for i,damageType in pairs(statusBonusDmgTypes) do
        damageList.Add(damageType, math.ceil(totalDamage * 0.1))
    end

    Game.Math.ApplyDamagesToHitInfo(damageList, hit)
    
    hit.ArmorAbsorption = hit.ArmorAbsorption + Game.Math.ComputeArmorDamage(damageList, target.CurrentArmor)
    hit.ArmorAbsorption = hit.ArmorAbsorption + Game.Math.ComputeMagicArmorDamage(damageList, target.CurrentMagicArmor)

    if hit.TotalDamageDone > 0 then
        ApplyLifeSteal(hit, target, attacker, hitType)
    else
        hit.DontCreateBloodSurface = true
    end

    if hitType == "Surface" then
        hit.Surface = true
    end

    if hitType == "DoT" then
        hit.DoT = true
    end
end

--- @param hitRequest HitRequest
--- @param damageList DamageList
--- @param statusBonusDmgTypes table
--- @param hitType HitTypeValues HitType enumeration
--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param damageMultiplier number
function HitOverrides.DoHit(hitRequest, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    damageMultiplier = damageMultiplier or 1.0
    if _EXTVERSION < 56 then
        hitRequest.DamageMultiplier = damageMultiplier
        --We're basically calling Game.Math.DoHit here, but it may be a modified version from a mod.
        HitOverrides.DoHitModified(hitRequest, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    else
        --TODO Waiting for a v56 Game.Math update for hit.DamageMultiplier
        DoHitUpdated(hitRequest, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    end
    Events.DoHit:Invoke({
        Hit = hitRequest,
        DamageList = damageList,
        StatusBonusDamageTypes = statusBonusDmgTypes,
        HitType = hitType,
        Target = target,
        Attacker = attacker
    })
	return hitRequest
end

--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param weapon StatItem
--- @param preDamageList DamageList
--- @param hitType HitTypeValues HitType enumeration
--- @param noHitRoll boolean
--- @param forceReduceDurability boolean
--- @param hit HitRequest
--- @param alwaysBackstab boolean
--- @param highGroundFlag HighGroundFlag HighGround enumeration
--- @param criticalRoll CriticalRollFlag CriticalRoll enumeration
--- @return HitRequest hit
local function ComputeCharacterHit(target, attacker, weapon, preDamageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    local damageMultiplier = 1.0
	local criticalMultiplier = 0.0
    local statusBonusDmgTypes = {}

	local damageList = Ext.NewDamageList()
    if _EXTVERSION >= 56 then
	    damageList:CopyFrom(preDamageList)
    else
        damageList:Merge(preDamageList)
    end
    local statusBonusDmgTypes = {}
    local hitBlocked = false

    --Fix: Temp fix for infinite reflection damage via Shackles of Pain + Retribution. This flag isn't being set or something in v56.
    if hitType == "Reflected" then
        GameHelpers.Hit.SetFlag(hit, "Reflection", true)
    end

    if attacker == nil then
        HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
        return hit
    end

    if weapon == nil then
        weapon = attacker.MainWeapon
    end
    
    if hitType == "Magic" and HitOverrides.BackstabSpellMechanicsEnabled(attacker) then
        local canBackstab,skipPositionCheck = HitOverrides.CanBackstab(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
        if alwaysBackstab or (canBackstab and (skipPositionCheck or Game.Math.CanBackstab(target, attacker))) then
            GameHelpers.Hit.SetFlag(hit, "Backstab", true)
        end
    end

    damageMultiplier = 1.0 + Game.Math.GetAttackerDamageMultiplier(attacker, target, highGroundFlag)
    if hitType == "Magic" or hitType == "Surface" or hitType == "DoT" or hitType == "Reflected" then
        damageMultiplier = HitOverrides.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll, damageMultiplier, criticalMultiplier)
        HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
        return hit
    end

    local canBackstab,skipPositionCheck = HitOverrides.CanBackstab(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    if alwaysBackstab or (canBackstab and (skipPositionCheck or Game.Math.CanBackstab(target, attacker))) then
        GameHelpers.Hit.SetFlag(hit, "Backstab", true)
    end

    if hitType == "Melee" then
        if Game.Math.IsInFlankingPosition(target, attacker) then
            GameHelpers.Hit.SetFlag(hit, "Flanking", true)
        end

        -- Apply Sadist talent
        if attacker.TALENT_Sadist then
            if GameHelpers.Hit.HasFlag(hit, "Poisoned") then
                table.insert(statusBonusDmgTypes, "Poison")
            end
            if GameHelpers.Hit.HasFlag(hit, "Burning") then
                table.insert(statusBonusDmgTypes, "Fire")
            end
            if GameHelpers.Hit.HasFlag(hit, "Bleeding") then
                table.insert(statusBonusDmgTypes, "Physical")
            end
        end
    end

    if attacker.TALENT_Damage then
        damageMultiplier = damageMultiplier + 0.1
    end

    if not noHitRoll then
        local hitChance = Game.Math.CalculateHitChance(attacker, target)
        local hitRoll = math.random(0, 99)
        if hitRoll >= hitChance then
            if target.TALENT_RangerLoreEvasionBonus and hitRoll < hitChance + 10 then
                GameHelpers.Hit.SetFlag(hit, "Dodged", true)
            else
                GameHelpers.Hit.SetFlag(hit, "Missed", true)
            end
            hitBlocked = true
        else
            local blockChance = target.BlockChance
            if not GameHelpers.Hit.HasFlag(hit, "Backstab") and blockChance > 0 and math.random(0, 99) < blockChance then
                GameHelpers.Hit.SetFlag(hit, "Blocked", true)
                hitBlocked = true
            end
        end
    end

    if weapon ~= nil and weapon.Name ~= "DefaultWeapon" and hitType ~= "Magic" and forceReduceDurability
    and not GameHelpers.Hit.HasFlag(hit, {"Missed", "Dodged"}) then
        Game.Math.ConditionalDamageItemDurability(attacker, weapon)
    end

    if not hitBlocked then
        damageMultiplier = HitOverrides.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll, damageMultiplier, criticalMultiplier)
        HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    end

    return hit
end

HitOverrides._ComputeCharacterHitFunction = ComputeCharacterHit

-- local _ComputeMeta = {
--     __index = function(_, k)
        
--     end,
--     __newindex = function(_, k, v)
        
--     end
-- }

function HitOverrides.ComputeCharacterHit(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    if HitOverrides.ComputeOverridesEnabled() or Vars.DebugMode then
        ComputeCharacterHit(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
        Events.ComputeCharacterHit:Invoke({
            Target = target,
            Attacker = attacker,
            Weapon = weapon,
            DamageList = damageList,
            HitType = hitType,
            Hit = hit,
            NoHitRoll = noHitRoll,
            ForceReduceDurability = forceReduceDurability,
            AlwaysBackstab = alwaysBackstab,
            HighGround = highGroundFlag,
            CriticalRoll = criticalRoll,
        })
        -- Ext.Dump({Context="ComputeCharacterHit", ["hit.DamageList"]=hit.DamageList:ToTable(), TotalDamageDone=hit.TotalDamageDone, HitType=hitType, ["event.DamageList"]=damageList:ToTable()})
        return hit
    end
end

if _EXTVERSION < 56 then
    Ext.RegisterListener("ComputeCharacterHit", HitOverrides.ComputeCharacterHit)
else
    Ext.Events.ComputeCharacterHit:Subscribe(function(event)
        local hit = HitOverrides.ComputeCharacterHit(event.Target, event.Attacker, event.Weapon, event.DamageList, event.HitType, event.NoHitRoll, event.ForceReduceDurability, event.Hit, event.AlwaysBackstab, event.HighGround, event.CriticalRoll)
        if hit then
            event.Handled = true
            --Ext.IO.SaveFile(string.format("Dumps/CCH_Hit_%s_%s.json", event.HitType, Ext.MonotonicTime()), Ext.DumpExport(event.Hit))
            --Ext.Dump({Context="ComputeCharacterHit", ["hit.DamageList"]=hit.DamageList:ToTable(), TotalDamageDone=hit.TotalDamageDone, HitType=event.HitType, ["event.DamageList"]=event.DamageList:ToTable()})
        end
    end)
end

Ext.Events.SessionLoaded:Subscribe(function()
    -- Set to Game.Math.DoHit here, instead of immediately, in case a mod has overwritten it.
    HitOverrides.DoHitModified = Game.Math.DoHit
    -- True if the original function was changed
    if (Game.Math.ApplyDamageCharacterBonuses ~= HitOverrides.ApplyDamageCharacterBonusesOriginal 
    and Game.Math.ApplyDamageCharacterBonuses ~= HitOverrides.ApplyDamageCharacterBonuses) then
        HitOverrides.ApplyDamageCharacterBonusesModified = Game.Math.ApplyDamageCharacterBonuses
    end
    Game.Math.DoHit = HitOverrides.DoHit
    Game.Math.ApplyDamageCharacterBonuses = HitOverrides.ApplyDamageCharacterBonuses
end)