local function CanInvokeListener(anyLevelType)
	return Vars.Initialized == true and Ext.GetGameState() == "Running" and (anyLevelType or ((not anyLevelType and SharedData.RegionData.LevelType == LEVELTYPE.GAME)))
end

local _OsirisEventSubscribe = Ext.Osiris.RegisterListener
if Ext.Utils.Version() >= 56 then
	_OsirisEventSubscribe = Ext.Osiris.RegisterListener
end

--- Registers a function that is called when certain Osiris functions are called, but only when a game level is loaded and the gamestate is running.
--- Supports events, built-in queries, DBs, PROCs, QRYs (user queries).
--- @param name string Osiris function/database name
--- @param arity number Number of columns for DBs or the number of parameters (both IN and OUT) for functions
--- @param event OsirisEventType Event type ('before' - triggered before Osiris call; 'after' - after Osiris call; 'beforeDelete'/'afterDelete' - before/after delete from DB)
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

---@class LeaderLibPersistentVars
local defaultPersistentVars = {
	---Associates a unique timer name (uuid-concatenated) with a general timer name.
	---@type table<string,string>
	TimerNameMap = {},
	---@type table<string,table[]>
	TimerData = {},
	StatusSource = {},
	---GUID->Statuses->ID->Source|False(for no source)
	---@type table<Guid,table<string,Guid|boolean>>
	ActivePermanentStatuses = {},
	---@type table<Guid, {ID:string, Position:vec3, Start:vec3, Handle:integer, Source:Guid, IsFromSkill:boolean, Skill:string, Distance:number}>
	ForceMoveData = {},
	KnockupData = {
		Active = false,
		---@type {ID:string, GUID:Guid, Start:number[], End:number[], Source:Guid, Skill:string, Falling:boolean}[]
		ObjectData = {}
	},
	SceneData = {
		ActiveScene = {},
		Queue = {}
	},
	SkillData = {},
	SkillPropertiesAction = {
		---Stores a GUID and AP to restore.
		---@type table<Guid,integer>
		MoveToTarget = {}
	},
	---@type table<Guid,string>
	IsPreparingSkill = {},
	---@type table<Guid,TurnCounterData>
	TurnCounterData = {},
	---@type table<Guid,table<string,boolean>>
	WaitForTurnEnding = {},
	---@type table<Guid, number>
	ScaleOverride = {},
	---@type table<Guid,Guid[]>
	Summons = {},
	---@type table<Guid,table<string,number>>
	BuffStatuses = {},

	---@type table<Guid,LeaderLibObjectLoopEffectSaveData[]>
	ObjectLoopEffects = {},

	---@type table<string,LeaderLibWorldLoopEffectSaveData[]>
	WorldLoopEffects = {},

	---@type table<Guid,string>
	LastUsedHealingSkill = {},

	---@class LeaderLibNextGenericHealStatusSourceData
	---@field StatusId string
	---@field Source Guid
	---@field Time number

	---@type table<Guid,LeaderLibNextGenericHealStatusSourceData>
	NextGenericHealStatusSource = {},

	---Used to avoid exploding projectiles caused from applying BonusWeapon properties triggering further BonusWeapon hits, which makes for endless loops.
	---@type table<Guid,boolean|string>
	JustAppliedBonusWeaponStatuses = {},

	BasicAttackData = {},
	StartAttackPosition = {},

	---UserID to RootTemplate, to BookId
	---@type table<integer,table<string, string>>
	ReadBooks = {},

	---@class LeaderLibPersistentVisualsEntry
	---@field ID string
	---@field Resource string
	---@field Options ExtenderClientVisualOptions|nil
	---@field ExtraOptions LeaderLibClientVisualOptions|nil
	---@field Persistence LeaderLibClientVisualPersistenceOptions|nil
	---@field RestrictToVisual FixedString|nil If set, this visual will only be recreated if character.RootTemplate.VisualTemplate matches this value.

	---@type table<Guid,LeaderLibPersistentVisualsEntry[]>
	PersistentVisuals = {},
	Debug = {},
}


Ext.Require("BootstrapShared.lua")
Ext.Require("Shared/UI/CombatLog.lua")
Ext.Require("Shared/UI/MessageBox.lua")
Ext.Require("Shared/UI/Overhead.lua")
Ext.Require("Shared/System/TutorialManager.lua")

local function _SetPersistentVars(v)
	PersistentVars = v
end
_SetPersistentVars(Common.CloneTable(defaultPersistentVars, true))

---@return LeaderLibPersistentVars
local function _GetPersistentVars()
	return PersistentVars
end

_PV = _GetPersistentVars()

---Sneaky way to set PersistentVars in a way that doesn't override the type, since these vars are isolated to LeaderLib

