---@type table<string,TagTooltipData>
UI.Tooltip.TagTooltips = {}
UI.Tooltip.HasTagTooltipData = false

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
	if Vars.DebugMode and SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
		print(skill, Common.Dump(Ext.StatGetAttribute(skill, "MemorizationRequirements")))
	end
	--print(Ext.JsonStringify(tooltip.Data))
	if Features.TooltipGrammarHelper then
		-- This fixes the double spaces from removing the "tag" part of Requires tag
		for i,element in pairs(tooltip:GetElements("SkillRequiredEquipment")) do
			element.Label = string.gsub(element.Label, "%s+", " ")
		end
	end

	if Features.FixRifleWeaponRequirement then
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

	if Features.FixFarOutManSkillRangeTooltip and (character ~= nil and character.Stats ~= nil and character.Stats.TALENT_FaroutDude == true) then
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

---@param character EclCharacter
---@param stat string
---@param tooltip TooltipData
local function OnStatTooltip(character, stat, tooltip)
	
end

---@param character EclCharacter
---@param stat ObjectHandle
---@param tooltip TooltipData
local function OnCustomStatTooltip(character, stat, tooltip)

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

local lastItem = nil

local function AddTags(tooltip_mc)
	if lastItem == nil then
		return
	end
	if UI.Tooltip.HasTagTooltipData then
		local text = ""
		for tag,data in pairs(TagTooltips) do
			if lastItem:HasTag(tag) then
				local tagName = ""
				if data.Title == nil then
					tagName = Ext.GetTranslatedStringFromKey(tag)
				else
					tagName = data.Title.Value
				end
				local tagDesc = ""
				if data.Description == nil then
					tagDesc = Ext.GetTranslatedStringFromKey(tag.."_Description")
				else
					tagDesc = data.Description.Value
				end
				tagName = GameHelpers.Tooltip.ReplacePlaceholders(tagName)
				tagDesc = GameHelpers.Tooltip.ReplacePlaceholders(tagDesc)
				if text ~= "" then
					text = text .. "<br>"
				end
				text = text .. string.format("%s<br>%s", tagName, tagDesc)
			end
		end
		if text ~= "" then
			local group = tooltip_mc.addGroup(15)
			if group ~= nil then
				group.orderId = 0;
				group.addDescription(text)
				--group.addWhiteSpace(0,0)
			else
				Ext.PrintError("[LeaderLib:TooltipHandler:AddTags] Failed to create group.")
			end
		end
	end
	lastItem = nil
end

local replaceText = {}

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
						local finalText = ""
						local tagName = ""
						if data.Title == nil then
							tagName = Ext.GetTranslatedStringFromKey(tag)
						else
							tagName = data.Title.Value
						end
						local tagDesc = ""
						if data.Description == nil then
							tagDesc = Ext.GetTranslatedStringFromKey(tag.."_Description")
						else
							tagDesc = data.Description.Value
						end
						if tagName ~= "" then
							tagName = GameHelpers.Tooltip.ReplacePlaceholders(tagName)
							finalText = tagName
						end
						if tagDesc ~= "" then
							tagDesc = GameHelpers.Tooltip.ReplacePlaceholders(tagDesc)
							if finalText ~= "" then
								finalText = finalText .. "<br>"
							end
							finalText = finalText .. tagDesc
						end
						if finalText ~= "" then
							element.label_txt.htmlText = finalText
							updatedText = true
						end
						--print(string.format("[%s] htmlText(%s) finalText(%s)", group.name, element.label_txt.htmlText, finalText))
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
	if UI.Tooltip.HasTagTooltipData or #UIListeners.OnTooltipPositioned > 0 then
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
					InvokeListenerCallbacks(UIListeners.OnTooltipPositioned, ui, tooltip_mc, false, lastItem, ...)
				end
			end
		end
	end
end

---RootTemplate -> Skill -> Enabled
---@type table<string,table<string,boolean>>
local skillBookAssociatedSkills = {}

