
local FarOutManFixSkillTypes = {
	Cone = "Range",
	Zone = "Range",
}

---@param character EclCharacter
---@param skill string
---@param tooltip TooltipData
function TooltipHandler.OnSkillTooltip(character, skill, tooltip)
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
					local startPos,endPos,damage = string.find(element.Label, TooltipHandler.ChaosDamagePattern)
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
--- @param param1 string
--- @param param2 string
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