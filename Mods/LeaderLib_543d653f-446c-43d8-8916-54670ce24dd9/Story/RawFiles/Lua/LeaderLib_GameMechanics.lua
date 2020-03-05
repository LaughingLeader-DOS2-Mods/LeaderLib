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

---Returns true if a hit isn't Dodged, Missed, or Blocked.
---Pass in an object if this is a status.
---@param target string
---@param handle integer
---@param is_hit integer
---@return boolean
local function HitSucceeded(target, handle, is_hit)
    if is_hit ~= 1 then
        return NRD_StatusGetInt(target, handle, "Dodged") == 0 and NRD_StatusGetInt(target, handle, "Missed") == 0 and NRD_StatusGetInt(target, handle, "Blocked") == 0
    else
        return NRD_HitGetInt(handle, "Dodged") == 0 and NRD_HitGetInt(handle, "Missed") == 0 and NRD_HitGetInt(handle, "Blocked") == 0
    end
end

Ext.NewQuery(HitSucceeded, "LeaderLib_Ext_QRY_HitSucceeded", "[in](GUIDSTRING)_Target, [in](INTEGER64)_Handle, [in](INTEGER)_IsHitType, [out](INTEGER)_Bool")

---Returns true if a hit is from a weapon.
---@param target string
---@param handle integer
---@param is_hit integer
---@return boolean
local function HitWithWeapon(target, handle, is_hit)
    local hit_type = -1
    local hitWithWeapon = false
    if is_hit ~= 1 then
        hit_type = NRD_StatusGetInt(target, handle, "HitReason")
        local source_type = NRD_StatusGetInt(target, handle, "DamageSourceType")
        hitWithWeapon = source_type == 6 or source_type == 7
    else
        hit_type = NRD_HitGetInt(handle, "HitType")
        hitWithWeapon = NRD_HitGetInt(handle, "HitWithWeapon") == 1
    end
    return (hit_type == 0 or hit_type == 2 or hit_type == 3) and hitWithWeapon
end

Ext.NewQuery(HitWithWeapon, "LeaderLib_Ext_QRY_HitWithWeapon", "[in](GUIDSTRING)_Target, [in](INTEGER64)_Handle, [in](INTEGER)_IsHitType, [out](INTEGER)_Bool")

---Reduce damage by a percentage (0.5).
---@param target string
---@param attacker string
---@param handlestr string
---@param reduction_str string
---@return boolean
local function ReduceDamage(target, attacker, handlestr, reduction_str)
    if reduction_str == nil then reduction_str = "0.5" end
    local handle = tonumber(handlestr)
    local reduction = tonumber(reduction_str)
	Ext.Print("[LeaderLib_GameMechanics.lua:RedirectDamage] Reducing damage to ("..tostring(reduction_str)..") of total. Handle("..tostring(handlestr).."). Target("..tostring(target)..") Attacker("..tostring(attacker)..")")
	local success = false
    for k,v in pairs(damage_types) do
        local damage = NRD_HitStatusGetDamage(target, handle, v)
        if damage ~= nil and damage > 0 then
            --local reduced_damage = math.max(math.ceil(damage * reduction), 1)
            --NRD_HitStatusClearDamage(target, handle, v)
            local reduced_damage = (damage * reduction) * -1
            NRD_HitStatusAddDamage(target, handle, v, reduced_damage)
			Ext.Print("[LeaderLib_GameMechanics.lua:RedirectDamage] Reduced damage: "..tostring(damage).." => "..tostring(reduced_damage).." for type: "..v)
			success = true
        end
	end
	return success
end

local function IncreaseDamage(target, attacker, handlestr, increase_str)
    if increase_str == nil then increase_str = "0.10" end
    local handle = tonumber(handlestr)
    local increase_amount = tonumber(increase_str)
	Ext.Print("[LeaderLib_GameMechanics.lua:IncreaseDamage] Increasing damage by ("..increase_str.."). Handle("..handlestr.."). Target(",target,") Attacker(",attacker,")")
	local success = false
    for k,v in pairs(damage_types) do
        local damage = NRD_HitStatusGetDamage(target, handle, v)
        if damage ~= nil and damage > 0 then
            --local increased_damage = damage + math.ceil(damage * increase_amount)
            --NRD_HitStatusClearDamage(target, handle, v)
            local increased_damage = math.ceil(damage * increase_amount)
            NRD_HitStatusAddDamage(target, handle, v, increased_damage)
			Ext.Print("[LeaderLib_GameMechanics.lua:IncreaseDamage] Increasing damage: "..tostring(damage).." => "..tostring(increased_damage).." for type: "..v)
			success = true
        end
	end
	return success
end

