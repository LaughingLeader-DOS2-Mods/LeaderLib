local function ShootProjectile(source, target, skill, forceHit, sourcePosition)
    local level = 1
    if ObjectIsCharacter(source) == 1 then
        level = CharacterGetLevel(source)
    else
        SetStoryEvent(source, "LeaderLib_Commands_SetItemLevel")
        level = GetVarInteger(source, "LeaderLib_Level")
    end
    NRD_ProjectilePrepareLaunch()
    NRD_ProjectileSetString("SkillId", skill)
    NRD_ProjectileSetInt("CasterLevel", level)

    NRD_ProjectileSetGuidString("Caster", source)
    NRD_ProjectileSetGuidString("Source", source)
    local x,y,z = GetPosition(source)
    if sourcePosition == nil then
        NRD_ProjectileSetVector3("SourcePosition", x,y+2,z)
    else
        NRD_ProjectileSetVector3("SourcePosition", sourcePosition[1],sourcePosition[2],sourcePosition[3])
    end
    if type(target) == "string" then
        if forceHit == true then
            NRD_ProjectileSetGuidString("HitObject", target)
            NRD_ProjectileSetGuidString("HitObjectPosition", target)
        end
        NRD_ProjectileSetGuidString("TargetPosition", target)
    elseif type(target) == "table" then
        local tx,ty,tz = table.unpack(target)
        if tx == nil then
            tx = x
        end
        if ty == nil then
            ty = y
        end
        if tz == nil then
            tz = z
        end
        if forceHit == true then
            NRD_ProjectileSetVector3("HitObjectPosition", tx,ty,tz)
        end
        NRD_ProjectileSetVector3("TargetPosition", tx,ty,tz)
    end
    NRD_ProjectileLaunch()
end
GameHelpers.ShootProjectile = ShootProjectile

local function ShootProjectileAtPosition(source, tx, ty, tz, skill, forceHit)
    local level = 1
    if ObjectIsCharacter(source) == 1 then
        level = CharacterGetLevel(source)
    else
        SetStoryEvent(source, "LeaderLib_Commands_SetItemLevel")
        level = GetVarInteger(source, "LeaderLib_Level")
    end
    NRD_ProjectilePrepareLaunch()
    NRD_ProjectileSetString("SkillId", skill)
    NRD_ProjectileSetInt("CasterLevel", level)

    NRD_ProjectileSetGuidString("Caster", source)
    NRD_ProjectileSetGuidString("Source", source)
    NRD_ProjectileSetVector3("TargetPosition", tx,ty,tz)

    if forceHit == true then
        NRD_ProjectileSetGuidString("SourcePosition", source)
        NRD_ProjectileSetVector3("HitObjectPosition", tx,ty,tz)
    else
        local x,y,z = GetPosition(source)
        NRD_ProjectileSetVector3("SourcePosition", x,y+2,z)
    end
    NRD_ProjectileLaunch()
end
GameHelpers.ShootProjectileAtPosition = ShootProjectileAtPosition

local function ExplodeProjectile(source, target, skill)
    local level = 1
    if ObjectIsCharacter(source) == 1 then
        level = CharacterGetLevel(source)
    else
        SetStoryEvent(source, "LeaderLib_Commands_SetItemLevel")
        level = GetVarInteger(source, "LeaderLib_Level")
    end
    NRD_ProjectilePrepareLaunch()
    NRD_ProjectileSetString("SkillId", skill)
    NRD_ProjectileSetInt("CasterLevel", level)
    NRD_ProjectileSetGuidString("Caster", source)
    NRD_ProjectileSetGuidString("Source", source)

    if type(target) == "string" then
        NRD_ProjectileSetGuidString("SourcePosition", target)
        NRD_ProjectileSetGuidString("HitObject", target)
        NRD_ProjectileSetGuidString("HitObjectPosition", target)
        NRD_ProjectileSetGuidString("TargetPosition", target)
    elseif type(target) == "table" then
        local x,y,z = GetPosition(source)
        local tx,ty,tz = table.unpack(target)
        if tx == nil then
            tx = x
        end
        if ty == nil then
            ty = y
        end
        if tz == nil then
            tz = z
        end
        NRD_ProjectileSetVector3("SourcePosition", tx,ty,tz)
        NRD_ProjectileSetVector3("HitObjectPosition", tx,ty,tz)
        NRD_ProjectileSetVector3("TargetPosition", tx,ty,tz)
    end
    NRD_ProjectileLaunch()
end
GameHelpers.ExplodeProjectile = ExplodeProjectile
--Ext.NewCall(ExplodeProjectile, "LeaderLib_Ext_ExplodeProjectile", "(GUIDSTRING)_Source, (GUIDSTRING)_Target, (STRING)_Skill")

local function ExplodeProjectileAtPosition(source, skill, x, y, z)
    local level = 1
    if ObjectIsCharacter(source) == 1 then
        level = CharacterGetLevel(source)
    else
        SetStoryEvent(source, "LeaderLib_Commands_SetItemLevel")
        level = GetVarInteger(source, "LeaderLib_Level")
    end
    NRD_ProjectilePrepareLaunch()
    NRD_ProjectileSetString("SkillId", skill)
    NRD_ProjectileSetInt("CasterLevel", level)
    NRD_ProjectileSetGuidString("SourcePosition", source)
    NRD_ProjectileSetGuidString("Caster", source)
    NRD_ProjectileSetGuidString("Source", source)
    NRD_ProjectileSetVector3("HitObjectPosition", x,y,z)
    NRD_ProjectileSetVector3("TargetPosition", x,y,z)
    NRD_ProjectileLaunch()
end
GameHelpers.ExplodeProjectileAtPosition = ExplodeProjectileAtPosition

local function GetForwardPosition(source, distanceMult)
    local x,y,z = GetPosition(source)
    local character = Ext.GetCharacter(source)
    if character ~= nil then
        if distanceMult == nil then
            distanceMult = 1.0
        end
        local forwardVector = {
            -character.Stats.Rotation[7] * distanceMult,
            0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
            -character.Stats.Rotation[9] * distanceMult,
        }
        x = character.Stats.Position[1] + forwardVector[1]
        z = character.Stats.Position[3] + forwardVector[3]
    end
    return {x,y,z}
end
GameHelpers.GetForwardPosition = GetForwardPosition

local function ExtendPositionWithForwardDirection(source, distanceMult, x,y,z)
    local character = Ext.GetCharacter(source)
    if character ~= nil then
        if distanceMult == nil then
            distanceMult = 1.0
        end
        local forwardVector = {
            -character.Stats.Rotation[7] * distanceMult,
            0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
            -character.Stats.Rotation[9] * distanceMult,
        }
        x = x + forwardVector[1]
        z = z + forwardVector[3]
    end
    return {x,y,z}
end
GameHelpers.ExtendPositionWithForward = ExtendPositionWithForwardDirection