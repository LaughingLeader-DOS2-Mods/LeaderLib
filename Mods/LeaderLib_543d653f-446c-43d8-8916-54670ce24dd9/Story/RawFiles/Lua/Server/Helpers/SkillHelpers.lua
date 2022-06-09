if GameHelpers == nil then GameHelpers = {} end
if GameHelpers.Skill == nil then GameHelpers.Skill = {} end

local function TrySetValue(target, k, v)
    target[k] = v
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

--LeaderLibProjectileCreationProperties
---@class BaseLeaderLibProjectileCreationProperties
---@field SkillId string
---@field CleanseStatuses string
---@field CasterLevel integer
---@field StatusClearChance integer
---@field IsTrap boolean
---@field UnknownFlag1 boolean
---@field IsFromItem boolean
---@field IsStealthed boolean
---@field IgnoreObjects boolean
---@field AlwaysDamage boolean
---@field CanDeflect boolean
---@field SourcePosition number[]|UUID|EsvCharacter|EsvItem
---@field TargetPosition number[]|UUID|EsvCharacter|EsvItem
---@field HitObjectPosition number[]|UUID|EsvCharacter|EsvItem
---@field Caster UUID|EsvCharacter|EsvItem
---@field Source UUID|EsvCharacter|EsvItem
---@field Target UUID|EsvCharacter|EsvItem
---@field HitObject UUID|EsvCharacter|EsvItem

---@class LeaderLibProjectileCreationProperties:BaseLeaderLibProjectileCreationProperties
---@field PlayCastEffects boolean|nil
---@field PlayTargetEffects boolean|nil
---@field EnemiesOnly boolean|nil
---@field Height number|nil
---@field SetHitObject boolean|nil
---@field SourceOffset number[]|nil
---@field TargetOffset number[]|nil
---@field ParamsParsed fun(props:LeaderLibProjectileCreationProperties, sourceObject:EsvCharacter|EsvItem|nil, targetObject:EsvCharacter|EsvItem|nil)|nil
---@field SkillOverrides StatEntrySkillData|nil Optional table of skill attributes to override the skill logic with.

local LeaderLibProjectileCreationPropertyNames = {
    PlayCastEffects = "boolean",
    PlayTargetEffects = "boolean",
    EnemiesOnly = "boolean",
    Height = "number",
    SetHitObject = "boolean",
    SourceOffset = "table",
    TargetOffset = "table",
    ParamsParsed = "function",
    SkillOverrides = "table",
}

