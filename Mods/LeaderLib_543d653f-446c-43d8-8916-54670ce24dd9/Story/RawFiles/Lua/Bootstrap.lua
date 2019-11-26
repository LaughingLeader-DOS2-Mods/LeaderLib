local function table_has_index(tbl, index)
	if #tbl > index then
		if tbl[index] ~= nil then
            return true
        end
	end
    return false
end

function LeaderLib_Ext_StringToVersion(version_str)
	obj = nil
	if ObjectExists(ITEMGUID_S_LeaderLib_EventParser_6983a226-0d86-47da-a27f-ee3e483625e6, 1) then

	else
		obj = CharacterGetHostCharacter()
	end

	if obj ~= nil then
		version_vals = {}
		for s in string.gmatch(version_str, "([^.]+)") do
			table.insert(version_vals, s)
		end
		--for i,v in ipairs(version_vals) do print(i,v) end

		major = -1
		minor = -1
		revision = -1
		build = -1
		if table_has_index(version_vals, 0) then
			major = version_vals[0]
		end
		if table_has_index(version_vals, 1) then
			minor = version_vals[1]
		end
		if table_has_index(version_vals, 2) then
			revision = version_vals[2]
		end
		if table_has_index(version_vals, 3) then
			build = version_vals[3]
		end
		if major ~= -1 and minor ~= -1 and revision ~= -1 and build ~= -1 then
			SetVarInteger(obj, "LeaderLib_StringToVersion_Major", major)
			SetVarInteger(obj, "LeaderLib_StringToVersion_Minor", minor)
			SetVarInteger(obj, "LeaderLib_StringToVersion_Revision", revision)
			SetVarInteger(obj, "LeaderLib_StringToVersion_Build", build)
			ObjectSetFlag(obj, "LeaderLib_StringToVersion_Success", 0)
			SetStoryEvent(obj, "LeaderLib_StringToVersion_Success")
		end
		--return major,minor,revision,build
end