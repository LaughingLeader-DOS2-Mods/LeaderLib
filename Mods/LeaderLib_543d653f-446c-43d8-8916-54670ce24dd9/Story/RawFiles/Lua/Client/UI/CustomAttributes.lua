local _type = type

---@class GameHelpersUIRegisterAttributeOptions:LeaderLibCustomAttributeTooltipSettings
---@field StatType ModifierListType|ModifierListType[]

---@param statType ModifierListType
---@param opts GameHelpersUIRegisterAttributeOptions
---@param sm StatsRPGStats
local function _AddCustomAttributeEntry(statType, opts, sm)
	if sm then
		local modifier = sm.ModifierLists:GetByName(statType)
		if not modifier or modifier.Attributes:GetByName(opts.Attribute) == nil then
			fprint(LOGLEVEL.WARNING, "[GameHelpers.UI.RegisterCustomAttribute] Custom attribute (%s) does not exist in stat type (%s).", opts.Attribute, statType)
		end
	end
	if TooltipHandler.CustomAttributes[statType] == nil then
		TooltipHandler.CustomAttributes[statType] = {}
	end
	table.insert(TooltipHandler.CustomAttributes[statType], {
		Attribute = opts.Attribute,
		DisplayName = opts.DisplayName,
		TooltipElementType = opts.TooltipElementType,
		GetTooltipElement = opts.GetTooltipElement
	})
end

---Register data for displaying custom attributes in tooltips and the UI.  
---Attributes must be added via `Ext.Stats.AddAttribute` during `Ext.Events.StatsStructureLoaded`, in `BootstrapModule.lua`.  
---🔧**Client-Only**🔧  
---@see Ext_Stats.AddAttribute
---@param opts GameHelpersUIRegisterAttributeOptions
function GameHelpers.UI.RegisterCustomAttribute(opts)
	assert(_type(opts.Attribute) == "string", "Attribute param must be a string")
	local sm = Ext.Stats.GetStatsManager()
	local t = _type(opts.StatType)
	if t == "string" then
		_AddCustomAttributeEntry(opts.StatType, opts, sm)
	elseif t == "table" then
		for _,v in pairs(opts.StatType) do
			assert(_type(v) == "string", "StatType param must be a string")
			_AddCustomAttributeEntry(v, opts, sm)
		end
	else
		error(("Wrong type (%s) for opts.StatType"):format(t), 2)
	end
end

---@param item EclItem
---@param id FixedString
---@return SerializableValue|nil
local function _TryGetCustomAttributeFromItem(item, id)
	if GameHelpers.Item.IsObject(item) then
		if item.StatsFromName then
			local value = item.StatsFromName.StatsEntry[id]
			if value ~= nil then
				return value
			end
		end
	else
		return item.Stats[id]
	end
	return nil
end

---@param stat StatEntryType
---@param id FixedString
---@return SerializableValue|nil
local function _TryGetCustomAttributeFromStat(stat, id)
	local value = stat[id]
	if value ~= nil then
		return value
	end
	return nil
end

---@param v LeaderLibCustomAttributeTooltipSettings
---@param modifier StatsModifierList
---@param statsManager StatsRPGStats
---@param value any
---@param character EclCharacter
---@return TooltipElement|nil
local function _GetElementForValue(v, modifier, statsManager, value, character)
	---@type ModifierValueType
	local valueType = statsManager.ModifierValueLists:GetByName(v.Attribute)

	local element = {Type="StatsBaseValue"}
	if _type(v.TooltipElementType) == "string" then
		element.Type = v.TooltipElementType
	else
		if valueType == "FixedString" then
			element.Type = "StatsBaseValue"
		elseif _type(value) == "number" then
			element.Type = "StatBoost"
		end
	end
	local spec = Game.Tooltip.TooltipSpecs[element.Type]
	for _,prop in pairs(spec) do
		local propName,propType = table.unpack(prop)
		if propName == "Value" then
			element.Value = tostring(value)
		elseif propName == "NumValue" then
			element.NumValue = value
		elseif propName == "Label" then
			if v.DisplayName then
				element.Label = GameHelpers.Tooltip.ReplacePlaceholders(v.DisplayName, character)
			else
				fprint(LOGLEVEL.WARNING, "[GameHelpers.Tooltip.GetCustomAttributeElements] No DisplayName for attribute (%s). Using the attribute ID.", v.Attribute)
				element.Label = v.Attribute
			end
		else
			if propType == "string" then
				element[propName] = ""
			elseif propType == "number" then
				element[propName] = 0
			elseif propType == "boolean" then
				element[propName] = false
			end
		end
	end
	return element
