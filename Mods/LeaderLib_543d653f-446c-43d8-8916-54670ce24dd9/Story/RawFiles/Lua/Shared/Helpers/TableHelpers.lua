if TableHelpers == nil then
	TableHelpers = {}
end

---@param orgin table
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

local validTypes = {
	string = true,
	table = true,
	number = true,
	boolean = true,
}
---Prepares a table for PersistentVars saving by removing invalid values.
---@param tbk table
---@return table<string|number|boolean,string|number|boolean|table>
function TableHelpers.SanitizeTable(tbl)
	if type(tbl) ~= "table" then
		return
	end
	local output = {}
	for k,v in pairs(tbl) do
		if validTypes[type(k)] then
			local t = type(v)
			if validTypes[t] then
				if t == "table" then
					output[k] = TableHelpers.SanitizeTable(v)
				else
					output[k] = v
				end
			end
		end
	end
	return output
end

function TableHelpers.AddOrUpdate(target, addFrom)
	for k,v in pairs(addFrom) do
		if not target[k] then
			target[k] = v
		else
			if type(v) == "table" then
				TableHelpers.AddOrUpdate(target[k], v)
			else
				target[k] = v
			end
		end
	end
end