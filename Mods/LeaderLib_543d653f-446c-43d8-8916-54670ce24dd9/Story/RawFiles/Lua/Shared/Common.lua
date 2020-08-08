function Log(...)
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
	_G["LEADERLIB_RAN_SEED"] = seed
	PrintDebug("[LeaderLib:Common.lua] Set LEADERLIB_RAN_SEED to ("..tostring(seed)..")")
	if Ext.IsServer() then
		Ext.BroadcastMessage("LeaderLib_SyncRanSeed", tostring(seed), nil)
	end
end
if _G["LEADERLIB_RAN_SEED"] == nil then
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

---PrintDebug a value or table (recursive).
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
	if tbl == nil then
		return false
	end
	local v = tbl[key]
	if v ~= nil then
		return true
	elseif #tbl > 0 or next(tbl, nil) ~= nil then
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
		local rnd = Ext.Random(1,#tbl)
		--local ran = math.max(1, math.fmod(rnd,#tbl))
		return tbl[rnd]
	end
	return nil
end

---Get a random entry from a table after removing it.
---@param tbl table
---@return any
local function PopRandomTableEntry(tbl)
	if #tbl > 0 then
		local rnd = Ext.Random(1,#tbl)
		--local ran = math.max(1, math.fmod(rnd,#tbl))
		local entry = tbl[rnd]
		tbl[rnd] = nil
		return entry
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
	local rnd = Ext.Random(0, _G["LEADERLIB_RAN_SEED"])
	local ran = math.max(min, math.fmod(rnd,max))
	return ran
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
	if #fields == 0 then
		return s
	else
		return fields
	end
end

---Formats a number with commas.
---@param amount integer
local function FormatNumber(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
		break
		end
	end
	return formatted
end

Common = {
	Dump = Dump,
	CopyTable = CopyTable,
	FlattenTable = FlattenTable,
	TableHasEntry = TableHasEntry,
	StringEquals = StringHelpers.Equals,
	StringIsNullOrEmpty = StringHelpers.IsNullOrEmpty,
	Split = Split,
	ShuffleTable = ShuffleTable,
	GetTableEntry = GetTableEntry,
	GetRandomTableEntry = GetRandomTableEntry,
	PopRandomTableEntry = PopRandomTableEntry,
	GetRandom = GetRandom,
	Enum = Enum,
	SafeguardParam = SafeguardParam,
	StringJoin = StringHelpers.Join,
	StringSplit = StringHelpers.Split,
	FormatNumber = FormatNumber
}