end


---@param self LeaderLibCustomAttributeTooltipCallbackEventArgs
---@param value string|number
---@param overwriteValue? boolean
local function _UpdateElement(self, value, overwriteValue)
	local options = self.Options
	if options.Element then
		if not overwriteValue and _type(options.ElementValue) == "string" then
			options.Element[options.ElementProperty] = StringHelpers.Append(options.ElementValue, value)
		else
			options.Element[options.ElementProperty] = value
		end
	end
end

---@param stat StatEntryType
---@param attributeType ModifierListType
---@param statsManager StatsRPGStats
---@param character EclCharacter
---@param tooltip TooltipData
---@param tooltipType TooltipRequestType
---@param options GameHelpersTooltipGetCustomAttributeElementsOptions
local function _AddElementForStat(stat, attributeType, statsManager, character, tooltip, tooltipType, options)
	if stat and attributeType then
		local entries = TooltipHandler.CustomAttributes[attributeType]
		local modifier = statsManager.ModifierLists:GetByName(attributeType)
		if entries then
			for _,v in pairs(entries) do
				local b,value = xpcall(_TryGetCustomAttributeFromStat, debug.traceback, stat, v.Attribute)
				if not b then
					fprint(LOGLEVEL.ERROR, "[LeaderLib] Failed to get custom attribute (%s) on stat (%s):\n%s", v.Attribute, stat.Name, value)
				elseif value ~= nil then
					if v.GetTooltipElement then
						local valueType = statsManager.ModifierValueLists:GetByName(v.Attribute)

						---@type LeaderLibCustomAttributeTooltipCallbackEventArgs
						local data = {
							Character = character,
							Tooltip = tooltip,
							TooltipType = tooltipType,
							Skill = options.Skill,
							Status = options.Status,
							Value = value,
							Attribute = v.Attribute,
							Modifier = modifier,
							ModifierValueType = valueType,
							Options = options,
							UpdateElement = _UpdateElement,
						}
						local b2,err = xpcall(v.GetTooltipElement, debug.traceback, data)
						if not b2 then
							fprint(LOGLEVEL.ERROR, "[LeaderLib] Failed to get tooltip element for custom attribute (%s) and stat (%s):\n%s", v.Attribute, stat.Name, err)
						end
					else
						local element = _GetElementForValue(v, modifier, statsManager, value, character)
						if element then
							if tooltipType == "Rune" then
								options.Element[options.ElementProperty] = StringHelpers.Append(options.ElementValue, element.Label)
							else
								tooltip:AppendElementAfterType(element, element.Type)
							end
						end
					end
				end
			end
		end
	end
end

local _RuneAccessorySlot = {
	Amulet = true,
	Ring = true,
	Ring2 = true,
	Belt = true,
}

---@param item EclItem
---@param statsManager StatsRPGStats
---@param character EclCharacter
---@param tooltip TooltipData
---@param tooltipType TooltipRequestType
---@param options GameHelpersTooltipGetCustomAttributeElementsOptions
local function _AddRuneCustomAttributes(item, statsManager, character, tooltip, tooltipType, options)
	if not item.StatsFromName then
		return
	end
	local runeEffect = tooltip:GetElement("RuneEffect")
	local runeSlots = tooltip:GetElements("RuneSlot")
	if runeEffect and item.StatsFromName.ModifierListIndex == 4 then
		local runeStat = item.StatsFromName.StatsEntry --[[@as StatEntryObject]]
		if runeStat then
			local weaponBoost = Ext.Stats.Get(runeStat.RuneEffectWeapon, nil, false)
			local armorBoost = Ext.Stats.Get(runeStat.RuneEffectUpperbody, nil, false)
			local accessoryBoost = Ext.Stats.Get(runeStat.RuneEffectAmulet, nil, false)
			options.Element = runeEffect
			options.ElementProperty = "Rune1"
			options.ElementValue = runeEffect.Rune1
			_AddElementForStat(weaponBoost, "Weapon", statsManager, character, tooltip, "Rune", options)
			options.ElementProperty = "Rune2"
			options.ElementValue = runeEffect.Rune2
			_AddElementForStat(armorBoost, "Armor", statsManager, character, tooltip, "Rune", options)
			options.ElementProperty = "Rune3"
			options.ElementValue = runeEffect.Rune3
			_AddElementForStat(accessoryBoost, "Armor", statsManager, character, tooltip, "Rune", options)
		end
	elseif item.StatsFromName.ModifierListIndex < 3 then
		local len = #item.Stats.DynamicStats
		if len >= 3 then
			local itemType = item.Stats.ItemType
			local slotType = item.Stats.StatsEntry.Slot --[[@as ItemSlot]]
			local currentRuneSlot = 1
			options.ElementProperty="Value"
			for i=3,len do
				local boost = item.Stats.DynamicStats[i]
				if not StringHelpers.IsNullOrEmpty(boost.BoostName) and GameHelpers.Stats.IsStatType(boost.BoostName, "Object") then
					local runeStat = Ext.Stats.Get(boost.BoostName, nil, false) --[[@as StatEntryObject]]
					local runeElement = runeSlots[currentRuneSlot]
					if runeStat and runeElement then
						options.Element = runeElement
						options.ElementValue = runeElement.Value
						if itemType == "Weapon" then
							local boost = Ext.Stats.Get(runeStat.RuneEffectWeapon, nil, false)
							if boost then
								_AddElementForStat(boost, "Weapon", statsManager, character, tooltip, "Rune", options)
								currentRuneSlot = currentRuneSlot + 1
							end
						elseif itemType == "Armor" then
							if _RuneAccessorySlot[slotType] then
								local boost = Ext.Stats.Get(runeStat.RuneEffectAmulet, nil, false)
								if boost then
									_AddElementForStat(boost, "Armor", statsManager, character, tooltip, "Rune", options)
									currentRuneSlot = currentRuneSlot + 1
								end
							else
								local boost = Ext.Stats.Get(runeStat.RuneEffectUpperbody, nil, false)
								if boost then
									_AddElementForStat(boost, "Armor", statsManager, character, tooltip, "Rune", options)
									currentRuneSlot = currentRuneSlot + 1
								end
							end
						end
					end
				end
			end
		end
	end
