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
		this.Value = Ext.GetTranslatedString(this.Handle, this.Content)
	end
	table.insert(TranslatedStringEntries, this)
    return this
end

function TranslatedString:Update()
	if self.Handle ~= "" and self.Handle ~= nil then
		self.Value = Ext.GetTranslatedString(self.Handle, self.Content) or self.Content
		if StringHelpers.IsNullOrEmpty(self.Value) then
			self.Value = self.Content
		end
	else
		self.Value = self.Content
	end
	return self.Value
end

--- Replace placeholder values in a string, such as [1], [2], etc. 
--- Takes a variable numbers of values.
--- @vararg values
--- @return string
function TranslatedString:ReplacePlaceholders(...)
	local values = {...}
	local str = self.Value
	if #values > 0 then
		for i,v in ipairs(values) do
			str = str:gsub("%["..tostring(i).."%]", v)
		end
	end
	return str
end

Classes["TranslatedString"] = TranslatedString
--local TranslatedString = Classes["TranslatedString"]