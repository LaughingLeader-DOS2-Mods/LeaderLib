---@type table<string,TagTooltipData>
UI.Tooltip.TagTooltips = {}
UI.Tooltip.HasTagTooltipData = false
UI.Tooltip.LastItem = nil

---@class TagTooltipData
---@field Title TranslatedString
---@field Description TranslatedString


local TagTooltips = UI.Tooltip.TagTooltips

---@type TranslatedString
local ts = Classes.TranslatedString

local chaosDamagePattern = "<font color=\"#C80030\">([%d-%s]+)</font>"

---@param character EclCharacter
---@param status EclStatus
---@param tooltip TooltipData
local function OnStatusTooltip(character, status, tooltip)
	if Features.ReplaceTooltipPlaceholders or Features.FixChaosDamageDisplay or Features.TooltipGrammarHelper then
		for i,element in pairs(tooltip:GetElements("StatusDescription")) do
			if element ~= nil then
				if Features.ReplaceTooltipPlaceholders then
					element.Label = GameHelpers.Tooltip.ReplacePlaceholders(element.Label, character)
				end

				if Features.TooltipGrammarHelper then
					element.Label = string.gsub(element.Label, "a 8", "an 8")
					local startPos,endPos = string.find(element.Label , "a <font.->8")
					if startPos then
						local text = string.sub(element.Label, startPos, endPos)
						element.Label = string.gsub(element.Label, text, text:gsub("a ", "an "))
					end
				end

				if Features.FixChaosDamageDisplay and not Data.EngineStatus[status.StatusId] then
					local statusType = Ext.StatGetAttribute(status.StatusId, "StatusType")
					local descParams = Ext.StatGetAttribute(status.StatusId, "DescriptionParams")
					if statusType == "DAMAGE" 
						and not StringHelpers.IsNullOrEmpty(descParams)
						and string.find(descParams, "Damage") 
						and not string.find(element.Label:lower(), LocalizedText.DamageTypeHandles.Chaos.Text.Value)
					then
						local startPos,endPos,damage = string.find(element.Label, chaosDamagePattern)
						if damage ~= nil then
							damage = string.gsub(damage, "%s+", "")
							local removeText = string.sub(element.Label, startPos, endPos):gsub("%-", "%%-")
							element.Label = string.gsub(element.Label, removeText, GameHelpers.GetDamageText("Chaos", damage))
						end
					end
				end
			end
		end
	end
end

local FarOutManFixSkillTypes = {
	Cone = "Range",
	Zone = "Range",
}

