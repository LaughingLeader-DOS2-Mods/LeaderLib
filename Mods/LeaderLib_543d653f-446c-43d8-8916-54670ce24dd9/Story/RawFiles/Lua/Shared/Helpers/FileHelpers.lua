if GameHelpers.IO == nil then
	GameHelpers.IO = {}
end

local _EXTVERSION = Ext.Version()

local _loadFile = _EXTVERSION < 56 and Ext.LoadFile or Ext.IO.LoadFile
local _saveFile = _EXTVERSION < 56 and Ext.SaveFile or Ext.IO.SaveFile

function GameHelpers.IO.LoadJsonFile(filepath, fallback)
	local file =_loadFile(filepath)
	if file then
		return Common.JsonParse(file)
	end
	return fallback
end

function GameHelpers.IO.SaveJsonFile(filepath, data)
	local output = data
	local t = type(data)
	if t == "table" then
		output = Common.JsonStringify(data)
	elseif t ~= "string" then
		output = tostring(data)
	end
	_saveFile(filepath, output)
end

---Simple wrapper around Ext.SaveFile or Ext.IO.SaveFile, depending on the extender version.
---@param filepath string
---@param text string|number|boolean|table|userdata|fun():string
function GameHelpers.IO.SaveFile(filepath, text)
	local t = type(text)
	local output = text
	if t ~= "string" then
		if t == "table" or t == "userdata" then
			output = Ext.DumpExport(text)
		elseif t == "number" or t == "boolean" then
			output = tostring(text)
		elseif t == "function" then
			local b,result = xpcall(text, debug.traceback)
			if result ~= nil then
				output = tostring(result)
			else
				output = ""
			end
		else
			output = tostring(text)
		end
	end
	_saveFile(filepath, output)
end

---Simple wrapper around Ext.LoadFile or Ext.IO.LoadFile, depending on the extender version.
---@param filepath string
---@param context string|nil
---@return string
function GameHelpers.IO.LoadFile(filepath, context)
	return _loadFile(filepath, context)
end