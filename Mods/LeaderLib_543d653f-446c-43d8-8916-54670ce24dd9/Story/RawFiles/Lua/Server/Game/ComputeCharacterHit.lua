HitOverrides = {
    --- The original ositools version
    DoHitOriginal = Game.Math.DoHit,
    DoHitModified = nil, -- We get this in SessionLoaded in a case a mod has overwritten it.
    ApplyDamageCharacterBonusesOriginal = Game.Math.ApplyDamageCharacterBonuses,
    ApplyDamageCharacterBonusesModified = nil
}
--- This script tweaks Game.Math functions to allow lowering resistance with Resistance Penetration tags on items of the attacker.

--- @param character StatCharacter
--- @param type string DamageType enumeration
--- @param type resistancePenetration integer
function HitOverrides.GetResistance(character, type, resistancePenetration)
    if type == "None" or type == "Chaos" then
        return 0
	end
	
	local res = character[type .. "Resistance"]
	if res > 0 and resistancePenetration ~= nil and resistancePenetration > 0 then
		--PrintDebug(res, " => ", math.max(res - resistancePenetration, 0))
		res = math.max(res - resistancePenetration, 0)
	end

    return res
end

--- @param character StatCharacter
--- @param damageList DamageList
--- @param resistancePenetration table<string,integer>
function HitOverrides.ApplyHitResistances(character, damageList, resistancePenetration)
	for i,damage in pairs(damageList:ToTable()) do
        local resistance = HitOverrides.GetResistance(character, damage.DamageType, resistancePenetration[damage.DamageType])
        damageList:Add(damage.DamageType, math.floor(damage.Amount * -resistance / 100.0))
    end
end

