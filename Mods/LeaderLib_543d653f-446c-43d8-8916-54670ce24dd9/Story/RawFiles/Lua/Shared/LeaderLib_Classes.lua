---@class TranslatedString
local TranslatedString = {
	Handle = "",
	Content = "",
	Value = ""
}
TranslatedString.__index = TranslatedString

---@param handle string
---@param content string
---@return TranslatedString
function TranslatedString:Create(handle,content)
    local this =
    {
		Handle = handle,
		Content = content
	}
	setmetatable(this, self)
	if this.Handle ~= "" and this.Handle ~= nil then
		if Ext.Version() >= 43 then
			this.Value = Ext.GetTranslatedString(this.Handle, this.Content)
		else
			this.Value = this.Content
		end
	end
    return this
end

function TranslatedString:Update()
	if self.Handle ~= "" and self.Handle ~= nil then
		if Ext.Version() >= 43 then
			self.Value = Ext.GetTranslatedString(self.Handle, self.Content)
		else
			self.Value = self.Content
		end
	else
		self.Value = self.Content
	end
	return self.Value
end

LeaderLib.Classes["TranslatedString"] = TranslatedString

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
		Ext.Print("[LeaderLib_Classes.lua:MessageData:CreateFromString] Error parsing string as table ("..str.."):\n" .. tostring(err))
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

LeaderLib.Classes["MessageData"] = MessageData

---An item boost to be used with NRD_ItemCloneAddBoost.
---@class ItemBoost
local ItemBoost = {
	Type = "DeltaMod",
	Boost = "",
	MinLevel = -1,
	MaxLevel = -1
}
ItemBoost.__index = ItemBoost

---@return ItemBoost
function ItemBoost:Create(boost, ...)
    local this =
    {
		Boost = boost
	}
	setmetatable(this, self)
	local params = {...}
	local paramsCount = #params
	if paramsCount > 0 then
		for i,param in ipairs(params) do
			if type(param) == "string" then
				this.Boost = param
			elseif type(param) == "number" then
				if this.MinLevel <= -1 then
					this.MinLevel = math.tointeger(param)
				elseif this.MinLevel <= -1 then
					this.MaxLevel = math.tointeger(param)
				end
			end
		end
	end
    return this
end

LeaderLib.Classes["ItemBoost"] = ItemBoost
--local ItemBoost = LeaderLib.Classes["ItemBoost"]