---@class LeaderLibHitOverrides
HitOverrides = {
    --- The original ositools version
    DoHitOriginal = Game.Math.DoHit,
    DoHitModified = nil, -- We get this in SessionLoaded in a case a mod has overwritten it.
    ApplyDamageCharacterBonusesOriginal = Game.Math.ApplyDamageCharacterBonuses,
    ApplyDamageCharacterBonusesModified = nil,
    GetCriticalHitMultiplierOriginal = Game.Math.GetCriticalHitMultiplier,
    GetCriticalHitMultiplierWasModified = false,
    ListenersRegistered = 0,
    CriticalHitListenersRegistered = 0,
    --- True if `Events.CCH.GetShouldApplyCriticalHit` is subscribed to, as mods may want to modify critical hits for melee basic attacks.
    ShouldOverrideBasicAttackCriticalHit = function ()
        return HitOverrides.CriticalHitListenersRegistered > 0
    end
}


--- This script tweaks Game.Math functions to allow lowering resistance with Resistance Penetration tags on items of the attacker.

local _EXTVERSION = Ext.Utils.Version()

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
 
    Events.CCH.ApplyDamageCharacterBonuses:Invoke({
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

local function _GetResistanceName(damageType)
    if Data.DamageTypeToResistance[damageType] then
        return Data.DamageTypeToResistance[damageType], true
    end
    return Data.DamageTypeToResistanceWithExtras[damageType], false
end

local function _GetResistanceAmount(character, damageType)
    local b,res = pcall(Ext.Stats.Math.GetResistance, character, damageType, false)
    if b and res then
        return res
    end
    return 0
end

--- @param character StatCharacter
--- @param damageType string DamageType enumeration
--- @param resistancePenetration integer
function HitOverrides.GetResistance(character, damageType, resistancePenetration)
    local res = _GetResistanceAmount(character, damageType)
    local resName _GetResistanceName(damageType)
    if not resName then
        resName = string.format("%sResistance", damageType)
    end

    local originalResistance = res

	if res > 0 and resistancePenetration ~= nil and resistancePenetration > 0 then
		res = math.max(res - resistancePenetration, 0)
	end
    ---@type SubscribableEventInvokeResult<GetHitResistanceBonusEventArgs>
    local invokeResult = Events.CCH.GetHitResistanceBonus:Invoke({
        Target = character,
        DamageType = damageType,
        ResistancePenetration = resistancePenetration,
        OriginalResistanceAmount = originalResistance,
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
    if attacker ~= nil and attacker.Character ~= nil then
        local resistancePenetration = GameHelpers.Stats.GetResistancePenetration(attacker)
        if GameHelpers.CharacterOrEquipmentHasTag(attacker.Character, "LeaderLib_IgnoreUndeadPoisonResistance") and character.TALENT_Zombie then
            if not resistancePenetration["Poison"] then
                resistancePenetration["Poison"] = 0
            end
            resistancePenetration["Poison"] = resistancePenetration["Poison"] + 200
        end
        return resistancePenetration
    else
        return {}
    end
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
    local invokeResult = Events.CCH.GetCanBackstab:Invoke({
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

local function _BackstabTalentEnabled(attacker)
    return (Mods.CharacterExpansionLib ~= nil or attacker.TALENT_Backstab or attacker.TALENT_RogueLoreDaggerBackStab)
end

--- This parses the GameSettings options for backstab settings, allowing both players and NPCs to backstab with other weapons if the condition is right.
--- Lets the Backstab talent work. Also lets ranged weapons backstab if the game settings option MeleeOnly is disabled.
--- @param target StatCharacter
--- @param attacker CDivinityStatsCharacter
--- @param weapon CDivinityStatsItem
--- @param hitType HitType
function HitOverrides.CanBackstab(target, attacker, weapon, hitType)
    local canBackstab = false
    if (weapon ~= nil and weapon.WeaponType == "Knife") then
        canBackstab = true
    end

    -- Enemy Upgrade Overhaul - Backstabber Upgrade
    if Ext.Mod.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") and not attacker.IsPlayer and weapon ~= nil and (attacker.TALENT_Backstab or attacker.TALENT_RogueLoreDaggerBackStab) then
        canBackstab = true
    end

    if canBackstab ~= true then
        local settings = nil
        if attacker.IsPlayer then
            settings = GameSettings.Settings.BackstabSettings.Player
        else
            settings = GameSettings.Settings.BackstabSettings.NPC
        end

        local backstabTalentRequired = settings.TalentRequired and _BackstabTalentEnabled(attacker)
    
        if settings.Enabled then
            if not backstabTalentRequired or (attacker.TALENT_Backstab or attacker.TALENT_RogueLoreDaggerBackStab) then
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
--- @param hitType HitType
--- @param criticalRoll CriticalRoll
--- @return boolean success
--- @return integer|nil roll
--- @return integer criticalChance
local function _CalculateShouldApplyCriticalHit(hit, attacker, hitType, criticalRoll)
    local roll = nil
    local critChance = attacker.CriticalChance
    if (Features.SpellsCanCrit or attacker.TALENT_ViolentMagic or GameSettings.Settings.SpellsCanCritWithoutTalent) and hitType == "Magic" then
        if attacker.TALENT_ViolentMagic then
            critChance = math.max(1, critChance * Ext.ExtraData.TalentViolentMagicCriticalChancePercent * 0.01)
        end
    end
    --TODO
    --[[Not technically engine-correct, but on basic attacks, CriticalRoll is already pre-determined,
    which means the backstab text happens without an actual increase in damage]]
    if hit.Backstab then
        return true, roll, critChance
    end
    if criticalRoll ~= "Roll" then
        return criticalRoll == "Critical", roll, critChance
    end

    if attacker.TALENT_Haymaker then
        return false, roll, critChance
    end

    if hitType == "DoT" or hitType == "Surface" then
        return false, roll, critChance
    end
    
    if (Features.SpellsCanCrit or attacker.TALENT_ViolentMagic or GameSettings.Settings.SpellsCanCritWithoutTalent) and hitType == "Magic" then
        --Continue along
    elseif hitType == "Magic" then
        return false, roll, critChance
    end

    roll = math.random(0, 99)
    return roll < critChance, roll, critChance
end

--- @param hit HitRequest
--- @param attacker StatCharacter
--- @param hitType HitType
--- @param criticalRoll CriticalRoll
--- @param isCriticalHit boolean
--- @param roll? integer
--- @param criticalChance integer
--- @param isFromBasicAttack? boolean
local function _InvokeGetShouldApplyCriticalHit(hit, attacker, hitType, criticalRoll, isCriticalHit, roll, criticalChance, isFromBasicAttack)
    ---@type LeaderLibGetShouldApplyCriticalHitEventArgs
    local evt = {
        Attacker = attacker,
        Hit = hit,
        HitType = hitType,
        CriticalRoll = criticalRoll,
        IsCriticalHit = isCriticalHit,
        RollAmount = roll,
        CriticalChance = criticalChance,
        IsFromBasicAttack = isFromBasicAttack == true,
    }
    ---@type SubscribableEventInvokeResult<LeaderLibGetShouldApplyCriticalHitEventArgs>
    local invokeResult = Events.CCH.GetShouldApplyCriticalHit:Invoke(evt)
    if invokeResult.ResultCode ~= "Error" then
        return invokeResult.Args.IsCriticalHit == true
    end
    return isCriticalHit
end

--- @param hit HitRequest
--- @param attacker StatCharacter
--- @param hitType HitType
--- @param criticalRoll CriticalRoll
--- @param isFromBasicAttack? boolean
--- @return boolean
function HitOverrides.ShouldApplyCriticalHit(hit, attacker, hitType, criticalRoll, isFromBasicAttack)
    local isCriticalHit,roll,criticalChance = _CalculateShouldApplyCriticalHit(hit, attacker, hitType, criticalRoll)
    return _InvokeGetShouldApplyCriticalHit(hit, attacker, hitType, criticalRoll, isCriticalHit, roll, criticalChance, isFromBasicAttack)
end

--- @param weapon StatItem
--- @param character StatCharacter
--- @param criticalMultiplier number
--- @return number
local function _InvokeGetCriticalHitMultiplier(weapon, character, criticalMultiplier)
    ---@type SubscribableEventInvokeResult<LeaderLibGetCriticalHitMultiplierEventArgs>
    local invokeResult = Events.CCH.GetCriticalHitMultiplier:Invoke({
        Attacker = character,
        Weapon = weapon,
        CriticalMultiplier = criticalMultiplier
    })
    if invokeResult.ResultCode ~= "Error" and type(invokeResult.Args.CriticalMultiplier) == "number" then
        return invokeResult.Args.CriticalMultiplier
    end
    return criticalMultiplier
end

--- @param weapon StatItem
--- @param character StatCharacter
--- @param criticalMultiplier number
--- @return number
function HitOverrides.GetCriticalHitMultiplier(weapon, character, criticalMultiplier)
	criticalMultiplier = criticalMultiplier or 0

    if weapon.ItemType == "Weapon" then
        for i,stat in pairs(weapon.DynamicStats) do
            ---@cast stat CDivinityStatsEquipmentAttributesWeapon
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
    local result = criticalMultiplier * 0.01

    if HitOverrides.GetCriticalHitMultiplierWasModified then
        local baseMult = Game.Math.GetCriticalHitMultiplier(weapon, character, criticalMultiplier)
        if baseMult > result then
            result = baseMult
        end
    end
    return _InvokeGetCriticalHitMultiplier(weapon, character, result)
end

--- @param hit HitRequest
--- @param attacker StatCharacter
--- @param damageMultiplier number
--- @param criticalMultiplier number
function HitOverrides.ApplyCriticalHit(hit, attacker, damageMultiplier, criticalMultiplier)
    local mainWeapon = attacker.MainWeapon
    if mainWeapon ~= nil then
        hit.CriticalHit = true
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
--- @param isFromBasicAttack? boolean
function HitOverrides.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll, damageMultiplier, criticalMultiplier, isFromBasicAttack)
    if HitOverrides.ShouldApplyCriticalHit(hit, attacker, hitType, criticalRoll, isFromBasicAttack) then
        damageMultiplier = HitOverrides.ApplyCriticalHit(hit, attacker, damageMultiplier, criticalMultiplier)
    end
    return damageMultiplier
end
--endregion

function HitOverrides.ComputeOverridesEnabled()
    if Features.DisableHitOverrides == true then
        return false
    end
    -- Any mod is subscribed to a LeaderLib ComputeCharacterHit-related event
    if HitOverrides.ListenersRegistered > 0 then
        return true
    end
    return Features.BackstabCalculation == true
    or Features.SpellsCanCrit == true
    or GameSettings.Settings.SpellsCanCritWithoutTalent == true
    or (GameSettings.Settings.BackstabSettings.Player.Enabled or GameSettings.Settings.BackstabSettings.NPC.Enabled)
    or Features.ResistancePenetration == true
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

---@param hit StatsHitDamageInfo
---@return boolean
local function _HitFailed(hit)
    if hit.Dodged or hit.Blocked or hit.Missed then
       return true
    elseif hit.Hit == false and ((hit.EffectFlags & 0x100 ) ~= 0) then
        return true
    end
    return false
end

---@param hit HitRequest
---@param damageList DamageList
---@param statusBonusDmgTypes string[]
---@param hitType string
---@param target StatCharacter
---@param attacker StatCharacter
---@param damageMultiplier number
local function DoHitUpdated(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    --Fixes hits still hitting if a mod has changed one of these flags
    hit.Hit = not _HitFailed(hit)
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

    hit.DamageList:CopyFrom(Ext.Stats.NewDamageList())

    for i,damageType in pairs(statusBonusDmgTypes) do
        damageList:Add(damageType, math.ceil(totalDamage * 0.1))
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

--- @param hitRequest StatsHitDamageInfo
--- @param damageList DamageList
--- @param statusBonusDmgTypes table
--- @param hitType HitTypeValues HitType enumeration
--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param ctxOrNumber number|{DamageMultiplier:number}
function HitOverrides.DoHit(hitRequest, damageList, statusBonusDmgTypes, hitType, target, attacker, ctxOrNumber)
    local damageMultiplier = 1.0
    local t = type(ctxOrNumber)
    if t == "table" then
        --Mods expecting the newer table arg
        damageMultiplier = ctxOrNumber.DamageMultiplier or 1.0
    elseif t == "number" then
        ---@cast ctxOrNumber number
        damageMultiplier = ctxOrNumber
    end
    DoHitUpdated(hitRequest, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    Events.CCH.DoHit:Invoke({
        Hit = hitRequest,
        DamageList = damageList,
        StatusBonusDamageTypes = statusBonusDmgTypes,
        HitType = hitType,
        Target = target,
        Attacker = attacker,
        DamageMultiplier = damageMultiplier
    })
	return hitRequest
end

--- @param attacker StatCharacter
--- @param target StatCharacter
local function _CalculateHitChance(attacker, target)
    local evt = GameHelpers.Ext.CreateEventTable("GetHitChance", {
        Attacker = attacker,
        Target = target,
        HitChance = 0
    })
    local chance = 0

    if attacker.TALENT_Haymaker then
        chance = 100
    else
        local ranged = Game.Math.IsRangedWeapon(attacker.MainWeapon)
        local accuracy = attacker.Accuracy
        local dodge = 0
        if (not attacker.Invisible or ranged) and target.IsIncapacitatedRefCount == 0 then
            dodge = target.Dodge
        end

        local chanceToHit1 = Ext.Utils.Round(((100.0 - dodge) * accuracy) / 100)
        chanceToHit1 = math.max(0, math.min(100, chanceToHit1))
        chance = chanceToHit1 + attacker.ChanceToHitBoost
    end

    evt.HitChance = chance
    Ext.Events.GetHitChance:Throw(evt)
    if type(evt.HitChance) == "number" then
        return evt.HitChance
    else
        return 0
    end
end

local function _HitEnd(target, attacker, weapon, hitType, forceReduceDurability, hit, criticalRoll, hitBlocked, damageList, damageMultiplier,criticalMultiplier, statusBonusDmgTypes, isFromBasicAttack)
    if weapon ~= nil and weapon.Name ~= "DefaultWeapon" and hitType ~= "Magic" and forceReduceDurability and not (hit.Missed or hit.Dodged) then
        Game.Math.ConditionalDamageItemDurability(attacker, weapon)
    end

    if not hitBlocked then
        damageMultiplier = HitOverrides.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll, damageMultiplier, criticalMultiplier, isFromBasicAttack)
        HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    end

    return hit
end

---@param attacker EsvCharacter
---@return EsvASAttack|nil
local function _GetASAttack(attacker)
	for _,layer in pairs(attacker.ActionMachine.Layers) do
		if layer.State and layer.State.Type == "Attack" then
			return layer.State
		end
	end
	return nil
end

--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param weapon CDivinityStatsItem
--- @param preDamageList DamageList
--- @param hitType HitTypeValues
--- @param noHitRoll boolean
--- @param forceReduceDurability boolean
--- @param hit StatsHitDamageInfo
--- @param alwaysBackstab boolean
--- @param highGroundFlag HighGroundBonus
--- @param criticalRoll CriticalRoll
--- @return StatsHitDamageInfo hit
local function ComputeCharacterHit(target, attacker, weapon, preDamageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    local hitBlocked = _HitFailed(hit)

    local damageMultiplier = 1.0
	local criticalMultiplier = 0.0
    local statusBonusDmgTypes = {}

	local damageList = Ext.Stats.NewDamageList()
    damageList:CopyFrom(preDamageList)
    
    --Fix: Temp fix for infinite reflection damage via Shackles of Pain + Retribution. This flag isn't being set or something in v56.
    if hitType == "Reflected" then
        hit.Reflection = true
    end
    
    if attacker == nil then
        if not hitBlocked then
            HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
        end
        return hit
    end
    
    local isFromBasicAttack = false
    if weapon ~= nil and (hitType == "Melee" or hitType == "Ranged") then
        --EsvASAttack sets CriticalRoll for melee attacks
        if not hit.CriticalHit and criticalRoll ~= "Roll" and HitOverrides.ShouldOverrideBasicAttackCriticalHit() then
            criticalRoll = "Roll"
        end
        if attacker.Character then
            local state = _GetASAttack(attacker.Character)
            if state and not state.IsFinished then
                isFromBasicAttack = true
            end
        end
    end

    if weapon == nil then
        weapon = attacker.MainWeapon
    end
    
    if hitType == "Magic" and HitOverrides.BackstabSpellMechanicsEnabled(attacker) then
        local canBackstab,skipPositionCheck = HitOverrides.CanBackstab(target, attacker, weapon, hitType)
        if alwaysBackstab or (canBackstab and (skipPositionCheck or Game.Math.CanBackstab(target, attacker))) then
            hit.Backstab = true
        end
    end

    damageMultiplier = 1.0 + Game.Math.GetAttackerDamageMultiplier(attacker, target, highGroundFlag)
    if hitType == "Magic" or hitType == "Surface" or hitType == "DoT" or hitType == "Reflected" then
        damageMultiplier = HitOverrides.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll, damageMultiplier, criticalMultiplier, isFromBasicAttack)
        if hitBlocked then
			return _HitEnd(target, attacker, weapon, hitType, forceReduceDurability, hit, criticalRoll, hitBlocked, damageList, damageMultiplier, criticalMultiplier, statusBonusDmgTypes, isFromBasicAttack)
		end
        HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
        return hit
    end

    local canBackstab,skipPositionCheck = HitOverrides.CanBackstab(target, attacker, weapon, hitType)
    if alwaysBackstab or (canBackstab and (skipPositionCheck or Game.Math.CanBackstab(target, attacker))) then
        hit.Backstab = true
    end

    --Oversight fix - Many melee skills have data "UseCharacterStats" "No", so the hitType ends up being "WeaponDamage".
    if hitType == "Melee" or (hitType == "WeaponDamage" and not Game.Math.IsRangedWeapon(weapon) and hit.HitWithWeapon) then
        if Game.Math.IsInFlankingPosition(target, attacker) then
           hit.Flanking = true
        end

        -- Apply Sadist talent
        if attacker.TALENT_Sadist then
            if hit.Poisoned then
                table.insert(statusBonusDmgTypes, "Poison")
            end
            if hit.Burning then
                table.insert(statusBonusDmgTypes, "Fire")
            end
            if hit.Bleeding then
                table.insert(statusBonusDmgTypes, "Physical")
            end
        end
    end

    if attacker.TALENT_Damage then
        damageMultiplier = damageMultiplier + 0.1
    end

    if not hitBlocked and not noHitRoll then
        local hitChance = _CalculateHitChance(attacker, target)
        local hitRoll = Ext.Utils.Random(0, 99)
        if hitRoll >= hitChance then
            if target.TALENT_RangerLoreEvasionBonus and hitRoll < hitChance + 10 then
                hit.Dodged = true
            else
                hit.Missed = true
            end
            hitBlocked = true
        else
            local blockChance = target.BlockChance
            if not hit.Backstab and blockChance > 0 and Ext.Utils.Random(0, 99) < blockChance then
                hit.Blocked = true
                hitBlocked = true
            end
        end
    end

    return _HitEnd(target, attacker, weapon, hitType, forceReduceDurability, hit, criticalRoll, hitBlocked, damageList, damageMultiplier, criticalMultiplier, statusBonusDmgTypes, isFromBasicAttack)
end

HitOverrides._ComputeCharacterHitFunction = ComputeCharacterHit

-- local _ComputeMeta = {
--     __index = function(_, k)
        
--     end,
--     __newindex = function(_, k, v)
        
--     end
-- }

--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param weapon CDivinityStatsItem
--- @param damageList DamageList
--- @param hitType HitTypeValues
--- @param noHitRoll boolean
--- @param forceReduceDurability boolean
--- @param hit StatsHitDamageInfo
--- @param alwaysBackstab boolean
--- @param highGroundFlag HighGroundBonus
--- @param criticalRoll CriticalRoll
--- @return StatsHitDamageInfo|nil
function HitOverrides.ComputeCharacterHit(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    if HitOverrides.ComputeOverridesEnabled() then
        ComputeCharacterHit(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
        Events.CCH.ComputeCharacterHit:Invoke({
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
        return hit
    end
end

Ext.Events.ComputeCharacterHit:Subscribe(function(e)
    local hit = HitOverrides.ComputeCharacterHit(e.Target, e.Attacker, e.Weapon, e.DamageList, e.HitType, e.NoHitRoll, e.ForceReduceDurability, e.Hit, e.AlwaysBackstab, e.HighGround, e.CriticalRoll)
    if hit then
        --Fixes hits still hitting if a mod has changed one of these flags
        if _HitFailed(hit) then
            hit.Hit = false
            if hit.Blocked or ((hit.EffectFlags & 0x100 ) ~= 0) then
                hit.DamageList:Clear()
                hit.TotalDamageDone = 0
                hit.DamageDealt = 0
                hit.LifeSteal = 0
                hit.ArmorAbsorption = 0
            end
        end
        e.Handled = true
    end
end, {Priority=101})

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
    HitOverrides.GetCriticalHitMultiplierWasModified = Game.Math.GetCriticalHitMultiplier ~= HitOverrides.GetCriticalHitMultiplierOriginal
end, {Priority=0})