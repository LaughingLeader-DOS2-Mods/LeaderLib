---@param item EsvItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	if item ~= nil then
		-- Resistance Penetration display
		if item:HasTag("LeaderLib_HasResistancePenetration") then
			for _,damageType in Data.DamageTypes:Get() do
				local tags = Data.ResistancePenetrationTags[damageType]
				if tags ~= nil then
					local totalResPen = 0
					for i,tagEntry in pairs(tags) do
						if item:HasTag(tagEntry.Tag) then
							totalResPen = totalResPen + tagEntry.Amount
						end
					end

					if totalResPen > 0 then
						local element = {
							Type = "OtherStatBoost",
							Label = LocalizedText.ItemBoosts.ResistancePenetration:ReplacePlaceholders(GameHelpers.GetResistanceNameFromDamageType(damageType)),
							Value = totalResPen,
						}
						tooltip:AppendElement(element)
					end
				end
			end
		end
	end
end

---@param character EsvCharacter
---@param status EsvStatus
---@param tooltip TooltipData
local function OnStatusTooltip(character, status, tooltip)
	print(status.StatusId)
	print(LeaderLib.Common.Dump(tooltip.Data))
	if status.StatusId == "LLENEMY_UPGRADE_INFO" then


	end
end

return {
	Init = function()
		Game.Tooltip.RegisterListener("Item", nil, OnItemTooltip)
		--Game.Tooltip.RegisterListener("Status", nil, OnStatusTooltip)
	end
}