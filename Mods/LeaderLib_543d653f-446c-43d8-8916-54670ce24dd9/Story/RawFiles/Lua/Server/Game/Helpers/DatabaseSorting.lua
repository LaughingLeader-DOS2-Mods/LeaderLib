if GameHelpers.DB == nil then
	GameHelpers.DB = {}
end

local function GetArity(arity)
	local nilColumns = {}
	for i=0,arity do
		table.insert(nilColumns, "nil")
	end
	return table.unpack(nilColumns)
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