local function ShootProjectile(source, target, skill, forceHit)
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
    if forceHit == true then
        NRD_ProjectileSetGuidString("SourcePosition", source)
        NRD_ProjectileSetGuidString("HitObject", target)
        NRD_ProjectileSetGuidString("HitObjectPosition", target)
    else
        local x,y,z = GetPosition(source)
        NRD_ProjectileSetVector3("SourcePosition", x,y+2,z)
    end
    NRD_ProjectileSetGuidString("TargetPosition", target)
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
    NRD_ProjectileSetGuidString("SourcePosition", target)
    NRD_ProjectileSetGuidString("Caster", source)
    NRD_ProjectileSetGuidString("Source", source)
    NRD_ProjectileSetGuidString("HitObject", target)
    NRD_ProjectileSetGuidString("HitObjectPosition", target)
    NRD_ProjectileSetGuidString("TargetPosition", target)
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