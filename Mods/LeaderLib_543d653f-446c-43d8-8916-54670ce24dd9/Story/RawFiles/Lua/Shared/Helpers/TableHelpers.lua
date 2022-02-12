if TableHelpers == nil then
	TableHelpers = {}
end

---@param orig table
---@param deep boolean|nil If true, metatables are copied as well.
function TableHelpers.Clone(orig, deep)
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
---@param supportedExtraTypes table<string,boolean>
---@param forJson ?boolean If true, key types will be restricted to number/string.
---@return table<string|number|boolean,string|number|boolean|table>
function TableHelpers.SanitizeTable(tbl, supportedExtraTypes, forJson)
	local output = {}
	local tableType = type(tbl)
	if tableType ~= "table" and tableType ~= "userdata" then
		return output
	end
	for k,v in pairs(tbl) do
		local keyType = type(k)
		if (forJson and validKeyTypes[keyType]) or not (forJson and validTypes(keyType)) then
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

---@param target table
---@param addFrom table
---@param skipExisting boolean|nil If true, existing values aren't updated.
function TableHelpers.AddOrUpdate(target, addFrom, skipExisting)
	if target == nil or addFrom == nil then
		return
	end
	for k,v in pairs(addFrom) do
		if target[k] == nil then
			target[k] = v
		else
			if type(v) == "table" then
				TableHelpers.AddOrUpdate(target[k], v, skipExisting)
			elseif skipExisting ~= true then
				target[k] = v
			end
		end
	end
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