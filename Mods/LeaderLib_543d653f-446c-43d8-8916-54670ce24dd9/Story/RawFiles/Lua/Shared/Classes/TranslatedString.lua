local _EXTVERSION = Ext.Utils.Version()

local _type = type
local _pairs = pairs
local _pcall = pcall
local _tostring = tostring
local _setmetatable = setmetatable

local _floor = math.floor

local _format = string.format
local _gsub = string.gsub

local _getTranslatedStringKey = Ext.L10N.GetTranslatedStringFromKey
local _getTranslatedString = Ext.L10N.GetTranslatedString

local _printError = Ext.Utils.PrintError
local _printWarning = Ext.Utils.PrintWarning
local _print = Ext.Utils.Print

local _strnull = StringHelpers.IsNullOrEmpty
local _strnullspace = StringHelpers.IsNullOrWhitespace
local _streq = StringHelpers.Equals
local _replaceplaceholders = GameHelpers.Tooltip.ReplacePlaceholders

---@type TranslatedString[]
local _registeredStrings = {}

---@class TranslatedStringOptions
---@field AutoReplacePlaceholders boolean|nil If true, GameHelpers.Tooltip.ReplacePlaceholders is called when the Value is updated.
---@field Format string|nil Text to wrap around the content. Should include an %s for the content's position in the string, such as <font color='#FF0000'>%s</font>

---Wrapper class around a translated string or string key, that auto-updates itself with the translated value when the session is loaded.   
---Allows easily replacing placeholders ([1], [2] etc) with variables.  
---@class TranslatedString:TranslatedStringOptions
---@field private Content string The fallback text.
---@field Value string The retrieved text for the key or handle. If the TranslatedString does not exist, this will be the fallback text or key.
local TranslatedString = {
	Type = "TranslatedString",
	Handle = "",
	Content = "",
	Key = "",
	Format = "",
	AutoReplacePlaceholders = false,
}

local _canUpdate = false

local _ValidStates = {
	Menu = true,
	Running = true,
	Paused = true,
	GameMasterPause = true,
}

Ext.Events.GameStateChanged:Subscribe(function (e)
	_canUpdate = _ValidStates[e.ToState]
end)

local _TSTRING_META = {
	__index = function (tbl,k)
		if k == "Value" then
			--Update the value when a script tries to retrieve it, instead of updating everything at once
			if _canUpdate then
				local value = TranslatedString.Update(tbl)
				return value
			else
				return tbl.Content
			end
		end
		return TranslatedString[k]
	end,
	__tostring = function(tbl)
		if tbl and tbl.Value then
			return tbl.Value
		end
		return tbl.Content
	end,
	__eq = function (a,b)
		return TranslatedString.Equals(a, b.Value, false)
	end
}

---@param target table
---@return TranslatedString
function TranslatedString:SetMeta(target)
	_setmetatable(target, _TSTRING_META)
	return target
end

---@param target table
---@return boolean
function TranslatedString:IsTranslatedString(target)
	if type(target) == "table" and (target.Type == TranslatedString.Type or target.Key or target.Handle) then
		return true
	end
	return false
end

---@param handle string
---@param fallback string
---@param params TranslatedStringOptions|nil
---@return TranslatedString
function TranslatedString:Create(handle, fallback, params)
	fallback = fallback or ""
	local this =
	{
		Handle = handle,
		Content = fallback,
		AutoReplacePlaceholders = false,
	}
	if _type(params) == "table" then
		for k,v in _pairs(params) do
			this[k] = v
		end
	end
	if _canUpdate then
		TranslatedString.Update(this)
	end
	_setmetatable(this, _TSTRING_META)
	_registeredStrings[#_registeredStrings+1] = this
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
	fallback = fallback or ""
	local this = {
		Key = key,
		Content = fallback,
		Handle = "",
		AutoReplacePlaceholders = false,
	}
	if _type(params) == "table" then
		for k,v in _pairs(params) do
			this[k] = v
		end
	end
	if _canUpdate then
		TranslatedString.Update(this)
	end
	_setmetatable(this, _TSTRING_META)
	_registeredStrings[#_registeredStrings+1] = this
	return this
end

---@private
---Updates the Value property of the TranslatedString, using either the Key or Handle. 
---This is an internal function called when TranslatedString.Value is first fetched.
function TranslatedString:Update()
	local value = ""
	local key = rawget(self, "Key") or ""
	local fallback = rawget(self, "Content") or ""
	local handle = rawget(self, "Handle") or ""
	local format = rawget(self, "Format") or ""

	if not _strnull(key) then
		local content,handle = _getTranslatedStringKey(key)
		if not _strnull(handle) then
			handle = handle
			rawset(self, "Handle", handle)
		end
		if not _strnull(content) then
			---@cast content string
			value = content
		elseif not _strnull(fallback) then
			value = fallback
		else
			value = key
		end
	elseif not _strnull(handle) then
		value = _getTranslatedString(handle, fallback)
		if _strnullspace(value) then
			value = fallback
		end
	else
		value = fallback
	end
	if not _strnullspace(format) then
		if _strnull(value) then
			local b,result = _pcall(_format, format, fallback)
			if b then
				value = result
			end
		else
			local b,result = _pcall(_format, format, value)
			if b then
				value = result
			end
		end
	end
	if not _strnullspace(value) and self.AutoReplacePlaceholders then
		value = _replaceplaceholders(value)
	end
	rawset(self, "Value", value)
	return value
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
	if self.AutoReplacePlaceholders then
		return GameHelpers.Tooltip.ReplacePlaceholders(str)
	end
	return str
end

---@param val string
---@param caseInsensitive boolean|nil
function TranslatedString:Equals(val, caseInsensitive)
	return _streq(self.Value, val, caseInsensitive)
end

Classes.TranslatedString = TranslatedString

if Vars.DebugMode then
	Ext.RegisterConsoleCommand("leaderlib_ts_missingkeys", function ()
		local kv = {}
		local keys = {}
		local length = #_registeredStrings
		for i=1,length do
			local entry = _registeredStrings[i]
			if entry then
				if not _strnull(entry.Key) then
					local content,handle = _getTranslatedStringKey(entry.Key)
					if _strnull(handle) and not kv[entry.Key] then
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