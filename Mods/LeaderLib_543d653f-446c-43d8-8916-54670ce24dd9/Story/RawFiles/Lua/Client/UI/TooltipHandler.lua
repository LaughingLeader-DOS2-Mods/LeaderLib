---@param item EsvItem
---@param tooltip TooltipData
local function OnItemTooltip(item, tooltip)
	if item ~= nil then
		-- Resistance Penetration display
		if item:HasTag("LeaderLib_HasResistancePenetration") then
			local tagsCheck = {}
			for _,damageType in Data.DamageTypes:Get() do
				local tags = Data.ResistancePenetrationTags[damageType]
				if tags ~= nil then
					local totalResPen = 0
					for i,tagEntry in ipairs(tags) do
						if item:HasTag(tagEntry.Tag) then
							totalResPen = totalResPen + tagEntry.Amount
							tagsCheck[#tagsCheck+1] = tagEntry.Tag
						end
					end

					if totalResPen > 0 then
						local tString = LocalizedText.ItemBoosts.ResistancePenetration
						local resistanceText = GameHelpers.GetResistanceNameFromDamageType(damageType)
						local result = tString:ReplacePlaceholders(GameHelpers.GetResistanceNameFromDamageType(damageType))
						print(tString.Value, resistanceText, totalResPen, result)
						local element = {
							Type = "ResistanceBoost",
							Label = result,
							Value = totalResPen,
						}
						tooltip:AppendElement(element)
					end
				end
			end
			--print("ResPen tags:", Ext.JsonStringify(tagsCheck))
		end
	end
end

---@param character EsvCharacter
---@param status EsvStatus
---@param tooltip TooltipData
local function OnStatusTooltip(character, status, tooltip)

end

local function SessionLoaded()
	Game.Tooltip.RegisterListener("Item", nil, OnItemTooltip)
end

Ext.RegisterListener("SessionLoaded", SessionLoaded)

local function EnableTooltipOverride()
	--Ext.AddPathOverride("Public/Game/GUI/tooltip.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/tooltip.swf")
	Ext.AddPathOverride("Public/Game/GUI/LSClasses.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LSClasses_Fixed.swf")
	--Ext.AddPathOverride("Public/Game/GUI/tooltipHelper_kb.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/tooltipHelper_kb_Fixed.swf")
	Ext.Print("[LeaderLib] Enabled tooltip override.")
end

-- Ext.RegisterListener("ModuleLoading", EnableTooltipOverride)
-- Ext.RegisterListener("ModuleLoadStarted", EnableTooltipOverride)
-- Ext.RegisterListener("ModuleResume", EnableTooltipOverride)
-- Ext.RegisterListener("SessionLoading", EnableTooltipOverride)
-- Ext.RegisterListener("SessionLoaded", EnableTooltipOverride)