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

---A global table that holds registration callback functions to run when a mod is initially registered. The key should be the mod's UUID.
LeaderLib_ModRegistered = {}
---A global table that holds update callback functions to run when a mod's version changes. The key should be the mod's UUID.
LeaderLib_ModUpdater = {}

Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib__Common.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_Main.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_GlobalSettings.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_GameMechanics.lua");
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib_Debug.lua");

function LeaderLib_Ext_Init()
	Osi.DB_LeaderLib_Extender_LuaInitialized(1)
	LeaderLib.Initialized = true
	-- LeaderLib
	Ext.Print("[LeaderLib:Bootstrap.lua] Registering LeaderLib's mod info.")
	local mod = Ext.GetModInfo("7e737d2f-31d2-4751-963f-be6ccc59cd0c")
	--Ext.Print(Ext.JsonStringify(mod))
	local versionInt = tonumber(mod.Version)
	local major = math.floor(versionInt >> 28)
	local minor = math.floor(versionInt >> 24) & 0x0F
	local revision = math.floor(versionInt >> 16) & 0xFF
	local build = math.floor(versionInt & 0xFFFF)
	Osi.LeaderLib_Mods_OnModLoaded("7e737d2f-31d2-4751-963f-be6ccc59cd0c", "LeaderLib", "LeaderLib - Definitive Edition", mod.Author, versionInt, major, minor, revision, build)
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

local function LeaderUpdater_OnModRegistered_Error (x)
	Ext.Print("[LeaderLib:Bootstrap.lua] Error calling mod registered callback function: ", x)
	return false
end

---Calls initial registration functions stored in LeaderLib_ModRegistered.
---@param uuid string
---@param version integer
function LeaderUpdater_Ext_OnModRegistered(uuid,version)
	local update_func = LeaderLib_ModRegistered[uuid]
	if update_func ~= nil then
		xpcall(update_func, LeaderUpdater_OnModRegistered_Error,version)
	end
end

local function LeaderUpdater_OnModUpdated_Error (x)
	Ext.Print("[LeaderLib:Bootstrap.lua] Error calling mod update callback function: ", x)
	return false
end

---Calls update functions stored in LeaderLib_ModUpdater when that mod's version changes.
---@param uuid string
---@param past_version integer
---@param new_version integer
function LeaderUpdater_Ext_OnModVersionChanged(uuid,past_version,new_version)
	local update_func = LeaderLib_ModUpdater[uuid]
	if update_func ~= nil then
		xpcall(update_func, LeaderUpdater_OnModUpdated_Error, past_version,new_version)
	end
end

local function GameSessionLoad()
	Ext.Print("[LeaderLib:Bootstrap.lua] Session is loading.")
end

local function ModuleLoading()
	Ext.Print("[LeaderLib:Bootstrap.lua] Module is loading.")
end

--v36 and higher
if Ext.RegisterListener ~= nil then
    Ext.RegisterListener("SessionLoading", GameSessionLoad)
    Ext.RegisterListener("ModuleLoading", ModuleLoading)
end

Ext.NewQuery(LeaderLib.Main.StringToVersion_Query, "LeaderLib_Ext_QRY_StringToVersion", "[in](STRING)_Version, [out](INTEGER)_Major, [out](INTEGER)_Minor, [out](INTEGER)_Revision, [out](INTEGER)_Build")

Ext.Print("[LeaderLib:Bootstrap.lua] Finished running.")

local ignore_mods = {
	["7e737d2f-31d2-4751-963f-be6ccc59cd0c"] = true,--LeaderLib
	["2bd9bdbe-22ae-4aa2-9c93-205880fc6564"] = true,--Shared
	["eedf7638-36ff-4f26-a50a-076b87d53ba0"] = true,--Shared_DOS
	["1301db3d-1f54-4e98-9be5-5094030916e4"] = true,--Divinity: Original Sin 2
	["a99afe76-e1b0-43a1-98c2-0fd1448c223b"] = true,--Arena
	["00550ab2-ac92-410c-8d94-742f7629de0e"] = true,--Game Master
	["015de505-6e7f-460c-844c-395de6c2ce34"] = true,--Nine Lives
	["38608c30-1658-4f6a-8adf-e826a5295808"] = true,--Herb Gardens
	["1273be96-6a1b-4da9-b377-249b98dc4b7e"] = true,--Source Meditation
	["af4b3f9c-c5cb-438d-91ae-08c5804c1983"] = true,--From the Ashes
	["ec27251d-acc0-4ab8-920e-dbc851e79bb4"] = true,--Endless Runner
	["b40e443e-badd-4727-82b3-f88a170c4db7"] = true,--Character_Creation_Pack
	["9b45f7e5-d4e2-4fc2-8ef7-3b8e90a5256c"] = true,--8 Action Points
	["f33ded5d-23ab-4f0c-b71e-1aff68eee2cd"] = true,--Hagglers
	["68a99fef-d125-4ed0-893f-bb6751e52c5e"] = true,--Crafter's Kit
	["ca32a698-d63e-4d20-92a7-dd83cba7bc56"] = true,--Divine Talents
	["f30953bb-10d3-4ba4-958c-0f38d4906195"] = true,--Combat Randomiser
	["423fae51-61e3-469a-9c1f-8ad3fd349f02"] = true,--Animal Empathy
	["2d42113c-681a-47b6-96a1-d90b3b1b07d3"] = true,--Fort Joy Magic Mirror
	["8fe1719c-ef8f-4cb7-84bd-5a474ff7b6c1"] = true,--Enhanced Spirit Vision
	["a945eefa-530c-4bca-a29c-a51450f8e181"] = true,--Sourcerous Sundries
	["f243c84f-9322-43ac-96b7-7504f990a8f0"] = true,--Improved Organisation
	["d2507d43-efce-48b8-ba5e-5dd136c715a7"] = true,--Pet Power
}

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

function LeaderLib_Ext_LoadMods()
	local loadOrder = Ext.GetModLoadOrder()
	for _,uuid in pairs(loadOrder) do
		if ignore_mods[uuid] ~= true then
			local mod = Ext.GetModInfo(uuid)
			local versionInt = tonumber(mod.Version)
			local major,minor,revision,build = LeaderLib_Ext_ParseVersion(versionInt)
			--local modid = string.gsub(mod.Name, "%s+", ""):gsub("%p+", ""):gsub("%c+", ""):gsub("%%+", ""):gsub("&+", "")
			local modid = string.match(mod.Directory, "(.*)_")
			Osi.LeaderLib_Mods_OnModLoaded(uuid, modid, mod.Name, mod.Author, versionInt, major, minor, revision, build)
		end
	end
end