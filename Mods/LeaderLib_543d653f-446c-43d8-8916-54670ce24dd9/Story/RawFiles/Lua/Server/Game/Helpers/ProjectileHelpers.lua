---@param source string
---@param target string|number[]
---@param skill string
---@param forceHit boolean|nil
---@param sourcePosition number[]|nil
---@param hitObject string
---@param canDeflect boolean
function GameHelpers.ShootProjectile(source, target, skill, forceHit, sourcePosition, hitObject, canDeflect)
    NRD_ProjectilePrepareLaunch()
    NRD_ProjectileSetString("SkillId", skill)
    NRD_ProjectileSetInt("CanDeflect", canDeflect == true and 1 or 0)
    local level = 1
    if ObjectIsCharacter(source) == 1 then
        level = CharacterGetLevel(source)
    else
        level = Ext.GetItem(source).Stats.Level
    end
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
            if hitObject ~= nil then
                NRD_ProjectileSetGuidString("HitObject", hitObject)
                NRD_ProjectileSetGuidString("HitObjectPosition", hitObject)
            else
                NRD_ProjectileSetGuidString("HitObject", target)
                NRD_ProjectileSetGuidString("HitObjectPosition", target)
            end
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
            if hitObject ~= nil then
                NRD_ProjectileSetGuidString("HitObject", hitObject)
                NRD_ProjectileSetGuidString("HitObjectPosition", hitObject)
                --NRD_ProjectileSetVector3("HitObjectPosition", tx,ty,tz)
            else
                NRD_ProjectileSetVector3("HitObjectPosition", tx,ty,tz)
            end
        end
        NRD_ProjectileSetVector3("TargetPosition", tx,ty,tz)
    end
    NRD_ProjectileLaunch()
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
    NRD_ProjectilePrepareLaunch()
    NRD_ProjectileSetString("SkillId", skill)
    NRD_ProjectileSetInt("CanDeflect", 0)
    
    local level = skillLevel
    if source ~= nil then
        NRD_ProjectileSetGuidString("Caster", source)
        NRD_ProjectileSetGuidString("Source", source)

        if level == nil then
            if ObjectIsCharacter(source) == 1 then
                level = CharacterGetLevel(source)
            else
                local item = Ext.GetItem(source)
                if item ~= nil and item.Stats ~= nil then
                    level = item.Stats.Level
                end
            end
        end
    end

    if level == nil and type(target) == "string" and ObjectIsCharacter(target) == 1 then
        level = CharacterGetLevel(target)
    end
    if level == nil then level = 1 end
    NRD_ProjectileSetInt("CasterLevel", level)

    if type(target) == "string" then
        NRD_ProjectileSetGuidString("SourcePosition", target)
        if noForcedHit ~= true then
            NRD_ProjectileSetGuidString("HitObject", target)
            NRD_ProjectileSetGuidString("HitObjectPosition", target)
        end
        NRD_ProjectileSetGuidString("TargetPosition", target)
    elseif type(target) == "table" then
        -- Exploding at a position
        local x,y,z = 0,0,0
        if source ~= nil then
            x,y,z = GetPosition(source)
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
        NRD_ProjectileSetVector3("SourcePosition", tx,ty,tz)
        NRD_ProjectileSetVector3("TargetPosition", tx,ty,tz)
        NRD_ProjectileSetVector3("HitObjectPosition", tx,ty,tz)
        --print(string.format("Mods.LeaderLib.GameHelpers.ExplodeProjectile(\"%s\", {%s,%s,%s}, \"%s\", %s)", source, tx,ty,tz, skill, level))
    end
    NRD_ProjectileLaunch()
end