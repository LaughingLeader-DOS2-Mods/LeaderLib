Ext.RegisterNetListener("LeaderLib_ToggleChainGroup", function(cmd, payload)
	---@class ToggleChainGroupData
	---@field Leader UUID
	---@field Target UUID[]
	---@field TotalChained integer
	---@field TotalUnchained integer
	local data = Common.JsonParse(payload)
	if data then
		if data.TotalChained > data.TotalUnchained then
			Osi.LeaderLib_LifeHacks_ChainToggle(data.Leader, CharacterGetReservedUserID(data.Leader), 0)
		else
			Osi.LeaderLib_LifeHacks_ChainToggle(data.Leader, CharacterGetReservedUserID(data.Leader), 1)
		end
	end
end)