if Testing == nil then
	Testing = {}
end

Testing.Active = false

---@param id string
---@param operations fun(self:LuaTest)[]
---@param params LuaTestParams|nil
---@return LuaTest
function Testing.CreateTest(id, operations, params)
	return Classes.LuaTest.Create(id, operations, params)
end

function Testing.WriteResults(uuid, results)
	if results and #results > 0 then
		local fileName = string.format("Tests/%s.lua", uuid)
		--GameHelpers.IO.SaveJsonFile(fileName, results)
		--GameHelpers.IO.SaveFile(fileName, StringHelpers.Join("\n", results, false, function(k,v) return Lib.serpent.block(v) end))
		local text = string.format("Test = \"%s\"\n", uuid)
		GameHelpers.IO.SaveFile(fileName, text .. "Results = " .. Lib.serpent.block(results))
		Ext.Print("Saved test results to", fileName)
	end
	Testing.Active = false
end

local _runningTest = {
	---@type LuaTest
	Current = nil,
	Length = 0,
	Index = 1,
	UUID = "",
	Tests = {},
	Results = {},
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

	local tests = tbl

	if tbl.Type == "LuaTest" then
		tests = {tbl}
	end

	if tests[1] and tests[1].Type == "LuaTest" then
		local testUUID = string.format("%s", testingName or Ext.MonotonicTime())
		_runningTest = {
			Tests = tests,
			Current = tests[1],
			Length = #tests,
			Index = 1,
			UUID = testUUID,
			Results = {}
		}

		if _runningTest.Current then
			_runningTest.Current:Reset()
		end
	
		Testing.Active = true
	else
		Ext.Dump(tests)
		Ext.PrintError("[TestingSystem] Tests is an invalid table. Should be an array of LuaTest tables.")
	end
end

function Testing.Stop()
	Testing.Active = false
	if _runningTest and _runningTest.Length > 0 then
		local co,isMain = coroutine.running()
		if co and not isMain then
			pcall(coroutine.close, co)
		end
		
		Testing.WriteResults(_runningTest.UUID, _runningTest.Results)
	end
end

RegisterTickListener(function(e)
	if Testing.Active then
		local test = _runningTest.Current
		if test then
			if test.State == -1 then
				test:Run()
			elseif test.State == 2 or test.Failed then
				if test.Failed then
					_runningTest.Results[#_runningTest.Results+1] = {
						ID = test.ID,
						Errors = test.Errors,
						Success = false
					}
				else
					_runningTest.Results[#_runningTest.Results+1] = {
						ID = test.ID,
						Success = true
					}
				end
				_runningTest.Current:Dispose()
				_runningTest.Index = _runningTest.Index + 1
				_runningTest.Current = _runningTest.Tests[_runningTest.Index]
				if _runningTest.Current then
					_runningTest.Current:Reset()
				end
			end
		else
			_runningTest.Index = _runningTest.Index + 1
			_runningTest.Current = _runningTest.Tests[_runningTest.Index]
			test = _runningTest.Current
			if _runningTest.Current then
				_runningTest.Current:Reset()
			end
		end

		Testing.OnLoop()

		if test == nil then
			Testing.Active = false
			Testing.WriteResults(_runningTest.UUID, _runningTest.Results)
		end
	end
end)

---@alias TestingSystemGetDescriptionCallback fun(id, ...:string):string
---@alias TestingSystemGetTestsCallback fun(id:string, ...:string):LuaTest[]

---@type table<string, {Description:string|TestingSystemGetDescriptionCallback, Tests:LuaTest[]|TestingSystemGetTestsCallback}>
local _consoleCommandTests = {}

---@param id string
---@param test LuaTest|LuaTest[]|TestingSystemGetTestsCallback
---@param description string|TestingSystemGetDescriptionCallback|nil
function Testing.RegisterConsoleCommandTest(id, test, description)
	local t = type(test)
	local desc = description or ""
	if t == "table" then
		if test.Type == "LuaTest" then
			id = id or test.ID
			_consoleCommandTests[id] = {Description=desc, Tests={test}}
		elseif test[1] then
			_consoleCommandTests[id] = {Description=desc, Tests=test}
		end
	elseif t == "function" then
		_consoleCommandTests[id] = {Description=desc, Tests=test}
	end
end

Ext.RegisterConsoleCommand("test", function (cmd, id, ...)
	if id == "help" then
		Ext.Print("[test] Available tests:")
		Ext.Print("==========")
		for id,data in pairs(_consoleCommandTests) do
			if type(data.Description) == "function" then
				fprint(LOGLEVEL.DEFAULT, "\"%s\": %s", id, data.Description(id, ...))
			else
				fprint(LOGLEVEL.DEFAULT, "\"%s\": %s", id, data.Description)
			end
		end
		Ext.Print("==========")
		Ext.Print("Run a test with the command:")
		Ext.Print("!test id subid")
		Ext.Print("(subid optional, depending on the above)")
	else
		local data = _consoleCommandTests[id]
		if data then
			if type(data.Tests) == "function" then
				local tests = data.Tests(id, ...)
				if type(tests) == "table" then
					Testing.RunTests(tests, id)
				else
					fprint(LOGLEVEL.ERROR, "[test] Failed to get table from Tests function for test id (%s)", id)
				end
			else
				Testing.RunTests(data.Tests, id)
			end
		end
	end
end)