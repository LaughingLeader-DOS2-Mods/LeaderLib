if GameHelpers.Net == nil then
	GameHelpers.Net = {}
end

--- Shortcut for calling Ext.PostMessageToClient to the host character.
--- @param channel string Channel that will receive the message
--- @param payload string Message payload
function GameHelpers.Net.PostMessageToHost(channel, payload)
	GameHelpers.Net.TryPostToUser(CharacterGetHostCharacter(), channel, payload)
end

--- Shortcut for calling Ext.PostMessageToUser for whatever UserID is associated with the UUID/EsvCharacter etc.
--- @param user UUID|EsvCharacter
--- @param channel string Channel that will receive the message
--- @param payload string Message payload
function GameHelpers.Net.TryPostToUser(user, channel, payload)
	local id = GameHelpers.GetUserID(user)
	if id then
		Ext.PostMessageToUser(id, channel, payload)
	end
end