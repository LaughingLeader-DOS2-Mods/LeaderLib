--[[
Adapted from ScriptExtender\LuaScripts\Libs\Event.lua in Extender v56 by Norbyte.
We don't have C++ event objects backing these, so they're more of a fancy way to register listeners.
]]

local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Version()
local _type = type
local _pairs = pairs
local _pcall = pcall
local _xpcall = xpcall
local _traceback = debug.traceback
local _tblremove = table.remove

local _printError = Ext.PrintError
local _format = string.format

local _errormsg = function (str, ...)
	_printError(_format(str, ...))
end

---Optional function to manipulate returned parameters when the event arguments are being unpacked for legacy listeners.
---@alias SubscribableEventGetArgFunction fun(paramId:string, param:any):any

---@class SubscribableEventCreateOptions
---@field GatherResults boolean|nil If true, event results from callbacks are gathered and return in in the Invoke function.
---@field SyncInvoke boolean|nil If true, this event will automatically be invoked on the opposite side, i.e. the client side will be invoked when the server side is. Defaults to false.
---@field CanSync fun(self:LeaderLibSubscribableEvent, args:LeaderLibSubscribableEventArgs, ...):boolean If set, this event can only sync is this function returns true.
---@field Disabled boolean|nil If this event is disabled, Invoke won't invoke registered callbacks.
---@field ArgsKeyOrder string[]|nil
---@field GetArg SubscribableEventGetArgFunction|nil
---@field OnSubscribe fun(callback:function, opts:SubscribableEventCreateOptions|nil, matchArgs:table|nil, matchArgsType:string) Called when a callback is subscribed to the event.

---@alias SubscribableEventInvokeResultCode string|"Success"|"Handled"|"Error"

---@class SubscribableEventInvokeResult<T>:{ResultCode: SubscribableEventInvokeResultCode, Results:table, Args:LeaderLibSubscribableEventArgs|T, Handled:boolean}
---@alias AnySubscribableEventInvokeResult SubscribableEventInvokeResult<EmptyEventArgs>
---@alias MatchArgsCallback<T> fun(e:T):boolean

---Used for event entry in the Events table, to support one base definition with multiple event argument types.
---T should be specific event arg classes that derive from SubscribableEventArgs.
---Example: SubscribableEvent<CharacterResurrectedEventArgs>
---@see SubscribableEventArgs
---@see LeaderLibSubscriptionEvents
---@class LeaderLibSubscribableEvent<T>:{ Subscribe:fun(self:LeaderLibSubscribableEvent, callback:fun(e:T|LeaderLibSubscribableEventArgs), opts:{Priority:integer, Once:boolean,  MatchArgs:T, CanSync:fun(self:LeaderLibSubscribableEvent, args:T)}|nil), Unsubscribe:fun(self:LeaderLibSubscribableEvent, indexOrCallback:integer|function, matchArgs:table|nil), Invoke:fun(self:LeaderLibSubscribableEvent, args:T|LeaderLibSubscribableEventArgs, unpackedKeyOrder:string[]|nil):SubscribableEventInvokeResult }

---@class BaseSubscribableEvent:SubscribableEventCreateOptions
---@field ID string
---@field First SubscribableEventNode|nil
---@field NextIndex integer
local SubscribableEvent = {}

local _INVOKERESULT = {
	Success = "Success",
	Handled = "Handled",
	Error = "Error",
}

---@param id string
---@param opts SubscribableEventCreateOptions|nil
---@return LeaderLibSubscribableEvent
function SubscribableEvent:Create(id, opts)
	local o = {
		First = nil,
		NextIndex = 1,
		ID = id,
		Disabled = false,
		GatherResults = false,
		SyncInvoke = false,
	}
	if _type(opts) == "table" then
		for k,v in _pairs(opts) do
			if SubscribableEvent[k] == nil then
				o[k] = v
			end
		end
	end
	setmetatable(o, {
		__index = SubscribableEvent
	})
    return o
end

---@class EventSubscriptionOptions
---@field Priority integer|nil
---@field Once boolean|nil
---@field MatchArgs table<string,any>|nil Optional event arguments to match before the callback is invoked.

---@class SubscribableEventNode
---@field Priority integer|nil
---@field Once boolean|nil
---@field Callback function
---@field Index integer
---@field Options SubscribableEventCreateOptions
---@field Prev SubscribableEventNode|nil
---@field Next SubscribableEventNode|nil
---@field IsMatch fun(eventArgs:table):boolean If MatchArgs has a single entry, a function is created to run a quick match.