---@param character EclCharacter
---@param skill string
---@param tooltip TooltipData
local function OnSkillTooltip(character, skill, tooltip)
	if Vars.DebugMode and skill == "ActionSkillFlee" then
		tooltip:MarkDirty()
		if tooltip:IsExpanded() then
			--tooltip:AppendElement({Type="SkillDescription", Label="<font color='#3399FF'>It's not fleeing, it's a tactical retreat!</font>"})
			local element = tooltip:GetElement("SkillDescription")
			element.Label=element.Label .. "<br><font color='#3399FF'>It's not fleeing, it's a tactical retreat!</font>"
		end
	end

	if Features.TooltipGrammarHelper then
		-- This fixes the double spaces from removing the "tag" part of Requires tag
		for i,element in pairs(tooltip:GetElements("SkillRequiredEquipment")) do
			element.Label = string.gsub(element.Label, "%s+", " ")
		end
	end

	if Features.FixRifleWeaponRequirement and Data.ActionSkills[skill] ~= true then
		local requirement = Ext.StatGetAttribute(skill, "Requirement")
		if requirement == "RifleWeapon" then
			local skillRequirements = tooltip:GetElements("SkillRequiredEquipment")
			local addRifleText = true
			if skillRequirements ~= nil and #skillRequirements > 0 then
				for i,element in pairs(skillRequirements) do
					if string.find(element.Label, LocalizedText.SkillTooltip.RifleWeapon.Value) then
						addRifleText = false
						break
					end
				end
			end
			if addRifleText then
				local hasRequirement = character.Stats.MainWeapon ~= nil and character.Stats.MainWeapon.WeaponType == "Rifle"
				local text = LocalizedText.SkillTooltip.SkillRequiredEquipment:ReplacePlaceholders(LocalizedText.SkillTooltip.RifleWeapon.Value)
				tooltip:AppendElement({
					Type="SkillRequiredEquipment",
					RequirementMet = hasRequirement,
					Label = text
				})
			end
		end
	end

	if Features.ReplaceTooltipPlaceholders
	or (Features.FixChaosDamageDisplay or Features.FixCorrosiveMagicDamageDisplay)
	or Features.TooltipGrammarHelper then
		for i,element in pairs(tooltip:GetElements("SkillDescription")) do
			if element ~= nil then
				if Features.TooltipGrammarHelper == true then
					element.Label = string.gsub(element.Label, "a 8", "an 8")
					local startPos,endPos = string.find(element.Label , "a <font.->8")
					if startPos then
						local text = string.sub(element.Label, startPos, endPos)
						element.Label = string.gsub(element.Label, text, text:gsub("a ", "an "))
					end
				end
				if Features.FixChaosDamageDisplay == true and not string.find(element.Label:lower(), LocalizedText.DamageTypeHandles.Chaos.Text.Value) then
					local startPos,endPos,damage = string.find(element.Label, chaosDamagePattern)
					if damage ~= nil then
						damage = string.gsub(damage, "%s+", "")
						local removeText = string.sub(element.Label, startPos, endPos):gsub("%-", "%%-")
						element.Label = string.gsub(element.Label, removeText, GameHelpers.GetDamageText("Chaos", damage))
					end
				end
				if Features.FixCorrosiveMagicDamageDisplay == true then
					local status,err = xpcall(function()
						local lowerLabel = string.lower(element.Label)
						local damageText = ""
						if string.find(lowerLabel, LocalizedText.DamageTypeHandles.Corrosive.Text.Value) then
							damageText = LocalizedText.DamageTypeHandles.Corrosive.Text.Value
						elseif string.find(lowerLabel, LocalizedText.DamageTypeHandles.Magic.Text.Value) then
							damageText = LocalizedText.DamageTypeHandles.Magic.Text.Value
						end
						if damageText ~= "" then
							local startPos,endPos = string.find(lowerLabel, "destroy <font.->[%d-]+ "..damageText..".-</font> on")
							if startPos and endPos then
								local str = string.sub(element.Label, startPos, endPos)
								local replacement = string.gsub(str, "Destroy","Deal"):gsub("destroy","deal"):gsub(" on"," to")
							element.Label = replacement..string.sub(element.Label, endPos+1)
							end
						end
						return true
					end, debug.traceback)
					if not status then
						Ext.PrintError(err)
					end
				end
				if Features.ReplaceTooltipPlaceholders == true then
					element.Label = GameHelpers.Tooltip.ReplacePlaceholders(element.Label, character)
				end
			end
		end
	end

	if Data.ActionSkills[skill] ~= true
	and Features.FixFarOutManSkillRangeTooltip 
	and (character ~= nil and character.Stats ~= nil and character.Stats.TALENT_FaroutDude == true) then
		local skillType = Ext.StatGetAttribute(skill, "SkillType")
		local rangeAttribute = FarOutManFixSkillTypes[skillType]
		if rangeAttribute ~= nil then
			local element = tooltip:GetElement("SkillRange")
			if element ~= nil then
				local range = Ext.StatGetAttribute(skill, rangeAttribute)
				element.Value = tostring(range).."m"
			end
		end
	end
end

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function SkillGetDescriptionParam(skill, character, isFromItem, param1, param2)
	if Features.ReplaceTooltipPlaceholders then
		if param1 == "ExtraData" then
			local value = Ext.ExtraData[param2]
			if value ~= nil then
				if value == math.floor(value) then
					return string.format("%i", math.floor(value))
				else
					if value <= 1.0 and value >= 0.0 then
						-- Percentage display
						value = value * 100
						return string.format("%i", math.floor(value))
					else
						return tostring(value)
					end
				end
			end
		end
	end
end

Ext.RegisterListener("SkillGetDescriptionParam", SkillGetDescriptionParam)

