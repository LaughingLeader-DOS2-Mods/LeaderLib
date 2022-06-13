---@param character EclCharacter
---@param status EclStatus
---@param tooltip TooltipData
function TooltipHandler.OnStatusTooltip(character, status, tooltip)
	local statusType = GameHelpers.Status.GetStatusType(status.StatusId)
	if Features.ApplyBonusWeaponStatuses then
		if not Data.EngineStatus[status.StatusId] and Data.StatusStatsIdTypes[statusType] then
			local potion = Ext.StatGetAttribute(status.StatusId, "StatsId")
			if not StringHelpers.IsNullOrWhitespace(potion) and not string.find(potion, ";") then
				local bonusWeapon = Ext.StatGetAttribute(potion, "BonusWeapon")
				if not StringHelpers.IsNullOrWhitespace(bonusWeapon) then
					--ExtraProperties
					local extraProps = GameHelpers.Stats.GetExtraProperties(bonusWeapon)
					if extraProps and #extraProps > 0 then
						local addedTopElement = false
						for _,v in pairs(extraProps) do
							local text = ""
							if v.Type == "Status" then
								if v.StatusChance > 0 and GameHelpers.Stats.Exists(v.Action, "StatusData") then
									local stat = Ext.GetStat(v.Action)
									local statusDisplayName = GameHelpers.GetStringKeyText(stat.DisplayName, stat.DisplayNameRef)
									local chanceText = ""
									if v.StatusChance < 1 then
										chanceText = " " .. LocalizedText.Tooltip.Chance:ReplacePlaceholders(Ext.Round(v.StatusChance * 100))
									end
									if v.Duration > 0 then
										local turns = v.Duration
										text = LocalizedText.Tooltip.ExtraPropertiesWithTurns:ReplacePlaceholders(statusDisplayName, chanceText, "", turns)
									else
										text = LocalizedText.Tooltip.ExtraPropertiesPermanent:ReplacePlaceholders(statusDisplayName, chanceText, "")
									end
								end
							elseif v.Type == "GameAction" then
								if v.Action == "TargetCreateSurface" then
									local radius = Ext.Round(v.Arg4)
									local surface = v.Arg3
									if surface == "None" then
										text = LocalizedText.Tooltip.ExtraPropertiesClearSurfacesTarget:ReplacePlaceholders(radius)
									else
										local surfaceName = LocalizedText.Surfaces[v.Arg3]
										if surfaceName then
											text = LocalizedText.Tooltip.ExtraPropertiesCreateSurfaceAtTarget:ReplacePlaceholders(surfaceName.Value, radius)
										end
									end
								end
							end
							if not StringHelpers.IsNullOrWhitespace(text) then
								if not addedTopElement then
									tooltip:AppendElement({
										Type = "Flags",
										Label = LocalizedText.Tooltip.BonusWeaponOnAttack.Value
									})
									addedTopElement = true
								end
								local element = {
									Type = "Flags",
									Label = text
								}
								tooltip:AppendElement(element)
							end
						end
					end
				end
			end
		end
	end
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
						local startPos,endPos,damage = string.find(element.Label, TooltipHandler.Settings.ChaosDamagePattern)
						if damage ~= nil and not string.find(element.Label, TooltipHandler.Settings.SkipChaosDamagePattern, startPos) then
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
					local damageSkillProps = GameHelpers.Ext.CreateSkillTable(param2, nil, true)
					local damageRange = Game.Math.GetSkillDamageRange(skillSource, damageSkillProps, nil, nil)
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