local function RedirectDamage(blocker, target, attacker, handlestr, reduction_str)
    if reduction_str == nil then reduction_str = "1.0" end
    local handle = tonumber(handlestr)
    local reduction = tonumber(reduction_str)
    --if CanRedirectHit(target, handle, hit_type) then -- Ignore surface, DoT, and reflected damage
    --local hit_type_name = NRD_StatusGetString(target, handle, "DamageSourceType")
    --local hit_type = NRD_StatusGetInt(target, handle, "HitType")
    --Ext.Print("[LeaderLib_GameMechanics.lua:RedirectDamage] Redirecting damage Handle("..handlestr.."). Blocker(",blocker,") Target(",target,") Attacker(",attacker,")")
    local redirected_hit = NRD_HitPrepare(blocker, attacker)
    local damageRedirected = false

    for k,v in pairs(LeaderLib.Data.DamageTypes) do
        local damage = NRD_HitStatusGetDamage(target, handle, v)
        if damage ~= nil and damage > 0 then
            local reduced_damage = math.max(math.ceil(damage * reduction), 1)
            --NRD_HitStatusClearDamage(target, handle, v)
            local removed_damage = damage * -1
            NRD_HitStatusAddDamage(target, handle, v, removed_damage)
            NRD_HitAddDamage(redirected_hit, v, reduced_damage)
            Ext.Print("[LeaderLib_GameMechanics.lua:RedirectDamage] Redirected damage: "..tostring(damage).." => "..tostring(reduced_damage).." for type: "..v)
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

---Get a skill's slot and cooldown, and store it in DB_LeaderLib_Helper_Temp_RefreshUISkill.
---@param char string
---@param skill string
local function StoreSkillData(char, skill)
    local slot = NRD_SkillBarFindSkill(char, skill)
    if slot ~= nil then
        local success,cd = pcall(NRD_SkillGetCooldown, char, skill)
        if success == false or cd == nil then cd = 0.0; end
        cd = math.max(cd, 0.0)
        --Osi.LeaderLib_RefreshUI_Internal_StoreSkillData(char, skill, slot, cd)
        Osi.DB_LeaderLib_Helper_Temp_RefreshUISkill(char, skill, slot, cd)
        NRD_SkillBarClear(char, slot)
        Osi.LeaderLog_Log("DEBUG", "[lua:LeaderLib_RefreshSkill] Refreshing (" .. tostring(skill) ..") for (" .. tostring(char) .. ") [" .. tostring(cd) .. "]")
    end
 end

local function StoreSkillSlots(char)
	-- Until we can fetch the active skill bar, iterate through every skill slot for now
   for i=0,144 do
	   local skill = NRD_SkillBarGetSkill(char, i)
	   if skill ~= nil then
		   local success,cd = pcall(NRD_SkillGetCooldown, char, skill)
		   if success == false or cd == nil then cd = 0.0 end;
		   cd = math.max(cd, 0.0)
		   Osi.LeaderLib_RefreshUI_Internal_StoreSkillData(char, skill, i, cd)
		   Osi.LeaderLog_Log("DEBUG", "[lua:LeaderLib_RefreshSkills] Storing skill slot data (" .. tostring(skill) ..") for (" .. tostring(char) .. ") [" .. tostring(cd) .. "]")
	   end
   end
end

---Sets a skill into an empty slot, or finds empty space.
local function SetSlotToSkill(char, slot, addskill)
    if type(slot) == "string" then
        slot = tonumber(slot)
    end
    local skill = NRD_SkillBarGetSkill(char, slot)
    if skill == nil then
        NRD_SkillBarSetSkill(char, slot, addskill)
        return true
    elseif skill == addskill then
        return true
    else
        local nextslot = slot + 1
        while nextslot < 144 do
            skill = NRD_SkillBarGetSkill(char, nextslot)
            if skill == nil then
                NRD_SkillBarSetSkill(char, slot, addskill)
                return true
            elseif skill == addskill then
                return true
            end
            nextslot = slot + 1
        end
    end
    return false
end

---Clone an item for a character.
---@param char string
---@param item string
---@param completion_event string
---@param autolevel string
local function CloneItemForCharacter(char, item, completion_event, autolevel)
    local autolevel_enabled = autolevel == "Yes"
	NRD_ItemCloneBegin(item)
    local cloned = NRD_ItemClone()
    if autolevel_enabled then
        local level = CharacterGetLevel(char)
        ItemLevelUpTo(cloned,level)
    end
    CharacterItemSetEvent(char, cloned, completion_event)
end

---Clone an item for a character.
---@param stat string
---@param level integer
---@return string
local function CreateItemByStat(stat, level)
    local x,y,z = GetPosition(CharacterGetHostCharacter())
    local item = CreateItemTemplateAtPosition("LOOT_LeaderLib_BackPack_Invisible_98fa7688-0810-4113-ba94-9a8c8463f830",x,y,z)
    NRD_ItemCloneBegin(item)
    NRD_ItemCloneSetString("GenerationStatsId", stat)
    NRD_ItemCloneSetString("StatsEntryName", stat)
    NRD_ItemCloneSetInt("HasGeneratedStats", 0)
    NRD_ItemCloneSetInt("StatsLevel", level)
    --NRD_ItemCloneResetProgression()
    local cloned NRD_ItemClone()
    ItemLevelUpTo(cloned,level)
    return cloned
end

LeaderLib.Game = {
	ReduceDamage = ReduceDamage,
	IncreaseDamage = IncreaseDamage,
    HitSucceeded = HitSucceeded,
	RedirectDamage = RedirectDamage,
    StoreSkillData = StoreSkillData,
    StoreSkillSlots = StoreSkillSlots,
    SetSlotToSkill = SetSlotToSkill,
    CloneItemForCharacter = CloneItemForCharacter,
}

LeaderLib.Register.Table(LeaderLib.Game);