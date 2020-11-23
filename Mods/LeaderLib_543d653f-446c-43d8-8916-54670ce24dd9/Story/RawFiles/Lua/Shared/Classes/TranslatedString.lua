---@class TranslatedString
local TranslatedString = {
	Type = "TranslatedString",
	Handle = "",
	Content = "",
	Value = "",
	Key = ""
}
TranslatedString.__index = TranslatedString

---@param handle string
---@param content string
---@return TranslatedString
function TranslatedString:Create(handle,content)
    local this =
    {
		Handle = handle,
		Content = content,
		Value = ""
	}
	setmetatable(this, self)
	this.Update(this)
	table.insert(TranslatedStringEntries, this)
    return this
end

---@param stringKey string
---@param fallback string|nil
---@return TranslatedString
function TranslatedString:CreateFromKey(stringKey, fallback)
	local this = {
		Key = stringKey,
		Content = fallback or "",
		Handle = "",
		Value = ""
	}
	setmetatable(this, self)
	this.Update(this)
	table.insert(TranslatedStringEntries, this)
    return this
end

function TranslatedString:Update()
	if not StringHelpers.IsNullOrEmpty(self.Key) then
		local content,handle = Ext.GetTranslatedStringFromKey(self.Key)
		if not StringHelpers.IsNullOrEmpty(handle) then
			self.Handle = handle
			self.Content = content or self.Content or ""
		end
	end
	if not StringHelpers.IsNullOrEmpty(self.Handle) then
		self.Value = Ext.GetTranslatedString(self.Handle, self.Content) or self.Content
	else
		self.Value = self.Content
	end
	if StringHelpers.IsNullOrEmpty(self.Value) then
		self.Value = self.Content or ""
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
					v = string.gsub(v, "%%", "%%%%")
					str = string.gsub(str, "%["..tostring(i).."%]", v)
				end
			end
		end
	end
	return str
end

Classes["TranslatedString"] = TranslatedString
--local TranslatedString = Classes["TranslatedString"]