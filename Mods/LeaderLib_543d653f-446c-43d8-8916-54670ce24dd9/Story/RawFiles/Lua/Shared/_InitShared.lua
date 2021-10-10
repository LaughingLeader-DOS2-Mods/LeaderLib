Classes = {}
Common = {}
---@class GameHelpers
GameHelpers = {
	Item = {},
	Math = {},
	Skill = {},
	Status = {},
	Tooltip = {},
	UI = {},
	Ext = {},
	Internal = {}
}

---Simple wrapper around assigning a variable to another without making EmmyLua pick up the result.
function GameHelpers.SetVariable(v1,v2)
	v1 = v2
end

if Timer == nil then
	Timer = {}
end
Vars = {
	Initialized = false,
	PostLoadEnableLuaListeners = false,
	JustReset = false,
	LeaveActionData = {
		Prefixes = {},
		Statuses = {},
		Total = 0
	},
	Commands = {
		CooldownsDisabled = false,
		Teleporting = false,
	},
	DebugMode = Ext.IsDeveloperMode() == true,
	LeaderDebugMode = false,
	Print = {
		HitPrepare = false,
		Hit = false,
		SpammyHits = false, -- To ignore surface and dots, because they get spammy
		Skills = false,
		CustomStats = false,
		--UI listeners
		UI = false,
		Input = false
	},
	ControllerEnabled = false,
	Users = {},
	IsEditorMode = false,
	ConsoleWindowVariables = {},
}

function PrintDebug(...)
	if Vars.DebugMode then
		--local lineNum = debug.getinfo(1).currentline
		--local lineInfo = string.format("[%s:%s]", currentFileName(), debug.getinfo(1).currentline)
		print(...)
	end
end

function PrintLog(str, ...)
	Ext.Print(string.format(str, ...))
	print(string.format(str, ...))
end

---@class LOGLEVEL
LOGLEVEL = {
	--- Ext.Print
	DEFAULT = 0,
	--- print, will allow the message to show up when in input mode in the command window.
	TRACE = 1,
	--- Ext.PrintWarning
	WARNING = 2,
	--- Ext.PrintError
	ERROR = 3,
	--- Ext.Print if in DeveloperMode
	TRACE2 = 4,
}

---Prints a string formatted message with optional severity.
---@param severity integer|LOGLEVEL
---@param str string
function fprint(severity, str, ...)
	if type(severity) == "string" then
		if string.find(severity, "%s", 1, true) then
			Ext.Print(string.format(severity, str, ...))
		else
			Ext.Print(severity, str, ...)
		end
	elseif type(str) == "string" then
		local msg = string.format(str, ...)
		if severity == LOGLEVEL.ERROR then
			Ext.PrintError(msg)
		elseif severity == LOGLEVEL.WARNING then
			Ext.PrintWarning(msg)
		elseif severity == LOGLEVEL.TRACE then
			if Vars.DebugMode then
				print(msg)
			end
		elseif severity == LOGLEVEL.TRACE2 then
			if Vars.DebugMode then
				Ext.Print(msg)
			end
		else
			Ext.Print(msg)
		end
	else
		print(severity,str,...)
	end
end

--- Adds a prefix to check statuses for when building Vars.LeaveActionData
---@param prefix string
function RegisterLeaveActionPrefix(prefix)
	table.insert(Vars.LeaveActionData.Prefixes, prefix)
end

---@type LeaderLibGameSettings
GameSettings = {Settings = {}}

