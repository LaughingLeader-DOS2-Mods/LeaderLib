---Reduce damage by a percentage (ex. 0.5)
---@param target string
---@param attacker string
---@param handle_param integer
---@param reduction_perc number
---@param is_hit_param integer
---@return boolean
local function ReduceDamage(target, attacker, handle_param, reduction_perc, is_hit_param)
    local handle = Common.SafeguardParam(handle_param, "integer", nil)
    if handle == nil then error("[LeaderLib_GameMechanics.lua:ReduceDamage] Handle is null! Skipping.") end
    local reduction = Common.SafeguardParam(reduction_perc, "number", 0.5)
    local is_hit = Common.SafeguardParam(is_hit_param, "integer", 0)
	PrintDebug("[LeaderLib_GameMechanics.lua:ReduceDamage] Reducing damage to ("..tostring(reduction)..") of total. Handle("..tostring(handle).."). Target("..tostring(target)..") Attacker("..tostring(attacker)..") IsHit("..tostring(is_hit)..")")
	local success = false
    for k,v in pairs(Data.DamageTypes) do
        local damage = nil
        if is_hit == 0 then
            damage = NRD_HitStatusGetDamage(target, handle, v)
        else
            damage = NRD_HitGetDamage(handle, v)
        end
        if damage ~= nil and damage > 0 then
            --local reduced_damage = math.max(math.ceil(damage * reduction), 1)
            --NRD_HitStatusClearDamage(target, handle, v)
            local reduced_damage = (damage * reduction) * -1
            if is_hit == 0 then
                NRD_HitStatusAddDamage(target, handle, v, reduced_damage)
            else
                NRD_HitAddDamage(handle, v, reduced_damage)
            end
			Log("[LeaderLib_GameMechanics.lua:ReduceDamage] Reduced damage: "..tostring(damage).." => "..tostring(reduced_damage).." for type: "..v)
			success = true
        end
	end
	return success
end

Ext.NewCall(ReduceDamage, "LeaderLib_Hit_ReduceDamage", "(GUIDSTRING)_Target, (GUIDSTRING)_Attacker, (INTEGER64)_Handle, (REAL)_Percentage, (INTEGER)_IsHitHandle")
Game.ReduceDamage = ReduceDamage

---Increase damage by a percentage (0.5).
---@param target string
---@param attacker string
---@param handle_param integer
---@param increase_perc number
---@param is_hit_param integer
---@return boolean
local function IncreaseDamage(target, attacker, handle_param, increase_perc, is_hit_param)
    local handle = Common.SafeguardParam(handle_param, "number", nil)
    if handle == nil then error("[LeaderLib_GameMechanics.lua:IncreaseDamage] Handle is null! Skipping.") end
    local increase_amount = Common.SafeguardParam(increase_perc, "number", 0.5)
    local is_hit = Common.SafeguardParam(is_hit_param, "number", 0)
	Log("[LeaderLib_GameMechanics.lua:IncreaseDamage] Increasing damage by ("..tostring(increase_amount).."). Handle("..tostring(handle).."). Target("..tostring(target)..") Attacker("..tostring(attacker)..") IsHit("..tostring(is_hit)..")")
	local success = false
    for k,v in pairs(Data.DamageTypes) do
        local damage = nil
        if is_hit == 0 then
            damage = NRD_HitStatusGetDamage(target, handle, v)
        else
            damage = NRD_HitGetDamage(handle, v)
        end
        if damage ~= nil and damage > 0 then
            --local increased_damage = damage + math.ceil(damage * increase_amount)
            --NRD_HitStatusClearDamage(target, handle, v)
            local increased_damage = math.ceil(damage * increase_amount)
            if is_hit == 0 then
                NRD_HitStatusAddDamage(target, handle, v, increased_damage)
            else
                NRD_HitAddDamage(handle, v, increased_damage)
            end
			Log("[LeaderLib_GameMechanics.lua:IncreaseDamage] Increasing damage: "..tostring(damage).." => "..tostring(damage + increased_damage).." for type: "..v)
			success = true
        end
	end
	return success
