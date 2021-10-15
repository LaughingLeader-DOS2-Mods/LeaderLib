if GameHelpers.Skill == nil then
    GameHelpers.Skill = {}
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
    local a = angle or math.rad(Ext.Random(0,359))
    local r = theta or (radius * math.sqrt(Ext.Random()))

    local x = tx + (r * math.cos(a))
    local z = tz - (r * math.sin(a))
    return GameHelpers.Grid.GetValidPositionInRadius({x,ty,z}, radius)
end

---@class LeaderLibProjectileCreationProperties:EsvShootProjectileRequest
---@field PlayCastEffects boolean
---@field PlayTargetEffects boolean
---@field EnemiesOnly boolean
---@field Height number

local LeaderLibProjectileCreationPropertyNames = {
    PlayCastEffects = "boolean",
    PlayTargetEffects = "boolean",
    EnemiesOnly = "boolean",
}

---@param target UUID|EsvCharacter|EsvItem|number[]
---@param skill StatEntrySkillData
---@param source UUID|EsvCharacter|EsvItem|number[]
---@param extraParams LeaderLibProjectileCreationProperties
---@return EsvShootProjectileRequest
local function PrepareProjectileProps(target, skill, source, extraParams)
    local enemiesOnly = extraParams and extraParams.EnemiesOnly

    local sourceLevel = extraParams and extraParams.CasterLevel or nil
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
                props.Caster = targetObject.MyGuid
                props.Source = targetObject.MyGuid
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
    else
        props.SourcePosition = target
    end

    local sourceType = GameHelpers.Ext.ObjectIsCharacter(sourceObject) and "character" or GameHelpers.Ext.ObjectIsItem(sourceObject) and "item"
    local targetType = GameHelpers.Ext.ObjectIsCharacter(targetObject) and "character" or GameHelpers.Ext.ObjectIsItem(targetObject) and "item"

    if sourceLevel == nil then
        if sourceObject then
            if sourceType == "character" then
                sourceLevel = sourceObject.Stats.Level
            elseif sourceType == "item" and not GameHelpers.Item.IsObject(sourceObject) then
                sourceLevel = sourceObject.Stats.Level
            end
        elseif targetType == "character" then
            sourceLevel = targetObject.Stats.Level
        end
    end

    if targetObject and sourceObject and enemiesOnly == true then
        if sourceType == "character"
        and targetType == "character"
        and (CharacterIsEnemy(targetObject.MyGuid, sourceObject.MyGuid) == 0 and IsTagged(target.MyGuid, "LeaderLib_FriendlyFireEnabled") == 0)
        then
            props.HitObject = nil
            props.HitObjectPosition = nil
        end
    end

    local radius = math.max(skill.AreaRadius or 0, skill.ExplodeRadius or 0)

    props.SkillId = skill.Name
    props.CanDeflect = skill.ProjectileType == "Arrow" and 1 or 0
    if not StringHelpers.IsNullOrEmpty(skill.CleanseStatuses) then
        props.CleanseStatuses = skill.CleanseStatuses
    end
    props.CasterLevel = sourceLevel
    props.SourcePosition = sourcePos or {0,0,0}
    props.TargetPosition = targetPos or {0,0,0}
    props.IsFromItem = isFromItem and 1 or 0
    props.IgnoreObjects = 0
    props.AlwaysDamage = skill["Damage Multiplier"] > 0 and 1 or 0

    --Failsafes to prevent crashes from not having a source/caster
    if not props.Caster then
        --Target Dummy
        props.Caster = "36069245-0e2d-44b1-9044-6797bd29bb15"
    end
    if not props.Source then
        props.Source = "36069245-0e2d-44b1-9044-6797bd29bb15"
    end

    if type(extraParams) == "table" then
        for k,v in pairs(extraParams) do
            if not LeaderLibProjectileCreationPropertyNames[k] then
                props[k] = v
            end
        end
    end

    return props,radius
end

--[[
ProcessProjectileProps  {
  AlwaysDamage = 1,
  CanDeflect = 0,
  CasterLevel = 1,
  HitObject = "e446752a-13cc-4a88-a32e-5df244c90d8b",
  HitObjectPosition = { 186.28746032715, -17.0, 359.96667480469 },
  IgnoreObjects = 0,
  IsFromItem = 0,
  SkillId = "Projectile_LLWEAPONEX_Greatbow_LightningStrike",
  SourcePosition = <1>{ 186.28746032715, -17.0, 359.96667480469 },
  Target = "e446752a-13cc-4a88-a32e-5df244c90d8b",
  TargetPosition = <table 1>
}
]]

