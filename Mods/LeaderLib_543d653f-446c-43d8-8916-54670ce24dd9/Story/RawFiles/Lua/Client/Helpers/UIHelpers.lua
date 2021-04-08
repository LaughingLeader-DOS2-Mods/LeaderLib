function UI.ToggleStatusVisibility(visible)
	visible = visible ~= nil and visible or true
	local ui = Ext.GetUIByType(Data.UIType.playerInfo)
	if ui then
		local main = ui:GetRoot()
		if main then
			for i=0,#main.player_array do
				local player_mc = main.player_array[i]
				if player_mc and player_mc.statusHolder_mc then
					player_mc.statusHolder_mc.visible = visible
				end
			end
		end
	end
end

Ext.RegisterNetListener("LeaderLib_UI_SetStatusMCVisibility", function(cmd, payload)
	UI.ToggleStatusVisibility(payload ~= "false")
end)

Ext.RegisterNetListener("LeaderLib_UI_RefreshStatusMCVisibility", function(cmd, payload)
	UI.ToggleStatusVisibility(not GameSettings.Settings.Client.HideStatuses)
end)