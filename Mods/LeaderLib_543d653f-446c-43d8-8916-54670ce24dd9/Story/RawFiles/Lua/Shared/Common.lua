if Common == nil then Common = {} end

function Common.InitSeed()
	local rnd = Ext.Random(9999)
	local seed = (Ext.Random(9999) * 214013) + 2531011
	_G["LEADERLIB_RAN_SEED"] = seed
	PrintDebug("[LeaderLib:Common.lua] Set LEADERLIB_RAN_SEED to ("..tostring(seed)..")")
	if Ext.IsServer() then
		Ext.BroadcastMessage("LeaderLib_SyncRanSeed", tostring(seed), nil)
	end
end

--Source: https://github.com/Luca96/lua-table, MIT License 2010
---Flattens a nested table.
---@param t table Either an array-like int indiced table, or any key-value pair type if deep is true.
---@param deep boolean If true, key-value pair types of tables will be flattened as well.
---@return table<int,any>
function Common.FlattenTable(t, deep)
	local queque = { t }
	local result = table()
	local base = 1
	local top  = 1
	local k = 1

	if deep then
		while base <= top do
			local items = queque[base]
			base = base + 1
			for _, v in pairs(items) do
				if type(v) == "table" then
					top = top + 1
					queque[top] = v
				else
					result[k] = v
					k = k + 1
				end
			end
		end
	else
		while base <= top do
			local items = queque[base]
			base = base + 1
			for i = 1, #items do
				local v = items[i]
				if type(v) == "table" then
					top = top + 1
					queque[top] = v
				else
					result[k] = v
					k = k + 1
				end
			end
		end
	end
	return result
end

function Common.FlattenTable(tbl, deep)
	local result = {}
	local function flatten(tbl)
		for _,v in pairs(tbl) do
			if type(v) == "table" then
				flatten(v)
			else
				table.insert(result, v)
			end
		end
	end
	flatten(tbl)
	return result
end