---@param self LeaderLibSubscribableEvent
---@param node SubscribableEventNode
---@param sub SubscribableEventNode
local function DoSubscribeBefore(self, node, sub)
	sub.Prev = node.Prev
	sub.Next = node

	if node.Prev ~= nil then
		node.Prev.Next = sub
	else
		self.First = sub
	end

	node.Prev = sub
end

---@param self LeaderLibSubscribableEvent
---@param sub SubscribableEventNode
local function DoSubscribe(self, sub)
	if self.First == nil then
		self.First = sub
		return
	end

	local cur = self.First
	local last = nil

	if cur ~= nil then
		while cur ~= nil do
			last = cur
			if sub.Priority > cur.Priority then
				DoSubscribeBefore(self, cur, sub)
				return
			end

			cur = cur.Next
		end
	end

	if last then
		last.Next = sub
	end

	sub.Prev = last
end

local function _TablesMatch(t1,t2)
	for k,v in _pairs(t1) do
		if t2[k] ~= v then
			return false
		end
	end
	return true
end

---@param callback function
---@param opts EventSubscriptionOptions|nil
---@return integer
function SubscribableEvent:Subscribe(callback, opts)
	assert(_type(callback) == "function", "callback parameter must be a function")
	local opts = _type(opts) == "table" and opts or {}
	local index = self.NextIndex
	self.NextIndex = self.NextIndex + 1

	---@type SubscribableEventNode
	local sub = {
		Callback = callback,
		Index = index,
		Priority = opts.Priority or 100,
		Once = opts.Once or false,
		Options = {}
	}

	local matchArgs = opts.MatchArgs
	local matchArgsType = _type(matchArgs)
	if matchArgsType == "table" then
		local firstEntry = nil
		local firstID = nil
		local count = 0
		for k,v in _pairs(matchArgs) do
			if firstEntry == nil then
				firstID = k
				firstEntry = v
			end
			count = count + 1
		end
		if count == 1 then
			sub.IsMatch = function(args)
				return args[firstID] == firstEntry
			end
		else
			sub.IsMatch = function(args)
				for k,v in _pairs(matchArgs) do
					if args[k] == nil then
						return false
					end
					if _type(v) == "table" then
						if not _TablesMatch(v, args[k]) then
							return false
						end
					elseif args[k] ~= v then
						return false
					end
				end
				return true
			end
		end
	elseif matchArgsType == "function" then
		sub.IsMatch = function(...)
			return matchArgs(...) == true
		end
	end
	
	DoSubscribe(self, sub)
	
	if self.OnSubscribe then
		self.OnSubscribe(callback, opts, matchArgs, matchArgsType)
	end

	return index
end

---@param self LeaderLibSubscribableEvent
---@param node SubscribableEventNode
local function RemoveNode(self, node)
	if node.Prev ~= nil then
		node.Prev.Next = node.Next
	end

	if node.Next ~= nil then
		node.Next.Prev = node.Prev
	end

	if self.First == node then
		self.First = node.Next
	end

	node.Prev = nil
	node.Next = nil
end

