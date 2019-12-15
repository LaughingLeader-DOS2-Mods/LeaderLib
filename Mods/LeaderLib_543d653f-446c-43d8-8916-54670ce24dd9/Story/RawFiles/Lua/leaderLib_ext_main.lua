local function table_has_index(tbl, index)
	if #tbl > index then
		if tbl[index] ~= nil then
            return true
        end
	end
    return false
end

local function process_version_str(version_str)
	local a,b,c,d = -1
	vals = {}
	for s in string.gmatch(version_str, "([^.]+)") do
		table.insert(vals, tonumber(s))
	end
	for k,v in pairs(vals) do
		if k == 1 then
			a = v
		elseif k == 2 then
			b = v
		elseif k == 3 then
			c = v
		elseif k == 4 then
			d = v
			break
		end
	end
	return a,b,c,d
end

--Added a lua->Osiris query
local function StringToVersion_Query(version_str)
	local b, major,minor,revision,build = pcall(process_version_str, version_str)
	if b then
		if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
			--Osi.LeaderLib_StringExt_SetVersionFromString(version_str,major,minor,revision,build)
			return major,minor,revision,build
		else
			error(version_str .. " is not a valid version string!")
		end
	else
		error("Failed to process '"..version_str.."' - function process_version_str has an error.")
	end
end

local function StringToVersion(version_str)
	local b, major,minor,revision,build = pcall(process_version_str, version_str)
	if b then
		if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
			Osi.LeaderLib_StringExt_SetVersionFromString(version_str,major,minor,revision,build)
		else
			error(version_str .. " is not a valid version string!")
		end
	else
		error("Failed to process '"..version_str.."' - function process_version_str has an error.")
	end
end

local function PrintAttributes(char)
	local attributes = {"Strength", "Finesse", "Intelligence", "Constitution", "Memory", "Wits"}
	for k, att in pairs(attributes) do
		local val = CharacterGetAttribute(char, att)
		Osi.LeaderLog_Log("DEBUG", "[lua:leaderlib.PrintAttributes] (" .. char .. ") | " .. att .. " = " .. val)
	end
end

local function PrintTest(str)
	DebugBreak("[LeaderLib:Lua:PrintTest] " .. str)
end

local function LeaderLib_RefreshSkills(char)
	 -- Until we can fetch the active skill bar, iterate through every skill slot for now
	for i=0,144 do
		local skill = NRD_SkillBarGetSkill(char, i)
		if skill ~= nil then
			local cd = NRD_SkillGetCooldown(char, skill)
			Osi.LeaderLib_RefreshUI_Internal_StoreSkillData(char, skill, i, cd)
			Osi.LeaderLog_Log("DEBUG", "[lua:LeaderLib_RefreshSkills] Refreshing (" .. skill ..") for (" .. char .. ") [" .. cd .. "]")
		end
	end
	Osi.LeaderLib_Timers_StartObjectTimer(char, 60, "Timers_LeaderLib_RefreshUI_RevertSkillCooldown", "LeaderLib_RefreshUI_RevertSkillCooldown");
end

local function RefreshSkills(char)
	 -- Until we can fetch the active skill bar, iterate through every skill slot for now
	for i=0,144 do
		local skill = NRD_SkillBarGetSkill(char, i)
		if skill ~= nil then
			local cd = NRD_SkillGetCooldown(char, skill)
			Osi.LeaderLib_RefreshUI_Internal_StoreSkillData(char, skill, i, cd)
			Osi.LeaderLog_Log("DEBUG", "[lua:LeaderLib_RefreshSkills] Refreshing (" .. skill ..") for (" .. char .. ") [" .. cd .. "]")
		end
	end
	Osi.LeaderLib_Timers_StartObjectTimer(char, 60, "Timers_LeaderLib_RefreshUI_RevertSkillCooldown", "LeaderLib_RefreshUI_RevertSkillCooldown");
end

local function RefreshSkill(char, skill)
	local slot = NRD_SkillBarFindSkill(char, skill)
	if slot ~= nil then
		local cd = NRD_SkillGetCooldown(char, skill)
		Osi.LeaderLib_RefreshUI_Internal_StoreSkillData(char, skill, slot, cd)
		Osi.LeaderLog_Log("DEBUG", "[lua:LeaderLib_RefreshSkill] Refreshing (" .. skill ..") for (" .. char .. ") [" .. cd .. "]")
	end
	Osi.LeaderLib_Timers_StartObjectTimer(char, 60, "Timers_LeaderLib_RefreshUI_RevertSkillCooldownDirect", "LeaderLib_RefreshUI_RevertSkillCooldown");
end

LeaderLib = {
	StringToVersion_Query = StringToVersion_Query,
	StringToVersion = StringToVersion,
	PrintAttributes = PrintAttributes,
	PrintTest = PrintTest,
	RefreshSkills = RefreshSkills,
	RefreshSkill = RefreshSkill,
	SkillMemorizationFix = SkillMemorizationFix
}

--Export local functions to global for now
for name,func in pairs(LeaderLib) do
    _G["LeaderLib_" .. name] = func
end