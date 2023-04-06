---@param source string
---@param target string|number[]
---@param skill string
---@param forceHit boolean|nil
---@param sourcePosition number[]|nil
---@param hitObject string
---@param canDeflect boolean
function GameHelpers.ShootProjectile(source, target, skill, forceHit, sourcePosition, hitObject, canDeflect)
    Osi.NRD_ProjectilePrepareLaunch()
    Osi.NRD_ProjectileSetString("SkillId", skill)
    Osi.NRD_ProjectileSetInt("CanDeflect", canDeflect == true and 1 or 0)
    local level = 1
    if Osi.ObjectIsCharacter(source) == 1 then
        level = Osi.CharacterGetLevel(source)
    else
        level = GameHelpers.GetItem(source).Stats.Level
    end
    Osi.NRD_ProjectileSetInt("CasterLevel", level)

    Osi.NRD_ProjectileSetGuidString("Caster", source)
    Osi.NRD_ProjectileSetGuidString("Source", source)

    local x,y,z = Osi.GetPosition(source)
    if sourcePosition == nil then
        Osi.NRD_ProjectileSetVector3("SourcePosition", x,y+2,z)
    else
        Osi.NRD_ProjectileSetVector3("SourcePosition", sourcePosition[1],sourcePosition[2],sourcePosition[3])
    end

    if type(target) == "string" then
        if forceHit == true then
            if hitObject ~= nil then
                Osi.NRD_ProjectileSetGuidString("HitObject", hitObject)
                Osi.NRD_ProjectileSetGuidString("HitObjectPosition", hitObject)
            else
                Osi.NRD_ProjectileSetGuidString("HitObject", target)
                Osi.NRD_ProjectileSetGuidString("HitObjectPosition", target)
            end
        end
        Osi.NRD_ProjectileSetGuidString("TargetPosition", target)
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
            if hitObject ~= nil then
                Osi.NRD_ProjectileSetGuidString("HitObject", hitObject)
                Osi.NRD_ProjectileSetGuidString("HitObjectPosition", hitObject)
                --NRD_ProjectileSetVector3("HitObjectPosition", tx,ty,tz)
            else
                Osi.NRD_ProjectileSetVector3("HitObjectPosition", tx,ty,tz)
            end
        end
        Osi.NRD_ProjectileSetVector3("TargetPosition", tx,ty,tz)
    end
    Osi.NRD_ProjectileLaunch()
end

---@param source string
---@param x number
---@param y number
---@param z number
---@param skill string
---@param forceHit boolean|nil
---@param canDeflect boolean
function GameHelpers.ShootProjectileAtPosition(source, x, y, z, skill, forceHit, canDeflect)
    GameHelpers.ShootProjectile(source, {x,y,z}, skill, forceHit, nil, nil, canDeflect)
end

---@see GameHelpers.Skill.Explode
function GameHelpers.ExplodeProjectile(source, target, skill, skillLevel, noForcedHit)
    Osi.NRD_ProjectilePrepareLaunch()
    Osi.NRD_ProjectileSetString("SkillId", skill)
    Osi.NRD_ProjectileSetInt("CanDeflect", 0)
    
    local level = skillLevel
    if source ~= nil then
        Osi.NRD_ProjectileSetGuidString("Caster", source)
        Osi.NRD_ProjectileSetGuidString("Source", source)

        if level == nil then
            if Osi.ObjectIsCharacter(source) == 1 then
                level = Osi.CharacterGetLevel(source)
            else
                local item = GameHelpers.GetItem(source)
                if item ~= nil and item.Stats ~= nil then
                    level = item.Stats.Level
                end
            end
        end
    end

    if level == nil and type(target) == "string" and Osi.ObjectIsCharacter(target) == 1 then
        level = Osi.CharacterGetLevel(target)
    end
    if level == nil then level = 1 end
    Osi.NRD_ProjectileSetInt("CasterLevel", level)

    if type(target) == "string" then
        Osi.NRD_ProjectileSetGuidString("SourcePosition", target)
        if noForcedHit ~= true then
            Osi.NRD_ProjectileSetGuidString("HitObject", target)
            Osi.NRD_ProjectileSetGuidString("HitObjectPosition", target)
        end
        Osi.NRD_ProjectileSetGuidString("TargetPosition", target)
    elseif type(target) == "table" then
        -- Exploding at a position
        local x,y,z = 0,0,0
        if source ~= nil then
            x,y,z = Osi.GetPosition(source)
        end

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
        Osi.NRD_ProjectileSetVector3("SourcePosition", tx,ty,tz)
        Osi.NRD_ProjectileSetVector3("TargetPosition", tx,ty,tz)
        Osi.NRD_ProjectileSetVector3("HitObjectPosition", tx,ty,tz)
        --print(string.format("Mods.LeaderLib.GameHelpers.ExplodeProjectile(\"%s\", {%s,%s,%s}, \"%s\", %s)", source, tx,ty,tz, skill, level))
    end
    Osi.NRD_ProjectileLaunch()
end