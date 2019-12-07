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

local function string_to_version(version_str)
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

function LeaderLib_Ext_StringToVersion(version_str)
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

local function print_attributes(char)
	local attributes = {"Strength", "Finesse", "Intelligence", "Constitution", "Memory", "Wits"}
	for k, att in pairs(attributes) do
		local val = CharacterGetAttribute(char, att)
		Osi.LeaderLog_Log("DEBUG", "[lua:leaderlib.print_attributes] (" .. char .. ") | " .. att .. " = " .. val)
	end
end

local function print_test(str)
	DebugBreak("[LeaderLib:Lua:print_test] " .. str)
end

Leaderlib = {
	string_to_version = string_to_version,
	print_attributes = print_attributes,
	print_test = print_test
}