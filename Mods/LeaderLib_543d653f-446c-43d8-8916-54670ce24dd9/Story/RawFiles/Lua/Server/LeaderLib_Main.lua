local function table_has_index(tbl, index)
	if #tbl > index then
		if tbl[index] ~= nil then
            return true
        end
	end
    return false
end

local function PrintAttributes(char)
	local attributes = {"Strength", "Finesse", "Intelligence", "Constitution", "Memory", "Wits"}
	for k, att in pairs(attributes) do
		local val = CharacterGetAttribute(char, att)
		Osi.LeaderLog_Log("DEBUG", "[lua:leaderlib.PrintAttributes] (" .. char .. ") | " .. att .. " = " .. val)
	end
end

local function SetModIsActiveFlag(uuid, modid)
	--local flag = string.gsub(modid, "%s+", "_") -- Replace spaces
	local flag = tostring(modid).. "_IsActive"
	local flagEnabled = GlobalGetFlag(flag)
	if NRD_IsModLoaded(uuid) == 1 then
		if flagEnabled == 0 then
			GlobalSetFlag(flag)
		end
	else
		if flagEnabled == 1 then
			GlobalClearFlag(flag)
		end
	end
end

---Set a character's name with a translated string value.
---@param char string
---@param handle string
---@param fallback string
function LeaderLib_Ext_SetCustomNameWithLocalization(char,handle,fallback)
	local name = fallback
	if Ext.Version() >= 43 then
		name = Ext.GetTranslatedString(handle, fallback)
	end
	CharacterSetCustomName(char, name)
end

LeaderLib.Main = {
	PrintAttributes = PrintAttributes,
	SetModIsActiveFlag = SetModIsActiveFlag
}

LeaderLib.Register.Table(LeaderLib.Main);