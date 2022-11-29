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
				local damageType = Ext.EnumIndexToLabel("DamageType", v.DamageType)
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
			-- Resistance Penetration display
			--if GameHelpers.ItemHasTag(item, "LeaderLib_HasResistancePenetration") then
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
					--Replaces double spacing or more with single spaces
					element.Label = string.gsub(element.Label, "%s+", " ")
					if not hasScalesWithText and string.find(element.Label, scalesWithTextSub) then
						hasScalesWithText = true
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