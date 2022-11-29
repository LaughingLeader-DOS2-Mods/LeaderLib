---@diagnostic disable undefined-field
function QOL.ToggleChainGroup()
	local targetGroupId = -1
	local client = Client:GetCharacter()
	local characters = {}
	local ui = Ext.UI.GetByType(Data.UIType.playerInfo)
	if ui then
		local this = ui:GetRoot()
		if this then
			for i=0,#this.player_array-1 do
				local player_mc = this.player_array[i]
				if player_mc then
					local groupId = player_mc.groupId
					local character = GameHelpers.Client.TryGetCharacterFromDouble(player_mc.characterHandle)
					if character then
						characters[#characters+1] = {
							Group = groupId,
							NetID = character.NetID
						}
						if character.NetID == client.NetID then
							targetGroupId = groupId
						end
					end
				end
			end
		end
	end
	local groupData = {
		Leader = client.NetID,
		Targets = {},
		TotalChained = 0,
		TotalUnchained = 0
	}
	for i,v in pairs(characters) do
		if v.NetID ~= groupData.Leader then
			groupData.Targets[#groupData.Targets+1] = v.NetID
			if v.Group ~= targetGroupId then
				groupData.TotalUnchained = groupData.TotalUnchained + 1
			else
				groupData.TotalChained = groupData.TotalChained + 1
			end
		end
	end
	if groupData.Leader then
		Ext.Net.PostMessageToServer("LeaderLib_ToggleChainGroup", Common.JsonStringify(groupData))
	end
end
---@diagnostic enable

Ext.RegisterUINameCall("LeaderLib_ToggleChainGroup", function(...)
	QOL.ToggleChainGroup()
end)

Input.Subscribe.RawInput("space", function (e)
	if Input.Ctrl then
		QOL.ToggleChainGroup()
		e.Handled = true
	end
end)