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
	_saveFile(filepath, Common.JsonStringify(data))
end