if GameHelpers.Net == nil then GameHelpers.Net = {} end

local _postToUser = Ext.PostMessageToUser
local _broadcast = Ext.BroadcastMessage

if Ext.Version() >= 56 then
	_postToUser = Ext.Net.PostMessageToUser
	_broadcast = Ext.Net.BroadcastMessage
end

local function EnsureString(payload)
	local t = type(payload)
	if t == "table" then
		return Common.JsonStringify(payload)
	elseif t == "string" then
		return payload
	elseif t == "nil" then
		return ""
	else
		return tostring(payload)
	end
end

--- Shortcut for calling GameHelpers.Net.PostToUser to the host character.
--- @param channel string Channel that will receive the message.
--- @param payload ?string|table Message payload. If this is a table, it'll automatically be converted to a string.
--- @return boolean
function GameHelpers.Net.PostMessageToHost(channel, payload)
	return GameHelpers.Net.PostToUser(CharacterGetHostCharacter(), channel, payload)
end

--- Shortcut for calling Ext.PostMessageToUser for whatever UserID is associated with the UUID/EsvCharacter etc. If no UserID is found, the message is skipped.
--- @param user UUID|EsvCharacter|integer The UUID, character, or UserID of the client to send the message to.
--- @param channel string The channel ID that will receive the message.
--- @param payload ?string|table Message payload. If this is a non-string, it'll automatically be converted to a string.
--- @return boolean
function GameHelpers.Net.PostToUser(user, channel, payload)
	local id = GameHelpers.GetUserID(user)
	if id then
		_postToUser(id, channel, EnsureString(payload))
		return true
	elseif Vars.DebugMode then
		fprint(LOGLEVEL.WARNING, "[LeaderLib:GameHelpers.Net.PostToUser(%s)] Failed to get user ID for character (%s).", channel, user)
	end
	return false
end

--- Shortcut for calling Ext.BroadcastMessage.
--- @param channel string Channel that will receive the message.
--- @param payload ?string|table Message payload. If this is a table, it'll automatically be converted to a string.
--- @param excludeCharacter ?UUID|EsvCharacter
--- @return boolean
function GameHelpers.Net.Broadcast(channel, payload, excludeCharacter)
	if excludeCharacter then
		_broadcast(channel, EnsureString(payload), GameHelpers.GetUUID(excludeCharacter, true))
	else
		_broadcast(channel, EnsureString(payload))
	end
	return true
end

--Old Osiris support
---@deprecated
---@param channel string
---@param payload string
function BroadcastToClient(channel, uuid)
	GameHelpers.Net.PostToUser(uuid, channel)
end