end

---@class GameHelpersTooltipGetCustomAttributeElementsOptions
---@field Item EclItem|nil
---@field Skill FixedString|nil
---@field Status EclStatus|nil
---@field Rune StatEntryObject|nil
---@field Element TooltipElement|nil For rune tooltips, or items with runes that have custom boosts, this will be the element to edit.
---@field ElementProperty string|nil The element property to edit in the Element.
---@field ElementValue string|number|nil The element property value, if Element is set.<br>Set `Element[ElementProperty]` directly, as this value isn't checked after the callback.

---Adds registered custom attributes to the given tooltip.  
---🔧**Client-Only**🔧  
---@param character EclCharacter
---@param tooltip TooltipData
---@param tooltipType TooltipRequestType
---@param options GameHelpersTooltipGetCustomAttributeElementsOptions
function GameHelpers.Tooltip.SetCustomAttributeElements(character, tooltip, tooltipType, options)
	local statsManager = Ext.Stats.GetStatsManager()
	if tooltipType == "Item" then
		assert(options.Item ~= nil, "options.Item must be set for Item tooltips")
		local item = options.Item --[[@as EclItem]]
		local b,err = xpcall(_AddRuneCustomAttributes, debug.traceback, item, statsManager, character, tooltip, tooltipType, options)
		if not b then
			Ext.Utils.PrintError(err)
		end
		if item.StatsFromName then
			local modifier = statsManager.ModifierLists.Elements[item.StatsFromName.ModifierListIndex+1]
			local entries = TooltipHandler.CustomAttributes[modifier.Name]
			if entries then
				for _,v in pairs(entries) do
					local b,value = xpcall(_TryGetCustomAttributeFromItem, debug.traceback, item, v.Attribute)
					if not b then
						fprint(LOGLEVEL.ERROR, "[LeaderLib] Failed to get custom attribute (%s) on item (%s):\n%s", v.Attribute, GameHelpers.Item.GetItemStat(item), value)
					elseif value ~= nil then
						if v.GetTooltipElement then
							local valueType = statsManager.ModifierValueLists:GetByName(v.Attribute)

							---@type LeaderLibCustomAttributeTooltipCallbackEventArgs
							local data = {
								Character = character,
								Tooltip = tooltip,
								TooltipType = tooltipType,
								Item = item,
								Value = value,
								Attribute = v.Attribute,
								Modifier = modifier,
								ModifierValueType = valueType,
								UpdateElement = _UpdateElement,
							}
							local b2,err = xpcall(v.GetTooltipElement, debug.traceback, data)
							if not b2 then
								fprint(LOGLEVEL.ERROR, "[LeaderLib] Failed to get tooltip element for custom attribute (%s) on item (%s):\n%s", v.Attribute, GameHelpers.Item.GetItemStat(item), err)
							end
						else
							local element = _GetElementForValue(v, modifier, statsManager, value, character)
							if element then
								tooltip:AppendElementAfterType(element, element.Type)
							end
						end
					end
				end
			end
		end
	elseif tooltipType == "Rune" then
		assert(options.Rune ~= nil, "options.Rune must be set for Rune tooltips")
		local runeStat = options.Rune
		local runeEffect = tooltip:GetElement("RuneEffect", {
			Unknown1 = 1,
			Rune1 = "",
			Rune3 = "",
			Rune2 = "",
			Type = "RuneEffect",
			Label2 = "Inactive",
			Label = "Active"
		})
		local weaponBoost = Ext.Stats.Get(runeStat.RuneEffectWeapon, nil, false)
		local armorBoost = Ext.Stats.Get(runeStat.RuneEffectUpperbody, nil, false)
		local accessoryBoost = Ext.Stats.Get(runeStat.RuneEffectAmulet, nil, false)
		options.Element = runeEffect
		options.ElementProperty = "Rune1"
		options.ElementValue = runeEffect.Rune1
		_AddElementForStat(weaponBoost, "Weapon", statsManager, character, tooltip, "Rune", options)
		options.ElementProperty = "Rune2"
		options.ElementValue = runeEffect.Rune2
		_AddElementForStat(armorBoost, "Armor", statsManager, character, tooltip, "Rune", options)
		options.ElementProperty = "Rune3"
		options.ElementValue = runeEffect.Rune3
		_AddElementForStat(accessoryBoost, "Armor", statsManager, character, tooltip, "Rune", options)
	else
		if tooltipType == "Skill" then
			assert(options.Skill ~= nil, "options.Skill must be set for Skill tooltips")
			local stat = Ext.Stats.Get(options.Skill, nil, false)
			_AddElementForStat(stat, "SkillData", statsManager, character, tooltip, tooltipType, options)
		elseif tooltipType == "Status" then
			local status = options.Status
			assert(status ~= nil, "options.Status must be set for Status tooltips")
			if not Data.EngineStatus[options.Status.StatusId] then
				local stat = Ext.Stats.Get(options.Status.StatusId, nil, false)
				_AddElementForStat(stat, "StatusData", statsManager, character, tooltip, tooltipType, options)
			end
			if not GameHelpers.Ext.TypeHasMember(status, "StatsDataPerTurn") then
				return
			end
			---@cast status EclStatusConsumeBase
			if status.StatsDataPerTurn then
				for _,v in pairs(status.StatsDataPerTurn) do
					local stat = Ext.Stats.Get(v.StatsId, nil, false) --[[@as StatEntryPotion]]
					if stat then
						_AddElementForStat(stat, "Potion", statsManager, character, tooltip, tooltipType, options)
					end
				end
			elseif status.StatsId then
				if string.find(status.StatsId, "[;,]") then
					for _,group in pairs(StringHelpers.Split(status.StatsId, ";")) do
						local groupEntry = StringHelpers.Split(group, ",")
						local statId = groupEntry[1]
						if statId then
							local stat = Ext.Stats.Get(statId, nil, false) --[[@as StatEntryPotion]]
							if stat then
								_AddElementForStat(stat, "Potion", statsManager, character, tooltip, tooltipType, options)
							end
						end
					end
				else
					local stat = Ext.Stats.Get(status.StatsId, nil, false) --[[@as StatEntryPotion]]
					if stat then
						_AddElementForStat(stat, "Potion", statsManager, character, tooltip, tooltipType, options)
					end
				end
			end
		end
	end
