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
		Ext.Utils.PrintError("[LeaderLib:GameHelpers.DB.SortDatabase] Error sorting database:", name)
		Ext.Utils.PrintError(result)
	else
		if result ~= nil then
			Osi[name]:Delete(GetArity(arity))
			for i,v in pairs(result) do
				Osi[name][i](v)
			end
			--fprint(LOGLEVEL.TRACE, name, Common.JsonStringify(Osi[name]:Get(GetArity(arity))))
		end
	end
end
GameHelpers.DB.SortDatabase = SortDatabase
Ext.Osiris.NewCall(SortDatabase, "LeaderLib_Ext_SortDatabase", "(STRING)_DatabaseName, (INTEGER)_Arity, (INTEGER)_SortByColumn")

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
		--fprint(LOGLEVEL.TRACE, id, Common.JsonStringify(Osi.DB_LeaderLib_Dictionary_Data:Get(id, nil, nil, nil)))
		return true
	end, debug.traceback)
	if not b then
		Ext.Utils.PrintError("[LeaderLib:SortDictionary] Error sorting dictionary:", id)
		Ext.Utils.PrintError(result)
	end
end

--print(Common.JsonStringify(Osi.DB_LeaderLib_Dictionary_Data:Get(nil, nil, nil, nil)))

---@param db table
---@param value any
---@param checkColumn? integer Defaults to 1 if not set.
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
---@param arity? integer Defaults to 1 if not set.
---@param checkColumn? integer Defaults to 1 if not set.
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
---@param arity? integer Defaults to 1 if not set.
---@param checkColumn? integer Defaults to 1 if not set.
---@return boolean
function GameHelpers.DB.HasUUID(databaseName, uuid, arity, checkColumn)
	uuid = GameHelpers.GetUUID(uuid, true)
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

function GameHelpers.DB.Flatten(databaseTable)
	local data = {}
	for i,v in pairs(databaseTable) do
		local params = v
		for i2,v2 in pairs(params) do
			if type(v2) == "string" then
				if StringHelpers.IsUUID(v2) then
					params[i2] = StringHelpers.GetUUID(v2)
				end
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

---@overload fun(name:string, arity:integer):table<integer, table<integer, OsirisValue>>
---@param name string The database name.
---@param arity integer The number of parameters for this DB, or nil to try and auto-detect it.
---@param index? integer The index to return, if any. Optional.
---@param unpack boolean If true, table.unpack is called on the result when returning the data.
---@return OsirisValue ... 
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
		Ext.Utils.PrintError("[LeaderLib:GameHelpers.DB.Get] Error getting database:", name)
		Ext.Utils.PrintError(result)
		return nil
	end
	if unpack and type(result) == "table" then
		return table.unpack(result)
	end
	return result
end

---Try to unpack a database retrieved with Get.
---@param tbl table
---@param index? integer Optional row to try and get. Defaults to 1.
---@return boolean,...
function GameHelpers.DB.TryUnpack(tbl, index)
	index = index or 1
	if type(tbl) == "table" and type(tbl[index]) == "table" then
		return true,table.unpack(tbl[index])
	end
	return false
end

---@alias OsirisValueReturnIterator fun():...:OsirisValue
---@alias GuidReturnIterator fun():...:Guid

---Get an iterator for a database, which returns the unpacked table for each entry.
---@param name string The database name.
---@param arity? integer The number of parameters for this DB, or nil to try and auto-detect it.
---@param returnGuid? boolean Set to true if you want the returned values to be processed with `StringHelpers.GetUUID`. This assumes the DB is only GUIDSTRING/CHARACTERGUID etc values.
---@param skipUnpack? boolean Skip unpacking the returned database entry.
---@return OsirisValueReturnIterator iterator
function GameHelpers.DB.GetAllEntries(name, arity, returnGuid, skipUnpack)
	local db = GameHelpers.DB.Get(name, arity)
	if db then
		local i = 0
		local count = #db
		local unpack = table.unpack
		if skipUnpack then
			unpack = function (tbl)
				return tbl
			end
		end
		if returnGuid then
			return function ()
				i = i + 1
				if i <= count then
					local entries = db[i]
					local data = {}
					for i,v in ipairs(entries) do
						data[i] = StringHelpers.GetUUID(v)
					end
					return unpack(data)
				end
			end
		else
			return function ()
				i = i + 1
				if i <= count then
					return unpack(db[i])
				end
			end
		end
	else
		return function () end
	end
end

---Basically `GameHelpers.DB.GetAllEntries`, but with a return value of Guid. 
---This should be a database that is only Guids. 
---@param name string The database name.
---@param arity? integer The number of parameters for this DB, or nil to try and auto-detect it.
---@param skipUnpack? boolean Skip unpacking the returned database entry.
---@return GuidReturnIterator iterator
function GameHelpers.DB.GetAllGuids(name, arity, skipUnpack)
	return GameHelpers.DB.GetAllEntries(name, arity, true, skipUnpack)
end

local function _TryDelete(id, ...)
	Osi[id]:Delete(...)
end

---Simple helper to wrap Osi DB deletion in a pcall, to ignore any errors (DB not existing etc).
---@param id string
---@param ... OsirisValue
function GameHelpers.DB.TryDelete(id, ...)
	return pcall(_TryDelete, id, ...)
end