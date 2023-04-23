local _EXTVERSION = Ext.Utils.Version()
local _ISCLIENT = Ext.IsClient()

if Testing == nil then
	---@class LeaderLibTestingSystem
	Testing = {}
end

Testing.Active = false

---@param id string
---@param operations fun(self:LuaTest)[]
---@param params LuaTestParams|nil
---@return LuaTest
function Testing.CreateTest(id, operations, params)
	return Classes.LuaTest:Create(id, operations, params)
end

function Testing.WriteResults(uuid, results)
	if results and #results > 0 then
		local fileName = string.format("Tests/%s.lua", uuid)
		--GameHelpers.IO.SaveJsonFile(fileName, results)
		--GameHelpers.IO.SaveFile(fileName, StringHelpers.Join("\n", results, false, function(k,v) return Lib.serpent.block(v) end))
		local text = string.format("Test = \"%s\"\n", uuid)
		GameHelpers.IO.SaveFile(fileName, text .. "Results = " .. Lib.serpent.block(results))
		Ext.Utils.Print("Saved test results to", fileName)
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

---Emit a signal to whatever test is currently running.
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
			---@diagnostic disable-next-line
			coroutine.close(co)
		end
	end

	local tests = tbl

	if tbl.Type == "LuaTest" then
		tests = {tbl}
	end

	if tests[1] and tests[1].Type == "LuaTest" then
		local testUUID = string.format("%s", testingName or Ext.Utils.MonotonicTime())
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
		Ext.Utils.PrintError("[TestingSystem] Tests is an invalid table. Should be an array of LuaTest tables.")
	end
end

function Testing.Stop()
	Testing.Active = false
	if _runningTest and _runningTest.Length > 0 then
		local co,isMain = coroutine.running()
		if co and not isMain then
			---@diagnostic disable-next-line
			pcall(coroutine.close, co)
		end
		
		Testing.WriteResults(_runningTest.UUID, _runningTest.Results)
		_runningTest = {}
	end
end

--Dispose/cleanup tests before lua gets reset, so test characters don't stick around
Events.BeforeLuaReset:Subscribe(function (e)
	if Testing.Active then
		if _runningTest.Current then
			_runningTest.Current:Dispose()
		end
		Testing.Stop()
	end
end, {Priority=999})

Ext.Events.Tick:Subscribe(function (e)
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
						Success = true,
						Message = not StringHelpers.IsNullOrEmpty(test.SuccessMessage) and test.SuccessMessage or nil
					}
				end
				test:Dispose()
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
			Testing.Stop()
		end
	end
end)

---@alias TestingSystemRegisterTestCallback (fun(test:LuaTest):boolean|nil)
---@alias TestingSystemRegisterTestArray table<any, TestingSystemRegisterTestCallback>
---@alias TestingSystemGetTestsCallbackReturnType LuaTest|LuaTest[]|nil
---@alias TestingSystemGetDescriptionCallback fun(id, ...:string):string
---@alias TestingSystemGetTestsCallback fun(id:string, ...:string):TestingSystemGetTestsCallbackReturnType

---@type table<string, {ID:string, Description:string|TestingSystemGetDescriptionCallback, Tests:LuaTest[]|TestingSystemGetTestsCallback}>
local _consoleCommandTests = {}

---@param id string
---@param test LuaTest|LuaTest[]|(TestingSystemGetTestsCallback)
---@param description? string|(TestingSystemGetDescriptionCallback)
function Testing.RegisterConsoleCommandTest(id, test, description)
	local t = type(test)
	local desc = description or ""
	if t == "table" then
		if test.Type == "LuaTest" then
			id = id or test.ID
			_consoleCommandTests[string.lower(id)] = {ID=id, Description=desc, Tests={test}}
		elseif test[1] then
			_consoleCommandTests[string.lower(id)] = {ID=id, Description=desc, Tests=test}
		end
	elseif t == "function" then
		_consoleCommandTests[string.lower(id)] = {ID=id, Description=desc, Tests=test}
	end