---@param target UUID|EsvCharacter|EsvItem|number[]
---@param skill StatEntrySkillData
---@param source UUID|EsvCharacter|EsvItem|number[]
---@param extraParams LeaderLibProjectileCreationProperties
---@return LeaderLibProjectileCreationProperties
local function PrepareProjectileProps(target, skill, source, extraParams)
    local enemiesOnly = extraParams and extraParams.EnemiesOnly

    local sourceLevel = extraParams and extraParams.CasterLevel or nil

    local sourceObject = source and GameHelpers.TryGetObject(source) or nil
    local targetObject = type(target) == "userdata" and GameHelpers.TryGetObject(target) or nil

    local targetPos = GameHelpers.Math.GetPosition(targetObject or target, false)
    local sourcePos = source and GameHelpers.Math.GetPosition(sourceObject or source, false) or targetPos

    local isFromItem = false
    ---@type LeaderLibProjectileCreationProperties
    local props = {}

    if extraParams.SourceOffset then
        sourcePos[1] = sourcePos[1] + extraParams.SourceOffset[1]
        sourcePos[2] = sourcePos[2] + extraParams.SourceOffset[2]
        sourcePos[3] = sourcePos[3] + extraParams.SourceOffset[3]
    end

    if extraParams.TargetOffset then
        targetPos[1] = targetPos[1] + extraParams.TargetOffset[1]
        targetPos[2] = targetPos[2] + extraParams.TargetOffset[2]
        targetPos[3] = targetPos[3] + extraParams.TargetOffset[3]
    end

    props.SourcePosition = sourcePos
    props.TargetPosition = targetPos
    
    if targetObject then
        if extraParams.SetHitObject then
            props.HitObject = targetObject.MyGuid
            props.HitObjectPosition = targetObject.WorldPos
        end
        props.Caster = targetObject.MyGuid
        props.Source = targetObject.MyGuid
        props.Target = targetObject.MyGuid
    end

    if sourceObject then
        props.Caster = sourceObject.MyGuid
        props.Source = sourceObject.MyGuid
        --props.SourcePosition = GameHelpers.Math.GetForwardPosition(sourceObject, 1.5)
    end

    local sourceType = GameHelpers.Ext.ObjectIsCharacter(sourceObject) and "character" or GameHelpers.Ext.ObjectIsItem(sourceObject) and "item"
    local targetType = GameHelpers.Ext.ObjectIsCharacter(targetObject) and "character" or GameHelpers.Ext.ObjectIsItem(targetObject) and "item"

    if sourceLevel == nil then
        if sourceObject then
            if sourceType == "character" then
                sourceLevel = sourceObject.Stats.Level
                if sourceObject.Stats.IsSneaking ~= nil then
                    props.IsStealthed = sourceObject.Stats.IsSneaking
                end
            elseif sourceType == "item" and not GameHelpers.Item.IsObject(sourceObject) then
                sourceLevel = sourceObject.Stats.Level
                if string.find("TRAP", sourceObject.Stats.Name) then
                    props.IsTrap = 1
                    isFromItem = true
                end
            end
        elseif targetType == "character" and targetObject then
            sourceLevel = targetObject.Stats.Level
        end
    end

    if targetObject and sourceObject and enemiesOnly == true then
        if sourceType == "character"
        and targetType == "character"
        and (not GameHelpers.Character.IsEnemy(targetObject, sourceObject) and not targetObject:HasTag("LeaderLib_FriendlyFireEnabled"))
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
                if v == "nil" then
                    props[k] = nil
                else
                    props[k] = v
                end
            end
        end
    end

    if extraParams.ParamsParsed then
        local b,err = xpcall(extraParams.ParamsParsed, debug.traceback, props, sourceObject, targetObject)
        if not b then
            Ext.PrintError(err)
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

---@param props LeaderLibProjectileCreationProperties
local function ProcessProjectileProps(props)
    if not props.SourcePosition or not props.TargetPosition then
        error(string.format("[LeaderLib:ProcessProjectileProps] Invalid projectile properties. Skipping launch to avoid crashing!\n%s", Lib.inspect(props)), 2)
    end
    NRD_ProjectilePrepareLaunch()
    for k,v in pairs(props) do
        if projectileCreationProperties[k] then
            local t = type(v)
            if t == "table" then
                NRD_ProjectileSetVector3(k, table.unpack(v))
            elseif t == "number" then
                NRD_ProjectileSetInt(k, v)
            elseif t == "string" then
                if projectileCreationProperties[k] == "GuidString" then
                    NRD_ProjectileSetGuidString(k, GameHelpers.GetUUID(v))
                else
                    NRD_ProjectileSetString(k, v)
                end
            end
        end
    end
    NRD_ProjectileLaunch()
end

--Mods.LeaderLib.GameHelpers.Skill.ProcessProjectileProps(CharacterGetHostCharacter(), "ProjectileStrike_HailStrike", CharacterGetHostCharacter())

---@param skill StatEntrySkillData
---@param props LeaderLibProjectileCreationProperties
local function PlayProjectileSkillEffects(skill, props, playCastEffect, playTargetEffect)
    if playCastEffect and not StringHelpers.IsNullOrEmpty(skill.CastEffect) then
        local effects = StringHelpers.Split(skill.CastEffect, ";")
        for _,effectEntry in pairs(effects) do
            local effect = string.gsub(effectEntry, ",.+", ""):gsub(":.+", "")
            local bone = effectEntry:gsub(".+:", "") or ""
            if props.Caster and not StringHelpers.IsNullOrEmpty(bone) then
                EffectManager.PlayEffect(effect, props.Caster, {Bone=bone})
            elseif props.SourcePosition then
                EffectManager.PlayEffectAt(effect, props.SourcePosition)
            end
        end
    end
    if playTargetEffect and not StringHelpers.IsNullOrWhitespace(skill.TargetEffect) then
        local effects = StringHelpers.Split(skill.TargetEffect, ";")
        for _,effectEntry in pairs(effects) do
            local effect = string.gsub(effectEntry, ",.+", ""):gsub(":.+", "")
            local bone = effectEntry:gsub(".+:", "") or ""
            if props.Target and not StringHelpers.IsNullOrEmpty(bone) then
                EffectManager.PlayEffect(effect, props.Target, {Bone=bone})
            elseif props.TargetPosition then
                EffectManager.PlayEffectAt(effect, props.TargetPosition)
            end
        end
    end
