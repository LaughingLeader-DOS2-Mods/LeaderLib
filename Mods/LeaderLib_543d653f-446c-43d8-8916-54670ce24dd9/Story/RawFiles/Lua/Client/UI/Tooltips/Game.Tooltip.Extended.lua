local math = math
local table = table
local debug = debug
local pairs = pairs
local ipairs = ipairs
local type = type
local string = string
local setmetatable = setmetatable
local xpcall = xpcall
local Ext = Ext
local print = print
local Mods = Mods
local Game = Game
local LOGLEVEL = LOGLEVEL
local fprint = fprint
local Dump = Common.Dump
local Data = Data
local CustomStatSystem = CustomStatSystem
local Client = Client

Game.Tooltip = {}
---@type TooltipRequestProcessor
local RequestProcessor = Ext.Require("Client/UI/Tooltips/TooltipRequests.lua")

_ENV = Game.Tooltip
if setfenv ~= nil then
	setfenv(1, Game.Tooltip)
end

local ControllerVars = {
	Enabled = false,
	LastPlayer = nil,
	LastOverhead = nil
}

local tooltipCustomIcons = {}

function Game.Tooltip.PrepareIcon(ui, id, icon, w, h)
	ui:SetCustomIcon(id, icon, w, h)
	tooltipCustomIcons[#tooltipCustomIcons+1] = id
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

-- for i,type in pairs(TooltipItemIds) do
-- 	TooltipItemTypes[type] = i
-- end

local _Label = {"Label", "string"}
local _Value = {"Value", "string"}
local _NumValue = {"Value", "number"}
local _Icon = {"Icon", "string"}
local _Warning = {"Warning", "string"}
local _Unused = {nil, nil}
local BoostSpec = {_Label, _NumValue, _Unused}

---@class TooltipElement:table

---@class BoostSpec:TooltipElement
---@field Label string
---@field Value number

---@class ItemName:TooltipElement
---@field Label string

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
		Ext.PrintError("Not enough fields to parse spec @" .. index)
		return
	end

	local element = {Type = typeName}
	for i,field in pairs(spec) do
		local val = tt[index + i - 1]
		if field[1] ~= nil then
			element[field[1]] = val
		end
		if field[2] ~= nil and type(val) ~= field[2] then
			Ext.PrintWarning("Type of field " .. typeName .. "." .. field[1] .. " differs: " .. type(val) .. " vs " .. field[2] .. ":", val)
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
			Ext.PrintError("Encountered unknown tooltip item type: ", id)
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
				Ext.PrintError("No spec available for tooltip item type: ", typeName)
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
				Ext.PrintWarning("Type of field " .. element.Type .. "." .. name .. " differs: " .. type(val) .. " vs " .. fieldType .. ":", val)
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

--- @param tt table Flash tooltip array
--- @return table
function EncodeTooltipArray(elements)
	local tt = {}
	for i=1,#elements do
		local element = elements[i]
		if element then
			local type = TooltipItemTypes[element.Type]
			if type == nil then
				Ext.PrintWarning("Couldn't encode tooltip element with unknown type:", element.Type)
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
						Ext.PrintWarning("No encoder found for tooltip element type:", element.Type)
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

	Ext.Print("tooltip_array: " .. Ext.JsonStringify(tooltipArray2))
	local parsed = ParseTooltipArray(tooltipArray)
	Ext.Print("Parsed: " .. Ext.JsonStringify(parsed))
	local encoded = EncodeTooltipArray(parsed)
	local parsed2 = ParseTooltipArray(encoded)
	Ext.Print("Encoding matches: ", Ext.JsonStringify(parsed2) == Ext.JsonStringify(parsed))
end

---@class TooltipRequest:table
---@field Type string

---@class TooltipItemRequest:TooltipRequest
---@field Item EclItem
---@field Character EclCharacter

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
---@field StatData CustomStatData

---@class TooltipGenericRequest:table
---@field Type string
---@field CallingUI integer
---@field Text string
---@field X number|nil
---@field Y number|nil
---@field Width number|nil
---@field Height number|nil
---@field Side string|nil
---@field AllowDelay boolean|nil
---@field AnchorEnum integer|nil
---@field BackgroundType integer|nil

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
}

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
		CompareOff = "tooltipOffHand_array"
	},
	Console = {
		CharacterCreation = {
			Main = "tooltipArray",
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

local selectEvents = {
	"selectStat",
	"selectAbility",
	"selectAbility",
	"selectTalent",
	"selectStatus",
	"selectTitle",
}

ControllerVars.Enabled = (Ext.GetBuiltinUI("Public/Game/GUI/msgBox_c.swf") or Ext.GetUIByType(Data.UIType.msgBox_c)) ~= nil

function TooltipHooks:RegisterControllerHooks()
	Ext.RegisterUITypeInvokeListener(Data.UIType.equipmentPanel_c, "updateTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.EquipmentPanel, ui, ...)
	end)
	Ext.RegisterUITypeInvokeListener(Data.UIType.equipmentPanel_c, "updateEquipTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.EquipmentPanel, ui, ...)
	end)

	Ext.RegisterUITypeInvokeListener(Data.UIType.craftPanel_c, "updateTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.CraftPanel, ui, ...)
	end)

	Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, "selectedAttribute", function(ui, method, id)
		self:OnRequestConsoleExamineTooltip(ui, method, id)
	end)
	Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, "selectCustomStat", function(ui, method, id)
		self:OnRequestConsoleExamineTooltip(ui, method, id)
	end)
	-- Disabled for now since this function doesn't include any ID for the tag.
	-- Ext.RegisterUICall(statsPanel, "selectTag", function(ui, method, emptyWorthlessTagTooltip)
	-- 	print(method, emptyWorthlessTagTooltip)
	-- 	local main = ui:GetRoot()
	-- 	local tags_mc = main.mainpanel_mc.stats_mc.tags_mc
	-- 	local selectedTag = tags_mc.statList.m_CurrentSelection
	-- 	if selectedTag ~= nil then
	-- 		local tagNameText = selectedTag.label_txt.htmlText
	-- 		self:OnRequestConsoleExamineTooltip(ui, method, tagNameText)
	-- 	end
	-- end)
	Ext.RegisterUITypeInvokeListener(Data.UIType.statsPanel_c, "showTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.StatsPanel, ui, ...)
	end)

	Ext.RegisterUITypeInvokeListener(Data.UIType.examine_c, "showFormattedTooltip", function (ui, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.Examine, ui, ...)
	end)

	for i,v in pairs(selectEvents) do
		Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, v, function(ui, ...)
			self:OnRequestConsoleExamineTooltip(ui, ...)
		end)
		Ext.RegisterUITypeCall(Data.UIType.examine_c, v, function(ui, ...)
			self:OnRequestConsoleExamineTooltip(ui, ...)
		end)
	end
	
	Ext.RegisterUITypeInvokeListener(Data.UIType.bottomBar_c, "updateTooltip", function (...)
		self:OnRenderTooltip(TooltipArrayNames.Console.BottomBar, ...)
	end)
	Ext.RegisterUITypeInvokeListener(Data.UIType.bottomBar_c, "setPlayerHandle", function (ui, method, handle)
		if handle ~= nil and handle ~= 0 then
			ControllerVars.LastPlayer = Ext.DoubleToHandle(handle)
		end
	end)
	self.GetLastPlayer = function(self)
		if ControllerVars.Enabled then
			local ui = Ext.GetUIByType(Data.UIType.bottomBar_c)
			if ui then
				local handle = ui:GetRoot().characterHandle
				if handle ~= nil then
					handle = Ext.DoubleToHandle(handle)
					ControllerVars.LastPlayer = handle
					return handle
				else
					return ControllerVars.LastPlayer
				end
			end
		end
	end

	Ext.RegisterUITypeInvokeListener(Data.UIType.partyInventory_c, "updateTooltip", function (...)
		self:OnRenderTooltip(TooltipArrayNames.Console.PartyInventory, ...)
	end)

	Ext.RegisterUITypeInvokeListener(Data.UIType.reward_c, "updateTooltipData", function (ui, method, ...)
		self:OnRenderTooltip(TooltipArrayNames.Console.Reward, ui, method, ...)
	end)

	Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation_c, "showTooltip", function(...)
		self:OnRenderTooltip(TooltipArrayNames.Console.CharacterCreation, ...)
	end)

	Ext.RegisterUITypeInvokeListener(Data.UIType.trade_c, "updateTooltip", function(...)
		self:OnRenderTooltip(TooltipArrayNames.Console.Trade, ...)
	end)

	-- This allows examine_c to have a character reference
	Ext.RegisterUITypeInvokeListener(Data.UIType.overhead, "updateOHs", function (ui, method, ...)
		if ControllerVars.Enabled then
			local main = ui:GetRoot()
			for i=0,#main.selectionInfo_array,21 do
				local id = main.selectionInfo_array[i]
				if id then
					ControllerVars.LastOverhead = Ext.DoubleToHandle(id)
					break
				end
			end
		end
	end)