function LoadPersistentVars(skipCallback)
	--Required for tables like ReadBooks that are indexed by UserID
	Common.ConvertTableKeysToNumbers(PersistentVars, true)
	_SetPersistentVars(GameHelpers.PersistentVars.Update(defaultPersistentVars, PersistentVars))

	_PV = _GetPersistentVars()
	SkillManager.LoadSaveData()
	GameHelpers._INTERNAL.SanitizeSummonsData()
	if not skipCallback then
		Events.PersistentVarsLoaded:Invoke({})
	end
	Vars.PersistentVarsLoaded = true
end

function SetModIsActiveFlag(uuid, modid)
	--local flag = string.gsub(modid, "%s+", "_") -- Replace spaces
	local flag = tostring(modid).. "_IsActive"
	local flagEnabled = Osi.GlobalGetFlag(flag)
	if Ext.Mod.IsModLoaded(uuid) then
		if flagEnabled == 0 then
			Osi.GlobalSetFlag(flag)
		end
	else
		if flagEnabled == 1 then
			Osi.GlobalClearFlag(flag)
		end
	end
end

Ext.Require("Server/Classes/_Init.lua")
Ext.Require("Server/Data/BasePresets.lua")
Ext.Require("Server/Helpers/ActionHelpers.lua")
Ext.Require("Server/Helpers/MiscHelpers.lua")
Ext.Require("Server/Helpers/DatabaseHelpers.lua")
Ext.Require("Server/Helpers/CombatHelpers.lua")
Ext.Require("Server/Helpers/DamageHelpers.lua")
Ext.Require("Server/Helpers/HitHelpers.lua")
Ext.Require("Server/Helpers/ProjectileHelpers.lua")
Ext.Require("Server/Helpers/SkillBarHelpers.lua")
Ext.Require("Server/Helpers/SkillHelpers.lua")
Ext.Require("Server/Helpers/StatusHelpers.lua")
Ext.Require("Server/Helpers/PersistentVarsHelpers.lua")
Ext.Require("Server/Game/GameEvents.lua")
Ext.Require("Server/Game/OsirisEvents.lua")
Ext.Require("Server/Game/ComputeCharacterHit.lua")
Ext.Require("Server/Game/QualityOfLife.lua")
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
if Ext.Debug.IsDeveloperMode() then
	Ext.Require("Server/Debug/DebugMain.lua")
	Ext.Require("Server/Debug/DeveloperCommands.lua")
	if coroutine then
	Ext.Require("Server/Debug/CoroutineTests.lua")
	end
	Ext.Require("Shared/Debug/SharedDebug.lua")
end
Ext.Require("Server/Game/QOL/BuffStatusPreserver.lua")
Ext.Require("Server/Game/QOL/SkipTutorial.lua")
Ext.Require("Server/Game/QOL/CombatVacuum.lua")
if Ext.Utils.Version() >= 56 then
	Ext.Require("Shared/QOL/ExtenderVisualSupport.lua")
	Ext.Require("Shared/QOL/InventoryTweaks.lua")
end
Ext.Require("Server/Updates.lua")

---Set a character's name with a translated string value.
---@param char string
---@param handle string
---@param fallback string
function SetCustomNameWithLocalization(char,handle,fallback)
	local name,_ = Ext.L10N.GetTranslatedString(handle, fallback)
	Osi.CharacterSetCustomName(char, name)
end

Ext.Osiris.NewQuery(GetSkillEntryName, "LeaderLib_Ext_QRY_GetSkillEntryName", "[in](STRING)_SkillPrototype, [out](STRING)_SkillId")

local function RandomQRY(min,max)
	if min == nil then min = 0 end
	if max == nil then max = 0 end
	return Ext.Utils.Random(min,max)
end
Ext.Osiris.NewQuery(RandomQRY, "LeaderLib_Ext_Random", "[in](INTEGER)_Min, [in](INTEGER)_Max, [out](INTEGER)_Ran")

--Outdated editor version
if Ext.Utils.GameVersion() == "v3.6.51.9303" then
	--The lua helper goal contains 3 new events not in the editor version, so we swap this out to avoid the initial compile error in the editor
	Ext.IO.AddPathOverride("Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Story/RawFiles/Goals/LeaderLib_19_TS_LuaOsirisSubscription_Generated.txt", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/OutdatedEditorEventsFix.txt")
	Ext.IO.AddPathOverride("Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Story/RawFiles/Goals/__AAA_LeaderLib_19_TS_LuaOsirisSubscription.txt", "Mods/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/Overrides/OutdatedEditorQueriesFix.txt")
end

Events.Loaded:Invoke(nil)