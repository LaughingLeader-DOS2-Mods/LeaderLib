
local FarOutManFixSkillTypes = {
	Cone = "Range",
	Zone = "Range",
}

local DamageNameFixing = {
	Chaos = {
		IsActive = function(skill) return Features.FixChaosDamageDisplay == true end,
		Pattern = "<font color=\"#C80030\">([%d-%s]+)</font>",
		Name = LocalizedText.DamageTypeHandles.Chaos.Text,
		Replace = function (self, damageType, element)
			local startPos,endPos,damageText = string.find(element.Label, self.Pattern)
			if damageText ~= nil then
				damageText = string.gsub(damageText, "%s+", "")
				local removeText = string.gsub(string.sub(element.Label, startPos, endPos), "%-", "%%-")
				element.Label = string.gsub(element.Label, removeText, GameHelpers.GetDamageText(damageType, damageText))
			end
		end
	},
	Magic = {
		IsActive = function(skill) return Features.FixCorrosiveMagicDamageDisplay == true end,
		Name = LocalizedText.DamageTypeHandles.Magic.Text,
		Replace = function (self, damageType, element)
			local startPos,endPos = StringHelpers.Find(element.Label, "destroy <font.->[%d-]+ "..self.Name.Value..".-</font> on")
			if startPos and endPos then
				local str = string.sub(element.Label, startPos, endPos)
				local replacement = string.gsub(str, "Destroy","Deal"):gsub("destroy","deal"):gsub(" on"," to")
				element.Label = replacement..string.sub(element.Label, endPos+1)
			end
		end
	},
	Corrosive = {
		IsActive = function(skill) return Features.FixCorrosiveMagicDamageDisplay == true end,
		Name = LocalizedText.DamageTypeHandles.Corrosive.Text,
		Replace = function (self, damageType, element)
			local startPos,endPos = StringHelpers.Find(element.Label, "destroy <font.->[%d-]+ "..self.Name.Value..".-</font> on")
			if startPos and endPos then
				local str = string.sub(element.Label, startPos, endPos)
				local replacement = string.gsub(str, "Destroy","Deal"):gsub("destroy","deal"):gsub(" on"," to")
				element.Label = replacement..string.sub(element.Label, endPos+1)
			end
		end
	},
	-- None = {
	-- 	IsActive = function() return Features.FixPureDamageDisplay == true end,
	-- 	Name = LocalizedText.DamageTypeHandles.None.Text,
	-- 	Pattern = "<font color=\"#C7A758\">([%d-%s]+)</font>",
	-- 	Replace = function (self, element)
	-- 		local startPos,endPos,damageText = string.find(element.Label, self.Pattern)
	-- 		if damageText ~= nil then
	-- 			damageText = string.gsub(damageText, "%s+", "")
	-- 			local removeText = string.gsub(string.sub(element.Label, startPos, endPos), "%-", "%%-")
	-- 			element.Label = string.gsub(element.Label, removeText, GameHelpers.GetDamageText(self.DamageType, damageText))
	-- 		end
	-- 	end
	-- },
	Sulfuric = {
		IsActive = function(skill) return Features.FixSulfuricDamageDisplay == true end,
		Name = LocalizedText.DamageTypeHandles.Sulfuric.Text,
		Pattern = "<font color=\"#C7A758\">([%d-%s]+)</font>",
		Replace = function (self, damageType, element)
			local startPos,endPos,damageText = string.find(element.Label, self.Pattern)
			if damageText ~= nil then
				damageText = StringHelpers.Trim(damageText)
				local removeText = string.gsub(string.sub(element.Label, startPos, endPos), "%-", "%%-")
				print(damageText, removeText)
				element.Label = string.gsub(element.Label, removeText, GameHelpers.GetDamageText(damageType, damageText))
			end
		end
	},
}

local function FixDamageNames(skill, element)
	for damageType,data in pairs(DamageNameFixing) do
		if data.IsActive(skill) then
			data:Replace(damageType, element)
		end
	end
end

---@param character EclCharacter
---@param skill string
---@param tooltip TooltipData
function TooltipHandler.OnSkillTooltip(character, skill, tooltip)
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

	for i,element in pairs(tooltip:GetElements("SkillDescription")) do
		FixDamageNames(skill, element)
		if Features.TooltipGrammarHelper == true then
			element.Label = string.gsub(element.Label, "a 8", "an 8")
			local startPos,endPos = string.find(element.Label , "a <font.->8")
			if startPos then
				local text = string.sub(element.Label, startPos, endPos)
				element.Label = string.gsub(element.Label, text, text:gsub("a ", "an "))
			end
		end
		if Features.ReplaceTooltipPlaceholders == true then
			element.Label = GameHelpers.Tooltip.ReplacePlaceholders(element.Label, character)
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

	Ext.Dump(tooltip.Data)
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