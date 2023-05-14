local appendRequirementsAfterTypes = {ItemRequirement=true, ItemLevel=true, APCostBoost=true}

local _EXTVERSION = Ext.Utils.Version()

local function _AlphabeticalCaseInsensitiveLabelSort(a,b)
	return string.lower(a.Label) < string.lower(b.Label)
end

local function _GetStatusAPCostBoost(id)
	local status = Ext.Stats.Get(id, nil, false)
	if status and not StringHelpers.IsNullOrWhitespace(status.StatsId) then
		local potion = Ext.Stats.Get(status.StatsId, nil, false)
		if potion then
			return potion.APCostBoost
		end
	end
	return nil
end

local function _AddResistancePen_Old(item, tooltip)
	-- Resistance Penetration display
	local resistancePenetration = {}
	local tags = GameHelpers.GetAllTags(item, true)
	for tag,b in pairs(tags) do
		local damageType,amount = GameHelpers.ParseResistancePenetrationTag(tag)
		if damageType then
			if resistancePenetration[damageType] == nil then
				resistancePenetration[damageType] = 0
			end
			resistancePenetration[damageType] = resistancePenetration[damageType] + amount
		end
	end
	local resPenText = LocalizedText.ItemBoosts.ResistancePenetration
	for i=1,#LocalizedText.DamageTypeNameAlphabeticalOrder do
		local damageType = LocalizedText.DamageTypeNameAlphabeticalOrder[i]
		local amount = resistancePenetration[damageType] or 0
		if amount > 0 then
			local resistanceText = GameHelpers.GetResistanceNameFromDamageType(damageType)
			if not StringHelpers.IsNullOrWhitespace(resistanceText) then
				local result = resPenText:ReplacePlaceholders(resistanceText)
				local element = {
					Type = "ResistanceBoost",
					Label = result,
					Value = amount,
				}
				tooltip:AppendElement(element)
			end
		end
	end
end

