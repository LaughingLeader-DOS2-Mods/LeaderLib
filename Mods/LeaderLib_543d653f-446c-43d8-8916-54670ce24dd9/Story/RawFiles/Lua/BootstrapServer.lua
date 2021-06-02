Ext.Require("BootstrapShared.lua")

---@alias UUID string
---@alias NETID integer

---@class LeaderLibPersistentVars
local defaultPersistentVars = {
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
	---@type table<UUID,table<STAT_ID,integer>>
	CustomStatAvailablePoints = {},
	---@type table<UUID, number>
	ScaleOverride = {}
}

---@type LeaderLibPersistentVars
PersistentVars = Common.CopyTable(defaultPersistentVars, true)
function LoadPersistentVars()
	Common.InitializeTableFromSource(PersistentVars, defaultPersistentVars)
	SkillSystem.LoadSaveData()
end

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

--- Registers a function that is called when certain Osiris functions are called, but only when a game level is loaded and the gamestate is running.
--- Supports events, built-in queries, DBs, PROCs, QRYs (user queries).
--- @param name string Osiris function/database name
--- @param arity number Number of columns for DBs or the number of parameters (both IN and OUT) for functions
--- @param event string Event type ('before' - triggered before Osiris call; 'after' - after Osiris call; 'beforeDelete'/'afterDelete' - before/after delete from DB)
--- @param handler function Lua function to run when the event fires
function RegisterProtectedOsirisListener(name, arity, event, handler)
	--Auto-arity mode
	if (arity == "before" or arity == "after") and type(event) == "function" and handler == nil then
		local eventArity = Data.OsirisEvents[name]
		if eventArity then
			Ext.RegisterOsirisListener(name, eventArity, arity, function(...)
				if Ext.GetGameState() == "Running" and SharedData.RegionData.LevelType == LEVELTYPE.GAME then
					event(...)
				end
			end)
		end
	else
		Ext.RegisterOsirisListener(name, arity, event, function(...)
			if Ext.GetGameState() == "Running" and SharedData.RegionData.LevelType == LEVELTYPE.GAME then
				handler(...)
			end
		end)
	end
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