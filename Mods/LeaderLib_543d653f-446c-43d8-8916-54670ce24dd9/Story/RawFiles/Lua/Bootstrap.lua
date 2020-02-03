---Registers a function to the global table.
---@param name string
---@param func function
local function Register_Function(name, func)
    if type(func) == "function" then
        local func_name = "LeaderLib_Ext_" .. name
        _G[func_name] = func
        Ext.Print("[LeaderLib_Bootstrap.lua] Registered function ("..func_name..").")
    end
end

---Registers a table of key => function to the global table. The key is used for the name.
---@param tbl table
local function Register_Table(tbl)
    for k,func in pairs(tbl) do
        if type(func) == "function" then
            local func_name = "LeaderLib_Ext_" .. k
            _G[func_name] = func
            Ext.Print("LeaderLib_Bootstrap.lua] Registered function ("..func_name..").")
        else
            Ext.Print("[LeaderLib_Bootstrap.lua] Not a function type ("..type(func)..").")
        end
    end
end

LeaderLib = {
	Main = {},
	Settings = {},
	Common = {},
	Game = {},
	Data = {},
	Register = {
        Function = Register_Function,
        Table = Register_Table
    },
	ModRegistration = {},
	Initialized = false,
}

---A global table that holds update functions to call when a mod's version changes. The key should be the mod's UUID.
LeaderLib_ModUpdater = {}

Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib__Common.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_Main.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_GlobalSettings.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_GameMechanics.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_Debug.lua");

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

Ext.NewQuery(LeaderLib.Main.StringToVersion_Query, "LeaderLib_Ext_QRY_StringToVersion", "[in](STRING)_Version, [out](INTEGER)_Major, [out](INTEGER)_Minor, [out](INTEGER)_Revision, [out](INTEGER)_Build")

Ext.Print("[LeaderLib:Bootstrap.lua] Finished running.")