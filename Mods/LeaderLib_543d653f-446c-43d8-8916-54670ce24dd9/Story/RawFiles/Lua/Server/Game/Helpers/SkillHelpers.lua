if GameHelpers.Skill == nil then
    GameHelpers.Skill = {}
end

---Get a skill's slot and cooldown, and store it in DB_LeaderLib_Helper_Temp_RefreshUISkill.
---@param char string
---@param skill string
---@param clearSkill boolean
function StoreSkillCooldownData(char, skill, clearSkill)
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

function GetSkillSlots(char, skill, makeLocal)
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

GameHelpers.Skill.GetSkillSlots = GetSkillSlots

---Swaps a skill with another one.
---@param char string
---@param targetSkill string The skill to find and replace.
---@param replacementSkill string The skill to replace the target one with.
---@param removeTargetSkill boolean Optional, removes the swapped skill from the character.
---@param resetCooldowns boolean Optional, defaults to true.
function GameHelpers.Skill.Swap(char, targetSkill, replacementSkill, removeTargetSkill, resetCooldowns)
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
---@param refreshBar boolean|nil
function GameHelpers.Skill.SetCooldown(char, skill, cooldown, refreshBar)
    if CharacterHasSkill(char, skill) == 1 then
        NRD_SkillSetCooldown(char, skill, cooldown)
        if refreshBar == true then
            GameHelpers.UI.RefreshSkillBar(char)
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

local projectileCreationProperties = {
    SkillId = "String",
    CleanseStatuses = "String",
    CasterLevel = "Integer",
    StatusClearChance = "Integer",
    IsTrap = "Flag",
    UnknownFlag1 = "Flag",
    IsFromItem = "Flag",
    IsStealthed = "Flag",
    IgnoreObjects = "Flag",
    AlwaysDamage = "Flag",
    CanDeflect = "Flag",
    --SourcePosition = "Vector3",
    SourcePosition = "GuidString",
    --TargetPosition = "Vector3",
    TargetPosition = "GuidString",
    --HitObjectPosition = "Vector3",
    HitObjectPosition = "GuidString",
    Caster = "GuidString",
    Source = "GuidString",
    Target = "GuidString",
    HitObject = "GuidString",
}

local function GetRandomPositionInCircleRadius(tx,ty,tz,radius,angle,theta)
    local a = angle or (Ext.Random() * 2 * math.pi)
    local r = theta or (radius * math.sqrt(Ext.Random()))

    local x = tx + (r * math.cos(a))
    local z = tz - (r * math.sin(a))
    return GameHelpers.Grid.GetValidPositionInRadius({x,ty,z}, radius)
end

local function CreateProjectileStrike(props)
    --print(Ext.JsonStringify(props))
    NRD_ProjectilePrepareLaunch()
    for k,v in pairs(props) do
        local t = type(v)
        if t == "table" then
            NRD_ProjectileSetVector3(k, table.unpack(v))
        elseif t == "number" then
            NRD_ProjectileSetInt(k, v)
        elseif t == "string" then
            if projectileCreationProperties[k] == "GuidString" then
                NRD_ProjectileSetGuidString(k, v)
            else
                NRD_ProjectileSetString(k, v)
            end
        end
    end
    NRD_ProjectileLaunch()
end

--Mods.LeaderLib.GameHelpers.Skill.CreateProjectileStrike(CharacterGetHostCharacter(), "ProjectileStrike_HailStrike", CharacterGetHostCharacter())

