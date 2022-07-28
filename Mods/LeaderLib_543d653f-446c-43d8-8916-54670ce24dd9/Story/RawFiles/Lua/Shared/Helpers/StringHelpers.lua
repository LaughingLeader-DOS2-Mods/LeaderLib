if StringHelpers == nil then 
	StringHelpers = {} 
end

--Optimize global function usage by assigning locals. We're only doing this since string helpers are used often.
local _type = type
local _gsub = string.gsub
local _sub = string.sub
local _lower = string.lower
local _upper = string.upper
local _reverse = string.reverse
local _format = string.format
local _find = string.find
local _match = string.match
local _tostring = tostring

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
		if insensitive then
			return _upper(_tostring(a)) == _upper(_tostring(b))
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

---@alias NULL_UUID "NULL_00000000-0000-0000-0000-000000000000"

StringHelpers.NULL_UUID = "NULL_00000000-0000-0000-0000-000000000000"
StringHelpers.UNSET_HANDLE = "ls::TranslatedStringRepository::s_HandleUnknown"

---Checks if a string is null or empty.
---@param str string|nil
---@return boolean
function StringHelpers.IsNullOrEmpty(str)
	-- CharacterCreationFinished sends 00000000-0000-0000-0000-000000000000 or some reason, omitting the NULL_
	return str == nil or str == "" or NULL_UUID[str] or _type(str) ~= "string"
end

---Checks if a string is null or only whitespace.
---@param str string|nil
---@return boolean
function StringHelpers.IsNullOrWhitespace(str)
	-- CharacterCreationFinished sends 00000000-0000-0000-0000-000000000000 or some reason, omitting the NULL_
	return str == nil or str == "" or NULL_UUID[str] or _type(str) ~= "string" or _gsub(str, "%s+", "") == ""
end

---Capitalize a string.
---@param s string
---@return string
function StringHelpers.Capitalize(s)
	return _upper(_sub(s, 1,1)).._sub(s, 2)
end

---@alias StringHelpersJoinGetStringCallback fun(k:any,v:any):string

---Join a table of string into one string.
---Source: http://www.wellho.net/resources/ex.php4?item=u105/spjo
---@param delimiter string
---@param list table
---@param uniqueOnly boolean|nil
---@param getStringFunction StringHelpersJoinGetStringCallback|nil
function StringHelpers.Join(delimiter, list, uniqueOnly, getStringFunction)
	local finalResult = ""
	local useFunction = _type(getStringFunction) == "function"

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
			if _type(result) ~= "string" then
				result = tostring(result)
			end
			if not uniqueOnly or (uniqueOnly and not _find(finalResult, result)) then
				if i > 1 and finalResult ~= "" then
					finalResult = _format("%s%s%s", finalResult, delimiter, result)
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
	local useFunction = _type(getStringFunction) == "function"

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
			if _type(result) ~= "string" then
				result = tostring(result)
			else
				result = '"'..result..'"'
			end
			if not uniqueOnly or (uniqueOnly and not _find(finalResult, result)) then
				if i > 1 then
					finalResult = _format("%s%s%s", finalResult, delimiter, result)
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
---@return string[]
function StringHelpers.Split(str, delimiter)
	if _type(str) ~= "string" then
		return {}
	end
	local list = {}; local pos = 1
	if _find("", delimiter, 1) then
		table.insert(list, str)
		return list
	end
	while 1 do
		local first, last = _find(str, delimiter, pos)
		if first then
			table.insert(list, _sub(str, pos, first-1))
			pos = last+1
		else
			table.insert(list, _sub(str, pos))
			break
		end
	end
	return list
end

--- Replace placeholder values in a string, such as [1], [2], etc. 
--- Takes a variable numbers of values.
--- @vararg SerializableValue
--- @return string
function StringHelpers.ReplacePlaceholders(text, ...)
	local values = {...}
	if #values > 0 then
		if _type(values[1]) == "table" then
			values = values[1]
		end
		if text == "" then
			text = values[1]
		else
			for i,v in pairs(values) do
				text = _gsub(text, "%["..tostring(math.tointeger(i)).."%]", v)
			end
		end
	end
	return text
end

--- Remove **only** leading/trailing whitespaces from a string.
--- @param s string
--- @return string
function StringHelpers.Trim(s)
	return _gsub(s, "^%s*(.-)%s*$", "%1")
end

--- Remove **all** whitespace from a string.
--- @param s string
--- @return string
function StringHelpers.RemoveWhitespace(s)
	return _gsub(s, "%s+", "")
end

--- Escapes all magic characters, such as -
--- @param s string
--- @return string
local function _escape(s)
	return _gsub(s, '[%^%$%(%)%%%.%[%]%*%+%-%?]','%%%1')
end

StringHelpers.EscapeMagic = _escape

--- Similar to gsub, but escapes all magic characters in the pattern beforehand.
--- @param s string
--- @param pattern string
--- @param repl string|table|function
--- @param n integer|nil
--- @return string
function StringHelpers.Replace(s, pattern, repl, n)
	return _gsub(s, _escape(pattern), repl, n)
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
		local start = _find(str, "_[^_]*$") or 0
		if start > 0 then
			result = _sub(str, start+1)
		else
			result = str
		end
		_cachedParsedGUID[str] = result
	end
	return result
end

local _ISUUID_PATTERN = "%x%x%x%x%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%-%x%x%x%x%x%x%x%x%x%x%x%x"

