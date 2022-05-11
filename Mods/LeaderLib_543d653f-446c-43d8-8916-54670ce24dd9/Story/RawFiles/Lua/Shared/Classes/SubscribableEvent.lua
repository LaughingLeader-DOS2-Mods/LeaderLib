--[[
Adapted from ScriptExtender\LuaScripts\Libs\Event.lua in Extender v56 by Norbyte.
We don't have C++ event objects backing these, so they're more of a fancy way to register listeners.
]]

---@class LeaderLibSubscribableEventOptions
---@field GatherResults boolean If true, event results from callbacks are gathered and return in in the Invoke function.

---@class LeaderLibSubscribableEvent:LeaderLibSubscribableEventOptions
---@field Name string
---@field First LeaderLibSubscribableEventNode|nil
---@field NextIndex integer
---@field StopInvoke boolean Set via StopPropagation when an event is invoked.
local SubscribableEvent = {}

---@alias LeaderLibSubscribableEventInvokeResult string|"Success"|"Handled"|"Error"|

local _INVOKERESULT = {
	Success = "Success",
	Handled = "Handled",
	Error = "Error",
}

---@param name string
---@param opts LeaderLibSubscribableEventOptions|nil
---@return LeaderLibSubscribableEvent
function SubscribableEvent:Create(name, opts)
	local o = {
		First = nil,
		NextIndex = 1,
		Name = name,
		StopInvoke = false
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

---@class LeaderLibSubscribableEventSubscribeOptions
---@field Priority integer|nil
---@field Once boolean|nil

---@class LeaderLibSubscribableEventNode
---@field Callback function
---@field Index integer
---@field Priority integer
---@field Once boolean
---@field Options LeaderLibSubscribableEventSubscribeOptions
---@field Prev LeaderLibSubscribableEventNode|nil
---@field Next LeaderLibSubscribableEventNode|nil

---@param self LeaderLibSubscribableEvent
---@param node LeaderLibSubscribableEventNode
---@param sub LeaderLibSubscribableEventNode
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
---@param sub LeaderLibSubscribableEventNode
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

---@generic T : function
---@param callback T
---@param opts LeaderLibSubscribableEventSubscribeOptions|nil
function SubscribableEvent:Subscribe(callback, opts)
	assert(type(callback) == "function", "callback parameter must be a function")
	local opts = type(opts) == "table" and opts or {}
	local index = self.NextIndex
	self.NextIndex = self.NextIndex + 1

	---@type LeaderLibSubscribableEventNode
	local sub = {
		Callback = callback,
		Index = index,
		Priority = opts.Priority or 100,
		Once = opts.Once or false,
		Options = {}
	}

	DoSubscribe(self, sub)
	return index
end

---@param self LeaderLibSubscribableEvent
---@param node LeaderLibSubscribableEventNode
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

	fprint(LOGLEVEL.WARNING, "[LeaderLib:SubscribableEvent] Attempted to remove subscriber ID %s for event '%s', but no such subscriber exists (maybe it was removed already?)", indexOrCallback, self.Name)
	return false
end

function SubscribableEvent:StopPropagation()
	self.StopInvoke = true
end

---@param sub LeaderLibSubscribableEvent
---@param resultsTable table
---@vararg any
local function InvokeCallbacks(sub, resultsTable, ...)
	local cur = sub.First
	local gatherResults = resultsTable ~= nil
	local result = _INVOKERESULT.Success
	while cur ~= nil do
		if sub.StopInvoke then
			result = _INVOKERESULT.Handled
			break
		end

		local b, result = xpcall(cur.Callback, debug.traceback, ...)
		if not b then
			fprint(LOGLEVEL.ERROR, "[LeaderLib:SubscribableEvent] Error while dispatching event %s:\n%s", sub.Name, result)
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
	end
	return result
end

---@vararg any
---@return any[]|LeaderLibSubscribableEventInvokeResult result Returns either an array of results, if GatherResults is true, or a string indicating the result (Success, Handled, or Error).
function SubscribableEvent:Invoke(...)
	local result = nil
	local cur = self.First
	if cur then
		if self.GatherResults then
			local results = {}
			InvokeCallbacks(self, results, ...)
			result = results
		else
			result = InvokeCallbacks(self, nil, ...)
		end
	end
	self.StopInvoke = false
	return result
end

Classes.SubscribableEvent = SubscribableEvent