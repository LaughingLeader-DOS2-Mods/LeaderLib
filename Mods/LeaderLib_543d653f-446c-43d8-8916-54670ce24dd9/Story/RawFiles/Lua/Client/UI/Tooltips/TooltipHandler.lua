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

---@param player EclCharacter
---@param tooltip TooltipData
local function OnTalentTooltip(player, talent, tooltip)
	print("OnTalentTooltip", player, talent, Ext.JsonStringify(tooltip.Data))
end

local tooltipTypeToElement = {
	Ability = "AbilityDescription",
	CustomStat = "StatsDescription",
	Item = "ItemDescription",
	Rune = "ItemDescription",
	Skill = "SkillDescription",
	Stat = "StatsDescription",
	Status = "StatusDescription",
	Tag = "TagDescription",
	Talent = "TalentDescription",
}

---@param request TooltipRequest
---@param tooltip TooltipData
function TooltipHandler.OnAnyTooltip(request, tooltip)
	local canShowText = not GameSettings.Settings.Client.AlwaysExpandTooltips and (not Vars.ControllerEnabled or Vars.DebugMode)
	if canShowText and TooltipExpander.IsDirty() then
		if request.Type == "Generic" then
			local format = "<br><br><p align='center'><font color='#44CC00'>%s</font></p>"
			local keyText = not Vars.ControllerEnabled and LocalizedText.Input.Shift.Value or LocalizedText.Input.Select.Value
			if TooltipExpander.IsExpanded() then
				tooltip.Data.Text = tooltip.Data.Text .. string.format(format, LocalizedText.Tooltip.ExpanderActive:ReplacePlaceholders(keyText))
			else
				tooltip.Data.Text = tooltip.Data.Text .. string.format(format, LocalizedText.Tooltip.ExpanderInactive:ReplacePlaceholders(keyText))
			end
		else
			local elementType = tooltipTypeToElement[request.Type]
			local element = tooltip:GetLastElement(elementType)
			if element then
				local target = element.Label or element.Description
				if target then
					local nextText = target
					local format = "<br><p align='center'><font color='#44CC00'>%s</font></p>"
					if not string.find(nextText, "<br>", #nextText-5, true) then
						format = "<br>"..format
					end
					local keyText = not Vars.ControllerEnabled and LocalizedText.Input.Shift.Value or LocalizedText.Input.Select.Value
					if TooltipExpander.IsExpanded() then
						nextText = nextText .. string.format(format, LocalizedText.Tooltip.ExpanderActive:ReplacePlaceholders(keyText))
					else
						nextText = nextText .. string.format(format, LocalizedText.Tooltip.ExpanderInactive:ReplacePlaceholders(keyText))
					end
					if element.Label then
						element.Label = nextText
					elseif element.Description then
						element.Description = nextText
					end
				end
			end
		end
	end
end

---@param tooltip TooltipData
function TooltipHandler.OnGenericTooltip(tooltip)
	if tooltip.Data.CallingUI == Data.UIType.hotBar and tooltip.Data.Text == "Toggle Chat" then
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
		print(stat, Ext.JsonStringify(tooltip.Data))
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
	Game.Tooltip.RegisterListener("Skill", nil, TooltipHandler.OnSkillTooltip)
	Game.Tooltip.RegisterListener("Status", nil, TooltipHandler.OnStatusTooltip)
	Game.Tooltip.RegisterListener("Stat", nil, TooltipHandler.OnStatTooltip)
	if Vars.DebugMode then
		Game.Tooltip.RegisterListener("Rune", nil, TooltipHandler.OnRuneTooltip)
		--Game.Tooltip.RegisterListener("Talent", nil, OnTalentTooltip)
		Game.Tooltip.RegisterListener("CustomStat", nil, TooltipHandler.OnCustomStatTooltip)
		--Game.Tooltip.RegisterListener("Ability", nil, TooltipHandler.OnAbilityTooltip)
	end

	Game.Tooltip.RegisterListener(TooltipHandler.OnAnyTooltip)
	--Game.Tooltip.RegisterListener("Generic", TooltipHandler.OnGenericTooltip)
end)