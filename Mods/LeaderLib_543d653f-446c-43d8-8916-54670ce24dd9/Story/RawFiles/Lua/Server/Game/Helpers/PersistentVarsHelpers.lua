if GameHelpers.PersistentVars == nil then
	GameHelpers.PersistentVars = {}
end

---@param modGlobalTable table The mod's global table (can just pass _G)
---@param defaultTable table A table of default values to copy from.
---@param initializedCallback function|nil If set, this function will be called during the PersistentVarsLoaded event, and PersistentVars will be updated with the default values if needed (like from older saves).
function GameHelpers.PersistentVars.Initialize(modGlobalTable, defaultTable, initializedCallback)
	local data = Common.CloneTable(defaultTable) or {}
	if initializedCallback then
		local t = type(initializedCallback)
		if t == "function" then
			RegisterListener("PersistentVarsLoaded", initializedCallback)
		else
			error(string.format("[GameHelpers.PersistentVars.Initialize] initializedCallback must be a function! type(%s)", t), 2)
		end
	end
	modGlobalTable.PersistentVars = data
	return modGlobalTable.PersistentVars
end