end

Ext.NewCall(IncreaseDamage, "LeaderLib_Hit_IncreaseDamage", "(GUIDSTRING)_Target, (GUIDSTRING)_Attacker, (INTEGER64)_Handle, (REAL)_Percentage, (INTEGER)_IsHitHandle")
Game.IncreaseDamage = IncreaseDamage

---Redirect damage to another target.
---@param target string
---@param defender string
---@param attacker string
---@param handle_param integer
---@param reduction_perc number
---@param is_hit_param integer
---@return boolean
local function RedirectDamage(target, defender, attacker, handle_param, reduction_perc, is_hit_param)
    local handle = Common.SafeguardParam(handle_param, "integer", nil)
    if handle == nil then error("[LeaderLib_GameMechanics.lua:RedirectDamage] Handle is null! Skipping.") end
    local reduction = Common.SafeguardParam(reduction_perc, "number", 0.5)
    local is_hit = Common.SafeguardParam(is_hit_param, "integer", 0)
	Log("[LeaderLib_GameMechanics.lua:RedirectDamage] Reducing damage to ("..tostring(reduction)..") of total. Handle("..tostring(handle).."). Target("..tostring(target)..") Defender("..tostring(defender)..") Attacker("..tostring(attacker)..") IsHit("..tostring(is_hit)..")")
    --if CanRedirectHit(defender, handle, hit_type) then -- Ignore surface, DoT, and reflected damage
    --local hit_type_name = NRD_StatusGetString(defender, handle, "DamageSourceType")
    --local hit_type = NRD_StatusGetInt(defender, handle, "HitType")
    --Log("[LeaderLib_GameMechanics.lua:RedirectDamage] Redirecting damage Handle("..handlestr.."). Blocker(",target,") Target(",defender,") Attacker(",attacker,")")
    local redirected_hit = NRD_HitPrepare(target, attacker)
    local damageRedirected = false

    for k,v in pairs(Data.DamageTypes) do
        local damage = nil
        if is_hit == 0 then
            damage = NRD_HitStatusGetDamage(defender, handle, v)
        else
            damage = NRD_HitGetDamage(handle, v)
        end
        if damage ~= nil and damage > 0 then
            local reduced_damage = math.max(math.ceil(damage * reduction), 1)
            --NRD_HitStatusClearDamage(defender, handle, v)
            local removed_damage = damage * -1
            if is_hit == 0 then
                NRD_HitStatusAddDamage(defender, handle, v, removed_damage)
            else
                NRD_HitAddDamage(handle, v, removed_damage)
            end
            NRD_HitAddDamage(redirected_hit, v, reduced_damage)
            Log("[LeaderLib_GameMechanics.lua:RedirectDamage] Redirected damage: "..tostring(damage).." => "..tostring(reduced_damage).." for type: "..v)
            damageRedirected = true
        end
    end

    if damageRedirected then
        local is_crit = 0
        if is_hit == 0 then
            is_crit = NRD_StatusGetInt(defender, handle, "CriticalHit") == 1
        else
            is_crit = NRD_HitGetInt(handle, "CriticalHit") == 1
        end
        if is_crit then
            NRD_HitSetInt(redirected_hit, "CriticalRoll", 1);
        else
            NRD_HitSetInt(redirected_hit, "CriticalRoll", 2);
        end
        NRD_HitSetInt(redirected_hit, "SimulateHit", 1);
        NRD_HitSetInt(redirected_hit, "HitType", 6);
        NRD_HitSetInt(redirected_hit, "Hit", 1);
        NRD_HitSetInt(redirected_hit, "NoHitRoll", 1);
        NRD_HitExecute(redirected_hit);
	end
	return damageRedirected;
end

Ext.NewCall(RedirectDamage, "LeaderLib_Hit_RedirectDamage", "(GUIDSTRING)_Target, (GUIDSTRING)_Defender, (GUIDSTRING)_Attacker, (INTEGER64)_Handle, (REAL)_Percentage, (INTEGER)_IsHitHandle")

Game.RedirectDamage = RedirectDamage