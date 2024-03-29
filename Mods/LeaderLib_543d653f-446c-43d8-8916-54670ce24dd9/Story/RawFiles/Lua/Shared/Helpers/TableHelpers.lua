if TableHelpers == nil then
	TableHelpers = {}
end

local _type = type

---@param orig table
---@param deep? boolean If true, metatables are copied as well.
function TableHelpers.Clone(orig, deep)
	local t = _type(orig)
	local copy = {}
	if t == "table" then
		for k, v in pairs(orig) do
			if _type(v) == "table" then
				copy[k] = TableHelpers.Clone(v, deep)
			else
				copy[k] = v
			end
		end
		if deep then
			local meta = getmetatable(orig)
			if meta then
				setmetatable(copy, meta)
			end
		end
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

---Returns an ordered iterator if the table is structured like that, otherwise returns a regular next iterator.
function TableHelpers.TryOrderedEach(tbl)
	if type(tbl) == "table" then
		local len = tbl and #tbl or 0
		if len > 0 then
			local i = 0
			return function ()
				i = i + 1
				if i <= len then
					return i,tbl[i]
				end
			end
		else
			local function iter(tbl, index)
				return next(tbl, index)
			end
			return iter,tbl,nil
		end
	else
		return pairs(tbl)
	end
end

local validKeyTypes = {
	string = true,
	number = true,
}

local validTypes = {
	string = true,
	table = true,
	number = true,
	boolean = true,
}
---Prepares a table for PersistentVars saving by removing invalid values.
---@param tbl table
---@param supportedExtraTypes? table<string,boolean>
---@param forJson? boolean If true, key types will be restricted to number/string.
---@param sanitizeValue (fun(key:string, value:userdata|table|function|nil, valueType:string):SerializableValue)
---@return table<string|number|boolean,string|number|boolean|table>
function TableHelpers.SanitizeTable(tbl, supportedExtraTypes, forJson, sanitizeValue)
	local output = {}
	local tableType = _type(tbl)
	if tableType ~= "table" and tableType ~= "userdata" then
		return output
	end
	for k,v in pairs(tbl) do
		local keyType = _type(k)
		if (forJson and validKeyTypes[keyType]) or not (forJson and validTypes[keyType]) then
			local t = _type(v)
			if sanitizeValue then
				output[k] = sanitizeValue(k, v, t)
			else
				if t == "table" or (t == "userdata" and getmetatable(v) ~= nil) then
					output[k] = TableHelpers.SanitizeTable(v, supportedExtraTypes, forJson, sanitizeValue)
				elseif validTypes[t] or (supportedExtraTypes and supportedExtraTypes[t]) then
					if sanitizeValue then
						output[k] = sanitizeValue(k, v, t)
					else
						output[k] = v
					end
				end
			end
		end
	end
	return output
end

---Add key/value entries to target from addFrom, optionally skipping if that key exists already.
---@param target table
---@param addFrom table
---@param skipExisting? boolean If true, existing values aren't updated.
---@param deep? boolean If true, iterate into table values to AddOrUpdate them as well.
---@return table target Returns the target table.
function TableHelpers.AddOrUpdate(target, addFrom, skipExisting, deep)
	if _type(target) ~= "table" or _type(addFrom) ~= "table" then
		return target
	end
	for k,v in pairs(addFrom) do
		local existingValue = target[k]
		if existingValue == nil then
			target[k] = v
		else
			if deep and (_type(v) == "table" and _type(existingValue) == "table") then
				TableHelpers.AddOrUpdate(existingValue, v, skipExisting, deep)
			elseif skipExisting ~= true then
				target[k] = v
			end
		end
	end
	return target
end

---Only assigns values from addFrom if they already exist in target.
---@param target table
---@param addFrom table
function TableHelpers.CopyExistingKeys(target, addFrom)
	if target == nil or addFrom == nil then
		return target
	end
	for k,v in pairs(target) do
		local newValue = addFrom[k]
		if newValue ~= nil then
			if _type(v) == "table" then
				TableHelpers.AddOrUpdate(v, newValue, false, true)
			else
				target[k] = newValue
			end
		end
	end
	return target
end

---@param tbl table
---@param indent? integer
---@return string
function TableHelpers.ToString(tbl, indent)
	if not indent then indent = 0 end
	--local toprint = string.rep(" ", indent) .. "{\n"
	--local toprint = string.rep(" ", indent) .. "{\n"
	local toprint = "{\n"
	indent = indent + 1
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if (_type(k) == "number") then
			toprint = toprint .. "[" .. k .. "] = "
		elseif (_type(k) == "string") then
			toprint = toprint  .. k ..  " = " 
		end
		if (_type(v) == "number") then
			toprint = toprint .. v .. ",\n"
		elseif (_type(v) == "string") then
			toprint = toprint .. "\"" .. v .. "\",\n"
		elseif (_type(v) == "table") then
			toprint = toprint .. TableHelpers.ToString(v, indent + 2) .. ",\n"
		else
			toprint = toprint .. "\"" .. tostring(v) .. "\",\n"
		end
	end
	toprint = toprint .. string.rep(" ", indent-1) .. "}"
	return toprint
