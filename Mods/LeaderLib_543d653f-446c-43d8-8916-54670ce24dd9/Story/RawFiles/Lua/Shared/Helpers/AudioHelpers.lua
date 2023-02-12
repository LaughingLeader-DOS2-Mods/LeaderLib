if GameHelpers.Audio == nil then
	GameHelpers.Audio = {}
end

local _ISCLIENT = Ext.IsClient()
local _type = type

---@alias SoundObjectID "Global"|"Music"|"Ambient"|"HUD"|"GM"|"Player1"|"Player2"|"Player3"|"Player4"

---@class LeaderLib_GameHelpers_Audio_PlaySound
---@field Target NetId|string
---@field Event string
---@field Position number
---@field TargetIsNetID boolean
---@field IsItem boolean

---@param target ObjectParam|SoundObjectID Object or built-in sound object ID
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
				data.IsItem = GameHelpers.Ext.ObjectIsItem(obj)
			end
		end
		if not specificPlayer then
			GameHelpers.Net.Broadcast("LeaderLib_GameHelpers_Audio_PlaySound", data)
		else
			GameHelpers.Net.PostToUser(specificPlayer, "LeaderLib_GameHelpers_Audio_PlaySound", data)
		end
	else
		soundPosition = soundPosition or 0
		local t = type(target)
		if t == "string" or GameHelpers.IsValidHandle(target) then
			Ext.Audio.PostEvent(target, sound, soundPosition)
		elseif ((t == "userdata" or t == "table") and target.Handle) then
			Ext.Audio.PostEvent(target.Handle, sound, soundPosition)
		else
			ferror("Wrong target type(%s)[%s] - Should be a handle, string, or object", t, target)
		end
	end
end

---@class LeaderLib_GameHelpers_Audio_PlaySoundForAllPlayers
---@field Event string
---@field Position number
---@field SoundObjectID string|nil Optional sound object ID to use, such as "HUD"

---@param sound string Sound event ID
---@param soundPosition number|nil Position in audio track
---@param soundObjectID SoundObjectID|nil Optional sound object ID to use, such as "HUD"
function GameHelpers.Audio.PlaySoundForAllPlayers(sound, soundPosition, soundObjectID)
	if not _ISCLIENT then
		local data = {
			Event=sound,
			Position=soundPosition,
			SoundObjectID=soundObjectID
		}
		GameHelpers.Net.Broadcast("LeaderLib_GameHelpers_Audio_PlaySoundForAllPlayers", data)
	else
		soundPosition = soundPosition or 0
		if not soundObjectID then
			local client = Client:GetCharacter()
			if client then
				Ext.Audio.PostEvent(client.Handle, sound, soundPosition)
			else
				Ext.Audio.PostEvent("GM", sound, soundPosition)
			end
		else
			Ext.Audio.PostEvent(soundObjectID, sound, soundPosition)
		end
	end
end

---@class LeaderLib_GameHelpers_Audio_PlayExternalSound
---@field Target NetId|string
---@field Event string
---@field Path string
---@field CodecId integer|nil
---@field TargetIsNetID boolean
---@field IsItem boolean

---@param target ObjectParam|SoundObjectID Object or built-in sound object ID
---@param eventName string Event to trigger
---@param path string Audio file path (relative to data directory)
---@param codecId integer|nil
---@param specificPlayer CharacterParam|nil
function GameHelpers.Audio.PlayExternalSound(target, eventName, path, codecId, specificPlayer)
	if not _ISCLIENT then
		local data = {Target=target, Event=eventName, Path=path, CodecId=codecId}
		local t = _type(target)
		if t == "userdata" or (t == "string" and StringHelpers.IsUUID(target)) then
			local obj = GameHelpers.TryGetObject(target)
			if obj then
				data.Target = obj.NetID
				data.TargetIsNetID = true
				data.IsItem = GameHelpers.Ext.ObjectIsItem(obj)
			end
		end
		if not specificPlayer then
			GameHelpers.Net.Broadcast("LeaderLib_GameHelpers_Audio_PlayExternalSound", data)
		else
			GameHelpers.Net.PostToUser(specificPlayer, "LeaderLib_GameHelpers_Audio_PlayExternalSound", data)
		end
	else
		soundPosition = soundPosition or 0
		local t = type(target)
		if t == "string" or GameHelpers.IsValidHandle(target) then
			Ext.Audio.PlayExternalSound(target, eventName, path, codecId or 0)
		elseif ((t == "userdata" or t == "table") and target.Handle) then
			Ext.Audio.PlayExternalSound(target.Handle, eventName, path, codecId or 0)
		else
			ferror("Wrong target type(%s)[%s] - Should be a handle, string, or object", t, target)
		end
	end
end

if _ISCLIENT then
	GameHelpers.Net.Subscribe("LeaderLib_GameHelpers_Audio_PlaySound", function (e, data)
		local target = data.Target --[[@as string|ComponentHandle]]
		if data.TargetIsNetID then
			local obj = nil
			if data.IsItem then
				obj = GameHelpers.GetItem(target, "EclItem")
			else
				obj = GameHelpers.GetCharacter(target, "EclCharacter")
			end
			if obj then
				target = obj.Handle
			else
				target = "GM"
			end
		end
		GameHelpers.Audio.PlaySound(target, data.Event, data.Position)
	end)

	GameHelpers.Net.Subscribe("LeaderLib_GameHelpers_Audio_PlayExternalSound", function (e, data)
		local target = data.Target --[[@as string|ComponentHandle]]
		if data.TargetIsNetID then
			local obj = nil
			if data.IsItem then
				obj = GameHelpers.GetItem(target, "EclItem")
			else
				obj = GameHelpers.GetCharacter(target, "EsvCharacter")
			end
			if obj then
				target = obj.Handle
			else
				target = "GM"
			end
		end
		GameHelpers.Audio.PlayExternalSound(target, data.Event, data.Path, data.CodecId or 0)
	end)

	Ext.RegisterNetListener("LeaderLib_GameHelpers_Audio_PlaySoundForAllPlayers", function (cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			assert(data.Event ~= nil, "Event property must be set")
			GameHelpers.Audio.PlaySoundForAllPlayers(data.Event, data.Position, data.SoundObjectID)
		end
	end)
end