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
--local TranslatedString = LeaderLib.Classes["TranslatedString"]

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
	SlotType = "",
	WeaponType = "",
	TwoHanded = "",
	Boost = "",
	MinLevel = -1,
	MaxLevel = -1,
	Chance = 100
}
ItemBoost.__index = ItemBoost

---@param itemBoost ItemBoost
---@param vars table
local function SetVars(itemBoost, vars)
	if vars ~= nil then
		if vars.Type ~= nil then itemBoost.Type = vars.Type end
		if vars.MinLevel ~= nil then itemBoost.MinLevel = vars.MinLevel end
		if vars.MaxLevel ~= nil then itemBoost.MaxLevel = vars.MaxLevel end
		if vars.Chance ~= nil then itemBoost.Chance = vars.Chance end
		if vars.SlotType ~= nil then itemBoost.SlotType = vars.SlotType end
		if vars.TwoHanded ~= nil then itemBoost.TwoHanded = vars.TwoHanded end
		if vars.WeaponType ~= nil then itemBoost.WeaponType = vars.WeaponType end
	end
end

---@param boost string
---@param vars table
---@return ItemBoost
function ItemBoost:Create(boost, vars)
    local this =
    {
		Boost = boost,
		Type = "DeltaMod",
		MinLevel = -1,
		MaxLevel = -1,
		Chance = 100
	}
	setmetatable(this, self)
	SetVars(this, vars)
    return this
end

LeaderLib.Classes["ItemBoost"] = ItemBoost
--local ItemBoost = LeaderLib.Classes["ItemBoost"]

---An container for multiple ItemBoost entries.
---@class ItemBoostGroup
local ItemBoostGroup = {
	Entries = {}
}
ItemBoostGroup.__index = ItemBoostGroup

---@param entries table
---@param vars table
---@return ItemBoostGroup
function ItemBoostGroup:Create(entries, vars)
    local this =
    {
		Entries = entries
	}
	setmetatable(this, self)
	if vars ~= nil then
		for i,v in pairs(this.Entries) do
			SetVars(v, vars)
		end
	end
    return this
end

---@return table
function ItemBoostGroup:GetRandomEntry()
    return LeaderLib.Common.GetRandomTableEntry(self.Entries)
end
LeaderLib.Classes["ItemBoostGroup"] = ItemBoostGroup
--local ItemBoostGroup = LeaderLib.Classes["ItemBoostGroup"]