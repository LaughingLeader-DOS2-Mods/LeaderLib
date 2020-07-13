---@class MessageData
local MessageData = {
	ID = "NONE",
	Params = {}
}
MessageData.__index = MessageData

---Prepares a message for data transfer and converts it to string.
---@return string
function MessageData:ToString()
    return Ext.JsonStringify(self)
end

local function TryParseTable(str)
	local tbl = Ext.JsonParse(str)
	if tbl ~= nil then
		if tbl.ID ~= nil and tbl.Params ~= nil then
			return MessageData:CreateFromTable(tbl.ID, tbl.Params)
		end
	end
	error("String is not a MessageData structure.")
end

---Prepares a message for data transfer and converts it to string.
---@param str string
---@return MessageData
function MessageData:CreateFromString(str)
	local b,result = xpcall(TryParseTable, function(err)
		Ext.PrintError("[LeaderLib_Classes.lua:MessageData:CreateFromString] Error parsing string as table ("..str.."):\n" .. tostring(err))
	end, str)
	if b and result ~= nil then
		return result
	end
	return nil
end

---@param id string
---@return MessageData
function MessageData:Create(id,...)
    local this =
    {
		ID = id,
		Params = {...}
	}
	setmetatable(this, self)
    return this
end

---@param id string
---@param params table
---@return MessageData
function MessageData:CreateFromTable(id,params)
    local this =
    {
		ID = id,
		Params = params
	}
	setmetatable(this, self)
    return this
end

Classes["MessageData"] = MessageData