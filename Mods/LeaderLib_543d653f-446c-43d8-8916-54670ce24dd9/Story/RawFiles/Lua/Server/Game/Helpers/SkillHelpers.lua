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

---@param skill StatEntrySkillData
---@return EsvShootProjectileRequest
local function PrepareProjectileProps(target, skill, source, level, enemiesOnly, extraParams)
    level = level or 1
    ---@type number[]
    local targetPos,sourcePos = nil,nil
    ---@type EsvCharacter|EsvItem
    local targetObject,sourceObject = nil,nil

    local isFromItem = false
    ---@type EsvShootProjectileRequest
    local props = {}
    
    local targetType,sourceType = type(target), type(source)

    if target then
        if targetType == "string" then
            targetObject = Ext.GetGameObject(target)
        elseif targetType == "userdata" then
            targetObject = target
        elseif targetType == "table" then
            targetPos = target
        end
        if targetObject then
            if target ~= source then
                props.HitObject = targetObject.MyGuid
                props.HitObjectPosition = targetObject.WorldPos
                props.Target = targetObject.MyGuid
            end
            targetPos = targetObject.WorldPos
        end
    end

    if source then
        if sourceType == "string" then
            sourceObject = Ext.GetGameObject(source)
        elseif sourceType == "userdata" then
            sourceObject = source
        elseif targetType == "table" then
            props.SourcePosition = source
        end
        if sourceObject then
            props.Caster = sourceObject.MyGuid
            props.Source = sourceObject.MyGuid
            local canCheckStats = ObjectIsItem(sourceObject.MyGuid) == 0 or not GameHelpers.Item.IsObject(sourceObject)
            if canCheckStats and sourceObject.Stats then
                level = sourceObject.Stats.Level
                if sourceObject.Stats.IsSneaking ~= nil then
                    props.IsStealthed = sourceObject.Stats.IsSneaking
                end
                if string.find("TRAP", sourceObject.Stats.Name) then
                    props.IsTrap = 1
                    isFromItem = true
                end
            end
            props.SourcePosition = sourceObject.WorldPos
        end
    end

    if targetObject and sourceObject and enemiesOnly == true then
        if ObjectIsCharacter(sourceObject.MyGuid) == 1 
        and ObjectIsCharacter(targetObject.MyGuid) == 1 
        and CharacterIsEnemy(targetObject.MyGuid, sourceObject.MyGuid) == 0
        then
            props.HitObject = nil
            props.HitObjectPosition = nil
        end
    end

    local height = skill.Height and (skill.Height / 1000) or 2
    local radius = math.max(skill.AreaRadius or 0, skill.ExplodeRadius or 0)
    if radius > 0 then
        radius = radius / 1000
    end
    --tx,ty,tz = GameHelpers.Grid.GetValidPositionInRadius({tx,ty,tz}, radius)

    local fallbackTarget = targetPos
    props.SkillId = skill.Name
    props.CanDeflect = skill.ProjectileType == "Arrow" and 1 or 0
    if not StringHelpers.IsNullOrEmpty(skill.CleanseStatuses) then
        props.CleanseStatuses = skill.CleanseStatuses
    end
    props.CasterLevel = level
    props.SourcePosition = sourcePos
    props.TargetPosition = fallbackTarget
    props.IsFromItem = isFromItem and 1 or 0
    props.IgnoreObjects = 0
    props.AlwaysDamage = skill["Damage Multiplier"] > 0 and 1 or 0

    if extraParams and type(extraParams) == "table" then
        for k,v in pairs(extraParams) do
            props[k] = v
        end
    end

    return props,radius
end

local function ProcessProjectileProps(props)
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

--Mods.LeaderLib.GameHelpers.Skill.ProcessProjectileProps(CharacterGetHostCharacter(), "ProjectileStrike_HailStrike", CharacterGetHostCharacter())

