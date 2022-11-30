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
        fprint(LOGLEVEL.TRACE, "[LeaderLib_RefreshSkill] Refreshing (" .. tostring(skill) ..") for (" .. tostring(char) .. ") [" .. tostring(cd) .. "]")
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
            fprint(LOGLEVEL.TRACE, "[LeaderLib_RefreshSkills] Storing skill slot data (" .. tostring(skill) ..") for (" .. tostring(char) .. ") [" .. tostring(cd) .. "]")
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
	local slots = {}
    local character = GameHelpers.GetCharacter(char)
    if not character or not GameHelpers.Character.IsPlayer(character) or not character.PlayerData then
        return slots
    end
    for i,v in pairs(character.PlayerData.SkillBar) do
        if v.SkillOrStatId == skill then
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
---@param char CharacterParam
---@param targetSkill string The skill to find and replace.
---@param replacementSkill string The skill to replace the target one with.
---@param removeTargetSkill boolean|nil Optional, removes the swapped skill from the character.
---@param resetCooldowns boolean|nil Optional, defaults to true.
function GameHelpers.Skill.Swap(char, targetSkill, replacementSkill, removeTargetSkill, resetCooldowns)
    local character = GameHelpers.GetCharacter(char)
    if not character then
        return false
    end
    ---@cast character EsvCharacter
    local GUID = character.MyGuid

    local cd = nil
    local existingSkill = character.SkillManager.Skills[targetSkill]
    if existingSkill then
        cd = existingSkill.ActiveCooldown
    end
    if not GameHelpers.Character.IsPlayer(character) then
        if removeTargetSkill ~= nil and removeTargetSkill ~= false then
            CharacterRemoveSkill(GUID, targetSkill)
        end
        CharacterAddSkill(GUID, replacementSkill, 0)
        return false
    end
    CharacterAddSkill(GUID, replacementSkill, 0)
    for i,v in pairs(character.PlayerData.SkillBar) do
        if v.SkillOrStatId == targetSkill then
            v.SkillOrStatId = replacementSkill
        elseif v.SkillOrStatId == replacementSkill then
            v.SkillOrStatId = ""
            v.Type = "None"
        end
    end
    if removeTargetSkill ~= false then
        CharacterRemoveSkill(GUID, targetSkill)
    end
    local addedSkillData = character.SkillManager.Skills[replacementSkill]
    if addedSkillData then
        if resetCooldowns ~= false then
            addedSkillData.ActiveCooldown = 0
        elseif cd ~= nil then
            addedSkillData.ActiveCooldown = cd
        end
    end
    GameHelpers.UI.RefreshSkillBar(character)
end

--[[ ---Set a skill cooldown if the character has the skill.
---@param char CharacterParam
---@param skill string
---@param cooldown number
function GameHelpers.Skill.SetCooldown(char, skill, cooldown)
    local uuid = GameHelpers.GetUUID(char)
    assert(not StringHelpers.IsNullOrEmpty(uuid), "A valid EsvCharacter, NetID, or UUID is required.")
    if CharacterHasSkill(uuid, skill) == 1 then
        if cooldown ~= 0 then
            --Cooldown 0 makes the engine stop sending updateSlotData invokes to hotBar.swf
            NRD_SkillSetCooldown(uuid, skill, 0)
            --Set the actual cooldown after a frame, now that the previous engine cooldown timer is done
            Timer.StartOneshot("", 30, function (e)
                NRD_SkillSetCooldown(uuid, skill, cooldown)
            end)
        else
            NRD_SkillSetCooldown(uuid, skill, 0)
        end
    end
end ]]

---Set a skill cooldown if the character has the skill.
---@param char CharacterParam
---@param skill string
---@param cooldown number
function GameHelpers.Skill.SetCooldown(char, skill, cooldown)
    local character = GameHelpers.GetCharacter(char) --[[@as EsvCharacter]]
    assert(character ~= nil, "A valid EsvCharacter, NetID, or UUID is required.")
    local skillData = character.SkillManager.Skills[skill]
    if skillData then
        skillData.ActiveCooldown = cooldown
        if cooldown ~= 0 and GameHelpers.Character.IsPlayer(character) and character.CharacterControl then
            --Force the hotbar to refresh the cooldown animations
            GameHelpers.UI.RefreshSkillBar(character)
        end
    end
end

---Add an amount to an active skill cooldown
---@param char CharacterParam
---@param skill string
---@param amount number
function GameHelpers.Skill.AddCooldown(char, skill, amount)
    local character = GameHelpers.GetCharacter(char) --[[@as EsvCharacter]]
    assert(character ~= nil, "A valid EsvCharacter, NetID, or UUID is required.")
    local skillData = character.SkillManager.Skills[skill]
    if skillData then
        if skillData.ActiveCooldown ~= 60 or not GameHelpers.Character.IsInCombat(character) then
            local cd = math.max(0, skillData.ActiveCooldown + amount)
            local guid = character.MyGuid
            skillData.ActiveCooldown = 0
            Timer.StartOneshot("", 33, function (e)
                GameHelpers.Skill.SetCooldown(guid, skill, cd, true)
            end)
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

---Removes all skills from a character.
---@param char CharacterParam
function GameHelpers.Skill.RemoveAllSkills(char)
    local char = GameHelpers.GetCharacter(char)
    if char then
        if not _OSIRIS() then
            fprint(LOGLEVEL.WARNING, "[GameHelpers.Skill.RemoveAllSkills] Can't remove skills from (%s)[%s] - Osiris is not callable.", GameHelpers.Character.GetDisplayName(char), char.MyGuid)
            return
        end
        for _,v in pairs(char:GetSkills()) do
            CharacterRemoveSkill(char.MyGuid, v)
        end
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
    local stat = Ext.Stats.Get(skill, nil, false)
    if stat then
        local memRequirements = stat.MemorizationRequirements
        if memRequirements then
            for i,v in pairs(memRequirements) do
                if v.Not == false and type(v.Param) == "number" and v.Param > 0 then
                    if Data.Attribute[v.Requirement] ~= nil then
                        local val = CharacterGetAttribute(char, v.Requirement)
                        if val < v.Param then
                            return false
                        end
                    elseif Data.Ability[v.Requirement] ~= nil then
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

---@deprecated
---Use GameHelpers.Skill.HasRequirements instead
GameHelpers.Skill.HasRequirements = function(...) return GameHelpers.Stats.CharacterHasRequirements(...) end