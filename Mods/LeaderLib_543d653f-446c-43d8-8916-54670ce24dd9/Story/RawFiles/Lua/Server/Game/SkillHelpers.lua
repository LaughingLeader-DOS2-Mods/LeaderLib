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
local function TrySetSkillSlot(char, slot, addskill)
    if type(slot) == "string" then
        slot = math.tointeger(slot)
    end
    if slot == nil or slot < 0 then slot = 0 end
    local skill = NRD_SkillBarGetSkill(char, slot)
    if skill == nil then
        NRD_SkillBarSetSkill(char, slot, addskill)
        return true
    elseif skill == addskill then
        return true
    else
        local maxslots = 144 - slot
        local nextslot = slot + 1
        while nextslot < maxslots do
            skill = NRD_SkillBarGetSkill(char, nextslot)
            if skill == nil then
                NRD_SkillBarSetSkill(char, slot, addskill)
                return true
            elseif skill == addskill then
                return true
            end
            nextslot = nextslot + 1
        end
    end
    return false
end
Ext.NewCall(TrySetSkillSlot, "LeaderLib_Ext_TrySetSkillSlot", "(CHARACTERGUID)_Character, (INTEGER)_Slot, (STRING)_Skill")

---Refreshes a skill if the character has it.
local function RefreshSkill(char, skill)
    if CharacterHasSkill(char, skill) == 1 then
        NRD_SkillSetCooldown(skill, 0.0)
    end
end
Ext.NewCall(RefreshSkill, "LeaderLib_Ext_RefreshSkill", "(CHARACTERGUID)_Character, (STRING)_Skill")

GameHelpers.StoreSkillData = StoreSkillData
GameHelpers.StoreSkillSlots = StoreSkillSlots
GameHelpers.TrySetSkillSlot = TrySetSkillSlot
GameHelpers.RefreshSkill = RefreshSkill