---@alias LuaTestOperationCallback fun(self:LuaTest):boolean
---@alias LuaTestOnCompleteCallback fun(self:LuaTest):boolean

---@class LuaTest
local LuaTest = {
	Type = "LuaTest",
	Name = "",
	Context = Ext.IsClient() and "CLIENT" or "SERVER",
	---@type LuaTestOperationCallback
	Operation = nil,
	---@type LuaTestOnCompleteCallback
	OnComplete = nil,
	---@type LuaTestOperationCallback
	Cleanup = nil,
	Success = 0,
	Active = false,
	ThrowErrors = true,
	ErrorMessage = "",
	SuccessMessage = "",
}
LuaTest.__index = LuaTest

---@param name string
---@param operationCallback LuaTestOperationCallback
---@param params table<string,any>|nil
---@return LuaTest
function LuaTest:Create(name, operationCallback, params)
    local this =
    {
		Name = name,
		Operation = operationCallback,
		OnComplete = nil,
		Cleanup = nil,
		Success = 0,
		Active = false,
		ErrorMessage = "",
		SuccessMessage = "",
	}
	if params and type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, self)
    return this
end

local function ValueErrorMessage(msg, target, expected, t1, t2, extraMsg)
	local v1 = target
	local v2 = expected
	if t1 == "table" then
		v1 = Common.Dump(target)
	end
	if t2 == "table" then
		v2 = Common.Dump(expected)
	end
	if t1 ~= "nil" and t2 ~= "nil" then
		return string.format("%s%s Actual (%s)[%s] Expected (%s)[%s]", (extraMsg ~= nil and string.format("%s ", extraMsg) or ""), msg, v1, t1, v2, t2)
	else
		if v1 == nil and v2 == nil then
			return string.format("%s%s Both values are nil.", (extraMsg ~= nil and string.format("%s ", extraMsg) or ""), msg)
		else
			return string.format("%s%s Actual (%s) Expected (%s)", (extraMsg ~= nil and string.format("%s ", extraMsg) or ""), msg, v1, v2)
		end
	end
end
function LuaTest:Failure(msg, level)
	self:Done()
	self.ErrorMessage = string.format("[LuaTest:%s] %s", self.Name, msg)
	if self.ThrowErrors then
		error(self.ErrorMessage, (level or 1) + 1)
	else
		Ext.PrintError(self.ErrorMessage)
	end
end

function LuaTest:AssertEquals(target, expected, extraMsg, deepTableComparison)
	local t1 = type(target)
	local t2 = type(expected)
	if t1 ~= t2 then
		self:Failure(ValueErrorMessage("Assert failed: values not equal.", target, expected, t1, t2, extraMsg), 3)
	elseif t1 == "table" and t2 == "table" then
		if not Common.TableEquals(target, expected, deepTableComparison) then
			self:Failure(ValueErrorMessage("Assert failed: values not equal.", target, expected, t1, t2, extraMsg), 3)
		end
	elseif target ~= expected then
		self:Failure(ValueErrorMessage("Assert failed: values not equal.", target, expected, t1, t2, extraMsg), 3)
	end
end

function LuaTest:AssertNotEquals(target, expected, extraMsg, deepTableComparison)
	local t1 = type(target)
	local t2 = type(expected)
	if t1 ~= t2 then
		return
	elseif t1 == "table" and t2 == "table" then
		if not Common.TableEquals(target, expected, deepTableComparison) then
			return
		end
	elseif target ~= expected then
		return
	end
	self:Failure(ValueErrorMessage("Values are equal.", target, expected, t1, t2, extraMsg), 2)
end

function LuaTest:Complete(success, ...)
	fprint(LOGLEVEL.TRACE, "[LuaTest:%s] Test complete. Active(%s)", self.Name, self.Active)
	if self.Active then
		self.Success = success == true and 1 or 0
		if self.OnComplete then
			local b2,result2 = xpcall(self.OnComplete, debug.traceback, self, ...)
			if not b2 then
				fprint(LOGLEVEL.ERROR, "[LuaTest:%s] Error with test.OnComplete. Time(%s)\n%s", self.Name, Ext.MonotonicTime(), result2)
				Ext.PrintError(result2)
			end
		end
		fprint(LOGLEVEL.TRACE, "[LuaTest:%s] Completed test. Time(%s) Success(%s)", self.Name, Ext.MonotonicTime(), self.Success)
		self:Done()
	end
	return self.Success == 1
end

function LuaTest:Dispose()
	if self.Cleanup then
		local b,result = xpcall(self.Cleanup, debug.traceback, self)
		if not b then
			fprint(LOGLEVEL.ERROR, "[LuaTest:%s] Time(%s) Error invoking Cleanup function:\n%s", self.Name, Ext.MonotonicTime(), result)
		end
	end
end

function LuaTest:GetResultText()
	if self.Success == 1 then
		if not StringHelpers.IsNullOrEmpty(self.SuccessMessage) then
			return string.format("%s: Passed\n%s", self.Name, self.SuccessMessage)
		else
			return string.format("%s: Passed", self.Name)
		end
	else
		if not StringHelpers.IsNullOrEmpty(self.ErrorMessage) then
			return string.format("%s: Failed\n%s\n", self.Name, self.ErrorMessage)
		else
			return string.format("%s: Failed", self.Name)
		end
	end
	return ""
end

function LuaTest:Done()
	self.Active = false
end

function LuaTest:Wait(ms)
	local co = coroutine.running()
	if co ~= nil then
		local wakeupTime = Testing.CurrentTime + ms
		Testing.Waiting[co] = wakeupTime
		return coroutine.yield(co)
	end
end

---@param self LuaTest
local function RunOperation(self, func, ...)
	local b,result = xpcall(func, debug.traceback, self, ...)
	if not b then
		self:Failure(string.format("[LuaTest:%s] Error with test. Time(%s)\n%s", self.Name, Ext.MonotonicTime(), result), 2)
		return nil
	end
	if result ~= nil then
		return result
	end
	return true
end

---@return boolean
function LuaTest:Run(...)
	self.Active = true
	fprint(LOGLEVEL.TRACE, "[LuaTest:%s] Running test. Time(%s)", self.Name, Ext.MonotonicTime())
	self.Success = 0
	local t = type(self.Operation)
	if t == "table" then
		local successes = 0
		local total = 0
		for _,v in pairs(self.Operation) do
			total = total + 1
			local result = RunOperation(self, v, ...)
			if result ~= nil then
				successes = successes + 1
			end
		end
		if successes >= total then
			return self:Complete(true, ...)
		end
	elseif t == "function" then
		local result = RunOperation(self, self.Operation, ...)
		if result == nil then
			self.Success = -1
			self:Done()
			return false
		else
			return self:Complete(result, ...)
		end
	end
end

return LuaTest