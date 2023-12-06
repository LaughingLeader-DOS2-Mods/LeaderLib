--[[
Adapted from ScriptExtender\LuaScripts\Libs\Event.lua in Extender v56 by Norbyte.
We don't have C++ event objects backing these, so they're more of a fancy way to register listeners.
]]

local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()
local _type = type
local _pairs = pairs
local _pcall = pcall
local _xpcall = xpcall
local _traceback = debug.traceback
local _tblremove = table.remove

local _printError = Ext.Utils.PrintError
local _printWarning = Ext.Utils.PrintWarning
local _print = Ext.Utils.Print
local _format = string.format
local _sline = Lib.serpent.line
local _serpentOpts = {SimplifyUserdata=true}

local _errormsg = function (str, ...)
	_printError(_format(str, ...))
end

---Optional function to manipulate returned parameters when the event arguments are being unpacked for legacy listeners.
---@alias SubscribableEventGetArgFunction (fun(self:LeaderLibRuntimeSubscribableEventArgs, id:string, value:any):any)
---Called when serializing event args, when syncing it to the other context.  
---Pass true as the second return to force the arg to be "handled".  
---@alias SubscribableEventSerializeArgFunction (fun(self:LeaderLibRuntimeSubscribableEventArgs, args:table, id:string, value:any, argType:type):SerializableValue|nil,boolean|nil)
---Called when deserializing event args, after the data has been syncing to the other context.  
---Pass true as the second return to force the arg to be "handled".
---@alias SubscribableEventDeserializeArgFunction (fun(self:LeaderLibRuntimeSubscribableEventArgs, args:table, id:string, value:SerializableValue, argType:type):any|nil,boolean|nil)

---@class SubscribableEventCreateOptions
---@field GatherResults boolean|nil If true, event results from callbacks are gathered and return in in the Invoke function.
---@field SyncInvoke boolean|nil If true, this event will automatically be invoked on the opposite side, i.e. the client side will be invoked when the server side is. Defaults to false.
---@field CanSync (fun(self:LeaderLibSubscribableEvent, args:LeaderLibSubscribableEventArgs, ...):boolean)|nil If set, this event can only sync is this function returns true.
---@field Disabled boolean|nil If this event is disabled, Invoke won't invoke registered callbacks.
---@field ArgsKeyOrder string[]|nil
---@field GetArg SubscribableEventGetArgFunction|nil Used when the event data is unpacked, such as when passing the data to an old callback listener.
---@field SerializeArg SubscribableEventSerializeArgFunction|nil Called when the event data is synced, and specific non-serializable args need to be converted (userdata etc).
---@field DeserializeArg SubscribableEventDeserializeArgFunction|nil Called when the event data is done syncing, and specific args need to be converted back to non-serializable types.
---@field OnSubscribe (fun(self:BaseSubscribableEvent, callback:function, opts:EventSubscriptionOptions, matchArgs:table|function|nil, matchArgsType:type))|nil Called when a callback is subscribed to the event.
---@field OnUnsubscribe (fun(self:BaseSubscribableEvent, callback:function, opts:EventSubscriptionOptions, matchArgs:table|function|nil, matchArgsType:type))|nil Called when a callback is unsubscribed to the event.
---@field Benchmark boolean|nil Print the time it takes to invoke listeners in DeveloperMode.

---@alias SubscribableEventInvokeResultCode string|"Success"|"Handled"|"Error"

---@class SubscribableEventInvokeResult<T>:{ResultCode: SubscribableEventInvokeResultCode, Results:table, Args:LeaderLibSubscribableEventArgs|T, Handled:boolean}
---@alias AnySubscribableEventInvokeResult SubscribableEventInvokeResult<EmptyEventArgs>
---@alias MatchArgsCallback<T> fun(e:T):boolean

