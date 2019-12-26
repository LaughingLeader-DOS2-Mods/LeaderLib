local function dump(o)
	if type(o) == 'table' then
		local s = '{ '
		for k,v in pairs(o) do
			if type(k) ~= 'number' then k = '"'..k..'"' end
			s = s .. '['..k..'] = ' .. dump(v) .. ','
		end
		return s .. '} \n'
	else
		return tostring(o)
	end
end

local function has_table_entry(tbl, key)
	local v = tbl[key]
	if v ~= nil then
		return true
	elseif #tbl > 0 then
		for k,v2 in pairs(tbl) do
			if type(v2) == "table" then
				return has_table_entry(v2, key)
			end
		end
	end
	return false
end

LeaderLib.Common = {
	Dump = dump,
	TableHasEntry = has_table_entry
}