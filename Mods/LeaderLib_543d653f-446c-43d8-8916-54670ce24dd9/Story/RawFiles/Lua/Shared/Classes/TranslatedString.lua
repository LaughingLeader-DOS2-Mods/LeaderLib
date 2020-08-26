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
	this.Update(this)
	table.insert(TranslatedStringEntries, this)
    return this
end

function TranslatedString:Update()
	if self.Handle ~= "" and self.Handle ~= nil then
		self.Value = Ext.GetTranslatedString(self.Handle, self.Content) or self.Content
	end
	if StringHelpers.IsNullOrEmpty(self.Value) then
		self.Value = self.Content
	end
	return self.Value
end

--- Replace placeholder values in a string, such as [1], [2], etc. 
--- Takes a variable numbers of values.
--- @vararg values
--- @return string
function TranslatedString:ReplacePlaceholders(...)
	if self == nil then
		Ext.PrintError("[LeaderLib:TranslatedString:ReplacePlaceholders] Call ReplacePlaceholders with a colon instead! myVar:ReplacePlaceholders(val1)")
		return ""
	end
	local values = {...}
	local str = self.Value
	if #values > 0 then
		if type(values[1]) == "table" then
			values = values[1]
		end
		if str == "" then
			str = values[1]
		else
			for i,v in pairs(values) do
				if type(v) == "number" then
					str = string.gsub(str, "%["..tostring(i).."%]", math.tointeger(v))
				else
					str = string.gsub(str, "%["..tostring(i).."%]", v)
				end
			end
		end
	end
	return str
end

Classes["TranslatedString"] = TranslatedString
--local TranslatedString = Classes["TranslatedString"]