end

---@class LeaderLibProjectileStrikeCreationProperties:LeaderLibProjectileCreationProperties
---@field Positions number[]|nil Optional positions to use for strikes. Overrides whatever positions it would have normally determined with Distribution.

---@param target string|number[]|EsvCharacter|EsvItem
---@param skillId string
---@param source string|EsvCharacter|EsvItem
---@param extraParams LeaderLibProjectileStrikeCreationProperties
function GameHelpers.Skill.CreateProjectileStrike(target, skillId, source, extraParams)
    extraParams = type(extraParams) == "table" and extraParams or {}
    local skill = GameHelpers.Ext.CreateSkillTable(skillId)
    if type(extraParams.SkillOverrides) == "table" then
        for k,v in pairs(extraParams.SkillOverrides) do
            skill[k] = v
        end
    end
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

    if extraParams.Positions then
        positions = extraParams.Positions
        count = #positions
    else
        if count > 0 then
            local startingAngle = GameHelpers.Math.Clamp(skill.Angle, -44, 44)
            local tx,ty,tz = table.unpack(props.TargetPosition)
            if skill.Distribution == "Random" then
                positions = {}
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

    if positions and skill.Shuffle == "Yes" then
        positions = TableHelpers.ShuffleTable(positions)
    end

    PlayProjectileSkillEffects(skill, props, extraParams.PlayCastEffects, extraParams.PlayTargetEffects)

    --local originalSource = TableHelpers.Clone(props.SourcePosition)

    if count > 0 then
        local i = 1
        local timerName = string.format("LeaderLib_ProjectileStrike%s_%s_%s", id, i, Ext.MonotonicTime())
        local onTimer = nil
        onTimer = function()
            if positions ~= nil then
                local x,y,z = table.unpack(positions[i])
                props.TargetPosition = {x,y,z}
                props.SourcePosition = {x,y+height,z}
            end
            props.Source = nil
            ProcessProjectileProps(props)
            i = i + 1
            if i <= count then
                local delay = skill.StrikeDelay or 250
                if delay <= 0 then
                    onTimer()
                else
                    timerName = string.format("LeaderLib_ProjectileStrike%s_%s_%s", id, i, Ext.MonotonicTime())
                    Timer.StartOneshot(timerName, skill.StrikeDelay or 250, onTimer)
                end
            end
        end
        local initialDelay = skill.ProjectileDelay or 50
        if initialDelay <= 0 then
            onTimer()
        else
            Timer.StartOneshot(timerName, initialDelay, onTimer)
        end
    end
end

---@param target string|number[]|EsvCharacter|EsvItem
---@param skillId string
---@param source string|EsvCharacter|EsvItem|nil
---@param extraParams LeaderLibProjectileCreationProperties|nil Optional table of properties to apply on top of the properties set from the skill stat.
function GameHelpers.Skill.ShootProjectileAt(target, skillId, source, extraParams)
    local extraParams = type(extraParams) == "table" and extraParams or {}
    local skill = GameHelpers.Ext.CreateSkillTable(skillId)
    if type(extraParams.SkillOverrides) == "table" then
        for k,v in pairs(extraParams.SkillOverrides) do
            skill[k] = v
        end
    end
    if not extraParams.SourceOffset then
        extraParams.SourceOffset = {0,2,0}
    end
    if not extraParams.ParamsParsed and source ~= nil and type(source) ~= "table" then
        extraParams.ParamsParsed = function(props, sourceObj, targetObj)
            --Modifies the SourcePosition to between the source and target
            local directionalVector = GameHelpers.Math.GetDirectionalVectorBetweenPositions(props.SourcePosition, props.TargetPosition)
	        props.SourcePosition = {GameHelpers.Grid.GetValidPositionAlongLine(props.SourcePosition, directionalVector, 1.0)}
            props.SourcePosition[2] = props.SourcePosition[2] + 2.0
        end
    end
    local props = PrepareProjectileProps(target, skill, source, extraParams)

    PlayProjectileSkillEffects(skill, props, extraParams.PlayCastEffects, extraParams.PlayTargetEffects)

    ProcessProjectileProps(props)
