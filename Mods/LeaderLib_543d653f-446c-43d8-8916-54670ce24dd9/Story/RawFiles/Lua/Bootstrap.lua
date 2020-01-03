LeaderLib = {
	Main = {},
	Settings = {},
	Common = {},
	ModRegistration = {},
	Initialized = false,
}

---A global table that holds update functions to call when a mod's version changes. The key should be the mod's UUID.
LeaderLib_ModUpdater = {}

Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib__Common.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_Main.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_GlobalSettings.lua");

function LeaderLib_Ext_Init()
	Osi.DB_LeaderLib_Extender_LuaInitialized(1)
	LeaderLib.Initialized = true
end

LeaderLib_DebugInitCalls = {}

function LeaderLib_Ext_DebugInit()
	for i = 1, #LeaderLib_DebugInitCalls do
		local func = LeaderLib_DebugInitCalls[i]
		if func ~= nil and type(func) == "function" then
			pcall(func)
		end
	end
end

---Called by other mods via Lua scripts.
function LeaderLib_Ext_RegisterMod(id,author,major,minor,revision,build,uuid)
	if LeaderLib.Initialized == true then
		Osi.LeaderUpdater_Register_Mod(id,author,major,minor,revision,build)
	else
		LeaderLib.ModRegistration[#LeaderLib.ModRegistration+1] = {
			id = id,
			author = author,
			version = {
				major = major,
				minor = minor,
				revision = revision,
				build = build
			},
			uuid = uuid
		}
	end
end

local function LeaderUpdater_ModUpdated_Error (x)
	Ext.Print("[LeaderLib:Bootstrap.lua] Error calling mod update function: ", x)
	return false
end

function LeaderUpdater_Ext_ModUpdated(id,author,past_version,new_version,uuid)
	local update_func = LeaderLib_ModUpdater[uuid]
	if update_func ~= nil then
		xpcall(update_func, LeaderUpdater_ModUpdated_Error, id,author,past_version,new_version)
	end
end

local GameSessionLoad = function ()
	Ext.Print("[LeaderLib:Bootstrap.lua] Session is loading.")
end

local ModuleLoading = function ()
	Ext.Print("[LeaderLib:Bootstrap.lua] Module is loading.")
end

--v36 and higher
if Ext.RegisterListener ~= nil then
    Ext.RegisterListener("SessionLoading", GameSessionLoad)
    Ext.RegisterListener("ModuleLoading", ModuleLoading)
end

local export = {
	StringToVersion = LeaderLib.Main.StringToVersion,
	PrintAttributes = LeaderLib.Main.PrintAttributes,
	PrintTest = LeaderLib.Main.PrintTest,
	RefreshSkills = LeaderLib.Main.RefreshSkills,
	RefreshSkill = LeaderLib.Main.RefreshSkill,
	RegisterModsFromLua = LeaderLib.Main.RegisterModsFromLua,
}

for name,func in pairs(export) do
	local func_name = "LeaderLib_Ext_" .. name
	_G[func_name] = func
	Ext.Print("[LeaderLib:Bootstrap.lua] Registered global function '"..func_name.."'.")
end

Ext.NewQuery(LeaderLib.Main.StringToVersion_Query, "LeaderLib_Ext_QRY_StringToVersion", "[in](STRING)_Version, [out](INTEGER)_Major, [out](INTEGER)_Minor, [out](INTEGER)_Revision, [out](INTEGER)_Build")

Ext.Print("[LeaderLib:Bootstrap.lua] Finished running.")