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
    NRD_ProjectileSetGuidString("SourcePosition", target)
    NRD_ProjectileSetGuidString("Caster", source)
    NRD_ProjectileSetGuidString("Source", source)
    NRD_ProjectileSetVector3("HitObjectPosition", x,y,z)
    NRD_ProjectileSetVector3("TargetPosition", x,y,z)
    NRD_ProjectileLaunch()
end

Game.ExplodeProjectile = ExplodeProjectile
Game.ExplodeProjectileAtPosition = ExplodeProjectileAtPosition