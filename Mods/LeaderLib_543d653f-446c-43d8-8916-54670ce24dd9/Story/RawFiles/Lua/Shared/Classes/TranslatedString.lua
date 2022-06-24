---@type TranslatedString[]
local _translatedStringUpdate = {}
--Turn into a weak table since we don't care to update variables that were deleted.
--setmetatable(_translatedStringUpdate, {__mode = "kv"})

local _EXTVERSION = Ext.Version()
local _getTranslatedStringKeyFunction = Ext.GetTranslatedStringFromKey
if _EXTVERSION >= 56 then
	_getTranslatedStringKeyFunction = Ext.L10N.GetTranslatedStringFromKey
end

---@class TranslatedStringOptions
---@field AutoReplacePlaceholders boolean|nil If true, GameHelpers.Tooltip.ReplacePlaceholders is called when the Value is updated.
---@field Format string|nil Text to wrap around the content. Should include an %s for the content's position in the string, such as <font color='#FF0000'>%s</font>

---@class TranslatedString:TranslatedStringOptions
local TranslatedString = {
	Type = "TranslatedString",
	Handle = "",
	Content = "",
	Value = "",
	Key = "",
	Format = "",
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
---@param params TranslatedStringOptions|nil
---@return TranslatedString
function TranslatedString:Create(handle, content, params)
	local this =
	{
		Handle = handle,
		Content = content,
		Value = "",
		AutoReplacePlaceholders = false,
	}
	if type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, self)
	this.Update(this)
	_translatedStringUpdate[#_translatedStringUpdate+1] = this
	return this
end

---@param format string Text to wrap around the content. Should include an %s for the content's position in the string, such as <font color='#FF0000'>%s</font>
---@return TranslatedString
function TranslatedString:WithFormat(format)
	self.Format = format
	return self
end

---@param key string
---@param fallback string|nil
---@param params TranslatedStringOptions|nil
---@return TranslatedString
function TranslatedString:CreateFromKey(key, fallback, params)
	local this = {
		Key = key,
		Content = fallback or "",
		Handle = "",
		Value = "",
		AutoReplacePlaceholders = false,
	}
	if type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, self)
	this.Update(this)
	_translatedStringUpdate[#_translatedStringUpdate+1] = this
	return this
end

function TranslatedString:Update()
	if not StringHelpers.IsNullOrEmpty(self.Key) then
		local content,handle = _getTranslatedStringKeyFunction(self.Key)
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
			self.Value = Ext.GetTranslatedString(self.Handle, self.Content)
			if StringHelpers.IsNullOrWhitespace(self.Value) then
				self.Value = self.Content
			end
		else
			self.Value = self.Content
		end
	end
	if not StringHelpers.IsNullOrWhitespace(self.Format) then
		if not StringHelpers.IsNullOrEmpty(self.Content) then
			local b,result = pcall(string.format, self.Format, self.Content)
			if b then
				self.Value = result
			end
		else
			local b,result = pcall(string.format, self.Format, self.Value)
			if b then
				self.Value = result
			end
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
	if not StringHelpers.IsNullOrWhitespace(self.Format) then
		--Just in case the Value already has the format when it was updated.
		if not StringHelpers.IsNullOrEmpty(self.Content) then
			local b,result = pcall(string.format, self.Format, self.Content)
			if b then
				str = result
			end
		else
			local b,result = pcall(string.format, self.Format, self.Value)
			if b then
				str = result
			end
		end
	end
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

function UpdateTranslatedStrings()
	local length = #_translatedStringUpdate
	for i=1,length do
		local entry = _translatedStringUpdate[i]
		if entry then
			TranslatedString.Update(entry)
		end
	end
	fprint(LOGLEVEL.TRACE, "[LeaderLib:TranslatedString:%s] Updated %s TranslatedString entries.", Ext.IsClient() and "CLIENT" or "SERVER", length)
end

if not Vars.IsEditorMode then
	Ext.RegisterListener("SessionLoaded", UpdateTranslatedStrings)
else
	RegisterListener("Initialized", UpdateTranslatedStrings)
end

if Vars.DebugMode then
	Ext.RegisterConsoleCommand("leaderlib_ts_missingkeys", function ()
		local kv = {}
		local keys = {}
		local length = #_translatedStringUpdate
		for i=1,length do
			local entry = _translatedStringUpdate[i]
			if entry then
				if not StringHelpers.IsNullOrEmpty(entry.Key) then
					local content,handle = Ext.GetTranslatedStringFromKey(entry.Key)
					if StringHelpers.IsNullOrEmpty(handle) then
						keys[#keys+1] = entry.Key
						kv[entry.Key] = entry.Value
					end
				end
			end
		end
		table.sort(keys)
		Ext.Print("Missing Keys:")
		Ext.Dump(keys)
		local text = "Key\tContent\n"
		for i,v in ipairs(keys) do
			text = text .. string.format("%s\t%s\n", v, kv[v])
		end
		Ext.Print("Saved key/values to 'Dumps/LeaderLib_MissingKeys.tsv'")
		GameHelpers.IO.SaveFile("Dumps/LeaderLib_MissingKeys.tsv", text)
	end)
end