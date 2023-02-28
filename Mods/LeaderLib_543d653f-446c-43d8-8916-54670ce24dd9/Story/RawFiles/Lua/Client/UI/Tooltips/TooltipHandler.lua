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
---@param title TranslatedString|string|(fun(tag:string, tooltipType:string):string)|nil
---@param description TranslatedString|string|(fun(tag:string, tooltipType:string):string)|nil
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
	if OptionsSettingsHooks.IsLeaderLibMenuActive() then
		---@type GenericDescription
		local desc = tooltip:GetDescriptionElement()
		if desc then
			desc.OverrideSize = true
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

Game.Tooltip.Register.Generic(TooltipHandler.OnGenericTooltip)

Game.Tooltip.RegisterRequestListener("Generic", function (request, ui, uiType, event, id, ...)
	if not StringHelpers.IsNullOrWhitespace(request.Text) then
		request.Text = GameHelpers.Tooltip.ReplacePlaceholders(request.Text)
	end
end, "After")

local function RegisterTooltipHandlers()
	local _r = Game.Tooltip.Register
	_r.Item(TooltipHandler.OnItemTooltip)
	_r.Skill(function (...)
		HotbarFixer.UpdateSkillRequirements(...)
		TooltipHandler.OnSkillTooltip(...)
	end)
	_r.Status(TooltipHandler.OnStatusTooltip)
	_r.Stat(TooltipHandler.OnStatTooltip)
	--TODO Need an extender way to get a surface on the client
	--[[ _r.Surface(function (character, surface, tooltip)
		if Features.SurfaceDisplaySource then
			local description = tooltip:GetDescriptionElement({Type="SurfaceDescription", Label=""})
			if not StringHelpers.IsNullOrWhitespace(description.Label) then
				description.Label = description.Label .. "<br>"
			end
			description.Label = string.format("%s%s", description.Label or "", idText)
		end
	end) ]]
	--_r.Generic(TooltipHandler.OnGenericTooltip)

	if Vars.DebugMode then
		_r.Rune(TooltipHandler.OnRuneTooltip)
		_r.CustomStat(TooltipHandler.OnCustomStatTooltip)
		-- _r.Surface(function (character, surfaceType, tooltip)
		-- 	local description = tooltip:GetDescriptionElement()
		-- 	if description then
		-- 		description.Label = description.Label .. "<br><font color='#33FF00'>Water can be transformed into poison with Contamination.</font>"
		-- 	end
		-- end, "Water")
	end
end

Ext.Events.SessionLoaded:Subscribe(RegisterTooltipHandlers, {Priority = 999})