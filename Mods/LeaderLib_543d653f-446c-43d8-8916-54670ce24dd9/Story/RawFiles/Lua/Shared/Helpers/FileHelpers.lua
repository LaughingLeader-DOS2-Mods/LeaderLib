if GameHelpers.IO == nil then
	GameHelpers.IO = {}
end

function GameHelpers.IO.LoadJsonFile(filepath, fallback)
	local file = Ext.IO.LoadFile(filepath)
	if file then
		return Common.JsonParse(file)
	end
	return fallback
end

function GameHelpers.IO.SaveJsonFile(filepath, data)
	Ext.IO.SaveFile(filepath, Common.JsonStringify(data))
end