---@param props EsvShootProjectileRequest
local function ProcessProjectileProps(props)
    if not props.SourcePosition or not props.TargetPosition then
        error(string.format("[LeaderLib:ProcessProjectileProps] Invalid projectile properties. Skipping launch to avoid crashing!\n%s", Lib.inspect(props)), 2)
    end
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
local function PlayProjectileSkillEffects(skill, props, playCastEffect, playTargetEffect)
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
        local effects = StringHelpers.Split(skill.TargetEffect, ";")
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
---@param extraParams LeaderLibProjectileCreationProperties
function GameHelpers.Skill.CreateProjectileStrike(target, skillId, source, extraParams)
    extraParams = type(extraParams) == "table" and extraParams or {}
    local skill = Ext.GetStat(skillId)
    local count = skill.StrikeCount or 0
    local props,radius = PrepareProjectileProps(target, skill, source, extraParams)

    --Fix for ProjectileStrikes being rotated weird or off-center. Don't set a Source.
    props.Source = nil

    --Making the source and target positions match
    if not props.TargetPosition then
        if props.SourcePosition then
            props.TargetPosition = props.SourcePosition
        else
            props.TargetPosition = {0,0,0}
            props.SourcePosition = {0,0,0}
        end
    else
        props.SourcePosition = {0,0,0}
        TableHelpers.AddOrUpdate(props.SourcePosition, props.TargetPosition)
    end

    local height = (extraParams.Height or skill.Height)
    props.SourcePosition[2] = props.SourcePosition[2] + height

    --props.HitObjectPosition = TableHelpers.Clone(props.TargetPosition)
    --props.HitObjectPosition[2] = props.HitObjectPosition[2] + (extraParams.Height or skill.Height)
    --props.TargetPosition[2] = props.TargetPosition[2] + (extraParams.Height or skill.Height)

    local id = string.format("%s%s", Ext.MonotonicTime(), Ext.Random(999999999))

    local positions = nil

    if count > 0 then
        local startingAngle = GameHelpers.Math.Clamp(skill.Angle, -44, 44)

        if skill.SingleSource ~= "Yes" then
            local tx,ty,tz = table.unpack(props.TargetPosition)
            if skill.Distribution == "Random" then
                positions = {}
                local angle = Ext.Random() * 2 * math.pi
                for p=1,count do
                    local cx,cy,cz = GetRandomPositionInCircleRadius(tx,ty,tz,radius)
                    positions[p] = {cx,cy,cz}
                end
            elseif skill.Distribution == "Edge" then
                positions = {}
                local inc = 360/count
                for p=1,count do
                    local angle = startingAngle + (inc * p)
                    local rads = math.rad(angle)
                    local cx = tx + (radius * math.cos(rads))
                    local cz = tz + (radius * math.sin(rads))
                    local cy = GameHelpers.Grid.GetY(cx,cz)
                    positions[p] = {cx,cy,cz}
                end
            elseif skill.Distribution == "EdgeCenter" then
                positions = {}
                local center = {tx,ty,tz}
                if count > 1 then
                    local inc = 360/(count-1)
                    for p=1,count-1 do
                        local angle = startingAngle + (inc * p)
                        local rads = math.rad(angle)
                        local cx = tx + (radius * math.cos(rads))
                        local cz = tz + (radius * math.sin(rads))
                        local cy = GameHelpers.Grid.GetY(cx,cz)
                        positions[p] = {cx,cy,cz}
                    end
                end
                positions[#positions+1] = center
            elseif skill.Distribution == "Line" then -- Custom
                positions = {}
                --startingAngle = startingAngle - 90
                local nextAngle = 0
                local nextRadius = 0
                for p=1,count do
                    local rads = math.rad(nextAngle)
                    local cx = tx + (nextRadius * math.cos(rads))
                    local cz = tz + (nextRadius * math.sin(rads))
                    local cy = GameHelpers.Grid.GetY(cx,cz)
                    positions[p] = {cx,cy,cz}
                    if nextAngle == startingAngle then
                        nextAngle = startingAngle + 180
                    else
                        nextAngle = startingAngle
                    end
                    if nextRadius > 0 then
                        nextRadius = -radius * p
                    else
                        nextRadius = radius * p
                    end
                end
            end
        end
    end

    PlayProjectileSkillEffects(skill, props, extraParams.PlayCastEffects, extraParams.PlayTargetEffects)

    local originalSource = TableHelpers.Clone(props.SourcePosition)

    if count > 0 then
        if skill.SingleSource ~= "Yes" and skill.Shuffle and string.find(skill.Distribution, "Edge") then
            positions = TableHelpers.ShuffleTable(positions)
        end
        local i = 1
        local timerName = string.format("Timers_LeaderLib_ProjectileStrike%s%s", id, Ext.MonotonicTime())
        local onTimer = nil
        onTimer = function()
            if skill.SingleSource ~= "Yes" and positions ~= nil then
                local x,y,z = table.unpack(positions[i])
                props.TargetPosition = {x,y,z}
                props.SourcePosition = {x,y+height,z}
            end
            props.Source = nil
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
---@param extraParams LeaderLibProjectileCreationProperties
function GameHelpers.Skill.Explode(target, skillId, source, extraParams)
    extraParams = type(extraParams) == "table" and extraParams or {}
    local skill = Ext.GetStat(skillId)
    local props,radius = PrepareProjectileProps(target, skill, source, extraParams)

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

    PlayProjectileSkillEffects(skill, props, extraParams.PlayCastEffects, extraParams.PlayTargetEffects)

    ProcessProjectileProps(props)
end


---@param target string|number[]|EsvCharacter|EsvItem
---@param skillId string
---@param source string|EsvCharacter|EsvItem
---@param extraParams LeaderLibProjectileCreationProperties|nil
function GameHelpers.Skill.ShootProjectileAt(target, skillId, source, extraParams)
    extraParams = type(extraParams) == "table" and extraParams or {}
    local skill = Ext.GetStat(skillId)
    local props,radius = PrepareProjectileProps(target, skill, source, extraParams)

    PlayProjectileSkillEffects(skill, props, extraParams.PlayCastEffects, extraParams.PlayTargetEffects)

    ProcessProjectileProps(props)
end

--Mods.LeaderLib.GameHelpers.Skill.CreateZone(GameHelpers.Math.GetForwardPosition(me.MyGuid, 10.0), "Zone_LaserRay", me.MyGuid)

---@param skill StatEntrySkillData
---@param source UUID
---@param targetObject UUID
---@param sourcePosition number[]
---@param targetPosition number[]
---@param playCastEffect boolean|nil
---@param playTargetEffect boolean|nil
local function PlayZoneSkillEffects(skill, source, targetObject, sourcePosition, targetPosition, playCastEffect, playTargetEffect)
    if playCastEffect and not StringHelpers.IsNullOrEmpty(skill.CastEffect) then
        local effects = StringHelpers.Split(skill.CastEffect, ";")
        for _,effectEntry in pairs(effects) do
            local effect = string.gsub(effectEntry, ",.+", ""):gsub(":.+", "")
            local bone = effectEntry:gsub(".+:", "") or ""
            if source and not StringHelpers.IsNullOrEmpty(bone) then
                PlayEffect(source, effect, bone)
            elseif sourcePosition then
                PlayEffectAtPosition(effect, table.unpack(sourcePosition))
            end
        end
    end
    if playTargetEffect and not StringHelpers.IsNullOrWhitespace(skill.TargetEffect) then
        local effects = StringHelpers.Split(skill.TargetEffect, ";")
        for _,effectEntry in pairs(effects) do
            local effect = string.gsub(effectEntry, ",.+", ""):gsub(":.+", "")
            local bone = effectEntry:gsub(".+:", "") or ""
            if targetObject and not StringHelpers.IsNullOrEmpty(bone) then
                PlayEffect(targetObject, effect, bone)
            elseif targetPosition then
                PlayEffectAtPosition(effect, table.unpack(targetPosition))
            end
        end
    end
end

---@class LeaderLibZoneCreationProperties:EsvZoneAction
---@field PlayCastEffects boolean
---@field PlayTargetEffects boolean
---@field ApplySkillProperties boolean


local LeaderLibZoneCreationPropertiesNames = {
    PlayCastEffects = "boolean",
    PlayTargetEffects = "boolean",
    ApplySkillProperties = "boolean",
}

---Shoot a zone/cone skill at a target object or position.
---@param skillId string Zone or Cone type skill.
---@param source UUID|EsvCharacter|EsvItem
---@param target UUID|number[]|EsvCharacter|EsvItem
---@param extraParams LeaderLibZoneCreationProperties A table of properties to apply on top of the parsed skill properties.
function GameHelpers.Skill.ShootZoneAt(skillId, source, target, extraParams)
    ---@type StatEntrySkillData
    local skill = Ext.GetStat(skillId)
    ---@type EsvZoneAction
    local action = Ext.CreateSurfaceAction("ZoneAction")
    ---@type LeaderLibZoneCreationProperties
    local props = {} 
    props.SkillId = skillId
    --zone.AiFlags = skill.AIFlags
    props.AngleOrBase = math.max(skill.Base or 0, skill.Angle or 0)
    props.BackStart = skill.BackStart
    props.DeathType = skill.DeathType
    props.FrontOffset = skill.FrontOffset
    props.GrowStep = skill.SurfaceGrowStep
    props.GrowTimer = skill.SurfaceGrowInterval * 0.01
    props.MaxHeight = 2.4
    props.Target = GameHelpers.Math.GetPosition(target, false, {0,0,0})
    props.Shape = skill.Shape == "Square" and 1 or 0
    props.Radius = skill.Range
    --Inherited properties
    props.SurfaceType = skill.SurfaceType
    props.StatusChance = 1.0
    props.Duration = (math.max(1, skill.SurfaceLifetime)) * 6.0
    if source then
        local sourceObject = GameHelpers.TryGetObject(source, true)
        if sourceObject then
            props.OwnerHandle = sourceObject.Handle
            props.Position = sourceObject.WorldPos

            if GameHelpers.Ext.ObjectIsCharacter(sourceObject) then
                local b,damageList,deathType = xpcall(Game.Math.GetSkillDamage, debug.traceback, skill, sourceObject.Stats, false, false, props.Position, props.Target, sourceObject.Stats.Level, false)
                if b then
                    props.DamageList = damageList
                else
                    Ext.PrintError(damageList)
                end
            end
        end
    end
    if not props.Position then
        props.Position = props.Target
    end

    local playCastEffects, playTargetEffects, applySkillProperties = false,false,false
    local sourceId = GameHelpers.GetUUID(source)

    if type(extraParams) == "table" then
        for k,v in pairs(extraParams) do
            if LeaderLibZoneCreationPropertiesNames[k] then
                if type(v) == LeaderLibZoneCreationPropertiesNames[k] then
                    if k == "PlayCastEffects" then
                        playCastEffects = v
                    elseif k == "PlayTargetEffects" then
                        playCastEffects = v
                    elseif k == "ApplySkillProperties" and v == true then
                        applySkillProperties = true
                        if not Vars.ApplyZoneSkillProperties[skillId] then
                            Vars.ApplyZoneSkillProperties[skillId] = {}
                        end
                        local timerName = string.format("%s_%s_ApplySkillPropertiesDone", skillId, sourceId)
                        Vars.ApplyZoneSkillProperties[skillId][sourceId] = true
                        Timer.StartOneshot(timerName, 2, function()
                            if Vars.ApplyZoneSkillProperties[skillId] then
                                Vars.ApplyZoneSkillProperties[skillId][sourceId] = timerName
                            end
                        end)
                    end
                end
            else
                props[k] = v
            end
        end
    end

    if applySkillProperties then
        if GetDistanceToPosition(sourceId, props.Position[1], props.Position[2], props.Position[3]) <= 1 then
            Ext.ExecuteSkillPropertiesOnTarget(skillId, sourceId, sourceId, props.Position, "Self", false)
        end
    end

    PlayZoneSkillEffects(skill, sourceId, GameHelpers.GetUUID(target), props.Position, props.Target, playCastEffects, playTargetEffects)

    for k,v in pairs(props) do
        action[k] = v
    end
    Ext.ExecuteSurfaceAction(action)
    return true
end

---Shoot a zone/cone skill in the direction the source object is looking.
---@param skillId string Zone or Cone type skill.
---@param source UUID|EsvCharacter|EsvItem
---@param extraParams LeaderLibZoneCreationProperties A table of properties to apply on top of the parsed skill properties.
function GameHelpers.Skill.ShootZoneFromSource(skillId, source, extraParams)
    local dist = extraParams and extraParams.Radius or Ext.StatGetAttribute(skillId, "Range") or 2
    local target = GameHelpers.Math.GetForwardPosition(source, dist)
    GameHelpers.Skill.ShootZoneAt(skillId, source, target, extraParams)
end

--Mods.LeaderLib.GameHelpers.Skill.ShootZoneFromSource("Cone_SilencingStare", me.MyGuid, {PlayCastEffects=true,PlayTargetEffects=true,ApplySkillProperties=true})