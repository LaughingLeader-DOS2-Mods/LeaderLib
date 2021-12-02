TotalSkillListeners = 0

---@alias LeaderLibSkillListenerCallback fun(skill:string, char:string, state:SKILL_STATE, data:SkillEventData|HitData|ProjectileHitData)

---Registers a function to call when a specific skill's events fire.
---@param skill string|string[]
---@param callback LeaderLibSkillListenerCallback
---@see SkillEventData#ForEach
---@see HitData#Success
---@see ProjectileHitData#Projectile
function RegisterSkillListener(skill, callback)
	local t = type(skill)
	if t == "string" then
		if StringHelpers.Equals(skill, "all", true) then
			skill = "All"
		end
		if SkillListeners[skill] == nil then
			SkillListeners[skill] = {}
		end
		table.insert(SkillListeners[skill], callback)
		TotalSkillListeners = TotalSkillListeners + 1

		if Vars.Initialized then
			Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaSkillListeners_Enabled", "LeaderLib")
			Osi.LeaderLib_ToggleScripts_EnableScript("LeaderLib_LuaEventListeners_Enabled", "LeaderLib")
		else
			Vars.PostLoadEnableLuaListeners = true
		end
	elseif t == "table" then
		for i,v in pairs(skill) do
			RegisterSkillListener(v, callback)
		end
	end
end

--- Removed a function from the listeners table.
---@param skill string
---@param callback function
function RemoveSkillListener(skill, callback)
	local t = type(skill)
	if t == "string" then
		if SkillListeners[skill] ~= nil then
			for i,v in pairs(SkillListeners[skill]) do
				if v == callback then
					table.remove(SkillListeners[skill], i)
					break
				end
			end
		end
	elseif t == "table" then
		for i,v in pairs(skill) do
			if SkillListeners[v] ~= nil then
				for i,v in pairs(SkillListeners[v]) do
					if v == callback then
						table.remove(SkillListeners[v], i)
						break
					end
				end
			end
		end
	end
end

local function CanInvokeListener(anyLevelType)
	return Ext.GetGameState() == "Running" and (anyLevelType or ((not anyLevelType and SharedData.RegionData.LevelType == LEVELTYPE.GAME)))
end

--- Registers a function that is called when certain Osiris functions are called, but only when a game level is loaded and the gamestate is running.
--- Supports events, built-in queries, DBs, PROCs, QRYs (user queries).
--- @param name string Osiris function/database name
--- @param arity number Number of columns for DBs or the number of parameters (both IN and OUT) for functions
--- @param event string Event type ('before' - triggered before Osiris call; 'after' - after Osiris call; 'beforeDelete'/'afterDelete' - before/after delete from DB)
--- @param handler function Lua function to run when the event fires
--- @param anyLevelType boolean|nil If true, the function will only be called for non-game levels as well (lobby, character creation).
function RegisterProtectedOsirisListener(name, arity, event, handler, anyLevelType)
	--Auto-arity mode
	if (arity == "before" or arity == "after") and type(event) == "function" and handler == nil then
		local eventArity = Data.OsirisEvents[name]
		if eventArity then
			Ext.RegisterOsirisListener(name, eventArity, arity, function(...)
				if CanInvokeListener(anyLevelType) then
					local b,result = xpcall(event, debug.traceback, ...)
					if not b then
						error(string.format("Error invoking listener for %s:\n%s", name, result), 2)
					end
				end
			end)
		end
	else
		Ext.RegisterOsirisListener(name, arity, event, function(...)
			if CanInvokeListener(anyLevelType) then
				local b,result = xpcall(handler, debug.traceback, ...)
				if not b then
					error(string.format("Error invoking listener for %s:\n%s", name, result), 2)
				end
			end
		end)
	end
end

--- Wraps an extender listener in a check to make sure the game is running before calling the supplied function.
--- @param event string
--- @param listener function Lua function to run when the event fires
--- @param anyLevelType boolean|nil If true, the function will only be called for non-game levels as well (lobby, character creation).
function RegisterProtectedExtenderListener(event, listener, anyLevelType)
	Ext.RegisterListener(event, function(...)
		if CanInvokeListener(anyLevelType) then
			local b,result = xpcall(listener, debug.traceback, ...)
			if not b then
				error(string.format("Error invoking listener for %s:\n%s", event, result), 2)
			end
		end
	end)
end

Ext.Require("BootstrapShared.lua")

---@alias UUID string
---@alias NETID integer

---@class LeaderLibPersistentVars
local defaultPersistentVars = {
	---Associates a unique timer name (uuid-concatenated) with a general timer name.
	---@type table<string,string>
	TimerNameMap = {},
	---@type table<string,table[]>
	TimerData = {},
	StatusSource = {},
	ForceMoveData = {},
	SceneData = {
		ActiveScene = {},
		Queue = {}
	},
	SkillData = {},
	SkillPropertiesAction = {
		---Stores a UUID and AP to restore.
		---@type table<UUID,integer>
		MoveToTarget = {}
	},
	---@type table<UUID,string>
	IsPreparingSkill = {},
	---@type table<UUID,TurnCounterData>
	TurnCounterData = {},
	---@type table<UUID,table<string,boolean>>
	WaitForTurnEnding = {},
	---@type table<UUID, number>
	ScaleOverride = {},
	---@type table<UUID,UUID[]>
	Summons = {},
	---@type table<UUID,table<string,number>>
	BuffStatuses = {},

	---@type table<UUID,LeaderLibObjectLoopEffectSaveData[]>
	ObjectLoopEffects = {},

	---@type table<string,LeaderLibWorldLoopEffectSaveData[]>
	WorldLoopEffects = {},

	---@type table<UUID,string>
	LastUsedHealingSkill = {},

	---@class LeaderLibNextGenericHealStatusSourceData
	---@field StatusId string
	---@field Source UUID
	---@field Time number

	---@type table<UUID,LeaderLibNextGenericHealStatusSourceData>
	NextGenericHealStatusSource = {},

	---Used to avoid exploding projectiles caused from applying BonusWeapon properties triggering further BonusWeapon hits, which makes for endless loops.
	---@type table<UUID,boolean|string>
	JustAppliedBonusWeaponStatuses = {},

	BasicAttackData = {},
	StartAttackPosition = {},
}

---@private
---@type LeaderLibPersistentVars
PersistentVars = Common.CloneTable(defaultPersistentVars, true)

---@type LeaderLibPersistentVars
LeaderLibPersistentVars = PersistentVars

function LoadPersistentVars()
	Common.InitializeTableFromSource(PersistentVars, defaultPersistentVars)
	SkillSystem.LoadSaveData()
	InvokeListenerCallbacks(Listeners.PersistentVarsLoaded)
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

InvokeListenerCallbacks(Listeners.Loaded)