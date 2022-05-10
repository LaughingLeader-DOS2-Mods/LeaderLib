TotalSkillListeners = 0

---@alias LeaderLibSkillListenerDataType string|'"boolean"'|'"StatEntrySkillData"'|'"HitData"'|'"ProjectileHitData"'|'"SkillEventData"'

---@alias LeaderLibSkillListenerCallback fun(skill:string, char:string, state:SKILL_STATE, data:SkillEventData|HitData|ProjectileHitData|StatEntrySkillData|boolean, dataType:LeaderLibSkillListenerDataType)

---Registers a function to call when skill events fire for a skill or table of skills.
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

local _OsirisEventSubscribe = Ext.RegisterOsirisListener
if Ext.Version() >= 56 then
	_OsirisEventSubscribe = Ext.Osiris.RegisterListener
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
			_OsirisEventSubscribe(name, eventArity, arity, function(...)
				if CanInvokeListener(anyLevelType) then
					local b,result = xpcall(event, debug.traceback, ...)
					if not b then
						error(string.format("Error invoking listener for %s:\n%s", name, result), 2)
					end
				end
			end)
		end
	else
		_OsirisEventSubscribe(name, arity, event, function(...)
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

---@alias UUID string
---@alias NETID integer

---A parameter type that can be either item userdata, or a ID to ultimately retrieve that userdata via GameHelpers.GetItem.
---@see GameHelpers.GetItem
---@alias ItemParam EsvItem|EclItem|UUID|NETID

---A parameter type that can be either character userdata, or a ID to ultimately retrieve that userdata via GameHelpers.GetCharacter.
---@see GameHelpers.GetCharacter
---@alias CharacterParam EsvCharacter|EclCharacter|UUID|NETID

---@class LeaderLibPersistentVars
local defaultPersistentVars = {
	---Associates a unique timer name (uuid-concatenated) with a general timer name.
	---@type table<string,string>
	TimerNameMap = {},
	---@type table<string,table[]>
	TimerData = {},
	StatusSource = {},
	---UUID->Statuses->ID->Source|False(for no source)
	---@type table<UUID,table<string,UUID|boolean>>
	ActivePermanentStatuses = {},
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

Ext.Require("BootstrapShared.lua")
Ext.Require("Shared/UI/CombatLog.lua")
Ext.Require("Shared/UI/MessageBox.lua")
Ext.Require("Shared/UI/Overhead.lua")
Ext.Require("Shared/System/TutorialManager.lua")

---@private
---@type LeaderLibPersistentVars
PersistentVars = Common.CloneTable(defaultPersistentVars, true)

function LoadPersistentVars(skipCallback)
	PersistentVars = GameHelpers.PersistentVars.Update(defaultPersistentVars, PersistentVars)
	SkillManager.LoadSaveData()
	if not skipCallback then
		InvokeListenerCallbacks(Listeners.PersistentVarsLoaded, PersistentVars)
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

function SetModIsActiveFlag(uuid, modid)
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

Ext.Require("Server/Helpers/NetHelpers.lua")
Ext.Require("Server/Classes/_Init.lua")
Ext.Require("Server/Data/BasePresets.lua")
Ext.Require("Server/Helpers/MiscHelpers.lua")
Ext.Require("Server/Helpers/DatabaseHelpers.lua")
Ext.Require("Server/Helpers/CombatHelpers.lua")
Ext.Require("Server/Helpers/DamageHelpers.lua")
Ext.Require("Server/Helpers/HitHelpers.lua")
Ext.Require("Server/Helpers/ProjectileHelpers.lua")
Ext.Require("Server/Helpers/SkillBarHelpers.lua")
Ext.Require("Server/Helpers/SkillHelpers.lua")
Ext.Require("Server/Helpers/StatusHelpers.lua")
Ext.Require("Server/Helpers/SurfaceHelpers.lua")
Ext.Require("Server/Helpers/PersistentVarsHelpers.lua")
Ext.Require("Server/Game/GameEvents.lua")
Ext.Require("Server/Game/ComputeCharacterHit.lua")
Ext.Require("Server/Game/QualityOfLife.lua")
Ext.Require("Server/Game/OriginFixes.lua")
Ext.Require("Server/System/EffectManager.lua")
Ext.Require("Server/System/TurnCounter.lua")
Ext.Require("Server/System/StatusManager.lua")
Ext.Require("Server/System/SkillManager.lua")
Ext.Require("Server/System/TagManager.lua")
Ext.Require("Server/System/AttackManager.lua")
Ext.Require("Server/System/SceneManager.lua")
Ext.Require("Server/Listeners/_Init.lua")
Ext.Require("Server/ModMenu/ModMenuServerCommands.lua")
Ext.Require("Server/Versioning.lua")
Ext.Require("Server/Debug/ConsoleCommands.lua")
if Vars.DebugMode then
	Ext.Require("Server/Debug/DebugMain.lua")
	Ext.Require("Server/Debug/DeveloperCommands.lua")
	if coroutine then
	Ext.Require("Server/Debug/CoroutineTests.lua")
	end
end
Ext.Require("Server/Game/QOL/BuffStatusPreserver.lua")
Ext.Require("Server/Game/QOL/SkipTutorial.lua")
Ext.Require("Server/Updates.lua")

---Set a character's name with a translated string value.
---@param char string
---@param handle string
---@param fallback string
function SetCustomNameWithLocalization(char,handle,fallback)
	local name,_ = Ext.GetTranslatedString(handle, fallback)
	CharacterSetCustomName(char, name)
end

Ext.NewQuery(GetSkillEntryName, "LeaderLib_Ext_QRY_GetSkillEntryName", "[in](STRING)_SkillPrototype, [out](STRING)_SkillId")

local function RandomQRY(min,max)
	if min == nil then min = 0 end
	if max == nil then max = 0 end
	return Ext.Random(min,max)
end
Ext.NewQuery(RandomQRY, "LeaderLib_Ext_Random", "[in](INTEGER)_Min, [in](INTEGER)_Max, [out](INTEGER)_Ran")

--Outdated editor version
if Ext.GameVersion() == "v3.6.51.9303" then
	--The lua helper goal contains 3 new events not in the editor version, so we swap this out to avoid the initial compile error in the editor
	Ext.AddPathOverride("Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Story/RawFiles/Goals/LeaderLib_19_TS_LuaOsirisSubscription_Generated.txt", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/OutdatedEditorEventsFix.txt")
	Ext.AddPathOverride("Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Story/RawFiles/Goals/__AAA_LeaderLib_19_TS_LuaOsirisSubscription.txt", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/OutdatedEditorQueriesFix.txt")
end

InvokeListenerCallbacks(Listeners.Loaded)