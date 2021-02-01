PersistentVars = {}
PersistentVars.TimerData = {}
PersistentVars.StatusSource = {}
PersistentVars.ForceMoveData = {}

--- Registers a function that is called when certain Osiris functions are called, but only when a game level is loaded and the gamestate is running.
--- Supports events, built-in queries, DBs, PROCs, QRYs (user queries).
--- @param name string Osiris function/database name
--- @param arity number Number of columns for DBs or the number of parameters (both IN and OUT) for functions
--- @param event string Event type ('before' - triggered before Osiris call; 'after' - after Osiris call; 'beforeDelete'/'afterDelete' - before/after delete from DB)
--- @param handler function Lua function to run when the event fires
function RegisterProtectedOsirisListener(name, arity, event, handler)
	Ext.RegisterOsirisListener(name, arity, event, function(...)
		if Ext.GetGameState() == "Running" and SharedData.RegionData.LevelType == LEVELTYPE.GAME then
			handler(...)
		end
	end)
end

-- local function LeaderLib_GameSessionLoad()
-- 	PrintDebug("[LeaderLib:Bootstrap.lua] Session is loading.")
-- end

-- local genericPresetOverrideTest = "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/CharacterCreation/OriginPresets/LeaderLib_GenericOverrideTest.lsx"
-- local pathOverrides = {
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic2.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic3.lsx"] = genericPresetOverrideTest,
-- 	["Mods/Shared/CharacterCreation/OriginPresets/Generic4.lsx"] = genericPresetOverrideTest,
-- }

local function ModuleResume()
	--PrintDebug("[LeaderLib:Bootstrap.lua] Module is loading.")
	-- if Vars.DebugMode then
	-- 	for file,override in pairs(pathOverrides) do
	-- 		Ext.AddPathOverride(file, override)
	-- 	end
	-- end
	InvokeListenerCallbacks(Listeners.ModuleResume)
end
Ext.RegisterListener("ModuleResume", ModuleResume)

local function SessionLoaded()
	InvokeListenerCallbacks(Listeners.SessionLoaded)
end
Ext.RegisterListener("SessionLoaded", SessionLoaded)

-- Ext.RegisterListener("SessionLoading", LeaderLib_GameSessionLoad)

Ext.Require("BootstrapShared.lua")
Ext.Require("Server/_InitServer.lua")