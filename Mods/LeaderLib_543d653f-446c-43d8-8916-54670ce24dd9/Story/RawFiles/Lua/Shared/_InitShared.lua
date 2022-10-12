---A collection of functions designed to make common tasks easier.  
---GameHelpers itself does not contain data.  
---@class LeaderLibGameHelpers
GameHelpers = {}

---@class LeaderLibQualityOfLifeTweaks
QOL = {}

---Manager tables that handle state changes and include ways to register callbacks for specific events.  
---@class LeaderLibManagers
Managers = {}

local function InitTable(name, target)
	target = target or Mods.LeaderLib
	if type(name) == "table" then
		for _,v in pairs(name) do
			target[v] = {}
		end
	elseif target[name] == nil then
		target[name] = {}
	end
end

InitTable("Classes")
InitTable("Common")
InitTable({"_INTERNAL", "Audio", "CC", "Damage", "Ext", "Item", "Math", "Net", "Skill", "Status", "Tooltip", "UI", "Utils"}, GameHelpers)

local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()
local _getTranslatedStringKeyFunction = Ext.L10N.GetTranslatedStringFromKey
local _getTranslatedStringFunction = Ext.L10N.GetTranslatedString

local _stringKeyText = {}

---Get the final value of a string key.
---This uses the handle returned from Ext.GetTranslatedStringFromKey to then get the text from Ext.GetTranslatedString.
---@param key string The string key.
---@param fallback string|nil Text to use if the key does not exist. Defaults to the key if not set.
---@return string
function GameHelpers.GetStringKeyText(key,fallback)
	fallback = fallback or key
	local text = _stringKeyText[key]
	if text == nil then
		text = _getTranslatedStringKeyFunction(key)
		if StringHelpers.IsNullOrEmpty(text) then
			text = fallback
		end
		_stringKeyText[key] = text
	end
	return text
end

---Get the content of a TranslatedString.
---@param handle string The string handle.
---@param fallback string|nil Text to use if the key does not exist. Defaults to the key if not set.
---@return string
function GameHelpers.GetTranslatedString(handle,fallback)
	fallback = fallback or handle
	local text = _getTranslatedStringFunction(handle, fallback)
	if text == nil then
		return fallback
	end
	return text
end

---@class ExtenderTranslatedString
---@field Handle string
---@field ReferenceString string

---@class ExtenderTranslatedStringObject
---@field ArgumentString ExtenderTranslatedString
---@field Handle ExtenderTranslatedString

---Gets the value from an extender TranslatedString. Either the ReferenceString if unset, or the localized handle value.
---@param object ExtenderTranslatedStringObject
---@param fallback string|nil
---@return string
function GameHelpers.GetTranslatedStringValue(object, fallback)
	if _EXTVERSION < 56 then
		return not StringHelpers.IsNullOrEmpty(object) and object or fallback
	else
		if type(object) == "string" then
			if string.sub(object, 1, 1) == "h" then
				return GameHelpers.GetTranslatedString(object, fallback)
			end
			return GameHelpers.GetStringKeyText(object, fallback)
		end
		local refString = object.Handle and object.Handle.ReferenceString or ""
		if StringHelpers.IsNullOrEmpty(refString) and object.ArgumentString then
			refString = object.ArgumentString.ReferenceString
		end
		if object.Handle and object.Handle.Handle ~= StringHelpers.UNSET_HANDLE then
			return _getTranslatedStringFunction(object.Handle.Handle, object.Handle.ReferenceString)
		elseif not StringHelpers.IsNullOrEmpty(refString) then
			return refString
		end
	end
	return fallback or ""
end

---Simple wrapper around assigning a variable to another without making EmmyLua pick up the result.
function GameHelpers.SetVariable(v1,v2)
	v1 = v2
end

if Timer == nil then
	Timer = {}
