---@class TranslatedString
local TranslatedString = {
	Type = "TranslatedString",
	Handle = "",
	Content = "",
	Value = "",
	Key = "",
	AutoReplacePlaceholders = false,
}
TranslatedString.__index = TranslatedString
TranslatedString.__tostring = function(t)
	if t and t.Value then
		return t.Value
	end
	return tostring(t)
end

---@param handle string
---@param content string
---@return TranslatedString
function TranslatedString:Create(handle,content)
	local this =
	{
		Handle = handle,
		Content = content,
		Value = "",
		AutoReplacePlaceholders = false,
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
		Value = "",
		AutoReplacePlaceholders = false,
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
		end
		if not StringHelpers.IsNullOrEmpty(content) then
			self.Value = content
		elseif not StringHelpers.IsNullOrEmpty(self.Content) then
			self.Value = self.Content
		else
			self.Value = self.Key
		end
	else
		if not StringHelpers.IsNullOrEmpty(self.Handle) then
			self.Value = Ext.GetTranslatedString(self.Handle, self.Content) or self.Content
		else
			self.Value = self.Content
		end
	end
	if not StringHelpers.IsNullOrWhitespace(self.Value) and self.AutoReplacePlaceholders then
		self.Value = GameHelpers.Tooltip.ReplacePlaceholders(self.Value)
	end
	return self.Value
end

--- Replace placeholder values in a string, such as [1], [2], etc. 
--- Takes a variable numbers of values.
--- @vararg any
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
				local pattern = string.format("%%[%i%%]", i)
				if type(v) == "number" then
					if math.floor(v) == v then
						str = string.gsub(str, pattern, string.format("%i", v))
					else
						str = string.gsub(str, pattern, tostring(v))
					end
				else
					v = string.gsub(v, "%%", "%%%%")
					str = string.gsub(str, pattern, v)
				end
			end
		end
	end
	return str
end

---@param val string
---@param caseInsensitive boolean|nil
function TranslatedString:Equals(val, caseInsensitive)
	return StringHelpers.Equals(self.Value, val, caseInsensitive)
end

Classes["TranslatedString"] = TranslatedString
--local TranslatedString = Classes["TranslatedString"]