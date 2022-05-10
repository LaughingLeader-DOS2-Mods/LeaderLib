if TableHelpers == nil then
	TableHelpers = {}
end

---@param orig table
---@param deep boolean|nil If true, metatables are copied as well.
function TableHelpers.Clone(orig, deep)
	if deep ~= true then
		local t = type(orig)
		local copy = {}
		if t == "table" then
			for k, v in pairs(orig) do
				if type(v) == "table" then
					copy[k] = TableHelpers.Clone(v, deep)
				else
					copy[k] = v
				end
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

---Returns an ordered iterator if the table is structured like that, otherwise returns a regular next iterator.
function TableHelpers.TryOrderedEach(tbl)
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
---@param supportedExtraTypes table<string,boolean>|nil
---@param forJson boolean|nil If true, key types will be restricted to number/string.
---@return table<string|number|boolean,string|number|boolean|table>
function TableHelpers.SanitizeTable(tbl, supportedExtraTypes, forJson)
	local output = {}
	local tableType = type(tbl)
	if tableType ~= "table" and tableType ~= "userdata" then
		return output
	end
	for k,v in pairs(tbl) do
		local keyType = type(k)
		if (forJson and validKeyTypes[keyType]) or not (forJson and validTypes[keyType]) then
			local t = type(v)
			if validTypes[t] or (supportedExtraTypes and supportedExtraTypes[t]) then
				if t == "table" or t == "userdata" then
					output[k] = TableHelpers.SanitizeTable(v, supportedExtraTypes, forJson)
				else
					output[k] = v
				end
			end
		end
	end
	return output
end

---Add key/value entries to target from addFrom, optionally skipping if that key exists already.
---@param target table
---@param addFrom table
---@param skipExisting boolean|nil If true, existing values aren't updated.
---@param deep boolean|nil If true, iterate into table values to AddOrUpdate them as well.
---@return table target Returns the target table.
function TableHelpers.AddOrUpdate(target, addFrom, skipExisting, deep)
	if type(target) ~= "table" or type(addFrom) ~= "table" then
		return target
	end
	for k,v in pairs(addFrom) do
		if target[k] == nil then
			target[k] = v
		else
			if deep and (type(v) == "table" and type(target[k]) == "table") then
				TableHelpers.AddOrUpdate(target[k], v, skipExisting)
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
		if addFrom[k] ~= nil then
			if type(v) == "table" then
				TableHelpers.AddOrUpdate(v, addFrom[k])
			else
				target[k] = addFrom[k]
			end
		end
	end
	return target
end

---@param tbl table
---@param indent integer|nil
---@return string
function TableHelpers.ToString(tbl, indent)
	if not indent then indent = 0 end
	--local toprint = string.rep(" ", indent) .. "{\n"
	--local toprint = string.rep(" ", indent) .. "{\n"
	local toprint = "{\n"
	indent = indent + 1
	for k, v in pairs(tbl) do
		toprint = toprint .. string.rep(" ", indent)
		if (type(k) == "number") then
			toprint = toprint .. "[" .. k .. "] = "
		elseif (type(k) == "string") then
			toprint = toprint  .. k ..  " = " 
		end
		if (type(v) == "number") then
			toprint = toprint .. v .. ",\n"
		elseif (type(v) == "string") then
			toprint = toprint .. "\"" .. v .. "\",\n"
		elseif (type(v) == "table") then
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
---@return any[]
function TableHelpers.ShuffleTable(tbl)
	local newTable = {}
	for i = 1, #tbl do
	  newTable[i] = tbl[i]
	end
	for i = #newTable, 2, -1 do
	  local j = Ext.Random(i)
	  newTable[i], newTable[j] = newTable[j], newTable[i]
	end
	return newTable
end

---Try to unpack a table and return the entries.
---@param tbl table
---@return boolean,...
function TableHelpers.TryUnpack(tbl)
	if type(tbl) == "table" then
		return true,table.unpack(tbl)
	end
	return false
end

---Checks if a table has a string/boolean/number value, or any value in a table of values, if provided.
---@param tbl table
---@param value SerializableValue|table<any, SerializableValue> A value or table of values to check for.
---@param deep boolean|nil If true, and table entry is a table, keep checking for the provided values.
---@return boolean
function TableHelpers.HasValue(tbl, value, deep)
	if type(tbl) ~= nil then
		return false
	end
	local t = type(value)
	if t == "table" then
		for k,v in pairs(value) do
			if TableHelpers.HasValue(table, v, deep) then
				return true
			end
		end
	else
		for k,v in pairs(tbl) do
			if v == value then
				return true
			end
			if deep and type(v) == "table" and TableHelpers.HasValue(v, value, deep) then
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
	if type(copyFrom) ~= "table" then
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
	if type(copyFrom) ~= "table" then
		return copyTo
	end
	for k,v in pairs(copyFrom) do
		copyTo[k] = v
	end
	return copyTo
end