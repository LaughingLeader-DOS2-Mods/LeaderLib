--- Split a version integer into separate values
---@param version integer
---@return integer,integer,integer,integer
function LeaderLib_Ext_ParseVersion(version)
	if type(version) == "string" then
		version = math.floor(tonumber(version))
	elseif type(version) == "number" then
		version = math.tointeger(version)
	end
	local major = math.floor(version >> 28)
	local minor = math.floor(version >> 24) & 0x0F
	local revision = math.floor(version >> 16) & 0xFF
	local build = math.floor(version & 0xFFFF)
	return major,minor,revision,build
end

--- Turn a version integer into a string.
---@param version integer
---@return string
function LeaderLib_Ext_VersionIntegerToVersionString(version)
	if version == -1 then return "-1" end
	local major,minor,revision,build = LeaderLib_Ext_ParseVersion(version)
	if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
		return tostring(major).."."..tostring(minor).."."..tostring(revision).."."..tostring(build)
	end 
	return nil
end

Ext.NewQuery(LeaderLib_Ext_VersionIntegerToVersionString, "LeaderLib_Ext_QRY_VersionIntegerToString", "[in](INTEGER)_Version, [out](STRING)_VersionString")

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

function LeaderLib_Ext_StringToVersion(version_str)
	local b,major,minor,revision,build = pcall(LeaderLib_Ext_StringToVersionIntegers, version_str)
	if b then
		if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
			return major,minor,revision,build
			--Osi.LeaderLib_StringExt_SetVersionFromString(version_str,major,minor,revision,build)
		else
			Ext.Print("[LeaderLib_Versioning.lua:LeaderLib_Ext_StringToVersion] ".. version_str .. " is not a valid version string!")
		end
	else
		Ext.Print("[LeaderLib_Versioning.lua:LeaderLib_Ext_StringToVersion] Failed to process '"..version_str.."' - function LeaderLib_Ext_StringToVersionIntegers had an error.")
	end
	return -1,-1,-1,-1
end

local function StringToVersion_Query(version_str)
	local major,minor,revision,build = LeaderLib_Ext_StringToVersion(version_str)
	if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
		return major,minor,revision,build
	end
end

Ext.NewQuery(StringToVersion_Query, "LeaderLib_Ext_QRY_StringToVersion", "[in](STRING)_Version, [out](INTEGER)_Major, [out](INTEGER)_Minor, [out](INTEGER)_Revision, [out](INTEGER)_Build")

function LeaderLib_Ext_VersionStringToVersionInteger(version_str, fallback)
	local b,major,minor,revision,build = pcall(LeaderLib_Ext_StringToVersionIntegers, version_str)
	if b then
		if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
			return (major << 28) + (minor << 24) + (revision << 16) + (build)
		else
			Ext.Print("[LeaderLib_Versioning.lua:VersionStringToVersionInteger] " .. version_str .. " is not a valid version string!")
		end
	else
		Ext.Print("[LeaderLib_Versioning.lua:VersionStringToVersionInteger] Failed to process '"..version_str.."' - function LeaderLib_Ext_StringToVersionIntegers has an error.")
	end
	return fallback
end

Ext.NewQuery(LeaderLib_Ext_VersionStringToVersionInteger, "LeaderLib_Ext_QRY_VersionStringToVersionInteger", "[in](STRING)_VersionString, [in](INTEGER)_Fallback, [out](INTEGER)_VersionInt")

function LeaderLib_Ext_CallModUpdated(modid, author, lastversionstr, nextversionstr)
	local old_version = LeaderLib_Ext_VersionIntegerToVersionString(math.tointeger(lastversionstr))
	local new_version = LeaderLib_Ext_VersionIntegerToVersionString(math.tointeger(nextversionstr))
	if old_version ~= nil or new_version ~= nil then
		Osi.LeaderUpdater_ModUpdated(modid, author, old_version, new_version)
	else
		Ext.Print("[LeaderLib_Versioning.lua:LeaderLib_Ext_CallModUpdated] Failed to process '"..lastversionstr.."' and "..nextversionstr.." into version strings")
	end
end