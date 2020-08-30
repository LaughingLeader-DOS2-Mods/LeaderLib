---@class TagTooltipData
---@field Title TranslatedString
---@field Description TranslatedString

---@type table<string,TagTooltipData>
local TagTooltips = {}

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
		return string.format("Set %s for %s turns(s). (%s Chance)", finalStatusText, finalTurnsText, finalChanceText)
	end
end

---@param item EsvItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	--print(item.StatsId, Ext.JsonStringify(item.WorldPos), Ext.JsonStringify(tooltip.Data))
	if item ~= nil then
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
		if #TagTooltips > 0 then
			for tag,enabled in pairs(TagTooltips) do
				if enabled and item:HasTag(tag) then
					local tagName,nameHandle = Ext.GetTranslatedStringFromKey(tag)
					local tagDesc,descHandle = Ext.GetTranslatedStringFromKey(tag.."_Description")
					local element = {
						Type = "Tags",
						Label = tagName,
						Value = tagDesc,
					}
					tooltip:AppendElement(element)
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
							print(startPos,endPos,damageText)
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

local function OnTooltipPositioned(ui, ...)
	if #UIListeners.OnTooltipPositioned > 0 then
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
					for i,callback in pairs(UIListeners.OnTooltipPositioned) do
						local status,err = xpcall(callback, debug.traceback, ui, tooltip_mc, ...)
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

---Registers a tag to display on item tooltips.
---@param tag string
---@param title TranslatedString
---@param description TranslatedString
function UI.RegisterItemTooltipTag(tag, title, description)
	TagTooltips[tag] = true
	--TagTooltips[tag] = {Title=title, Description=description}
end

-- Ext.RegisterListener("ModuleLoading", EnableTooltipOverride)
-- Ext.RegisterListener("ModuleLoadStarted", EnableTooltipOverride)
-- Ext.RegisterListener("ModuleResume", EnableTooltipOverride)
-- Ext.RegisterListener("SessionLoading", EnableTooltipOverride)
-- Ext.RegisterListener("SessionLoaded", EnableTooltipOverride)