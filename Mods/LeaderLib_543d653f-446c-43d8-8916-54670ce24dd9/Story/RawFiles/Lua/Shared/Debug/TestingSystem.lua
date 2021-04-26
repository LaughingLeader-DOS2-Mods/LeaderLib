---@class LuaTest
local LuaTest = {
	Type = "LuaTest",
	Name = "",
	Context = Ext.IsClient() and "CLIENT" or "SERVER",
	---@type function
	Operation = nil,
	---@type function
	OnComplete = nil,
	Success = 0,
	Active = false,
}
LuaTest.__index = LuaTest

---@param name string
---@param operationCallback function
---@param onComplete function|nil
---@return LuaTest
function LuaTest:Create(name, operationCallback, onComplete)
    local this =
    {
		Name = name,
		Operation = operationCallback,
		OnComplete = onComplete,
		Success = 0,
		Active = false
	}
	setmetatable(this, self)
    return this
end

---@return boolean
function LuaTest:Run(...)
	self.Active = true
	fprint(LOGLEVEL.TRACE, "[LeaderLib:LuaTest:Run] Running test (%s) Time(%s)", self.Name, Ext.MonotonicTime())
	self.Success = 0
	local b,result = xpcall(self.Operation, debug.traceback, self, ...)
	if not b then
		fprint(LOGLEVEL.ERROR, "[LeaderLib:LuaTest:Run] Error with test (%s) Time(%s)\n%s", self.Name, Ext.MonotonicTime(), result)
		self.Success = -1
		self.Active = false
		return false
	end
	if result == true then
		self.Success = 1
		if self.OnComplete then
			local b2,result2 = xpcall(self.OnComplete, debug.traceback, self, ...)
			if not b2 then
				fprint(LOGLEVEL.ERROR, "[LeaderLib:LuaTest:Run] Error with test.OnComplete (%s) Time(%s)\n%s", self.Name, Ext.MonotonicTime(), result2)
				Ext.PrintError(result2)
			end
		end
		fprint(LOGLEVEL.TRACE, "[LeaderLib:LuaTest:Run] Completed test (%s) Time(%s) Success(1)", self.Name, Ext.MonotonicTime())
		self.Active = false
		return true
	end
	fprint(LOGLEVEL.TRACE, "[LeaderLib:LuaTest:Run] Completed test (%s) Time(%s) Success(0)", self.Name, Ext.MonotonicTime())
	self.Success = 0
	self.Active = false
	return true
end

if Testing == nil then
	Testing = {}
end

---@param name string
---@param operationCallback function
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