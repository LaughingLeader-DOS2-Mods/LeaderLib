if TooltipHandler == nil then
	TooltipHandler = {}
end

---@type table<string,TagTooltipData>
TooltipHandler.TagTooltips = {}
TooltipHandler.HasTagTooltipData = false
---@type EclItem
TooltipHandler.LastItem = nil

TooltipHandler.ChaosDamagePattern = "<font color=\"#C80030\">([%d-%s]+)</font>"
---RootTemplate -> Skill -> Enabled
---@type table<string,table<string,boolean>>
TooltipHandler.SkillBookAssociatedSkills = {}

---@class TagTooltipData
---@field Title TranslatedString
---@field Description TranslatedString

---Registers a tag to display on item tooltips.
---@param tag string
---@param title TranslatedString
---@param description TranslatedString
function TooltipHandler.RegisterItemTooltipTag(tag, title, description)
	local data = {}
	if title ~= nil then
		data.Title = title
	end
	if description ~= nil then
		data.Description = description
	end
	TooltipHandler.TagTooltips[tag] = data
	TooltipHandler.HasTagTooltipData = true
end

if not UI then
	UI = {}
end

---Deprecated
---@see TooltipHandler.RegisterItemTooltipTag
UI.RegisterItemTooltipTag = TooltipHandler.RegisterItemTooltipTag

---@param tooltip TooltipData
function TooltipHandler.OnGenericTooltip(tooltip)
	if tooltip.Data.UIType == Data.UIType.hotBar and string.find(tooltip.Data.Text, "Toggle Chat") then
		tooltip:MarkDirty()
		tooltip.Data.AllowDelay = false
		--tooltip.Data.Text = tooltip.Data.Text .. "<br>This is appended text! Yahoo!"
		if tooltip:IsExpanded() then
			tooltip.Data.Text = "Toggle Chat<br>Global chat was disabled before release ;("
		end
	end
end

---@param tooltip TooltipData
function TooltipHandler.OnAbilityTooltip(character, stat, tooltip)
	if Vars.DebugMode then
		PrintDebug(stat, Common.JsonStringify(tooltip.Data))
	end
end

Ext.Require("Client/UI/Tooltips/Handlers/ItemTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/SkillTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/StatusTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/StatTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/CustomStatTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/RuneTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/WorldTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/TooltipFormatting.lua")

Ext.RegisterListener("SessionLoaded", function()
	Game.Tooltip.RegisterListener("Item", nil, TooltipHandler.OnItemTooltip)
	Game.Tooltip.RegisterListener("Skill", nil, HotbarFixer.UpdateSkillRequirements)
	Game.Tooltip.RegisterListener("Skill", nil, TooltipHandler.OnSkillTooltip)
	Game.Tooltip.RegisterListener("Status", nil, TooltipHandler.OnStatusTooltip)
	Game.Tooltip.RegisterListener("Stat", nil, TooltipHandler.OnStatTooltip)
	if Vars.DebugMode then
		Game.Tooltip.RegisterListener("Rune", nil, TooltipHandler.OnRuneTooltip)
		--Game.Tooltip.RegisterListener("Talent", nil, OnTalentTooltip)
		Game.Tooltip.RegisterListener("CustomStat", nil, TooltipHandler.OnCustomStatTooltip)
		--Game.Tooltip.RegisterListener("Ability", nil, TooltipHandler.OnAbilityTooltip)
		Game.Tooltip.RegisterListener("Generic", TooltipHandler.OnGenericTooltip)
	end


	-- if Vars.DebugMode then
	-- 	Game.Tooltip.RegisterListener(nil, nil, function (...)
	-- 		local params =  {...}
	-- 		Ext.Dump(params)
	-- 	end)
	-- end
end)