end

local function _GetLuaTest(data, ...)
	local t = type(data)
	if t == "function" then
		local tests = data.Tests(...)
		local returnType = type(tests)
		if returnType == "table" then
			return tests
		end
	elseif t == "table" then
		return data
	end
end

---@param id string
---@param description? string|(TestingSystemGetDescriptionCallback)
function Testing.AddCommandGroup(id, description)
	local desc = description or ""
	local cmdID = string.lower(id)
	local getSubTest = function (id, subid)
		local group = _consoleCommandTests[cmdID]
		if group then
			local tests = group.SubTests
			if StringHelpers.Equals(subid, "all", true, true) then
				local runTests = {}
				for _,tbl in pairs(tests) do
					for _,v in ipairs(tbl) do
						runTests[#runTests+1] = _GetLuaTest(v.Tests, id, subid)
					end
				end
				return runTests
			else
				local sid = string.lower(subid)
				local test = tests[sid]
				if test then
					return _GetLuaTest(test.Tests, id, subid)
				else
					fprint(LOGLEVEL.WARNING, "[test:%s] No test for ID (%s)", id, subid)
				end
			end
		end
	end
	_consoleCommandTests[cmdID] = {
		ID=id,
		Description=function (...)
			local group = _consoleCommandTests[cmdID]
			local tests = group.SubTests
			local testNames = {}
			for bid,v in pairs(tests) do
				testNames[#testNames+1] = " " .. bid
			end
			if #testNames > 0 then
				table.sort(testNames)
				return "\n" .. StringHelpers.Join("\n", testNames)
			else
				return "No registered tests."
			end
		end,
		Tests=getSubTest,
		SubTests = {}
	}
end

---@param groupId string
---@param id string
---@param test LuaTest|LuaTest[]|(TestingSystemGetTestsCallback)
---@param description? string|(TestingSystemGetDescriptionCallback)
function Testing.AddSubCommand(groupId, id, test, description)
	local group = _consoleCommandTests[string.lower(groupId)]
	local t = type(test)
	local desc = description or ""
	local sid = string.lower(id)
	if t == "table" then
		if test.Type == "LuaTest" then
			id = id or test.ID
			sid = string.lower(id)
			group.SubTests[sid] = {ID=id, Description=desc, Tests={test}}
		elseif test[1] then
			group.SubTests[sid] = {ID=id, Description=desc, Tests=test}
		end
	elseif t == "function" then
		group.SubTests[sid] = {ID=id, Description=desc, Tests=test}
	end
end

Ext.RegisterConsoleCommand("test", function (cmd, id, ...)
	local cmdId = nil
	if id then
		cmdId = string.lower(id)
	end
	if not cmdId or cmdId == "help" then
		Ext.Utils.Print("[test] Available tests:")
		Ext.Utils.Print("==========")
		for id,data in pairs(_consoleCommandTests) do
			if type(data.Description) == "function" then
				fprint(LOGLEVEL.DEFAULT, "\"%s\": %s", id, data.Description(id, ...))
			else
				fprint(LOGLEVEL.DEFAULT, "\"%s\": %s", id, data.Description)
			end
		end
		Ext.Utils.Print("==========")
		Ext.Utils.Print("Run a test with the command:")
		Ext.Utils.Print("!test id subid")
		Ext.Utils.Print("(subid optional, depending on the above)")
	else
		local data = _consoleCommandTests[cmdId]
		if data then
			if type(data.Tests) == "function" then
				local tests = data.Tests(cmdId, ...)
				local returnType = type(tests)
				if returnType == "table" then
					Testing.RunTests(tests, cmdId)
				else
					fprint(LOGLEVEL.ERROR, "[test] Failed to get table from Tests function for test id (%s). Function return type was (%s)", id, returnType)
				end
			else
				Testing.RunTests(data.Tests, data.ID)
			end
		end
	end
end)