---Checks if a string is a UUID.
---@param str string
---@return boolean
function StringHelpers.IsUUID(str)
	if _type(str) ~= "string" then
		return false
	end
	if str == nil or str == "" then
		return false
	end
	if str == "NULL_00000000-0000-0000-0000-000000000000"
	or str == "00000000-0000-0000-0000-000000000000"
	then
		return true
	end
	return _match(str, _ISUUID_PATTERN) ~= nil
end

local _ISHANDLE_PATTERN = "h%x%x%x%x%x%x%x%xg%x%x%x%xg%x%x%x%xg%x%x%x%xg%x%x%x%x%x%x%x%x%x%x%x%x"

---Checks if a string is a Translated String handle.
---@param str string
---@return boolean
function StringHelpers.IsTranslatedStringHandle(str)
	if _type(str) ~= "string" then
		return false
	end
	if str == nil or str == "" then
		return false
	end
	if str == StringHelpers.UNSET_HANDLE then
		return true
	end
	return _match(str, _ISHANDLE_PATTERN) ~= nil
end

--- Split a version integer into separate values
---@param version integer
---@return integer,integer,integer,integer
function ParseVersion(version)
	if _type(version) == "string" then
		version = math.floor(tonumber(version))
	elseif _type(version) == "number" then
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
			result = _format("%s.%s.%s.%s", major, minor, revision, build)
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
		return _format("%s%s%s", a, (appendWith or ""), b)
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
	return _gsub(str, "<font.-'>", ""):gsub("</font>", "")
end

function StringHelpers.IsMatch(str, match, explicit)
	if not explicit then
		str = _lower(str)
	end
	if _type(match) == "table" then
		for i,v in pairs(match) do
			if explicit then
				if v == str then
					return true
				end
			else
				if _find(str, _lower(v)) then
					return true
				end
			end
		end
	else
		if explicit then
			return str == match
		else
			if _find(str, _lower(match)) then
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
    local result = _format("%.1f", n / steps[steps.use][1])
    if tonumber(result) >= 1e3 and steps.use < #steps then
        steps.use = steps.use + 1
        result = _format("%.1f", tonumber(result) / 1e3)
    end
    result = _sub(result,0,_sub(result,-1) == "0" and -3 or -1) -- Remove .0 (just if it is zero!)
    return result .. steps[steps.use][2]
end

---Add commas to a number.
---@param n number
---@return string
function StringHelpers.CommaNumber(n)
	if n == nil then
		return ""
	end
	local left,num,right = _match(n,'^([^%d]*%d)(%d*)(.-)$')
	if left then
		return _format("%s%s%s", left, _reverse(_gsub(_reverse(num), "(%d%d%d)", "%1,")), right or "")
	end
	return ""
	--return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
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

---Get a skill's real entry name. Formats away _-1, _10, etc.
---@param skillPrototype string A skill id like Projectile_Fireball_-1
---@return string
function StringHelpers.GetSkillEntryName(skillPrototype)
	local result = _skillPrototypeToId[skillPrototype]
	if result == nil then
		result = _gsub(skillPrototype, "_%-?%d+$", "")
		_skillPrototypeToId[skillPrototype] = result
	end
	return result
end

GetSkillEntryName = StringHelpers.GetSkillEntryName

---Helper for find with some additional options.
---@param s string
---@param pattern string|string[]
---@param caseInsensitive boolean|nil Searches for a lower version of s.
---@param startPos integer|nil If set, start the find from this position.
---@param endPos integer|nil If set, end the find at this position.
---@param findStartPos integer|nil
---@param findPlain boolean|nil
---@return integer,integer,string
function StringHelpers.Find(s, pattern, caseInsensitive, startPos, endPos, findStartPos, findPlain)
	if caseInsensitive then
		s = _lower(s)
	end
	local t = _type(pattern)
	if t == "string" then
		if startPos then
			local subText = _sub(s, startPos, endPos)
			return _find(subText, pattern, findStartPos, findPlain)
		else
			return _find(s, pattern, findStartPos, findPlain)
		end
	elseif t == "table" then
		for k,v in pairs(pattern) do
			local results = {StringHelpers.Find(s, v, caseInsensitive, startPos, endPos, findStartPos, findPlain)}
			if results[1] then
				return table.unpack(results)
			end
		end
	end
end

---Similar to find, except it just checks that the result isn't nil, and supports an array of strings to check.
---@param str string|string[]
---@param pattern string|string[]
---@param caseInsensitive boolean|nil Searches for a lower version of s.
---@param startPos integer|nil If set, start the find from this position.
---@param endPos integer|nil If set, end the find at this position.
---@param findStartPos integer|nil
---@param findPlain boolean|nil
---@return boolean stringContainsPattern
function StringHelpers.Contains(str, pattern, caseInsensitive, startPos, endPos, findStartPos, findPlain)
	local strType = _type(str)
	if strType == "string" then
		if caseInsensitive then
			str = _lower(str)
		end
		local t = _type(pattern)
		if t == "string" then
			if startPos then
				local subText = _sub(str, startPos, endPos)
				return _find(subText, pattern, findStartPos, findPlain) ~= nil
			else
				return _find(str, pattern, findStartPos, findPlain) ~= nil
			end
		elseif t == "table" then
			for _,v in pairs(pattern) do
				if StringHelpers.Contains(str, v, caseInsensitive, startPos, endPos, findStartPos, findPlain) then
					return true
				end
			end
		end
	elseif strType == "table" then
		for _,v in pairs(str) do
			if StringHelpers.Contains(v, pattern, caseInsensitive, startPos, endPos, findStartPos, findPlain) then
				return true
			end
		end
	end
	return false
end