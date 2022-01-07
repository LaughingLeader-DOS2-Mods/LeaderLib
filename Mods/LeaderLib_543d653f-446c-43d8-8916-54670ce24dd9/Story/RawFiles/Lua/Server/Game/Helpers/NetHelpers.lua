if GameHelpers == nil then GameHelpers = {} end
if GameHelpers.Net == nil then GameHelpers.Net = {} end

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
--- @param user UUID|EsvCharacter
--- @param channel string Channel that will receive the message.
--- @param payload ?string|table Message payload. If this is a table, it'll automatically be converted to a string.
--- @return boolean
function GameHelpers.Net.PostToUser(user, channel, payload)
	local id = GameHelpers.GetUserID(user)
	if id then
		Ext.PostMessageToUser(id, channel, EnsureString(payload))
		return true
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
		Ext.BroadcastMessage(channel, EnsureString(payload), GameHelpers.GetUUID(excludeCharacter, true))
	else
		Ext.BroadcastMessage(channel, EnsureString(payload), "")
	end
	return true
end