if GameHelpers.Tooltip == nil then
	GameHelpers.Tooltip = {}
end


---Replace placeholder text in strings, such as ExtraData, Skill, etc.
---@param str string
---@param character EclCharacter|EsvCharacter Optional character to use for the tooltip.
---@return string
function GameHelpers.Tooltip.ReplacePlaceholders(str, character)
	local status,result = xpcall(ReplacePlaceholders, debug.traceback, str, character)
	if status then
		return result
	else
		Ext.PrintError("[LeaderLib:GameHelpers.Tooltip.ReplacePlaceholders] Error replacing placeholders:")
		Ext.PrintError(result)
		return str
	end
end

--- Formats a damage range typically returned from GameHelpers.Math.GetSkillDamageRange
---@param damageRange table<string,number[]>
---@return string
function GameHelpers.Tooltip.FormatDamageRange(damageRange)
	if damageRange ~= nil then
		local damageTexts = {}
		local totalDamageTypes = 0
		for damageType,damage in pairs(damageRange) do
			local min = damage.Min or damage[1]
			local max = damage.Max or damage[2]
			if min ~= nil and max ~= nil then
				if max == min then
					table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i", max)))
				else
					table.insert(damageTexts, GameHelpers.GetDamageText(damageType, string.format("%i-%i", min, max)))
				end
				totalDamageTypes = totalDamageTypes + 1
			end
		end
		if totalDamageTypes > 0 then
			if totalDamageTypes > 1 then
				return StringHelpers.Join(", ", damageTexts)
			else
				return damageTexts[1]
			end
		end
	end
	return ""
end

if Ext.IsClient() then

local extraPropStatusTurnsPattern = "Set (.+) for (%d+) turn%(s%).-%((%d+)%% Chance%)"

---@param tooltip TooltipData
---@param inputElements table
---@param addColor boolean|nil
function GameHelpers.Tooltip.CondensePropertiesText(tooltip, inputElements, addColor)
	local entries = {}
	for i,v in pairs(inputElements) do
		v.Label = string.gsub(v.Label, "  ", " ")
		local a,b,status,turns,chance = string.find(v.Label, extraPropStatusTurnsPattern)
		if status ~= nil and turns ~= nil and chance ~= nil then
			local color = ""
			tooltip:RemoveElement(v)
			if addColor == true then
				
			end
			table.insert(entries, {Status = status, Turns = turns, Chance = chance, Color = color})
		end
	end
	
	if #entries > 0 then
		local finalStatusText = ""
		local finalTurnsText = ""
		local finalChanceText = ""
		for i,v in pairs(entries) do
			finalStatusText = finalStatusText .. v.Status
			finalTurnsText = finalTurnsText .. v.Turns
			finalChanceText = finalChanceText .. v.Chance.."%"
			if i >= 1 and i < #entries then
				finalStatusText = finalStatusText .. "/"
				finalTurnsText = finalTurnsText .. "/"
				finalChanceText = finalChanceText .. "/"
			end
		end
		return LocalizedText.Tooltip.ExtraPropertiesOnHit:ReplacePlaceholders(finalStatusText, finalTurnsText, finalChanceText)
	end
end

end