local function _DisplayAllProgressionBonuses(item, tooltip)
	local progressionEntries,totalEntries = ProgressionManager.GetDataForObject(item)
	if totalEntries > 0 then
		local level = item.Stats.Level
		local statsType = item.Stats.DynamicStats[1].StatsType
		local maxLevel = 0
		for i=1,totalEntries do
			local entry = progressionEntries[i]
			local boostTexts = {}
			for _,group in pairs(entry.Boosts) do
				if maxLevel < group.Level then
					maxLevel = group.Level
				end
				if boostTexts[group.Level] == nil then
					boostTexts[group.Level] = {}
				end
				local textGroup = boostTexts[group.Level]
				for _,boost in pairs(group.Entries) do
					if boost.Type == "Attribute" then
						---@cast boost -LeaderLibProgressionDataBoostStatEntry
						if boost.Attribute ~= "RuneSlots_V1" then
							textGroup[#textGroup+1] = string.format("+%s %s", boost.Value, boost.Attribute)
						end
					elseif boost.Type == "Stat" then
						---@cast boost -LeaderLibProgressionDataBoostAttributeEntry
						local stat = Ext.Stats.Get(boost.ID, level, false, true) --[[@as StatEntryWeapon|StatEntryShield|StatEntryArmor]]
						if stat ~= nil then
							local bonuses = entry:GetSetValues(statsType, stat)
							for attribute,value in pairs(bonuses) do
								if attribute ~= "RuneSlots_V1" then
									textGroup[#textGroup+1] = string.format("+%s %s", value, attribute)
								end
							end
						end
					end
				end
			end
			local finalText = ""
			local fontText = "Progression Bonuses:<br><font size='16'>%s</font>"
			for i=1,maxLevel do
				local entries = boostTexts[i]
				if entries then
					table.sort(entries)
					local entriesText = "<br>" .. StringHelpers.Join("<br>", entries)
					local groupText = LocalizedText.Tooltip.AbilityCurrentLevel:ReplacePlaceholders(i, entriesText)
					finalText = StringHelpers.Append(finalText, groupText, "<br>")
				end
			end
			tooltip:AppendElement({
				Type = "StatsPointValue",
				Label = fontText:format(finalText)
			})
		end
	end
end

---@param attribute string
---@param value string|number
---@param statsType? ModifierListType
---@return string
local function _FormatAttributeValue(attribute, value, statsType)
	if attribute == "Skills" then
		local skillNames = {}
		local len = 0
		for _,v in pairs(StringHelpers.Split(value, ";")) do
			local name = GameHelpers.Stats.GetDisplayName(v, "SkillData")
			if not StringHelpers.IsNullOrWhitespace(name) then
				len = len + 1
				skillNames[len] = name
			end
		end
		if len > 0 then
			table.sort(skillNames)
			return LocalizedText.ItemTooltip.GrantsSkillFromBoost:ReplacePlaceholders(StringHelpers.Join(", ", skillNames, true))
		end
	elseif attribute == "Tags" then
		local tagNames = {}
		local len = 0
		for _,v in pairs(StringHelpers.Split(value, ";")) do
			local name = GameHelpers.GetStringKeyText(v, "")
			if not StringHelpers.IsNullOrWhitespace(name) then
				len = len + 1
				tagNames[len] = name
			end
		end
		if len > 0 then
			table.sort(tagNames)
			return string.format("%s %s", LocalizedText.ItemTooltip.Tags.Value, StringHelpers.Join(", ", tagNames, true))
		end
	elseif attribute == "VitalityBoost" then
		return string.format("+%s %s", value, LocalizedText.ItemTooltip.VitalityBoost.Value)
	else
		local name = GameHelpers.Stats.GetAttributeName(attribute, statsType)
		if name then
			return string.format("+%s %s", value, name)
		end
	end
	return nil
end

---@param item EclItem
---@param tooltip TooltipData
function TooltipHandler.OnItemTooltip(item, tooltip)
	if tooltip == nil then
		return
	end
	if item ~= nil then
		local gameSettings = GameSettingsManager.GetSettings().Client
		local isRead = false
		TooltipHandler.LastItem = item
		local character = Client:GetCharacter()
		if character ~= nil then
			if Features.FixItemAPCost == true then
				local apElement = tooltip:GetElement("ItemUseAPCost")
				if apElement ~= nil then
					local ap = apElement.Value
					if ap > 0 then
						for i,status in pairs(character:GetStatuses()) do
							if not Data.EngineStatus[status] then
								local apCostBoost = _GetStatusAPCostBoost(status)
								if apCostBoost ~= nil and apCostBoost ~= 0 then
									ap = math.max(0, ap + apCostBoost)
								end
							end
						end
						apElement.Value = ap
					end
				end
			end

			local rootTemplate = GameHelpers.GetTemplate(item)
			if rootTemplate then
				isRead = UI.InventoryTweaks.ReadBooks[rootTemplate] ~= nil

				if tooltip:GetElement("SkillDescription") ~= nil then
					---Invokes skill tooltip listeners if the item has skill elements
					local skills,itemParams = GameHelpers.Item.GetUseActionSkills(item, true)
					for skill,b in pairs(skills) do
						tooltip.IsFromItem = true
						tooltip.ItemHasSkill = true
						--TooltipHandler.OnSkillTooltip(character, skill, tooltip)
						Game.Tooltip.TooltipHooks:NotifyAll(Game.Tooltip.TooltipHooks.TypeListeners.Skill, character, skill, tooltip)
						if Game.Tooltip.TooltipHooks.ObjectListeners.Skill ~= nil then
							Game.Tooltip.TooltipHooks:NotifyAll(Game.Tooltip.TooltipHooks.ObjectListeners.Skill[skill], character, skill, tooltip)
						end
					end
				end
			end
		end

		local fixPure = Features.FixPureDamageDisplay
		local fixSulfur = Features.FixSulfuricDamageDisplay
		local fixSentinel = Features.FixSentinelDamageDisplay

		if fixPure or fixSulfur or fixSentinel then
			for i,v in pairs(tooltip:GetElements("WeaponDamage")) do
				local damageType = Ext.Stats.EnumIndexToLabel("DamageType", v.DamageType)
				if v.Label == "" then
					if damageType == "None" and fixPure then
						v.Label = LocalizedText.DamageTypeNames.None.Text.Value
					elseif damageType == "Sulfuric" and fixSulfur then
						v.Label = LocalizedText.DamageTypeNames.Sulfuric.Text.Value
					elseif damageType == "Sentinel" and fixSentinel then
						v.Label = LocalizedText.DamageTypeNames.Sentinel.Text.Value
					end
				end
			end
		end

		if Features.ResistancePenetration == true then
			--_AddResistancePen_Old()
		end
		if TooltipHandler.HasTagTooltipData then
			TooltipHandler.AddTooltipTags(item, tooltip)
		end
		if (Features.TooltipGrammarHelper or gameSettings.AlwaysDisplayWeaponScalingText)
		and item.Stats and item.Stats.Requirements ~= nil and #item.Stats.Requirements > 0
		then
			local hasScalesWithText = false
			local requiresPointsHigherThanZero = false
			local scalesWithTextSub = string.sub(LocalizedText.Tooltip.ScalesWith.Value, 1, 5)
			local requirements = tooltip:GetElements("ItemRequirement")
			if #requirements > 0 then
				for i,element in pairs(requirements) do
					if not StringHelpers.IsNullOrEmpty(element.Label) then
						--Replaces double spacing or more with single spaces
						element.Label = string.gsub(element.Label, "%s+", " ")
						if not hasScalesWithText and string.find(element.Label, scalesWithTextSub) then
							hasScalesWithText = true
						end
					end
				end
			end
			local attributeName = ""
			local attributeValue = 0
			local requirementsMet = true
			local hasCharacterStats = character ~= nil and character.Stats ~= nil
			for i,v in pairs(item.Stats.Requirements) do
				if Data.Attribute[v.Requirement] ~= nil then
					attributeName = LocalizedText.AttributeNames[v.Requirement].Value
					if type(v.Param) == "number" and v.Param > 0 then
						attributeValue = v.Param
						requiresPointsHigherThanZero = true
						if hasCharacterStats then
							if character.Stats[v.Requirement] < v.Param then
								requirementsMet = false
							end
						end
					end
				end
			end
			if not StringHelpers.IsNullOrEmpty(attributeName) then
				tooltip:RemoveElements("ItemRequirement")
				--Remove elements mentioning the attribute
				for i,v in pairs(requirements) do
					if string.find(v.Label, attributeName) then
						table.remove(requirements, i)
					end
				end
				if requiresPointsHigherThanZero then
					--Armor doesn't scale with requirements, so just show the attribute requirement.
					local element = {
						Type = "ItemRequirement",
						Label = LocalizedText.Tooltip.RequiresWithParam:ReplacePlaceholders(attributeName, attributeValue),
						RequirementMet = requirementsMet
					}
					tooltip:AppendElementAfterType(element, appendRequirementsAfterTypes)
				end
				--Also show the 'Scales With' text for weapons.
				if item.Stats.ItemType == "Weapon" and (not requiresPointsHigherThanZero or gameSettings.AlwaysDisplayWeaponScalingText) then
					local element = {
						Type = "ItemRequirement",
						Label = LocalizedText.Tooltip.ScalesWith:ReplacePlaceholders(attributeName),
						RequirementMet = true
					}
					tooltip:AppendElementAfterType(element, appendRequirementsAfterTypes)
				end
				--Append other requirements the item may have had
				if #requirements > 0 then
					for i,v in pairs(requirements) do
						tooltip:AppendElementAfterType(v, appendRequirementsAfterTypes)
					end
				end
			end
		end
		local element = tooltip:GetElement("ItemDescription", {Type="ItemDescription", Label=""})
		if item:HasTag("LeaderLib_AutoLevel") then
			if not string.find(string.lower(element.Label), "automatically level") then
				if not StringHelpers.IsNullOrEmpty(element.Label) then
					element.Label = element.Label .. "<br>" .. LocalizedText.Tooltip.AutoLevel.Value
				else
					element.Label = LocalizedText.Tooltip.AutoLevel.Value
				end
			end
		end
		if isRead then
			--tooltip:GetElement("SkillAlreadyLearned", {Type="SkillAlreadyLearned", Label = LocalizedText.Tooltip.BookIsKnown.Value})
			element.Label = element.Label .. "<br>" .. LocalizedText.Tooltip.BookIsKnown.Value
		end
		if gameSettings.CondenseItemTooltips then
			local elements = tooltip:GetElements("ExtraProperties")
			if #elements > 1 then
				for i,v in pairs(elements) do
					if StringHelpers.IsNullOrEmpty(StringHelpers.Trim(v.Label)) then
						table.remove(elements, i)
					end
				end
				table.sort(elements, _AlphabeticalCaseInsensitiveLabelSort)
				local result,removedElements = GameHelpers.Tooltip.CondensePropertiesText(tooltip, elements)
				if result ~= nil then
					tooltip:RemoveElements("ExtraProperties")
					local combined = {
						Type = "ExtraProperties",
						Label = result
					}
					tooltip:AppendElement(combined)
					if removedElements then
						for i,v in ipairs(elements) do
							if not removedElements[i] then
								tooltip:AppendElement(v)
							end
						end
					end
				end
			end
		end

		
		if Features.TooltipProgressionData then
			local progressionEntries,totalEntries = ProgressionManager.GetDataForObject(item)
			if totalEntries > 0 then
				-- tooltip:MarkDirty()
				-- if tooltip:IsExpanded() then
					local level = item.Stats.Level
					local statsType = item.Stats.DynamicStats[1].StatsType
					--local maxLevel = GameHelpers.GetExtraData("LevelCap", 35, true)
					---@type LeaderLibProgressionDataBoostGroup 
					local nextGroup = nil
					---@type LeaderLibProgressionData
					local nextEntry = nil
					for i=1,totalEntries do
						local entry = progressionEntries[i]
						for group in entry:GetOrderedGroups() do
							if group.Level > level then
								nextGroup = group
								nextEntry = entry
								break
							end
						end
					end
					if nextGroup then
						local boostTexts = {}
						local boostTextsLen = 0
						for _,boost in pairs(nextGroup.Entries) do
							if boost.Type == "Attribute" then
								---@cast boost -LeaderLibProgressionDataBoostStatEntry
								if boost.Attribute ~= "RuneSlots_V1" then
									local text = _FormatAttributeValue(boost.Attribute, boost.Value, statsType)
									if text then
										boostTextsLen = boostTextsLen + 1
										boostTexts[boostTextsLen] = text
									end
								end
							elseif boost.Type == "Stat" then
								---@cast boost -LeaderLibProgressionDataBoostAttributeEntry
								local stat = Ext.Stats.Get(boost.ID, level, false, true) --[[@as StatEntryWeapon|StatEntryShield|StatEntryArmor]]
								if stat ~= nil then
									local bonuses = nextEntry:GetSetValues(statsType, stat)
									for attribute,value in pairs(bonuses) do
										if attribute ~= "RuneSlots_V1" then
											local text = _FormatAttributeValue(attribute, value, statsType)
											if text then
												boostTextsLen = boostTextsLen + 1
												boostTexts[boostTextsLen] = text
											end
										end
									end
								end
							end
						end
						if boostTextsLen > 0 then
							table.sort(boostTexts)
							local finalText = StringHelpers.Join("<br>", boostTexts)

							local title = LocalizedText.Tooltip.LeaderLibProgressionBonus
							--local title = boostTextsLen == 1 and LocalizedText.Tooltip.LeaderLibProgressionBonus or LocalizedText.Tooltip.LeaderLibProgressionBonuses

							tooltip:AppendElementAfterType({
								Type = "ExtraProperties",
								Label = title:ReplacePlaceholders(LocalizedText.Tooltip.LevelWithParam:ReplacePlaceholders(nextGroup.Level), finalText),
							}, "ItemRequirement")
						end
					end
				-- end
			end
		end

		if Features.DisplayDebugInfoInTooltips and item.StatsFromName then
			local description = tooltip:GetDescriptionElement({Type="ItemDescription", Label=""})
			local idText = string.format("<font color='%s'>%s</font>", Data.Colors.Common.AztecGold, item.StatsFromName.Name)
			if description.Label ~= "" then
				description.Label = description.Label .. "<br>"
			end
			description.Label = string.format("%s%s", description.Label, idText)
		end
	end
end