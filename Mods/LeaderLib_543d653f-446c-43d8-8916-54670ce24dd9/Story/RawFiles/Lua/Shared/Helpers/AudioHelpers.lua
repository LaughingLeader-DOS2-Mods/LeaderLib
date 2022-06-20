local _type = type

if GameHelpers.Audio == nil then
	GameHelpers.Audio = {}
end

local _ISCLIENT = Ext.IsClient()

---@param target ObjectParam|SoundObjectID Object or built-in sound type ID
---@param sound string Sound event ID
---@param soundPosition number|nil Position in audio track
---@param specificPlayer CharacterParam|nil
function GameHelpers.Audio.PlaySound(target, sound, soundPosition, specificPlayer)
	if not _ISCLIENT then
		local data = {Target=target, Event=sound, Position=soundPosition}
		local t = _type(target)
		if t == "userdata" or (t == "string" and StringHelpers.IsUUID(target)) then
			local obj = GameHelpers.TryGetObject(target)
			if obj then
				data.Target = obj.NetID
				data.TargetIsNetID = true
			end
		end
		if not specificPlayer then
			GameHelpers.Net.Broadcast("LeaderLib_GameHelpers_Audio_PlaySound", data)
		else
			GameHelpers.Net.PostToUser(specificPlayer, "LeaderLib_GameHelpers_Audio_PlaySound", data)
		end
	else
		target = target or Client:GetCharacter().Handle
		soundPosition = soundPosition or 0
		Ext.Audio.PostEvent(target, sound, soundPosition)
	end
end

---@param sound string Sound event ID
---@param soundPosition number|nil Position in audio track
function GameHelpers.Audio.PlaySoundForAllPlayers(sound, soundPosition, playerID)
	if not _ISCLIENT then
		local data = {Event=sound, Position=soundPosition}
		GameHelpers.Net.Broadcast("LeaderLib_GameHelpers_Audio_PlaySoundForAllPlayers", data)
	else
		soundPosition = soundPosition or 0
		Ext.Audio.PostEvent(playerID or Client:GetCharacter().Handle, sound, soundPosition)
	end
end

if _ISCLIENT then
	Ext.RegisterNetListener("LeaderLib_GameHelpers_Audio_PlaySound", function (cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			--assert(data.Target ~= nil, "Target property must be set")
			assert(data.Event ~= nil, "Event property must be set")
			local target = data.Target
			if data.TargetIsNetID then
				local obj = GameHelpers.TryGetObject(data.Target)
				if obj then
					target = obj.Handle
				else
					target = "Player1"
				end
			end
			GameHelpers.Audio.PlaySound(target, data.Event, data.Position)
		end
	end)
	Ext.RegisterNetListener("LeaderLib_GameHelpers_Audio_PlaySoundForAllPlayers", function (cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			assert(data.Event ~= nil, "Event property must be set")
			GameHelpers.Audio.PlaySoundForAllPlayers(data.Event, data.Position)
		end
	end)
end