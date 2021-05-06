--[[
This script is an experiment to allow tooltips to be re-rendered when shift is pressed or released,
allowing mods to alter how much text/info they provide in a tooltip.
]]

if Vars.DebugMode then
	local lastTooltip = {
		UI = nil,
		Args = nil,
		LastCall = nil,
		RebuildingTooltip = false
	}

	local calls = {
		"showSkillTooltip",
		"showStatusTooltip",
		"showItemTooltip",
		"showTooltip",
	}

	for i,v in pairs(calls) do
		Ext.RegisterUINameCall(v, function(ui, call, ...)
			if not lastTooltip.RebuildingTooltip then
				lastTooltip.UI = ui:GetTypeId()
				lastTooltip.Args = {...}
				lastTooltip.LastCall = call
			end
			lastTooltip.RebuildingTooltip = false
		end)
	end
	
	Ext.RegisterUINameCall("hideTooltip", function(ui, ...)
		if not lastTooltip.RebuildingTooltip then
			lastTooltip.Args = nil
		end
	end)

	Input.RegisterListener("SplitItemToggle", function(eventName, pressed, id, inputMap, controllerEnabled)
		-- Left Shift
		fprint(LOGLEVEL.DEFAULT, "[LeaderLib:InputEvent] SplitItemToggle (%s) (%s) (%s)", lastTooltip.UI, lastTooltip.LastCall, lastTooltip.Args)
		if lastTooltip.Args ~= nil then
			local ui = Ext.GetUIByType(lastTooltip.UI)
			lastTooltip.RebuildingTooltip = true
			ui:ExternalInterfaceCall("hideTooltip")
			ui:ExternalInterfaceCall(lastTooltip.LastCall, table.unpack(lastTooltip.Args))
		end
	end)
end