end
Vars = {
	Initialized = false,
	PersistentVarsLoaded = false,
	PostLoadEnableLuaListeners = false,
	JustReset = false,
	LeaveActionData = {
		Prefixes = {},
		Statuses = {},
		Total = 0
	},
	---Temporary list of zone skills to listen for during OnHit, to then apply SkillProperties.
	---@see GameHelpers.Skill.ShootZoneAt
	---@type table<UUID,string>
	ApplyZoneSkillProperties = {},
	Commands = {
		CooldownsDisabled = false,
		Teleporting = false,
	},
	DebugMode = Ext.Debug.IsDeveloperMode() == true,
	DebugSettings = {
		DisplayExtraContextMenuOptions = false,
	},
	LeaderDebugMode = false,
	---The last GUID of a context menu object, in developer mode.
	---@type UUID|nil
	LastContextTarget = nil,
	Print = {
		HitPrepare = false,
		Hit = false,
		SpammyHits = false, -- To ignore surface and dots, because they get spammy
		Skills = false,
		CustomStats = false,
		--UI listeners
		UI = false,
		--TreasureItemGenerated stuff
		Treasure = false,
		Input = false
	},
	ControllerEnabled = false,
	Users = {},
	IsEditorMode = false,
	IsClient = Ext.IsClient(),
	ConsoleWindowVariables = {},
	RaceData = {
		Dwarf = {Tag="DWARF", BaseTag = "DWARF"},
		Elf = {Tag="ELF", BaseTag = "ELF"},
		Human = {Tag="HUMAN", BaseTag = "HUMAN"},
		Lizard = {Tag="LIZARD", BaseTag = "LIZARD"},
		Undead_Dwarf = {Tag="UNDEAD_DWARF", BaseTag = "DWARF"},
		Undead_Elf = {Tag="UNDEAD_ELF", BaseTag = "ELF"},
		Undead_Human = {Tag="UNDEAD_HUMAN", BaseTag = "HUMAN"},
		Undead_Lizard = {Tag="UNDEAD_LIZARD", BaseTag = "LIZARD"},
	},
	---Table of base game stat fixes.
	StatFixes = {},
	Overrides = {
		SPIRIT_VISION_PROPERTY = {
			Action = "ToggleStatus",
			Context = {"Self"},
			Arg1 = 1.0,
			Arg2 = -1,
			Arg3 = "SPIRIT_VISION",
			Arg4 = 1, -- Make permanent, i.e. it's re-applied when resurrected, and blocked from deletion
			Arg5 = 10, -- Default duration
			Type = "Extender",
		}
	},
	Version = Ext.Utils.Version(),
	StatusEvent = {
		BeforeAttempt = "BeforeAttempt",
		Attempt = "Attempt",
		Applied = "Applied",
		BeforeDelete = "BeforeDelete",
		Removed = "Removed",
	},
	GetModInfoIgnoredMods = {
		--["7e737d2f-31d2-4751-963f-be6ccc59cd0c"] = true,--LeaderLib
		["2bd9bdbe-22ae-4aa2-9c93-205880fc6564"] = true,--Shared
		["eedf7638-36ff-4f26-a50a-076b87d53ba0"] = true,--Shared_DOS
		["1301db3d-1f54-4e98-9be5-5094030916e4"] = true,--Divinity: Original Sin 2
		["a99afe76-e1b0-43a1-98c2-0fd1448c223b"] = true,--Arena
		["00550ab2-ac92-410c-8d94-742f7629de0e"] = true,--Game Master
		--["015de505-6e7f-460c-844c-395de6c2ce34"] = true,--Nine Lives
		--["38608c30-1658-4f6a-8adf-e826a5295808"] = true,--Herb Gardens
		--["1273be96-6a1b-4da9-b377-249b98dc4b7e"] = true,--Source Meditation
		--["af4b3f9c-c5cb-438d-91ae-08c5804c1983"] = true,--From the Ashes
		--["ec27251d-acc0-4ab8-920e-dbc851e79bb4"] = true,--Endless Runner
		["b40e443e-badd-4727-82b3-f88a170c4db7"] = true,--Character_Creation_Pack
		["9b45f7e5-d4e2-4fc2-8ef7-3b8e90a5256c"] = true,--8 Action Points
		--["f33ded5d-23ab-4f0c-b71e-1aff68eee2cd"] = true,--Hagglers
		--["68a99fef-d125-4ed0-893f-bb6751e52c5e"] = true,--Crafter's Kit
		--["ca32a698-d63e-4d20-92a7-dd83cba7bc56"] = true,--Divine Talents
		--["f30953bb-10d3-4ba4-958c-0f38d4906195"] = true,--Combat Randomiser
		--["423fae51-61e3-469a-9c1f-8ad3fd349f02"] = true,--Animal Empathy
		--["2d42113c-681a-47b6-96a1-d90b3b1b07d3"] = true,--Fort Joy Magic Mirror
		--["8fe1719c-ef8f-4cb7-84bd-5a474ff7b6c1"] = true,--Enhanced Spirit Vision
		["a945eefa-530c-4bca-a29c-a51450f8e181"] = true,--Sourcerous Sundries -- Overrides everything
		["f243c84f-9322-43ac-96b7-7504f990a8f0"] = true,--Improved Organisation
		["d2507d43-efce-48b8-ba5e-5dd136c715a7"] = true,--Pet Power
		["3da57b9d-8b41-46c7-a33c-afb31eea38a3"] = true,--Armor Sets
	}
}

