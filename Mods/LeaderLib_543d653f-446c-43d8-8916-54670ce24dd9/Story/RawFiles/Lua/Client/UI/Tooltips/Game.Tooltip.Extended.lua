local Ext = Ext
local Mods = Mods
local assert = assert
local debug = debug
local ipairs = ipairs
local math = math
local pairs = pairs
local pcall = pcall
local xpcall = xpcall
local print = print
local setmetatable = setmetatable
local string = string
local table = table
local tostring = tostring
local type = type

local _EXTVERSION = Ext.Version()
local _DEBUG = Ext.IsDeveloperMode()

local _UITYPE = Data.UIType

local _GetCharacter = Ext.GetCharacter
local _GetGameState = Ext.GetGameState

local _GetUIByType = Ext.GetUIByType
local _GetUIByPath = Ext.GetBuiltinUI

local _HandleToDouble = Ext.HandleToDouble
local _DoubleToHandle = Ext.DoubleToHandle
local _IsValidHandle = GameHelpers.IsValidHandle

local _Stringify = Common.JsonStringify
local _IsNaN = GameHelpers.Math.IsNaN

local _RegisterUITypeInvokeListener = Ext.RegisterUITypeInvokeListener
local _RegisterRegisterUITypeCall = Ext.RegisterUITypeCall
local _RegisterUINameCall = Ext.RegisterUINameCall
local _RegisterUINameInvokeListener = Ext.RegisterUINameInvokeListener

local _Require = Ext.Require

local _Print = Ext.Print
local _PrintWarning = Ext.PrintWarning
local _PrintError = Ext.PrintError
local _Dump = Ext.Dump
local _DumpExport = Ext.DumpExport

if Game == nil then
	Game = {}
end

if Game.Tooltip == nil then
	Game.Tooltip = {}
end

---@type GameTooltipRequestProcessor
local RequestProcessor = _Require("Client/UI/Tooltips/TooltipRequestProcessor.lua")
Game.Tooltip.RequestProcessor = RequestProcessor

local game = Game
_ENV = Game.Tooltip
_ENV.Game = game
---@diagnostic disable deprecated
if setfenv ~= nil then
	setfenv(1, Game.Tooltip)
end
---@diagnostic enable

---@class GameTooltipControllerVars
---@field LastPlayer integer The NetID of the last player character.
---@field LastOverhead number The double handle of the overhead object.
local ControllerVars = {}
Game.Tooltip.ControllerVars = ControllerVars

local tooltipCustomIcons = {}

