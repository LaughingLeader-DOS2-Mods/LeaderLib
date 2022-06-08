if Testing == nil then
	Testing = {}
end

Testing.Results = {}
Testing.Active = false

---@param id string
---@param operations fun(self:LuaTest)[]
---@param params LuaTestParams|nil
---@return LuaTest
function Testing.CreateTest(id, operations, params)
	return Classes.LuaTest.Create(id, operations, params)
end

function Testing.WriteResults(uuid)
	if Testing.Results[uuid] and #Testing.Results[uuid] > 0 then
		local fileName = string.format("Tests/%s-%s.txt", uuid, Ext.MonotonicTime())
		GameHelpers.IO.SaveFile(fileName, StringHelpers.Join("\n", Testing.Results[uuid], false))
		Ext.Print("Saved test results to", fileName)
		Testing.Results[uuid] = nil
	end
	Testing.Active = false
end

local _runningTest = {
	---@type LuaTest
	Current = nil,
	Length = 0,
	Index = 1,
	UUID = "",
	Tests = {}
}

---@param id string
function Testing.EmitSignal(id)
	if _runningTest.Current then
		_runningTest.Current:OnSignal(id)
	end
end

function Testing.OnLoop()
	if _runningTest.Current and _runningTest.Current.State == 0 then
		_runningTest.Current:CheckForWake()
	end
end

---@param tbl LuaTest[]
---@param testingName string
function Testing.RunTests(tbl, testingName)
	if Testing.Active then
		Timer.Cancel("LeaderLib_Testing_SaveResults")
		Timer.Cancel("LeaderLib_LuaTesting_RunNext")
		local co,isMain = coroutine.running()
		if co and not isMain then
			coroutine.close(co)
		end
	end

	local testUUID = string.format("%s", testingName or Ext.MonotonicTime())
	Testing.Results[testUUID] = {}

	_runningTest = {
		Current = tbl[1],
		Length = #tbl,
		Index = 1,
		UUID = testUUID,
		Tests = tbl
	}

	Testing.Active = true
end

RegisterTickListener(function(e)
	if Testing.Active then
		local test = _runningTest.Current
		if test then
			if test.State == -1 then
				test:Run()
			elseif test.State == 2 then
				_runningTest.Current:Dispose()
				_runningTest.Index = _runningTest.Index + 1
				_runningTest.Current = _runningTest.Tests[_runningTest.Index]
			end
		else
			_runningTest.Index = _runningTest.Index + 1
			_runningTest.Current = _runningTest.Tests[_runningTest.Index]
			test = _runningTest.Current
		end

		Testing.OnLoop()

		if test == nil then
			Testing.Active = false
			Testing.WriteResults(Testing.CurrentTestUUID)
		end
	end
end)