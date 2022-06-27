--[[
This script allows tooltips to be re-rendered when shift is pressed or released,
allowing mods to alter how much text/info they provide in a tooltip.

Mods should check tooltip.IsExpanded() when determining which text to write, 
and call tooltip.MarkDirty() when the current tooltip can be changed when the key is pressed or released.
]]

if not TooltipExpander then
	---@see TooltipExpander#MarkDirty
	---@see TooltipExpander#IsExpanded
	TooltipExpander = {}
end

local dirty = false
local rebuildingTooltip = false
local keyboardKey = "SplitItemToggle"--Data.Input.SplitItemToggle
local controllerKey = "ToggleMap"

TooltipExpander.CallData = {
	---@type integer
	UI = nil,
	---@type table
	Args = nil,
	---@type string
	LastCall = nil,
	RebuildingTooltip = false,
}

---Signals to the expander that pressing or releasing the expand key will cause the current visible tooltip to re-render.
function TooltipExpander.MarkDirty()
	dirty = true
end

---@return boolean
function TooltipExpander.IsDirty()
	return dirty
end

---Whether or not the tooltip should be expanded. Check this when setting up tooltip elements.
---@return boolean
function TooltipExpander.IsExpanded()
	if GameSettings.Settings.Client.AlwaysExpandTooltips then
		return true
	end
	if not Vars.ControllerEnabled then
		return Input.IsPressed(keyboardKey)
	else
		return Input.IsPressed(controllerKey)
	end
end

local function SaveTooltipData(ui, call, ...)
	dirty = false
	if not rebuildingTooltip then
		TooltipExpander.CallData.UI = ui:GetTypeId()
		TooltipExpander.CallData.Args = {...}
		TooltipExpander.CallData.LastCall = call
	end
	rebuildingTooltip = false
end

local calls = {
	"showSkillTooltip",
	"showStatusTooltip",
	"showItemTooltip",
	"showStatTooltip",
	"showAbilityTooltip",
	"showTalentTooltip",
	"showTagTooltip",
	"showCustomStatTooltip",
	"showRuneTooltip",
	"showTooltip",
}

for i,v in pairs(calls) do
	Ext.RegisterUINameCall(v, SaveTooltipData, "Before")
end

local controller_calls = {
	"itemDollOver",
	"overItem",
	"refreshTooltip",
	"requestAbilityTooltip",
	"requestAttributeTooltip",
	"requestSkillTooltip",
	"requestTagTooltip",
	"requestTalentTooltip",
	"runeSlotOver",
	"selectCustomStat",
	"selectedAttribute",
	"setTooltipPanelVisible",
	"setTooltipVisible",
	"SlotHover",
	"slotOver",
	"showTooltip",
}

for i,v in pairs(controller_calls) do
	Ext.RegisterUINameCall(v, function(ui, call, ...)
		if Vars.ControllerEnabled then
			SaveTooltipData(ui, call, ...)
		end
	end, "Before")
end

local function OnHideTooltip(ui, call, ...)
	dirty = false
	if not rebuildingTooltip then
		TooltipExpander.CallData = {}
	end
end

Ext.RegisterUINameCall("hideTooltip", OnHideTooltip)
--playerInfo/summonInfo.as
Ext.RegisterUINameCall("hidetooltip", OnHideTooltip)

