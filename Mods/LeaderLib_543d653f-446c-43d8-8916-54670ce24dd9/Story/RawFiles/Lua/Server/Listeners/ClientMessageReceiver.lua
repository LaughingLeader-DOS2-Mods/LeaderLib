Ext.RegisterNetListener("LeaderLib_ToggleChainGroup", function(cmd, payload)
	---@class ToggleChainGroupData
	---@field Leader Guid
	---@field Target Guid[]
	---@field TotalChained integer
	---@field TotalUnchained integer
	local data = Common.JsonParse(payload)
	if data then
		local leader = GameHelpers.GetCharacter(data.Leader)
		if leader then
			if data.TotalChained > data.TotalUnchained then
				Osi.LeaderLib_LifeHacks_ChainToggle(leader.MyGuid, Osi.CharacterGetReservedUserID(leader.MyGuid), 0)
			else
				Osi.LeaderLib_LifeHacks_ChainToggle(leader.MyGuid, Osi.CharacterGetReservedUserID(leader.MyGuid), 1)
			end
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_RefreshCharacterSheet", function(cmd, uuid)
	Osi.CharacterAddAbilityPoint(uuid, 0)
	Osi.CharacterAddCivilAbilityPoint(uuid, 0)
	Osi.CharacterAddAttributePoint(uuid, 0)
	Osi.CharacterAddAttribute(uuid, "Dummy", 0)
end)

Ext.RegisterNetListener("LeaderLib_DeferUICapture", function(cmd, userId)
	if userId then
		userId = tonumber(userId)
	end
	Timer.StartOneshot(string.format("LeaderLib_DeferUICapture_%s", userId), 1, function()
		GameHelpers.Net.PostToUser(userId, "LeaderLib_CaptureActiveUIs", "")
	end)
end)

Ext.RegisterNetListener("LeaderLib_TeleportToPosition", function(cmd, payload)
	local data = Common.JsonParse(payload)
	fassert(data ~= nil, "[%s] Payload (%s) resulted in a nil table.", cmd, payload)
	fassert(data.Target ~= nil, "[%s] A valid Target parameter is required. Payload:\n%s", cmd, payload)
	fassert(data.Pos ~= nil, "[%s] A valid Pos parameter is required. Payload:\n%s", cmd, payload)
	local object = GameHelpers.TryGetObject(data.Target)
	fassert(object ~= nil, "[%s] Object returned by the Target parameter is nil. Payload:\n%s", cmd, payload)
	local x,y,z = table.unpack(data.Pos)
	Osi.LeaderLib_Behavior_TeleportTo(object.MyGuid, x, y, z)
	Osi.CharacterMoveToPosition(object.MyGuid, x, y, z, 1, "")
end)

Ext.RegisterNetListener("LeaderLib_CharacterStatusText", function(cmd, payload)
	local data = Common.JsonParse(payload)
	fassert(data ~= nil, "[%s] Payload (%s) resulted in a nil table.", cmd, payload)
	fassert(data.Target ~= nil, "[%s] A valid Target parameter is required. Payload:\n%s", cmd, payload)
	fassert(data.Text ~= nil, "[%s] A valid Text parameter is required. Payload:\n%s", cmd, payload)
	Osi.CharacterStatusText(GameHelpers.GetUUID(data.Target), data.Text)
end)

Ext.RegisterNetListener("LeaderLib_SaveDebugInfo_Run", function(cmd, payload)
	SettingsManager.GetLeaderLibSettings().Global:InvokeButton("LeaderLib_SaveDebugInfo")
end)