local function Print(...)
	if Ext.IsDeveloperMode() then
		Ext.Print(...)
	end
end

LeaderLib.Print = Print

function LeaderLib_Ext_Init()
	LeaderLib.Initialized = true
end

---Registers a function to the global table.
---@param name string
---@param func function
local function Register_Function(name, func)
    if type(func) == "function" then
        local func_name = "LeaderLib_Ext_" .. name
        _G[func_name] = func
        Ext.Print("[LeaderLib_Bootstrap.lua] Registered function ("..func_name..").")
    end
end

---Registers a table of key => function to the global table. The key is used for the name.
---@param tbl table
local function Register_Table(tbl)
    for k,func in pairs(tbl) do
        if type(func) == "function" then
            local func_name = "LeaderLib_Ext_" .. k
            _G[func_name] = func
            Ext.Print("LeaderLib_Bootstrap.lua] Registered function ("..func_name..").")
        else
            Ext.Print("[LeaderLib_Bootstrap.lua] Not a function type ("..type(func)..").")
        end
    end
end

LeaderLib.Register["Function"] = Register_Function
LeaderLib.Register["Table"] = Register_Table

function LeaderLib_Ext_Log(...)
	local printEnabled = false
	if Ext.Version() >= 42 then
		printEnabled = Ext.IsDeveloperMode() == true
	else
		printEnabled = GlobalGetFlag("LeaderLib_IsEditorMode") == 1
	end
	if printEnabled then
		local logArgs = {...}
		local output_str = ""
		for i,v in ipairs(logArgs) do
			output_str = output_str .. tostring(v)
		end
		Ext.Print(output_str)
	end
end

local function init_seed()
	local rnd = Ext.Random(9999)
	local seed = (Ext.Random(9999) * 214013) + 2531011
	LEADERLIB_RAN_SEED = seed
	Ext.Print("[LeaderLib_Common.lua] Set LEADERLIB_RAN_SEED to ("..tostring(LEADERLIB_RAN_SEED)..")")
	if Ext.IsServer() then
		Ext.BroadcastMessage("LeaderLib_SyncRanSeed", tostring(LEADERLIB_RAN_SEED), nil)
	end
end
if LEADERLIB_RAN_SEED == nil then
	init_seed()
end

local function FlattenTable(tbl)
	local result = {}
	local function flatten(tbl)
		for _, v in ipairs(tbl) do
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

local function DeepCopyTable(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[DeepCopyTable(orig_key)] = DeepCopyTable(orig_value)
		end
		setmetatable(copy, DeepCopyTable(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

local function CopyTable(orig, deep)
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
		return copy
	else
		return DeepCopyTable(orig)
	end
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

---Print a value or table (recursive).
---@param o table
---@param indexMap table
---@param innerOnly boolean
---@return string
local function Dump(o, indexMap, innerOnly, recursionLevel)
	if recursionLevel == nil then recursionLevel = 0 end
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if innerOnly == true then
				if recursionLevel > 0 then
					s = s .. ' ['..PrintIndex(k, indexMap)..'] = ' .. Dump(v, indexMap, innerOnly, recursionLevel + 1) .. ','
				else
					s = s .. ' ['..PrintIndex(k, nil)..'] = ' .. Dump(v, indexMap, innerOnly, recursionLevel + 1) .. ','
				end
			else
				s = s .. ' ['..PrintIndex(k, indexMap)..'] = ' .. Dump(v, indexMap, innerOnly, recursionLevel + 1) .. ','
			end
		end
		return s .. '} \n'
	else
		return tostring(o)
	end
end

---@param tbl table
---@param key any
---@return boolean
local function TableHasEntry(tbl, key)
	local v = tbl[key]
	if v ~= nil then
		return true
	elseif #tbl > 0 then
		for k,v2 in pairs(tbl) do
			if type(v2) == "table" then
				return TableHasEntry(v2, key)
			end
		end
	end
	return false
end

---@param tbl table
---@param key any
---@param fallback any
---@return any
local function GetTableEntry(tbl, key, fallback)
	local v = tbl[key]
	if v ~= nil then
		return v
	end
	return fallback
end

---Get a random entry from a table.
---@param tbl table
---@return any
local function GetRandomTableEntry(tbl)
	if #tbl > 0 then
		local rnd = Ext.Random(LEADERLIB_RAN_SEED)
		local ran = math.max(1, math.fmod(rnd,#tbl))
		return tbl[ran]
	end
	return nil
end

local function ShuffleTable(tbl)
	for i = #tbl, 2, -1 do
		local j = Ext.Random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

---@param max integer
---@param min integer
---@return integer
local function GetRandom(max,min)
	if max == nil then max = 999 end
	if min == nil then min = 0 end
	local rnd = Ext.Random(LEADERLIB_RAN_SEED)
	local ran = math.max(min, math.fmod(rnd,max))
	return ran
end

---Check if a string is equal to another. Case-insenstive.
---@param a string
---@param b string
---@param insensitive boolean
---@return boolean
local function StringEquals(a,b, insensitive)
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

local function StringIsNullOrEmpty(x)
	return x == nil or x == ""
end

--Source: https://github.com/sulai/Lib-Pico8/blob/master/lang.lua
---Generates an enum-like table
---@param names table
---@param offset integer
---@return table
local function Enum(names, offset)
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
local function SafeguardParam(in_value, param_type, fallback_value)
	if in_value == nil then return fallback_value end
	local in_type = type(in_value)
	if in_type == param_type then
		return in_value
	elseif in_type == "number" and param_type == "integer" then
		return in_value
	elseif in_type == "string" and param_type == "number" then
		return tonumber(in_value)
	elseif in_type == "string" and param_type == "integer" then
		return math.tointeger(in_value)
	else
		return fallback_value
	end
end

local function Split(s, sep)
    local fields = {}

    local sep = sep or " "
    local pattern = string.format("([^%s]+)", sep)
    string.gsub(s, pattern, function(c) fields[#fields + 1] = c end)

    return fields
end

---Join a table of string into one string.
---Source: http://www.wellho.net/resources/ex.php4?item=u105/spjo
---@param delimiter string
---@param list table
local function StringJoin(delimiter, list)
	local len = #list
	if len == 0 then
		return ""
	end
	local string = list[1]
	for i = 2, len do
		string = string .. delimiter .. list[i]
	end
	return string
end

---Split a string into a table.
---Source: http://www.wellho.net/resources/ex.php4?item=u105/spjo
---@param delimiter string
---@param str string
local function StringSplit(delimiter, str)
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

LeaderLib.Common = {
	Dump = Dump,
	CopyTable = CopyTable,
	FlattenTable = FlattenTable,
	TableHasEntry = TableHasEntry,
	StringEquals = StringEquals,
	StringIsNullOrEmpty = StringIsNullOrEmpty,
	Split = Split,
	ShuffleTable = ShuffleTable,
	GetTableEntry = GetTableEntry,
	GetRandomTableEntry = GetRandomTableEntry,
	GetRandom = GetRandom,
	Enum = Enum,
	SafeguardParam = SafeguardParam,
	StringJoin = StringJoin,
	StringSplit = StringSplit
}