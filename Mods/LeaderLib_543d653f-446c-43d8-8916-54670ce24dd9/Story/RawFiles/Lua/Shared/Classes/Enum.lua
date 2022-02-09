---@class Enum
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

local function CreateEnum(target)
	local integers = {}
	local names = {}
	local startIndex = 1
	for k,v in pairs(target) do
		local t = type(k)
		if t == "string" then
			if v == 0 then startIndex = 0 end
			names[v] = k
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
			if t == "number" or t == "string" then
				return target[v]
			end
		end,
		__newindex = function() end,
		__index = function(_,key)
			return names[key] or integers[key]
		end,
		__pairs = iterFunc,
		__ipairs = iterFunc
	})
	return target
end

function Enum:Create(target)
	return CreateEnum(target)
end
setmetatable(Enum, {
	__call = CreateEnum
})

Classes.Enum = Enum