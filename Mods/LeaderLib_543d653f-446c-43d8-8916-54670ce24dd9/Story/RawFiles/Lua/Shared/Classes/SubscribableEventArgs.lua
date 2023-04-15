local type = type

---@alias LeaderLibSubscribableEventArgsGetArgForMatchCallback (fun(self:LeaderLibSubscribableEvent, argKey:string, matchedValue:any):any)

---@class LeaderLibSubscribableEventArgs
---@field StopPropagation fun(self:LeaderLibSubscribableEventArgs) Stop the event from continuing on to other registered listeners.
---@field Dump fun(self:LeaderLibSubscribableEventArgs) Dumps the event's parameters to the console.
---@field DumpExport fun(self:LeaderLibSubscribableEventArgs):string Converts the event's parameters to a string.
---@field Unsubscribe fun(self:LeaderLibSubscribableEventArgs) Unsubscribes the current listener.

---@class LeaderLibRuntimeSubscribableEventArgsPrivateFields
---@field LLEventID string The Event ID
---@field Handled boolean
---@field KeyOrder string[]|nil When unpacking, this is the specific order to unpack values in.
---@field GetArg SubscribableEventGetArgFunction|nil
---@field GetArgForMatch LeaderLibSubscribableEventArgsGetArgForMatchCallback|nil
---@field Args table<string,any> The table of args used to create this instance.

---@class LeaderLibRuntimeSubscribableEventArgs
---@field _Private LeaderLibRuntimeSubscribableEventArgsPrivateFields
local SubscribableEventArgs = {
	Type = "SubscribableEventArgs"
}

function SubscribableEventArgs:StopPropagation()
	self._Private.Handled = true
end

---@param self LeaderLibRuntimeSubscribableEventArgs
---@param key string
local function _TryGetArg(self, key)
	if self._Private.GetArg then
		local b,value = pcall(self._Private.GetArg, self, key, self._Private.Args[key])
		if b then
			if value ~= nil then
				return value
			end
		end
	end
	return self[key]
end

---@class SubscribableEventCustomMetatable
---@field __index fun(tbl:table, key:any):any
---@field __newindex fun(tbl:table, key:any, value:any)

---@param args? table
---@param unpackedKeyOrder? string[]
---@param getArg? SubscribableEventGetArgFunction
---@param customMeta? SubscribableEventCustomMetatable Automatically set if the args table had a metatable set.
---@param eventID? string
---@param getArgForMatch? LeaderLibSubscribableEventArgsGetArgForMatchCallback
---@return LeaderLibRuntimeSubscribableEventArgs
function SubscribableEventArgs:Create(args, unpackedKeyOrder, getArg, customMeta, eventID, getArgForMatch)
	local _private = {
		LLEventID = eventID or "",
		Handled = false,
		--The table of args used to create this instance.
		Args = args or {},
		--When unpacking, this is the specific order to unpack values in.
		KeyOrder = unpackedKeyOrder,
		GetArg = getArg,
		GetArgForMatch = getArgForMatch,
	}
	local eventArgs = {}
	if type(args) == "table" then
		for k,v in pairs(args) do
			eventArgs[k] = v
		end
	end
	local getCustomMetaIndex = nil
	if customMeta then
		local indexType = type(customMeta.__index)
		if indexType == "table" then
			getCustomMetaIndex = function (tbl, k)
				return customMeta.__index[k]
			end
		elseif indexType == "function" then
			getCustomMetaIndex = customMeta.__index
		end
	end

	setmetatable(eventArgs, {
		__index = function (_,k)
			if k == "_Private" then
				return _private
			elseif k == "Handled" then
				return _private.Handled
			elseif k == "LLEventID" then
				return _private.EventID
			end
			if getCustomMetaIndex then
				local b,value = xpcall(getCustomMetaIndex, debug.traceback, eventArgs, k)
				if b and value ~= nil then
					return value
				elseif not b then
					Ext.Utils.PrintError(value)
				end
			end
			return SubscribableEventArgs[k]
		end,
		__newindex = function (_, k, v)
			if customMeta and customMeta.__newindex then
				local b,value = xpcall(customMeta.__newindex, debug.traceback, self, k, v)
				if not b then
					Ext.Utils.PrintError(value)
				else
					return
				end
			end
			if _private[k] == nil then
				rawset(eventArgs, k, v)
			end
		end
	})
	return eventArgs
end

---@param argKey string
---@param matchValue any
function SubscribableEventArgs:ValueMatchesArg(argKey, matchValue)
	if self._Private.GetArgForMatch then
		local argValue = self._Private.GetArgForMatch(self, argKey, matchValue)
		if argValue ~= nil then
			return argValue == matchValue
		end
	end
	return self[argKey] == matchValue
end

---Unpack the event args to separate values, using a specific key order.
---This can be used when invoking older listeners that don't access parameters from the event args table directly.
---@param keyOrder string[]|nil
function SubscribableEventArgs:Unpack(keyOrder)
	---@type string[]
	local keyOrder = keyOrder or self._Private.KeyOrder
	local temp = {}
	local length = 0
	if type(keyOrder) == "table" then
		for i=1,#keyOrder do
			length = length + 1
			local key = keyOrder[i]
			if self._Private.Args[key] ~= nil then
				temp[length] = _TryGetArg(self, key)
			end
		end
	else
		--Unpack unordered args as a fallback. Should work fine if the event only has one arg anyway.
		for _,v in pairs(self._Private.Args) do
			length = length + 1
			temp[length] = v
		end
	end
	--Workaround for args that may be nil, so they get unpacked as well
	--By giving unpack a range to unpack (1-length), indexes not set, such as temp[3] should unpack as nil.
	return table.unpack(temp, 1, length)
end

---Debug function for dumping args to the console.
function SubscribableEventArgs:Dump()
	fprint(LOGLEVEL.TRACE, "%s", Lib.serpent.block({_Event=self._Private.LLEventID, Args=self._Private.Args, _Context = Ext.IsClient() and "CLIENT" or "SERVER"}, {SimplifyUserdata = true}))
end

---@return string
function SubscribableEventArgs:DumpExport()
	return Lib.serpent.block({_Event=self._Private.LLEventID, Args=self._Private.Args, _Context = Ext.IsClient() and "CLIENT" or "SERVER"}, {SimplifyUserdata = true})
end

Classes.SubscribableEventArgs = SubscribableEventArgs