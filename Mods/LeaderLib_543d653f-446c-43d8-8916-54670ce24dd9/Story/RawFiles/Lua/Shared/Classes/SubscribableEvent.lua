--[[
Adapted from ScriptExtender\LuaScripts\Libs\Event.lua in Extender v56 by Norbyte.
We don't have C++ event objects backing these, so they're more of a fancy way to register listeners.
]]

local isClient = Ext.IsClient()

---@class SubscribableEventCreateOptions
---@field GatherResults boolean If true, event results from callbacks are gathered and return in in the Invoke function.
---@field SyncInvoke boolean If true, this event will automatically be invoked on the opposite side, i.e. the client side will be invoked when the server side is. Defaults to false.
---@field Disabled boolean If this event is disabled, Invoke won't invoke registered callbacks.
---@field ArgsKeyOrder string[]|nil

---Used for event entry in the Events table, to support one base definition with multiple event argument types.
---T should be specific event arg classes that derive from SubscribableEventArgs.
---Example: SubscribableEvent<CharacterResurrectedEventArgs>
---@see SubscribableEventArgs
---@see LeaderLibSubscriptionEvents
---@class SubscribableEvent<T>:{ Subscribe:fun(self:SubscribableEvent, callback:fun(e:T|SubscribableEventArgs), opts:{Priority:integer, Once:boolean, MatchArgs:T}|nil), Invoke:fun(self:SubscribableEvent, args:T|SubscribableEventArgs, unpackedKeyOrder:string[]|nil), Unsubscribe:fun(self:SubscribableEvent, indexOrCallback:integer|function) }

---@class BaseSubscribableEvent:SubscribableEventCreateOptions
---@field ID string
---@field First SubscribableEventNode|nil
---@field NextIndex integer
local SubscribableEvent = {}

---@alias SubscribableEventInvokeResult string|"Success"|"Handled"|"Error"|

local _INVOKERESULT = {
	Success = "Success",
	Handled = "Handled",
	Error = "Error",
}

---@param id string
---@param opts SubscribableEventCreateOptions|nil
---@return SubscribableEvent
function SubscribableEvent:Create(id, opts)
	local o = {
		First = nil,
		NextIndex = 1,
		ID = id,
		Disabled = false,
		GatherResults = false,
		SyncInvoke = false,
	}
	if type(opts) == "table" then
		for k,v in pairs(opts) do
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

---@class SubscribableEventNode:EventSubscriptionOptions
---@field Callback function
---@field Index integer
---@field Options SubscribableEventCreateOptions
---@field Prev SubscribableEventNode|nil
---@field Next SubscribableEventNode|nil

---@param self SubscribableEvent
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

---@param self SubscribableEvent
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

---@param callback function
---@param opts EventSubscriptionOptions|nil
---@return integer
function SubscribableEvent:Subscribe(callback, opts)
	assert(type(callback) == "function", "callback parameter must be a function")
	local opts = type(opts) == "table" and opts or {}
	local index = self.NextIndex
	self.NextIndex = self.NextIndex + 1

	---@type SubscribableEventNode
	local sub = {
		Callback = callback,
		Index = index,
		Priority = opts.Priority or 100,
		Once = opts.Once or false,
		MatchArgs = opts.MatchArgs or nil,
		Options = {}
	}

	DoSubscribe(self, sub)
	return index
end

---@param self SubscribableEvent
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
function SubscribableEvent:Unsubscribe(indexOrCallback)
	local t = type(indexOrCallback)
	local cur = self.First
	if cur then
		while cur ~= nil do
			if (t == "number" and cur.Index == indexOrCallback)
			or (t == "function" and cur.Callback == indexOrCallback)
			then
				RemoveNode(self, cur)
				return true
			end
			cur = cur.Next
		end
	end

	fprint(LOGLEVEL.WARNING, "[LeaderLib:SubscribableEvent] Attempted to remove subscriber ID %s for event '%s', but no such subscriber exists (maybe it was removed already?)", indexOrCallback, self.ID)
	return false
end

function SubscribableEvent:StopPropagation()
	self.StopInvoke = true
end

local function _TablesMatch(t1,t2)
	for k,v in pairs(t1) do
		if t2[k] ~= v then
			return false
		end
	end
	return true
end

---@param node SubscribableEventNode
---@param eventArgs RuntimeSubscribableEventArgs
local function _EventArgsMatch(node, eventArgs)
	local match = true
	if node.MatchArgs ~= nil then
		for k,v in pairs(node.MatchArgs) do
			if eventArgs[k] == nil then
				return false
			end
			if type(v) == "table" then
				if not _TablesMatch(v, eventArgs[k]) then
					return false
				end
			elseif eventArgs[k] ~= v then
				return false
			end
		end
	end
	return match
end

---@param sub BaseSubscribableEvent
---@param args RuntimeSubscribableEventArgs
---@param resultsTable table
---@vararg any
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
			local b, result = xpcall(cur.Callback, debug.traceback, args, ...)
			if not b then
				fprint(LOGLEVEL.ERROR, "[LeaderLib:SubscribableEvent] Error while dispatching event %s:\n%s", sub.ID, result)
				result = _INVOKERESULT.Error
			elseif gatherResults and result ~= nil then
				resultsTable[#resultsTable+1] = result
			end
			if cur.Once then
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

--Convert userdata event args to a table with the NetID, so the other side can retrieve it.
local function SerializeArgs(args)
	local tbl = {}
	for k,v in pairs(args) do
		local t = type(v)
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

local function DeserializeArgs(args)
	local tbl = {}
	for k,v in pairs(args) do
		if type(v) == "table" then
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

---@param args table|nil
---@param skipAutoInvoke boolean|nil
---@vararg any
---@return any[]|SubscribableEventInvokeResult result Returns either an array of results, if GatherResults is true, or a string indicating the result (Success, Handled, or Error).
function SubscribableEvent:Invoke(args, skipAutoInvoke, ...)
	args = args or {}
	local eventObject = Classes.SubscribableEventArgs:Create(args, self.ArgsKeyOrder)
	local result = nil
	local cur = self.First
	if cur then
		if self.GatherResults then
			local results = {}
			InvokeCallbacks(self, eventObject, results, ...)
			result = results
		else
			result = InvokeCallbacks(self, eventObject, nil, ...)
		end
	end
	if not skipAutoInvoke and self.SyncInvoke then
		local messageFunc = isClient and Ext.PostMessageToServer or GameHelpers.Net.Broadcast
		messageFunc("LeaderLib_SubscribableEvent_Invoke", Common.JsonStringify({
			ID = self.ID,
			Args = SerializeArgs(args)
		}))
	end
	return result
end

Classes.SubscribableEvent = SubscribableEvent

Ext.RegisterNetListener("LeaderLib_SubscribableEvent_Invoke", function(cmd, payload)
	local data = Common.JsonParse(payload, true)
	if data then
		local sub = Events[data.ID]
		if sub then
			sub:Invoke(DeserializeArgs(data.Args), true)
		end
	end
end)