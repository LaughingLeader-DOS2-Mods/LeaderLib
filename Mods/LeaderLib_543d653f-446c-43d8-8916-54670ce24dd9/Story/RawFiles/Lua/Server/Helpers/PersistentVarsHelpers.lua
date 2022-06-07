if GameHelpers.PersistentVars == nil then
	---@class LeaderLibGameHelpers.PersistentVars
	GameHelpers.PersistentVars = {}
end

---@param modGlobalTable {PersistentVars:table} The mod's global table.
---@param defaultTable table A table of default values to copy from.
---@param initializedCallback fun(e:PersistentVarsLoadedEventArgs)|nil If set, this function will be called during the PersistentVarsLoaded event.
---@param autoUpdateVars boolean|nil If true, GameHelpers.PersistentVars.Update will be called on modGlobalTable.PersistentVars, using defaultTable, during the PersistentVarsLoaded event.
function GameHelpers.PersistentVars.Initialize(modGlobalTable, defaultTable, initializedCallback, autoUpdateVars)
	local data = TableHelpers.Clone(defaultTable or {}, true)
	if autoUpdateVars == true then
		local providedCallback = initializedCallback
		if providedCallback == nil then
			initializedCallback = function (e)
				modGlobalTable.PersistentVars = GameHelpers.PersistentVars.Update(defaultTable, modGlobalTable.PersistentVars)
			end
		else
			initializedCallback = function (e)
				modGlobalTable.PersistentVars = GameHelpers.PersistentVars.Update(defaultTable, modGlobalTable.PersistentVars)
				providedCallback(e)
			end
		end
	end
	if initializedCallback then
		local t = type(initializedCallback)
		if t == "function" then
			Events.PersistentVarsLoaded:Subscribe(initializedCallback)
		else
			error(string.format("[GameHelpers.PersistentVars.Initialize] initializedCallback must be a function! type(%s)", t), 2)
		end
	end
	modGlobalTable.PersistentVars = data
	return data
end

---Creates a new clone of defaultPersistentVars, copies keys that match from the loaded PersistentVars, then returns the new table. Use this to effectively remove unused entries from PersistentVars, while preserving whatever default values you need, by assigning PersistentVars to the table returned from this function.
---@param defaultPersistentVars table A table of default values to copy from.
---@param loadedPersistentVars table The loaded PersistentVars.
---@return table PersistentVars Assign PersistentVars to this value.
function GameHelpers.PersistentVars.Update(defaultPersistentVars, loadedPersistentVars)
	local data = TableHelpers.Clone(defaultPersistentVars, true)
	TableHelpers.CopyExistingKeys(data, loadedPersistentVars)
	return data
end