end

---Explode a skill as a target. Similar to CreateExplosion, EXPODE or LeaveAction/DieAction.
---@param target UUID|EsvCharacter|EsvItem|number[] The target character, item, or position.
---@param skillId string The skill to use for damage.
---@param source UUID|EsvCharacter|EsvItem The source of the damage, either a character, item, or UUID.
---@param extraParams LeaderLibProjectileCreationProperties|nil Optional table of properties to apply on top of the properties set from the skill stat.
function GameHelpers.Skill.Explode(target, skillId, source, extraParams)
    --Support for older usage
    if extraParams == true then
        extraParams = {
            EnemiesOnly = true
        }
    end
    local extraParams = type(extraParams) == "table" and extraParams or {}
    local skill = GameHelpers.Ext.CreateSkillTable(skillId)
    if type(extraParams.SkillOverrides) == "table" then
        for k,v in pairs(extraParams.SkillOverrides) do
            skill[k] = v
        end
    end
    local props = PrepareProjectileProps(target, skill, source, extraParams)

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
---@field SkillOverrides StatEntrySkillData|nil Optional table of skill attributes to override the skill logic with.


local LeaderLibZoneCreationPropertiesNames = {
    PlayCastEffects = "boolean",
    PlayTargetEffects = "boolean",
    ApplySkillProperties = "boolean",
    SkillOverrides = "table",
}

---Shoot a zone/cone skill at a target object or position.
---@param skillId string Zone or Cone type skill.
---@param source UUID|EsvCharacter|EsvItem
---@param target UUID|number[]|EsvCharacter|EsvItem
---@param extraParams LeaderLibZoneCreationProperties An optional table of properties to apply on top of the parsed skill properties.
function GameHelpers.Skill.ShootZoneAt(skillId, source, target, extraParams)
    extraParams = type(extraParams) == "table" and extraParams or {}
    local skill = GameHelpers.Ext.CreateSkillTable(skillId)
    if type(extraParams.SkillOverrides) == "table" then
        for k,v in pairs(extraParams.SkillOverrides) do
            skill[k] = v
        end
    end
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
    props.Target = GameHelpers.Math.GetPosition(target, false)
    props.Shape = skill.Shape == "Square" and 1 or 0
    props.Radius = skill.Range
    --Inherited properties
    props.SurfaceType = skill.SurfaceType
    props.StatusChance = 1.0
    props.Duration = (math.max(1, skill.SurfaceLifetime)) * 6.0
    if source then
        local sourceObject = GameHelpers.TryGetObject(source)
        if sourceObject then
            props.OwnerHandle = sourceObject.Handle
            props.Position = sourceObject.WorldPos

            if GameHelpers.Ext.ObjectIsCharacter(sourceObject) then
                local b,damageList,deathType = xpcall(Game.Math.GetSkillDamage, debug.traceback, skill, sourceObject.Stats, false, false, props.Position, props.Target, sourceObject.Stats.Level, false)
                if b then
                    if damageList then
                        if props.DamageList == nil then
                            props.DamageList = Ext.NewDamageList()
                        end
                        props.DamageList:Merge(damageList)
                    end
                    props.DeathType = deathType or "Physical"
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
        pcall(TrySetValue, action, k, v)
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

---Returns true if the string is an action "skill" (not actually a skill), such as sneaking or unsheathing.
---@param skill string
---@return boolean
function GameHelpers.Skill.IsAction(skill)
    local t = type(skill)
    if t == "table" then
        for _,v in pairs(skill) do
            if Data.ActionSkills[skill] == true then
                return true
            end
        end
    elseif t == "string" then
        return Data.ActionSkills[skill] == true
    end
    return false
end