if not _ISCLIENT then
	---If a mod registers a listener for an ignored status (such as HIT), it will be added to this table to allow callbacks to run for that status.
	---@type table<string,boolean>
	Vars.RegisteredIgnoredStatus = {}
end

function PrintDebug(...)
	if Vars.DebugMode and Vars.LeaderDebugMode then
		--local lineNum = debug.getinfo(1).currentline
		--local lineInfo = string.format("[%s:%s]", currentFileName(), debug.getinfo(1).currentline)
		Ext.Utils.Print(...)
	end
end

function PrintLog(str, ...)
	Ext.Utils.Print(string.format(str, ...))
	print(string.format(str, ...))
end

--- Adds a prefix to check statuses for when building Vars.LeaveActionData
---@param prefix string
function RegisterLeaveActionPrefix(prefix)
	table.insert(Vars.LeaveActionData.Prefixes, prefix)
end

---@type LeaderLibGameSettingsWrapper
GameSettings = {Settings = {}, Loaded = false}

---@class GlobalSettings
GlobalSettings = {
	---@type table<string, ModSettings>
	Mods = {},
	Version = -1,
}

IgnoredMods = {
	--["7e737d2f-31d2-4751-963f-be6ccc59cd0c"] = true,--LeaderLib
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
	["3da57b9d-8b41-46c7-a33c-afb31eea38a3"] = true,--Armor Sets
}

---@alias DoHitCallback fun(hit:StatsHitDamageInfo, damageList:DamageList, statusBonusDmgTypes:DamageList, hitType:string, target:StatCharacter, attacker:StatCharacter):StatsHitDamageInfo

---@alias ApplyDamageCharacterBonusesCallback fun(character:StatCharacter, attacker:StatCharacter, damageList:DamageList, preModifiedDamageList:StatsDamagePairList[], resistancePenetration:table<string,integer>)

Ext.Require("Shared/Listeners.lua")

---@deprecated
SkillListeners = {}
ModListeners = {
	Registered = {},
	Updated = {},
	Loaded = {},
}

LocalizedText = {}

---@class LeaderLibFeatures
Features = {
	---Applies ExtraProperties from BonusWeapon stats in active statuses, on basic attack or hit with a skill that has UseWeaponProperties.
	ApplyBonusWeaponStatuses = false,
	---Allows backstabs to happen with various conditions (like from spells or non-daggers), depending on game settings.
	BackstabCalculation = false,
	---Disables the LeaderLib ComputeCharactreHit listener.
	DisableHitOverrides = false,
	---Fixes the lack of a damage name for chaos damage in skills/statuses.
	FixChaosDamageDisplay = true,
	---Fixes chaos damage not being applied correctly when from projectile weapons (wands).
	FixChaosWeaponProjectileDamage = true,
	---Changes Corrosive/Magic damage tooltip text from "Reduce Armor" to proper damage names.
	FixCorrosiveMagicDamageDisplay = false,
	---Fixes the incorrect skill tooltip range when you have Far Out Man.
	FixFarOutManSkillRangeTooltip = false,
	---Fixes the item tooltip AP cost being incorrect when a character has statuses that reduce AP costs.
	FixItemAPCost = true,
	---Fixes the lack of a damage name for pure type damage in tooltips.
	FixPureDamageDisplay = true,
	---Fixes the lack of a damage name for Sulfuric damage in tooltips.
	FixSulfuricDamageDisplay = true,
	---Fixes the lack of a damage name for Sentinel damage in tooltips.
	FixSentinelDamageDisplay = true,
	---Fixes tooltips not displaying "Requires a Rifle" when they have a RifleRequirement.
	FixRifleWeaponRequirement = false,
	---Fixed tag requirements for skills being ignored by skills granted by items. Also fixes tag changes not updating the hotbar.
	FixSkillTagRequirements = false,
	---Remove empty SkillProperty.Properties elements from skill tooltips.
	FixTooltipEmptySkillProperties = false,
	---Formats tag element tooltips after they've been added to flash, allowing html font colors and more.
	FormatTagElementTooltips = false,
	---Condenses item tooltips by simplifying the ExtraProperties text.
	ReduceTooltipSize = true,
	---Replaces various LeaderLib placeholders in tooltips.
	ReplaceTooltipPlaceholders = true,
	---Linked to a GameSettings option, allows various percentages of resistances to be ignored.
	ResistancePenetration = false,
	---Linked to a GameSettings option, allows spells to crit without the associated talent.
	SpellsCanCrit = false,
	---Fixes statuses not displaying skill damage correctly when using the Skill:SkillId:Damage param.
	StatusParamSkillDamage = false,
	---Display the status source in status tooltips.
	StatusDisplaySource = true,
	---Display the status type and ID in status tooltips.
	DisplayDebugInfoInTooltips = Ext.Debug.IsDeveloperMode(),
	---Fixes various tooltip things like extra spaces and grammar issues.
	TooltipGrammarHelper = false,
	---Enables a workaround for requiring WINGS or PURE to make characters play the flying animation when moving around.
	WingsWorkaround = false,
}