end

---Randomly reorders an array and returns a new copy.
---@param tbl any[]
---@param inPlace? boolean Modify the original table, instead of making a copy.
---@return any[]
function TableHelpers.ShuffleTable(tbl, inPlace)
	if not inPlace then
		local newTable = {}
		for i = 1, #tbl do
		  newTable[i] = tbl[i]
		end
		for i = #newTable, 2, -1 do
		  local j = Ext.Utils.Random(1, i)
		  newTable[i], newTable[j] = newTable[j], newTable[i]
		end
		return newTable
	else
		for i = #tbl, 2, -1 do
			local j = Ext.Utils.Random(1, i)
			tbl[i], tbl[j] = tbl[j], tbl[i]
		end
		return tbl
	end
end

---Try to unpack a table and return the entries.
---@param tbl table
---@return boolean,...
function TableHelpers.TryUnpack(tbl)
	if _type(tbl) == "table" then
		return true,table.unpack(tbl)
	end
	return false
end

---@alias SerializableValue string|boolean|number

---Checks if a table has a string/boolean/number value, or any value in a table of values, if provided.
---@param tbl table
---@param value SerializableValue|SerializableValue[] A value or table of values to check for.
---@param deep? boolean If true, and table entry is a table, keep checking for the provided values.
---@return boolean
function TableHelpers.HasValue(tbl, value, deep)
	if _type(tbl) ~= "table" then
		return false
	end
	local t = _type(value)
	if t == "table" then
		for _,v in pairs(value) do
			if TableHelpers.HasValue(tbl, v, deep) then
				return true
			end
		end
	else
		for _,v in pairs(tbl) do
			if v == value then
				return true
			end
			if deep and _type(v) == "table" and TableHelpers.HasValue(v, value, deep) then
				return true
			end
		end
	end

	return false
end

---Appends values from one array into another.
---@param copyTo any[]
---@param copyFrom any[]
---@return table copyTo Returns the copyTo table
function TableHelpers.AppendArrays(copyTo, copyFrom)
	if _type(copyFrom) ~= "table" then
		return copyTo
	end
	for k,v in pairs(copyFrom) do
		table.insert(copyTo, v)
	end
	return copyTo
end

---Copies key/pair values from one table to another.
---@param copyTo table
---@param copyFrom table
---@return table copyTo Returns the copyTo table
function TableHelpers.CopyKeys(copyTo, copyFrom)
	if _type(copyFrom) ~= "table" then
		return copyTo
	end
	for k,v in pairs(copyFrom) do
		copyTo[k] = v
	end
	return copyTo
end

---Create a copy of a table where all the values are unique, and optionally sorted.
---@generic T : table
---@param tbl T An array-like table.
---@param sort? boolean Whether to sort the results.
---@param sortFunc? function Optional function to use when sorting. Defaults to the regular table.sort otherwise.
---@return T
function TableHelpers.MakeUnique(tbl, sort, sortFunc)
	local result = {}
	local existing = {}
	for _,v in pairs(tbl) do
		if existing[v] == nil then
			existing[v] = true
			result[#result+1] = v
		end
	end
	if sort then
		if sortFunc then
			table.sort(result, sortFunc)
		else
			table.sort(result)
		end
	end
	return result
end

---Configure a table's metatable __index to point to a table of default keys/values.  
---If tbl is not a table, the default values table is returned.
---@generic T : table
---@param opts? table A table of key/value entries.
---@param defaultValues T An array-like table.
---@return T
function TableHelpers.SetDefaultOptions(opts, defaultValues)
	local result = nil
	if type(opts) ~= "table" then
		result = {}
	else
		result = opts
		local meta = getmetatable(opts)
		if meta then
			local inheritedIndex = meta.__index
			local inheritedIndexType = _type(inheritedIndex)
			local newMeta = {
				__index = function (tbl,k)
					if defaultValues[k] ~= nil then
						return defaultValues[k]
					end
					if inheritedIndexType == "table" then
						return inheritedIndex[k]
					elseif inheritedIndexType == "function" then
						return inheritedIndex(tbl,k)
					end 
				end,
				__newindex = function (_,k,v) rawset(result, k, v) end
			}
			TableHelpers.AddOrUpdate(newMeta, meta, true)
			setmetatable(result, newMeta)
			return result
		end
	end
	if defaultValues then
		setmetatable(result, {__index = defaultValues, __newindex = function (_,k,v) rawset(result, k, v) end})
	end
	return result
end