---@param target string|number[]|EsvCharacter|EsvItem
---@param skillId string
---@param source string|EsvCharacter|EsvItem
function GameHelpers.Skill.CreateProjectileStrike(target, skillId, source)
    local level = -1
    local x,y,z = 0,0,0
    local tx,ty,tz = 0,0,0

    local id = tostring(Ext.Random(9999))
    local isFromItem = false
    ---@type EsvShootProjectileRequest
    local props = {}

    if source then
        if type(source) == "string" then
            props.Caster = source
            props.Source = source
            id = id .. source
            x,y,z = GetPosition(source)
            if ObjectIsCharacter(source) == 1 then
                level = CharacterGetLevel(source)
                local character = Ext.GetCharacter(source)
                if character then
                    props.IsStealthed = character.Stats.IsSneaking
                end
            else
                if string.find("TRAP", NRD_ItemGetStatsId(source)) then
                    props.IsTrap = 1
                end
                isFromItem = true
                local item = Ext.GetItem(source)
                if item and item.Stats then
                    level = item.Stats.Level
                end
            end
        elseif source.Stats then
            level = source.Stats.Level
            isFromItem = ObjectIsItem(source.MyGuid) == 1
            props.Caster = source.MyGuid
            props.Source = source.MyGuid
            x,y,z = table.unpack(source.WorldPos)
            if string.find("TRAP", source.Stats.Name) then
                props.IsTrap = 1
            end
        end
    end

    if type(target) == "string" then
        id = id .. target
        tx,ty,tz = GetPosition(target)
        if target ~= source then
            props.HitObject = target
            props.HitObjectPosition = target
            props.Target = target
        end
    elseif type(target) == "table" then
        tx,ty,tz = table.unpack(target)
    elseif target.WorldPosition ~= nil then
        tx,ty,tz = table.unpack(target.WorldPosition)
    else
        tx = x
        ty = y
        tz = z
    end

    ---@type StatEntrySkillData
    local skill = Ext.GetStat(skillId, level)
    local height = skill.Height and (skill.Height / 1000) or 2
    local radius = math.max(skill.AreaRadius or 0, skill.ExplodeRadius or 0)
    if radius > 0 then
        radius = radius / 1000
    end
    --tx,ty,tz = GameHelpers.Grid.GetValidPositionInRadius({tx,ty,tz}, radius)

    local fallbackTarget = {tx,ty,tz}
    props.SkillId = skill.Name
    props.CanDeflect = skill.ProjectileType == "Arrow" and 1 or 0
    if not StringHelpers.IsNullOrEmpty(skill.CleanseStatuses) then
        props.CleanseStatuses = skill.CleanseStatuses
    end
    props.CasterLevel = level
    props.SourcePosition = {x,y+height,z}
    props.TargetPosition = fallbackTarget
    props.IsFromItem = isFromItem and 1 or 0
    props.IgnoreObjects = 0
    props.AlwaysDamage = skill["Damage Multiplier"] > 0 and 1 or 0

    local count = skill.StrikeCount or 0

    local positions = nil

    if count > 0 then
        if skill.Distribution == "Random" then
            positions = {}
            local angle = Ext.Random() * 2 * math.pi
            for p=1,count+1 do
                local cx,cy,cz = GetRandomPositionInCircleRadius(tx,ty,tz,radius)
                positions[p] = {cx,cy,cz}
            end
            props.TargetPosition = positions[1]
        elseif skill.Distribution == "Edge" then
            positions = {}
            for p=1,count+1 do
                local b = p / count
                local c = (360 * b)
                local cx = tx + (radius * math.sin(math.rad(c)))
                local cz = tz + (radius * math.cos(math.rad(c)))
                local cx,cy,cz = GameHelpers.Grid.GetValidPositionInRadius({cx, ty, cz}, radius)
                positions[p] = {cx,cy,cz}
            end
            props.TargetPosition = positions[1]
        end
    end

    if not StringHelpers.IsNullOrEmpty(skill.CastEffect) then
        local effects = StringHelpers.Split(skill.CastEffect, ";")
        for _,effectEntry in pairs(effects) do
            local effect = string.gsub(effectEntry, ",.+", ""):gsub(":.+", "")
            local bone = effectEntry:gsub(".+:", "") or ""
            if not StringHelpers.IsNullOrEmpty(bone) and source then
                if bone == "root" then
                    bone = "Dummy_Root"
                end
                PlayEffect(source, effect, bone)
            else
                PlayEffectAtPosition(effect, x, y, z)
            end
        end
    end

    if count > 0 then
        local i = 1
        local timerName = string.format("Timers_LeaderLib_ProjectileStrike%s%s", id, Ext.MonotonicTime())
        local onTimer = nil
        onTimer = function()
            if positions ~= nil then
                props.TargetPosition = positions[i] or fallbackTarget
            end
            CreateProjectileStrike(props)
            i = i + 1
            if i <= count then
                timerName = string.format("Timers_LeaderLib_ProjectileStrike%s%s", id, Ext.MonotonicTime())
                StartOneshotTimer(timerName, skill.StrikeDelay or 250, onTimer)
            end
        end
        StartOneshotTimer(timerName, skill.ProjectileDelay or 50, onTimer)
    end
end