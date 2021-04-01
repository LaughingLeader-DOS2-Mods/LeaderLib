if GameHelpers.Net == nil then
	GameHelpers.Net = {}
end

--- Shortcut for calling Ext.PostMessageToClient to the host character.
--- @param channel string Channel that will receive the message
--- @param payload string Message payload
function GameHelpers.Net.PostMessageToHost(channel, payload)
	local host = CharacterGetHostCharacter()
	if not StringHelpers.IsNullOrEmpty(host) then
		Ext.PostMessageToClient(host, channel, payload or "")
	end
end