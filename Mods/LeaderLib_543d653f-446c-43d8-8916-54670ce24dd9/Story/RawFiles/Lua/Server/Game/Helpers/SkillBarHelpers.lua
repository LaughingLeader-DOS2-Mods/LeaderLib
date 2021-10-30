if GameHelpers.Skill == nil then
    GameHelpers.Skill = {}
end

---Get a skill's slot and cooldown, and store it in DB_LeaderLib_Helper_Temp_RefreshUISkill.
---@param char string
---@param skill string
---@param clearSkill boolean
function StoreSkillCooldownData(char, skill, clearSkill)
    char = GameHelpers.GetUUID(char)
    if CharacterIsPlayer(char) == 0 then
        return false
    end
    local slot = NRD_SkillBarFindSkill(char, skill)
    if slot ~= nil then
        local success,cd = pcall(NRD_SkillGetCooldown, char, skill)
        if success == false or cd == nil then cd = 0.0; end
        cd = math.max(cd, 0.0)
        --Osi.LeaderLib_RefreshUI_Internal_StoreSkillCooldownData(char, skill, slot, cd)
        Osi.DB_LeaderLib_Helper_Temp_RefreshUISkill(char, skill, slot, cd)
        if type(clearSkill) == "string" then
            clearSkill = clearSkill == "true"
        end
        if clearSkill then
            NRD_SkillBarClear(char, slot)
        end
        PrintDebug("[LeaderLib_RefreshSkill] Refreshing (" .. tostring(skill) ..") for (" .. tostring(char) .. ") [" .. tostring(cd) .. "]")
    end
 end

local function StoreSkillSlots(char)
    if CharacterIsPlayer(char) == 0 then
        return false
    end
    -- Until we can fetch the active skill bar, iterate through every skill slot for now
    for i=0,144 do
        local skill = NRD_SkillBarGetSkill(char, i)
        if skill ~= nil then
            local success,cd = pcall(NRD_SkillGetCooldown, char, skill)
            if success == false or cd == nil then cd = 0.0 end;
            cd = math.max(cd, 0.0)
            Osi.LeaderLib_RefreshUI_Internal_StoreSkillCooldownData(char, skill, i, cd)
            PrintDebug("[LeaderLib_RefreshSkills] Storing skill slot data (" .. tostring(skill) ..") for (" .. tostring(char) .. ") [" .. tostring(cd) .. "]")
        end
    end
end

local function ClearSlotsWithSkill(char, skill)
    if CharacterIsPlayer(char) == 0 then
        return false
    end
    local maxslots = 144
    local slot = 0
    while slot < 144 do
        local checkskill = NRD_SkillBarGetSkill(char, slot)
        if checkskill == skill then
            NRD_SkillBarClear(char, slot)
        end
        slot = slot + 1
    end
end

---Sets a skill into an empty slot, or finds empty space.
local function TrySetSkillSlot(char, slot, addskill, clearCurrentSlot)
    char = GameHelpers.GetUUID(char)
    if CharacterIsPlayer(char) == 0 then
        return false
    end
    if type(slot) == "string" then
        slot = math.tointeger(slot)
    end
    if slot == nil then slot = 0 end
    if slot < 0 then
        return false
    end

    if clearCurrentSlot == 1 or clearCurrentSlot == true or clearCurrentSlot == "true" then
        ClearSlotsWithSkill(char, addskill)
    end

    local skill = NRD_SkillBarGetSkill(char, slot)
    if skill == nil or skill == "" then
        NRD_SkillBarSetSkill(char, slot, addskill)
        return true
    elseif skill == addskill then
        return true
    else
        local maxslots = 144 - slot
        local nextslot = slot
        while nextslot < maxslots do
            skill = NRD_SkillBarGetSkill(char, nextslot)
            if skill == nil then
                NRD_SkillBarSetSkill(char, slot, addskill)
                return true
            elseif skill == addskill then
                return true
            end
            nextslot = nextslot + 1
        end
    end
    return false
end
Ext.NewCall(TrySetSkillSlot, "LeaderLib_Ext_TrySetSkillSlot", "(CHARACTERGUID)_Character, (INTEGER)_Slot, (STRING)_Skill, (INTEGER)_ClearCurrentSlot")

