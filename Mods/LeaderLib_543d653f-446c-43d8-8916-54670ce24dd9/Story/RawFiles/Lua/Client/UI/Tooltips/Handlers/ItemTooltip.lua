local appendRequirementsAfterTypes = {ItemRequirement=true, ItemLevel=true, APCostBoost=true}

local _EXTVERSION = Ext.Version()

local function _AlphabeticalCaseInsensitiveLabelSort(a,b)
	return string.lower(a.Label) < string.lower(b.Label)
end

---@param item EclItem
---@param tooltip TooltipData
function TooltipHandler.OnItemTooltip(item, tooltip)
	if tooltip == nil then
		return
	end
	if item ~= nil then
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
								local potion = Ext.StatGetAttribute(status, "StatsId")
								if potion ~= nil and potion ~= "" then
									local apCostBoost = Ext.StatGetAttribute(potion, "APCostBoost")
									if apCostBoost ~= nil and apCostBoost ~= 0 then
										ap = math.max(0, ap + apCostBoost)
									end
								end
							end
						end
						apElement.Value = ap
					end
				end
			end

			local rootTemplate = GameHelpers.GetTemplate(item)
			if rootTemplate then
				if tooltip:GetElement("SkillDescription") ~= nil then
					if _EXTVERSION >= 56 then
						---Invokes skill tooltip listeners if the item has skill elements
						for skill,b in pairs(GameHelpers.Item.GetUseActionSkills(item, true)) do
							tooltip.IsFromItem = true
							tooltip.ItemHasSkill = true
							--TooltipHandler.OnSkillTooltip(character, skill, tooltip)
							Game.Tooltip.TooltipHooks:NotifyAll(Game.Tooltip.TooltipHooks.TypeListeners.Skill, character, skill, tooltip)
							if Game.Tooltip.TooltipHooks.ObjectListeners.Skill ~= nil then
								Game.Tooltip.TooltipHooks:NotifyAll(Game.Tooltip.TooltipHooks.ObjectListeners.Skill[skill], character, skill, tooltip)
							end
						end
					else
						local savedSkills = TooltipHandler.SkillBookAssociatedSkills[rootTemplate]
						if savedSkills == nil then
							local skillBookSkillDisplayName = GameHelpers.Tooltip.GetElementAttribute(tooltip:GetElement("SkillbookSkill"), "Value")
							local tooltipIcon = GameHelpers.Tooltip.GetElementAttribute(tooltip:GetElement("SkillIcon"), "Label")
							local tooltipSkillDescription = GameHelpers.Tooltip.GetElementAttribute(tooltip:GetElement("SkillDescription"), "Label")
							for skill in GameHelpers.Stats.GetSkills(true) do
								local icon = skill.Icon
								if tooltipIcon == icon then
									local displayName = GameHelpers.GetStringKeyText(skill.DisplayName)
									local description = GameHelpers.GetStringKeyText(skill.Description)
			
									if displayName == skillBookSkillDisplayName and description == tooltipSkillDescription then
										if TooltipHandler.SkillBookAssociatedSkills[rootTemplate] == nil then
											TooltipHandler.SkillBookAssociatedSkills[rootTemplate] = {}
											savedSkills = TooltipHandler.SkillBookAssociatedSkills[rootTemplate]
										end
										TooltipHandler.SkillBookAssociatedSkills[rootTemplate][skill.Name] = true
									end
								end
							end
						end
						if savedSkills ~= nil then
							for skill,b in pairs(savedSkills) do
								if b then
									TooltipHandler.OnSkillTooltip(character, skill, tooltip)
								end
							end
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
		if (Features.TooltipGrammarHelper or GameSettings.Settings.Client.AlwaysDisplayWeaponScalingText)
		and not GameHelpers.Item.IsObject(item)
		and item.Stats.Requirements ~= nil
		and #item.Stats.Requirements > 0
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
				if Data.AttributeEnum[v.Requirement] ~= nil then
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
				if item.ItemType == "Weapon" and (not requiresPointsHigherThanZero or GameSettings.Settings.Client.AlwaysDisplayWeaponScalingText) then
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
		if item:HasTag("LeaderLib_AutoLevel") then
			local element = tooltip:GetElement("ItemDescription", {Type="ItemDescription", Label=""})
			if not string.find(string.lower(element.Label), "automatically level") then
				if not StringHelpers.IsNullOrEmpty(element.Label) then
					element.Label = element.Label .. "<br>" .. LocalizedText.Tooltip.AutoLevel.Value
				else
					element.Label = LocalizedText.Tooltip.AutoLevel.Value
				end
			end
		end
		local settings = GameSettingsManager.GetSettings()
		if settings.Client.CondenseItemTooltips then
			local elements = tooltip:GetElements("ExtraProperties")
			if #elements > 1 then
				Ext.Dump(elements)
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
	end
end