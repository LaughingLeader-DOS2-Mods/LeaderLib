local function table_has_index(tbl, index)
	if #tbl > index then
		if tbl[index] ~= nil then
            return true
        end
	end
    return false
end

---Checks if a version string is less than a given version.
---@param past_version string
---@param major integer
---@param minor integer
---@param revision integer
---@param build integer
--_@return boolean
function LeaderLib_Ext_VersionIsLessThan(past_version,major,minor,revision,build)
	local b,pastmajor,pastminor,pastrevision,pastbuild = pcall(LeaderLib_Ext_StringToVersionIntegers, past_version)

	if b == true then
		if  major > pastmajor then
			return true
		elseif major == pastmajor and minor > pastminor then
			return true
		elseif major == pastmajor and pastminor == minor and revision > pastrevision then
			return true
		elseif major == pastmajor and pastminor == minor and pastrevision == revision and build > pastbuild then
			return true
		end
	end

	return false
end

function LeaderLib_Ext_StringToVersionIntegers(version_str)
	local a,b,c,d = -1
	local vals = {}
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
	local b, major,minor,revision,build = pcall(LeaderLib_Ext_StringToVersionIntegers, version_str)
	if b then
		if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
			--Osi.LeaderLib_StringExt_SetVersionFromString(version_str,major,minor,revision,build)
			return major,minor,revision,build
		else
			error(version_str .. " is not a valid version string!")
		end
	else
		error("Failed to process '"..version_str.."' - function LeaderLib_Ext_StringToVersionIntegers has an error.")
	end
end

local function StringToVersion(version_str)
	local b, major,minor,revision,build = pcall(LeaderLib_Ext_StringToVersionIntegers, version_str)
	if b then
		if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
			Osi.LeaderLib_StringExt_SetVersionFromString(version_str,major,minor,revision,build)
		else
			error(version_str .. " is not a valid version string!")
		end
	else
		error("Failed to process '"..version_str.."' - function LeaderLib_Ext_StringToVersionIntegers has an error.")
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
	NRD_DebugLog("[LeaderLib:Lua:PrintTest] " .. str)
end

local function Register_Mod_Table(tbl)
	local id = tbl["id"]
	local author = tbl["author"]
	local version = tbl["version"]
	local b = false
	local major,minor,revision,build = 0
	if id ~= nil and author ~= nil then
		if version == nil then
			Osi.LeaderUpdater_Register_Mod(id, author, 0,0,0,0);
		else
			if type(version) == "string" then
				b,major,minor,revision,build = pcall(LeaderLib_Ext_StringToVersionIntegers, version)
				if b then
					Osi.LeaderUpdater_Register_Mod(id,author,major,minor,revision,build)
				else
					Osi.LeaderUpdater_Register_Mod(id,author,0,0,0,0)
				end
			elseif type(version) == "table" then
				local major = LeaderLib.Common.GetTableEntry(version, "major", 0)
				local minor = LeaderLib.Common.GetTableEntry(version, "minor", 0)
				local revision = LeaderLib.Common.GetTableEntry(version, "revision", 0)
				local build = LeaderLib.Common.GetTableEntry(version, "build", 0)
				Osi.LeaderUpdater_Register_Mod(id,author,major,minor,revision,build)
			end
		end

		local uuid = tbl["uuid"]
		if uuid ~= nil then
			Osi.LeaderUpdater_Register_UUID(id,author,uuid)
		end
		Ext.Print("[LeaderLib_Main.lua] Registered mod (",LeaderLib.Common.Dump(tbl),").")
	end
end

---Lua-based mod registration.
local function RegisterModsFromLua()
	for k,v in pairs(LeaderLib.ModRegistration) do
		Register_Mod_Table(v)
	end
	--Clear
	LeaderLib.ModRegistration = {}
end

local function SetModIsActiveFlag(uuid, name)
	local flag = string.gsub(name, "%s+", "_") -- Replace spaces
	local flagEnabled = GlobalGetFlag(flag)
	if NRD_IsModLoaded(uuid) == 1 then
		if flagEnabled == 0 then
			GlobalSetFlag(flag)
		end
	else
		if flagEnabled == 1 then
			GlobalClearFlag(flag)
		end
	end
end

LeaderLib.Main = {
	StringToVersion_Query = StringToVersion_Query,
	StringToVersion = StringToVersion,
	PrintAttributes = PrintAttributes,
	PrintTest = PrintTest,
	RegisterModsFromLua = RegisterModsFromLua,
	SetModIsActiveFlag = SetModIsActiveFlag
}

LeaderLib.Register.Table(LeaderLib.Main);