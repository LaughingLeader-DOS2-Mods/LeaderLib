if GameHelpers.DB == nil then
	GameHelpers.DB = {}
end

local function GetArity(arity)
	if arity == 1 then
		return nil
	elseif arity == 2 then
		return nil,nil
	elseif arity == 3 then
		return nil,nil,nil
	elseif arity == 4 then
		return nil,nil,nil,nil
	elseif arity == 5 then
		return nil,nil,nil,nil,nil
	elseif arity == 6 then
		return nil,nil,nil,nil,nil,nil
	elseif arity == 7 then
		return nil,nil,nil,nil,nil,nil,nil
	elseif arity == 8 then
		return nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 9 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 10 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 11 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 12 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 13 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 14 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 15 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 16 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 17 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 18 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 19 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	elseif arity == 20 then
		return nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	else
		local nilColumns = {}
		for i=1,arity do
			table.insert(nilColumns, "nil")
		end
		return table.unpack(nilColumns)
	end
end

local function SortDatabase(name, arity, sortColumn)
	local b,result = xpcall(function()
		local db = Osi[name]:Get(GetArity(arity))
		if db ~= nil then
			table.sort(db, function(a,b)
				return a[sortColumn] < b[sortColumn]
			end)
		end
		return db
	end, debug.traceback)
	if not b then
		Ext.PrintError("[LeaderLib:GameHelpers.DB.SortDatabase] Error sorting database:", name)
		Ext.PrintError(result)
	else
		if result ~= nil then
			Osi[name]:Delete(GetArity(arity))
			for i,v in pairs(result) do
				Osi[name][i](v)
			end
			--PrintDebug(name, Ext.JsonStringify(Osi[name]:Get(GetArity(arity))))
		end
	end
end
GameHelpers.DB.SortDatabase = SortDatabase
Ext.NewCall(SortDatabase, "LeaderLib_Ext_SortDatabase", "(STRING)_DatabaseName, (INTEGER)_Arity, (INTEGER)_SortByColumn")

function SortDictionary(id)
	local b,result = xpcall(function()
		--DB_LeaderLib_Dictionary_Data(_DictionaryID, _Index, _CheckID, _CheckDisplayName)
		local db = Osi.DB_LeaderLib_Dictionary_Data:Get(id, nil, nil, nil)
		if db ~= nil then
			table.sort(db, function(a,b)
				return a[4] < b[4]
			end)
		end
		Osi.DB_LeaderLib_Dictionary_Data:Delete(id, nil, nil, nil)

		local index = 0
		for i,v in pairs(db) do
			Osi.DB_LeaderLib_Dictionary_Data(id, index, v[3], v[4])
			index = index + 1
		end
		--PrintDebug(id, Ext.JsonStringify(Osi.DB_LeaderLib_Dictionary_Data:Get(id, nil, nil, nil)))
		return true
	end, debug.traceback)
	if not b then
		Ext.PrintError("[LeaderLib:SortDictionary] Error sorting dictionary:", id)
		Ext.PrintError(result)
	end
end

--print(Ext.JsonStringify(Osi.DB_LeaderLib_Dictionary_Data:Get(nil, nil, nil, nil)))

---@param databaseName string
---@param value any
---@param arity integer|nil Defaults to 1 if not set.
---@param checkColumn integer|nil Defaults to 1 if not set.
---@return boolean
function GameHelpers.DB.HasValue(databaseName, value, arity, checkColumn)
	arity = arity or 1
	checkColumn = checkColumn or 1
	local b,result = xpcall(function()
		local db = Osi[databaseName]:Get(GetArity(arity))
		if db ~= nil and #db > 0 then
			for i,entry in pairs(db) do
				print(entry[checkColumn], value)
				if entry[checkColumn] == value then
					return true
				end
			end
		end
		return false
	end, debug.traceback)
	if not b then
		fprint(LOGLEVEL.ERROR, "[LeaderLib:GameHelpers.DB.HasValue] Error checking database %s(%s):\n%s", databaseName, arity, result)
		return false
	else
		return result
	end
end

---@param database table
---@param value any
---@param checkColumn integer|nil Defaults to 1 if not set.
---@return boolean
function GameHelpers.DB.TableHasValue(db, value, checkColumn)
	local b,result = xpcall(function()
		if db ~= nil and #db > 0 then
			checkColumn = checkColumn or 1
			for i,entry in pairs(db) do
				if entry[checkColumn] == value then
					return true
				end
			end
		end
		return false
	end, debug.traceback)
	if not b then
		fprint(LOGLEVEL.ERROR, "[LeaderLib:GameHelpers.DB.HasValue] Error checking database %s(%s):\n%s", databaseName, arity, result)
		return false
	else
		return result
	end
end