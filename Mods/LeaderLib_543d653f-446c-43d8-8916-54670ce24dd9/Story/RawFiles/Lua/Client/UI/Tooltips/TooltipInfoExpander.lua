if not TooltipExpander then
	TooltipExpander = {}
end

local dirty = false
TooltipExpander.IsExpanded = false
local rebuildingTooltip = false

TooltipExpander.CallData = {
	---@type integer
	UI = nil,
	---@type table
	Args = nil,
	---@type string
	LastCall = nil,
	RebuildingTooltip = false,
}

---Signals to the expander that pressing shift will cause the current visible tooltip to re-render.
function TooltipExpander.MarkDirty()
	dirty = true
end

function TooltipExpander.ShowMoreInfo()
	if not Vars.ControllerEnabled then
		return Input.GetKeyStateByID(Data.Input.SplitItemToggle) == true
	else
		return true
	end
end

--[[
This script is an experiment to allow tooltips to be re-rendered when shift is pressed or released,
allowing mods to alter how much text/info they provide in a tooltip.
]]

if Vars.DebugMode then
	local calls = {
		"showSkillTooltip",
		"showStatusTooltip",
		"showItemTooltip",
		"showTooltip",
	}

	for i,v in pairs(calls) do
		Ext.RegisterUINameCall(v, function(ui, call, ...)
			if not rebuildingTooltip then
				TooltipExpander.CallData.UI = ui:GetTypeId()
				TooltipExpander.CallData.Args = {...}
				TooltipExpander.CallData.LastCall = call
			end
			rebuildingTooltip = false
		end)
	end
	
	Ext.RegisterUINameCall("hideTooltip", function(ui, call, ...)
		dirty = false
		if not rebuildingTooltip then
			TooltipExpander.IsExpanded = TooltipExpander.ShowMoreInfo()
			TooltipExpander.CallData = {}
		end
	end)

	-- Left Shift
	Input.RegisterListener(Data.Input.SplitItemToggle, function(eventName, pressed, id, inputMap, controllerEnabled)
		--fprint(LOGLEVEL.DEFAULT, "[LeaderLib:InputEvent] SplitItemToggle dirty(%s) (%s) (%s)", dirty, TooltipExpander.CallData.UI, TooltipExpander.CallData.LastCall)
		TooltipExpander.IsExpanded = pressed
		if dirty then
			if TooltipExpander.CallData.Args ~= nil then
				local ui = Ext.GetUIByType(TooltipExpander.CallData.UI)
				if ui then
					rebuildingTooltip = true
					dirty = false
					ui:ExternalInterfaceCall("hideTooltip")
					ui:ExternalInterfaceCall(TooltipExpander.CallData.LastCall, table.unpack(TooltipExpander.CallData.Args))
				else
					rebuildingTooltip = false
				end
			else
				rebuildingTooltip = false
			end
		end
	end)
end