PersistentVars = {}
PersistentVars.TimerData = {}
PersistentVars.StatusSource = {}
PersistentVars.ForceMoveData = {}

Ext.Require("BootstrapShared.lua")
-- Server-side Listeners
Listeners.TimerFinished = {}
---@type table<string,fun(uuid1:string|nil, uuid2:string|nil):void>
Listeners.NamedTimerFinished = {}

---Hit listeners/callbacks, for mod compatibility.
---Called from HitOverrides.ComputeCharacterHit at the end of the function, if certain features are enabled or listeners are registered.
---@type ExtComputeCharacterHitCallback[]
Listeners.ComputeCharacterHit = {}
---Called from HitOverrides.DoHit, which overrides Game.Math.DoHit to wrap listener callbacks. The original Game.Math.DoHit is called for calculation.
---If the original function was overwritten by a mod, this should still work.
---@type DoHitCallback[]
Listeners.DoHit = {}
---Called from a Game.Math.ApplyDamageCharacterBonuses override. This is where resistance penetration happens. 
---@type ApplyDamageCharacterBonusesCallback[]
Listeners.ApplyDamageCharacterBonuses = {}
--Flag events
---@type table<string, fun(flag:string, enabled:boolean):void[]>
Listeners.GlobalFlagChanged = {}

---@alias OnPrepareHitCallback fun(target:string, source:string, damage:integer, handle:integer):void
---@alias OnHitCallback fun(target:string, source:string, damage:integer, handle:integer, skill:string|nil):void
---@alias OnSkillHitCallback fun(skill:string, source:string, state:SKILL_STATE, data:HitData|ProjectileHitData):void

---@type OnPrepareHitCallback[]
Listeners.OnPrepareHit = {}
---@type OnHitCallback[]
Listeners.OnHit = {}
---Fires when a skill hits, or a projectile from a skill hits.
---@type OnSkillHitCallback[]
Listeners.OnSkillHit = {}

--Debug listeners
Listeners.BeforeLuaReset = {}
Listeners.LuaReset = {}

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

Ext.Require("Server/_InitServer.lua")