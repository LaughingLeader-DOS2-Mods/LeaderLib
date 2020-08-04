---@class TagTooltipData
---@field Title TranslatedString
---@field Description TranslatedString

---@type table<string,TagTooltipData>
local TagTooltips = {}

---@param item EsvItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	--print(item.StatsId, Ext.JsonStringify(item.WorldPos), Ext.JsonStringify(tooltip.Data))
	if item ~= nil then
		if Features.ResistancePenetration == true then
			-- Resistance Penetration display
			if item:HasTag("LeaderLib_HasResistancePenetration") then
				local tagsCheck = {}
				for _,damageType in Data.DamageTypes:Get() do
					local tags = Data.ResistancePenetrationTags[damageType]
					if tags ~= nil then
						local totalResPen = 0
						for i,tagEntry in ipairs(tags) do
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
	end
end

local chaosDamagePattern = "<font color=\"#C80030\">([%d-%s]+)</font>"

---@param character EsvCharacter
---@param status EclStatus
---@param tooltip TooltipData
local function OnStatusTooltip(character, status, tooltip)
	if Features.FixChaosDamageDisplay then
		if status.StatusType == "DAMAGE" and string.find(Ext.StatGetAttribute(status.StatusId, "DescriptionParams"), "Damage") then
			local element = tooltip:GetElement("StatusDescription")
			if element ~= nil and not string.find(element.Label:lower(), "chaos damage") then
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

---@param character EsvCharacter
---@param skill EsvStatus
---@param tooltip TooltipData
local function OnSkillTooltip(character, skill, tooltip)
	if Features.TooltipGrammarHelper then
		local element = tooltip:GetElement("SkillDescription")
		if element ~= nil then
			element.Label = string.gsub(element.Label, "a 8", "an 8")
		end
		-- This fixes the double spaces from removing the "tag" part of Requires tag
		element = tooltip:GetElement("SkillRequiredEquipment")
		if element ~= nil and not element.RequirementMet and string.find(element.Label, "Requires  ") then
			element.Label = string.gsub(element.Label, "  ", " ")
		end
	end
	if Features.FixChaosDamageDisplay then
		local element = tooltip:GetElement("SkillDescription")
		if element ~= nil and not string.find(element.Label:lower(), "chaos damage") then
			local startPos,endPos,damage = string.find(element.Label, chaosDamagePattern)
			if damage ~= nil then
				damage = string.gsub(damage, "%s+", "")
				local removeText = string.sub(element.Label, startPos, endPos):gsub("%-", "%%-")
				element.Label = string.gsub(element.Label, removeText, GameHelpers.GetDamageText("Chaos", damage))
			end
		end
	end
end

--- @param skill StatEntrySkillData
--- @param character StatCharacter
--- @param isFromItem boolean
--- @param param string
local function SkillGetDescriptionParam(skill, character, isFromItem, param1, param2)
	if Features.ExtraDataSkillParamReplacement then
		if param1 == "ExtraData" then
			local value = Ext.ExtraData[param2]
			if value ~= nil then
				local result = tostring(math.floor(value))
				if result ~= nil then
					return result
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
	if Features.ExtraDataSkillParamReplacement then
		if param1 == "ExtraData" then
			local success,result = xpcall(function()
				local value = Ext.ExtraData[param2]
				if value ~= nil then
					local result = tostring(math.floor(value))
					if result ~= nil then
						return result
					end
				end
			end, debug.traceback)
			if not success then
				Ext.PrintError(result)
			else
				return result
			end
		end
	end
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

Ext.RegisterListener("SessionLoaded", function()
	Game.Tooltip.RegisterListener("Item", nil, OnItemTooltip)
	Game.Tooltip.RegisterListener("Skill", nil, OnSkillTooltip)
	Game.Tooltip.RegisterListener("Status", nil, OnStatusTooltip)
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