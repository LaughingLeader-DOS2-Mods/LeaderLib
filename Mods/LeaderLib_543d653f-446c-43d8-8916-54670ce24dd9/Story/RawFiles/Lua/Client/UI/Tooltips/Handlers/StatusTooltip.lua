local function _AlphabeticalCaseInsensitiveLabelSort(a,b)
	return string.lower(a.Label) < string.lower(b.Label)
end

---@type table<NETID, table<string, boolean>>
local _PermanentStatuses = {}

---@param netid NETID
---@param status string
---@param enabled boolean
local function UpdatePermanentStatus(netid, status, enabled)
	if _PermanentStatuses[netid] == nil then
		_PermanentStatuses[netid] = {}
	end
	if enabled == true then
		_PermanentStatuses[netid][status] = true
	else
		_PermanentStatuses[netid][status] = nil
		if not Common.TableHasAnyEntry(_PermanentStatuses[netid]) then
			_PermanentStatuses[netid] = nil
		end
	end
end

Ext.RegisterNetListener("LeaderLib_RemovePermanentStatuses", function (channel, payload, user)
	local netid = tonumber(payload)
	assert(type(netid) == "number", "data.Target is not a valid NetID")
	_PermanentStatuses[netid] = nil
end)

Ext.RegisterNetListener("LeaderLib_UpdatePermanentStatuses", function (channel, payload, user)
	local data = Common.JsonParse(payload, true)
	if data then
		assert(type(data.Target) == "number", "data.Target is not a valid NetID")
		UpdatePermanentStatus(data.Target, data.StatusId, data.Enabled)
	end
end)

Ext.RegisterNetListener("LeaderLib_UpdateAllPermanentStatuses", function (channel, payload, user)
	local data = Common.JsonParse(payload, true)
	if data then
		for target,statuses in pairs(data) do
			for id,b in pairs(statuses) do
				UpdatePermanentStatus(target, id, b)
			end
		end
	end
end)

