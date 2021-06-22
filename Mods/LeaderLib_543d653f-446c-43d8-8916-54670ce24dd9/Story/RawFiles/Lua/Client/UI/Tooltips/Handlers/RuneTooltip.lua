---@param item EclItem
---@param rune StatEntryObject
---@param slot integer
---@param tooltip TooltipData
function TooltipHandler.OnRuneTooltip(item, rune, slot, tooltip)
	if Vars.DebugMode then
		Ext.PrintWarning("OnRuneTooltip", item.StatsId, rune.Name, slot, Ext.JsonStringify(tooltip))
	end
end