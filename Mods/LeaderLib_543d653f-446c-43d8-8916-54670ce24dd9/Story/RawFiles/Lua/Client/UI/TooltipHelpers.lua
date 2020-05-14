
--- Formats a damage range typically returned from Game.Math.GetSkillDamageRange
---@param damageRange table<string,number[]>
---@return string
local function FormatDamageRange(damageRange)
	if damageRange ~= nil then
		local damageTexts = {}
		local totalDamageTypes = 0
		for damageType,damage in pairs(damageRange) do
			local min = damage[1]
			local max = damage[2]
			if min ~= nil and max ~= nil then
				if max == min then
					table.insert(damageTexts, Game.GetDamageText(damageType, string.format("%i", max)))
				else
					table.insert(damageTexts, Game.GetDamageText(damageType, string.format("%i-%i", min, max)))
				end
				totalDamageTypes = totalDamageTypes + 1
			end
		end
		if totalDamageTypes > 0 then
			if totalDamageTypes > 1 then
				return Common.StringJoin(", ", damageTexts)
			else
				return damageTexts[1]
			end
		end
	end
	return ""
end

UI.Tooltip.FormatDamageRange = FormatDamageRange