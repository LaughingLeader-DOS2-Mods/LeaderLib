
---@param character EclCharacter
---@param stat CustomStatData
---@param tooltip TooltipData
function TooltipHandler.OnCustomStatTooltip(character, stat, tooltip)
	if Vars.DebugMode then
		if stat.ID == "Lucky" then
			local element = tooltip:GetElement("AbilityDescription")
			local value = stat:GetValue(character)
			if value > 0 then
				element.CurrentLevelEffect = string.format("Level %s: Gain %s%% more loot.", value or 1, 100)
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