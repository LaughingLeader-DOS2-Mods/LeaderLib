local _EXTVERSION = Ext.Version()

local _type = type
local _pairs = pairs
local _pcall = pcall
local _tostring = tostring
local _setmetatable = setmetatable

local _floor = math.floor

local _format = string.format
local _gsub = string.gsub

local _getTranslatedStringKey = Ext.GetTranslatedStringFromKey
local _getTranslatedString = Ext.GetTranslatedString

local _printError = Ext.PrintError
local _printWarning = Ext.PrintWarning
local _print = Ext.Print

if _EXTVERSION >= 56 then
	_getTranslatedStringKey = Ext.L10N.GetTranslatedStringFromKey
	_getTranslatedString = Ext.L10N.GetTranslatedString
	_printError = Ext.Utils.PrintError
	_printWarning = Ext.Utils.PrintWarning
	_print = Ext.Utils.Print
end


local _strnull = StringHelpers.IsNullOrEmpty
local _strnullspace = StringHelpers.IsNullOrWhitespace
local _streq = StringHelpers.Equals
local _replaceplaceholders = GameHelpers.Tooltip.ReplacePlaceholders

---@type TranslatedString[]
local _translatedStringUpdate = {}
--Turn into a weak table since we don't care to update variables that were deleted.
--setmetatable(_translatedStringUpdate, {__mode = "kv"})

---@class TranslatedStringOptions
---@field AutoReplacePlaceholders boolean|nil If true, GameHelpers.Tooltip.ReplacePlaceholders is called when the Value is updated.
---@field Format string|nil Text to wrap around the content. Should include an %s for the content's position in the string, such as <font color='#FF0000'>%s</font>

---Wrapper class around a translated string or string key, that auto-updates itself with the translated value when the session is loaded.   
---Allows easily replacing placeholders ([1], [2] etc) with variables.  
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

local _TSTRING_META = {
	__index = function (_,k)
		return TranslatedString[k]
	end,
	__tostring = function(t)
		if t and t.Value then
			return t.Value
		end
		return _tostring(t)
	end,
	__eq = function (a,b)
		return TranslatedString.Equals(a, b.Value, false)
	end
}

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
	if _type(params) == "table" then
		for k,v in _pairs(params) do
			this[k] = v
		end
	end
	_setmetatable(this, _TSTRING_META)
	TranslatedString.Update(this)
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
	if _type(params) == "table" then
		for k,v in _pairs(params) do
			this[k] = v
		end
	end
	_setmetatable(this, _TSTRING_META)
	TranslatedString.Update(this)
	_translatedStringUpdate[#_translatedStringUpdate+1] = this
	return this
end

function TranslatedString:Update()
	if not _strnull(self.Key) then
		local content,handle = _getTranslatedStringKey(self.Key)
		if not _strnull(handle) then
			self.Handle = handle
		end
		if not _strnull(content) then
			self.Value = content
		elseif not _strnull(self.Content) then
			self.Value = self.Content
		else
			self.Value = self.Key
		end
	else
		if not _strnull(self.Handle) then
			self.Value = _getTranslatedString(self.Handle, self.Content)
			if _strnullspace(self.Value) then
				self.Value = self.Content
			end
		else
			self.Value = self.Content
		end
	end
	if not _strnullspace(self.Format) then
		if not _strnull(self.Content) then
			local b,result = _pcall(_format, self.Format, self.Content)
			if b then
				self.Value = result
			end
		else
			local b,result = _pcall(_format, self.Format, self.Value)
			if b then
				self.Value = result
			end
		end
	end
	if not _strnullspace(self.Value) and self.AutoReplacePlaceholders then
		self.Value = _replaceplaceholders(self.Value)
	end
	return self.Value
end

--- Replace placeholder values in a string, such as [1], [2], etc.  
--- Takes a variable numbers of values.  
--- @vararg SerializableValue|table<integer, SerializableValue>
--- @return string
function TranslatedString:ReplacePlaceholders(...)
	if self == nil then
		_printError("[LeaderLib:TranslatedString:ReplacePlaceholders] Call ReplacePlaceholders with a colon instead! myVar:ReplacePlaceholders(val1)")
		return ""
	end
	local values = {...}
	local str = self.Value
	if not _strnullspace(self.Format) then
		--Just in case the Value already has the format when it was updated.
		if not _strnull(self.Content) then
			local b,result = _pcall(_format, self.Format, self.Content)
			if b then
				str = result
			end
		else
			local b,result = _pcall(_format, self.Format, self.Value)
			if b then
				str = result
			end
		end
	end
	local len = #values
	if str ~= "" and len > 0 then
		for i=1,len do
			local v = values[i]
			local pattern = _format("%%[%i%%]", i)
			local t = _type(v)
			if t == "number" then
				if _floor(v) == v then
					str = _gsub(str, pattern, _format("%i", v))
				else
					str = _gsub(str, pattern, _tostring(v))
				end
			elseif t == "table" then
				_printWarning(_format("[TranslatedString:ReplacePlaceholders(%s)] Entry (%s) in params is a table (%s). Joining with ', '", self.Key or self.Handle, i, Lib.serpent.line(v, {SimplifyUserdata=true})))
				str = _gsub(str, pattern, _gsub(StringHelpers.Join(", ", v), "%%", "%%%%"))
			elseif t == "string" then
				v = _gsub(v, "%%", "%%%%")
				str = _gsub(str, pattern, v)
			end
		end
	end
	return str
end

---@param val string
---@param caseInsensitive boolean|nil
function TranslatedString:Equals(val, caseInsensitive)
	return _streq(self.Value, val, caseInsensitive)
end

Classes["TranslatedString"] = TranslatedString
--local TranslatedString = Classes["TranslatedString"]

function UpdateTranslatedStrings()
	local length = #_translatedStringUpdate
	if length > 0 then
		for i=1,length do
			local entry = _translatedStringUpdate[i]
			if entry then
				TranslatedString.Update(entry)
			end
		end
	end
	if Vars.DebugMode then
		fprint(LOGLEVEL.TRACE, "[LeaderLib:TranslatedString:%s] Updated %s TranslatedString entries.", Ext.IsClient() and "CLIENT" or "SERVER", length)
	end
end

if not Vars.IsEditorMode then
	Ext.RegisterListener("SessionLoaded", UpdateTranslatedStrings)
else
	Events.Initialized:Subscribe(UpdateTranslatedStrings)
end

if Vars.DebugMode then
	Ext.RegisterConsoleCommand("leaderlib_ts_missingkeys", function ()
		local kv = {}
		local keys = {}
		local length = #_translatedStringUpdate
		for i=1,length do
			local entry = _translatedStringUpdate[i]
			if entry then
				if not _strnull(entry.Key) then
					local content,handle = _getTranslatedStringKey(entry.Key)
					if _strnull(handle) then
						keys[#keys+1] = entry.Key
						kv[entry.Key] = entry.Value
					end
				end
			end
		end
		table.sort(keys)
		_print("Missing Keys:")
		Ext.Dump(keys)
		local text = "Key\tContent\n"
		for i=1,#keys do
			local v = keys[i]
			text = text .. _format("%s\t%s\n", v, kv[v])
		end
		_print("Saved key/values to 'Dumps/LeaderLib_MissingKeys.tsv'")
		GameHelpers.IO.SaveFile("Dumps/LeaderLib_MissingKeys.tsv", text)
	end)
end