---@param status EsvStatus
---@param statusSource StatCharacter
---@param target StatCharacter
---@param param1 string
---@param param2 string
---@param param3 string
local function StatusGetDescriptionParam(status, statusSource, target, param1, param2, param3)
	if Features.StatusParamSkillDamage then
		if param1 == "Skill" and param2 ~= nil then
			if param3 == "Damage" then
				local success,result = xpcall(function()
					local skillSource = statusSource or target
					local damageSkillProps = GameHelpers.Ext.CreateSkillTable(param2)
					local damageRange = Game.Math.GetSkillDamageRange(skillSource, damageSkillProps)
					if damageRange ~= nil then
						local damageTexts = {}
						local totalDamageTypes = 0
						for damageType,damage in pairs(damageRange) do
							local min = damage.Min or damage[1]
							local max = damage.Max or damage[2]
							if min > 0 or max > 0 then
								if max == min then
									table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i", max)))
								else
									table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i-%i", min, max)))
								end
							end
							totalDamageTypes = totalDamageTypes + 1
						end
						if totalDamageTypes > 0 then
							if totalDamageTypes > 1 then
								return StringHelpers.Join(", ", damageTexts)
							else
								return damageTexts[1]
							end
						end
					end
				end, debug.traceback)
				if not success then
					Ext.PrintError(result)
				else
					return result
				end
			elseif param3 == "ExplodeRadius" then
				return tostring(Ext.StatGetAttribute(param2, param3))
			end
		end
	end
	if Features.ReplaceTooltipPlaceholders then
		if param1 == "ExtraData" then
			local value = Ext.ExtraData[param2]
			if value ~= nil then
				if value == math.floor(value) then
					return string.format("%i", math.floor(value))
				else
					if value <= 1.0 and value >= 0.0 then
						-- Percentage display
						value = value * 100
						return string.format("%i", math.floor(value))
					else
						return tostring(value)
					end
				end
			end
		end
	end
end

Ext.RegisterListener("StatusGetDescriptionParam", StatusGetDescriptionParam)

local baseText = ts:Create("hbb9884d7g3b9ag43dfga88egdcc32db8bd74", "<br>Base: [1]")

---@param character EclCharacter
---@param name string
---@param tooltip TooltipData
local function OnStatTooltip(character, name, tooltip)
	if name == "APRecovery" then
		local stat = Ext.GetStat(character.Stats.Name)
		for i,element in ipairs(tooltip:GetElements("StatsAPBase")) do
			if i == 1 then
				element.Label = baseText:ReplacePlaceholders(stat.APMaximum)
			elseif i == 2 then
				element.Label = baseText:ReplacePlaceholders(stat.APStart)
			elseif i == 3 then
				element.Label = baseText:ReplacePlaceholders(stat.APRecovery)
			end
		end
	end
end

---@param character EclCharacter
---@param stat CustomStatData
---@param tooltip TooltipData
local function OnCustomStatTooltip(character, stat, tooltip)
	if Vars.DebugMode then
		if stat.ID == "Lucky" then
			local element = tooltip:GetElement("AbilityDescription")
			local value = stat:GetValue(character)
			if value > 0 then
				element.CurrentLevelEffect = string.format("Level %s: Gain %s%% more loot.", value or 1, 200)
				element.NextLevelEffect = string.format("Next Level %s: Gain %s%% more loot.", value+1, (value+1)*100)
				tooltip:AppendElement({
					Type="StatsTalentsBoost",
					Label = string.format("Loot Baggins +%s", value or 1)
				})
			else
				element.CurrentLevelEffect = ""
				element.NextLevelEffect = string.format("Next Level %s: Gain %s%% more loot.", value+1, (value+1)*100)
			end
		end
	end
end

local tooltipSwf = {
	"Public/Game/GUI/LSClasses.swf",
	"Public/Game/GUI/tooltip.swf",
	"Public/Game/GUI/tooltipHelper.swf",
	"Public/Game/GUI/tooltipHelper_kb.swf",
}

local function ApplyLeading(tooltip_mc, element, amount)
	local val = 0
	if element then
		if amount == 0 or amount == nil then
			amount = tooltip_mc.m_Leading * 0.5
		end
		local heightPadding = 0
		if element.heightOverride then
			heightPadding = element.heightOverride / amount
		else
			heightPadding = element.height / amount
		end
		heightPadding = Ext.Round(heightPadding)
		if heightPadding <= 0 then
			heightPadding = 1
		end
		element.heightOverride = heightPadding * amount
	end
end

