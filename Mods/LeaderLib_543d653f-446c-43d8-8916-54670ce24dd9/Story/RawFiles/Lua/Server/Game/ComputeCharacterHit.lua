HitOverrides = {
    --- The original ositools version
    DoHitOriginal = Game.Math.DoHit,
    DoHitModified = nil, -- We get this in SessionLoaded in a case a mod has overwritten it.
    ApplyDamageCharacterBonusesOriginal = Game.Math.ApplyDamageCharacterBonuses,
    ApplyDamageCharacterBonusesModified = nil
}
--- This script tweaks Game.Math functions to allow lowering resistance with Resistance Penetration tags on items of the attacker.

local extVersion = Ext.Version()
local HitFlag = Game.Math.HitFlag

--region Game.Math functions

--- @param character StatCharacter
--- @param attacker StatCharacter
--- @param damageList DamageList
function HitOverrides.ApplyDamageCharacterBonuses(character, attacker, damageList)
    local preModifiedDamageList = damageList:ToTable()
    local resistancePenetration = HitOverrides.GetResistancePenetration(character, attacker)

    if HitOverrides.ApplyDamageCharacterBonusesModified ~= nil then
        -- Since a mod has overwritten ApplyDamageCharacterBonuses, let's swap out Game.Math.ApplyHitResistances for HitOverrides.ApplyDamageSkillAbilityBonuses
        -- The reason we're not overriding this in the first place is that Game.Math.ApplyHitResistances doesn't have a reference to the attacker character.
        local funcOriginal = Game.Math.ApplyHitResistances
        Game.Math.ApplyHitResistances = function(c, d)
            HitOverrides.ApplyHitResistances(c, d, resistancePenetration)
        end
        HitOverrides.ApplyDamageCharacterBonusesModified(character, attacker, damageList)
        -- Reset it back so we don't have other characters benefitting from this specific resistancePenetration table.
        Game.Math.ApplyHitResistances = funcOriginal
    else
        damageList:AggregateSameTypeDamages()
        HitOverrides.ApplyHitResistances(character, damageList, resistancePenetration)
        Game.Math.ApplyDamageSkillAbilityBonuses(damageList, attacker)
    end
 
    InvokeListenerCallbacks(Listeners.ApplyDamageCharacterBonuses, character, attacker, damageList, preModifiedDamageList, resistancePenetration)
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
        return Data.DamageTypeToResistance[damageType]
    end
    return damageType .. "Resistance"
end

--- @param character StatCharacter
--- @param damageType string DamageType enumeration
--- @param resistancePenetration integer
function HitOverrides.GetResistance(character, damageType, resistancePenetration)
	local res = character[GetResistanceName(damageType)] or 0

    --Workaround for PhysicalResistance in StatCharacter being double what it actually is
    if extVersion <= 55 and damageType == "Physical" then
        local stat = Ext.GetStat(character.Name)
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
    local length = #Listeners.GetHitResistanceBonus
    if length > 0 then
        for i=1,length do
            local callback = Listeners.GetHitResistanceBonus[i]
            local b,bonus = xpcall(callback, debug.traceback, character, damageType, resistancePenetration, res)
            if b then
                if bonus ~= nil and type(bonus) == "number" then
                    res = res + bonus
                end
            else
                Ext.PrintError(bonus)
            end
        end
    end

    return res
end

