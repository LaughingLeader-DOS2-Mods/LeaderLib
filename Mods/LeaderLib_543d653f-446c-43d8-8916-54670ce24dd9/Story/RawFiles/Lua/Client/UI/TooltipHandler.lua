---@type table<string,TagTooltipData>
UI.Tooltip.TagTooltips = {}
UI.Tooltip.HasTagTooltipData = false

---@class TagTooltipData
---@field Title TranslatedString
---@field Description TranslatedString


local TagTooltips = UI.Tooltip.TagTooltips

---@type TranslatedString
local ts = Classes.TranslatedString

local AutoLevelingDescription = ts:Create("hca27994egc60eg495dg8146g7f81c970e265", "<font color='#80FFC3'>Automatically levels up with the wearer.</font>")

local extraPropStatusTurnsPattern = "Set (.+) for (%d+) turn%(s%).-%((%d+)%% Chance%)"

---@param item EsvItem
---@param tooltip TooltipData
local function CondenseItemStatusText(tooltip, inputElements, addColor)
	
	local entries = {}
	
	for i,v in pairs(inputElements) do
		v.Label = string.gsub(v.Label, "  ", " ")
		local a,b,status,turns,chance = string.find(v.Label, extraPropStatusTurnsPattern)
		if status ~= nil and turns ~= nil and chance ~= nil then
			local color = ""
			tooltip:RemoveElement(v)
			if addColor == true then
				
			end
			table.insert(entries, {Status = status, Turns = turns, Chance = chance, Color = color})
		end
	end
	
	if #entries > 0 then
		local finalStatusText = ""
		local finalTurnsText = ""
		local finalChanceText = ""
		for i,v in pairs(entries) do
			finalStatusText = finalStatusText .. v.Status
			finalTurnsText = finalTurnsText .. v.Turns
			finalChanceText = finalChanceText .. v.Chance.."%"
			if i >= 1 and i < #entries then
				finalStatusText = finalStatusText .. "/"
				finalTurnsText = finalTurnsText .. "/"
				finalChanceText = finalChanceText .. "/"
			end
		end
		return string.format("On Hit:<br>%s for %s turns(s). (%s Chance)", finalStatusText, finalTurnsText, finalChanceText)
	end
end

local chaosDamagePattern = "<font color=\"#C80030\">([%d-%s]+)</font>"

---@param character EsvCharacter
---@param status EsvStatus
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
						and not string.find(element.Label:lower(), "chaos damage")
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

---@param character EclCharacter
---@param skill EsvStatus
---@param tooltip TooltipData
local function OnSkillTooltip(character, skill, tooltip)
	if character ~= nil then UI.ClientCharacter = character.MyGuid or character.NetID end
	if Features.TooltipGrammarHelper then
		-- This fixes the double spaces from removing the "tag" part of Requires tag
		local element = tooltip:GetElement("SkillRequiredEquipment")
		if element ~= nil and not element.RequirementMet and string.find(element.Label, "Requires  ") then
			element.Label = string.gsub(element.Label, "  ", " ")
		end
	end

	if Features.ReplaceTooltipPlaceholders or (Features.FixChaosDamageDisplay or Features.FixCorrosiveMagicDamageDisplay) or Features.TooltipGrammarHelper then
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
				if Features.FixChaosDamageDisplay == true and not string.find(element.Label:lower(), "chaos damage") then
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
						if string.find(lowerLabel, "corrosive damage") then
							damageText = "corrosive damage"
						elseif string.find(lowerLabel, "magic damage") then
							damageText = "magic damage"
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
						print(err)
					end
				end
				if Features.ReplaceTooltipPlaceholders == true then
					element.Label = GameHelpers.Tooltip.ReplacePlaceholders(element.Label, character)
				end
			end
		end
	end