Importer = {
	SetupVarsMetaTable = function(targetModTable)
		local meta = {}
		if targetModTable.Vars ~= nil and getmetatable(targetModTable.Vars) then
			meta = getmetatable(targetModTable.Vars)
		end
		if meta.__index == nil then
			meta.__index = Vars
		else
			local lastIndexer = meta.__index
			local indexerType = type(lastIndexer)
			meta.__index = function (tbl, k)
				if Vars[k] ~= nil then
					return Vars[k]
				end
				if indexerType == "function" then
					return lastIndexer(tbl, k)
				else
					return lastIndexer[k]
				end
			end
		end
		if targetModTable.Vars == nil then
			rawset(targetModTable, "Vars", {})
		end
		setmetatable(targetModTable.Vars, meta)
	end,
	PrivateKeys = {
		--lua base
		--[[ ["_G"] = true,
		tonumber = true,
		pairs = true,
		ipairs = true,
		table = true,
		tostring = true,
		math = true,
		type = true,
		print = true,
		error = true,
		next = true,
		string = true,
		rawget = true,
		rawset = true,
		--ositools base
		Sandboxed = true,
		Game = true,
		Ext = true,
		Osi = true, ]]
		ModuleUUID = true,
		PersistentVars = true,
		LoadPersistentVars = true,
		--LeaderLib ignores
		Debug = true,
		Vars = true,
		Listeners = true,
		SkillListeners = true,
		ModListeners = true,
		Settings = true,
		Importer = true,
		ImportUnsafe = true,
		Import = true,
		CustomSkillProperties = true,
		_PV = true,
	},
	GetIndexer = function(originalGetIndex, additionalTable)
		local getIndex = function(tbl, k)
			if k == "LeaderLib" then
				return Mods.LeaderLib
			end
			if not Importer.PrivateKeys[k] then
				if additionalTable and additionalTable[k] then
					return additionalTable[k]
				end
				if Mods.LeaderLib[k] ~= nil then
					return Mods.LeaderLib[k]
				end
			end
			if originalGetIndex then
				return originalGetIndex(tbl, k)
			end
		end
		return getIndex
	end
}

---Makes LeaderLib's globals accessible using metamethod magic. Pass it a mod table, such as Mods.MyModTable.
---@param targetModTable table
---@param additionalTable table|nil An additional table to use for __index lookup.
function Import(targetModTable, additionalTable)
	Importer.SetupVarsMetaTable(targetModTable)
	local targetMeta = getmetatable(targetModTable)
	if not targetMeta then
		setmetatable(targetModTable, {
			__index = Importer.GetIndexer(nil, additionalTable)
		})
	else
		local targetOriginalGetIndex = nil
		if targetMeta.__index then
			if type(targetMeta.__index) == "function" then
				targetOriginalGetIndex = targetMeta.__index
			else
				local originalIndex = targetMeta.__index
				targetOriginalGetIndex = function(tbl,k)
					return originalIndex[k]
				end
			end
		end
		targetMeta.__index = Importer.GetIndexer(targetOriginalGetIndex, additionalTable)
	end
end

---DEPRECATED
---Makes LeaderLib's globals accessible using metamethod magic. Pass it a mod table, such as Mods.MyModTable.
---This is the same as the regular Import now.
---@deprecated
---@param targetModTable table
function ImportUnsafe(targetModTable)
	Import(targetModTable)
end

--Outdated editor version
if Ext.GameVersion() == "v3.6.51.9303" then
	Vars.IsEditorMode = true
end