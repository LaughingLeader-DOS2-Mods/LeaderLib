if TooltipHandler == nil then
	TooltipHandler = {}
end

--Global access for mods
TooltipHandler.Settings = {
	ChaosDamagePattern = "<font color=\"#C80030\">([%d-%s]+)</font>",
	---Skills to always avoid formatting damage text for.
	---@see LeaderLibFeatures#FixChaosDamageDisplay
	IgnoreDamageFixingSkills = {}
}

---@type table<string,TagTooltipData>
TooltipHandler.TagTooltips = {}
TooltipHandler.HasTagTooltipData = false
---@type EclItem
TooltipHandler.LastItem = nil
---RootTemplate -> Skill -> Enabled
---@type table<string,table<string,boolean>>
TooltipHandler.SkillBookAssociatedSkills = {}

---@class TagTooltipData
---@field Title TranslatedString
---@field Description TranslatedString

---Registers a tag to display on item tooltips.
---@param tag string
---@param title TranslatedString|string|fun(tag:string, tooltipType:string):string|nil
---@param description TranslatedString|string|fun(tag:string, tooltipType:string):string|nil
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

Ext.Require("Client/UI/Tooltips/Handlers/ItemTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/SkillTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/StatusTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/StatTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/CustomStatTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/RuneTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/WorldTooltip.lua")
Ext.Require("Client/UI/Tooltips/Handlers/TooltipFormatting.lua")

local function RegisterTooltipHandlers()
	local _r = Game.Tooltip.Register
	_r.Item(TooltipHandler.OnItemTooltip)
	_r.Skill(function (...)
		HotbarFixer.UpdateSkillRequirements(...)
		TooltipHandler.OnSkillTooltip(...)
	end)
	_r.Status(TooltipHandler.OnStatusTooltip)
	_r.Stat(TooltipHandler.OnStatTooltip)

	if Vars.DebugMode then
		_r.Rune(TooltipHandler.OnRuneTooltip)
		_r.CustomStat(TooltipHandler.OnCustomStatTooltip)
		_r.Generic(TooltipHandler.OnGenericTooltip)
		-- _r.Surface(function (character, surfaceType, tooltip)
		-- 	local description = tooltip:GetDescriptionElement()
		-- 	if description then
		-- 		description.Label = description.Label .. "<br><font color='#33FF00'>Water can be transformed into poison with Contamination.</font>"
		-- 	end
		-- end, "Water")
	end
end

if Ext.Version() < 56 then
	Ext.RegisterListener("SessionLoaded",RegisterTooltipHandlers)
else
	Ext.Events.SessionLoaded:Subscribe(RegisterTooltipHandlers, {Priority = 0})
end