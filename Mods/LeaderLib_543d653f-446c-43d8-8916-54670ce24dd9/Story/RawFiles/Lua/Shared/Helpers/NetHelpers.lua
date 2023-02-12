if GameHelpers.Net == nil then GameHelpers.Net = {} end

local _ISCLIENT = Ext.IsClient()

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

if not _ISCLIENT then
	local _postToUser = Ext.Net.PostMessageToUser
	local _broadcast = Ext.Net.BroadcastMessage

	--- Shortcut for calling GameHelpers.Net.PostToUser to the host character.
	--- @param channel string Channel that will receive the message.
	--- @param payload SerializableValue|table|nil Message payload. If this is a table, it'll automatically be converted to a string.
	--- @return boolean
	function GameHelpers.Net.PostMessageToHost(channel, payload)
		return GameHelpers.Net.PostToUser(CharacterGetHostCharacter(), channel, payload)
	end

	--- Shortcut for calling Ext.PostMessageToUser for whatever UserID is associated with the UUID/EsvCharacter etc. If no UserID is found, the message is skipped.
	--- @param user Guid|EsvCharacter|integer The UUID, character, or UserID of the client to send the message to.
	--- @param channel string The channel ID that will receive the message.
	--- @param payload SerializableValue|table|nil Message payload. If this is a non-string, it'll automatically be converted to a string.
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
	--- @param payload SerializableValue|table|nil Message payload. If this is a table, it'll automatically be converted to a string.
	--- @param excludeCharacter CharacterParam|nil
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
	---@param uuid string
	function BroadcastToClient(channel, uuid)
		GameHelpers.Net.PostToUser(uuid, channel)
	end
else
	local _postMessageToServer = Ext.Net.PostMessageToServer

	---Send a net message to the server.  
	---🔧**Client-Only**🔧  
	---@param channel string
	---@param payload SerializableValue|table|nil
	function GameHelpers.Net.PostMessageToServer(channel, payload)
		_postMessageToServer(channel, EnsureString(payload))
	end
end

local _listenerCallbacks = {}

---@generic T
---@param id `T` The channel ID string value. Hint: If this name matches an annotated class type, the data param will automatically be that type in the callback.
---@param callback fun(e:LuaNetMessageEvent, data:T)
---@param skipParse boolean|nil Skip automatically parsing Payload to a table.
function GameHelpers.Net.Subscribe(id, callback, skipParse)
	if _listenerCallbacks[id] == nil then
		_listenerCallbacks[id] = {}
	end
	if not skipParse then
		---@param e LuaNetMessageEvent
		local wrapper = function (e)
			local data = Common.JsonParse(e.Payload)
			callback(e, data)
		end
		table.insert(_listenerCallbacks[id], wrapper)
	else
		table.insert(_listenerCallbacks[id], callback)
	end
end

Ext.Events.NetMessageReceived:Subscribe(function (e)
	local callbacks = _listenerCallbacks[e.Channel]
	if callbacks then
		local len = #callbacks
		for i=1,len do
			local b,err = xpcall(callbacks[i], debug.traceback, e, e.Payload)
			if not b then
				Ext.Utils.PrintError(err)
			end
		end
	end
end)