if StringHelpers == nil then 
	StringHelpers = {} 
end

---Check if a string is equal to another. Case-insenstive.
---@param a string
---@param b string
---@param insensitive boolean
---@return boolean
local function Equals(a,b, insensitive)
	if insensitive == nil then insensitive = true end
	if a ~= nil and b ~= nil then
		if insensitive then
			return string.upper(a) == string.upper(b)
		else
			return a == b
		end
	end
	return false
end

StringHelpers.Equals = Equals

---Checks if a string is null or empty.
---@type x string
---@return boolean
local function IsNullOrEmpty(x)
	return x == nil or x == "" or x == "NULL_00000000-0000-0000-0000-000000000000" or type(x) ~= "string"
end

StringHelpers.IsNullOrEmpty = IsNullOrEmpty

---Capitalize a string.
---@type s string
---@return string
local function Capitalize(s)
	return s:sub(1,1):upper()..s:sub(2)
end

StringHelpers.Capitalize = Capitalize

---Join a table of string into one string.
---Source: http://www.wellho.net/resources/ex.php4?item=u105/spjo
---@param delimiter string
---@param list table
local function Join(delimiter, list, uniqueOnly)
	local len = #list
	if len == 0 then
		return ""
	elseif len == 1 then
		return list[1]
	end
	local string = list[1]
	for i = 2, len do
		if uniqueOnly == true and not string.find(string, list[i]) then
			string = string .. delimiter .. list[i]
		elseif not uniqueOnly then
			string = string .. delimiter .. list[i]
		end
	end
	return string
end

StringHelpers.Join = Join

---Split a string into a table.
---Source: http://www.wellho.net/resources/ex.php4?item=u105/spjo
---@param str string
---@param delimiter string
local function Split(str, delimiter)
	local list = {}; local pos = 1
	if string.find("", delimiter, 1) then
		return list
	end
	while 1 do
		local first, last = string.find(str, delimiter, pos)
		if first then
			table.insert(list, string.sub(str, pos, first-1))
			pos = last+1
		else
			table.insert(list, string.sub(str, pos))
			break
		end
	end
	return list
end

StringHelpers.Split = Split

--- Replace placeholder values in a string, such as [1], [2], etc. 
--- Takes a variable numbers of values.
--- @vararg values
--- @return string
function StringHelpers.ReplacePlaceholders(text, ...)
	local values = {...}
	if #values > 0 then
		if type(values[1]) == "table" then
			values = values[1]
		end
		if text == "" then
			text = values[1]
		else
			for i,v in pairs(values) do
				text = string.gsub(text, "%["..tostring(math.tointeger(i)).."%]", v)
			end
		end
	end
	return text
end

--- Remove leading/trailing whitespaces from a string.
--- @param s string
--- @return string
function StringHelpers.Trim(s)
	return (s:gsub("^%s*(.-)%s*$", "%1"))
end

---Get the UUID from a template, GUIDSTRING, etc.
---@type str string
---@return string
function StringHelpers.GetUUID(str)
	if str == nil then
		return nil
	end
	local start = string.find(str, "_[^_]*$") or 0
	if start > 0 then
		return string.sub(str, start+1)
	else
		return str
	end
end