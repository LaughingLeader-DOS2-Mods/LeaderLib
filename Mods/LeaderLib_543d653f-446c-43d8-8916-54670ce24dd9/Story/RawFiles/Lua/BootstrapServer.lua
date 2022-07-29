local function CanInvokeListener(anyLevelType)
	return Vars.Initialized == true and Ext.GetGameState() == "Running" and (anyLevelType or ((not anyLevelType and SharedData.RegionData.LevelType == LEVELTYPE.GAME)))
end

local _OsirisEventSubscribe = Ext.RegisterOsirisListener
if Ext.Version() >= 56 then
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

---@alias UUID string
---@alias NETID integer

---A parameter type that can be either item userdata, or a ID to ultimately retrieve that userdata via GameHelpers.GetItem.
---@see GameHelpers.GetItem
---@alias ItemParam EsvItem|EclItem|UUID|NETID|ComponentHandle

---A parameter type that can be either character userdata, or a ID to ultimately retrieve that userdata via GameHelpers.GetCharacter.
---@see GameHelpers.GetCharacter
---@alias CharacterParam EsvCharacter|EclCharacter|UUID|NETID|ComponentHandle
---@alias ObjectParam EsvCharacter|EclCharacter|EsvItem|EclItem|UUID|NETID|ComponentHandle
---@alias ServerObject EsvCharacter|EsvItem
---@alias ClientObject EclCharacter|EclItem

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
	KnockupData = {
		Active = false,
		---@type {ID:string, GUID:UUID, Start:number[], End:number[], Source:UUID, Skill:string, Falling:boolean}[]
		ObjectData = {}
	},
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

	---UserID to RootTemplate, to BookId
	---@type table<integer,table<string, string>>
	ReadBooks = {},

	---@class LeaderLibPersistentVisualsEntry
	---@field Resource string
	---@field Options ExtenderClientVisualOptions|nil
	---@field ExtraOptions LeaderLibClientVisualOptions|nil
	---@field Persistence LeaderLibClientVisualPersistenceOptions|nil
	---@field RestrictToVisual FixedString|nil If set, this visual will only be recreated if character.RootTemplate.VisualTemplate matches this value.

	---@type table<UUID,LeaderLibPersistentVisualsEntry[]>
	PersistentVisuals = {}
}


Ext.Require("BootstrapShared.lua")
Ext.Require("Shared/UI/CombatLog.lua")
Ext.Require("Shared/UI/MessageBox.lua")
Ext.Require("Shared/UI/Overhead.lua")
Ext.Require("Shared/System/TutorialManager.lua")

---@type LeaderLibPersistentVars
PersistentVars = Common.CloneTable(defaultPersistentVars, true)

function LoadPersistentVars(skipCallback)
	PersistentVars = GameHelpers.PersistentVars.Update(defaultPersistentVars, PersistentVars)
	SkillManager.LoadSaveData()
	if not skipCallback then
		Events.PersistentVarsLoaded:Invoke({})
	end
	Vars.PersistentVarsLoaded = true
end

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
if Ext.IsDeveloperMode() then
	Ext.Require("Server/Debug/DebugMain.lua")
	Ext.Require("Server/Debug/DeveloperCommands.lua")
	if coroutine then
	Ext.Require("Server/Debug/CoroutineTests.lua")
	end
	Ext.Require("Shared/Debug/SharedDebug.lua")
end
Ext.Require("Server/Game/QOL/BuffStatusPreserver.lua")
Ext.Require("Server/Game/QOL/SkipTutorial.lua")
if Ext.Version() >= 56 then
	Ext.Require("Shared/QOL/ExtenderVisualSupport.lua")
	Ext.Require("Shared/QOL/InventoryTweaks.lua")
end
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

Events.Loaded:Invoke(nil)