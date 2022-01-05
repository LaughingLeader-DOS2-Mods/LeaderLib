if StringHelpers == nil then 
	StringHelpers = {} 
end

---Check if a string is equal to another. Case-insenstive.
---@param a string
---@param b string
---@param insensitive boolean|nil
---@param trimWhitespace boolean|nil
---@return boolean
function StringHelpers.Equals(a,b, insensitive, trimWhitespace)
	if insensitive == nil then insensitive = true end
	if a ~= nil and b ~= nil then
		if trimWhitespace == true then
			a = StringHelpers.Trim(a)
			b = StringHelpers.Trim(b)
		end
		if insensitive and type(a) == "string" and type(b) == "string" then
			return string.upper(a) == string.upper(b)
		else
			return a == b
		end
	end
	return false
end

local NULL_UUID = {
	["NULL_00000000-0000-0000-0000-000000000000"] = true,
	["00000000-0000-0000-0000-000000000000"] = true
}

StringHelpers.NULL_UUID = "NULL_00000000-0000-0000-0000-000000000000"

---Checks if a string is null or empty.
---@param str string
---@return boolean
function StringHelpers.IsNullOrEmpty(str)
	-- CharacterCreationFinished sends 00000000-0000-0000-0000-000000000000 or some reason, omitting the NULL_
	return str == nil or str == "" or NULL_UUID[str] or type(str) ~= "string"
end

---Checks if a string is null or only whitespace.
---@param str string
---@return boolean
function StringHelpers.IsNullOrWhitespace(str)
	-- CharacterCreationFinished sends 00000000-0000-0000-0000-000000000000 or some reason, omitting the NULL_
	return str == nil or str == "" or NULL_UUID[str] or type(str) ~= "string" or string.gsub(str, "%s+", "") == ""
end

---Capitalize a string.
---@param s string
---@return string
function StringHelpers.Capitalize(s)
	return s:sub(1,1):upper()..s:sub(2)
end

---Join a table of string into one string.
---Source: http://www.wellho.net/resources/ex.php4?item=u105/spjo
---@param delimiter string
---@param list table
---@param uniqueOnly boolean 
---@param getStringFunction fun(k:any,v:any):string
function StringHelpers.Join(delimiter, list, uniqueOnly, getStringFunction)
	local finalResult = ""
	local useFunction = type(getStringFunction) == "function"

	local i = 0
	for o,v in TableHelpers.TryOrderedEach(list) do
		i = i + 1
		local result = nil
		if useFunction then
			local b,str = xpcall(getStringFunction, debug.traceback, o, v)
			if b then
				if str then
					result = str
				end
			else
				Ext.PrintError(str)
			end
		else
			result = v
		end
		if result ~= nil then
			if type(result) ~= "string" then
				result = tostring(result)
			end
			if not uniqueOnly or (uniqueOnly and not string.find(finalResult, result)) then
				if i > 1 and finalResult ~= "" then
					finalResult = string.format("%s%s%s", finalResult, delimiter, result)
				else
					finalResult = result
				end
			end
		end
	end
	return finalResult
end

---Join a table of string into one string.
---Source: http://www.wellho.net/resources/ex.php4?item=u105/spjo
---@param delimiter string
---@param list table
---@param uniqueOnly boolean 
---@param getStringFunction table
function StringHelpers.DebugJoin(delimiter, list, uniqueOnly, getStringFunction)
	local finalResult = ""
	local useFunction = type(getStringFunction) == "function"

	local i = 0
	for k,v in TableHelpers.TryOrderedEach(list) do
		i = i + 1
		local result = nil
		if useFunction then
			local b,str = xpcall(getStringFunction, debug.traceback, k, v)
			if b then
				result = str
			else
				Ext.PrintError(str)
			end
		else
			result = v
		end
		if result ~= nil then
			if type(result) ~= "string" then
				result = tostring(result)
			else
				result = '"'..result..'"'
			end
			if not uniqueOnly or (uniqueOnly and not string.find(finalResult, result)) then
				if i > 1 then
					finalResult = string.format("%s%s%s", finalResult, delimiter, result)
				else
					finalResult = result
				end
			end
		end
	end
	return finalResult
end

---Split a string into a table.
---Source: http://www.wellho.net/resources/ex.php4?item=u105/spjo
---@param str string
---@param delimiter string
function StringHelpers.Split(str, delimiter)
	local list = {}; local pos = 1
	if string.find("", delimiter, 1) then
		table.insert(list, str)
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

--- Replace placeholder values in a string, such as [1], [2], etc. 
--- Takes a variable numbers of values.
--- @vararg any
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

--- Escapes all magic characters, such as -
--- @param s string
--- @return string
function StringHelpers.EscapeMagic(s)
	return (s:gsub('[%^%$%(%)%%%.%[%]%*%+%-%?]','%%%1'))
end

--- Similar to string.gsub, but escapes all magic characters in the pattern beforehand.
--- @param s string
--- @param pattern string
--- @param repl string|table|function
--- @param n ?integer
--- @return string
function StringHelpers.Replace(s, pattern, repl, n)
	return string.gsub(s, StringHelpers.EscapeMagic(pattern), repl, n)
end

local _cachedParsedGUID = {}

