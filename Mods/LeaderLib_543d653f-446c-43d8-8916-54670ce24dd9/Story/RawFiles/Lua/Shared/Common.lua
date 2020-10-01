if Common == nil then Common = {} end

function Common.InitSeed()
	local rnd = Ext.Random(9999)
	local seed = (Ext.Random(9999) * 214013) + 2531011
	_G["LEADERLIB_RAN_SEED"] = seed
	PrintDebug("[LeaderLib:Common.lua] Set LEADERLIB_RAN_SEED to ("..tostring(seed)..")")
	if Ext.IsServer() then
		Ext.BroadcastMessage("LeaderLib_SyncRanSeed", tostring(seed), nil)
	end
end

function Common.FlattenTable(tbl)
	local result = {}
	function Common.flatten(tbl)
		for _, v in pairs(tbl) do
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

function Common.DeepCopyTable(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[Common.DeepCopyTable(orig_key)] = Common.DeepCopyTable(orig_value)
		end
		setmetatable(copy, Common.DeepCopyTable(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

function Common.CopyTable(orig, deep)
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
		return Common.DeepCopyTable(orig)
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
function Common.Dump(o, indexMap, innerOnly, recursionLevel)
	if recursionLevel == nil then recursionLevel = 0 end
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if innerOnly == true then
				if recursionLevel > 0 then
					s = s .. ' ['..PrintIndex(k, indexMap)..'] = ' .. Common.Dump(v, indexMap, innerOnly, recursionLevel + 1) .. ','
				else
					s = s .. ' ['..PrintIndex(k, nil)..'] = ' .. Common.Dump(v, indexMap, innerOnly, recursionLevel + 1) .. ','
				end
			else
				s = s .. ' ['..PrintIndex(k, indexMap)..'] = ' .. Common.Dump(v, indexMap, innerOnly, recursionLevel + 1) .. ','
			end
		end
		return s .. '}'
	else
		return tostring(o)
	end
end

---@param tbl table
---@param key any
---@return boolean
function Common.TableHasEntry(tbl, key)
	if tbl == nil then
		return false
	end
	local v = tbl[key]
	if v ~= nil then
		return true
	elseif #tbl > 0 or next(tbl, nil) ~= nil then
		for k,v2 in pairs(tbl) do
			if type(v2) == "table" then
				return Common.TableHasEntry(v2, key)
			end
		end
	end
	return false
end

---@param tbl table
---@return boolean
function Common.TableHasAnyEntry(tbl)
	if tbl == nil then
		return false
	end
	for i,v in pairs(tbl) do
		return true
	end
	return false
end

---@param tbl table
---@param key any
---@param fallback any
---@return any
function Common.GetTableEntry(tbl, key, fallback)
	local v = tbl[key]
	if v ~= nil then
		return v
	end
	return fallback
end

---Get a random entry from a table.
---@param tbl table
---@return any
function Common.GetRandomTableEntry(tbl)
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
function Common.PopRandomTableEntry(tbl)
	if #tbl > 0 then
		local rnd = Ext.Random(1,#tbl)
		--local ran = math.max(1, math.fmod(rnd,#tbl))
		local entry = tbl[rnd]
		tbl[rnd] = nil
		return entry
	end
	return nil
end

function Common.ShuffleTable(tbl)
	for i = #tbl, 2, -1 do
		local j = Ext.Random(i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

---@param max integer
---@param min integer
---@return integer
function Common.GetRandom(max,min)
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
function Common.Enum(names, offset)
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
function Common.SafeguardParam(in_value, param_type, fallback_value)
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

function Common.Split(s, sep)
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
function Common.FormatNumber(amount)
	local formatted = amount
	while true do  
		formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
		if (k==0) then
		break
		end
	end
	return formatted
end

function Common.TableLength(tbl, isKeyValueType)
	if isKeyValueType ~= true then
		return #tbl
	else
		local total = 0
		for k,v in pairs(tbl) do
			total = total + 1
		end
		return total
	end
end

-- Legacy
Common.StringEquals = StringHelpers.Equals
Common.StringIsNullOrEmpty = StringHelpers.IsNullOrEmpty
Common.StringJoin = StringHelpers.Join
Common.StringSplit = StringHelpers.Split