local function RepositionElements(tooltip_mc)
	--tooltip_mc.list.sortOnce("orderId",16,false)

	local leading = tooltip_mc.m_Leading * 0.5;
	local index = 0
	local element = nil
	local lastElement = nil
	while index < tooltip_mc.list.length do
		element = tooltip_mc.list.content_array[index]
		if element.list then
			element.list.positionElements()
		end
		if element == tooltip_mc.equipHeader then
			element.updateHeight()
		else
			if element.needsSubSection then
				if element.heightOverride == 0 or element.heightOverride == nil then
					element.heightOverride = element.height
				end
				--element.heightOverride = element.heightOverride + leading;
				element.heightOverride = element.heightOverride + leading
				if lastElement and not lastElement.needsSubSection then
					if lastElement.heightOverride == 0 or lastElement.heightOverride == nil then
						lastElement.heightOverride = lastElement.height
					end
					--lastElement.heightOverride = lastElement.heightOverride + leading;
					lastElement.heightOverride = lastElement.heightOverride + leading
				end
			end
			--tooltip_mc.applyLeading(element)
			ApplyLeading(tooltip_mc, element)
		end
		lastElement = element
		index = index + 1
	end
	--tooltip_mc.repositionElements()
	tooltip_mc.list.positionElements()
	tooltip_mc.resetBackground()
end

local function ItemHasTag(item, tag)
	if item:HasTag(tag) then
		return true
	end
	if not GameHelpers.Item.IsObject(item) then
		if not StringHelpers.IsNullOrWhitespace(item.Stats.Tags) and 
		Common.TableHasValue(StringHelpers.Split(item.Stats.Tags, ";"), tag) then
			return true
		end
		-- for _,v in pairs(item:GetDeltaMods()) do
		-- 	local deltamod = Ext.GetDeltaMod(v, item.ItemType)
		-- 	if deltamod then
		-- 		for _,boost in pairs(deltamod.Boosts) do
		-- 			local tags = Ext.StatGetAttribute(boost.Boost, "Tags")
		-- 			if not StringHelpers.IsNullOrWhitespace(tags) and
		-- 			Common.TableHasValue(StringHelpers.Split(tags, ";"), tag) then
		-- 				return true
		-- 			end
		-- 		end
		-- 	end
		-- end
		for _,v in pairs(item.Stats.DynamicStats) do
			if not StringHelpers.IsNullOrWhitespace(v.ObjectInstanceName) then
				local tags = Ext.StatGetAttribute(v.ObjectInstanceName, "Tags")
				if not StringHelpers.IsNullOrWhitespace(tags) and Common.TableHasValue(StringHelpers.Split(tags, ";"), tag) then
					return true
				end
			end
		end
	end
	return false
end

local replaceText = {}

---@param tag string
---@param data TagTooltipData
---@return string
local function GetTagTooltipText(tag, data, tooltipType)
	local finalText = ""
	local tagName = ""
	local tagDesc = ""
	if data.Title == nil then
		tagName = Ext.GetTranslatedStringFromKey(tag)
	else
		local t = type(data.Title)
		if t == "string" then
			tagName = data.Title
		elseif t == "table" and data.Type == "TranslatedString" then
			tagName = data.Title.Value
		elseif t == "function" then
			local b,result = xpcall(data.Title, debug.traceback, tag, tooltipType)
			if b then
				tagName = result
			else
				Ext.PrintError(result)
			end
		end
	end
	if data.Description == nil then
		tagDesc = Ext.GetTranslatedStringFromKey(tag.."_Description")
	else
		local t = type(data.Description)
		if t == "string" then
			tagDesc = data.Description
		elseif t == "table" and data.Type == "TranslatedString" then
			tagDesc = data.Description.Value
		elseif t == "function" then
			local b,result = xpcall(data.Description, debug.traceback, tag, tooltipType)
			if b then
				tagDesc = result
			else
				Ext.PrintError(result)
			end
		end
	end
	if tagName ~= "" then
		finalText = tagName
	end
	if tagDesc ~= "" then
		if finalText ~= "" then
			finalText = finalText .. "<br>"
		end
		finalText = finalText .. tagDesc
	end
	return GameHelpers.Tooltip.ReplacePlaceholders(finalText)
end

local function FormatTagText(content_array, group, isControllerMode)
	local updatedText = false
	for i=0,#content_array,1 do
		local element = content_array[i]
		if element ~= nil then
			local b,result = xpcall(function()
				if element.label_txt ~= nil then
					local searchText = StringHelpers.Trim(element.label_txt.htmlText):gsub("[\r\n]", "")
					local tag = replaceText[searchText]
					local data = TagTooltips[tag]
					if data ~= nil then
						local finalText = GetTagTooltipText(tag, data, "Item")
						if not StringHelpers.IsNullOrWhitespace(finalText) then
							element.label_txt.htmlText = finalText
							updatedText = true
						end
					end
					-- if Vars.DebugMode then
					-- 	PrintDebug(string.format("(%s) label_txt.htmlText(%s) color(%s)", group.groupID, element.label_txt.htmlText, element.label_txt.textColor))
					-- end
				end
				return true
			end, debug.traceback)
			if not b then
				Ext.PrintError("[LeaderLib:FormatTagText] Error:")
				Ext.PrintError(result)
			end
		end
	end
	if updatedText and group ~= nil then
		group.iconId = 16
		group.setupHeader()
	end
