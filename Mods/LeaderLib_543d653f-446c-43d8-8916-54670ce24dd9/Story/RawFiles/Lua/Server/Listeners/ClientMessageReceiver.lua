Ext.RegisterNetListener("LeaderLib_ToggleChainGroup", function(cmd, payload)
	print(cmd, payload)
	---@class ToggleChainGroupData
	---@field Leader UUID
	---@field Target UUID[]
	---@field TotalChained integer
	---@field TotalUnchained integer
	local data = Common.JsonParse(payload)
	if data then
		local leader = Ext.GetCharacter(data.Leader)
		print(leader, leader and leader.MyGuid or "nil")
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