function Common.DeepCopyTable(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[Common.DeepCopyTable(orig_key)] = Common.DeepCopyTable(orig_value)
		end
		setmetatable(copy, Common.DeepCopyTable(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function Common.CloneTable(orig, deep)
	if deep ~= true then
		local orig_type = type(orig)
		local copy
		if orig_type == 'table' then
			copy = {}
			for orig_key, orig_value in pairs(orig) do
				copy[orig_key] = orig_value
			end
		else -- number, string, boolean, etc
			copy = orig
		end
		local meta = getmetatable(orig)
		if meta then
			setmetatable(copy, meta)
		end
		return copy
	else
		return Common.DeepCopyTable(orig)
	end
end

---DEPRECATED, use Common.CloneTable instead.
function Common.CopyTable(orig, deep)
	return Common.CloneTable(orig, deep)
end

---Merge two arrays.
---@param target any[]
---@param mergeFrom any[]
function Common.MergeTables(target, mergeFrom)
	for i=1,#mergeFrom do
		target[#target+1] = mergeFrom[i]
	end
end

function Common.CopyTableToTable(target, copyFrom)
	if target and copyFrom then
		for k,v in pairs(copyFrom) do
			if target[k] == nil then
				target[k] = v
			else
				if type(v) == "table" and type(target[k]) == "table" then
					Common.CopyTableToTable(target[k], v)
				else
					target[k] = v
				end
			end
		end
	end
end

function Common.TableEquals(t1, t2, deepComparison)
	deepComparison = deepComparison or false
	local v1 = Common.FlattenTable(t1, deepComparison)
	local v2 = Common.FlattenTable(t2, deepComparison)
	local l1 = #v1
	local l2 = #v2
 
	if l1 == l2 then
	   for i = 1, l1 do
		  if v1[i] ~= v2[i] then
			 return false
		  end
	   end
	   return true
	end
 
	return false
end

local function PrintIndex(k, indexMap)
	if indexMap ~= nil and type(indexMap) == "table" then
		local displayValue = indexMap[k]
		if displayValue ~= nil then
			return displayValue
		end
	end
	if type(k) == "string" then
		return '"'..k..'"'
	else
		return tostring(k)
	end
end

---PrintDebug a value or table (recursive).
---@param o table
---@param indexMap table
---@param innerOnly boolean
---@return string
function Common.Dump(o, indexMap, innerOnly, recursionLevel)
	if recursionLevel == nil then recursionLevel = 0 end
	local t = type(o)
	if t == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if innerOnly == true then
				if recursionLevel > 0 then
					s = s .. ' ['..PrintIndex(k, indexMap)..'] = ' .. Common.Dump(v, indexMap, innerOnly, recursionLevel + 1) .. ','
				else
					s = s .. ' ['..PrintIndex(k, nil)..'] = ' .. Common.Dump(v, indexMap, innerOnly, recursionLevel + 1) .. ','
				end
			else
				s = s .. ' ['..PrintIndex(k, indexMap)..'] = ' .. Common.Dump(v, indexMap, innerOnly, recursionLevel + 1) .. ','
			end
		end
		return s .. '}'
	elseif t == "string" then
		return '"'..o..'"'
	else
		return tostring(o)
	end
end

---@param tbl table
---@param key any
---@param caseInsensitive boolean|nil
---@return boolean
function Common.TableHasKey(tbl, key, caseInsensitive)
	if tbl == nil then
		return false
	end
	local v = tbl[key]
	if caseInsensitive == true and v == nil and type(key) == "string" then
		v = tbl[string.lower(key)]
	end
	if v ~= nil then
		return true
	elseif #tbl > 0 or next(tbl, nil) ~= nil then
		for k,v2 in pairs(tbl) do
			if type(v2) == "table" then
				return Common.TableHasEntry(v2, key)
			end
		end
	end
	return false
end

---@param tbl table
---@param value any
---@param caseInsensitive boolean|nil
---@return boolean
function Common.TableHasEntry(tbl, value, caseInsensitive)
	if tbl == nil then
		return false
	end
	local t = type(value)
	for k,v in pairs(tbl) do
		if type(v) == t then
			if t == "string" and StringHelpers.Equals(value, v, caseInsensitive) then
				return true
			elseif t == "table" and Common.TableHasAnyEntry(v, value, caseInsensitive) then
				return true
			elseif v == value then
				return true
			end
		end

	end
	return false
end

---@param tbl table
---@param value any
---@return boolean
function Common.TableHasValue(tbl, value)
	if tbl == nil then
		return false
	end
	for _,v in pairs(tbl) do
		if type(v) == "table" then
			if Common.TableHasValue(v, value) then
				return true
			end
		else
			if v == value then
				return true
			end
		end
	end
	return false
end

---@param tbl table
---@return boolean
function Common.TableHasAnyEntry(tbl)
	if tbl == nil then
		return false
	end
	for i,v in pairs(tbl) do
		if v ~= nil then
			return true
		end
	end
	return false
end

---Checks if a table retrieved via Osi.DB_Whatever:Get has an entry.
---@param tbl table
---@return boolean
function Common.OsirisDatabaseHasAnyEntry(tbl)
	if tbl == nil or type(tbl) ~= "table" then
		return false
	end
	for i,v in pairs(tbl) do
		if v and type(v) == "table" and #v > 0 then
			return true
		end
	end
	return false
end

---@param tbl table
---@param key any
---@param fallback any
---@return any
function Common.GetTableEntry(tbl, key, fallback)
	local v = tbl[key]
	if v ~= nil then
		return v
	end
	return fallback
end

---Get a random entry from a table.
---@param tbl table
---@return any
function Common.GetRandomTableEntry(tbl)
	if #tbl > 0 then
		local rnd = Ext.Random(1,#tbl)
		--local ran = math.max(1, math.fmod(rnd,#tbl))
		return tbl[rnd]
	end
	return nil
end

---Get a random entry from a table after removing it.
---@param tbl table
---@return any
function Common.PopRandomTableEntry(tbl)
	if #tbl > 0 then
		local rnd = Ext.Random(1,#tbl)
		--local ran = math.max(1, math.fmod(rnd,#tbl))
		local entry = tbl[rnd]
		tbl[rnd] = nil
		return entry
	end
	return nil
end

function Common.ShuffleTable(tbl)
	for i = #tbl, 2, -1 do
		local j = Ext.Random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

---Copies nil keys from the source table to the target, if it's nil on the target.
---@param source table
---@param target table
function Common.InitializeTableFromSource(target, source)
	if source ~= nil then
		for k,v in pairs(source) do
			if target[k] == nil then
				target[k] = v
			elseif type(v) == "table" then
				Common.InitializeTableFromSource(target[k], v)
			end		
		end
	else
		Ext.PrintError("[LeaderLib:Common.InitializeTableFromSource] Source table is nil!")
	end
end

---Converts a table string keys to numbers. Useful for converting JsonStringify number keys back to numbers.
---@param tbl table
---@param recursive boolean
function Common.ConvertTableKeysToNumbers(tbl, recursive)
	for k,v in pairs(tbl) do
		if type(k) ~= "number" then
			local num = tonumber(k)
			if num ~= nil then
				tbl[num] = v
				tbl[k] = nil
			end
			if recursive == true and type(v) == "table" then
				Common.ConvertTableKeysToNumbers(v, recursive)
			end
		end
	end
end

function Common.JsonParse(str)
	local tbl = Ext.JsonParse(str)
	if tbl ~= nil then
		Common.ConvertTableKeysToNumbers(tbl, true)
	end
	return tbl
end

---@param max integer
---@param min integer
---@return integer
function Common.GetRandom(max,min)
	if max == nil then max = 999 end
	if min == nil then min = 0 end
	local rnd = Ext.Random(0, _G["LEADERLIB_RAN_SEED"])
	local ran = math.max(min, math.fmod(rnd,max))
	return ran
end

--Source: https://github.com/sulai/Lib-Pico8/blob/master/lang.lua
---Generates an enum-like table
---@param names table
---@param offset integer
---@return table
function Common.Enum(names, offset)
	offset=offset or 1
	local objects = {}
	local size=0
	for idr,name in pairs(names) do
		local id = idr + offset - 1
		local obj = {
			id=id,       -- id
			idr=idr,     -- 1-based relative id, without offset being added
			name=name    -- name of the object
		}
		objects[name] = obj
		objects[id] = obj
		size=size+1
	end
	objects.idstart = offset        -- start of the id range being used
	objects.idend = offset+size-1   -- end of the id range being used
	objects.size=size
	objects.all = function()
		local list = {}
		for _,name in pairs(names) do
			table.insert(list, objects[name])
		end
		local i=0
		return function() i=i+1 if i<=#list then return list[i] end end
	end
	return objects
end

---@param in_value any
---@param param_type string
---@param fallback_value any
---@return any
function Common.SafeguardParam(in_value, param_type, fallback_value)
	if in_value == nil then return fallback_value end
	local in_type = type(in_value)
	if in_type == param_type then
		return in_value
	else
		if type(param_type) == "table" then
			for i,v in pairs(param_type) do
				if in_type == v then
					return in_value
				end
			end
		else
			if in_type == "number" and param_type == "integer" then
				return in_value
			elseif in_type == "string" and param_type == "number" then
				return tonumber(in_value)
			elseif in_type == "string" and param_type == "integer" then
				return math.tointeger(in_value)
			end
		end
	end
	return fallback_value
end

function Common.Split(s, sep)
	local fields = {}
	local sep = sep or " "
	local pattern = string.format("([^%s]+)", sep)
	string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)
	if #fields == 0 then
		return s
	else
		return fields
	end
end

---Formats a number with commas.
---@param amount integer
function Common.FormatNumber(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
		break
		end
	end
	return formatted
end

function Common.TableLength(tbl, isKeyValueType)
	if isKeyValueType ~= true then
		return #tbl
	else
		local total = 0
		for k,v in pairs(tbl) do
			total = total + 1
		end
		return total
	end
end

-- Legacy
Common.StringEquals = StringHelpers.Equals
Common.StringIsNullOrEmpty = StringHelpers.IsNullOrEmpty
Common.StringJoin = StringHelpers.Join
Common.StringSplit = StringHelpers.Split

---Returns the value is not nil, otherwise returns the fallback value.
---@param val any|nil
---@param fallback any
function Common.GetValueOrDefault(val, fallback)
	if val == nil then
		return fallback
	end
	return val
end