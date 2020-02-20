local function table_has_index(tbl, index)
	if #tbl > index then
		if tbl[index] ~= nil then
            return true
        end
	end
    return false
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

local function SetModIsActiveFlag(uuid, modid)
	--local flag = string.gsub(modid, "%s+", "_") -- Replace spaces
	local flag = tostring(modid).. "_IsActive"
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
	PrintAttributes = PrintAttributes,
	PrintTest = PrintTest,
	RegisterModsFromLua = RegisterModsFromLua,
	SetModIsActiveFlag = SetModIsActiveFlag
}

LeaderLib.Register.Table(LeaderLib.Main);