---@param character EclCharacter
---@param status EclStatus
---@param tooltip TooltipData
function TooltipHandler.OnStatusTooltip(character, status, tooltip)
	local statusType = status.StatusType or GameHelpers.Status.GetStatusType(status.StatusId)
	local gameSettings = GameSettingsManager.GetSettings()
	if Features.StatusDisplaySource and not gameSettings.Client.HideStatusSource then
		local equipmentStatuses = GameHelpers.Character.GetEquipmentOnEquipStatuses(character, true)
		local sourceName = nil
		if GameHelpers.IsValidHandle(status.StatusSourceHandle) then
			local source = GameHelpers.TryGetObject(status.StatusSourceHandle)
			if source then
				local displayName = GameHelpers.GetDisplayName(source)
				sourceName = displayName
				if source.MyGuid == character.MyGuid then
					local itemSourceData = equipmentStatuses[status.StatusId]
					if itemSourceData then
						local itemName = GameHelpers.GetDisplayName(itemSourceData.Item)
						local rarityColor = Data.Colors.Rarity[itemSourceData.Item.Stats.ItemTypeReal] or Data.Colors.Common.White
						sourceName = string.format("<font color='%s'>%s</font>", rarityColor, itemName)
					end
				end

				if sourceName == displayName then
					if _PermanentStatuses[character.NetID] and _PermanentStatuses[character.NetID][status.StatusId] then
						sourceName = string.format("%s (<font color='%s'>%s</font>)", displayName, Data.Colors.FormatStringColor.Gold, GameHelpers.GetTranslatedString("h4f8643fega7ebg4749g9e93gb66b65102545", "Permanent"))
					end
				end
			end
		end

		if not sourceName and _PermanentStatuses[character.NetID] and _PermanentStatuses[character.NetID][status.StatusId] then
			local displayName = GameHelpers.GetDisplayName(character)
			sourceName = string.format("%s (<font color='%s'>%s</font>)", displayName, Data.Colors.FormatStringColor.Gold, GameHelpers.GetTranslatedString("h4f8643fega7ebg4749g9e93gb66b65102545", "Permanent"))
		end

		if not sourceName and equipmentStatuses[status.StatusId] then
			local itemSourceData = equipmentStatuses[status.StatusId]
			if itemSourceData then
				local itemName = GameHelpers.GetDisplayName(itemSourceData.Item)
				local rarityColor = Data.Colors.Rarity[itemSourceData.Item.Stats.ItemTypeReal] or Data.Colors.Common.White
				sourceName = string.format("<font color='%s'>%s</font>", rarityColor, itemName)
			end
		end

		if not StringHelpers.IsNullOrWhitespace(sourceName) then
			local description = tooltip:GetDescriptionElement({Type="StatusDescription", Label=""})
			if not StringHelpers.IsNullOrWhitespace(description.Label) then
				description.Label = description.Label .. "<br>"
			end
			description.Label = string.format("%s%s", description.Label or "", LocalizedText.Tooltip.StatusSource:ReplacePlaceholders(sourceName))
		end
	end
	if Features.DisplayStatusDebugInfo then
		local idText = ""
		-- if status.StatusType ~= status.StatusId then
		-- 	idText = string.format("<font color='%s'>%s</font><br><font color='%s' size='18'>%s</font>", Data.Colors.Common.AztecGold, status.StatusId, Data.Colors.Common.Bittersweet, status.StatusType)
		-- else
		-- 	idText = string.format("<font color='%s'>%s</font>", Data.Colors.Common.AztecGold, status.StatusId)
		-- end
		idText = string.format("<font color='%s'>%s</font><br><font color='%s' size='18'>[%s]</font>", Data.Colors.Common.AztecGold, status.StatusId, Data.Colors.Common.Bittersweet, status.StatusType)
		local description = tooltip:GetDescriptionElement({Type="StatusDescription", Label=""})
		if not StringHelpers.IsNullOrWhitespace(description.Label) then
			description.Label = description.Label .. "<br>"
		end
		description.Label = string.format("%s%s", description.Label or "", idText)
	end
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

	--Better tooltip sorting
	if gameSettings.Client.FixStatusTooltips then
		local maluses = tooltip:GetElements("StatusMalus")
		local bonuses = tooltip:GetElements("StatusBonus")
		tooltip:RemoveElements("StatusMalus")
		tooltip:RemoveElements("StatusBonus")
		table.sort(maluses, _AlphabeticalCaseInsensitiveLabelSort)
		table.sort(bonuses, _AlphabeticalCaseInsensitiveLabelSort)
		tooltip:AppendElements(bonuses)
		tooltip:AppendElements(maluses)
	end

	local immunityElements = tooltip:GetElements("StatusImmunity")
	local len = #immunityElements
	if len > 0 then
		tooltip:RemoveElements("StatusImmunity")
		--Place immunities at the bottom of the tooltips, but only sort/check them if there's more than 1 element
		if len > 1 then
			table.sort(immunityElements, _AlphabeticalCaseInsensitiveLabelSort)
			if gameSettings.Client.CondenseStatusTooltips then
				local immunitiesCombined = {Type="StatusImmunity", Label=""}
				local preserveElements = {}
				local immunities = {}
				local replaceText = StringHelpers.Replace(LocalizedText.Tooltip.ImmunityTo.Value, " [1]<br>", "")
				for i=1,len do
					local v = immunityElements[i]
					if string.find(v.Label, replaceText) then
						local text = StringHelpers.Trim(StringHelpers.Replace(StringHelpers.Replace(v.Label, replaceText, ""), "<br>", ""))
						if not StringHelpers.IsNullOrWhitespace(text) then
							if string.sub(text, -1) == "." then
								text = string.sub(text, 1, string.len(text)-1)
							end
							immunities[#immunities+1] = text
						else
							preserveElements[#preserveElements+1] = v
						end
					else
						preserveElements[#preserveElements+1] = v
					end
				end
				table.sort(immunities, function(a,b)
					return a:lower() < b:lower()
				end)
				immunitiesCombined.Label = LocalizedText.Tooltip.ImmunityTo:ReplacePlaceholders(StringHelpers.Join(", ", immunities))
				if not StringHelpers.IsNullOrWhitespace(immunitiesCombined.Label) then
					preserveElements[#preserveElements+1] = immunitiesCombined
				end
				if #preserveElements > 0 then
					immunityElements = preserveElements
				end
			end
		end
		tooltip:AppendElements(immunityElements)
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