end

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function SkillGetDescriptionParam(skill, character, isFromItem, param1, param2)
	if character.Character ~= nil then UI.ClientCharacter = character.Character.MyGuid or character.NetID end
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
	if character ~= nil then UI.ClientCharacter = character.MyGuid or character.NetID end
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
				print("Failed to create group")
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
					print(tag, searchText)
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
							tagDesc = string.format("<font color='#C7A758'>%s</font>", GameHelpers.Tooltip.ReplacePlaceholders(tagDesc))
							if finalText ~= "" then
								finalText = finalText .. "<br>"
							end
							finalText = finalText .. tagDesc
						end
						if finalText ~= "" then
							element.label_txt.htmlText = finalText
							updatedText = true
						end
						print(string.format("[%s] htmlText(%s) finalText(%s)", group.name, element.label_txt.htmlText, finalText))
					end
					-- if Ext.IsDeveloperMode() then
					-- 	PrintDebug(string.format("(%s) label_txt.htmlText(%s) color(%s)", group.groupID, element.label_txt.htmlText, element.label_txt.textColor))
					-- end
				end
				return true
			end, debug.traceback)
			if not b then
				print("[LeaderLib:FormatTagText] Error:")
				print(result)
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
				--print(string.format("[%i] groupID(%i) orderId(%s) icon(%s)", i, group.groupID or -1, group.orderId or -1, group.iconId))
				if group.list ~= nil then
					FormatTagText(tooltip_mc.list.content_array, group, false)
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
					for i,callback in pairs(UIListeners.OnTooltipPositioned) do
						local status,err = xpcall(callback, debug.traceback, ui, tooltip_mc, false, ...)
						if not status then
							Ext.PrintError("[LeaderLib:AdjustTagElements] Error invoking callback:")
							Ext.PrintError(err)
						end
					end
				end
			end
		end
	end
end

---@param item EsvItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	if tooltip == nil then
		return
	end
	--print(item.StatsId, Ext.JsonStringify(item.WorldPos), Ext.JsonStringify(tooltip.Data))
	if item ~= nil then
		lastItem = item
		if Features.FixItemAPCost == true then
			local character = nil
			if UI.ClientCharacter ~= nil then
				character = Ext.GetCharacter(UI.ClientCharacter)
			elseif item.ParentInventoryHandle ~= nil then
				character = Ext.GetCharacter(item.ParentInventoryHandle)
			end
			if character ~= nil then
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
		if Features.TooltipGrammarHelper then
			local requirements = tooltip:GetElements("ItemRequirement")
			if requirements ~= nil then
				for i,element in pairs(requirements) do
					if string.find(element.Label, "Requires  ") then
						element.Label = string.gsub(element.Label, "  ", " ")
					end
				end
			end
		end
		if item:HasTag("LeaderLib_AutoLevel") then
			local element = tooltip:GetElement("ItemDescription")
			if element ~= nil and not string.find(element.Label, "Automatically levels") then
				if not StringHelpers.IsNullOrEmpty(element.Label) then
					element.Label = element.Label .. "<br>" .. AutoLevelingDescription.Value
				else
					element.Label = AutoLevelingDescription.Value
				end
			end
		end
		if Features.ReduceTooltipSize and Ext.IsDeveloperMode() then
			--print(Ext.JsonStringify(tooltip.Data))
			local elements = tooltip:GetElements("ExtraProperties")
			if elements ~= nil and #elements > 0 then
				local result = CondenseItemStatusText(tooltip, elements)
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

Ext.RegisterListener("SessionLoaded", function()
	Game.Tooltip.RegisterListener("Item", nil, OnItemTooltip)
	Game.Tooltip.RegisterListener("Skill", nil, OnSkillTooltip)
	Game.Tooltip.RegisterListener("Status", nil, OnStatusTooltip)
	Game.Tooltip.RegisterListener("Stat", nil, OnStatTooltip)

	Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", function(ui, ...)
		OnTooltipPositioned(ui)
	end)
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