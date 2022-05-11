---@class SubscribableEventArgs
---@field StopPropagation fun(self:SubscribableEventArgs):void

---@class RuntimeSubscribableEventArgs
---@field Handled boolean
---@field KeyOrder string[]|nil When unpacking, this is the specific order to unpack values in.
---@field Args table<string,any> The table of args used to create this instance.
local SubscribableEventArgs = {
	Type = "SubscribableEventArgs"
}

function SubscribableEventArgs:StopPropagation()
	self.Handled = true
end

---@param args table|nil
---@param unpackedKeyOrder string[]|nil
---@return RuntimeSubscribableEventArgs
function SubscribableEventArgs:Create(args, unpackedKeyOrder)
	local params = {
		Handled = false,
		--The table of args used to create this instance.
		Args = args,
		--When unpacking, this is the specific order to unpack values in.
		KeyOrder = unpackedKeyOrder,
	}
	if type(args) == "table" then
		for k,v in pairs(args) do
			params[k] = v
		end
	end
	setmetatable(params, {
		__index = SubscribableEventArgs
	})
	return params
end

---Unpack the event args to separate values, using a specific key order.
---This can be used when invoking older listeners that don't access parameters from the event args table directly.
---@param keyOrder string[]|nil
function SubscribableEventArgs:Unpack(keyOrder)
	keyOrder = keyOrder or self.KeyOrder
	if type(keyOrder) == "table" then
		local temp = {}
		for i=1,#keyOrder do
			local key = keyOrder[i]
			if self.Args[key] then
				temp[#temp+1] = self[key]
			end
		end
		return table.unpack(temp)
	else
		--fprint(LOGLEVEL.WARNING, "[SubscribableEventArgs:Unpack] Missing a KeyOrder table for event args. Cannot unpack.")
		return table.unpack(self.Args)
	end
end

Classes.SubscribableEventArgs = SubscribableEventArgs