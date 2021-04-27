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
	return string.format("%sExpected (%s)[%s] Actual (%s)[%s]%s", msg, v1, t1, v2, t2, extraMsg ~= nil and string.format("\n%s", extraMsg) or "")
end
function LuaTest:Failure(msg, level)
	self:Done()
	error(string.format("[LuaTest:%s] %s", self.Name, msg), (level or 1) + 1)
end

function LuaTest:AssertEquals(target, expected, extraMsg, deepTableComparison)
	local t1 = type(target)
	local t2 = type(expected)
	if t1 ~= t2 then
		self:Failure(ValueErrorMessage("Values not equal. ", target, expected, t1, t2, extraMsg), 2)
	elseif t1 == "table" and t2 == "table" then
		if not Common.TableEquals(target, expected, deepTableComparison) then
			self:Failure(ValueErrorMessage("Values not equal. ", target, expected, t1, t2, extraMsg), 2)
		end
	elseif target ~= expected then
		self:Failure(ValueErrorMessage(t"Values not equal. ", target, expected, t1, t2, extraMsg), 2)
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
	self:Failure(ValueErrorMessage("Values are equal. ", target, expected, t1, t2, extraMsg), 2)
end

function LuaTest:Complete(success, ...)
	self.Success = success and 1 or -1
	if self.OnComplete then
		local b2,result2 = xpcall(self.OnComplete, debug.traceback, self, ...)
		if not b2 then
			fprint(LOGLEVEL.ERROR, "[LuaTest:%s] Error with test.OnComplete. Time(%s)\n%s", self.Name, Ext.MonotonicTime(), result2)
			Ext.PrintError(result2)
		end
	end
	fprint(LOGLEVEL.TRACE, "[LuaTest:%s] Completed test. Time(%s) Success(1)", self.Name, Ext.MonotonicTime())
	self:Done()
	return self.Success
end

---@param self LuaTest
local function RunOperation(self, func, ...)
	local b,result = xpcall(func, debug.traceback, self, ...)
	if not b then
		self:Failure(string.format("[LuaTest:%s] Error with test. Time(%s)\n%s", self.Name, Ext.MonotonicTime(), result), 2)
		return nil
	end
	return result
end

function LuaTest:Done()
	self.Active = false
	if self.Cleanup then
		local b,result = xpcall(self.Cleanup, debug.traceback, self)
		if not b then
			fprint(LOGLEVEL.ERROR, "[LuaTest:%s] Time(%s) Error invoking Cleanup function:\n%s", self.Name, Ext.MonotonicTime(), result)
		end
	end
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
		for k,v in pairs(self.Operation) do
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

if Testing == nil then
	Testing = {}
end

---@param name string
---@param operationCallback LuaTestOperationCallback
---@return LuaTest
function Testing.CreateTest(name, operation)
	return LuaTest:Create(name, operation)
end

---@param tbl LuaTest[]
---@param delay integer|nil
function Testing.RunTests(tbl, delay, ...)
	local args = {...}
	if delay and delay > 0 then
		local timerLaunchFunc = Ext.IsServer() and StartOneshotTimer or UIExtensions.StartTimer
		local i = 0
		local runNext = nil
		local launchTimer = function(test)
			if test then
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib:Testing.RunTests] Test (%s) complete. Success(%s)", test.Name, test.Success)
			end
			timerLaunchFunc(string.format("LuaTesting_%s", Ext.MonotonicTime()), delay, runNext)
		end
		runNext = function()
			i = i + 1
			local test = tbl[i]
			if test then
				test.OnComplete = launchTimer
				test:Run(table.unpack(args))
			end
		end
		launchTimer()
	else
		for k,v in pairs(tbl) do
			v:Run()
		end
	end
end