local function RebuildTooltip()
	if dirty then
		if TooltipExpander.CallData.Args ~= nil then
			--if TooltipExpander.CallData.LastCall == "showTooltip" then
			if Game.Tooltip.TooltipHooks.Last.Type == "Generic" then
				rebuildingTooltip = true
				dirty = false
				local ui = Ext.GetUIByType(Data.UIType.tooltip)
				local text, x, y, width, height, side, allowDelay = table.unpack(TooltipExpander.CallData.Args)

				---@type TooltipGenericRequest
				local request = Game.Tooltip.RequestProcessor.CreateRequest()
				request.Type = "Generic"
				request.Text = text
				request.UIType = TooltipExpander.CallData.UI
				request.X = x
				request.Y = y
				request.Width = width
				request.Height = height
				request.Side = side
				request.AllowDelay = allowDelay

				local this = ui:GetRoot()
				if this and this.tf then
					request.AllowDelay = this.tf.allowDelay
					request.BackgroundType = this.tf.bg_mc and this.tf.bg_mc.visible == true and 0 or 1
				end

				local tooltip = Game.Tooltip.TooltipData:Create(request)
				Game.Tooltip.TooltipHooks:NotifyListeners("Generic", nil, request, tooltip)

				if this and this.tf then
					this.tf.shortDesc = tooltip.Data.Text

					if this.tf.setText then
						this.tf.setText(tooltip.Data.Text,tooltip.Data.BackgroundType or 0)
					else
						Ext.PrintError(this.tf.name)
					end

					this.checkTooltipBoundaries(this.getTooltipWidth(),this.getTooltipHeight(), tooltip.Data.X + this.frameSpacing, tooltip.Data.Y + this.frameSpacing)

					if tooltip.Data.BackgroundType and tooltip.Data.BackgroundType > 0 and tooltip.Data.BackgroundType < 5 then
						ui:ExternalInterfaceCall("keepUIinScreen", true)
					else
						ui:ExternalInterfaceCall("keepUIinScreen", false)
					end
				end
			elseif TooltipExpander.CallData.UI then
				local ui = Ext.GetUIByType(TooltipExpander.CallData.UI)
				if ui then
					rebuildingTooltip = true
					dirty = false
					ui:ExternalInterfaceCall("hideTooltip")
					ui:ExternalInterfaceCall(TooltipExpander.CallData.LastCall, table.unpack(TooltipExpander.CallData.Args))
					return
				end
			end
		end
	end
	rebuildingTooltip = false
end

function TooltipExpander.OnShiftKey(pressed)
	--RebuildTooltip()
end

Input.RegisterListener(keyboardKey, function (eventName, pressed, id, inputMap, controllerEnabled)
	RebuildTooltip()
end)
Input.RegisterListener(controllerKey, function(eventName, pressed, id, inputMap, controllerEnabled)
	if controllerEnabled then
		RebuildTooltip()
	end
end)

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
TooltipExpander.TooltipTypeToElement = tooltipTypeToElement

---@param request TooltipRequest
---@param tooltip TooltipData
function TooltipExpander.AppendHelpText(request, tooltip)
	local canShowText = not GameSettings.Settings.Client.AlwaysExpandTooltips and (not Vars.ControllerEnabled or Vars.DebugMode)
	if canShowText and TooltipExpander.IsDirty() then
		local keyText = not Vars.ControllerEnabled and LocalizedText.Input.Shift.Value or LocalizedText.Input.Select.Value
		if request.Type == "Generic" then
			local format = "<br><br><p align='center'><font color='#44CC00'>%s</font></p>"
			if TooltipExpander.IsExpanded() then
				tooltip.Data.Text = tooltip.Data.Text .. string.format(format, LocalizedText.Tooltip.ExpanderActive:ReplacePlaceholders(keyText))
			else
				tooltip.Data.Text = tooltip.Data.Text .. string.format(format, LocalizedText.Tooltip.ExpanderInactive:ReplacePlaceholders(keyText))
			end
		else
			local elementType = tooltipTypeToElement[request.Type]
			local element = tooltip:GetLastElement(elementType)
			--Create a description tooltip element if one doesn't exist
			if element == nil then
				local spec = Game.Tooltip.TooltipSpecs[elementType]
				if spec then
					element = {}
					for _,field in pairs(spec) do
						local fieldName = field[1]
						local t = field[2]
						if t == "string" then
							element[fieldName] = ""
						elseif t == "number" then
							element[fieldName] = 0
						elseif t == "boolean" then
							element[fieldName] = false
						end
					end
				end
			end
			if element then
				local target = element.Label or element.Description
				if target then
					local nextText = target
					local format = "<br><p align='center'><font color='#44CC00'>%s</font></p>"
					if not string.find(nextText, "<br>", #nextText-5, true) then
						format = "<br>"..format
					end
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


Ext.RegisterListener("SessionLoaded", function ()
	---Whether or not the tooltip should be expanded. Check this when setting up tooltip elements.
	---@return boolean
	Game.Tooltip.TooltipData.IsExpanded = function(self)
		return TooltipExpander.IsExpanded()
	end

	---Signals to the tooltip expander that pressing or releasing the expand key will cause the current visible tooltip to re-render.
	Game.Tooltip.TooltipData.MarkDirty = function(self)
		return TooltipExpander.MarkDirty()
	end

	Game.Tooltip.RegisterListener(nil, nil, function (request, tooltip)
		TooltipExpander.AppendHelpText(request, tooltip)
	end)
end)