---@param indexOrCallback integer|function
---@param matchArgs table|nil
function SubscribableEvent:Unsubscribe(indexOrCallback, matchArgs)
	if indexOrCallback == nil then
		return false
	end
	if not self._Invoking then
		local t = _type(indexOrCallback)
		local cur = self.First
		if cur then
			while cur ~= nil do
				if (t == "number" and cur.Index == indexOrCallback)
				or (t == "function" and cur.Callback == indexOrCallback)
				or (matchArgs and cur.IsMatch and cur.IsMatch(matchArgs))
				then
					RemoveNode(self, cur)
					return true
				end
				cur = cur.Next
			end
		end
	else
		if self._RemoveNext == nil then
			self._RemoveNext = {}
		end
		self._RemoveNext[#self._RemoveNext+1] = {Index = indexOrCallback, MatchArgs = matchArgs}
	end
	--fprint(LOGLEVEL.WARNING, "[LeaderLib:SubscribableEvent] Attempted to remove subscriber ID %s for event '%s', but no such subscriber exists (maybe it was removed already?)", indexOrCallback, self.ID)
	return false
end

function SubscribableEvent:StopPropagation()
	self.StopInvoke = true
end

---@param node SubscribableEventNode
---@param eventArgs LeaderLibRuntimeSubscribableEventArgs
local function _EventArgsMatch(node, eventArgs)
	local match = true
	if node.IsMatch ~= nil then
		local b,result = _pcall(node.IsMatch, eventArgs)
		if result ~= nil then
			match = result
		end
	end
	return match
end

--Convert userdata event args to a table with the NetID, so the other side can retrieve it.
local function SerializeArgs(args)
	local tbl = {}
	for k,v in _pairs(args) do
		local t = _type(v)
		if t == "userdata" then
			if v.NetID then
				tbl[k] = {Type="Object", NetID=v.NetID, UUID=v.MyGuid}
			end
		elseif t == "table" then
			tbl[k] = SerializeArgs(v)
		elseif t == "boolean" or t == "string" or t == "number" then
			tbl[k] = v
		end
	end
	return tbl
end

---@param sub BaseSubscribableEvent
---@param args LeaderLibRuntimeSubscribableEventArgs
---@param resultsTable table
---@vararg SerializableValue
local function InvokeCallbacks(sub, args, resultsTable, ...)
	local cur = sub.First
	local gatherResults = resultsTable ~= nil
	local result = _INVOKERESULT.Success
	while cur ~= nil do
		if args.Handled then
			result = _INVOKERESULT.Handled
			break
		end

		if _EventArgsMatch(cur, args) then
			if gatherResults then
				local callbackResults = {_xpcall(cur.Callback, _traceback, args, ...)}
				if not callbackResults[1] then
					_errormsg("[LeaderLib:SubscribableEvent] Error while dispatching event %s:\n%s", sub.ID, callbackResults[2])
					result = _INVOKERESULT.Error
				elseif gatherResults and callbackResults[2] ~= nil then
					if callbackResults[3] == nil then
						resultsTable[#resultsTable+1] = callbackResults[2]
					else
						--Multiple return values
						_tblremove(callbackResults, 1)
						resultsTable[#resultsTable+1] = callbackResults
					end
				end
			else
				local b,err = _xpcall(cur.Callback, _traceback, args, ...)
				if not b then
					_errormsg("[LeaderLib:SubscribableEvent] Error while dispatching event %s:\n%s", sub.ID, err)
					result = _INVOKERESULT.Error
				end
			end

			if cur.Once or args.__unsubscribeListener == true then
				local last = cur
				cur = last.Next
				RemoveNode(sub, last)
			else
				cur = cur.Next
			end
		else
			cur = cur.Next
		end
	end
	return result
end

---@param args table|nil
---@param skipAutoInvoke boolean|nil
---@vararg any
---@return SubscribableEventInvokeResult result
function SubscribableEvent:Invoke(args, skipAutoInvoke, ...)
	args = args or {}
	local metatable = nil
	if _type(args.__metatable) == "table" then
		metatable = args.__metatable
		args.__metatable = nil
	end
	local eventObject = Classes.SubscribableEventArgs:Create(args, self.ArgsKeyOrder, self.GetArg, metatable)
	---@type SubscribableEventInvokeResultCode
	local invokeResult = _INVOKERESULT.Success
	local results = {}
	if self.First ~= nil then
		self._Invoking = true
		if self.GatherResults then
			invokeResult = InvokeCallbacks(self, eventObject, results, ...)
		else
			invokeResult = InvokeCallbacks(self, eventObject, nil, ...)
		end
		self._Invoking = nil
		if self._RemoveNext then
			for i=1,#self._RemoveNext do
				local v = self._RemoveNext[i]
				self:Unsubscribe(v.Index, v.MatchArgs)
			end
			self._RemoveNext = nil
		end
	end
	if not skipAutoInvoke and self.SyncInvoke then
		local canSync = true
		if self.CanSync then
			local b,result = _xpcall(self.CanSync, _traceback, self, args, ...)
			if not b then
				Ext.PrintError(result)
			else
				canSync = result == true
			end
		end
		if canSync then
			local _netMessageFunc = _ISCLIENT and Ext.PostMessageToServer or GameHelpers.Net.Broadcast
			_netMessageFunc("LeaderLib_SubscribableEvent_Invoke", Common.JsonStringify({
				ID = self.ID,
				Args = SerializeArgs(args)
			}))
		end
	end
	local handled = false
	if invokeResult == _INVOKERESULT.Handled then
		invokeResult = _INVOKERESULT.Success
		handled = true
	end
	return {ResultCode = invokeResult, Results = results, Args = eventObject, Handled = handled}
end

local function DeserializeArgs(args)
	local tbl = {}
	for k,v in _pairs(args) do
		if _type(v) == "table" then
			if v.Type == "Object" then
				tbl[k] = GameHelpers.TryGetObject(v.NetID)
				if not tbl[k] then
					tbl[k] = v.UUID
				end
			else
				tbl[k] = DeserializeArgs(v)
			end
		else
			tbl[k] = v
		end
	end
	return tbl
end

Ext.RegisterNetListener("LeaderLib_SubscribableEvent_Invoke", function(cmd, payload)
	local data = Common.JsonParse(payload, true)
	if data then
		local sub = Events[data.ID]
		if sub then
			sub:Invoke(DeserializeArgs(data.Args), true)
		end
	end
end)

Classes.SubscribableEvent = SubscribableEvent