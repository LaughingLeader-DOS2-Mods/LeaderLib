---@class LeaderLibEnum
---@field _Names table<string,integer>
---@field _Integers table<integer,string>
---@field Get fun():(fun():integer,string)
---@operator call(string):integer
local Enum = {}

local iter = function (tbl,i)
	i = i + 1
	local value = tbl[i]
	if value == nil then return end
	return i, value
end

local function stateless_iter(tbl, k)
	local v = nil
	k,v = next(tbl, k)
	if nil~=v then return k,v end
end

---@param target table
---@param integersTbl table<integer, string>|nil
---@param namesTbl table<string, integer>|nil
---@param startIndex integer|nil
local function CreateEnum(target, integersTbl, namesTbl, startIndex)
	local integers = {}
	local names = {}
	local startIndex = startIndex or 1
	if integersTbl then
		integers = integersTbl
	end
	if namesTbl then
		names = namesTbl
	end
	if not namesTbl or not integersTbl then
		for k,v in pairs(target) do
			local t = type(k)
			if t == "string" then
				if v == 0 then startIndex = 0 end
				names[k] = v
				if type(v) == "number" then
					integers[v] = k
				end
			elseif t == "number" then
				if k == 0 then startIndex = 0 end
				integers[k] = v
				if type(v) == "string" then
					names[v] = k
				end
			end
		end
	end
	local hasIntegers = #integers > 0
	local iterFunc = function ()
		if hasIntegers then
			return iter, integers, startIndex-1
		else
			return stateless_iter, names, nil
		end
	end
	setmetatable(target, {
		__call = function(tbl, v)
			local t = type(v)
			if t == "number" then
				return integers[v]
			elseif t == "string" then
				return names[v]
			end
		end,
		__newindex = function() end,
		__index = function(_,key)
			if key == "_Names" then
				return names
			elseif key == "_Integers" then
				return integers
			elseif key == "Get" then
				return iterFunc
			end
			return names[key] or integers[key]
		end,
		__pairs = iterFunc,
		__ipairs = iterFunc
	})
	return target
end

---@param target table
---@param integersTbl table<integer, string>|nil
---@param namesTbl table<string, integer>|nil
---@param startIndex integer|nil
function Enum:Create(target, integersTbl, namesTbl, startIndex)
	return CreateEnum(target, integersTbl, namesTbl, startIndex)
end

setmetatable(Enum, {
	__call = CreateEnum
})

Classes.Enum = Enum