end

function TooltipHooks:Init()
	if self.Initialized then
		return
	end

	for i = 1,150 do
		local ui = Ext.GetUIByType(i)
		if ui ~= nil then
			ui:CaptureExternalInterfaceCalls()
			ui:CaptureInvokes()
		end
	end

	RequestProcessor:Init(self)

	Ext.RegisterUINameInvokeListener("addFormattedTooltip", function (...)
		self:OnRenderTooltip(TooltipArrayNames.Default, ...)
	end)

	Ext.RegisterUINameInvokeListener("addStatusTooltip", function (...)
		self:OnRenderTooltip(TooltipArrayNames.Default, ...)
	end)

	--Generic tooltips
	Ext.RegisterUINameCall("showTooltip", function(ui, ...)
		if ui:GetTypeId() == Data.UIType.examine then
			self:OnRequestExamineUITooltip(ui, ...)
		else
			self:OnRequestGenericTooltip(ui, ...)
		end
	end, "Before")

	--Disabled for now since character portrait tooltips get spammed
	-- Ext.RegisterUINameCall("showCharTooltip", function(ui, call, handle, x, y, width, height, side)
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
	
	Ext.RegisterUINameInvokeListener("addTooltip", function (ui, call, text, ...)
		self:OnRenderGenericTooltip(ui, call, text, ...)
	end)

	Ext.RegisterUINameCall("hideTooltip", function (ui, call, ...)
		self.IsOpen = false
		self.ActiveType = ""
		if self.NextRequest and self.NextRequest.Type == "Generic" then
			self.Last.Request = self.NextRequest
			self.NextRequest = nil
		end
		local tt = Ext.GetUIByType(Data.UIType.tooltip)
		if #tooltipCustomIcons > 0 then
			for _,v in pairs(tooltipCustomIcons) do
				tt:ClearCustomIcon(v)
			end
			tooltipCustomIcons = {}
		end
	end)

	Ext.RegisterUINameCall("keepUIinScreen", function (ui, method, keepUIinScreen)
		if self.GenericTooltipData then
			self:UpdateGenericTooltip(ui, method, keepUIinScreen)
		end
	end)

	---@param ui UIObject
	Ext.RegisterListener("UIObjectCreated", function (ui)
		ui:CaptureExternalInterfaceCalls()
		ui:CaptureInvokes()
	end)

	self:RegisterControllerHooks()

	self.Initialized = true
end

function TooltipHooks:OnRequestGenericTooltip(ui, call, text, x, y, width, height, side, allowDelay)
	if self.NextRequest == nil then
		---@type TooltipGenericRequest
		local request = {
			Type = "Generic",
			Text = text,
			CallingUI = ui:GetTypeId()
		}
		if x then
			request.X = x
			request.Y = y
			request.Width = width
			request.Height = height
			request.Side = side
			request.AllowDelay = allowDelay
		end

		self.NextRequest = request
		self.Last.Event = call
		self.Last.UIType = ui:GetTypeId()
	end
end

function TooltipHooks:UpdateGenericTooltip(ui, method, keepUIinScreen)
	if not self.GenericTooltipData then
		return
	end
	local this = ui:GetRoot()
	if this and this.tf then
		this.tf.shortDesc = self.GenericTooltipData.Text
		this.tf.setText(self.GenericTooltipData.Text,self.GenericTooltipData.BackgroundType or 0)
	end
	self.GenericTooltipData = nil
end

---@param ui UIObject
---@param method string
function TooltipHooks:OnRenderGenericTooltip(ui, method, text, x, y, allowDelay, anchorEnum, backgroundType)
	---@type TooltipGenericRequest
	local req = self.NextRequest
	if not req or req.Type ~= "Generic" then
		return
	end
	if req.IsCharacterTooltip then
		req.Text = text
	end

	self.IsOpen = true

	---@type TooltipGenericRequest
	self.GenericTooltipData = {}
	self.GenericTooltipData.Text = text
	self.GenericTooltipData.X = x
	self.GenericTooltipData.Y = y
	req.AllowDelay = allowDelay
	req.AnchorEnum = anchorEnum
	req.BackgroundType = backgroundType

	local tooltip = TooltipData:Create(req)
	self:NotifyListeners("Generic", nil, req, tooltip)

	if tooltip.Data.Text ~= text or tooltip.Data.X ~= x or tooltip.Data.Y ~= y then
		for k,v in pairs(tooltip.Data) do
			self.GenericTooltipData[k] = v
		end
	else
		self.GenericTooltipData = nil
	end
	self.Last.Type = "Generic"
	self.Last.Request = self.NextRequest
	self.NextRequest = nil
end

--- @param ui UIObject
function TooltipHooks:OnRequestExamineUITooltip(ui, method, typeIndex, id, ...)
	local request = {
		Character = Ext.GetCharacter(ui:GetPlayerHandle())
	}

	if request.Character == nil then
		request.Character = Client:GetCharacter()
	end

	if typeIndex == 1 then
		request.Type = "Stat"
		request.Stat = TooltipStatAttributes[id]

		if request.Stat == nil then
			Ext.PrintWarning("Requested tooltip for unknown stat ID " .. id)
		end
	elseif typeIndex == 2 then
		request.Type = "Ability"
		request.Ability = Ext.EnumIndexToLabel("AbilityType", id)
	elseif typeIndex == 3 then
		request.Type = "Talent"
		request.Talent = Ext.EnumIndexToLabel("TalentType", id)
	elseif typeIndex == 7 then
		request.Type = "Status"
		local handle = Ext.DoubleToHandle(id)
		if handle and request.Character then
			request.Status = Ext.GetStatus(request.Character.Handle, handle)
		end
	else
		return
	end

	if self.NextRequest ~= nil then
		Ext.PrintWarning("Previous tooltip request not cleared in render callback?")
	end

	self.NextRequest = request
	self.Last.Event = method
	self.Last.UIType = ui:GetTypeId()
end

---@param ui UIObject
---@param item EclItem
---@return EclCharacter
function TooltipHooks:GetCompareOwner(ui, item)
	local owner = ui:GetPlayerHandle()

	if owner ~= nil then
		local char = Ext.GetCharacter(owner)
		if char.Stats.IsPlayer then
			return char
		end
	end

	local handle = nil
	if not ControllerVars.Enabled then
		local hotbar = Ext.GetUIByType(Data.UIType.hotBar)
		if hotbar ~= nil then
			local main = hotbar:GetRoot()
			if main ~= nil then
				handle = Ext.DoubleToHandle(main.hotbar_mc.characterHandle)
			end
		end
	else
		local hotbar = Ext.GetUIByType(Data.UIType.bottomBar_c)
		if hotbar ~= nil then
			local main = hotbar:GetRoot()
			if main ~= nil then
				handle = Ext.DoubleToHandle(main.characterHandle)
			end
		end
	end

	if handle ~= nil then
		return Ext.GetCharacter(handle)
	end

	local character = nil
	if Client then
		character = Client:GetCharacter()
	end

	if character == nil then
		--Default to the item's owner last since it may not be the active character.
		local itemOwner = item:GetOwnerCharacter()
		if itemOwner ~= nil then
			local ownerCharacter = Ext.GetCharacter(itemOwner)
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
--- @return string|nil
function TooltipHooks:GetCompareItem(ui, item, offHand)
	local char = self:GetCompareOwner(ui, item)

	if char == nil then
		Ext.PrintWarning("Tooltip compare render failed: Couldn't find owner of item", item.StatsId)
		return nil
	end

	if item.Stats.ItemSlot == "Weapon" then
		if offHand then
			return char:GetItemBySlot("Shield")
		else
			return char:GetItemBySlot("Weapon")
		end
	elseif item.Stats.ItemSlot == "Ring" or item.Stats.ItemSlot == "Ring2" then
		if offHand then
			return char:GetItemBySlot("Ring2")
		else
			return char:GetItemBySlot("Ring")
		end
	else
		return char:GetItemBySlot(item.Stats.ItemSlot)
	end
end

---@param arrayData TooltipArrayData
---@param ui UIObject
function TooltipHooks:OnRenderTooltip(arrayData, ui, method, ...)
	if self.NextRequest == nil then
		Ext.PrintWarning("Got tooltip render request, but did not find original tooltip info!")
		return
	end

	self.IsOpen = true
	
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
				req.Item = Ext.GetItem(compareItem)
				self:OnRenderSubTooltip(ui, arrayData.CompareMain, req, method, ...)
				req.Item = reqItem
			else
				Ext.PrintError("Tooltip compare render failed: Couldn't find item to compare")
			end
		end

		if compareArray and compareArray[0] ~= nil then
			local compareItem = self:GetCompareItem(ui, reqItem, true)
			if compareItem ~= nil then
				req.Item = Ext.GetItem(compareItem)
				self:OnRenderSubTooltip(ui, arrayData.CompareOff, req, method, ...)		
				req.Item = reqItem
			else
				Ext.PrintError("Tooltip compare render failed: Couldn't find off-hand item to compare")
			end
		end
	end

	self.Last.Request = self.NextRequest
	self.NextRequest = nil
end

---@param ui UIObject
---@param propertyName string
---@param req TooltipRequest
---@param method string
function TooltipHooks:OnRenderSubTooltip(ui, propertyName, req, method, ...)
	iconUpdateRequired = false
	local tt = TableFromFlash(ui, propertyName)
	local params = ParseTooltipArray(tt)
	if params ~= nil then
		local tooltip = TooltipData:Create(params)
		if req.Type == "Stat" then
			self:NotifyListeners("Stat", req.Stat, req, tooltip, req.Character, req.Stat)
		elseif req.Type == "CustomStat" then
			if req.RequestUpdate then
				CustomStatSystem:UpdateStatTooltipArray(ui, req.Stat, tooltip, req)
				req.RequestUpdate = false
			end
			local statData = req.StatData or CustomStatSystem:GetStatByDouble(req.Stat)
			if statData ~= nil then
				req.StatData = statData
				self:NotifyListeners("CustomStat", statData.ID or statData.UUID, req, tooltip, req.Character, statData)
				CustomStatSystem:OnTooltip(ui, req.Character, statData, tooltip)
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
			self:NotifyListeners("Status", req.Status.StatusId, req, tooltip, req.Character, req.Status)
		elseif req.Type == "Item" then
			self:NotifyListeners("Item", nil, req, tooltip, req.Item)
		elseif req.Type == "Rune" then
			self:NotifyListeners("Rune", req.StatsId, req, tooltip, req.Item, req.Rune, req.Slot)
		elseif req.Type == "Tag" then
			self:NotifyListeners("Tag", req.Category, req, tooltip, req.Tag)
		elseif req.Type == "Generic" then
			-- Skip since it's handled in addTooltip
		else
			Ext.PrintError("Unknown tooltip type? ", req.Type)
		end

		local newTooltip = EncodeTooltipArray(tooltip.Data)
		if newTooltip ~= nil then
			ReplaceTooltipArray(ui, propertyName, newTooltip, tt)
		end
	end
end

-- Controller/Console UI support

--- @param ui UIObject
function TooltipHooks:OnRequestConsoleExamineTooltip(ui, method, id, characterHandle)
	local request = {
		Character = nil
	}

	if characterHandle == nil then
		local uiType = ui:GetTypeId()
		--TODO: Need a way to get the object's characterHandle for what's being examined.
		if uiType == Data.UIType.examine_c then
			characterHandle = ControllerVars.LastOverhead
		else
			characterHandle = ui:GetPlayerHandle()
			if characterHandle == nil and uiType == Data.UIType.statsPanel_c then
				characterHandle = self:GetLastPlayer() -- Get the bottomBar player
			end
		end
	end

	if characterHandle ~= nil then
		request.Character = Ext.GetCharacter(characterHandle) or nil
	end

	if method == "selectStatus" then
		local statusHandle = Ext.DoubleToHandle(id)
		request.Type = "Status"
		request.Status = nil
		if statusHandle ~= nil and request.Character ~= nil then
			request.Status = Ext.GetStatus(request.Character.Handle, statusHandle)
		end
	elseif method == "selectAbility" then
		request.Type = "Ability"
		request.Ability = Ext.EnumIndexToLabel("AbilityType", id)
	elseif method == "selectTalent" then
		request.Type = "Talent"
		request.Talent = Ext.EnumIndexToLabel("TalentType", id)
	elseif method == "selectStat" or method == "selectedAttribute" then
		request.Type = "Stat"
		request.Stat = id
		local stat = TooltipStatAttributes[request.Stat]
		if stat ~= nil then
			request.Stat = stat
		else
			Ext.PrintWarning("Requested tooltip for unknown stat ID " .. request.Stat)
		end
	elseif method == "selectCustomStat" then
		request.Type = "CustomStat"
		request.Stat = id
	elseif method == "selectTag" then
		request.Type = "Tag"
		request.Tag = id
		request.Category = ""
	end

	self.NextRequest = request
	self.Last.Event = method
	self.Last.UIType = ui:GetTypeId()
end

---@param type string
---@param name string
---@param request TooltipRequest
---@param tooltip TooltipData
---@vararg any
function TooltipHooks:NotifyListeners(type, name, request, tooltip, ...)
    local args = {...}
    table.insert(args, tooltip)
    self:NotifyAll(self.TypeListeners[type], table.unpack(args))
    if name ~= nil and self.ObjectListeners[type] ~= nil then
        self:NotifyAll(self.ObjectListeners[type][name], table.unpack(args))
    end

    self:NotifyAll(self.GlobalListeners, request, tooltip)
end

function TooltipHooks:NotifyAll(listeners, ...)
	if not listeners then
		return
	end
	for i,callback in pairs(listeners) do
		local status, err = xpcall(callback, debug.traceback, ...)
		if not status then
			Ext.PrintError("Error during tooltip callback: ", err)
		end
	end
end

function TooltipHooks:RegisterListener(type, name, listener)
	if not self.Initialized then
		if self.SessionLoaded then
			self:Init()
		else
			self.InitializationRequested = true
		end
	end

	if type == nil then
		table.insert(self.GlobalListeners, listener)
	elseif name == nil then
		if self.TypeListeners[type] == nil then
			self.TypeListeners[type] = {listener}
		else
			table.insert(self.TypeListeners[type], listener)
		end
	else
		local listeners = self.ObjectListeners[type]
		if listeners == nil then
			self.ObjectListeners[type] = {[name] = {listener}}
		else
			if listeners[name] == nil then
				listeners[name] = {listener}
			else
				table.insert(listeners[name], listener)
			end
		end
	end
end

---@class TooltipData
---@field Data TooltipElement[]
---@field ControllerEnabled boolean
---@field IsExtended boolean Simple variable a mod can check to see if this is a LeaderLib tooltip.
TooltipData = {}

---@class GenericTooltipData:TooltipData
---@field Data TooltipGenericRequest

function TooltipData:Create(data)
	local tt = {
		Data = data,
		ControllerEnabled = ControllerVars.Enabled or false,
		IsExtended = true
	}
	setmetatable(tt, {__index = self})
	return tt
end

---Whether or not the tooltip should be expanded. Check this when setting up tooltip elements.
---@return boolean
function TooltipData:IsExpanded()
	return Mods.LeaderLib.TooltipExpander.IsExpanded()
end

---Signals to the tooltip expander that pressing or releasing the expand key will cause the current visible tooltip to re-render.
function TooltipData:MarkDirty()
	return Mods.LeaderLib.TooltipExpander.MarkDirty()
end

local function ElementTypeMatch(e,t,isTable)
	if isTable then
		for i=1,#t do
			if t[i] == e then
				return true
			end
		end
	elseif e == t then
		return true
	end
end

---@param t string|string[] The tooltip element type.
---@param fallback TooltipElement|nil If an element of the type isn't found, the fallback is appended and returned, if set.
function TooltipData:GetElement(t, fallback)
	local isTable = type(t) == "table"
	for i,element in pairs(self.Data) do
		if ElementTypeMatch(element.Type, t, isTable) then
			return element
		end
	end
	--If this element wasn't found, and fallback is set, append it.
	if fallback ~= nil then
		self:AppendElement(fallback)
		return fallback
	end
end

function TooltipData:GetLastElement(t)
	local isTable = type(t) == "table"
	for i=#self.Data,1,-1 do
		local element = self.Data[i]
		if element and ElementTypeMatch(element.Type, t, isTable) then
			return element
		end
	end
end

function TooltipData:GetElements(t)
	local isTable = type(t) == "table"
	local elements = {}
	for i,element in ipairs(self.Data) do
		if ElementTypeMatch(element.Type, t, isTable) then
			table.insert(elements, element)
		end
	end
	return elements
end

function TooltipData:RemoveElements(type)
	for i=#self.Data,1,-1 do
		if self.Data[i].Type == type then
			table.remove(self.Data, i)
		end
	end
end

function TooltipData:RemoveElement(ele)
	for i,element in pairs(self.Data) do
		if element == ele then
			table.remove(self.Data, i)
			break
		end
	end
end

function TooltipData:AppendElement(ele)
	table.insert(self.Data, ele)
end

---@param ele TooltipElement
---@param appendAfter TooltipElement
function TooltipData:AppendElementAfter(ele, appendAfter)
	for i,element in pairs(self.Data) do
		if element == appendAfter then
			table.insert(self.Data, i+1, ele)
			return
		end
	end

	table.insert(self.Data, ele)
end

---@param ele TooltipElement
---@param appendAfter TooltipElement
function TooltipData:AppendElementBefore(ele, appendBefore)
	for i=1,#self.Data do
		local element = self.Data[i]
		if element == appendBefore then
			table.insert(self.Data, i-1, ele)
			return
		end
	end

	table.insert(self.Data, ele)
end

---@param ele TooltipElement
---@param elementType string|table<string,boolean>
function TooltipData:AppendElementAfterType(ele, elementType)
	local t = type(elementType)
	for i=1,#self.Data do
		local element = self.Data[i]
		if (t == "string" and element.Type == elementType) or (t == "table" and elementType[element.Type] == true) then
			table.insert(self.Data, i+1, ele)
			return
		end
	end

	table.insert(self.Data, ele)
end

---@param ele TooltipElement
---@param elementType string|table<string,boolean>
function TooltipData:AppendElementBeforeType(ele, elementType)
	local t = type(elementType)
	for i=1,#self.Data do
		local element = self.Data[i]
		if (t == "string" and element.Type == elementType) or (t == "table" and elementType[element.Type] == true) then
			table.insert(self.Data, i-1, ele)
			return
		end
	end

	table.insert(self.Data, ele)
end

function Game.Tooltip.RegisterListener(...)
	local args = {...}
	if #args == 1 then
		TooltipHooks:RegisterListener(nil, nil, args[1])
	elseif #args == 2 then
		TooltipHooks:RegisterListener(args[1], nil, args[2])
	else
		TooltipHooks:RegisterListener(args[1], args[2], args[3])
	end
end

function Game.Tooltip.RequestTypeEquals(t)
	if TooltipHooks.ActiveType == t or (TooltipHooks.NextRequest and TooltipHooks.NextRequest.Type == t) then
		return true
	end
	return false
end

function Game.Tooltip.LastRequestTypeEquals(t)
	if TooltipHooks.Last.Type == t or (TooltipHooks.NextRequest and TooltipHooks.NextRequest.Type == t) then
		return true
	end
	return false
end

---@return TooltipRequest
function Game.Tooltip.GetCurrentOrLastRequest()
	if TooltipHooks.NextRequest then
		return TooltipHooks.NextRequest
	end
	return TooltipHooks.Last.Request
end

---@return boolean
function Game.Tooltip.IsOpen()
	return TooltipHooks.IsOpen
end

local function OnSessionLoaded()
	ControllerVars.Enabled = (Ext.GetBuiltinUI("Public/Game/GUI/msgBox_c.swf") or Ext.GetUIByType(Data.UIType.msgBox_c)) ~= nil
	TooltipHooks.SessionLoaded = true
	if TooltipHooks.InitializationRequested then
		TooltipHooks:Init()
	end
end

Ext.RegisterListener("SessionLoaded", OnSessionLoaded)
