Ext.RegisterNetListener("LeaderLib_ToggleChainGroup", function(cmd, payload)
	---@class ToggleChainGroupData
	---@field Leader UUID
	---@field Target UUID[]
	---@field TotalChained integer
	---@field TotalUnchained integer
	local data = Common.JsonParse(payload)
	if data then
		local leader = Ext.GetCharacter(data.Leader)
		if leader then
			if data.TotalChained > data.TotalUnchained then
				Osi.LeaderLib_LifeHacks_ChainToggle(leader.MyGuid, CharacterGetReservedUserID(leader.MyGuid), 0)
			else
				Osi.LeaderLib_LifeHacks_ChainToggle(leader.MyGuid, CharacterGetReservedUserID(leader.MyGuid), 1)
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_RefreshCharacterSheet", function(cmd, uuid)
	CharacterAddAbilityPoint(uuid, 0)
	CharacterAddCivilAbilityPoint(uuid, 0)
	CharacterAddAttributePoint(uuid, 0)
	CharacterAddAttribute(uuid, "Dummy", 0)
end)

Ext.RegisterNetListener("LeaderLib_DeferUICapture", function(cmd, userId)
	if userId then
		userId = tonumber(userId)
	end
	Timer.StartOneshot(string.format("LeaderLib_DeferUICapture_%s", userId), 1, function()
		Ext.PostMessageToUser(userId, "LeaderLib_CaptureActiveUIs", "")
	end)
end)