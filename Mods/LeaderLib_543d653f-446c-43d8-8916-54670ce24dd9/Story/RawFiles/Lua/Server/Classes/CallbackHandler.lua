---@class CallbackHandler
local CallbackHandler = {
	Type = "CallbackHandler",
	---@type function
	Callback = nil,
	CanInvoke = true,
	InvokeIsFunction = false
}
CallbackHandler.__index = CallbackHandler

function CallbackHandler:Create(callback, canInvoke)
	local this = {
		Callback = callback
	}
	if canInvoke ~= nil then
		this.CanInvoke = canInvoke
		if type(canInvoke) == "function" then
			this.InvokeIsFunction = true
		end
	end
	setmetatable(this, CallbackHandler)
	return this
end

function CallbackHandler:Invoke(...)
	local canInvoke = self.CanInvoke
	if self.InvokeIsFunction then
		canInvoke = self.CanInvoke()
	end
	if canInvoke then
		self.Callback(...)
	end
end

Classes.CallbackHandler = CallbackHandler