---@param item EclItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	if tooltip == nil then
		return
	end
	if Vars.DebugMode then
		Ext.PrintWarning("OnItemTooltip", item and item.StatsId or "nil", Ext.JsonStringify(tooltip.Data))
	end
	if item ~= nil then
		lastItem = item
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
						for i,skill in pairs(Ext.GetStatEntries("SkillData")) do
							local icon = Ext.StatGetAttribute(skill, "Icon")
							if tooltipIcon == icon then
								local displayName = GameHelpers.GetStringKeyText(Ext.StatGetAttribute(skill, "DisplayName"))
								local description = GameHelpers.GetStringKeyText(Ext.StatGetAttribute(skill, "Description"))
		
								if displayName == skillBookSkillDisplayName and description == tooltipSkillDescription then
									if skillBookAssociatedSkills[item.RootTemplate.Id] == nil then
										skillBookAssociatedSkills[item.RootTemplate.Id] = {}
										savedSkills = skillBookAssociatedSkills[item.RootTemplate.Id]
									end
									skillBookAssociatedSkills[item.RootTemplate.Id][skill] = true
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
							--PrintDebug(tString.Value, resistanceText, totalResPen, result)
							local element = {
								Type = "ResistanceBoost",
								Label = result,
								Value = totalResPen,
							}
							tooltip:AppendElement(element)
						end
					end
				end
				--print("ResPen tags:", Ext.JsonStringify(tagsCheck))
			end
		end
		if UI.Tooltip.HasTagTooltipData then
			for tag,data in pairs(TagTooltips) do
				if item:HasTag(tag) then
					local finalText = ""
					local tagName = ""
					local tagDesc = ""
					if data.Title == nil then
						tagName = Ext.GetTranslatedStringFromKey(tag)
					else
						tagName = data.Title.Value
					end
					if data.Description == nil then
						tagDesc = Ext.GetTranslatedStringFromKey(tag.."_Description")
					else
						tagDesc = data.Description.Value
					end
					if tagName ~= "" then
						tagName = GameHelpers.Tooltip.ReplacePlaceholders(tagName)
						finalText = tagName
					end
					if tagDesc ~= "" then
						tagDesc = GameHelpers.Tooltip.ReplacePlaceholders(tagDesc)
						if finalText ~= "" then
							finalText = finalText .. "<br>"
						end
						finalText = finalText .. tagDesc
					end
					if finalText ~= "" then
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
		if Features.TooltipGrammarHelper or GameSettings.Settings.Client.AlwaysDisplayWeaponScalingText then
			local hasScalesWithText = false
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
			if (GameSettings.Settings.Client.AlwaysDisplayWeaponScalingText and not hasScalesWithText 
			and item.Stats and item.Stats.Requirements ~= nil and #item.Stats.Requirements > 0) then
				local attributeName = ""
				for i,v in pairs(item.Stats.Requirements) do
					if Data.AttributeEnum[v.Requirement] ~= nil then
						attributeName = LocalizedText.AttributeNames[v.Requirement].Value
					end
				end
				if not StringHelpers.IsNullOrEmpty(attributeName) then
					local element = {
						Type = "ItemRequirement",
						Label = LocalizedText.Tooltip.ScalesWith:ReplacePlaceholders(attributeName),
						RequirementMet = true
					}
					if not requirements then
						tooltip:AppendElement(element)
					else
						tooltip:RemoveElements("ItemRequirement")
						tooltip:AppendElement(element)
						for i,v in pairs(requirements) do
							tooltip:AppendElement(v)
						end
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
			--print(Ext.JsonStringify(tooltip.Data))
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

local debugTooltipCalls = {
	"tooltipClicked",
	"tooltipOut",
	"tooltipOver",
	"showItemTooltip",
	"showTooltip",
	"hideTooltip",
	"setTooltipSize",
}

---@param item EclItem
---@param rune StatEntryObject
---@param slot integer
---@param tooltip TooltipData
local function OnRuneTooltip(item, rune, slot, tooltip)
	if Vars.DebugMode then
		Ext.PrintWarning("OnRuneTooltip", item.StatsId, rune.Name, slot, Ext.JsonStringify(tooltip))
	end
end

Ext.RegisterListener("SessionLoaded", function()
	Game.Tooltip.RegisterListener("Item", nil, OnItemTooltip)
	Game.Tooltip.RegisterListener("Rune", nil, OnRuneTooltip)
	Game.Tooltip.RegisterListener("Skill", nil, OnSkillTooltip)
	Game.Tooltip.RegisterListener("Status", nil, OnStatusTooltip)
	--Game.Tooltip.RegisterListener("Stat", nil, OnStatTooltip)
	--Game.Tooltip.RegisterListener("CustomStat", nil, OnCustomStatTooltip)

	---@param ui UIObject
	-- Ext.RegisterUITypeInvokeListener(44, "updateTooltips", function(ui, method, ...)
	-- 	print(ui:GetTypeId(), method, Common.Dump{...})
	-- end)
	-- Ext.RegisterUITypeInvokeListener(44, "showTooltipLong", function(ui, method, ...)
	-- 	print(ui:GetTypeId(), method, Common.Dump{...})
	-- end)
	Ext.RegisterUITypeInvokeListener(Data.UIType.tooltip, "addTooltip", function(ui, method, text, xPos, yPos, ...)
		for i,callback in pairs(UIListeners.OnWorldTooltip) do
			local status,err = xpcall(callback, debug.traceback, ui, text, xPos, yPos, ...)
			if not status then
				Ext.PrintError("[LeaderLib:OnWorldTooltip] Error invoking callback:")
				Ext.PrintError(err)
			end
		end
	end, "After")
	-- Ext.RegisterUITypeInvokeListener(44, "addFormattedTooltip", function(ui, method, ...)
	-- 	print(ui:GetTypeId(), method, Common.Dump{...})
	-- end)

	-- for i,v in pairs(debugTooltipCalls) do
	-- 	Ext.RegisterUINameCall(v, function(ui, call, ...)
	-- 		print(ui:GetTypeId(), call, Common.Dump{...})
	-- 	end)
	-- end

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