---Add a custom icon to the tooltip UI.  
---Use this with tooltip elements that have an Icon string property, such as WandSkill.
---@param id string
---@param icon string
---@param w integer
---@param h integer
function Game.Tooltip.AddCustomIconToTooltip(id, icon, w, h)
	local ui = _GetUIByType(_UITYPE.tooltip)
	if ui then
		ui:SetCustomIcon(id, icon, w, h)
		tooltipCustomIcons[#tooltipCustomIcons+1] = id
	end
end

TooltipItemIds = {
	"ItemName","ItemWeight","ItemGoldValue","ItemLevel","ItemDescription","ItemRarity","ItemUseAPCost","ItemAttackAPCost","StatBoost",
	"ResistanceBoost","AbilityBoost","OtherStatBoost","VitalityBoost","ChanceToHitBoost","DamageBoost","APCostBoost","APMaximumBoost",
	"APStartBoost","APRecoveryBoost","CritChanceBoost","ArmorBoost","ConsumableDuration","ConsumablePermanentDuration","ConsumableEffect",
	"ConsumableDamage","ExtraProperties","Flags","ItemRequirement","WeaponDamage","WeaponDamagePenalty","WeaponCritMultiplier","WeaponCritChance",
	"WeaponRange","Durability","CanBackstab","AccuracyBoost","DodgeBoost","EquipmentUnlockedSkill","WandSkill","WandCharges","ArmorValue",
	"ArmorSlotType","Blocking","NeedsIdentifyLevel","IsQuestItem","PriceToIdentify","PriceToRepair","PickpocketInfo","Engraving",
	"ContainerIsLocked","SkillName","SkillIcon","SkillSchool","SkillTier","SkillRequiredEquipment","SkillAPCost","SkillCooldown",
	"SkillDescription","SkillProperties","SkillDamage","SkillRange","SkillExplodeRadius","SkillCanPierce","SkillCanFork","SkillStrikeCount",
	"SkillProjectileCount","SkillCleansesStatus","SkillMultiStrikeAttacks","SkillWallDistance","SkillPathSurface","SkillPathDistance",
	"SkillHealAmount","SkillDuration","ConsumableEffectUknown","Reflection","SkillAlreadyLearned","SkillOnCooldown","SkillAlreadyUsed",
	"AbilityTitle","AbilityDescription","TalentTitle","TalentDescription","SkillMPCost","MagicArmorValue","WarningText","RuneSlot",
	"RuneEffect","Equipped","ShowSkillIcon","SkillbookSkill","Tags","EmptyRuneSlot","StatName","StatsDescription","StatsDescriptionBoost",
	"StatSTRWeight","StatMEMSlot","StatsPointValue","StatsTalentsBoost","StatsTalentsMalus","StatsBaseValue","StatsPercentageBoost",
	"StatsPercentageMalus","StatsPercentageTotal","StatsGearBoostNormal","StatsATKAPCost","StatsCriticalInfos","StatsAPTitle","StatsAPDesc",
	"StatsAPBase","StatsAPBonus","StatsAPMalus","StatsTotalDamage","TagDescription","StatusImmunity","StatusBonus","StatusMalus","StatusDescription",
	"Title","SurfaceDescription","Duration","Fire","Water","Earth","Air","Poison","Physical","Sulfur","Heal","Splitter","ArmorSet"
}
TooltipItemTypes = {
	ItemName = 1,
	ItemWeight = 2,
	ItemGoldValue = 3,
	ItemLevel = 4,
	ItemDescription = 5,
	ItemRarity = 6,
	ItemUseAPCost = 7,
	ItemAttackAPCost = 8,
	StatBoost = 9,
	ResistanceBoost = 10,
	AbilityBoost = 11,
	OtherStatBoost = 12,
	VitalityBoost = 13,
	ChanceToHitBoost = 14,
	DamageBoost = 15,
	APCostBoost = 16,
	APMaximumBoost = 17,
	APStartBoost = 18,
	APRecoveryBoost = 19,
	CritChanceBoost = 20,
	ArmorBoost = 21,
	ConsumableDuration = 22,
	ConsumablePermanentDuration = 23,
	ConsumableEffect = 24,
	ConsumableDamage = 25,
	ExtraProperties = 26,
	Flags = 27,
	ItemRequirement = 28,
	WeaponDamage = 29,
	WeaponDamagePenalty = 30,
	WeaponCritMultiplier = 31,
	WeaponCritChance = 32,
	WeaponRange = 33,
	Durability = 34,
	CanBackstab = 35,
	AccuracyBoost = 36,
	DodgeBoost = 37,
	EquipmentUnlockedSkill = 38,
	WandSkill = 39,
	WandCharges = 40,
	ArmorValue = 41,
	ArmorSlotType = 42,
	Blocking = 43,
	NeedsIdentifyLevel = 44,
	IsQuestItem = 45,
	PriceToIdentify = 46,
	PriceToRepair = 47,
	PickpocketInfo = 48,
	Engraving = 49,
	ContainerIsLocked = 50,
	SkillName = 51,
	SkillIcon = 52,
	SkillSchool = 53,
	SkillTier = 54,
	SkillRequiredEquipment = 55,
	SkillAPCost = 56,
	SkillCooldown = 57,
	SkillDescription = 58,
	SkillProperties = 59,
	SkillDamage = 60,
	SkillRange = 61,
	SkillExplodeRadius = 62,
	SkillCanPierce = 63,
	SkillCanFork = 64,
	SkillStrikeCount = 65,
	SkillProjectileCount = 66,
	SkillCleansesStatus = 67,
	SkillMultiStrikeAttacks = 68,
	SkillWallDistance = 69,
	SkillPathSurface = 70,
	SkillPathDistance = 71,
	SkillHealAmount = 72,
	SkillDuration = 73,
	ConsumableEffectUknown = 74,
	Reflection = 75,
	SkillAlreadyLearned = 76,
	SkillOnCooldown = 77,
	SkillAlreadyUsed = 78,
	AbilityTitle = 79,
	AbilityDescription = 80,
	TalentTitle = 81,
	TalentDescription = 82,
	SkillMPCost = 83,
	MagicArmorValue = 84,
	WarningText = 85,
	RuneSlot = 86,
	RuneEffect = 87,
	Equipped = 88,
	ShowSkillIcon = 89,
	SkillbookSkill = 90,
	Tags = 91,
	EmptyRuneSlot = 92,
	StatName = 93,
	StatsDescription = 94,
	StatsDescriptionBoost = 95,
	StatSTRWeight = 96,
	StatMEMSlot = 97,
	StatsPointValue = 98,
	StatsTalentsBoost = 99,
	StatsTalentsMalus = 100,
	StatsBaseValue = 101,
	StatsPercentageBoost = 102,
	StatsPercentageMalus = 103,
	StatsPercentageTotal = 104,
	StatsGearBoostNormal = 105,
	StatsATKAPCost = 106,
	StatsCriticalInfos = 107,
	StatsAPTitle = 108,
	StatsAPDesc = 109,
	StatsAPBase = 110,
	StatsAPBonus = 111,
	StatsAPMalus = 112,
	StatsTotalDamage = 113,
	TagDescription = 114,
	StatusImmunity = 115,
	StatusBonus = 116,
	StatusMalus = 117,
	StatusDescription = 118,
	Title = 119,
	SurfaceDescription = 120,
	Duration = 121,
	Fire = 122,
	Water = 123,
	Earth = 124,
	Air = 125,
	Poison = 126,
	Physical = 127,
	Sulfur = 128,
	Heal = 129,
	Splitter = 130,
	ArmorSet = 131,
}

Game.Tooltip.TooltipItemTypes = TooltipItemTypes

local _Label = {"Label", "string"}
local _Value = {"Value", "string"}
local _NumValue = {"Value", "number"}
local _Icon = {"Icon", "string"}
local _Warning = {"Warning", "string"}
local _Unused = {nil, nil}
local BoostSpec = {_Label, _NumValue, _Unused}
TooltipSpecs = {
	ItemName = {_Label},
	ItemWeight = {_Label, _Unused},
	ItemGoldValue = {_Label},
	ItemLevel = {_Label, _NumValue, _Unused},
	ItemDescription = {_Label},
	ItemRarity = {_Label},
	ItemUseAPCost = {_Label, _NumValue, {"RequirementMet", "boolean"}},
	ItemAttackAPCost = {_Label, _NumValue, _Warning, {"RequirementMet", "boolean"}},
	StatBoost = BoostSpec,
	ResistanceBoost = BoostSpec,
	AbilityBoost = BoostSpec,
	OtherStatBoost = {_Label, _Value, _Unused, _Unused},
	VitalityBoost = BoostSpec,
	ChanceToHitBoost = BoostSpec,
	DamageBoost = BoostSpec,
	APCostBoost = BoostSpec,
	APMaximumBoost = BoostSpec,
	APStartBoost = BoostSpec,
	APRecoveryBoost = BoostSpec,
	CritChanceBoost = BoostSpec,
	ArmorBoost = BoostSpec,
	ConsumableDuration = {_Label, _Unused, _Unused, _Value},
	ConsumablePermanentDuration = {_Label, _Value},
	ConsumableEffect = {_Label, _Unused, _Value, _Unused},
	ConsumableDamage = {_Unused, {"MinDamage", "number"}, {"MaxDamage", "number"}, {"DamageType", "number"}, _Label},
	ExtraProperties = {_Label, _Unused, _Unused, _Unused, _Unused},
	Flags = {_Label, _Unused, _Unused},
	ItemRequirement = {_Label, _Unused, {"RequirementMet", "boolean"}},
	WeaponDamage = {{"MinDamage", "number"}, {"MaxDamage", "number"}, _Label, {"DamageType", "number"}, _Unused},
	WeaponDamagePenalty = {_Label},
	WeaponCritMultiplier = {_Label, _Unused, _Unused, _Unused, _Value},
	WeaponCritChance = {_Label, _Value, _Unused, _Unused},
	WeaponRange = {_Label, _Unused, _Value, _Unused},
	Durability = {_Label, _NumValue, {"Max", "number"}, _Unused, _Unused},
	CanBackstab = {_Label, _Unused},
	AccuracyBoost = {_Label, _NumValue, _Unused},
	DodgeBoost = {_Label, _NumValue, _Unused},
	EquipmentUnlockedSkill = {_Label, _Value, {"Icon", "number"}},
	WandSkill = {_Label, _Value, _Icon, _Warning},
	WandCharges = {_Label, {"Value", "number"}, {"MaxValue", "number"}, _Unused, _Unused},
	ArmorValue = {_Label, _NumValue, _Unused, _Unused},
	ArmorSlotType = {_Label, _Unused, _Unused},
	Blocking = {_Label, _NumValue, _Unused, _Unused},
	NeedsIdentifyLevel = {_Label, _Unused, _Unused},
	IsQuestItem = {},
	PriceToIdentify = {_Label, _Value, _Unused},
	PriceToRepair = {_Label, _Value, _Unused},
	PickpocketInfo = {_Label, _Unused},
	Engraving = {_Label, _Unused},
	ContainerIsLocked = {_Label, _Unused},
	Tags = {_Label, _Value, _Warning},
	SkillName = {_Label},
	SkillIcon = {_Label},
	SkillSchool = {_Label, {"Icon", "number"}},
	SkillTier = {_Label, _Unused},
	SkillRequiredEquipment = {_Label, {"RequirementMet", "boolean"}},
	SkillAPCost = {_Label, _NumValue, _Warning, {"RequirementMet", "boolean"}},
	SkillCooldown = {_Label, _NumValue, _Warning, _Unused, {"ValueText", "string"}},
	SkillDescription = {_Label},
	SkillDamage = {_Label, {"MinValue", "number"}, {"MaxValue", "number"}, {"DamageType", "number"}},
	SkillRange = {_Value, _Unused, _Label},
	SkillExplodeRadius = {_Label, _Unused, _Value},
	SkillCanPierce = {_Label, _Value},
	SkillCanFork = {_Label, _Value, _Unused, _Unused, _Unused},
	SkillStrikeCount = {_Label, _Value, _Unused},
	SkillProjectileCount = {_Label, _Value, _Unused},
	SkillCleansesStatus = {_Label, _Value, _Unused},
	SkillMultiStrikeAttacks = {_Label, _Value, _Unused, _Unused},
	SkillWallDistance = {_Label, _Value, _Unused},
	SkillPathSurface = {_Label, _Value, _Unused},
	SkillPathDistance = {_Label, _Value, _Unused},
	SkillHealAmount = {_Label, _Unused, _Unused, _Value},
	SkillDuration = {_Label, _NumValue, _Unused, _Warning},
	ConsumableEffectUknown = {_Label, _Unused},
	Reflection = {_Label},
	SkillAlreadyLearned = {_Label},
	SkillOnCooldown = {_Label},
	SkillAlreadyUsed = {_Label},

	AbilityTitle = {_Label},
	AbilityDescription = {{"AbilityId", "number"}, {"Description", "string"}, {"Description2", "string"}, {"CurrentLevelEffect", "string"}, {"NextLevelEffect", "string"}},
	
	TalentTitle = {_Label},
	TalentDescription = {{"TalentId", "number"}, {"Description", "string"}, {"Requirement", "string"}, {"IncompatibleWith", "string"}, {"Selectable", "boolean"}, {"Unknown", "boolean"}},

	SkillMPCost = {_Label, _NumValue, {"RequirementMet", "boolean"}},
	MagicArmorValue = {_Label, _NumValue, _Unused, {"RequirementMet", "boolean"}},
	WarningText = {_Label},
	RuneSlot = {_Label, _Value, _Unused},
	RuneEffect = {{"Unknown1", "number"}, {"Rune1", "string"}, {"Rune2", "string"}, {"Rune3", "string"}, _Label, {"Label2", "string"}},
	Equipped = {{"EquippedBy", "string"}, _Label, {"Slot", "string"}},
	ShowSkillIcon = {_Unused},
	SkillbookSkill = {_Label, _Value, {"Icon", "number"}},
	EmptyRuneSlot = {_Label, _Value, _Unused},

	StatName = {_Label},
	StatsDescription = {_Label},
	StatsDescriptionBoost = {_Label, _NumValue},

	StatSTRWeight = {_Label},
	StatMEMSlot = {_Label},
	StatsPointValue = {_Label},
	StatsTalentsBoost = {_Label},
	StatsTalentsMalus = {_Label},
	StatsBaseValue = {_Label},
	StatsPercentageBoost = {_Label},
	StatsPercentageMalus = {_Label},
	StatsPercentageTotal = {_Label, _NumValue},
	StatsGearBoostNormal = {_Label},
	StatsATKAPCost = {_Label},
	StatsCriticalInfos = {_Label},
	StatsAPTitle = {_Label},
	StatsAPDesc = {_Label},
	StatsAPBase = {_Label},
	StatsAPBonus = {_Label},
	StatsAPMalus = {_Label},
	StatsTotalDamage = {_Label},

	TagDescription = {_Label, {"Image", "number"}},

	StatusImmunity = {_Label},
	StatusBonus = {_Label},
	StatusMalus = {_Label},
	StatusDescription = {_Label},

	--Unused / throw errors
	
	Title = {_Label},
	SurfaceDescription = {_Label},
	Duration = {_Label},

	Fire = {_Label},
	Water = {_Label},
	Earth = {_Label},
	Air = {_Label},
	Poison = {_Label},
	Physical = {_Label},
	Sulfur = {_Label},
	Heal = {_Label},

	Splitter = {}
}

TooltipStatAttributes = {
	[0x0] = "Strength",
	[0x1] = "Finesse",
	[0x2] = "Intelligence",
	[0x3] = "Constitution",
	[0x4] = "Memory",
	[0x5] = "Wits",
	[0x6] = "Damage",
	[0x7] = "Armor",
	[0x8] = "MagicArmor",
	[0x9] = "CriticalChance",
	[0xA] = "Accuracy",
	[0xB] = "Dodge",
	[0xC] = "Vitality",
	[0xD] = "APRecovery",
	[0xE] = "Source",
	[0x11] = "Sight",
	[0x12] = "Hearing",
	[0x14] = "Movement",
	[0x15] = "Initiative",
	[0x17] = "PiercingResistance",
	[0x18] = "PhysicalResistance",
	[0x19] = "CorrosiveResistance",
	[0x1A] = "MagicResistance",
	[0x1B] = "ShadowResistance",
	[0x1C] = "FireResistance",
	[0x1D] = "WaterResistance",
	[0x1E] = "EarthResistance",
	[0x1F] = "AirResistance",
	[0x20] = "PoisonResistance",
	[0x21] = "CustomResistance",
	[0x24] = "Experience",
	[0x25] = "NextLevelExperience",
	[0x26] = "MaxAP",
	[0x27] = "StartAP",
	[0x28] = "APRecovery2",
	[0x2A] = "MinDamage",
	[0x2B] = "MaxDamage",
	[0x2C] = "LifeSteal",
	[0x2D] = "Gain",
}

Game.Tooltip.TooltipStatAttributes = TooltipStatAttributes

--- @param ui UIObject
--- @param name string MainTimeline property name to fetch
--- @return table
function TableFromFlash(ui, name)
	local value
	local idx = 0
	local tbl = {}

	repeat
		value = ui:GetValue(name, nil, idx)
		idx = idx + 1
		if value ~= nil then
			table.insert(tbl, value)
		end
	until value == nil

	return tbl
end

--- @param ui UIObject
--- @param name string MainTimeline property name to write
--- @param tbl table Table to convert to Flash
function TableToFlash(ui, name, tbl)
	for i=1,#tbl do
		ui:SetValue(name, tbl[i], i-1)
	end
end

--- @param ui UIObject Tooltip UI object
--- @param propertyName string Flash property name (tooltip_array, tooltipCompare_array, etc.)
--- @param tooltipArray table Tooltip array
--- @param originalTooltipArray table Unmodified tooltip array
function ReplaceTooltipArray(ui, propertyName, tooltipArray, originalTooltipArray)
	TableToFlash(ui, propertyName, tooltipArray)
	if #tooltipArray < #originalTooltipArray then
		-- Pad out the tooltip array with dummy values
		for i=#tooltipArray,#originalTooltipArray do
			ui:SetValue(propertyName, TooltipItemTypes.IsQuestItem, i)
		end
	end
end

function ParseTooltipElement(tt, index, spec, typeName)
	if #tt - index + 1 < #spec then
		_PrintError("Not enough fields to parse spec @" .. index)
		return
	end

	local element = {Type = typeName}
	for i,field in pairs(spec) do
		local val = tt[index + i - 1]
		if field[1] ~= nil then
			element[field[1]] = val
		end
		if _DEBUG and (field[2] ~= nil and type(val) ~= field[2]) then
			_PrintWarning("Type of field " .. typeName .. "." .. field[1] .. " differs: " .. type(val) .. " vs " .. field[2] .. ":", val)
		end
	end

	return index + #spec, element
end

function ParseTooltipSkillProperties(tt, index)
	local element = {
		Type = "SkillProperties",
		Properties = {},
		Resistances = {}
	}

	local numProps = tt[index + 1]
	index = index + 2

	for i=1,numProps do
		local prop = {
			Label = tt[index],
			Warning = tt[index + 1]
		}
		index = index + 2
		table.insert(element.Properties, prop)
	end
	
	local numResistances = tt[index]
	index = index + 1

	for i=1,numResistances do
		local resist = {
			Label = tt[index],
			Value = tt[index + 1]
		}
		index = index + 2
		table.insert(element.Resistances, resist)
	end

	return index, element
end

function ParseTooltipArmorSet(tt, index)
	local element = {
		Type = "ArmorSet",
		GrantedStatuses = {},
		GrantedStatuses2 = {}
	}

	element.SetName = tt[index]
	element.FoundPieces = tt[index + 1]
	element.TotalPieces = tt[index + 2]
	element.SetDescription = tt[index + 3]
	local numStatuses = tt[index + 4]
	index = index + 5

	for i=1,numStatuses do
		local prop = {
			Label = tt[index],
			IconIndex = tt[index + 1]
		}
		index = index + 2
		table.insert(element.GrantedStatuses, prop)
	end
	
	local numStatuses2 = tt[index]
	index = index + 1

	for i=1,numStatuses2 do
		local resist = {
			Label = tt[index],
			IconIndex = tt[index + 1]
		}
		index = index + 2
		table.insert(element.GrantedStatuses2, resist)
	end

	return index, element
end

--- @param tt table Flash tooltip array
--- @return TooltipElement[]
function ParseTooltipArray(tt)
	local index = 1
	local element
	local elements = {}

	while index <= #tt do
		local id = tt[index]
		index = index + 1

		if TooltipItemIds[id] == nil then
			_PrintError("Encountered unknown tooltip item type: ", id)
			return elements
		end

		local typeName = TooltipItemIds[id]
		if typeName == "SkillProperties" then
			index, element = ParseTooltipSkillProperties(tt, index)
		elseif typeName == "ArmorSet" then
			index, element = ParseTooltipArmorSet(tt, index)
		else
			local spec = TooltipSpecs[typeName]
			if spec == nil then
				_PrintError("No spec available for tooltip item type: ", typeName)
				return elements
			end

			index, element = ParseTooltipElement(tt, index, spec, typeName)
			if element == nil then
				return elements
			end
		end

		table.insert(elements, element)
	end

	return elements
end

function EncodeTooltipElement(tt, spec, element)
	for i,field in pairs(spec) do
		local name = field[1]
		local fieldType = field[2]
		local val = element[name]
		if name == nil then
			table.insert(tt, "")
		else
			if fieldType ~= nil and type(val) ~= fieldType then
				if _DEBUG then
					_PrintWarning("Type of field " .. element.Type .. "." .. name .. " differs: " .. type(val) .. " vs " .. fieldType .. ":", val)
				end
				val = nil
			end

			if val == nil then
				if fieldType == "boolean" then
					val = false
				elseif fieldType == "number" then
					val = 0
				else
					val = ""
				end
			end

			table.insert(tt, val)
		end
	end
end

function EncodeTooltipSkillProperties(tt, element)
	local properties = element.Properties or {}
	table.insert(tt, "")
	table.insert(tt, #properties)
	for i,prop in pairs(properties) do
		table.insert(tt, prop.Label or "")
		table.insert(tt, prop.Warning or "")
	end

	local resistances = element.Resistances or {}
	table.insert(tt, #resistances)
	for i,prop in pairs(resistances) do
		table.insert(tt, prop.Label or "")
		table.insert(tt, prop.Value or "")
	end
end

function EncodeTooltipArmorSet(tt, element)
	local statuses = element.GrantedStatuses or {}
	local statuses2 = element.GrantedStatuses2 or {}

	table.insert(tt, element.SetName or "")
	table.insert(tt, element.FoundPieces or 0)
	table.insert(tt, element.TotalPieces or 0)
	table.insert(tt, element.SetDescription or "")

	table.insert(tt, #statuses)
	for i,status in pairs(statuses) do
		table.insert(tt, status.Label or "")
		table.insert(tt, status.IconIndex or "")
	end

	table.insert(tt, #statuses2)
	for i,status in pairs(statuses2) do
		table.insert(tt, status.Label or "")
		table.insert(tt, status.IconIndex or "")
	end
end

--- @param elements table Flash tooltip array
--- @return table
function EncodeTooltipArray(elements)
	local tt = {}
	for i=1,#elements do
		local element = elements[i]
		if element then
			local type = TooltipItemTypes[element.Type]
			if type == nil then
				if _DEBUG then
					_PrintError("Couldn't encode tooltip element with unknown type:", element.Type)
					_Dump(element)
				end
			else
				if element.Type == "SkillProperties" then
					table.insert(tt, type)
					EncodeTooltipSkillProperties(tt, element)
				elseif element.Type == "ArmorSet" then
					table.insert(tt, type)
					EncodeTooltipArmorSet(tt, element)
				else
					local spec = TooltipSpecs[element.Type]
					if spec == nil then
						if _DEBUG then
							_PrintError("No encoder found for tooltip element type:", element.Type)
							_Dump(element)
						end
					else
						table.insert(tt, type)
						EncodeTooltipElement(tt, spec, element)
					end
				end
			end
		end
	end
	return tt
end

function DebugTooltipEncoding(ui)
	local tooltipArray = TableFromFlash(ui, "tooltip_array")
	local tooltipArray2 = {}

	for i,s in pairs(tooltipArray) do
		if s ~= nil and type(s) == "number" and TooltipItemIds[s] ~= nil then
			s = "TYPE: " .. TooltipItemIds[s]
		end

		tooltipArray2[i] = s
	end

	_Print("tooltip_array: " .. _Stringify(tooltipArray2))
	local parsed = ParseTooltipArray(tooltipArray)
	_Print("Parsed: " .. _Stringify(parsed))
	local encoded = EncodeTooltipArray(parsed)
	local parsed2 = ParseTooltipArray(encoded)
	_Print("Encoding matches: ", _Stringify(parsed2) == _Stringify(parsed))
end

---@class TooltipRequest:table
---@field Type TooltipRequestType
---@field UIType integer The UI type ID for the UI that initially called for a tooltip.
---@field TooltipUIType integer The UI type ID for the tooltip UI.
---@field ObjectHandleDouble number|nil

---@class TooltipItemRequest:TooltipRequest
---@field Item EclItem
---@field Character EclCharacter

---@class TooltipPyramidRequest:TooltipRequest
---@field Item EclItem

---@class TooltipRuneRequest:TooltipRequest
---@field Item EclItem
---@field Character EclCharacter
---@field Rune StatEntryObject The rune stat entry.
---@field Slot integer
---@field StatsId string The rune stat id.

---@class TooltipSkillRequest:TooltipRequest
---@field Character EclCharacter
---@field Skill string

---@class TooltipStatusRequest:TooltipRequest
---@field Character EclCharacter
---@field Status EclStatus
---@field StatusId string

---@class TooltipStatRequest:TooltipRequest
---@field Character EclCharacter
---@field Stat string

---@class TooltipAbilityRequest:TooltipRequest
---@field Character EclCharacter
---@field Ability string

---@class TooltipTalentRequest:TooltipRequest
---@field Character EclCharacter
---@field Talent string

---@class TooltipTagRequest:TooltipRequest
---@field Character EclCharacter
---@field Tag string
---@field Category string

---@class TooltipCustomStatRequest:TooltipRequest
---@field Character EclCharacter
---@field Stat number The stat handle.
---@field StatIndex integer The stat index in the characterSheet array.
---@field StatData {ID:string, __tostring:fun(tbl:table):string}|nil Custom stats data that returns a string ID via the metamethod __tostring. Must be implemented by a mod, otherwise this is nil.

---@class TooltipSurfaceRequest:TooltipRequest
---@field Character EclCharacter
---@field Ground string|nil
---@field Cloud string|nil

---@class TooltipGenericRequest:TooltipRequest
---@field Text string
---@field X number|nil
---@field Y number|nil
---@field Width number|nil
---@field Height number|nil
---@field Side string|nil
---@field AllowDelay boolean|nil
---@field AnchorEnum integer|nil
---@field BackgroundType integer|nil
---@field IsCharacterTooltip boolean|nil

---@class TooltipWorldRequest:TooltipRequest
---@field Text string Set this to change the resulting world tooltip text.
---@field X number
---@field Y number
---@field IsFromItem boolean
---@field Item EclItem|nil

---@class TooltipPlayerPortraitRequest:TooltipRequest
---@field Text string Set this to change the resulting tooltip text.
---@field X number
---@field Y number
---@field Width number|nil
---@field Height number|nil
---@field Side string|nil
---@field Character EclCharacter

local previousListeners = {}

---@class TooltipHooks
TooltipHooks = {
	---@type TooltipRequest
	NextRequest = nil,
	ActiveType = "",
	Last = {
		---@type TooltipRequest
		Request = nil,
		Event = "",
		Type = "",
		---@type integer
		UIType = -1,
	},
	IsOpen = false,
	SessionLoaded = false,
	InitializationRequested = false,
	Initialized = false,
	GlobalListeners = {},
	TypeListeners = {},
	ObjectListeners = {},
	RequestListeners = {
		All = {}
	},
	BeforeNotifyListeners = {
		All = {},
	},
}

RequestProcessor.Tooltip = TooltipHooks

if previousListeners.GlobalListeners then
	for _,v in pairs(previousListeners.GlobalListeners) do
		TooltipHooks.GlobalListeners[#TooltipHooks.GlobalListeners+1] = v
	end
end

if previousListeners.TypeListeners then
	for t,v in pairs(previousListeners.TypeListeners) do
		if TooltipHooks.TypeListeners[t] == nil then
			TooltipHooks.TypeListeners[t] = v
		else
			for _,v2 in pairs(v) do
				table.insert(TooltipHooks.TypeListeners[t], v2)
			end
		end
	end
end

if previousListeners.ObjectListeners then
	for t,v in pairs(previousListeners.ObjectListeners) do
		if TooltipHooks.ObjectListeners[t] == nil then
			TooltipHooks.ObjectListeners[t] = v
		else
			for k,v2 in pairs(v) do
				TooltipHooks.ObjectListeners[t][k] = v2
			end
		end
	end
end

--Auto-completion
Game.Tooltip.TooltipHooks = TooltipHooks

---@class TooltipArrayData
---@field Main string
---@field CompareMain string|nil
---@field CompareOff string|nil

local TooltipArrayNames = {
	---@type TooltipArrayData
	Default = {
		Main = "tooltip_array",
		CompareMain = "tooltipCompare_array",
		CompareOff = "tooltipOffHand_array",
	},
	Surface = {Main = "tooltipArray" },
	Console = {
		CharacterCreation = {
			Main = "tooltipArray",
		},
		ContainerInventory = {
			Main = "tooltip_array",
		},
		PartyInventory = {
			Main = "tooltip_array",
			CompareMain = "compareTooltip_array",
			CompareOff = "offhandTooltip_array"
		},
		BottomBar = {
			Main = "tooltip_array"
		},
		Examine = {
			Main = "tooltipArray"
		},
		Trade = {
			Main = "tooltip_array",
			CompareMain = "tooltipCompare_array",
			CompareOff = "equipOffhandTooltip_array"
		},
		Reward = {
			Main = "tooltip_array",
		},
		EquipmentPanel = {
			Main = "tooltip_array",
			CompareMain = "equipTooltip_array",
		},
		StatsPanel = {
			Main = "tooltipArray",
		},
		CraftPanel = {
			Main = "tooltip_array",
		}
	}
}
Game.Tooltip.TooltipArrayNames = TooltipArrayNames

function TooltipHooks:RegisterControllerHooks()
	_RegisterUITypeInvokeListener(_UITYPE.equipmentPanel_c, "updateTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.EquipmentPanel, ui, ...)
	end)
	_RegisterUITypeInvokeListener(_UITYPE.equipmentPanel_c, "updateEquipTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.EquipmentPanel, ui, ...)
	end)

	_RegisterUITypeInvokeListener(_UITYPE.craftPanel_c, "updateTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.CraftPanel, ui, ...)
	end)

	_RegisterUITypeInvokeListener(_UITYPE.containerInventory.Default, "updateTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.ContainerInventory, ui, ...)
	end)

	_RegisterUITypeInvokeListener(_UITYPE.containerInventory.Pickpocket, "updateTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.ContainerInventory, ui, ...)
	end)

	_RegisterUITypeInvokeListener(_UITYPE.statsPanel_c, "showTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.StatsPanel, ui, ...)
	end)

	_RegisterUITypeInvokeListener(_UITYPE.examine_c, "showFormattedTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.Examine, ui, ...)
	end)
	
	_RegisterUITypeInvokeListener(_UITYPE.bottomBar_c, "updateTooltip", function (...)
		self:OnRenderTooltip(TooltipArrayNames.Console.BottomBar, ...)
	end)
	_RegisterUITypeInvokeListener(_UITYPE.bottomBar_c, "setPlayerHandle", function (ui, method, doubleHandle)
		if doubleHandle ~= nil and doubleHandle ~= 0 then
			local handle = _DoubleToHandle(doubleHandle)
			if _IsValidHandle(handle) then
				local character = _GetCharacter(handle)
				if character then
					ControllerVars.LastPlayer = character.NetID
				end
			end
		end
	end)
	---@param self TooltipHooks
	---@return EclCharacter
	self.GetLastPlayer = function(self)
		if RequestProcessor.ControllerEnabled then
			if ControllerVars.LastPlayer then
				local character = _GetCharacter(ControllerVars.LastPlayer)
				if character then
					return character
				end
			end
			local ui = _GetUIByType(_UITYPE.bottomBar_c)
			if ui then
				---@type {characterHandle:number}
				local this = ui:GetRoot()
				if this and not _IsNaN(this.characterHandle) then
					local character = RequestProcessor.Utils.GetObjectFromDouble(this.characterHandle)
					if character then
						ControllerVars.LastPlayer = character.NetID
						return character
					end
				end
			end
		end
	end

	_RegisterUITypeInvokeListener(_UITYPE.partyInventory_c, "updateTooltip", function (...)
		self:OnRenderTooltip(TooltipArrayNames.Console.PartyInventory, ...)
	end)

	_RegisterUITypeInvokeListener(_UITYPE.reward_c, "updateTooltipData", function (ui, method, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.Reward, ui, method, ...)
	end)

	_RegisterUITypeInvokeListener(_UITYPE.characterCreation_c, "showTooltip", function(...)
		self:OnRenderTooltip(TooltipArrayNames.Console.CharacterCreation, ...)
	end)

	_RegisterUITypeInvokeListener(_UITYPE.trade_c, "updateTooltip", function(...)
		self:OnRenderTooltip(TooltipArrayNames.Console.Trade, ...)
	end)

	-- This allows examine_c to have a character reference
	_RegisterUITypeInvokeListener(_UITYPE.overhead, "updateOHs", function (ui, method, ...)
		if RequestProcessor.ControllerEnabled then
			---@type {selectionInfo_array:FlashArray<number>}
			local main = ui:GetRoot()
			if main then
				for i=0,#main.selectionInfo_array,21 do
					local id = main.selectionInfo_array[i]
					if id and not _IsNaN(id) then
						ControllerVars.LastOverhead = id
						break
					end
				end
			end
		end
	end)
end

function TooltipHooks:Init()
	if self.Initialized then
		return
	end

	RequestProcessor:Init(TooltipHooks)

	_RegisterUINameInvokeListener("addFormattedTooltip", function (...)
		self:OnRenderTooltip(TooltipArrayNames.Default, ...)
	end)

	_RegisterUINameInvokeListener("addStatusTooltip", function (...)
		self:OnRenderTooltip(TooltipArrayNames.Default, ...)
	end)

	_RegisterUINameInvokeListener("displaySurfaceText", function (...)
		self:OnRenderTooltip(TooltipArrayNames.Surface, ...)
	end, "After")

	--Disabled for now since character portrait tooltips get spammed
	-- _RegisterUINameCall("showCharTooltip", function(ui, call, handle, x, y, width, height, side)
	-- 	self.NextRequest = {
	-- 		Type = "Generic",
	-- 		IsCharacterTooltip = true,
	--		Handle = handle,
	-- 		X = x,
	-- 		Y = y,
	-- 		Width = width,
	-- 		Height = height,
	-- 		Side = side
	-- 	}
	-- end, "Before")
	
	_RegisterUINameInvokeListener("addTooltip", function (ui, call, text, ...)
		self:OnRenderGenericTooltip(ui, call, text, ...)
	end)

	_RegisterUINameCall("hideTooltip", function (ui, call, ...)
		self.IsOpen = false
		self.ActiveType = ""
		if self.NextRequest and self.NextRequest.Type == "Generic" then
			self.Last.Request = self.NextRequest
			self.NextRequest = nil
		end
		local tt = _GetUIByType(_UITYPE.tooltip)
		if tt then
			if #tooltipCustomIcons > 0 then
				for _,v in pairs(tooltipCustomIcons) do
					tt:ClearCustomIcon(v)
				end
				tooltipCustomIcons = {}
			end
		end
	end)

	_RegisterUINameCall("keepUIinScreen", function (ui, method, keepUIinScreen)
		if self.GenericTooltipData then
			self:UpdateGenericTooltip(ui, method, keepUIinScreen)
		end
	end)

	self:RegisterControllerHooks()

	self.Initialized = true
end

function TooltipHooks:UpdateGenericTooltip(ui, method, keepUIinScreen)
	if not self.GenericTooltipData then
		return
	end
	local this = ui:GetRoot()
	if this and this.tf then
		if self.GenericTooltipData.Text == "" or self.GenericTooltipData.Text == nil then
			this.INTRemoveTooltip()
		else
			this.tf.shortDesc = self.GenericTooltipData.Text
			this.tf.setText(self.GenericTooltipData.Text,self.GenericTooltipData.BackgroundType or 0)
		end
	end
	self.GenericTooltipData = nil
end

local _GenericTooltipTypes = {
	Generic = true,
	WorldHover = true,
	PlayerPortrait = true,
}

---@param ui UIObject
---@param method string
function TooltipHooks:OnRenderGenericTooltip(ui, method, text, x, y, allowDelay, anchorEnum, backgroundType)
	---@type TooltipGenericRequest|TooltipPlayerPortraitRequest|TooltipWorldRequest
	local req = self.NextRequest
	if not req then
		return
	end
	if _GenericTooltipTypes[req.Type] then
		if req.Type == "WorldHover" then
			req.Type = "World"
		end

		if req.IsCharacterTooltip then
			req.Text = text
		end
	
		self.IsOpen = true
	
		---@type TooltipGenericRequest
		self.GenericTooltipData = {
			Text = text,
			X = x,
			Y = y
		}
		req.AllowDelay = allowDelay
		req.AnchorEnum = anchorEnum
		req.BackgroundType = backgroundType
	
		local tooltipData = TooltipData:Create({{
			Type = "Description",
			Label = text,
			X = x,
			Y = y,
		}}, ui:GetTypeId(), req.UIType)

		self.ActiveType = req.Type
		self.Last.Type = req.Type

		if req.Type == "World" then
			local item = req.Item
			if item then
				self:NotifyListeners("World", item.StatsId, req, tooltipData, item)
			else
				self:NotifyListeners("World", nil, req, tooltipData, nil)
			end
		elseif req.Type == "PlayerPortrait" then
			self:NotifyListeners("PlayerPortrait", nil, req, tooltipData, req.Character)
		else
			self:NotifyListeners("Generic", nil, req, tooltipData)
		end
	
		local desc = tooltipData:GetDescriptionElement()
		if desc then
			self.GenericTooltipData.Text = desc.Label or ""
			if desc.X then self.GenericTooltipData.X = desc.X end
			if desc.Y then self.GenericTooltipData.Y = desc.Y end
		end
	
		self.Last.Request = self.NextRequest
		self.NextRequest = nil
	end
end

---@param ui UIObject
---@param item EclItem
---@return EclCharacter
function TooltipHooks:GetCompareOwner(ui, item)
	local owner = ui:GetPlayerHandle()

	if owner ~= nil then
		local char = _GetCharacter(owner)
		if char.Stats.IsPlayer then
			return char
		end
	end

	local handle = nil
	if not RequestProcessor.ControllerEnabled then
		local hotbar = _GetUIByType(_UITYPE.hotBar)
		if hotbar ~= nil then
			---@type {hotbar_mc:{characterHandle:number}}
			local main = hotbar:GetRoot()
			if main ~= nil then
				handle = _DoubleToHandle(main.hotbar_mc.characterHandle)
			end
		end
	else
		local hotbar = _GetUIByType(_UITYPE.bottomBar_c)
		if hotbar ~= nil then
			---@type {characterHandle:number}
			local main = hotbar:GetRoot()
			if main ~= nil then
				handle = _DoubleToHandle(main.characterHandle)
			end
		end
	end

	if handle ~= nil then
		local char = _GetCharacter(handle)
		if char then
			return char
		end
	end

	local character = RequestProcessor.Utils.GetClientCharacter()

	if character == nil then
		--Fallback to the item's owner last, since it may not be the active character.
		local itemOwner = item:GetOwnerCharacter()
		if itemOwner ~= nil then
			local ownerCharacter = _GetCharacter(itemOwner)
			if ownerCharacter ~= nil and ownerCharacter.Stats.IsPlayer then
				return ownerCharacter
			end
		end
	else
		return character
	end
	
	return nil
end

--- @param ui UIObject
--- @param item EclItem
--- @param offHand boolean
--- @return EclItem|nil
function TooltipHooks:GetCompareItem(ui, item, offHand)
	local char = self:GetCompareOwner(ui, item)

	if char == nil then
		_PrintWarning("Tooltip compare render failed: Couldn't find owner of item", item.StatsId)
		return nil
	end

	if item.Stats.ItemSlot == "Weapon" then
		if offHand then
			return char:GetItemObjectBySlot("Shield")
		else
			return char:GetItemObjectBySlot("Weapon")
		end
	elseif item.Stats.ItemSlot == "Ring" or item.Stats.ItemSlot == "Ring2" then
		if offHand then
			return char:GetItemObjectBySlot("Ring2")
		else
			return char:GetItemObjectBySlot("Ring")
		end
	else
		return char:GetItemObjectBySlot(item.Stats.ItemSlot)
	end
end

---@param arrayData TooltipArrayData
---@param ui UIObject
function TooltipHooks:OnRenderTooltip(arrayData, ui, method, ...)
	if self.NextRequest == nil then
		if _DEBUG then
			_PrintWarning(string.format("[Game.Tooltip] Got tooltip render request, but did not find original tooltip info! method(%s)", method))
		end
		return
	end

	self.IsOpen = true
	
	---@type TooltipItemRequest
	local req = self.NextRequest
	self.ActiveType = req.Type
	self.Last.Type = req.Type

	self:OnRenderSubTooltip(ui, arrayData.Main, req, method, ...)
	
	if req.Type == "Item" then
		local this = ui:GetRoot()

		local reqItem = req.Item
		local mainArray = arrayData.CompareMain and this[arrayData.CompareMain] or nil
		local compareArray = arrayData.CompareOff and this[arrayData.CompareOff] or nil

		if mainArray and mainArray[0] ~= nil then
			local compareItem = self:GetCompareItem(ui, reqItem, false)
			if compareItem ~= nil then
				local lastObjectHandle = req.ObjectHandleDouble
				local lastStatsId = req.StatsId
				req.ObjectHandleDouble = _HandleToDouble(compareItem.Handle)
				req.StatsId = compareItem.StatsId
				self:OnRenderSubTooltip(ui, arrayData.CompareMain, req, method, ...)
				req.ObjectHandleDouble = lastObjectHandle
				req.StatsId = lastStatsId
			else
				_PrintError("Tooltip compare render failed: Couldn't find item to compare")
			end
		end

		if compareArray and compareArray[0] ~= nil then
			local compareItem = self:GetCompareItem(ui, reqItem, true)
			if compareItem ~= nil then
				local lastObjectHandle = req.ObjectHandleDouble
				local lastStatsId = req.StatsId
				req.ObjectHandleDouble = _HandleToDouble(compareItem.Handle)
				req.StatsId = compareItem.StatsId
				self:OnRenderSubTooltip(ui, arrayData.CompareOff, req, method, ...)		
				req.ObjectHandleDouble = lastObjectHandle
				req.StatsId = lastStatsId
			else
				_PrintError("Tooltip compare render failed: Couldn't find off-hand item to compare")
			end
		end
	end

	self.Last.Request = self.NextRequest
	self.NextRequest = nil
end

---@param ui UIObject
---@param propertyName string
---@param req AnyTooltipRequest
---@param method string
function TooltipHooks:OnRenderSubTooltip(ui, propertyName, req, method, ...)
	local tt = TableFromFlash(ui, propertyName)
	local params = ParseTooltipArray(tt)
	if params ~= nil then
		local tooltip = TooltipData:Create(params, ui:GetTypeId(), req.UIType)
		self:InvokeBeforeNotifyListeners(req, ui, method, tooltip, ...)
		if req.Type == "Stat" then
			self:NotifyListeners("Stat", req.Stat, req, tooltip, req.Character, req.Stat)
		elseif req.Type == "CustomStat" then
			if req.StatData ~= nil then
				self:NotifyListeners("CustomStat", tostring(req.StatData), req, tooltip, req.Character, req.StatData)
			else
				self:NotifyListeners("CustomStat", nil, req, tooltip, req.Character, {ID=req.Stat})
			end
		elseif req.Type == "Skill" then
			self:NotifyListeners("Skill", req.Skill, req, tooltip, req.Character, req.Skill)
		elseif req.Type == "Ability" then
			self:NotifyListeners("Ability", req.Ability, req, tooltip, req.Character, req.Ability)
		elseif req.Type == "Talent" then
			self:NotifyListeners("Talent", req.Talent, req, tooltip, req.Character, req.Talent)
		elseif req.Type == "Status" then
			self:NotifyListeners("Status", req.StatusId, req, tooltip, req.Character, req.Status)
		elseif req.Type == "Item" then
			self:NotifyListeners("Item", req.StatsId, req, tooltip, req.Item)
		elseif req.Type == "Pyramid" then
			self:NotifyListeners("Pyramid", req.StatsId, req, tooltip, req.Item)
		elseif req.Type == "Rune" then
			self:NotifyListeners("Rune", req.StatsId, req, tooltip, req.Item, req.Rune, req.Slot)
		elseif req.Type == "Tag" then
			self:NotifyListeners("Tag", req.Category, req, tooltip, req.Tag)
		elseif req.Type == "Surface" then
			if req.Ground then
				self:NotifyListeners("Surface", req.Ground, req, tooltip, req.Character, req.Ground)
			end
			if req.Cloud then
				self:NotifyListeners("Surface", req.Cloud, req, tooltip, req.Character, req.Cloud)
			end
			if not req.Cloud and not req.Ground then
				self:NotifyListeners("Surface", "Unknown", req, tooltip, req.Character, "Unknown")
			end
		elseif req.Type == "World" then
			-- Manually invoked in RequestProcessor, so the text array can be updated
			---@see GameTooltipRequestProcessorInternals#CreateWorldTooltipRequest
		elseif req.Type == "PlayerPortrait" then
			---@see TooltipHooks#OnRenderGenericTooltip
		elseif req.Type == "Generic" then
			---@see TooltipHooks#OnRenderGenericTooltip
		else
			_PrintError("Unknown tooltip type? ", req.Type)
		end

		local newTooltip = EncodeTooltipArray(tooltip.Data)
		if newTooltip ~= nil then
			ReplaceTooltipArray(ui, propertyName, newTooltip, tt)
		end
	end
end

local function InvokeListenerTable(tbl, ...)
	if tbl then
		for _,v in pairs(tbl) do
			local b,err = xpcall(v, debug.traceback, ...)
			if not b then
				_PrintError(err)
			end
		end
	end
end

---@param requestType string
---@param listener fun(req:TooltipRequest)
function TooltipHooks:RegisterBeforeNotifyListener(requestType, listener)
	if requestType == nil or requestType == "all" then
		requestType = "All"
	end
	if self.BeforeNotifyListeners[requestType] == nil then
		self.BeforeNotifyListeners[requestType] = {}
	end
	if self.BeforeNotifyListeners[requestType] == nil then
		self.BeforeNotifyListeners[requestType] = {}
	end
	table.insert(self.BeforeNotifyListeners[requestType], listener)
end

---@param request TooltipRequest
---@vararg string|boolean|number|EclGameObject
function TooltipHooks:InvokeBeforeNotifyListeners(request, ...)
	local rTypeTable = self.BeforeNotifyListeners[request.Type]
	if rTypeTable then
		InvokeListenerTable(rTypeTable, request, ...)
	end
	InvokeListenerTable(self.BeforeNotifyListeners.All, request, ...)
end

---@param requestType string
---@param name string
---@param request TooltipRequest
---@param tooltip TooltipData
function TooltipHooks:NotifyListeners(requestType, name, request, tooltip, ...)
	local args = {...}
	table.insert(args, tooltip)
	self:NotifyAll(self.TypeListeners[requestType], table.unpack(args))
	if name ~= nil and self.ObjectListeners[requestType] ~= nil then
		self:NotifyAll(self.ObjectListeners[requestType][name], table.unpack(args))
	end

	self:NotifyAll(self.GlobalListeners, request, tooltip, ...)
end

function TooltipHooks:NotifyAll(listeners, ...)
	if not listeners then
		return
	end
	for i,callback in pairs(listeners) do
		local status, err = xpcall(callback, debug.traceback, ...)
		if not status then
			_PrintError("Error during tooltip callback: ", err)
		end
	end
end

---@param tooltipType string|nil
---@param tooltipID string|nil
---@param listener function
function TooltipHooks:RegisterListener(tooltipType, tooltipID, listener)
	if not self.Initialized then
		self:Init()
	end

	if tooltipType == nil then
		table.insert(self.GlobalListeners, listener)
	elseif tooltipID == nil then
		if self.TypeListeners[tooltipType] == nil then
			self.TypeListeners[tooltipType] = {listener}
		else
			table.insert(self.TypeListeners[tooltipType], listener)
		end
	else
		local listeners = self.ObjectListeners[tooltipType]
		if listeners == nil then
			self.ObjectListeners[tooltipType] = {[tooltipID] = {listener}}
		else
			if listeners[tooltipID] == nil then
				listeners[tooltipID] = {listener}
			else
				table.insert(listeners[tooltipID], listener)
			end
		end
	end
end

---@param requestType string
---@param listener fun(req:TooltipRequest)
---@param state string
function TooltipHooks:RegisterRequestListener(requestType, listener, state)
	if requestType == nil or requestType == "all" then
		requestType = "All"
	end
	if self.RequestListeners[requestType] == nil then
		self.RequestListeners[requestType] = {}
	end
	if state and type(state) == "string" then
		state = string.lower(state)
		state = state == "before" and "before" or "after"
	else
		state = "after"
	end
	if self.RequestListeners[requestType][state] == nil then
		self.RequestListeners[requestType][state] = {}
	end
	table.insert(self.RequestListeners[requestType][state], listener)
end

function TooltipHooks:InvokeRequestListeners(request, state, ...)
	local rTypeTable = self.RequestListeners[request.Type]
	if rTypeTable then
		InvokeListenerTable(rTypeTable[state], request, ...)
	end
	InvokeListenerTable(self.RequestListeners.All[state], request, ...)
end

---@class TooltipData
---@field Data TooltipElement[]
---@field ControllerEnabled boolean
---@field TooltipUIType integer
---@field UIType integer
---@field Instance UIObject
---@field Root FlashMainTimeline
TooltipData = {}

---@class GenericTooltipData:TooltipData
---@field Data TooltipGenericRequest

---@param data TooltipElement[]
---@param tooltipUIType integer
---@param requestingUIType integer
---@return TooltipData
function TooltipData:Create(data, tooltipUIType, requestingUIType)
	local tt = {
		Data = data,
		ControllerEnabled = RequestProcessor.ControllerEnabled or false,
		TooltipUIType = tooltipUIType,
		UIType = requestingUIType
	}
	setmetatable(tt, {
		__index = function(tbl, k)
			if k == "Instance" then
				return _GetUIByType(tooltipUIType)
			elseif k == "Root" then
				local ui = _GetUIByType(tooltipUIType)
				if ui then
					return ui:GetRoot()
				end
			end
			return TooltipData[k]
		end
	})
	return tt
end

local DescriptionElements = {
	AbilityDescription = true,
	ItemDescription = true,
	SkillDescription = true,
	StatsDescription = true,
	StatusDescription = true,
	SurfaceDescription = true,
	TagDescription = true,
	TalentDescription = true,
	Description = true, -- World Tooltips
}

---Gets whichever element is the description.
---@return {Type:string, Label:string}
function TooltipData:GetDescriptionElement()
	---@type {Type:TooltipElementType, Label:string|nil}
	local elements = self.Data
	for _,element in pairs(elements) do
		if DescriptionElements[element.Type] and element.Label then
			return element
		end
	end
	return nil
end

local function _IsTooltipElement(ele)
	return type(ele) == "table" and TooltipItemTypes[ele.Type] ~= nil
end

local function _ElementTypeMatch(e,t,isTable)
	if isTable then
		for i=1,#t do
			if t[i] == e then
				return true
			end
		end
	elseif e == t then
		return true
	end
	return false
end

---@overload fun(self:TooltipData, t:TooltipElementType, fallback:TooltipElement|nil)
---@generic T:TooltipElement|TooltipElementType
---@param t `T`|`T`[] The tooltip element type, or an array of element types.
---@param fallback TooltipElement|nil If an element of the desired type isn't found, append and return this fallback element.
---@return T|nil elementOrFallback
function TooltipData:GetElement(t, fallback)
	local isTable = type(t) == "table"
	for i=1,#self.Data do
		local element = self.Data[i]
		if element and _ElementTypeMatch(element.Type, t, isTable) then
			return element
		end
	end
	--If this element wasn't found, and fallback is set, append it.
	if _IsTooltipElement(fallback) then
		self:AppendElement(fallback)
		return fallback
	end
	return nil
end

---Get the last element in the tooltip data of the given type.
---@overload fun(self:TooltipData, t:TooltipElementType, fallback:TooltipElement|nil)
---@generic T:TooltipElement|TooltipElementType
---@param t `T`|`T`[] The tooltip element type, or an array of element types.
---@param fallback TooltipElement|nil If an element of the desired type isn't found, append and return this fallback element.
---@return T|nil lastElementOrFallback
function TooltipData:GetLastElement(t, fallback)
	local isTable = type(t) == "table"
	for i=#self.Data,1,-1 do
		local element = self.Data[i]
		if element and _ElementTypeMatch(element.Type, t, isTable) then
			return element
		end
	end
	if type(fallback) == "table" then
		self:AppendElement(fallback)
		return fallback
	end
	return nil
end

---@overload fun(self:TooltipData, t:TooltipElementType)
---@generic T:TooltipElement|TooltipElementType
---@param t `T`|`T`[] The tooltip element type, or an array of element types.
---@return T[] elements An array of elements, or an empty table.
function TooltipData:GetElements(t)
	local isTable = type(t) == "table"
	local elements = {}
	for i=1,#self.Data do
		local element = self.Data[i]
		if element and _ElementTypeMatch(element.Type, t, isTable) then
			elements[#elements+1] = element
		end
	end
	return elements
end

---Remove all elements matching the given tooltip element type(s).
---@param t TooltipElementType|TooltipElementType[] The tooltip element type, or an array of element types.
---@return boolean success Whether any elements matching the given types were removed.
function TooltipData:RemoveElements(t)
	local isTable = type(t) == "table"
	local success = false
	local j = 1
	local n = #self.Data
	--Alternative table.remove optimization
	--https://stackoverflow.com/a/53038524/2290477
	for i=1,n do
		if not _ElementTypeMatch(self.Data[i].Type, t, isTable) then
			if (i ~= j) then
				self.Data[j] = self.Data[i]
				self.Data[i] = nil
			end
			j = j + 1
		else
			self.Data[i] = nil
		end
	end
	return success
end

---Remove the provided tooltip element.
---@param ele TooltipElement
---@return boolean success Whether the element was removed.
function TooltipData:RemoveElement(ele)
	for i,element in pairs(self.Data) do
		if element == ele then
			table.remove(self.Data, i)
			return true
		end
	end
	return false
end

---Append a tooltip element to the end of the tooltip data.
---@param ele TooltipElement
---@return TooltipElement
function TooltipData:AppendElement(ele)
	if _IsTooltipElement(ele) then
		self.Data[#self.Data+1] = ele
	else
		_PrintError(string.format("[Game.Tooltip::TooltipData:AppendElement] Invalid tooltip element parameter: (%s)", _DumpExport(ele)))
	end
	return ele
end

---Append a table of elements to the end of the tooltip data.
---@param tbl TooltipElement[]
---@return TooltipElement
function TooltipData:AppendElements(tbl)
	for i=1,#tbl do
		local ele = tbl[i]
		if _IsTooltipElement(ele) then
			self.Data[#self.Data+1] = ele
		else
			_PrintError(string.format("[Game.Tooltip::TooltipData:AppendElements] Invalid tooltip element parameter: (%s)", _DumpExport(ele)))
		end
	end
end

---@param ele TooltipElement
---@param appendAfter TooltipElement
---@return TooltipElement
function TooltipData:AppendElementAfter(ele, appendAfter)
	if _IsTooltipElement(ele) then
		if _IsTooltipElement(appendAfter) then
			for i=1,#self.Data do
				local compareEle = self.Data[i]
				if compareEle == appendAfter then
					table.insert(self.Data, i+1, ele)
					return ele
				end
			end
		end
		self.Data[#self.Data+1] = ele
	else
		_PrintError(string.format("[Game.Tooltip::TooltipData:AppendElementAfter] Invalid tooltip element parameter: (%s)", _DumpExport(ele)))
	end
	return ele
end

---@param ele TooltipElement
---@param appendBefore TooltipElement
---@return TooltipElement
function TooltipData:AppendElementBefore(ele, appendBefore)
	if _IsTooltipElement(ele) then
		if _IsTooltipElement(appendBefore) then
			for i=1,#self.Data do
				local compareEle = self.Data[i]
				if compareEle == appendBefore then
					table.insert(self.Data, i-1, ele)
					return ele
				end
			end
		end
		self.Data[#self.Data+1] = ele
	else
		_PrintError(string.format("[Game.Tooltip::TooltipData:AppendElementBefore] Invalid tooltip element parameter: (%s)", _DumpExport(ele)))
	end
	return ele
end

---Append an element after a specific element type.
---@param ele TooltipElement
---@param elementType TooltipElementType|table<TooltipElementType,boolean> Either an TooltipElementType (string), or a table where the key is a TooltipElementType (i.e. `enableTypes = { SkillDescription = true, ItemDescription = true}`)
---@return TooltipElement
function TooltipData:AppendElementAfterType(ele, elementType)
	if _IsTooltipElement(ele) then
		local t = type(elementType)
		for i=1,#self.Data do
			local element = self.Data[i]
			if (t == "string" and element.Type == elementType) or (t == "table" and elementType[element.Type] == true) then
				table.insert(self.Data, i+1, ele)
				return ele
			end
		end
		self.Data[#self.Data+1] = ele
	else
		_PrintError(string.format("[Game.Tooltip::TooltipData:AppendElementAfterType] Invalid tooltip element parameter: (%s)", _DumpExport(ele)))
	end

	return ele
end

---Append an element before a specific element type.
---@param ele TooltipElement
---@param elementType TooltipElementType|table<TooltipElementType,boolean> Either an TooltipElementType (string), or a table where the key is a TooltipElementType (i.e. `enableTypes = { SkillDescription = true, ItemDescription = true}`)
---@return TooltipElement
function TooltipData:AppendElementBeforeType(ele, elementType)
	if _IsTooltipElement(ele) then
		local t = type(elementType)
		for i=1,#self.Data do
			local element = self.Data[i]
			if (t == "string" and element.Type == elementType) or (t == "table" and elementType[element.Type] == true) then
				table.insert(self.Data, i-1, ele)
				return ele
			end
		end
		self.Data[#self.Data+1] = ele
	else
		_PrintError(string.format("[Game.Tooltip::TooltipData:AppendElementAfterType] Invalid tooltip element parameter: (%s)", _DumpExport(ele)))
	end

	return ele
end

Game.Tooltip.Register = {
	---@param callback fun(request:AnyTooltipRequest, tooltip:TooltipData)
	Global = function(callback)
		TooltipHooks:RegisterListener(nil, nil, callback)
	end,

	---@param callback fun(character:EclCharacter, ability:StatsAbilityType|string, tooltip:TooltipData)
	---@param ability StatsAbilityType|nil Optional ability to filter by.
	Ability = function(callback, ability)
		TooltipHooks:RegisterListener("Ability", ability, callback)
	end,

	---@param callback fun(character:EclCharacter, statData:{ID:string}, tooltip:TooltipData)
	---@param id string|nil Optional CustomStat ID to filter by.
	CustomStat = function(callback, id)
		TooltipHooks:RegisterListener("CustomStat", id, callback)
	end,
	
	---@param callback fun(tooltip:TooltipData)
	Generic = function(callback)
		TooltipHooks:RegisterListener("Generic", nil, callback)
	end,

	---@param callback fun(item:EclItem, tooltip:TooltipData)
	---@param statsId string|nil Optional Rune StatsId to filter by.
	Item = function(callback, statsId)
		TooltipHooks:RegisterListener("Item", statsId, callback)
	end,

	---Called when a tooltip is created when hovering over a player portrait.
	---@param callback fun(character:EclCharacter|nil, tooltip:TooltipData)
	PlayerPortrait = function(callback)
		TooltipHooks:RegisterListener("PlayerPortrait", nil, callback)
	end,

	---@param callback fun(item:EclItem, tooltip:TooltipData)
	---@param statsId string|nil Optional Rune StatsId to filter by.
	Pyramid = function(callback, statsId)
		TooltipHooks:RegisterListener("Pyramid", statsId, callback)
	end,

	---@param callback fun(item:EclItem, tooltip:TooltipData)
	---@param statsId string|nil Optional Rune StatsId to filter by.
	Rune = function(callback, statsId)
		TooltipHooks:RegisterListener("Rune", statsId, callback)
	end,

	---@param callback fun(character:EclCharacter, skill:string, tooltip:TooltipData)
	---@param skillId string|nil Optional Skill ID to filter by.
	Skill = function(callback, skillId)
		TooltipHooks:RegisterListener("Skill", skillId, callback)
	end,

	---Register a callback for stat tooltips in the character sheet, such as attributes and resistances.
	---@param callback fun(character:EclCharacter, stat:StatsCharacterStatGetterType|string, tooltip:TooltipData)
	---@param id StatsCharacterStatGetterType|string|nil Optional Stat ID to filter by, such as "Damage".
	Stat = function(callback, id)
		TooltipHooks:RegisterListener("Stat", id, callback)
	end,

	---@param callback fun(character:EclCharacter, status:EclStatus, tooltip:TooltipData)
	---@param statusId string|nil Optional Status ID to filter by.
	Status = function(callback, statusId)
		TooltipHooks:RegisterListener("Status", statusId, callback)
	end,

	---Register a callback for when cloud and ground surface tooltip text is shown.
	---@param callback fun(character:EclCharacter, surface:string, tooltip:TooltipData)
	---@param surfaceId SurfaceType|nil Optional Surface ID to filter by.
	Surface = function(callback, surfaceId)
		TooltipHooks:RegisterListener("Surface", surfaceId, callback)
	end,

	---@param callback fun(character:EclCharacter, tag:string, tooltip:TooltipData)
	---@param tag string|nil Optional Tag ID to filter by.
	Tag = function(callback, tag)
		TooltipHooks:RegisterListener("Tag", tag, callback)
	end,

	---@param callback fun(character:EclCharacter, talent:StatsTalentType|string, tooltip:TooltipData)
	---@param talentId StatsTalentType|nil Optional Talent ID to filter by.
	Talent = function(callback, talentId)
		TooltipHooks:RegisterListener("Talent", talentId, callback)
	end,

	---Called for both mouse-hovered items, and item names displayed when pressing "Show World Tooltips".
	---@param callback fun(item:EclItem|nil, tooltip:TooltipData)
	---@param statsId string|nil Optional item StatsId to filter by.
	World = function(callback, statsId)
		TooltipHooks:RegisterListener("World", statsId, callback)
	end,
}

---Register a function to call when a tooltip occurs.
---Examples:
---Game.Tooltip.RegisterListener("Skill", nil, myFunction) - Register a function for skill type tooltips.
---Game.Tooltip.RegisterListener("Status", "HASTED", myFunction) - Register a function for a HASTED status tooltip.
---Game.Tooltip.RegisterListener(myFunction) - Register a function for every kind of tooltip.
---@param tooltipTypeOrCallback TooltipRequestType|function The tooltip type, such as "Skill".
---@param idOrNil string|function The tooltip ID, such as "Projectile_Fireball".
---@param callbackOrNil function If the first two parameters are set, this is the function to invoke.
function Game.Tooltip.RegisterListener(tooltipTypeOrCallback, idOrNil, callbackOrNil)
	if type(callbackOrNil) == "function" then
		--assert(type(tooltipTypeOrCallback) == "string", "If the third parameter is a function, the first parameter must be a string (TooltipType).")
		--assert(type(tooltipID) == "string", "If the third parameter is a function, the second parameter must be a string.")
		TooltipHooks:RegisterListener(tooltipTypeOrCallback, idOrNil, callbackOrNil)
	elseif type(idOrNil) == "function" then
		assert(type(tooltipTypeOrCallback) == "string", "If the second parameter is a function, the first parameter must be a string (TooltipType).")
		TooltipHooks:RegisterListener(tooltipTypeOrCallback, nil, idOrNil)
	elseif type(tooltipTypeOrCallback) == "function" then
		TooltipHooks:RegisterListener(nil, nil, tooltipTypeOrCallback)
	else
		local t1 = type(tooltipTypeOrCallback)
		local t2 = type(idOrNil)
		local t3 = type(callbackOrNil)
		_PrintError(string.format("[Game.Tooltip.RegisterListener] Invalid arguments - 1: [%s](%s), 2: [%s](%s), 3: [%s](%s)", tooltipTypeOrCallback, t1, idOrNil, t2, callbackOrNil, t3))
	end
end

---@alias GameTooltipRequestListener fun(request:AnyTooltipRequest, ui:UIObject, uiType:integer, event:string, id:string|number|boolean|nil, ...:string|number|boolean|nil)

---@param typeOrCallback string|GameTooltipRequestListener
---@param callbackOrNil GameTooltipRequestListener
---@param state string The function state, either "before" or "after".
function Game.Tooltip.RegisterRequestListener(typeOrCallback, callbackOrNil, state)
	state = state or "after"
	local t = type(typeOrCallback)
	if t == "string" then
		assert(type(callbackOrNil) == "function", "Second parameter must be a function.")
		TooltipHooks:RegisterRequestListener(typeOrCallback, callbackOrNil, state)
	elseif t == "function" then
		TooltipHooks:RegisterRequestListener(nil, typeOrCallback, state)
	end
end

---@alias GameTooltipBeforeNotifyListener fun(request:AnyTooltipRequest, ui:UIObject, method:string, tooltip:TooltipData)

---@param typeOrCallback string|GameTooltipBeforeNotifyListener Request type or the callback to register.
---@param callbackOrNil GameTooltipBeforeNotifyListener The callback to register if the first parameter is a string.
function Game.Tooltip.RegisterBeforeNotifyListener(typeOrCallback, callbackOrNil)
	local t = type(typeOrCallback)
	if t == "string" then
		assert(type(callbackOrNil) == "function", "Second parameter must be a function.")
		TooltipHooks:RegisterBeforeNotifyListener(typeOrCallback, callbackOrNil)
	elseif t == "function" then
		TooltipHooks:RegisterBeforeNotifyListener("All", typeOrCallback)
	end
end

---Check if the current tooltip request type matches the given type.
---@param t TooltipRequestType
---@return boolean
function Game.Tooltip.RequestTypeEquals(t)
	if TooltipHooks.ActiveType == t or (TooltipHooks.NextRequest and TooltipHooks.NextRequest.Type == t) then
		return true
	end
	return false
end

---Check if the last tooltip request type matches the given type.
---@param t TooltipRequestType
---@return boolean
function Game.Tooltip.LastRequestTypeEquals(t)
	if TooltipHooks.Last.Type == t or (TooltipHooks.NextRequest and TooltipHooks.NextRequest.Type == t) then
		return true
	end
	return false
end

---Get the current or last request table and type.
---@return AnyTooltipRequest request
---@return TooltipRequestType requestType
function Game.Tooltip.GetCurrentOrLastRequest()
	if TooltipHooks.NextRequest then
		return TooltipHooks.NextRequest,TooltipHooks.ActiveType
	end
	if TooltipHooks.Last then
		return TooltipHooks.Last.Request,TooltipHooks.Last.Type
	end
	return nil,""
end

---Returns true if a tooltip is currently open.
---@return boolean
function Game.Tooltip.IsOpen()
	return TooltipHooks.IsOpen
end

local function CaptureBuiltInUIs()
	for i = 1,150 do
		local ui = _GetUIByType(i)
		if ui ~= nil then
			ui:CaptureExternalInterfaceCalls()
			ui:CaptureInvokes()
		end
	end
end

local function EnableHooks()
	RequestProcessor.ControllerEnabled = (_GetUIByPath("Public/Game/GUI/msgBox_c.swf") or _GetUIByType(_UITYPE.msgBox_c)) ~= nil

	if TooltipHooks.InitializationRequested then
		TooltipHooks:Init()
	end

	CaptureBuiltInUIs()
end

Ext.RegisterListener("GameStateChanged", function (from, to)
	if to == "Menu" then
		EnableHooks()
	end
end)

Ext.RegisterListener("SessionLoaded", function()
	TooltipHooks.SessionLoaded = true
	EnableHooks()
end)

Ext.RegisterListener("UIObjectCreated", function(ui)
	ui:CaptureExternalInterfaceCalls()
	-- Has the 'no flash player' warning if the root is nil
	if ui:GetRoot() ~= nil then
		ui:CaptureInvokes()
	elseif _GetGameState() == "Running" then
		Ext.PostMessageToServer("LeaderLib_DeferUICapture", tostring(Mods.LeaderLib.Client.ID))
	end
end)

Ext.RegisterNetListener("LeaderLib_CaptureActiveUIs", function()
	CaptureBuiltInUIs()
end)

--#region Annotations

---@alias TooltipElementType string|"AbilityBoost"|"AbilityDescription"|"AbilityTitle"|"AccuracyBoost"|"APCostBoost"|"APMaximumBoost"|"APRecoveryBoost"|"APStartBoost"|"ArmorBoost"|"ArmorSet"|"ArmorSlotType"|"ArmorValue"|"Blocking"|"CanBackstab"|"ChanceToHitBoost"|"ConsumableDamage"|"ConsumableDuration"|"ConsumableEffect"|"ConsumableEffectUknown"|"ConsumablePermanentDuration"|"ContainerIsLocked"|"CritChanceBoost"|"DamageBoost"|"DodgeBoost"|"Durability"|"EmptyRuneSlot"|"Engraving"|"EquipmentUnlockedSkill"|"Equipped"|"ExtraProperties"|"Flags"|"IsQuestItem"|"ItemAttackAPCost"|"ItemDescription"|"ItemGoldValue"|"ItemLevel"|"ItemName"|"ItemRarity"|"ItemRequirement"|"ItemUseAPCost"|"ItemWeight"|"MagicArmorValue"|"NeedsIdentifyLevel"|"OtherStatBoost"|"PickpocketInfo"|"PriceToIdentify"|"PriceToRepair"|"Reflection"|"ResistanceBoost"|"RuneEffect"|"RuneSlot"|"ShowSkillIcon"|"SkillAlreadyLearned"|"SkillAlreadyUsed"|"SkillAPCost"|"SkillbookSkill"|"SkillCanFork"|"SkillCanPierce"|"SkillCleansesStatus"|"SkillCooldown"|"SkillDamage"|"SkillDescription"|"SkillDuration"|"SkillExplodeRadius"|"SkillHealAmount"|"SkillIcon"|"SkillMPCost"|"SkillMultiStrikeAttacks"|"SkillName"|"SkillOnCooldown"|"SkillPathDistance"|"SkillPathSurface"|"SkillProjectileCount"|"SkillProperties"|"SkillRange"|"SkillRequiredEquipment"|"SkillSchool"|"SkillStrikeCount"|"SkillTier"|"SkillWallDistance"|"StatBoost"|"StatMEMSlot"|"StatName"|"StatsAPBase"|"StatsAPBonus"|"StatsAPDesc"|"StatsAPMalus"|"StatsAPTitle"|"StatsATKAPCost"|"StatsBaseValue"|"StatsCriticalInfos"|"StatsDescription"|"StatsDescriptionBoost"|"StatsGearBoostNormal"|"StatsPercentageBoost"|"StatsPercentageMalus"|"StatsPercentageTotal"|"StatsPointValue"|"StatsTalentsBoost"|"StatsTalentsMalus"|"StatsTotalDamage"|"StatSTRWeight"|"StatusBonus"|"StatusDescription"|"StatusImmunity"|"StatusMalus"|"TagDescription"|"Tags"|"TalentDescription"|"TalentTitle"|"VitalityBoost"|"WandCharges"|"WandSkill"|"WarningText"|"WeaponCritChance"|"WeaponCritMultiplier"|"WeaponDamage"|"WeaponDamagePenalty"|"WeaponRange"|
---@alias TooltipRequestType "Ability"|"CustomStat"|"Generic"|"Item"|"PlayerPortrait"|"Pyramid"|"Rune"|"Skill"|"Stat"|"Status"|"Surface"|"Tag"|"Talent"|"World"
---@alias AnyTooltipRequest TooltipItemRequest|TooltipRuneRequest|TooltipSkillRequest|TooltipStatusRequest|TooltipAbilityRequest|TooltipTalentRequest|TooltipStatRequest|TooltipSurfaceRequest|TooltipPyramidRequest|TooltipTagRequest|TooltipCustomStatRequest|TooltipGenericRequest|TooltipWorldRequest

---@class TooltipElement
---@field Type TooltipElementType

---@class TooltipLabelElement
---@field Label string

---@class TooltipLabelDamageElement
---@field Label string
---@field DamageType integer
---@field MinDamage integer
---@field MaxDamage integer

---@class TooltipLabelNumValueElement
---@field Label string
---@field Value number

---@class TooltipLabelStringValueElement
---@field Label string
---@field Value string

---@class BoostSpec:TooltipElement
---@field Type string
---@field Value number

---@class ItemName:TooltipLabelElement
---@class ItemWeight:TooltipLabelElement
---@class ItemGoldValue:TooltipLabelElement
---@class ItemLevel:TooltipLabelNumValueElement
---@class ItemDescription:TooltipLabelElement
---@class ItemRarity:TooltipLabelElement

---@class ItemUseAPCost:TooltipLabelNumValueElement
---@field RequirementMet boolean

---@class ItemAttackAPCost:TooltipLabelNumValueElement
---@field Warning string
---@field RequirementMet boolean

---@class StatBoost:BoostSpec
---@class ResistanceBoost:BoostSpec
---@class AbilityBoost:BoostSpec
---@class OtherStatBoost:TooltipLabelStringValueElement
---@class VitalityBoost:BoostSpec
---@class ChanceToHitBoost:BoostSpec
---@class DamageBoost:BoostSpec
---@class APCostBoost:BoostSpec
---@class APMaximumBoost:BoostSpec
---@class APStartBoost:BoostSpec
---@class APRecoveryBoost:BoostSpec
---@class CritChanceBoost:BoostSpec
---@class ArmorBoost:BoostSpec
---@class ConsumableDuration:TooltipLabelStringValueElement
---@class ConsumablePermanentDuration:TooltipLabelStringValueElement
---@class ConsumableEffect:TooltipLabelStringValueElement

---@class ConsumableDamage:TooltipLabelDamageElement

---@class ExtraProperties:TooltipLabelElement
---@class Flags:TooltipLabelElement

---@class ItemRequirement:TooltipLabelElement
---@field RequirementMet boolean

---@class WeaponDamage:TooltipLabelDamageElement

---@class WeaponDamagePenalty:TooltipLabelElement
---@class WeaponCritMultiplier:TooltipLabelStringValueElement
---@class WeaponCritChance:TooltipLabelStringValueElement
---@class WeaponRange:TooltipLabelStringValueElement

---@class Durability:TooltipLabelNumValueElement
---@field Max number

---@class CanBackstab:TooltipLabelElement
---@class AccuracyBoost:TooltipLabelNumValueElement
---@class DodgeBoost:TooltipLabelNumValueElement

---@class EquipmentUnlockedSkill:TooltipLabelStringValueElement
---@field Icon number

---@class WandSkill:TooltipLabelStringValueElement
---@field Icon string
---@field Warning string

---@class WandCharges:TooltipLabelNumValueElement
---@field MaxValue number

---@class ArmorValue:TooltipLabelNumValueElement
---@class ArmorSlotType:TooltipLabelElement
---@class Blocking:TooltipLabelNumValueElement
---@class NeedsIdentifyLevel:TooltipLabelElement
---@class IsQuestItem:TooltipElement
---@class PriceToIdentify:TooltipLabelStringValueElement
---@class PriceToRepair:TooltipLabelStringValueElement
---@class PickpocketInfo:TooltipLabelElement
---@class Engraving:TooltipLabelElement
---@class ContainerIsLocked:TooltipLabelElement

---@class Tags:TooltipLabelStringValueElement
---@field Warning string

---@class SkillName:TooltipLabelElement
---@class SkillIcon:TooltipLabelElement

---@class SkillSchool:TooltipLabelElement
---@field Icon number

---@class SkillTier:TooltipLabelElement

---@class SkillRequiredEquipment:TooltipLabelElement
---@field RequirementMet boolean

---@class SkillAPCost:TooltipLabelNumValueElement
---@field Warning string
---@field RequirementMet boolean

---@class SkillCooldown:TooltipLabelNumValueElement
---@field Warning string
---@field ValueText string

---@class SkillDescription:TooltipLabelElement
---@class SkillDamage:TooltipLabelDamageElement
---@class SkillRange:TooltipLabelStringValueElement
---@class SkillExplodeRadius:TooltipLabelStringValueElement
---@class SkillCanPierce:TooltipLabelStringValueElement
---@class SkillCanFork:TooltipLabelStringValueElement
---@class SkillStrikeCount:TooltipLabelStringValueElement
---@class SkillProjectileCount:TooltipLabelStringValueElement
---@class SkillCleansesStatus:TooltipLabelStringValueElement
---@class SkillMultiStrikeAttacks:TooltipLabelStringValueElement
---@class SkillWallDistance:TooltipLabelStringValueElement
---@class SkillPathSurface:TooltipLabelStringValueElement
---@class SkillPathDistance:TooltipLabelStringValueElement
---@class SkillHealAmount:TooltipLabelStringValueElement

---@class SkillDuration:TooltipLabelNumValueElement
---@field Warning string

---@class ConsumableEffectUknown:TooltipLabelElement
---@class Reflection:TooltipLabelElement
---@class SkillAlreadyLearned:TooltipLabelElement
---@class SkillOnCooldown:TooltipLabelElement
---@class SkillAlreadyUsed:TooltipLabelElement
---@class AbilityTitle:TooltipLabelElement

---@class AbilityDescription:TooltipElement
---@field AbilityId number
---@field Description string
---@field Description2 string
---@field CurrentLevelEffect string
---@field NextLevelEffect string

---@class TalentTitle:TooltipLabelElement

---@class TalentDescription:TooltipElement
---@field TalentId number
---@field Description string
---@field Requirement string
---@field IncompatibleWith string
---@field Selectable boolean
---@field Unknown boolean

---@class SkillMPCost:TooltipLabelNumValueElement
---@field RequirementMet boolean

---@class MagicArmorValue:TooltipLabelNumValueElement
---@field RequirementMet boolean

---@class WarningText:TooltipLabelElement
---@class RuneSlot:TooltipLabelStringValueElement

---@class RuneEffect:TooltipElement
---@field Unknown1 number
---@field Rune1 string
---@field Rune2 string
---@field Rune3 string
---@field Label string
---@field Label2 string

---@class Equipped:TooltipLabelElement
---@field EquippedBy string
---@field Slot string

---@class ShowSkillIcon:TooltipElement
---@class SkillbookSkill:TooltipLabelStringValueElement
---@field Icon number

---@class EmptyRuneSlot:TooltipLabelStringValueElement
---@class StatName:TooltipLabelElement
---@class StatsDescription:TooltipLabelElement
---@class StatsDescriptionBoost:TooltipLabelNumValueElement
---@class StatSTRWeight:TooltipLabelElement
---@class StatMEMSlot:TooltipLabelElement
---@class StatsPointValue:TooltipLabelElement
---@class StatsTalentsBoost:TooltipLabelElement
---@class StatsTalentsMalus:TooltipLabelElement
---@class StatsBaseValue:TooltipLabelElement
---@class StatsPercentageBoost:TooltipLabelElement
---@class StatsPercentageMalus:TooltipLabelElement
---@class StatsPercentageTotal:TooltipLabelNumValueElement
---@class StatsGearBoostNormal:TooltipLabelElement
---@class StatsATKAPCost:TooltipLabelElement
---@class StatsCriticalInfos:TooltipLabelElement
---@class StatsAPTitle:TooltipLabelElement
---@class StatsAPDesc:TooltipLabelElement
---@class StatsAPBase:TooltipLabelElement
---@class StatsAPBonus:TooltipLabelElement
---@class StatsAPMalus:TooltipLabelElement
---@class StatsTotalDamage:TooltipLabelElement

---@class TagDescription:TooltipLabelElement
---@field Image number

---@class StatusImmunity:TooltipLabelElement
---@class StatusBonus:TooltipLabelElement
---@class StatusMalus:TooltipLabelElement
---@class StatusDescription:TooltipLabelElement

--#endregion