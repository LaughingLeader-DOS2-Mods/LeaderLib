---@class LuaTestParams
---@field ID string
---@field OnComplete fun(self:LuaTest)
---@field Cleanup fun(self:LuaTest)
---@field Params table Params to pass to invoked tasks.

---@class LuaTest:LuaTestParams
---@field Active boolean
---@field State integer
---@field Thread thread
---@field Tasks function[]
---@field CurrentTaskIndex integer
local LuaTest = {
	ThrowErrors = true,
	ErrorMessage = "",
	SuccessMessage = "",
}
setmetatable(LuaTest, {
	__call = function (_, ...)
		return LuaTest:Create(...)
	end
})

local _NilThread = {}

---@param id string
---@param tasks function[]
---@param params LuaTestParams|nil
---@return LuaTest
function LuaTest.Create(id, tasks, params)
	local inst = {
		ID = id or "",
		Tasks = tasks or {},
		Thread = _NilThread,
		CurrentTaskIndex = 1,
		Params = {},
		Active = false,
		State = -1,
		ErrorMessage = "",
		SuccessMessage = "",
	}
	if type(params) == "table" then
		for k,v in pairs(params) do
			inst[k] = v
		end
	end
	setmetatable(inst, {
		__index = LuaTest
	})
	return inst
end

local function Done(self)
	self.Active = false
	self.State = 2
end

function LuaTest:Pause()
	self.State = 0
	if self.Thread == coroutine.running() then
		coroutine.yield()
	end
end

---@param ms number
function LuaTest:Wait(ms)
	self.WakeupTime = Ext.MonotonicTime() + ms
	self:Pause()
end

function LuaTest:CheckForWake()
	if self.State == 0 and self.WakeupTime and Ext.MonotonicTime() >= self.WakeupTime then
		if self:Resume() then
			return true
		end
	end
	return false
end

---@param id string
---@param timeout number|nil
function LuaTest:WaitForSignal(id, timeout)
	self.NextSignal = id
	if timeout then
		self.WakeupTime = Ext.MonotonicTime() + timeout
	end
	self:Pause()
end

---@param id string
function LuaTest:OnSignal(id)
	if self.NextSignal == id then
		if self:Resume() then
			return true
		end
	end
	return false
end

function LuaTest:Resume()
	if self.Thread ~= _NilThread then
		local currentThread,isMain = coroutine.running()
		if currentThread == nil or isMain or coroutine.status(currentThread) ~= "running" then
			self.State = 1
			self.NextSignal = nil
			self.WakeupTime = nil
			coroutine.resume(self.Thread, self, table.unpack(self.Params))
			return true
		else
			Ext.PrintError("coroutine is currently occupied with a different thread.")
		end
	end
	return false
end

local function ValueErrorMessage(msg, target, expected, t1, t2, extraMsg)
	local v1 = target
	local v2 = expected
	if t1 == "table" then
		v1 = Lib.serpent.block(target)
	end
	if t2 == "table" then
		v2 = Lib.serpent.block(expected)
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
	Done(self)
	self.ErrorMessage = string.format("[LuaTest:%s] %s", self.ID, msg)
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
	if self.Active then
		fprint(LOGLEVEL.TRACE, "[LuaTest:%s] Test complete.", self.ID)
		Done(self)
		if self.OnComplete then
			local b,err = xpcall(self.OnComplete, debug.traceback, self, ...)
			if not b then
				fprint(LOGLEVEL.ERROR, "[LuaTest:%s] Error running OnComplete. Time(%s)\n%s", self.ID, Ext.MonotonicTime(), err)
			end
		end
	end
end

function LuaTest:Run()
	if self.Thread == _NilThread then
		self.Active = true
		self.State = 1
		local currentThread,isMain = coroutine.running()
		if currentThread == nil or isMain then
			if self.CurrentTaskIndex <= #self.Tasks then
				local task = self.Tasks[self.CurrentTaskIndex]
				if task then
					self.Thread = coroutine.create(function (...)
						local b,err = xpcall(task, debug.traceback, ...)
						if not b then
							Ext.PrintError(err)
						end
						self.CurrentTaskIndex = self.CurrentTaskIndex + 1
						self.Thread = _NilThread
						self.State = -1
					end)
					coroutine.resume(self.Thread, self, table.unpack(self.Params))
				end
			else
				fprint(LOGLEVEL.DEFAULT, "[LuaTest] Test (%s) is finished!", self.ID)
				self:Complete(true)
			end
		else
			error("coroutine is currently occupied with a different thread.", 2)
		end
	end
end

function LuaTest:Dispose()
	self.State = -1
	self.Active = false
	self.CurrentTaskIndex = 1
	self.Thread = _NilThread
	if self.Cleanup then
		local b,err = xpcall(self.Cleanup, debug.traceback, self)
		if not b then
			fprint(LOGLEVEL.ERROR, "[LuaTest:%s] Error invoking Cleanup function:\n%s", self.ID, err)
		end
	end
end

Classes.LuaTest = LuaTest