--- @param character StatCharacter
--- @param damageList DamageList
--- @param resistancePenetration table<string,integer>
function HitOverrides.ApplyHitResistances(character, damageList, resistancePenetration)
	for i,damage in pairs(damageList:ToTable()) do
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
        for damageType,tags in pairs(Data.ResistancePenetrationTags) do
            for i,tagEntry in pairs(tags) do
                if GameHelpers.CharacterOrEquipmentHasTag(attacker.Character, tagEntry.Tag) then
                    if resistancePenetration[damageType] == nil then
                        resistancePenetration[damageType] = 0
                    end
                    resistancePenetration[damageType] = resistancePenetration[damageType] + tagEntry.Amount
                end
            end
        end
        
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
    local length = #Listeners.GetCanBackstab
    if length > 0 then
        for i=1,length do
            local callback = Listeners.GetCanBackstab[i]
            local b,result,skipPositionResult = xpcall(callback, debug.traceback, canBackstab, target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
            if b then
                if type(result) == "boolean" then
                    canBackstab = result
                end
                if type(skipPositionResult) == "boolean" then
                    skipPositionCheck = skipPositionResult
                end
            else
                Ext.PrintError(result)
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
    if (weapon ~= nil and weapon.WeaponType == "Knife") then
        return GetCanBackstabFinalResult(true, target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    end

    -- Enemy Upgrade Overhaul - Backstabber Upgrade
    if Ext.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") and not attacker.IsPlayer and weapon ~= nil and (attacker.TALENT_Backstab or attacker.TALENT_RogueLoreDaggerBackStab) then
        return GetCanBackstabFinalResult(true, target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    end

    local backstabSettings = GameSettings.Settings.BackstabSettings
    local settings = nil
    if attacker.IsPlayer then
        settings = GameSettings.Settings.BackstabSettings.Player
    else
        settings = GameSettings.Settings.BackstabSettings.NPC
    end

    if settings.Enabled then
        if not settings.TalentRequired or (settings.TalentRequired and (attacker.TALENT_Backstab or attacker.TALENT_RogueLoreDaggerBackStab)) then
            if weapon ~= nil then
                return not settings.MeleeOnly or (settings.MeleeOnly and not Game.Math.IsRangedWeapon(weapon) and HitOverrides.CanBackstabWithTwoHandedWeapon(weapon))
            elseif settings.SpellsCanBackstab then
                if settings.MeleeOnly then
                    return GetCanBackstabFinalResult(hitType == "Melee" or HitOverrides.WithinMeleeDistance(attacker.Position, target.Position), target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
                else
                    return GetCanBackstabFinalResult(true, target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
                end
            end
        end
    end
    return GetCanBackstabFinalResult(false, attacker, weapon, hitType, target)
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

--- @param hit HitRequest
--- @param attacker StatCharacter
--- @param damageMultiplier number
function HitOverrides.ApplyCriticalHit(hit, attacker, damageMultiplier)
    local mainWeapon = attacker.MainWeapon
    if mainWeapon ~= nil then
        GameHelpers.Hit.SetFlag(hit, "CriticalHit", true)
        damageMultiplier = damageMultiplier + (Game.Math.GetCriticalHitMultiplier(mainWeapon, attacker, 0, 0) - 1.0)
    end
    return damageMultiplier
end

--- @param hit HitRequest
--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param hitType string HitType enumeration
--- @param criticalRoll string CriticalRoll enumeration
--- @param damageMultiplier number
function HitOverrides.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll, damageMultiplier)
    if Features.SpellsCanCrit or GameSettings.Settings.SpellsCanCritWithoutTalent then
        if HitOverrides.ShouldApplyCriticalHit(hit, attacker, hitType, criticalRoll) then
            damageMultiplier = HitOverrides.ApplyCriticalHit(hit, attacker, damageMultiplier)
        end
    else
        damageMultiplier = damageMultiplier or Game.Math.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll, damageMultiplier)
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
    or #Listeners.ComputeCharacterHit > 0
end

--- @param hitRequest HitRequest
--- @param damageList DamageList
--- @param statusBonusDmgTypes DamageList
--- @param hitType string HitType enumeration
--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param damageMultiplier number
function HitOverrides.DoHit(hitRequest, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    local hit = hitRequest
    if extVersion < 56 then
        hit.DamageMultiplier = damageMultiplier
    else
        --TODO Waiting for a v56 Game.Math update for hit.DamageMultiplier
        local hitTable = {
            DamageMultiplier = damageMultiplier
        }
        setmetatable(hitTable, {__index = hitRequest})
        hit = hitTable
    end
    -- We're basically calling Game.Math.DoHit here, but it may be a modified version from a mod.
    HitOverrides.DoHitModified(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    InvokeListenerCallbacks(Listeners.DoHit, hit, damageList, statusBonusDmgTypes, hitType, target, attacker)
	return hitRequest
end

--- @param target StatCharacter
--- @param attacker StatCharacter
--- @param weapon StatItem
--- @param damageList DamageList
--- @param hitType string HitType enumeration
--- @param noHitRoll boolean
--- @param forceReduceDurability boolean
--- @param hit HitRequest
--- @param alwaysBackstab boolean
--- @param highGroundFlag HighGroundFlag HighGround enumeration
--- @param criticalRoll CriticalRollFlag CriticalRoll enumeration
local function ComputeCharacterHit(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    --Ext.Dump({Before={hit=hit, weapon=weapon.Name, damageList=damageList:ToTable(), hitType=hitType, noHitRoll=noHitRoll,  forceReduceDurability=forceReduceDurability, alwaysBackstab=alwaysBackstab, highGroundFlag=highGroundFlag, criticalRoll=criticalRoll}}, true, true)
    local damageMultiplier = 1.0
    --Declare locals here so goto works
    local statusBonusDmgTypes = {}
    local backstabbed = false
    local hitBlocked = false

    if attacker == nil then
        HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker)
        return hit
    end

    if weapon == nil then
        weapon = attacker.MainWeapon
    end

    if hitType == "Magic" and HitOverrides.BackstabSpellMechanicsEnabled(attacker) then
        local canBackstab,skipPositionCheck = HitOverrides.CanBackstab(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
        if alwaysBackstab or (canBackstab and (skipPositionCheck or Game.Math.CanBackstab(target, attacker))) then
            GameHelpers.Hit.SetFlag(hit, "Backstab", true)
            backstabbed = true
        end
    end

    damageMultiplier = 1.0 + Game.Math.GetAttackerDamageMultiplier(target, attacker, highGroundFlag)
    if hitType == "Magic" or hitType == "Surface" or hitType == "DoT" or hitType == "Reflected" then
        damageMultiplier = HitOverrides.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll, damageMultiplier)
        HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
        return hit
    end

    if alwaysBackstab or (HitOverrides.CanBackstab(target, attacker, weapon, hitType, target) and Game.Math.CanBackstab(target, attacker)) then
        GameHelpers.Hit.SetFlag(hit, "Backstab", true)
        backstabbed = true
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
            if GameHelpers.Hit.HasFlag(hit, "Burning") ~= 0 then
                table.insert(statusBonusDmgTypes, "Fire")
            end
            if GameHelpers.Hit.HasFlag(hit, "Bleeding") ~= 0 then
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
            if not backstabbed and blockChance > 0 and math.random(0, 99) < blockChance then
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
        damageMultiplier = HitOverrides.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll, damageMultiplier)
        HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker, damageMultiplier)
    end

    return hit
end


function HitOverrides.ComputeCharacterHit(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    if HitOverrides.ComputeOverridesEnabled() then
        hit = ComputeCharacterHit(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
        InvokeListenerCallbacks(Listeners.ComputeCharacterHit, target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
        return hit
    end
end

if extVersion < 56 then
    Ext.RegisterListener("ComputeCharacterHit", HitOverrides.ComputeCharacterHit)
else
    Ext.Events.ComputeCharacterHit:Subscribe(function(event)
        local hit = HitOverrides.ComputeCharacterHit(event.Target, event.Attacker, event.Weapon, event.DamageList, event.HitType, event.NoHitRoll, event.ForceReduceDurability, event.Hit, event.AlwaysBackstab, event.HighGround, event.CriticalRoll)
        if hit then
            return hit
        end
    end)
end

Ext.RegisterListener("SessionLoaded", function()
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