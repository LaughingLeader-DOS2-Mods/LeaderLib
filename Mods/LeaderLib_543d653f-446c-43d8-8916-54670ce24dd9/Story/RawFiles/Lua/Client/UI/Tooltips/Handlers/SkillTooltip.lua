local _EXTVERSION = Ext.Utils.Version()

local FarOutManFixSkillTypes = {
	Cone = "Range",
	Zone = "Range",
}

TooltipHandler.Settings.FarOutManFixSkillTypes = FarOutManFixSkillTypes

--Any text with the same color following the damage numbers, as it may be trying to give chaos damage a name
local _skipChaosDamagePattern = "<font color=\"#C80030\">[%d-%s]+</font>%s-<font color=[\"-']#C80030[\"-']>([%a-%s]+)</font>"
TooltipHandler.Settings.SkipChaosDamagePattern = _skipChaosDamagePattern

local DamageNameFixing = {
	Chaos = {
		IsActive = function(skill) return Features.FixChaosDamageDisplay == true end,
		Name = LocalizedText.DamageTypeHandles.Chaos.Text,
		Replace = function (self, damageType, element)
			local startPos,endPos,damageText = string.find(element.Label, TooltipHandler.Settings.ChaosDamagePattern)
			if damageText ~= nil and not string.find(element.Label, _skipChaosDamagePattern, startPos) then
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
	Sulfuric = {
		IsActive = function(skill) return Features.FixSulfuricDamageDisplay == true end,
		Name = LocalizedText.DamageTypeHandles.Sulfuric.Text,
		Pattern = "<font color=\"#C7A758\">([%d-%s]+)</font>",
		Replace = function (self, damageType, element)
			local startPos,endPos,damageText = string.find(element.Label, self.Pattern)
			if damageText ~= nil then
				damageText = StringHelpers.Trim(damageText)
				local removeText = string.gsub(string.sub(element.Label, startPos, endPos), "%-", "%%-")
				element.Label = string.gsub(element.Label, removeText, GameHelpers.GetDamageText(damageType, damageText))
			end
		end
	},
	--Replacing just the color
	None = {
		IsActive = function(skill) return Features.FixPureDamageDisplay == true end,
		Name = LocalizedText.DamageTypeHandles.None.Text,
		Replace = function (self, damageType, element)
			local pattern = "(<font color=\"#C80030\">.-"..self.Name.Value.."</font>)"
			local startPos,endPos,damageText = string.find(element.Label, pattern)
			if damageText ~= nil then
				local replaceText = string.gsub(damageText, "#C80030", LocalizedText.DamageTypeHandles.None.Color)
				element.Label = StringHelpers.Replace(element.Label, damageText, replaceText)
			end
		end
	},
}

TooltipHandler.Settings.DamageNameFixing = DamageNameFixing

local _skillDamagePattern = "(.+):Damage$"

local function GetSkillDamageTypes(id, description)
	local skill = Ext.Stats.Get(id, nil, false)
	if not skill then
		return {}
	end
	local damageTypes = {
		[skill.DamageType] = true
	}
	
	if not StringHelpers.IsNullOrWhitespace(skill.StatsDescriptionParams) then
		for _,v in pairs(StringHelpers.Split(skill.StatsDescriptionParams, ";")) do
			local _,_,otherSkill = string.find(v, _skillDamagePattern)
			if not StringHelpers.IsNullOrEmpty(otherSkill) then
				local stat = Ext.Stats.Get(otherSkill, nil, false)
				if stat then
					local damageType = stat.DamageType
					if damageType then
						damageTypes[damageType] = true
					end
				end
			end
		end
	end
	return damageTypes
end

local function FixDamageNames(skill, element)
	if not TooltipHandler.Settings.IgnoreDamageFixingSkills[skill] then
		local compareText = string.lower(element.Label)
		local validDamageTypes = GetSkillDamageTypes(skill, element.Label)
		for damageType,data in pairs(DamageNameFixing) do
			if validDamageTypes[damageType] and data.IsActive(skill) then
				if not string.find(compareText, data.Name.Value) then
					data:Replace(damageType, element)
				end
			end
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

	local isAction = GameHelpers.Stats.IsAction(skill)

	if not isAction then
		local stat = Ext.Stats.Get(skill, nil, false)
		if stat then
			if Features.FixRifleWeaponRequirement then
				local requirement = stat.Requirement
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

			if Features.FixFarOutManSkillRangeTooltip 
			and (character ~= nil and character.Stats ~= nil
			and character.Stats.TALENT_FaroutDude == true) then
				local skillType = stat.SkillType
				local rangeAttribute = FarOutManFixSkillTypes[skillType]
				if rangeAttribute ~= nil then
					local element = tooltip:GetElement("SkillRange")
					if element ~= nil then
						local range = stat[rangeAttribute]
						if range then
							element.Value = tostring(range).."m"
						else
							element.Value = "0m"
						end
					end
				end
			end
		end

		if not Vars.ControllerEnabled then
			if skill == "Shout_LeaderLib_ChainAll" or skill == "Shout_LeaderLib_UnchainAll" then
				tooltip:MarkDirty()
				if tooltip:IsExpanded() then
					local desc = tooltip:GetDescriptionElement()
					if desc then
						desc.Label = string.format("%s<br>%s", desc.Label, LocalizedText.SkillTooltip.LeaderLibToggleGrouping.Value)
					end
				end
			end
		end
	end

	for i,element in pairs(tooltip:GetElements("SkillDescription")) do
		if not isAction then
			FixDamageNames(skill, element)
		end
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

	if Features.FixTooltipEmptySkillProperties then
		local emptyExtraProperties = StringHelpers.Trim(LocalizedText.Tooltip.ExtraPropertiesPermanent:ReplacePlaceholders("", "", ""))
		local skillPropsElements = tooltip:GetElement("SkillProperties")
		if skillPropsElements then
			local replaceProperties = {}
			local shouldReplace = false
			for i,element in pairs(skillPropsElements.Properties) do
				if not StringHelpers.IsNullOrWhitespace(element.Label) and not StringHelpers.IsNullOrWhitespace(StringHelpers.Replace(element.Label, emptyExtraProperties, "")) then
					replaceProperties[#replaceProperties+1] = element
				else
					shouldReplace = true
				end
			end
			if shouldReplace then
				skillPropsElements.Properties = replaceProperties
			end
		end
	end
end

Ext.Events.SkillGetDescriptionParam:Subscribe(function(e)
	if Features.ReplaceTooltipPlaceholders then
		local param1,param2 = table.unpack(e.Params)
		if param1 == "ExtraData" then
			local value = GameHelpers.GetExtraData(param2, nil)
			if value ~= nil then
				if value == math.floor(value) then
					e.Description = string.format("%i", math.floor(value))
				else
					if value <= 1.0 and value >= 0.0 then
						-- Percentage display
						value = value * 100
						e.Description = string.format("%i", math.floor(value))
					else
						e.Description = tostring(value)
					end
				end
			end
		end
	end
end)