---Get the UUID from a template, GUIDSTRING, etc.
---@param str string
---@return string
function StringHelpers.GetUUID(str)
	if str == nil
	or str == ""
	or str == "NULL_00000000-0000-0000-0000-000000000000"
	or str == "00000000-0000-0000-0000-000000000000"
	then
		return str
	end
	local result = _cachedParsedGUID[str]
	if result == nil then
		local start = string.find(str, "_[^_]*$") or 0
		if start > 0 then
			result = string.sub(str, start+1)
		else
			result = str
		end
		_cachedParsedGUID[str] = result
	end
	return result
end

--- Split a version integer into separate values
---@param version integer
---@return integer,integer,integer,integer
function ParseVersion(version)
	if type(version) == "string" then
		version = math.floor(tonumber(version))
	elseif type(version) == "number" then
		version = math.tointeger(version)
	end
	local major = math.floor(version >> 28)
	local minor = math.floor(version >> 24) & 0x0F
	local revision = math.floor(version >> 16) & 0xFF
	local build = math.floor(version & 0xFFFF)
	return major,minor,revision,build
end

local _versionIntToString = {}

--- Turn a version integer into a string.
---@param version integer
---@return string
function StringHelpers.VersionIntegerToVersionString(version)
	local result = _versionIntToString[version]
	if result == nil then
		if version == -1 then
			_versionIntToString[-1] = "-1"
			return "-1"
		end
		local major,minor,revision,build = ParseVersion(version)
		if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
			result = string.format("%s.%s.%s.%s", major, minor, revision, build)
			_versionIntToString[version] = result
		elseif major == -1 and minor == -1 and revision == -1 and build == -1 then
			result = "-1"
			_versionIntToString[version] = result
		end
	end
	return result
end

---@deprecated
VersionIntegerToVersionString = StringHelpers.VersionIntegerToVersionString

---Appends two strings together with some text if the first string is not empty, otherwise returns the second string.
---@param a string
---@param b string
---@param appendWith string|nil
function StringHelpers.Append(a,b,appendWith)
	if a == nil or a == "" then
		return b
	else
		return string.format("%s%s%s", a, (appendWith or ""), b)
	end
end

---Returns an iterator for each line of a string.
---@param s string
function StringHelpers.GetLines(s)
	if s:sub(-1)~="\n" then s=s.."\n" end
	return s:gmatch("(.-)\n")
end

---Remove font tags from a string.
---@param str string
function StringHelpers.StripFont(str)
	if str == nil or str == "" then
		return str
	end
	return string.gsub(str, "<font.-'>", ""):gsub("</font>", "")
end

function StringHelpers.IsMatch(str, match, explicit)
	if not explicit then
		str = string.lower(str)
	end
	if type(match) == "table" then
		for i,v in pairs(match) do
			if explicit then
				if v == str then
					return true
				end
			else
				if string.find(str, string.lower(v)) then
					return true
				end
			end
		end
	else
		if explicit then
			return str == match
		else
			if string.find(str, string.lower(match)) then
				return true
			end
		end
	end
	return false
end

---Formats a number into a short version, such as 1000 to 1K.
---@param n number
---@return string
function StringHelpers.GetShortNumberString(n)
    local steps = {
        {1,""},
        {1e3,"K"},
        {1e6,"M"},
        {1e9,"G"},
        {1e12,"T"},
    }
    for _,b in ipairs(steps) do
        if b[1] <= n+1 then
            steps.use = _
        end
    end
    local result = string.format("%.1f", n / steps[steps.use][1])
    if tonumber(result) >= 1e3 and steps.use < #steps then
        steps.use = steps.use + 1
        result = string.format("%.1f", tonumber(result) / 1e3)
    end
    result = string.sub(result,0,string.sub(result,-1) == "0" and -3 or -1) -- Remove .0 (just if it is zero!)
    return result .. steps[steps.use][2]
end

---Add commas to a number.
---@param n number
---@return string
function StringHelpers.CommaNumber(n)
	if n == nil then
		return ""
	end
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
	return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

---Check if a string separated by a delimiter has a value.
---@param str string
---@param delimiter string
---@param value string
---@return boolean
function StringHelpers.DelimitedStringContains(str, delimiter, value)
	if StringHelpers.IsNullOrWhitespace(str) then
		return false
	end
	local values = StringHelpers.Split(str, delimiter)
	return Common.TableHasValue(values, value)
end

local _skillPrototypeToId = {}
--setmetatable(_skillPrototypeToId, {__mode = "kv"})

---Get a skill's real entry name. Formats away _-1, _10, etc.
---@param skillPrototype string A skill id like Projectile_Fireball_-1
---@return string
function StringHelpers.GetSkillEntryName(skillPrototype)
	local result = _skillPrototypeToId[skillPrototype]
	if result == nil then
		result = string.gsub(skillPrototype, "_%-?%d+$", "")
		_skillPrototypeToId[skillPrototype] = result
	end
	return result
end

GetSkillEntryName = StringHelpers.GetSkillEntryName

---Helper for string.find with some additional options.
---@param s string
---@param pattern string
---@param caseInsensitive ?boolean Searches for a string.lower version of s.
---@param startPos ?integer If set, start the find from this position.
---@param endPos ?integer If set, end the find at this position.
---@param findStartPos ?integer
---@param findPlain ?boolean
---@return integer,integer,string
function StringHelpers.Find(s, pattern, caseInsensitive, startPos, endPos, findStartPos, findPlain)
	if caseInsensitive then
		s = string.lower(s)
	end
	if startPos then
		local subText = string.sub(s, startPos, endPos)
		return string.find(subText, pattern, findStartPos, findPlain)
	else
		return string.find(s, pattern, findStartPos, findPlain)
	end
end