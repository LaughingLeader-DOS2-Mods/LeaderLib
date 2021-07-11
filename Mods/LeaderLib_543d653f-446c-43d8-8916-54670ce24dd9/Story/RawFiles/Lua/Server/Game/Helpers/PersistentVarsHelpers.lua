if GameHelpers.PersistentVars == nil then
	GameHelpers.PersistentVars = {}
end

---@param modGlobalTable table The mod's global table (can just pass _G)
---@param defaults table A table of default values to copy from.
---@param initializedCallback function|nil If set, this function will be called during the PersistentVarsLoaded event, and PersitentVars will be updated with the default values if needed (like from older saves).
function GameHelpers.PersistentVars.Initialize(modGlobalTable, defaults, initializedCallback)
	GameHelpers.SetVariable(modGlobalTable.PersistentVars, TableHelpers.Clone(defaults))
	if initializedCallback then
		local t = type(initializedCallback)
		if t == "function" then
			RegisterListener("PersistentVarsLoaded", initializedCallback)
		else
			error(string.format("[GameHelpers.PersistentVars.Initialize] initializedCallback must be a function! type(%s)", t), 2)
		end
	end
	return modGlobalTable.PersistentVars
end

function GameHelpers.PersistentVars.Initialize(modGlobalTable, defaults)
	GameHelpers.SetVariable(modGlobalTable.PersistentVars, TableHelpers.Clone(defaults))
	return modGlobalTable.PersistentVars
end