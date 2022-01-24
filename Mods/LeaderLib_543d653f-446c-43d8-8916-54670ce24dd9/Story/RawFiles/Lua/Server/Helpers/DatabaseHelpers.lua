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
			--PrintDebug(name, Common.JsonStringify(Osi[name]:Get(GetArity(arity))))
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
		--PrintDebug(id, Common.JsonStringify(Osi.DB_LeaderLib_Dictionary_Data:Get(id, nil, nil, nil)))
		return true
	end, debug.traceback)
	if not b then
		Ext.PrintError("[LeaderLib:SortDictionary] Error sorting dictionary:", id)
		Ext.PrintError(result)
	end
end

--print(Common.JsonStringify(Osi.DB_LeaderLib_Dictionary_Data:Get(nil, nil, nil, nil)))

---@param db table
---@param value any
---@param checkColumn integer|nil Defaults to 1 if not set.
---@return boolean
function GameHelpers.DB.TableHasValue(db, value, checkColumn)
	checkColumn = checkColumn or 1
	local b,result = xpcall(function()
		if type(value) == "table" then
			for _,v in pairs(value) do
				for _,entry in pairs(db) do
					if entry[checkColumn] == v then
						return true
					end
				end
			end
		else
			for _,entry in pairs(db) do
				if entry[checkColumn] == value then
					return true
				end
			end
		end
		return false
	end, debug.traceback)
	if b then
		return result
	end
	fprint(LOGLEVEL.ERROR, "[LeaderLib:GameHelpers.DB.TableHasValue] Error checking database table:\n%s", result)
	return false
end

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
		if db and #db > 0 then
			return db
		end
		return nil
	end, debug.traceback)

	if b and result then
		return GameHelpers.DB.TableHasValue(result, value, checkColumn)
	end
	return false
end

---Similar to GameHelpers.DB.HasValue, but checks the UUID part of the string values, since it may be stored as Name_UUID in the DB.
---@param databaseName string
---@param uuid string
---@param arity integer|nil Defaults to 1 if not set.
---@param checkColumn integer|nil Defaults to 1 if not set.
---@return boolean
function GameHelpers.DB.HasUUID(databaseName, uuid, arity, checkColumn)
	arity = arity or 1
	checkColumn = checkColumn or 1
	local b,result = xpcall(function()
		local db = Osi[databaseName]:Get(GetArity(arity))
		if db ~= nil and #db > 0 then
			return db
		end
		return nil
	end, debug.traceback)

	if not b then
		fprint(LOGLEVEL.ERROR, "[LeaderLib:GameHelpers.DB.HasValue] Error checking database %s(%s):\n%s", databaseName, arity, result)
		return false
	elseif result ~= nil then
		local t = type(uuid)
		if t == "table" then
			for _,uuid2 in pairs(uuid) do
				uuid2 = StringHelpers.GetUUID(uuid2)
				for _,entry in pairs(result) do
					if StringHelpers.GetUUID(entry[checkColumn]) == uuid2 then
						return true
					end
				end
			end
		elseif t == "string" then
			uuid = StringHelpers.GetUUID(uuid)
			for _,entry in pairs(result) do
				if StringHelpers.GetUUID(entry[checkColumn]) == uuid then
					return true
				end
			end
		else
			fprint(LOGLEVEL.ERROR, "[LeaderLib:GameHelpers.DB.HasUUID] uuid value (%s) needs to be a string or table of strings.", uuid)
		end
	end
	return false
end

function GameHelpers.DB.Flatten(databaseTable, formatUUID)
	local data = {}
	for i,v in pairs(databaseTable) do
		local params = v
		for i2,v2 in pairs(params) do
			if type(v2) == "string" then
				params[i2] = StringHelpers.GetUUID(v2)
			end
		end
		if #params > 1 then
			data[i] = params
		else
			data[i] = table.unpack(params)
		end
	end
	return data
end

---@param name string The database name.
---@param arity integer The number of parameters for this DB.
---@param index integer|nil The index to return, if any. Optional.
---@param unpack boolean If true, table.unpack is called on the result when returning the data.
function GameHelpers.DB.Get(name, arity, index, unpack)
	local b,result = xpcall(function()
		local db = Osi[name]:Get(GetArity(arity))
		if db then
			if index and #db >= index then
				return db[index]
			end
		end
		return db
	end, debug.traceback)
	if not b then
		Ext.PrintError("[LeaderLib:GameHelpers.DB.Get] Error getting database:", name)
		Ext.PrintError(result)
		return nil
	end
	if unpack and result ~= nil then
		return table.unpack(result)
	end
	return result
end

---Try to unpack a database retrieved with Get.
---@param tbl table
---@param index ?integer Optional row to try and get. Defaults to 1.
---@return boolean,...
function GameHelpers.DB.TryUnpack(tbl, index)
	index = index or 1
	if type(tbl) == "table" and type(tbl[index]) == "table" then
		return true,table.unpack(tbl[index])
	end
	return false
end