end

UI.FormatArrayTagText = FormatTagText

local function FormatTagTooltip(ui, tooltip_mc, ...)
	local length = #tooltip_mc.list.content_array
	if length > 0 then
		for i=0,length,1 do
			local group = tooltip_mc.list.content_array[i]
			if group ~= nil then
				--print(string.format("[%i] groupID(%i) orderId(%s) icon(%s) list(%s)", i, group.groupID or -1, group.orderId or -1, group.iconId, group.list))
				if group.list ~= nil then
					FormatTagText(group.list.content_array, group, false)
				end
			end
		end
	end
end

local function OnTooltipPositioned(ui, ...)
	if UI.Tooltip.HasTagTooltipData or #Listeners.OnTooltipPositioned > 0 then
		local root = ui:GetRoot()
		if root ~= nil then
			local tooltips = {}

			if root.formatTooltip ~= nil then
				tooltips[#tooltips+1] = root.formatTooltip.tooltip_mc
			end
			if root.compareTooltip ~= nil then
				tooltips[#tooltips+1] = root.compareTooltip.tooltip_mc
			end
			if root.offhandTooltip ~= nil then
				tooltips[#tooltips+1] = root.offhandTooltip.tooltip_mc
			end

			if #tooltips > 0 then
				for i,tooltip_mc in pairs(tooltips) do
					if Features.FormatTagElementTooltips then
						FormatTagTooltip(ui, tooltip_mc)
					end
					InvokeListenerCallbacks(Listeners.OnTooltipPositioned, ui, tooltip_mc, false, UI.Tooltip.LastItem, ...)
				end
			end
		end
	end
end

---RootTemplate -> Skill -> Enabled
---@type table<string,table<string,boolean>>
local skillBookAssociatedSkills = {}

local appendRequirementsAfterTypes = {ItemLevel=true, APCostBoost=true}

local function AddTooltipTags(item, tooltip)
	for tag,data in pairs(TagTooltips) do
		if ItemHasTag(item, tag) then
			local finalText = GetTagTooltipText(tag, data, "Item")
			if not StringHelpers.IsNullOrWhitespace(finalText) then
				tooltip:AppendElement({
					Type="StatsTalentsBoost",
					Label=finalText
				})
				local searchText = finalText:gsub("<font.->", ""):gsub("</font>", ""):gsub("<br>", "")
				replaceText[searchText] = tag
			end
		end
	end
end

---@param item EclItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	if tooltip == nil then
		return
	end
	if item ~= nil then
		UI.Tooltip.LastItem = item
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
					local savedSkills = skillBookAssociatedSkills[item.RootTemplate.Id]
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
									if skillBookAssociatedSkills[item.RootTemplate.Id] == nil then
										skillBookAssociatedSkills[item.RootTemplate.Id] = {}
										savedSkills = skillBookAssociatedSkills[item.RootTemplate.Id]
									end
									skillBookAssociatedSkills[item.RootTemplate.Id][skill.Name] = true
								end
							end
						end
					end
					if savedSkills ~= nil then
						for skill,b in pairs(savedSkills) do
							if b then
								OnSkillTooltip(character, skill, tooltip)
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
		if UI.Tooltip.HasTagTooltipData then
			AddTooltipTags(item, tooltip)
		end
		if Features.TooltipGrammarHelper or GameSettings.Settings.Client.AlwaysDisplayWeaponScalingText then
			local hasScalesWithText = false
			local requiresPointsHigherThanZero = false
			local scalesWithTextSub = string.sub(LocalizedText.Tooltip.ScalesWith.Value, 1, 5)
			local requirements = tooltip:GetElements("ItemRequirement")
			if requirements ~= nil then
				for i,element in pairs(requirements) do
					if Features.TooltipGrammarHelper then
						element.Label = string.gsub(element.Label, "%s+", " ")
					end
					if not hasScalesWithText and string.find(element.Label, scalesWithTextSub) then
						hasScalesWithText = true
					end
				end
			end
			if not GameHelpers.Item.IsObject(item) and item.Stats.Requirements ~= nil and #item.Stats.Requirements > 0 then
				local attributeName = ""
				local requirementsMet = true
				for i,v in pairs(item.Stats.Requirements) do
					if Data.AttributeEnum[v.Requirement] ~= nil then
						attributeName = LocalizedText.AttributeNames[v.Requirement].Value
						if type(v.Param) == "number" and v.Param > 0 then
							requiresPointsHigherThanZero = true
							if character.Stats[v.Requirement] < v.Param then
								requirementsMet = false
							end
						end
					end
				end
				if not StringHelpers.IsNullOrEmpty(attributeName) then
					if item.ItemType == "Weapon" then
						if GameSettings.Settings.Client.AlwaysDisplayWeaponScalingText and not hasScalesWithText then
							local element = {
								Type = "ItemRequirement",
								Label = LocalizedText.Tooltip.ScalesWith:ReplacePlaceholders(attributeName),
								RequirementMet = requirementsMet
							}
							if not requirements then
								tooltip:AppendElement(element)
							else
								tooltip:RemoveElements("ItemRequirement")
								tooltip:AppendElementAfterType(element, appendRequirementsAfterTypes)
								for i,v in pairs(requirements) do
									tooltip:AppendElementAfter(v, element)
								end
							end
						end
					elseif hasScalesWithText and requiresPointsHigherThanZero then
						--Armor doesn't scale with requirements, so just show the attribute requirement.
						tooltip:RemoveElements("ItemRequirement")
						local element = {
							Type = "ItemRequirement",
							Label = LocalizedText.Tooltip.Requires:ReplacePlaceholders(attributeName),
							RequirementMet = requirementsMet
						}
						tooltip:AppendElementAfterType(element, appendRequirementsAfterTypes)
					end
				end
			end
		end
		if item:HasTag("LeaderLib_AutoLevel") then
			local element = tooltip:GetElement("ItemDescription")
			if element ~= nil and not string.find(string.lower(element.Label), "automatically level") then
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

---@param item EclItem
---@param rune StatEntryObject
---@param slot integer
---@param tooltip TooltipData
local function OnRuneTooltip(item, rune, slot, tooltip)
	if Vars.DebugMode then
		Ext.PrintWarning("OnRuneTooltip", item.StatsId, rune.Name, slot, Ext.JsonStringify(tooltip))
	end
end

local function InvokeWorldTooltipCallbacks(ui, text, x, y, isFromItem, item)
	local textResult = text
	local length = Listeners.OnWorldTooltip and #Listeners.OnWorldTooltip or 0
	if length > 0 then
		for i=1,length do
			local callback = Listeners.OnWorldTooltip[i]
			local b,result = xpcall(callback, debug.traceback, ui, textResult, x, y, isFromItem, item)
			if not b then
				Ext.PrintError(result)
			elseif result then
				textResult = result
			end
		end
	end
	return textResult
end


---@param player EclCharacter
---@param tooltip TooltipData
local function OnTalentTooltip(player, talent, tooltip)
	print("OnTalentTooltip", player, talent, Ext.JsonStringify(tooltip.Data))
end

local tooltipTypeToElement = {
	Ability = "AbilityDescription",
	CustomStat = "StatsDescription",
	Item = "ItemDescription",
	Rune = "ItemDescription",
	Skill = "SkillDescription",
	Stat = "StatsDescription",
	Status = "StatusDescription",
	Tag = "TagDescription",
	Talent = "TalentDescription",
}

---@param request TooltipRequest
---@param tooltip TooltipData
local function OnAnyTooltip(request, tooltip)
	local canShowText = not GameSettings.Settings.Client.AlwaysExpandTooltips and (not Vars.ControllerEnabled or Vars.DebugMode)
	if canShowText and TooltipExpander.IsDirty() then
		if request.Type == "Generic" then
			local format = "<br><br><p align='center'><font color='#44CC00'>%s</font></p>"
			local keyText = not Vars.ControllerEnabled and LocalizedText.Input.Shift.Value or LocalizedText.Input.Select.Value
			if TooltipExpander.IsExpanded() then
				tooltip.Data.Text = tooltip.Data.Text .. string.format(format, LocalizedText.Tooltip.ExpanderActive:ReplacePlaceholders(keyText))
			else
				tooltip.Data.Text = tooltip.Data.Text .. string.format(format, LocalizedText.Tooltip.ExpanderInactive:ReplacePlaceholders(keyText))
			end
		else
			local elementType = tooltipTypeToElement[request.Type]
			local element = tooltip:GetLastElement(elementType)
			if element then
				local target = element.Label or element.Description
				if target then
					local nextText = target
					local format = "<br><p align='center'><font color='#44CC00'>%s</font></p>"
					if not string.find(nextText, "<br>", #nextText-5, true) then
						format = "<br>"..format
					end
					local keyText = not Vars.ControllerEnabled and LocalizedText.Input.Shift.Value or LocalizedText.Input.Select.Value
					if TooltipExpander.IsExpanded() then
						nextText = nextText .. string.format(format, LocalizedText.Tooltip.ExpanderActive:ReplacePlaceholders(keyText))
					else
						nextText = nextText .. string.format(format, LocalizedText.Tooltip.ExpanderInactive:ReplacePlaceholders(keyText))
					end
					if element.Label then
						element.Label = nextText
					elseif element.Description then
						element.Description = nextText
					end
				end
			end
		end
	end
end

Ext.RegisterListener("SessionLoaded", function()
	Game.Tooltip.RegisterListener("Item", nil, OnItemTooltip)
	Game.Tooltip.RegisterListener("Rune", nil, OnRuneTooltip)
	Game.Tooltip.RegisterListener("Skill", nil, OnSkillTooltip)
	Game.Tooltip.RegisterListener("Status", nil, OnStatusTooltip)
	Game.Tooltip.RegisterListener("Stat", nil, OnStatTooltip)
	if Vars.DebugMode then
		--Game.Tooltip.RegisterListener("Talent", nil, OnTalentTooltip)
		Game.Tooltip.RegisterListener("CustomStat", nil, OnCustomStatTooltip)
		-- Game.Tooltip.RegisterListener("Ability", nil, function(character, stat, tooltip)
		-- 	print(stat, Ext.JsonStringify(tooltip.Data))
		-- end)
		---@param tooltip GenericTooltipData
		-- Game.Tooltip.RegisterListener("Generic", function(tooltip)
		-- 	if tooltip.Data.CallingUI == Data.UIType.hotBar and tooltip.Data.Text == "Toggle Chat" then
		-- 		tooltip:MarkDirty()
		-- 		tooltip.Data.AllowDelay = false
		-- 		--tooltip.Data.Text = tooltip.Data.Text .. "<br>This is appended text! Yahoo!"
		-- 		if tooltip:IsExpanded() then
		-- 			tooltip.Data.Text = "Toggle Chat<br>Global chat was disabled before release ;("
		-- 		end
		-- 	end
		-- end)
	end

	Game.Tooltip.RegisterListener(OnAnyTooltip)

	-- Ext.RegisterUITypeInvokeListener(Data.UIType.tooltip, "addTooltip", function(ui, method, text, xPos, yPos, ...)
	-- 	InvokeListenerCallbacks(Listeners.OnAddTooltip, ui, text, xPos, yPos, ...)
	-- end)

	local canGetTooltipItem = Ext.GetPickingState ~= nil

	-- Called after addTooltip, so main.tf should be set up.
	Ext.RegisterUITypeCall(Data.UIType.tooltip, "keepUIinScreen", function(ui, call, b)
		local main = ui:GetRoot()
		if main and main.tf and main.tf.newBG_mc then
			local text = main.tf.shortDesc
			local param2 = main.tf.newBG_mc.visible and 1 or 0
			if canGetTooltipItem then
				local cursorData = Ext.GetPickingState()
				if cursorData and cursorData.HoverItem then
					local item = Ext.GetItem(cursorData.HoverItem)
					if item then
						local textResult = InvokeWorldTooltipCallbacks(ui, text, main.tf.x, main.tf.y, true, item)
						if textResult ~= text then
							main.tf.shortDesc = textResult
							main.tf.setText(textResult, param2)
						end
					end
				end
			else
				local textResult = InvokeWorldTooltipCallbacks(ui, text, main.tf.x, main.tf.y, false, nil)
				if textResult ~= text then
					main.tf.shortDesc = textResult
					main.tf.setText(textResult, param2)
				end
			end
		end
	end)
	Ext.RegisterUITypeInvokeListener(Data.UIType.worldTooltip, "updateTooltips", function(ui, method)
		local main = ui:GetRoot()
		if main then
			--public function setTooltip(param1:uint, param2:Number, param3:Number, param4:Number, param5:String, param6:Number, param7:Boolean, param8:uint = 16777215, param9:uint = 0
			--this.setTooltip(val2,val3,val4,val5,val6,this.worldTooltip_array[val2++],this.worldTooltip_array[val2++]);
			for i=0,#main.worldTooltip_array,6 do
				local doubleHandle = main.worldTooltip_array[i]
				if doubleHandle then
					local x = main.worldTooltip_array[i+1]
					local y = main.worldTooltip_array[i+2]
					local text = main.worldTooltip_array[i+3]
					--local sortHelper = main.worldTooltip_array[i+4]
					local isItem = main.worldTooltip_array[i+5]
					if isItem then
						local handle = Ext.DoubleToHandle(doubleHandle)
						local item = Ext.GetItem(handle)
						if item then
							local textResult = InvokeWorldTooltipCallbacks(ui, text, x, y, true, item)
							if textResult ~= text then
								main.worldTooltip_array[i+3] = textResult
							end
						end
					else
						local textResult = InvokeWorldTooltipCallbacks(ui, text, x, y, false)
						if textResult ~= text then
							main.worldTooltip_array[i+3] = textResult
						end
					end
				end
			end
		end
	end)

	Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", function(ui, ...)
		OnTooltipPositioned(ui, ...)
	end)

	-- Ext.RegisterUITypeCall(104, "showTooltip", function (ui, call, mcType, doubleHandle, ...)
	-- end)
	-- Ext.RegisterUITypeInvokeListener(Data.UIType.examine, "update", function(ui, method)
	-- 	print(ui:GetTypeId(), method)
	-- 	local main = ui:GetRoot()
	-- 	local array = main.addStats_array
	-- 	if main ~= nil and array ~= nil then
	-- 		for i=0,#array do
	-- 			print(i, array[i])
	-- 		end
	-- 	end
	-- end)
	-- Ext.RegisterUITypeInvokeListener(Data.UIType.examine, "updateStatusses", function(ui, method)
	-- 	local main = ui:GetRoot()
	-- 	local array = main.status_array
	-- 	if main ~= nil and array ~= nil then
	-- 		local handleDouble = array[0]
	-- 		if handleDouble ~= nil then
	-- 			local character = Ext.GetCharacter(Ext.DoubleToHandle(handleDouble))
	-- 			if character ~= nil then
	-- 				print(character.MyGuid, handleDouble)
	-- 			end
	-- 		end
	-- 		for i=0,#array do
	-- 			print(i, array[i])
	-- 		end
	-- 	end
	-- end)
	-- Ext.RegisterUITypeInvokeListener(Data.UIType.contextMenu, "updateButtons", function(ui, method)
	-- 	print(ui:GetTypeId(), method)
	-- 	local main = ui:GetRoot()
	-- 	if main ~= nil and main.buttonArr ~= nil then
	-- 		for i=0,#main.buttonArr do
	-- 			print(i, main.buttonArr[i])
	-- 		end
	-- 	end
	-- end)
	-- Ext.RegisterUITypeCall(Data.UIType.contextMenu, "buttonPressed", function(ui, ...)
	-- 	print(Common.Dump({...}))
	-- end)
end)

local function EnableTooltipOverride()
	--Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/tooltip.swf")
	Ext.AddPathOverride("Public/Game/GUI/LSClasses.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LSClasses_Fixed.swf")
	--Ext.AddPathOverride("Public/Game/GUI/tooltipHelper_kb.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/tooltipHelper_kb_Fixed.swf")
	Ext.Print("[LeaderLib] Enabled tooltip override.")
end

if UI == nil then
	UI = {}
end

---Registers a tag to display on item tooltips.
---@param tag string
---@param title TranslatedString
---@param description TranslatedString
function UI.RegisterItemTooltipTag(tag, title, description)
	local data = {}
	if title ~= nil then
		data.Title = title
	end
	if description ~= nil then
		data.Description = description
	end
	TagTooltips[tag] = data
	UI.Tooltip.HasTagTooltipData = true
end

-- Ext.RegisterListener("ModuleLoading", EnableTooltipOverride)
-- Ext.RegisterListener("ModuleLoadStarted", EnableTooltipOverride)
-- Ext.RegisterListener("ModuleResume", EnableTooltipOverride)
-- Ext.RegisterListener("SessionLoading", EnableTooltipOverride)
-- Ext.RegisterListener("SessionLoaded", EnableTooltipOverride)