---Refreshes a skill if the character has it.
local function RefreshSkill(char, skill)
    if CharacterHasSkill(char, skill) == 1 then
        NRD_SkillSetCooldown(char, skill, 0.0)
    end
end
Ext.NewCall(RefreshSkill, "LeaderLib_Ext_RefreshSkill", "(CHARACTERGUID)_Character, (STRING)_Skill")

function GameHelpers.Skill.GetSkillSlots(char, skill, makeLocal)
    char = GameHelpers.GetUUID(char)
	local slots = {}
	for i=0,144,1 do
        local slot = NRD_SkillBarGetSkill(char, i)
		if slot ~= nil and slot == skill then
			if makeLocal == true then
				slots[#slots+1] = i%29
			else
				slots[#slots+1] = i
			end
		end
	end
	return slots
end

GetSkillSlots = GameHelpers.Skill.GetSkillSlots

---Swaps a skill with another one.
---@param char string
---@param targetSkill string The skill to find and replace.
---@param replacementSkill string The skill to replace the target one with.
---@param removeTargetSkill boolean Optional, removes the swapped skill from the character.
---@param resetCooldowns boolean Optional, defaults to true.
function GameHelpers.Skill.Swap(char, targetSkill, replacementSkill, removeTargetSkill, resetCooldowns)
    char = GameHelpers.GetUUID(char)
    local cd = nil
    if CharacterHasSkill(char, targetSkill) == 1 then
        cd = NRD_SkillGetCooldown(char, targetSkill)
    end
    if CharacterIsPlayer(char) == 0 then
        if removeTargetSkill ~= nil and removeTargetSkill ~= false then
            CharacterRemoveSkill(char, targetSkill)
        end
        CharacterAddSkill(char, replacementSkill, 0)
        return false
    end
    local slots = GetSkillSlots(char, targetSkill)
    if #slots > 0 then
        if CharacterHasSkill(char, replacementSkill) == 0 then
            CharacterAddSkill(char, replacementSkill, 0)
        end
        local newSlot = NRD_SkillBarFindSkill(char, replacementSkill)
        if newSlot ~= nil then
            NRD_SkillBarClear(char, newSlot)
        end

        for i,slot in pairs(slots) do
            NRD_SkillBarSetSkill(char, slot, replacementSkill)
        end
    else
        CharacterAddSkill(char, replacementSkill, 0)
    end
    if removeTargetSkill ~= false then
        CharacterRemoveSkill(char, targetSkill)
    end
    if resetCooldowns ~= false then
        NRD_SkillSetCooldown(char, replacementSkill, 0.0)
    elseif cd ~= nil then
        NRD_SkillSetCooldown(char, replacementSkill, cd)
    end
end

---Set a skill cooldown if the character has the skill.
---@param char string
---@param skill string
---@param cooldown number
function GameHelpers.Skill.SetCooldown(char, skill, cooldown)
    char = GameHelpers.GetUUID(char)
    if CharacterHasSkill(char, skill) == 1 then
        if cooldown ~= 0 then
            --Cooldown 0 makes the engine stop sending updateSlotData invokes to hotBar.fla
            NRD_SkillSetCooldown(char, skill, 0)
            --Set the actual cooldown after a frame, now that the previous engine cooldown timer is done
            Timer.StartOneshot("", 1, function()
                NRD_SkillSetCooldown(char, skill, cooldown)
            end)
        else
            NRD_SkillSetCooldown(char, skill, 0)
        end
    end
end

---Set a skill cooldown if the character has the skill.
---@param char string
---@param skill string
function GameHelpers.Skill.RemoveFromSlots(char, skill)
    char = GameHelpers.GetUUID(char)
    local slots = GameHelpers.Skill.GetSkillSlots(char, skill)
    for i=1,#slots do
        local slot = slots[i]
        NRD_SkillBarClear(char,slot)
    end
end

GameHelpers.Skill.StoreCooldownData = StoreSkillCooldownData
GameHelpers.Skill.StoreSlots = StoreSkillSlots
GameHelpers.Skill.TrySetSlot = TrySetSkillSlot
GameHelpers.Skill.Refresh = RefreshSkill
SwapSkill = GameHelpers.Skill.Swap

---@param char string
---@param skill string
---@return boolean
function GameHelpers.Skill.CanMemorize(char, skill)
    local stat = Ext.GetStat(skill)
    if stat then
        local memRequirements = stat.MemorizationRequirements
        if memRequirements then
            for i,v in pairs(memRequirements) do
                if v.Not == false and type(v.Param) == "number" and v.Param > 0 then
                    if Data.AttributeEnum[v.Requirement] ~= nil then
                        local val = CharacterGetAttribute(char, v.Requirement)
                        if val < v.Param then
                            return false
                        end
                    elseif Data.AbilityEnum[v.Requirement] ~= nil then
                        local val = CharacterGetAbility(char, v.Requirement)
                        if val < v.Param then
                            return false
                        end
                    end
                end
            end
        end
    end
    return true
end

---@param character UUID|NETID|EsvCharacter|EclCharacter
---@param skill string
---@return boolean
function GameHelpers.Skill.HasRequirements(character, skill)
    local character = GameHelpers.GetCharacter(character)
    ---@type StatEntrySkillData
    local skillData = Ext.GetStat(skill)
    if skillData then
        local spCost = skillData["Magic Cost"]
        for _,prop in pairs(skillData.Requirements) do
            if prop.Requirement == "Tag" then
                if character:HasTag(prop.Param) == prop.Not then
                    return false
                end
            elseif prop.Requirement == "Combat" then
                if not GameHelpers.Character.IsInCombat(character) == prop.Not then
                    return false
                end
            elseif prop.Requirement == "Immobile" then
                if GameHelpers.Character.IsImmobile(character) == prop.Not then
                    return false
                end
            end
        end
        local APCostBoost = 0
        local SPCostBoost = 0
        for _,dt in pairs(character.Stats.DynamicStats) do
            if dt.APCostBoost then
                APCostBoost = APCostBoost + dt.APCostBoost
            end
            if dt.SPCostBoost then
                SPCostBoost = SPCostBoost + dt.SPCostBoost
            end
        end
        if (character.Stats.CurrentAP + character.Stats.BonusActionPoints) < (skillData.ActionPoints + APCostBoost) then
            return false
        elseif spCost > 0 and character.Stats.MPStart < (spCost + SPCostBoost) then
            return false
        end

        if not StringHelpers.IsNullOrWhitespace(skillData.Requirement) then
            local items = {character.Stats.MainWeapon, character.Stats.OffHandWeapon}
            local meleeTypes = {"Sword", "Club", "Axe", "Staff", "Knife", "Spear"}
            local rangeTypes = {"Bow", "Crossbow", "Wand", "Arrow", "Rifle"}
            if skillData.Requirement == Data.SkillRequirement.MeleeWeapon then
                if not GameHelpers.Item.IsWeaponType(items, meleeTypes) then
                    return false
                end
            elseif skillData.Requirement == Data.SkillRequirement.DaggerWeapon then
                if not GameHelpers.Item.IsWeaponType(items, "Dagger") then
                    return false
                end
            elseif skillData.Requirement == Data.SkillRequirement.ShieldWeapon then
                if character.Stats.OffHandWeapon == nil or character.Stats.OffHandWeapon.ItemType ~= "Shield" then
                    return false
                end
            elseif skillData.Requirement == Data.SkillRequirement.StaffWeapon then
                if not GameHelpers.Item.IsWeaponType(items, "Staff") then
                    return false
                end
            elseif skillData.Requirement == Data.SkillRequirement.RangedWeapon then
                if not GameHelpers.Item.IsWeaponType(items, rangeTypes) then
                    return false
                end
            elseif skillData.Requirement == Data.SkillRequirement.ArrowWeapon then
                if not GameHelpers.Item.IsWeaponType(items, "Arrow") then
                    return false
                end
            elseif skillData.Requirement == Data.SkillRequirement.RifleWeapon then
                if not GameHelpers.Item.IsWeaponType(items, "Rifle") then
                    return false
                end
            end
        end
    end
    return true
end