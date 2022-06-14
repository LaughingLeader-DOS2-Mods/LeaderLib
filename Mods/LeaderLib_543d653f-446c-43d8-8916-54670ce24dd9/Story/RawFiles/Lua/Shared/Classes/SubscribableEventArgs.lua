---@class SubscribableEventArgs
---@field StopPropagation fun(self:SubscribableEventArgs) Stop the event from continuing on to other registered listeners.
---@field Dump fun(self:SubscribableEventArgs) Dumps the event's parameters to the console.

---@class RuntimeSubscribableEventArgs
---@field Handled boolean
---@field KeyOrder string[]|nil When unpacking, this is the specific order to unpack values in.
---@field GetArg SubscribableEventGetArgFunction|nil
---@field Args table<string,any> The table of args used to create this instance.
local SubscribableEventArgs = {
	Type = "SubscribableEventArgs"
}

function SubscribableEventArgs:StopPropagation()
	self.Handled = true
end

---@param self RuntimeSubscribableEventArgs
---@param key string
local function _TryGetArg(self, key)
	if self.GetArg then
		local b,value = pcall(self.GetArg, key, self.Args[key])
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

---@param args table|nil
---@param unpackedKeyOrder string[]|nil
---@param getArg SubscribableEventGetArgFunction|nil
---@param customMeta SubscribableEventCustomMetatable|nil Automatically set if the args table had key set for '__metatable'
---@return RuntimeSubscribableEventArgs
function SubscribableEventArgs:Create(args, unpackedKeyOrder, getArg, customMeta)
	local _private = {
		Handled = false,
		--The table of args used to create this instance.
		Args = args,
		--When unpacking, this is the specific order to unpack values in.
		KeyOrder = unpackedKeyOrder,
		GetArg = getArg
	}
	local eventArgs = {}
	if type(args) == "table" then
		for k,v in pairs(args) do
			eventArgs[k] = v
		end
	end
	setmetatable(eventArgs, {
		__index = function (_,k)
			if _private[k] ~= nil then
				return _private[k]
			end
			if customMeta and customMeta.__index then
				local b,value = xpcall(customMeta.__index, debug.traceback, eventArgs, k)
				if b and value ~= nil then
					return value
				elseif not b then
					Ext.PrintError(value)
				end
			end
			return SubscribableEventArgs[k]
		end,
		__newindex = function (_, k, v)
			if customMeta and customMeta.__newindex then
				local b,value = xpcall(customMeta.__newindex, debug.traceback, self, k, v)
				if not b then
					Ext.PrintError(value)
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

---Unpack the event args to separate values, using a specific key order.
---This can be used when invoking older listeners that don't access parameters from the event args table directly.
---@param keyOrder string[]|nil
function SubscribableEventArgs:Unpack(keyOrder)
	---@type string[]
	local keyOrder = keyOrder or self.KeyOrder
	local temp = {}
	local length = 0
	if type(keyOrder) == "table" then
		for i=1,#keyOrder do
			length = length + 1
			local key = keyOrder[i]
			if self.Args[key] ~= nil then
				temp[length] = _TryGetArg(self, key)
			end
		end
	else
		--Unpack unordered args as a fallback. Should work fine if the event only has one arg anyway.
		for _,v in pairs(self.Args) do
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
	fprint(LOGLEVEL.TRACE, Lib.serpent.block(self.Args, {SimplifyUserdata = true}))
end

function SubscribableEventArgs:DumpExport()
	return Lib.serpent.block(self.Args, {SimplifyUserdata = true})
end

Classes.SubscribableEventArgs = SubscribableEventArgs