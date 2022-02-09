---@class Enum
local Enum = {}

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
		__pairs = function(tbl)
			local i = startIndex
			local function iter(tbl)
				local name = names[i]
				local v = target[name]
				if v ~= nil then
					i = i + 1
					return name,v
				end
			end
			return iter, tbl, names[i]
		end,
		__ipairs = function(tbl)
			local i = startIndex
			local function iter(tbl,i)
				local v = target[integers[i]]
				if v ~= nil then
					i = i + 1
					return integers[1],v
				end
			end
			return iter, tbl, integers[1]
		end
	})
end

function Enum:Create(target)
	return CreateEnum(target)
end
setmetatable(Enum, {
	__call = CreateEnum
})

Classes.Enum = Enum