end

---@param self {Result:string}
---@param value string|number
---@param overwriteValue? boolean
local function _UpdateCraftingUI(self, value, overwriteValue)
	if not overwriteValue and _type(self.Result) == "string" then
		self.Result = StringHelpers.Append(self.Result, value)
	else
		self.Result = value
	end
end

--Rune UI support

local _lastRuneDoubleHandle = nil
local _lastRuneSlot = -1

Ext.RegisterUITypeInvokeListener(Data.UIType.uiCraft, "setCraftResultHandle", function (ui, event, doubleHandle, runeSlot)
	_lastRuneDoubleHandle = doubleHandle
	_lastRuneSlot = runeSlot
end, "Before")

Ext.RegisterUITypeInvokeListener(Data.UIType.uiCraft, "updateRuneSlots", function (ui, event, ...)
	local this = ui:GetRoot()
	local arr = this.runeslotUpdateList
	local runesPanel_mc = this.craftPanel_mc.runesPanel_mc
	local doubleHandle = runesPanel_mc.targetHit_mc.itemHandle
	if doubleHandle == nil or doubleHandle == 0 then
		doubleHandle = _lastRuneDoubleHandle
	end
	if doubleHandle == nil or doubleHandle == 0 and runesPanel_mc.inventory_mc.selectecItemMC then
		doubleHandle = runesPanel_mc.inventory_mc.selectecItemMC.itemHandle
	end
	local runeSlot = math.max(1, runesPanel_mc.targetHit_mc.contextParam or _lastRuneSlot)
	local item = GameHelpers.Client.TryGetItemFromDouble(doubleHandle)
	if not item then
		fprint(LOGLEVEL.WARNING, "[LeaderLib:CustomAttributes:uiCraft] Failed to get item from runesPanel_mc.targetHit_mc.itemHandle(%s)", doubleHandle)
		return
	end
	local character = Client:GetCharacter()
	local boostEntry = item.Stats.DynamicStats[2+runeSlot]
	---@type StatEntryObject
	local runeStat = nil
	if boostEntry and not StringHelpers.IsNullOrEmpty(boostEntry.BoostName) then
		runeStat = Ext.Stats.Get(boostEntry.BoostName, nil, false) --[[@as StatEntryObject]]
	end
	if not runeStat then
		fprint(LOGLEVEL.WARNING, "[LeaderLib:CustomAttributes:uiCraft] Failed to get rune stat for item (%s) in slot (%s)", GameHelpers.GetDisplayName(item), runeSlot)
		return
	end

	local itemType = item.Stats.ItemType
	local slotType = item.Stats.StatsEntry.Slot

	local boostStat = nil
	if itemType == "Weapon" then
		boostStat = Ext.Stats.Get(runeStat.RuneEffectWeapon, nil, false)
	elseif itemType == "Armor" then
		if _RuneAccessorySlot[slotType] then
			boostStat = Ext.Stats.Get(runeStat.RuneEffectAmulet, nil, false)
		else
			boostStat = Ext.Stats.Get(runeStat.RuneEffectUpperbody, nil, false)
		end
	end
	if not boostStat then
		fprint(LOGLEVEL.WARNING, "[LeaderLib:CustomAttributes:uiCraft] Failed to get rune boost stat for item type (%s:%s) and rune (%s)", itemType, slotType, runeStat.Name)
		return
	end

	local statsManager = Ext.Stats.GetStatsManager()
	local modifier = statsManager.ModifierLists.Elements[item.StatsFromName.ModifierListIndex+1]
	local entries = TooltipHandler.CustomAttributes[modifier.Name]
	if entries then
		for i=0,6,#arr do
			local slot = arr[i]
			local runeName = arr[i+1]
			if not StringHelpers.IsNullOrEmpty(runeName) then
				local boostText = arr[i+2]
				local iconName = arr[i+3]
				local state = arr[i+4]
				local tooltip = arr[i+5]
				for _,v in pairs(entries) do
					local b,value = xpcall(_TryGetCustomAttributeFromStat, debug.traceback, boostStat, v.Attribute)
					if not b then
						fprint(LOGLEVEL.ERROR, "[LeaderLib] Failed to get custom attribute (%s) on stat (%s):\n%s", v.Attribute, boostStat.Name, value)
					elseif value ~= nil then
						if v.GetTooltipElement then
							local valueType = statsManager.ModifierValueLists:GetByName(v.Attribute)

							---@type LeaderLibCustomAttributeTooltipCallbackEventArgs
							local data = {
								Character = character,
								TooltipType = "Rune",
								IsUIText = true,
								Value = value,
								Attribute = v.Attribute,
								Modifier = modifier,
								ModifierValueType = valueType,
								Options = {Item=item, Rune=runeStat},
								Result=boostText,
								UpdateElement = _UpdateCraftingUI,
							}
							local b2,err = xpcall(v.GetTooltipElement, debug.traceback, data)
							if not b2 then
								fprint(LOGLEVEL.ERROR, "[LeaderLib] Failed to get display text for custom attribute (%s) and stat (%s):\n%s", v.Attribute, boostStat.Name, err)
							else
								arr[i+2] = data.Result
							end
						else
							local valueText = ""
							if v.DisplayName then
								valueText = string.format("%s: %s", GameHelpers.Tooltip.ReplacePlaceholders(v.DisplayName, character), value)
							else
								fprint(LOGLEVEL.WARNING, "[GameHelpers.Tooltip.GetCustomAttributeElements] No DisplayName for attribute (%s). Using the attribute ID.", v.Attribute)
								valueText = string.format("%s: %s", v.Attribute, value)
							end
							arr[i+2] = StringHelpers.Append(boostText, valueText, "<br>")
						end
					end
				end
			end
		end
	end
end, "Before")