---@param character StatCharacter
---@param attacker StatCharacter
---@return table<string,integer>
function HitOverrides.GetResistancePenetration(character, attacker)
    --- @type table<string,integer>
    local resistancePenetration = {}
        
    if attacker ~= nil and attacker.Character ~= nil then
        ---@type EsvItem[]
        local resPenItems = {}
        for i,itemId in pairs(attacker.Character:GetInventoryItems()) do
            ---@type EsvItem
            local item = Ext.GetItem(itemId)
            --print(i, item.Slot, item.StatsId)
            if item.Slot < 15 and item:HasTag("LeaderLib_HasResistancePenetration") then
                resPenItems[#resPenItems+1] = item
            elseif item.Slot >= 15 then
                break
            end
        end
        if #resPenItems > 0 then
            for i,item in pairs(resPenItems) do
                for damageType,tags in pairs(Data.ResistancePenetrationTags) do
                    for i,tagEntry in pairs(tags) do
                        if item:HasTag(tagEntry.Tag) then
                            if resistancePenetration[damageType] == nil then
                                resistancePenetration[damageType] = 0
                            end
                            resistancePenetration[damageType] = resistancePenetration[damageType] + tagEntry.Amount
                        end
                    end
                end
            end
        end
        
        if attacker.Character:HasTag("LeaderLib_IgnoreUndeadPoisonResistance") and character.TALENT_Zombie then
            resistancePenetration["Poison"] = 200
        end
    end
    return resistancePenetration
end

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
 
    local length = #Listeners.ApplyDamageCharacterBonuses
    if length > 0 then
        for i=1,length do
            local callback = Listeners.ApplyDamageCharacterBonuses[i]
            local b,err = xpcall(callback, debug.traceback, character, attacker, damageList, preModifiedDamageList, resistancePenetration)
            if not b then
                Ext.PrintError("[LeaderLib] Error calling function for 'ApplyDamageCharacterBonuses':\n", err)
            end
        end
    end
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

function HitOverrides.ComputeOverridesEnabled()
    return Features.DisableHitOverrides ~= true and (
        (Features.BackstabCalculation == true or Features.ResistancePenetration == true) 
            or #Listeners.ComputeCharacterHit > 0)
end

function HitOverrides.WithinMeleeDistance(pos1, pos2)
    --print(GameSettings.Settings.BackstabSettings.MeleeSpellBackstabMaxDistance, GameHelpers.Math.GetDistance(pos1,pos2))
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

--- This parses the GameSettings options for backstab settings, allowing both players and NPCs to backstab with other weapons if the condition is right.
--- Lets the Backstab talent work. Also lets ranged weapons backstab if the game settings option MeleeOnly is disabled.
--- @param attacker StatCharacter
--- @param weapon StatItem
--- @param hitType string
function HitOverrides.CanBackstab(attacker, weapon, hitType, target)
    if (weapon ~= nil and weapon.WeaponType == "Knife") then
        return true
    end

    -- Enemy Upgrade Overhaul - Backstabber Upgrade
    if Ext.IsModLoaded("046aafd8-ba66-4b37-adfb-519c1a5d04d7") and not attacker.IsPlayer and weapon ~= nil and (attacker.TALENT_Backstab or attacker.TALENT_RogueLoreDaggerBackStab) then
        return true
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
                    return hitType == "Melee" or HitOverrides.WithinMeleeDistance(attacker.Position, target.Position)
                else
                    return true
                end
            end
        end
    end
    return false
end

--- @param hit HitRequest
--- @param damageList DamageList
--- @param statusBonusDmgTypes DamageList
--- @param hitType string HitType enumeration
--- @param target StatCharacter
--- @param attacker StatCharacter
function HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker)
    -- We're basically calling Game.Math.DoHit here, but it may be a modified version from a mod.
    HitOverrides.DoHitModified(hit, damageList, statusBonusDmgTypes, hitType, target, attacker)
    local length = #Listeners.DoHit
    if length > 0 then
        for i=1,length do
            local callback = Listeners.DoHit[i]
            local b,err = xpcall(callback, debug.traceback, hit, damageList, statusBonusDmgTypes, hitType, target, attacker)
            if not b then
                Ext.PrintError("[LeaderLib] Error calling function for 'DoHit':\n", err)
            end
        end
    end
	
	return hit
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
--- @param highGroundFlag string HighGround enumeration
--- @param criticalRoll string CriticalRoll enumeration
function HitOverrides.ComputeCharacterHit(target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
    if HitOverrides.ComputeOverridesEnabled() then
        hit.DamageMultiplier = 1.0
        local statusBonusDmgTypes = {}
        
        if attacker == nil then
            HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker)
            goto hit_done
        end

        local backstabbed = false
        if weapon == nil then
            weapon = attacker.MainWeapon
        end
        
        if hitType == "Magic" and HitOverrides.BackstabSpellMechanicsEnabled(attacker) then
            if alwaysBackstab or (HitOverrides.CanBackstab(attacker, weapon, hitType, target) and Game.Math.CanBackstab(target, attacker)) then
                hit.EffectFlags = hit.EffectFlags | Game.Math.HitFlag.Backstab
                backstabbed = true
            end
        end

        hit.DamageMultiplier = 1.0 + Game.Math.GetAttackerDamageMultiplier(target, attacker, highGroundFlag)
        if hitType == "Magic" or hitType == "Surface" or hitType == "DoT" or hitType == "Reflected" then
            Game.Math.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll)
            HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker)
            goto hit_done
        end

        if alwaysBackstab or (HitOverrides.CanBackstab(attacker, weapon, hitType, target) and Game.Math.CanBackstab(target, attacker)) then
            hit.EffectFlags = hit.EffectFlags | Game.Math.HitFlag.Backstab
            backstabbed = true
        end

        if hitType == "Melee" then
            if Game.Math.IsInFlankingPosition(target, attacker) then
                hit.EffectFlags = hit.EffectFlags | Game.Math.HitFlag.Flanking
            end
        
            -- Apply Sadist talent
            if attacker.TALENT_Sadist then
                if (hit.EffectFlags & Game.Math.HitFlag.Poisoned) ~= 0 then
                    table.insert(statusBonusDmgTypes, "Poison")
                end
                if (hit.EffectFlags & Game.Math.HitFlag.Burning) ~= 0 then
                    table.insert(statusBonusDmgTypes, "Fire")
                end
                if (hit.EffectFlags & Game.Math.HitFlag.Bleeding) ~= 0 then
                    table.insert(statusBonusDmgTypes, "Physical")
                end
            end
        end

        if attacker.TALENT_Damage then
            hit.DamageMultiplier = hit.DamageMultiplier + 0.1
        end

        local hitBlocked = false

        if not noHitRoll then
            local hitChance = Game.Math.CalculateHitChance(attacker, target)
            local hitRoll = math.random(0, 99)
            if hitRoll >= hitChance then
                if target.TALENT_RangerLoreEvasionBonus and hitRoll < hitChance + 10 then
                    hit.EffectFlags = hit.EffectFlags | Game.Math.HitFlag.Dodged
                else
                    hit.EffectFlags = hit.EffectFlags | Game.Math.HitFlag.Missed
                end
                hitBlocked = true
            else
                local blockChance = target.BlockChance
                if not backstabbed and blockChance > 0 and math.random(0, 99) < blockChance then
                    hit.EffectFlags = hit.EffectFlags | Game.Math.HitFlag.Blocked;
                    hitBlocked = true
                end
            end
        end

        if weapon ~= nil and weapon.Name ~= "DefaultWeapon" and hitType ~= "Magic" and forceReduceDurability and (hit.EffectFlags & (Game.Math.HitFlag.Missed|Game.Math.HitFlag.Dodged)) == 0 then
            Game.Math.ConditionalDamageItemDurability(attacker, weapon)
        end

        if not hitBlocked then
            Game.Math.ConditionalApplyCriticalHitMultiplier(hit, target, attacker, hitType, criticalRoll)
            HitOverrides.DoHit(hit, damageList, statusBonusDmgTypes, hitType, target, attacker)
        end

        ::hit_done::

        local length = #Listeners.ComputeCharacterHit
        if length > 0 then
            for i=1,length do
                local callback = Listeners.ComputeCharacterHit[i]
                local b,err = xpcall(callback, debug.traceback, target, attacker, weapon, damageList, hitType, noHitRoll, forceReduceDurability, hit, alwaysBackstab, highGroundFlag, criticalRoll)
                if not b then
                    Ext.PrintError("[LeaderLib] Error calling function for 'ComputeCharacterHit':\n", err)
                end
            end
        end

        return hit
    end
end

Ext.RegisterListener("ComputeCharacterHit", HitOverrides.ComputeCharacterHit)

Ext.RegisterListener("SessionLoaded", function()
    -- Set to Game.Math.DoHit here, instead of immediately, in case a mod has overwritten it.
    HitOverrides.DoHitModified = Game.Math.DoHit
    -- Original function was changed
    if (Game.Math.ApplyDamageCharacterBonuses ~= HitOverrides.ApplyDamageCharacterBonusesOriginal 
    and Game.Math.ApplyDamageCharacterBonuses ~= HitOverrides.ApplyDamageCharacterBonuses) then
        HitOverrides.ApplyDamageCharacterBonusesModified = Game.Math.ApplyDamageCharacterBonuses
    end
    Game.Math.DoHit = HitOverrides.DoHit
    Game.Math.ApplyDamageCharacterBonuses = HitOverrides.ApplyDamageCharacterBonuses
end)