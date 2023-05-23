---@class FlashTooltipGroupHolder


local _ElementTypeToGroup = {
	AbilityBoost = 2,
	AbilityDescription = 15,
	Air = 6,
	APRecoveryBoost = 4,
	ArmorBoost = 2,
	ArmorSet = 45,
	CanBackstab = 5,
	ConsumableDuration = 5,
	ConsumableEffect = 2,
	ConsumableEffectUknown = 2,
	ConsumablePermanentDuration = 5,
	ContainerIsLocked = 5,
	CritChanceBoost = 1,
	DamageBoost = 2,
	DodgeBoost = 2,
	Durability = 5,
	Duration = 2,
	Earth = 5,
	EmptyRuneSlot = 14,
	EquipmentUnlockedSkill = 12,
	ExtraProperties = 2,
	Fire = 3,
	Flags = 2,
	Heal = 10,
	ItemAttackAPCost = 4,
	ItemLevel = 5,
	ItemRequirement = 5,
	ItemUseAPCost = 4,
	OtherStatBoost = 2,
	Physical = 8,
	PickpocketInfo = 5,
	Poison = 7,
	PriceToRepair = 5,
	Reflection = 2,
	ResistanceBoost = 2,
	RuneEffect = 8,
	RuneSlot = 7,
	SkillAlreadyLearned = 11,
	SkillAlreadyUsed = 5,
	SkillAPCost = 4,
	SkillbookSkill = 12,
	SkillCanFork = 2,
	SkillCanPierce = 2,
	SkillCleansesStatus = 2,
	SkillCooldown = 5,
	SkillDuration = 5,
	SkillExplodeRadius = 5,
	SkillHealAmount = 2,
	SkillMPCost = 6,
	SkillMultiStrikeAttacks = 2,
	SkillName = 2,
	SkillOnCooldown = 5,
	SkillPathDistance = 2,
	SkillPathSurface = 2,
	SkillProperties = 2,
	SkillRange = 5,
	SkillRequiredEquipment = 5,
	SkillWallDistance = 2,
	Splitter = 1,
	StatBoost = 2,
	StatMEMSlot = 18,
	StatsAPBase = 22,
	StatsAPBonus = 20,
	StatsAPDesc = 15,
	StatsAPMalus = 21,
	StatsAPTitle = 28,
	StatsATKAPCost = 15,
	StatsBaseValue = 22,
	StatsCriticalInfos = 1,
	StatsDescription = 15,
	StatsGearBoostNormal = 26,
	StatsPercentageBoost = 23,
	StatsPercentageMalus = 24,
	StatsPercentageTotal = 25,
	StatsPointValue = 19,
	StatsTalentsBoost = 20,
	StatsTalentsMalus = 21,
	StatsTotalDamage = 15,
	StatSTRWeight = 17,
	StatusBonus = 34,
	StatusDescription = 15,
	StatusImmunity = 33,
	StatusMalus = 35,
	Sulfur = 9,
	SurfaceDescription = 1,
	TagDescription = 15,
	Tags = 13,
	TalentDescription = 15,
	Title = 1,
	VitalityBoost = 2,
	WandCharges = 12,
	WandSkill = 12,
	WarningText = 11,
	Water = 4,
	WeaponCritChance = 1,
	WeaponCritMultiplier = 1,
	WeaponDamagePenalty = 5,
	WeaponRange = 5,
}

---@class LeaderLibTooltipWrapper:LeaderLibUIWrapper
---@field Root FlashTooltipMainTimeline|table
local Tooltip = Classes.UIWrapper:CreateFromType(Data.UIType.tooltip)

local _nextTooltipProperty = "defaultTooltip"

Tooltip.Register:Invoke("addTooltip", function (self, e, ui, event, ...)
	_nextTooltipProperty = "defaultTooltip"
end, "Before", "All")

Tooltip.Register:Invoke("addFormattedTooltip", function (self, e, ui, event, ...)
	_nextTooltipProperty = "formatTooltip"
end, "Before", "All")

