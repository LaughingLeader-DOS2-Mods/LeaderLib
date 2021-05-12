--[[
This script allows tooltips to be re-rendered when shift is pressed or released,
allowing mods to alter how much text/info they provide in a tooltip.

Mods should check TooltipExpander.IsExpanded() when determining which text to write, 
and call TooltipExpander.MarkDirty() when the current tooltip can be changed when the key is pressed or released.
]]

if not TooltipExpander then
	---@see TooltipExpander#MarkDirty
	---@see TooltipExpander#IsExpanded
	TooltipExpander = {}
end

local dirty = false
local rebuildingTooltip = false
local keyboardKey = Data.Input.SplitItemToggle
local controllerKey = Data.Input.ToggleMap

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

local function RebuildTooltip(eventName, pressed, id, inputMap, controllerEnabled)
	if dirty then
		if TooltipExpander.CallData.Args ~= nil then
			if TooltipExpander.CallData.LastCall == "showTooltip" then
				rebuildingTooltip = true
				dirty = false
				local ui = Ext.GetUIByType(Data.UIType.tooltip)
				local text, x, y, width, height, side, allowDelay = table.unpack(TooltipExpander.CallData.Args)

				---@type GenericTooltipRequest
				local request = {
					Type = "Generic",
					Text = text,
					CallingUI = TooltipExpander.CallData.UI,
					X = x,
					Y = y,
					Width = width,
					Height = height,
					Side = side,
					AllowDelay = allowDelay
				}

				local this = ui:GetRoot()
				if this and this.tf then
					request.AllowDelay = this.tf.allowDelay
					request.BackgroundType = this.tf.bg_mc.visible == true and 0 or 1
				end

				local tooltip = Game.Tooltip.TooltipData:Create(request)
				Game.Tooltip.TooltipHooks:NotifyListeners("Generic", nil, request, tooltip)

				if this and this.tf then
					this.tf.shortDesc = tooltip.Data.Text
					this.tf.setText(tooltip.Data.Text,tooltip.Data.BackgroundType or 0)

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

Input.RegisterListener(keyboardKey, RebuildTooltip)
Input.RegisterListener(controllerKey, function(eventName, pressed, id, inputMap, controllerEnabled)
	if controllerEnabled then
		RebuildTooltip(eventName, pressed, id, inputMap, controllerEnabled)
	end
end)