---Used for event entry in the Events table, to support one base definition with multiple event argument types.
---T should be specific event arg classes that derive from SubscribableEventArgs.
---Example: SubscribableEvent<CharacterResurrectedEventArgs>
---@see SubscribableEventArgs
---@see LeaderLibSubscriptionEvents
---@class LeaderLibSubscribableEvent<T>:{IsSubscribed:boolean, (Subscribe:fun(self:LeaderLibSubscribableEvent, callback:fun(e:T|LeaderLibSubscribableEventArgs), opts:{Priority:integer|nil, Once:boolean|nil, MatchArgs:T|(fun(e:T):boolean)|nil, CanSync:fun(self:LeaderLibSubscribableEvent, args:T)}|nil):integer), (Unsubscribe:fun(self:LeaderLibSubscribableEvent, indexOrCallback:integer|function, matchArgs:T|(fun(e:T):boolean)|nil):boolean), (Invoke:fun(self:LeaderLibSubscribableEvent, args:T|LeaderLibSubscribableEventArgs, skipAutoInvoke:boolean|nil, getArgForMatch:(fun(self:T, argKey:string, matchedValue:any):any)|nil):SubscribableEventInvokeResult)}

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
---@param opts? SubscribableEventCreateOptions
---@return LeaderLibSubscribableEvent
function SubscribableEvent:Create(id, opts)
	local _privateKeys = {
		First = true,
		NextIndex = true,
		_EnterCount = true,
	}
	local o = {
		--First = nil,
		NextIndex = 1,
		ID = id,
		Disabled = false,
		GatherResults = false,
		SyncInvoke = false,
		Options = opts or {},
		Benchmark = false,
		_EnterCount = 0
	}
	if _type(opts) == "table" then
		for k,v in _pairs(opts) do
			if not _privateKeys[k] and SubscribableEvent[k] == nil then
				o[k] = v
			end
		end
	end
	if o.Benchmark and not Ext.Debug.IsDeveloperMode() then
		o.Benchmark = false
	end
	setmetatable(o, {
		__index = function (_,k)
			if k == "IsSubscribed" then
				local first = rawget(o, "First")
				return first ~= nil
			end
			return SubscribableEvent[k]
		end
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
---@field Unsubscribe function

local wasSet = false
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
	
	while cur ~= nil do
		last = cur
		if sub.Priority > cur.Priority then
			DoSubscribeBefore(self, cur, sub)
			return
		end

		cur = cur.Next
	end

	last.Next = sub
	sub.Prev = last
end

---@param callback function
---@param opts? EventSubscriptionOptions
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
		Once = opts.Once == true,
		Options = opts or {},
		Unsubscribe = function ()
			self:Unsubscribe(index)
		end
	}

	local matchArgs = opts.MatchArgs
	local matchArgsType = _type(matchArgs)
	if matchArgsType == "table" then
		local firstEntry = nil
		local firstID = nil
		local count = 0
		---@type {Key:string, Value:any}[]
		local _matchArray = {}
		for k,v in _pairs(matchArgs) do
			if firstEntry == nil then
				firstID = k
				firstEntry = v
			end
			_matchArray[#_matchArray+1] = {Key=k, Value=v}
			count = count + 1
		end
		if count == 1 then
			_matchArray = nil
			---@param args LeaderLibRuntimeSubscribableEventArgs
			sub.IsMatch = function(args)
				return args:ValueMatchesArg(firstID, firstEntry) == true
			end
		elseif count > 1 then
			---@param args LeaderLibRuntimeSubscribableEventArgs
			sub.IsMatch = function(args)
				for i=1,count do
					local m = _matchArray[i]
					if not args:ValueMatchesArg(m.Key, m.Value) then
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
		local b,err = xpcall(self.OnSubscribe, debug.traceback, self, opts, matchArgs, matchArgsType)
		if not b then
			_printError(err)
		end
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
---@param matchArgs? table
function SubscribableEvent:Unsubscribe(indexOrCallback, matchArgs)
	if indexOrCallback == nil then
		return false
	end
	if self._EnterCount == 0 then
		local t = _type(indexOrCallback)
		local matchArgsType = _type(matchArgs)
		local cur = self.First
		if cur then
			while cur ~= nil do
				if (t == "number" and cur.Index == indexOrCallback)
				or (t == "function" and cur.Callback == indexOrCallback)
				or (matchArgsType == "table" and cur.IsMatch and cur.IsMatch(matchArgs))
				then
					RemoveNode(self, cur)
					if self.OnUnsubscribe then
						local b,err = xpcall(self.OnUnsubscribe, debug.traceback, self, cur.Callback, cur.Options, matchArgs, matchArgsType)
						if not b then
							_printError(err)
						end
					end
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

local function _ProcessRemoveNext(self)
	if self._EnterCount == 0 and self._RemoveNext then
		local len = #self._RemoveNext
		if len > 0 then
			for i=1,len do
				local v = self._RemoveNext[i]
				self:Unsubscribe(v.Index, v.MatchArgs)
			end
		end
		self._RemoveNext = nil
	end
end

function SubscribableEvent:StopPropagation()
	self.StopInvoke = true
end

---@param self BaseSubscribableEvent
---@param node SubscribableEventNode
---@param eventArgs LeaderLibRuntimeSubscribableEventArgs
local function _EventArgsMatch(self, node, eventArgs)
	local match = true
	if node.IsMatch ~= nil then
		local b,result = _pcall(node.IsMatch, eventArgs)
		if result ~= nil then
			match = result
		elseif not b then
			match = false
		end
	end
	return match
end

---Converts userdata event args to a table with the NetID, so the other side can retrieve it.
---@param sub BaseSubscribableEvent|SubscribableEventNode
---@param subArgs table The outer args
---@param eventID string
---@param args table Current table being processed
---@param seralizeFunc? SubscribableEventSerializeArgFunction
local function _SerializeArgs(sub, subArgs, eventID, args, seralizeFunc)
	local tbl = {}
	for k,v in _pairs(args) do
		local t = _type(v)
		local handled = false
		if seralizeFunc then
			local b,result,forceHandled = xpcall(seralizeFunc, debug.traceback, sub, subArgs, k, v, t)
			if not b then
				_printError(result)
			elseif result ~= nil then
				tbl[k] = result
				handled = true
			end
			if forceHandled == true then
				handled = true
			end
		end
		if not handled then
			if t == "userdata" then
				if GameHelpers.IsValidHandle(v) then
					--TODO this is probably a server/client handle, so it won't work in the other context
					tbl[k] = {Type="Object", HandleINT = Ext.Utils.HandleToInteger(v)}
				elseif GameHelpers.Ext.ObjectIsAnyType(v) then
					if v.NetID or v.UUID then
						tbl[k] = {Type="Object", NetID=v.NetID, UUID=v.MyGuid}
					end
				end
			elseif t == "table" then
				tbl[k] = _SerializeArgs(sub, subArgs, eventID, v, seralizeFunc)
			elseif t == "boolean" or t == "string" or t == "number" then
				tbl[k] = v
			end
		end
	end
	return tbl
end

---@param self BaseSubscribableEvent
---@param args LeaderLibRuntimeSubscribableEventArgs
---@param resultsTable table
---@vararg SerializableValue
local function InvokeCallbacks(self, args, resultsTable, ...)
	local cur = self.First
	local gatherResults = resultsTable ~= nil
	local result = _INVOKERESULT.Success
	while cur ~= nil do
		if _EventArgsMatch(self, cur, args) then
			if gatherResults then
				local callbackResults = {_xpcall(cur.Callback, _traceback, args, ...)}
				if not callbackResults[1] then
					_errormsg("[LeaderLib:SubscribableEvent] Error while dispatching event %s:\n%s", self.ID, callbackResults[2])
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
					_errormsg("[LeaderLib:SubscribableEvent] Error while dispatching event %s:\n%s", self.ID, err)
					result = _INVOKERESULT.Error
				end
			end

			if cur.Once == true or args.__unsubscribeListener == true then
				local last = cur
				cur = last.Next
				RemoveNode(self, last)
			else
				cur = cur.Next
			end
		else
			cur = cur.Next
		end
		if args._Private.Handled then
			return _INVOKERESULT.Handled
		end
	end
	return result
end

---@param self BaseSubscribableEvent|SubscribableEventNode
---@param args? table
---@param skipAutoInvoke? boolean
---@param getArgForMatch? LeaderLibSubscribableEventArgsGetArgForMatchCallback
---@vararg any
---@return SubscribableEventInvokeResult result
local function _TryInvoke(self, args, skipAutoInvoke, getArgForMatch, ...)
	args = args or {}
	local metatable = getmetatable(args)
	if metatable then
		setmetatable(args, nil)
	end
	local ts = Ext.Utils.MonotonicTime()
	local eventObject = Classes.SubscribableEventArgs:Create(args, self.ArgsKeyOrder, self.GetArg, metatable, self.ID, getArgForMatch)
	rawset(eventObject, "Unsubscribe", self.Unsubscribe)
	---@type SubscribableEventInvokeResultCode
	local invokeResult = _INVOKERESULT.Success
	local results = {}
	if self.First ~= nil then
		if self.GatherResults then
			invokeResult = InvokeCallbacks(self, eventObject, results, ...)
		else
			invokeResult = InvokeCallbacks(self, eventObject, nil, ...)
		end
	end
	if not skipAutoInvoke and self.SyncInvoke then
		local canSync = true
		if self.CanSync then
			local b,result = _xpcall(self.CanSync, _traceback, self, args, ...)
			if not b then
				_printError(result)
			else
				canSync = result == true
			end
		end
		if canSync then
			local b,args = xpcall(_SerializeArgs, debug.traceback, self, args, self.ID, args, self.SerializeArg)
			if not b then
				_printError(args)
			else
				local payload = {ID = self.ID, Args = args}
				if _ISCLIENT then
					GameHelpers.Net.PostMessageToServer("LeaderLib_SubscribableEvent_Invoke", payload)
				else
					GameHelpers.Net.Broadcast("LeaderLib_SubscribableEvent_Invoke", payload)
				end
			end
		end
	end
	local handled = false
	if invokeResult == _INVOKERESULT.Handled then
		invokeResult = _INVOKERESULT.Success
		handled = true
	end
	if self.Benchmark then
		local timeTaken = Ext.Utils.MonotonicTime() - ts
		local msg = _format("[LeaderLib:%s:Invoke] Took (%s) ms to invoke callbacks.\nArgs:%s", self.ID, timeTaken, _sline(args, _serpentOpts))
		if timeTaken > 100 then
			_printWarning(msg)
		elseif timeTaken >= 1000 then
			_printError(msg)
		else
			_print(msg)
		end
	end
	return {ResultCode = invokeResult, Results = results, Args = eventObject, Handled = handled}
end

---@param args? table
function SubscribableEvent:DoSyncInvoke(args)
	local canSync = true
	if self.CanSync then
		local b,result = _xpcall(self.CanSync, _traceback, self, args)
		if not b then
			_printError(result)
		else
			canSync = result == true
		end
	end
	if canSync then
		local b,args = xpcall(_SerializeArgs, debug.traceback, self, args, self.ID, args, self.SerializeArg)
		if not b then
			_printError(args)
		else
			local payload = {ID = self.ID, Args = args}
			if _ISCLIENT then
				GameHelpers.Net.PostMessageToServer("LeaderLib_SubscribableEvent_Invoke", payload)
			else
				GameHelpers.Net.Broadcast("LeaderLib_SubscribableEvent_Invoke", payload)
			end
		end
	end
end

---@param args? table
---@param skipAutoInvoke? boolean
---@param getArgForMatch? LeaderLibSubscribableEventArgsGetArgForMatchCallback
---@return SubscribableEventInvokeResult result
function SubscribableEvent:Invoke(args, skipAutoInvoke, getArgForMatch)
	self._EnterCount = self._EnterCount + 1
	local b,result = _pcall(_TryInvoke, self, args, skipAutoInvoke, getArgForMatch)
	self._EnterCount = self._EnterCount - 1
	_ProcessRemoveNext(self)
	if b then
		return result
	end
	return nil
end

---@param sub BaseSubscribableEvent|SubscribableEventNode
---@param subArgs table The outer args
---@param eventID string
---@param args table Current table being processed
---@param deserializeFunc? SubscribableEventDeserializeArgFunction
local function _DeserializeArgs(sub, subArgs, eventID, args, deserializeFunc)
	local tbl = {}
	for k,v in _pairs(args) do
		local t = _type(v)
		local handled = false
		if deserializeFunc then
			local b,result,forceHandled = xpcall(deserializeFunc, debug.traceback, sub, subArgs, k, v, t)
			if not b then
				_printError(result)
			elseif result ~= nil then
				tbl[k] = result
				handled = true
			end
			if forceHandled == true then
				handled = true
			end
		end
		if not handled then
			if t == "table" then
				if v.Type == "Object" then
					if eventID == "SummonChanged" then
						local level = Ext.Entity.GetCurrentLevel()
						local arr = nil
						if args.IsItem == true then
							arr = level.EntityManager.ItemConversionHelpers.RegisteredItems[level.LevelDesc.LevelName]
						else
							arr = level.EntityManager.CharacterConversionHelpers.RegisteredCharacters[level.LevelDesc.LevelName]
						end
						for i=1,#arr do
							local entry = arr[i]
							if entry.NetID == v.NetID then
								tbl[k] = entry
								break
							end
						end
					else
						local _getObjFunc = GameHelpers.TryGetObject
						if k == "Item" then
							_getObjFunc = GameHelpers.GetItem
						elseif k == "Character" then
							_getObjFunc = GameHelpers.GetCharacter
						end
						local obj = nil
						if not obj and v.NetID then
							obj = _getObjFunc(v.NetID)
						end
						if not obj and v.UUID then
							obj = _getObjFunc(v.UUID)
						end
						if not obj then
							tbl[k] = v.UUID
						else
							tbl[k] = obj
						end
					end
				else
					tbl[k] = _DeserializeArgs(sub, subArgs, eventID, v, deserializeFunc)
				end
			else
				tbl[k] = v
			end
		end
	end
	return tbl
end

Ext.RegisterNetListener("LeaderLib_SubscribableEvent_Invoke", function(cmd, payload)
	local data = Common.JsonParse(payload, true)
	if data then
		local sub = Events[data.ID] --[[@as BaseSubscribableEvent|SubscribableEventNode]]
		if sub then
			sub:Invoke(_DeserializeArgs(sub, data.Args, data.ID, data.Args, sub.DeserializeArg), true)
		end
	end
end)

Classes.SubscribableEvent = SubscribableEvent