---@private
---@class LeaderLibTooltipHolderWrapper
---@field mc FlashLSTooltipClass The tooltip_mc, i.e. `tf.tooltip_mc`
local TooltipHolderWrapper = {}
TooltipHolderWrapper.__index = TooltipHolderWrapper

function TooltipHolderWrapper:Wrap(mc)
	local this = {
		mc = mc
	}
	setmetatable(this, TooltipHolderWrapper)
	return this
end

---@return fun():FlashTooltipGroupHolder
function TooltipHolderWrapper:GetGroups()
	local len = #self.mc.list.content_array
	local i = -1
	return function ()
		i = i + 1
		if i < len then
			return self.mc.list.content_array[i]
		end
	end
end

---@param self LeaderLibTooltipWrapper
---@param primaryOnly? boolean
---@return LeaderLibTooltipHolderWrapper|nil
local function _GetTooltipHolder(self, primaryOnly)
	local this = self.Root
	if this then
		local tooltipMC = nil
		if this.tf ~= nil then
			tooltipMC = this.tf
		elseif this.ctf ~= nil then
			tooltipMC = this.ctf
		elseif this.ohctf ~= nil then
			tooltipMC = this.ohctf
		else
			local mc = this[_nextTooltipProperty]
			if mc then
				tooltipMC = mc
			elseif not primaryOnly then
				tooltipMC = this.formatTooltip
			end
		end
		if tooltipMC then
			return TooltipHolderWrapper:Wrap(tooltipMC.tooltip_mc)
		end
	end
end

local function _ParseArray(arr, outputTable, checkProperty)
	local len = #arr
	for i=0,len-1 do
		local element = arr[i]
		if element then
			if not checkProperty or element[checkProperty] ~= nil then
				table.insert(outputTable, element)
			end
		end
	end
end

---@return FlashTooltipGroupHolder[]
function Tooltip:GetAllTooltipGroups()
	local groups = {}
	local this = self.Root
	if this then
		if this.formatTooltip and this.formatTooltip.tooltip_mc then
			_ParseArray(this.formatTooltip.tooltip_mc.list.content_array, groups, "groupID")
		end
		if this.compareTooltip and this.compareTooltip.tooltip_mc then
			_ParseArray(this.compareTooltip.tooltip_mc.list.content_array, groups, "groupID")
		end
		if this.offhandTooltip and this.offhandTooltip.tooltip_mc then
			_ParseArray(this.offhandTooltip.tooltip_mc.list.content_array, groups, "groupID")
		end
	end
	return groups
end

local function _MovieClipsAreEqual(a,b)
	if a and b then
		return a.name == b.name
	end
	return false
end

---True if this.tf or the compare tooltips are a tooltip that supported formatted elements.
---@return boolean
function Tooltip:IsFormattedTooltip()
	local this = self.Root
	if this then
		if _MovieClipsAreEqual(this.tf, this.formatTooltip) then
			return true
		elseif _MovieClipsAreEqual(this.ctf, this.compareTooltip) then
			return true
		elseif _MovieClipsAreEqual(this.ohctf, this.offhandTooltip) then
			return true
		end
	end
	return false
end

---@param id integer
---@return FlashTooltipGroupHolder|nil
function Tooltip:GetGroupByID(id)
	local groups = self:GetAllTooltipGroups()
	for _,group in pairs(groups) do
		if group.groupID == id then
			return group
		end
	end
	return nil
end

---@param elementType TooltipElementType
---@return FlashTooltipGroupHolder|nil
function Tooltip:GetGroupByType(elementType)
	local groupid = _ElementTypeToGroup[elementType]
	if groupid then
		return self:GetGroupByID(groupid)
	end
end

---@param elementType TooltipElementType
---@return fun():FlashTooltipElement
function Tooltip:GetElementsByType(elementType)
	local id = _ElementTypeToGroup[elementType]
	local groups = self:GetAllTooltipGroups()
	local elements = {}
	for _,group in pairs(groups) do
		if group.groupID == id and group.list then
			_ParseArray(group.list.content_array, elements)
		end
	end
	local len = #elements
	local i = 0
	return function ()
		i = i + 1
		if i <= len then
			return elements[i]
		end
	end
end

return Tooltip