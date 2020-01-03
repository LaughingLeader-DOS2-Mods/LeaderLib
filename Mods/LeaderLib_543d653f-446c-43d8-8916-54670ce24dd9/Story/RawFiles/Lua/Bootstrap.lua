LeaderLib = {
	Main = {},
	Settings = {},
	Common = {},
	ModRegistration = {},
	Initialized = false
}

Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib__Common.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_Main.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_GlobalSettings.lua");

function LeaderLib_Ext_Init()
	Osi.DB_LeaderLib_Extender_LuaInitialized(1)
	LeaderLib.Initialized = true
end

function LeaderLib_Ext_RegisterMod(id,author,major,minor,revision,build)
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
			}
		}
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