if _G["LeaderLib"] == nil then
	LeaderLib = {
		Main = {},
		Settings = {},
		Common = {},
		Game = {},
		Data = {},
		Register = {},
		ModRegistration = {},
		Initialized = false,
		IgnoredMods = {
			--["7e737d2f-31d2-4751-963f-be6ccc59cd0c"] = true,--LeaderLib
			["2bd9bdbe-22ae-4aa2-9c93-205880fc6564"] = true,--Shared
			["eedf7638-36ff-4f26-a50a-076b87d53ba0"] = true,--Shared_DOS
			["1301db3d-1f54-4e98-9be5-5094030916e4"] = true,--Divinity: Original Sin 2
			["a99afe76-e1b0-43a1-98c2-0fd1448c223b"] = true,--Arena
			["00550ab2-ac92-410c-8d94-742f7629de0e"] = true,--Game Master
			["015de505-6e7f-460c-844c-395de6c2ce34"] = true,--Nine Lives
			["38608c30-1658-4f6a-8adf-e826a5295808"] = true,--Herb Gardens
			["1273be96-6a1b-4da9-b377-249b98dc4b7e"] = true,--Source Meditation
			["af4b3f9c-c5cb-438d-91ae-08c5804c1983"] = true,--From the Ashes
			["ec27251d-acc0-4ab8-920e-dbc851e79bb4"] = true,--Endless Runner
			["b40e443e-badd-4727-82b3-f88a170c4db7"] = true,--Character_Creation_Pack
			["9b45f7e5-d4e2-4fc2-8ef7-3b8e90a5256c"] = true,--8 Action Points
			["f33ded5d-23ab-4f0c-b71e-1aff68eee2cd"] = true,--Hagglers
			["68a99fef-d125-4ed0-893f-bb6751e52c5e"] = true,--Crafter's Kit
			["ca32a698-d63e-4d20-92a7-dd83cba7bc56"] = true,--Divine Talents
			["f30953bb-10d3-4ba4-958c-0f38d4906195"] = true,--Combat Randomiser
			["423fae51-61e3-469a-9c1f-8ad3fd349f02"] = true,--Animal Empathy
			["2d42113c-681a-47b6-96a1-d90b3b1b07d3"] = true,--Fort Joy Magic Mirror
			["8fe1719c-ef8f-4cb7-84bd-5a474ff7b6c1"] = true,--Enhanced Spirit Vision
			["a945eefa-530c-4bca-a29c-a51450f8e181"] = true,--Sourcerous Sundries
			["f243c84f-9322-43ac-96b7-7504f990a8f0"] = true,--Improved Organisation
			["d2507d43-efce-48b8-ba5e-5dd136c715a7"] = true,--Pet Power
		}
	}
end

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
	local rnd = math.random(9999)
	local seed = (math.random(9999) * 214013) + 2531011
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
		local rnd = math.random(LEADERLIB_RAN_SEED)
		local ran = math.max(1, math.fmod(rnd,#tbl))
		return tbl[ran]
	end
	return nil
end

---@param max integer
---@param min integer
---@return integer
local function GetRandom(max,min)
	if max == nil then max = 999 end
	if min == nil then min = 0 end
	local rnd = math.random(LEADERLIB_RAN_SEED)
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

LeaderLib.Common = {
	Dump = Dump,
	CopyTable = CopyTable,
	FlattenTable = FlattenTable,
	TableHasEntry = has_table_entry,
	StringEquals = StringEquals,
	StringIsNullOrEmpty = StringIsNullOrEmpty,
	Split = Split,
	GetTableEntry = GetTableEntry,
	GetRandomTableEntry = GetRandomTableEntry,
	GetRandom = GetRandom,
	Enum = Enum,
	SafeguardParam = SafeguardParam
}