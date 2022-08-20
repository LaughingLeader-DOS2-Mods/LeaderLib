Ext.NewQuery(VersionIntegerToVersionString, "LeaderLib_Ext_QRY_VersionIntegerToString", "[in](INTEGER)_Version, [out](STRING)_VersionString")

---Checks if a version string is less than a given version.
---@param past_version string
---@param major integer
---@param minor integer
---@param revision integer
---@param build integer
--_@return boolean
function VersionIsLessThan(past_version,major,minor,revision,build)
	local b,pastmajor,pastminor,pastrevision,pastbuild = pcall(StringToVersionIntegers, past_version)

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

function StringToVersionIntegers(version_str)
	local a,b,c,d = -1,-1,-1,-1
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

function StringToVersion(version_str)
	local b,major,minor,revision,build = pcall(StringToVersionIntegers, version_str)
	if b then
		if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
			return major,minor,revision,build
			--Osi.LeaderLib_StringExt_SetVersionFromString(version_str,major,minor,revision,build)
		else
			if version_str ~= "-1" then
				Ext.Utils.PrintError("[LeaderLib_Versioning.lua:LeaderLib_Ext_StringToVersion] ".. version_str .. " is not a valid version string!")
			end
		end
	else
		Ext.Utils.PrintError("[LeaderLib_Versioning.lua:LeaderLib_Ext_StringToVersion] Failed to process '"..version_str.."' - function StringToVersionIntegers had an error.")
	end
	return -1,-1,-1,-1
end

local function StringToVersion_Query(version_str)
	local major,minor,revision,build = StringToVersion(version_str)
	if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
		return major,minor,revision,build
	end
end

Ext.NewQuery(StringToVersion_Query, "LeaderLib_Ext_QRY_StringToVersion", "[in](STRING)_Version, [out](INTEGER)_Major, [out](INTEGER)_Minor, [out](INTEGER)_Revision, [out](INTEGER)_Build")

function VersionStringToVersionInteger(version_str, fallback)
	local b,major,minor,revision,build = pcall(StringToVersionIntegers, version_str)
	if b then
		if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
			return (major << 28) + (minor << 24) + (revision << 16) + (build)
		else
			if version_str ~= "-1" then
				Ext.Utils.PrintError("[LeaderLib_Versioning.lua:VersionStringToVersionInteger] " .. version_str .. " is not a valid version string!")
			end
		end
	else
		Ext.Utils.PrintError("[LeaderLib_Versioning.lua:VersionStringToVersionInteger] Failed to process '"..version_str.."' - function StringToVersionIntegers has an error.")
	end
	return fallback
end

Ext.NewQuery(VersionStringToVersionInteger, "LeaderLib_Ext_QRY_VersionStringToVersionInteger", "[in](STRING)_VersionString, [in](INTEGER)_Fallback, [out](INTEGER)_VersionInt")

local function Register_Mod_Table(tbl)
	local id = tbl["id"]
	local author = tbl["author"]
	local version = tbl["version"]
	local b = false
	local major,minor,revision,build = 0,0,0,0
	if id ~= nil and author ~= nil then
		if version == nil then
			Osi.LeaderUpdater_Register_Mod(id, author, 0,0,0,0);
		else
			if type(version) == "string" then
				b,major,minor,revision,build = pcall(StringToVersionIntegers, version)
				if b then
					Osi.LeaderUpdater_Register_Mod(id,author,major,minor,revision,build)
				else
					Osi.LeaderUpdater_Register_Mod(id,author,0,0,0,0)
				end
			elseif type(version) == "table" then
				local major = Common.GetTableEntry(version, "major", 0)
				local minor = Common.GetTableEntry(version, "minor", 0)
				local revision = Common.GetTableEntry(version, "revision", 0)
				local build = Common.GetTableEntry(version, "build", 0)
				Osi.LeaderUpdater_Register_Mod(id,author,major,minor,revision,build)
			end
		end

		local uuid = tbl["uuid"]
		if uuid ~= nil then
			Osi.LeaderUpdater_Register_UUID(id,author,uuid)
		end
		PrintDebug("[LeaderLib_Main.lua] Registered mod (",Common.Dump(tbl),").")
	end
end

