if EffectManager == nil then
	EffectManager = {}
end

---@alias LeaderLibEffectManagerTarget UUID|NETID|EsvCharacter|EsvItem|number[]

---@class LeaderLibObjectLoopEffectSaveData
---@field Effect string
---@field Bone string
---@field Handle integer

---@param uuid string
---@param effect string
---@param bone string
---@param handle integer
function EffectManager.SaveObjectEffectData(uuid, effect, bone, handle)
	if PersistentVars.ObjectLoopEffects[uuid] == nil then
		PersistentVars.ObjectLoopEffects[uuid] = {}
	end
	table.insert(PersistentVars.ObjectLoopEffects[uuid], {
		Effect = effect,
		Bone = bone,
		Handle = handle
	})
end

---@class LeaderLibWorldLoopEffectSaveData
---@field Effect string
---@field Position number[]
---@field Handle integer

---@param target number[]
---@param effect string
---@param bone string
---@param handle integer
function EffectManager.SaveWorldEffectData(target, effect, handle)
	local region = SharedData.RegionData.Current

	if PersistentVars.WorldLoopEffects[region] == nil then
		PersistentVars.WorldLoopEffects[region] = {}
	end

	table.insert(PersistentVars.WorldLoopEffects[region], {
		Effect = effect,
		Position = target,
		Handle = handle
	})
end

---@private
EffectManager.Callbacks = {
	LoopEffectStarted = {}
}

---@alias EffectManagerLoopEffectStartedCallback fun(effect:string, target:LeaderLibEffectManagerTarget, handle:integer, bone:string|nil):void

EffectManager.Register = {
	---@param callback EffectManagerTagObjectCallback
	LoopEffectStarted = function(callback)
		table.insert(EffectManager.Callbacks.TagObject, callback)
	end
}

---@return EffectManagerStopEffectOptions
local function PrepareOptions(tbl)
	local opts = {
		IsOptionTable = true
	}
	if type(tbl) == "table" then
		if tbl.IsOptionTable then
			return tbl
		end
		for k,v in pairs(tbl) do
			if type(k) == "string" then
				opts[k:lower()] = v
			else
				opts[k] = v
			end
		end
	elseif type(tbl) == "userdata" then
		setmetatable(opts, {
			__index = function(_,k)
				return tbl[k]
			end
		})
	end
	return opts
end

---@param target LeaderLibEffectManagerTarget Either an object or a position.
---@param effect string
---@param bone string|nil If playing an effect on an object, this is an optional bone name to use.
function EffectManager.StartLoopEffect(target, effect, bone)
	local handle = nil

	if type(target) == "table" then
		handle = PlayLoopEffectAtPosition(effect, target[1], target[2], target[3])
		EffectManager.SaveWorldEffectData(target, effect, handle)
	else
		bone = bone or ""
		local uuid = GameHelpers.GetUUID(target)
		handle = PlayLoopEffect(uuid, effect, bone)
		EffectManager.SaveObjectEffectData(uuid, effect, bone, handle)
	end
	InvokeListenerCallbacks(EffectManager.Callbacks.LoopEffectStarted, effect, target, handle, bone)
end

---@param handle integer
function EffectManager.StopLoopEffectByHandle(handle)
	StopLoopEffect(handle)
	for region,dataTable in pairs(PersistentVars.WorldLoopEffects) do
		for i,v in pairs(dataTable) do
			if v.Handle == handle then
				table.remove(dataTable, i)
			end
		end
	end
	for uuid,dataTable in pairs(PersistentVars.ObjectLoopEffects) do
		for i,v in pairs(dataTable) do
			if v.Handle == handle then
				table.remove(dataTable, i)
			end
		end
	end
end

---@class EffectManagerStopEffectOptions:table
---@field target LeaderLibEffectManagerTarget An object or position to filter the search.
---@field all boolean Stops all effects with this name.

---@param effect string|string[]
---@param options EffectManagerStopEffectOptions
function EffectManager.StopLoopEffectByName(effect, options)
	options = PrepareOptions(options)
	if type(effect) == "table" then
		for k,v in pairs(effect) do
			EffectManager.StopLoopEffectByName(v, options)
		end
		return true
	end
	local t = type(options.target)
	if t == "table" then
		for region,dataTable in pairs(PersistentVars.WorldLoopEffects) do
			for i,v in pairs(dataTable) do
				if v.Effect == effect then
					StopLoopEffect(v.Handle)
					table.remove(dataTable, i)
					if not options.all then
						return true
					end
				end
			end
		end
	elseif t == "userdata" or t == "number" or t == "string" then
		local uuid = GameHelpers.GetUUID(options.target)
		if uuid then
			if options.all then
				CharacterStopAllEffectsWithName(uuid, effect)
			end
			local dataTable = PersistentVars.ObjectLoopEffects[uuid]
			if dataTable then
				local length = 0
				for i,v in pairs(dataTable) do
					if v.Effect == effect then
						StopLoopEffect(v.Handle)
						table.remove(dataTable, i)
						if not options.all then
							break
						end
					end
				end
				if #dataTable == 0 then
					PersistentVars.ObjectLoopEffects[uuid] = nil
				end
			end
		else
			fprint(LOGLEVEL.WARNING, "[LeaderLib:EffectManager:StopLoopEffectByName] Failed to get UUID from target parameter:\n%s", Lib.serpent.block(options))
		end
	else
		for region,dataTable in pairs(PersistentVars.WorldLoopEffects) do
			for i,v in pairs(dataTable) do
				if v.Effect == effect then
					StopLoopEffect(v.Handle)
					table.remove(dataTable, i)
					if not options.all then
						break
					end
				end
			end
		end
		for uuid,dataTable in pairs(PersistentVars.ObjectLoopEffects) do
			for i,v in pairs(dataTable) do
				if v.Effect == effect then
					StopLoopEffect(v.Handle)
					table.remove(dataTable, i)
					if not options.all then
						break
					end
				end
			end
			if #dataTable == 0 then
				PersistentVars.ObjectLoopEffects[uuid] = nil
			end
		end
	end
end

function EffectManager.RestoreEffects(region)
	--TODO
end

Ext.RegisterOsirisListener("GameStarted", 2, "after", function(region, isEditorMode)
	EffectManager.RestoreEffects(region)
end)

-- Ext.RegisterOsirisListener("RegionEnded", 1, "after", function(region)
	
-- end)