---@class GlobalSettings
GlobalSettings = {
	---@type table<string, ModSettings>
	Mods = {},
	Version = Ext.GetModInfo("7e737d2f-31d2-4751-963f-be6ccc59cd0c").Version,
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

---@alias DoHitCallback fun(hit:HitRequest, damageList:DamageList, statusBonusDmgTypes:DamageList, string:HitType, target:StatCharacter, attacker:StatCharacter):HitRequest

---@alias ApplyDamageCharacterBonusesCallback fun(character:StatCharacter, attacker:StatCharacter, damageList:DamageList, preModifiedDamageList:DamageItem[], resistancePenetration:table<string,integer>)

Ext.Require("Shared/Listeners.lua")

SkillListeners = {}
ModListeners = {
	Registered = {},
	Updated = {},
	Loaded = {},
}

LocalizedText = {}

---@type TranslatedString[]
TranslatedStringEntries = {}

---@type table<string,boolean>
Features = {
	BackstabCalculation = false,
	FixPureDamageDisplay = true,
	FixChaosDamageDisplay = true,
	FixChaosWeaponProjectileDamage = true,
	FixCorrosiveMagicDamageDisplay = false,
	FixItemAPCost = true,
	RacialTalentsDisplayFix = true,
	ReduceTooltipSize = true,
	ReplaceTooltipPlaceholders = false,
	ResistancePenetration = false,
	StatusParamSkillDamage = false,
	TooltipGrammarHelper = false,
	WingsWorkaround = false,
	FixRifleWeaponRequirement = false,
	FixFarOutManSkillRangeTooltip = false,
	CustomStatsSystem = false
}

Importer = {
	SetupVarsMetaTable = function(targetModTable)
		local meta = targetModTable.Vars and getmetatable(targetModTable.Vars) or {}
		if not meta.__index then
			meta.__index = Vars
		end
		if not targetModTable.Vars then
			targetModTable.Vars = {}
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
		ImportUnsafe = true,
		Import = true,
		CustomSkillProperties = true,
	},
	GetIndexer = function(originalGetIndex, additionalTable)
		local getIndex = function(tbl, k)
			if k == "LeaderLib" then
				return Mods.LeaderLib
			end
			if Importer.PrivateKeys[k] then
				return nil
			end
			if additionalTable and additionalTable[k] then
				return additionalTable[k]
			end
			if Mods.LeaderLib[k] then
				return Mods.LeaderLib[k]
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

---Makes LeaderLib's globals accessible using metamethod magic. Pass it a mod table, such as Mods.MyModTable.
---This is the same as the regular Import now.
---@param targetModTable table
function ImportUnsafe(targetModTable)
	Import(targetModTable)
end

--[[
--Old import stuff.

--Data/table imports.
local imports = {
	All = {
		"LOGLEVEL",
		"StringHelpers",
		"GameHelpers",
		"TableHelpers",
		"Common",
		"SharedData",
		"LocalizedText",
		"LEVELTYPE",
		"Classes",
		"Data",
		"Timer",
	},
	Server = {
		"SKILL_STATE",
	},
	Client = {
		"UI",
		"Client"
	}
}

---[DEPRECATED]
---Imports specific 'safe' LeaderLib globals to the target table.
---@param targetModTable table
---@param skipExistingCheck boolean If true, each key is set in the target table without checking if it already exists.
local function ImportOld(targetModTable, skipExistingCheck)
	SetupMetaTables(targetModTable)
	local modName = Ext.GetModInfo(targetModTable.ModuleUUID)
	if modName then
		modName = modName.Name
	else
		modName = targetModTable.ModuleUUID
	end
	for _,k in pairs(imports.All) do
		if skipExistingCheck == true or not targetModTable[k] then
			targetModTable[k] = Mods.LeaderLib[k]
		elseif Vars.DebugMode and not Vars.ConsoleWindowVariables[k] then
			fprint(LOGLEVEL.WARNING, "Global key (%s) already exists in mod table for mod (%s)", k, modName)
		end
	end
	-- Automatically importing global functions
	for k,v in pairs(Mods.LeaderLib) do
		if ignoreImports[k] ~= true and type(v) == "function" then
			if skipExistingCheck == true or not targetModTable[k] then
				targetModTable[k] = v
			elseif Vars.DebugMode and not Vars.ConsoleWindowVariables[k] then
				fprint(LOGLEVEL.WARNING, "Global function (%s) already exists in mod table for mod (%s)", k, modName)
			end
		end
	end
	if Ext.IsServer() then
		for _,k in pairs(imports.Server) do
			if skipExistingCheck == true or not targetModTable[k] then
				targetModTable[k] = Mods.LeaderLib[k]
			elseif Vars.DebugMode and not Vars.ConsoleWindowVariables[k] then
				fprint(LOGLEVEL.WARNING, "Global key (%s) already exists in mod table for mod (%s)", k, modName)
			end
		end
	else
		for _,k in pairs(imports.Client) do
			if skipExistingCheck == true or not targetModTable[k] then
				targetModTable[k] = Mods.LeaderLib[k]
			elseif Vars.DebugMode and not Vars.ConsoleWindowVariables[k] then
				fprint(LOGLEVEL.WARNING, "Global key (%s) already exists in mod table for mod (%s)", k, modName)
			end
		end
	end
end

---[DEPRECATED]
---Imports all of LeaderLib's globals to the target table, excluding PersistentVars and some truly unsafe tables.
---@param targetModTable table
---@param skipExistingCheck boolean If true, each key is set in the target table without checking if it already exists.
local function ImportUnsafeOld(targetModTable, skipExistingCheck)
	SetupMetaTables(targetModTable)
	local modName = Ext.GetModInfo(targetModTable.ModuleUUID)
	if modName then
		modName = modName.Name
	else
		modName = targetModTable.ModuleUUID
	end
	for k,v in pairs(Mods.LeaderLib) do
		if ignoreImports[k] ~= true then
			if skipExistingCheck == true or not targetModTable[k] then
				targetModTable[k] = v
			elseif Vars.DebugMode and not Vars.ConsoleWindowVariables[k] then
				fprint(LOGLEVEL.WARNING, "[LeaderLib:ImportUnsafe] Global key (%s) already exists in mod table for mod (%s)", k, modName)
			end
		end
	end
end
]]