local function LeaderUpdater_OnModRegistered_Error (x)
	Ext.Utils.PrintError("[LeaderLib:Bootstrap.lua] Error calling mod registered callback function: ", x)
	return false
end

---Calls initial registration functions stored in LeaderLib_ModRegistered.
---@param uuid string
---@param version integer
function OnModRegistered(uuid,version)
	local callback = ModListeners.Registered[uuid]
	if callback ~= nil then
		local status,err = xpcall(callback, debug.traceback, version)
		if not status then
			Ext.Utils.PrintError("[LeaderLib:OnModRegistered] Error calling function:\n", err)
		end
	end
end

local function LeaderUpdater_OnModUpdated_Error (x)
	Ext.Utils.PrintError("[LeaderLib:Bootstrap.lua] Error calling mod update callback function: ", x)
	return false
end

---Calls update functions stored in LeaderLib_ModUpdater when that mod's version changes.
---@param uuid string
---@param past_version integer
---@param new_version integer
function OnModVersionChanged(uuid,past_version,new_version)
	local callback = ModListeners.Updated[uuid]
	if callback ~= nil then
		local status,err = xpcall(callback, debug.traceback, past_version, new_version)
		if not status then
			Ext.Utils.PrintError("[LeaderLib:OnModVersionChanged] Error calling function:\n", err)
		end
	end
end

local function _LoadLeaderLib()
	-- LeaderLib
	local mod = Ext.Mod.GetMod(ModuleUUID)
	local major,minor,revision,build = table.unpack(mod.Info.ModVersion)
	local versionInt = (major << 28) + (minor << 24) + (revision << 16) + (build)
	Osi.LeaderLib_Mods_OnModLoaded(ModuleUUID, "LeaderLib", mod.Info.Name, mod.Info.Author, versionInt, major, minor, revision, build)
end

function LoadMods()
	PrintDebug("[LeaderLib:Bootstrap.lua] Registering LeaderLib's mod info.")
	_LoadLeaderLib()

	local loadOrder = Ext.Mod.GetLoadOrder()
	for _,uuid in pairs(loadOrder) do
		if IgnoredMods[uuid] ~= true then
			local mod = Ext.Mod.GetMod(uuid)
			local info = mod.Info
			local major,minor,revision,build = table.unpack(info.ModVersion)
			local versionInt = (major << 28) + (minor << 24) + (revision << 16) + (build)
			--local modid = string.gsub(mod.Name, "%s+", ""):gsub("%p+", ""):gsub("%c+", ""):gsub("%%+", ""):gsub("&+", "")
			local modName = info.Name or ""
			local modid = string.match(info.Directory, "(.*)_") or modName .. uuid
			local author = info.Author or ""
			if modName == nil then
				modName = ""
			end
			local callback = ModListeners.Loaded[uuid]
			if callback ~= nil then
				--DB_LeaderLib_Mods_Registered(_UUID, _ModID, _DisplayName, _LastAuthor, _LastVersion, _LastMajor, _LastMinor, _LastRevision, _LastBuild)
				local lastVersion = -1
				local db = Osi.DB_LeaderLib_Mods_Registered:Get(uuid, nil, nil, nil, nil, nil, nil, nil, nil)
				if db ~= nil and #db > 0 then
					local _,_,_,_,lastVersionStored = table.unpack(db[1])
					if lastVersionStored ~= nil then
						lastVersion = lastVersionStored
					end
				end
				local b,err = xpcall(callback, debug.traceback, lastVersion, versionInt)
				if not b then
					Ext.Utils.PrintError(err)
				end
			end
			Osi.LeaderLib_Mods_OnModLoaded(uuid, modid, modName, author, versionInt, major, minor, revision, build)
		end
	end
end

function CallModUpdated(modid, author, lastversionstr, nextversionstr)
	local old_version = VersionIntegerToVersionString(math.tointeger(lastversionstr))
	local new_version = VersionIntegerToVersionString(math.tointeger(nextversionstr))
	if old_version ~= nil or new_version ~= nil then
		Osi.LeaderUpdater_ModUpdated(modid, author, old_version, new_version)
	else
		Ext.Utils.PrintError("[LeaderLib_Versioning.lua:LeaderLib_Ext_CallModUpdated] Failed to process '"..lastversionstr.."' and "..nextversionstr.." into version strings")
	end
end