---@param skill StatEntrySkillData
---@param props EsvShootProjectileRequest
local function PlaySkillEffects(skill, props, playCastEffect, playTargetEffect)
    if playCastEffect and not StringHelpers.IsNullOrEmpty(skill.CastEffect) then
        local effects = StringHelpers.Split(skill.CastEffect, ";")
        for _,effectEntry in pairs(effects) do
            local effect = string.gsub(effectEntry, ",.+", ""):gsub(":.+", "")
            local bone = effectEntry:gsub(".+:", "") or ""
            if props.Caster and not StringHelpers.IsNullOrEmpty(bone) then
                PlayEffect(props.Caster, effect, bone)
            elseif props.SourcePosition then
                PlayEffectAtPosition(effect, table.unpack(props.SourcePosition))
            end
        end
    end
    if playTargetEffect and not StringHelpers.IsNullOrWhitespace(skill.TargetEffect) then
        effects = StringHelpers.Split(skill.TargetEffect, ";")
        for _,effectEntry in pairs(effects) do
            local effect = string.gsub(effectEntry, ",.+", ""):gsub(":.+", "")
            local bone = effectEntry:gsub(".+:", "") or ""
            if props.Target and not StringHelpers.IsNullOrEmpty(bone) then
                PlayEffect(props.Target, effect, bone)
            elseif props.TargetPosition then
                PlayEffectAtPosition(effect, table.unpack(props.TargetPosition))
            end
        end
    end
end

---@param target string|number[]|EsvCharacter|EsvItem
---@param skillId string
---@param source string|EsvCharacter|EsvItem
---@param level integer|nil
---@param enemiesOnly boolean|nil
---@param playCastEffects boolean|nil
---@param playTargetEffects boolean|nil
---@param extraParams table|nil
function GameHelpers.Skill.CreateProjectileStrike(target, skillId, source, level, enemiesOnly, playCastEffects, playTargetEffects, extraParams)
    local skill = Ext.GetStat(skillId)
    local count = skill.StrikeCount or 0
    local props,radius = PrepareProjectileProps(target, skill, source, level, enemiesOnly, extraParams)

    --Making the source and target positions match
    if not props.TargetPosition then
        if props.SourcePosition then
            props.TargetPosition = props.SourcePosition
        else
            props.TargetPosition = {0,0,0}
            props.SourcePosition = props.TargetPosition
        end
    else
        props.SourcePosition = props.TargetPosition
    end

    local id = string.format("%s%s", Ext.MonotonicTime(), Ext.Random(999999999))

    local positions = nil

    if count > 0 then
        local tx,ty,tz = table.unpack(props.TargetPosition)
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

    PlaySkillEffects(skill, props, playCastEffects, playTargetEffects)

    if count > 0 then
        local i = 0
        local timerName = string.format("Timers_LeaderLib_ProjectileStrike%s%s", id, Ext.MonotonicTime())
        local onTimer = nil
        onTimer = function()
            if positions ~= nil then
                props.TargetPosition = positions[i] or props.TargetPosition
            end
            ProcessProjectileProps(props)
            i = i + 1
            if i <= count then
                timerName = string.format("Timers_LeaderLib_ProjectileStrike%s%s", id, Ext.MonotonicTime())
                Timer.StartOneshot(timerName, skill.StrikeDelay or 250, onTimer)
            end
        end
        Timer.StartOneshot(timerName, skill.ProjectileDelay or 50, onTimer)
    end
end


---@param target string|number[]|EsvCharacter|EsvItem
---@param skillId string
---@param source string|EsvCharacter|EsvItem
---@param level integer|nil
---@param enemiesOnly boolean|nil
---@param playCastEffects boolean|nil
---@param playTargetEffects boolean|nil
---@param extraParams table|nil
function GameHelpers.Skill.Explode(target, skillId, source, level, enemiesOnly, playCastEffects, playTargetEffects, extraParams)
    local skill = Ext.GetStat(skillId)
    local props,radius = PrepareProjectileProps(target, skill, source, level, enemiesOnly, extraParams)

    --Making the source and target positions match
    if not props.TargetPosition then
        if props.SourcePosition then
            props.TargetPosition = props.SourcePosition
        else
            props.TargetPosition = {0,0,0}
            props.SourcePosition = props.TargetPosition
        end
    else
        props.SourcePosition = props.TargetPosition
    end

    PlaySkillEffects(skill, props, playCastEffects, playTargetEffects)

    ProcessProjectileProps(props)
end


---@param target string|number[]|EsvCharacter|EsvItem
---@param skillId string
---@param source string|EsvCharacter|EsvItem
---@param level integer|nil
---@param enemiesOnly boolean|nil
---@param playCastEffects boolean|nil
---@param playTargetEffects boolean|nil
---@param extraParams table|nil
function GameHelpers.Skill.ShootProjectileAt(target, skillId, source, level, enemiesOnly, playCastEffects, playTargetEffects, extraParams)
    local skill = Ext.GetStat(skillId)
    local props,radius = PrepareProjectileProps(target, skill, source, level, enemiesOnly, extraParams)

    PlaySkillEffects(skill, props, playCastEffects, playTargetEffects)

    ProcessProjectileProps(props)
end