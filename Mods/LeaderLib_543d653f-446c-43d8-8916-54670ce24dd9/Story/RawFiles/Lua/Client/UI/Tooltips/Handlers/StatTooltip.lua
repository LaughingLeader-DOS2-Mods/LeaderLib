---@module LeaderLibStatTooltipHandler
---@param character EclCharacter
---@param stat string
---@param tooltip TooltipData
function TooltipHandler.OnStatTooltip(character, stat, tooltip)
	--fprint(LOGLEVEL.DEFAULT, "[OnStatTooltip:%s]\n%s", stat, Ext.JsonStringify(tooltip.Data))
	if stat == "APRecovery" then
		local stat = Ext.GetStat(character.Stats.Name)
		for i,element in ipairs(tooltip:GetElements("StatsAPBase")) do
			if i == 1 then
				element.Label = LocalizedText.Tooltip.StatBase:ReplacePlaceholders(stat.APMaximum)
			elseif i == 2 then
				element.Label = LocalizedText.Tooltip.StatBase:ReplacePlaceholders(stat.APStart)
			elseif i == 3 then
				element.Label = LocalizedText.Tooltip.StatBase:ReplacePlaceholders(stat.APRecovery)
			end
		end
	end
end