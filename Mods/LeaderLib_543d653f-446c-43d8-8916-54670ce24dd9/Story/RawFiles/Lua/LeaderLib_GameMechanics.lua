local damage_types = {
    "None",
    "Physical",
    "Piercing",
    "Corrosive",
    "Magic",
    "Chaos",
    "Fire",
    "Air",
    "Water",
    "Earth",
    "Poison",
    "Shadow"
}

LeaderLib.Data["DamageTypes"] = damage_types

local function ReduceDamage(target, attacker, handlestr, reduction_str)
    local handle = tonumber(handlestr)
    local reduction = tonumber(reduction_str)
	Ext.Print("[LeaderLib_GameMechanics.lua:RedirectDamage] Reducing damage to ("..reduction_str..") of total. Handle("..handlestr.."). Target(",target,") Attacker(",attacker,")")
	local success = false
    for k,v in pairs(damage_types) do
        local damage = NRD_HitStatusGetDamage(target, handle, v)
        if damage ~= nil and damage > 0 then
            local reduced_damage = math.max(math.ceil(damage * reduction), 1)
            NRD_HitStatusClearDamage(target, handle, v)
            NRD_HitStatusAddDamage(target, handle, v, reduced_damage)
			Ext.Print("[LeaderLib_GameMechanics.lua:RedirectDamage] Reduced damage: "..tostring(damage).." => "..tostring(reduced_damage).." for type: "..v)
			success = true
        end
	end
	return success
end

local function RedirectDamage(blocker, target, attacker, handlestr, reduction_str)
    local handle = tonumber(handlestr)
    local reduction = tonumber(reduction_str)
    --if CanRedirectHit(target, handle, hit_type) then -- Ignore surface, DoT, and reflected damage
    local hit_type_name = NRD_StatusGetString(target, handle, "DamageSourceType")
    --local hit_type = NRD_StatusGetInt(target, handle, "HitType")
    Ext.Print("[LeaderLib_GameMechanics.lua:RedirectDamage] Redirecting damage Handle("..handlestr.."). Blocker(",blocker,") Target(",target,") Attacker(",attacker,")")
    local redirected_hit = NRD_HitPrepare(blocker, attacker)
    local damageRedirected = false

    for k,v in pairs(_G["LeaderLib"].Data["DamageTypes"]) do
        local damage = NRD_HitStatusGetDamage(target, handle, v)
        if damage ~= nil and damage > 0 then
            local reduced_damage = math.max(math.ceil(damage * reduction), 1)
            NRD_HitStatusClearDamage(target, handle, v)
            NRD_HitStatusAddDamage(target, handle, v, reduced_damage)
            NRD_HitAddDamage(redirected_hit, v, reduced_damage)
            Ext.Print("Redirected damage: "..tostring(damage).." => "..tostring(reduced_damage).." for type: "..v)
            damageRedirected = true
        end
    end

    if damageRedirected then
        local is_crit = NRD_StatusGetInt(target, handle, "CriticalHit") == 1
        if is_crit then
            NRD_HitSetInt(redirected_hit, "CriticalRoll", 1);
        else
            NRD_HitSetInt(redirected_hit, "CriticalRoll", 2);
        end
        NRD_HitSetInt(redirected_hit, "SimulateHit", 1);
        NRD_HitSetInt(redirected_hit, "HitType", 6);
        NRD_HitSetInt(redirected_hit, "Hit", 1);
        NRD_HitSetInt(redirected_hit, "RollForDamage", 1);
        NRD_HitExecute(redirected_hit);
	end
	return damageRedirected;
end

local function RefreshSkills(char)
	-- Until we can fetch the active skill bar, iterate through every skill slot for now
   for i=0,144 do
	   local skill = NRD_SkillBarGetSkill(char, i)
	   if skill ~= nil then
		   local success,cd = pcall(NRD_SkillGetCooldown, char, skill)
		   if success == false then cd = 0.0 end;
		   cd = math.max(cd, 0.0)
		   Osi.LeaderLib_RefreshUI_Internal_StoreSkillData(char, skill, i, cd)
		   Osi.LeaderLog_Log("DEBUG", "[lua:LeaderLib_RefreshSkills] Refreshing (" .. tostring(skill) ..") for (" .. tostring(char) .. ") [" .. tostring(cd) .. "]")
	   end
   end
   Osi.LeaderLib_Timers_StartObjectTimer(char, 60, "Timers_LeaderLib_RefreshUI_RevertSkillCooldown", "LeaderLib_RefreshUI_RevertSkillCooldown");
end

local function RefreshSkill(char, skill)
   local slot = NRD_SkillBarFindSkill(char, skill)
   if slot ~= nil then
	   local cd = pcall(NRD_SkillGetCooldown, char, skill)
	   if cd == nil then cd = 0 end
	   cd = math.max(cd, 0)
	   Osi.LeaderLib_RefreshUI_Internal_StoreSkillData(char, skill, slot, cd)
	   Osi.LeaderLog_Log("DEBUG", "[lua:LeaderLib_RefreshSkill] Refreshing (" .. tostring(skill) ..") for (" .. tostring(char) .. ") [" .. tostring(cd) .. "]")
   end
   Osi.LeaderLib_Timers_StartObjectTimer(char, 60, "Timers_LeaderLib_RefreshUI_RevertSkillCooldownDirect", "LeaderLib_RefreshUI_RevertSkillCooldown");
end

LeaderLib.Game = {
	ReduceDamage = ReduceDamage,
	RedirectDamage = RedirectDamage,
	RefreshSkills = RefreshSkills,
	RefreshSkill = RefreshSkill,
}

LeaderLib.Register.Table(LeaderLib.Game);