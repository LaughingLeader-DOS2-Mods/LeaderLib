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
	local _private = {
		Handled = false,
		--The table of args used to create this instance.
		Args = args,
		--When unpacking, this is the specific order to unpack values in.
		KeyOrder = unpackedKeyOrder,
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
			return SubscribableEventArgs[k]
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
	if type(keyOrder) == "table" then
		for i=1,#keyOrder do
			local key = keyOrder[i]
			if self.Args[key] then
				temp[#temp+1] = self[key]
			end
		end
	else
		--Unpack unordered args as a fallback. Should work fine if the event only has one arg anyway.
		for _,v in pairs(self.Args) do
			temp[#temp+1] = v
		end
	end
	return table.unpack(temp)
end

Classes.SubscribableEventArgs = SubscribableEventArgs