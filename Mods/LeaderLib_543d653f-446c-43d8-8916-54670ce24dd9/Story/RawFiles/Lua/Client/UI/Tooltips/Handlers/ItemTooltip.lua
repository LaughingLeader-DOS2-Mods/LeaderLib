local appendRequirementsAfterTypes = {ItemRequirement=true, ItemLevel=true, APCostBoost=true}

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

			if item.RootTemplate ~= nil and not StringHelpers.IsNullOrEmpty(item.RootTemplate.Id) then
				local skillBookSkillDisplayName = GameHelpers.Tooltip.GetElementAttribute(tooltip:GetElement("SkillbookSkill"), "Value")
				if not StringHelpers.IsNullOrEmpty(skillBookSkillDisplayName) then
					local savedSkills = TooltipHandler.SkillBookAssociatedSkills[item.RootTemplate.Id]
					if savedSkills == nil then
						local tooltipIcon = GameHelpers.Tooltip.GetElementAttribute(tooltip:GetElement("SkillIcon"), "Label")
						local tooltipSkillDescription = GameHelpers.Tooltip.GetElementAttribute(tooltip:GetElement("SkillDescription"), "Label")
						for i,skillId in pairs(Ext.GetStatEntries("SkillData")) do
							local skill = Ext.GetStat(skillId)
							local icon = skill.Icon
							if tooltipIcon == icon then
								local displayName = GameHelpers.GetStringKeyText(skill.DisplayName)
								local description = GameHelpers.GetStringKeyText(skill.Description)
		
								if displayName == skillBookSkillDisplayName and description == tooltipSkillDescription then
									if TooltipHandler.SkillBookAssociatedSkills[item.RootTemplate.Id] == nil then
										TooltipHandler.SkillBookAssociatedSkills[item.RootTemplate.Id] = {}
										savedSkills = TooltipHandler.SkillBookAssociatedSkills[item.RootTemplate.Id]
									end
									TooltipHandler.SkillBookAssociatedSkills[item.RootTemplate.Id][skill.Name] = true
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

		if Features.FixPureDamageDisplay then
			if not GameHelpers.Item.IsObject(item) and item.Stats.ItemType == "Weapon" then
				local hasPureDamage = false
				if item.Stats["Damage Type"] == "None" then
					hasPureDamage = true
				end
				if not hasPureDamage then
					for i,v in pairs(item.Stats.DynamicStats) do
						if v.DamageType == "None" then
							hasPureDamage = true
							break
						end
					end
				end
				if hasPureDamage then
					for i,v in pairs(tooltip:GetElements("WeaponDamage")) do
						if v.Label == "" then
							local entry = LocalizedText.DamageTypeNames.None
							--v.Label = string.format("<font color='%s'>%s</font>", entry.Color, entry.Text.Value)
							v.Label = entry.Text.Value
						end
					end
				end
			end
		end

		if Features.ResistancePenetration == true then
			-- Resistance Penetration display
			if item:HasTag("LeaderLib_HasResistancePenetration") then
				local tagsCheck = {}
				for _,damageType in Data.DamageTypes:Get() do
					local tags = Data.ResistancePenetrationTags[damageType]
					if tags ~= nil then
						local totalResPen = 0
						for i,tagEntry in pairs(tags) do
							if item:HasTag(tagEntry.Tag) then
								totalResPen = totalResPen + tagEntry.Amount
								tagsCheck[#tagsCheck+1] = tagEntry.Tag
							end
						end

						if totalResPen > 0 then
							local tString = LocalizedText.ItemBoosts.ResistancePenetration
							local resistanceText = GameHelpers.GetResistanceNameFromDamageType(damageType)
							local result = tString:ReplacePlaceholders(GameHelpers.GetResistanceNameFromDamageType(damageType))
							local element = {
								Type = "ResistanceBoost",
								Label = result,
								Value = totalResPen,
							}
							tooltip:AppendElement(element)
						end
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
			for i,v in pairs(item.Stats.Requirements) do
				if Data.AttributeEnum[v.Requirement] ~= nil then
					attributeName = LocalizedText.AttributeNames[v.Requirement].Value
					if type(v.Param) == "number" and v.Param > 0 then
						attributeValue = v.Param
						requiresPointsHigherThanZero = true
						if character.Stats[v.Requirement] < v.Param then
							requirementsMet = false
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
		if Features.ReduceTooltipSize then
			local elements = tooltip:GetElements("ExtraProperties")
			if elements ~= nil and #elements > 0 then
				for i,v in pairs(elements) do
					if StringHelpers.IsNullOrEmpty(StringHelpers.Trim(v.Label)) then
						elements[i] = nil
						tooltip:RemoveElement(v)
					end
				end
				local result = GameHelpers.Tooltip.CondensePropertiesText(tooltip, elements)
				if result ~= nil then
					local combined = {
						Type = "ExtraProperties",
						Label = result
					}
					tooltip:AppendElement(combined)
				end
			end
		end
	end
end