local function init_seed()
    local rnd = math.random(9999)
    local seed = (math.random(9999) * 214013) + 2531011
	LeaderLib_RAN_SEED = seed
	Ext.Print("[LeaderLib__Common.lua] Set LeaderLib_RAN_SEED to ("..tostring(LeaderLib_RAN_SEED)..")")
end
init_seed()

local function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..tostring(k)..'"' end
			s = s .. '['..tostring(k)..'] = ' .. dump(v) .. ','
		end
		return s .. '} \n'
	else
		return tostring(o)
	end
end

local function has_table_entry(tbl, key)
	local v = tbl[key]
	if v ~= nil then
		return true
	elseif #tbl > 0 then
		for k,v2 in pairs(tbl) do
			if type(v2) == "table" then
				return has_table_entry(v2, key)
			end
		end
	end
	return false
end

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
		local rnd = math.random(LeaderLib_RAN_SEED)
		local ran = math.max(1, math.fmod(rnd,#tbl))
		return tbl[ran]
	end
	return nil
end

local function GetRandom(max,min)
	if max == nil then max = 999 end
	if min == nil then min = 0 end
	local rnd = math.random(LeaderLib_RAN_SEED)
	local ran = math.max(min, math.fmod(rnd,max))
	return ran
end

local function StringEquals(a,b)
	if a ~= nil and b ~= nil then
		return string.upper(a) == string.upper(b)
	end
	return false
end

local function StringIsNullOrEmpty(x)
	return x == nil or x == ""
end

--Source: https://github.com/sulai/Lib-Pico8/blob/master/lang.lua
---Generate an enum-like table
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

LeaderLib.Common = {
	Dump = dump,
	TableHasEntry = has_table_entry,
	StringEquals = StringEquals,
	StringIsNullOrEmpty = StringIsNullOrEmpty,
	GetTableEntry = GetTableEntry,
	GetRandomTableEntry = GetRandomTableEntry,
	GetRandom = GetRandom,
	Enum = Enum
}