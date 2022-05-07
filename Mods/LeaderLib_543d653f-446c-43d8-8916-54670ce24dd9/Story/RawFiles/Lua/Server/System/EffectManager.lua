local _EXTVERSION = Ext.Version()

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
---@field Params EffectManagerEsvEffectParams|nil

---@param target number[]
---@param effect string
---@param handle integer
---@param params EffectManagerEsvEffectParams|nil
function EffectManager.SaveWorldEffectData(target, effect, handle, params)
	if type(handle) ~= "number" then
		return
	end
	local region = SharedData.RegionData.Current

	if PersistentVars.WorldLoopEffects[region] == nil then
		PersistentVars.WorldLoopEffects[region] = {}
	end

	local data = {
		Effect = effect,
		Position = target,
		Handle = handle
	}
	if params then
		data.Params = params
	end

	table.insert(PersistentVars.WorldLoopEffects[region], data)
end

---@private
EffectManager.Callbacks = {
	LoopEffectStarted = {}
}

---@alias EffectManagerLoopEffectStartedCallback fun(effect:string, target:LeaderLibEffectManagerTarget, handle:integer, bone:string|nil):void

EffectManager.Register = {
	---@param callback EffectManagerLoopEffectStartedCallback
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
	local worldEffects = PersistentVars.WorldLoopEffects[region]
	if worldEffects then
		for i,v in pairs(worldEffects) do
			StopLoopEffect(v.Handle)
			if v.Params then
				EffectManager.PlayEffectAt(v.Effect, v.Position, v.Params)
			else
				EffectManager.PlayEffectAt(v.Effect, v.Position, {Loop=true})
			end
		end
	end

	--TODO
	-- for uuid,dataTable in pairs(PersistentVars.ObjectLoopEffects) do
	-- 	for i,v in pairs(dataTable) do
	-- 		if v.Effect == effect then
	-- 			StopLoopEffect(v.Handle)
	-- 			table.remove(dataTable, i)
	-- 			if not options.all then
	-- 				break
	-- 			end
	-- 		end
	-- 	end
	-- 	if #dataTable == 0 then
	-- 		PersistentVars.ObjectLoopEffects[uuid] = nil
	-- 	end
	-- end
end

---@class EffectManagerEsvEffectParams
---@field BeamTarget ObjectHandle
---@field BeamTargetBone string
---@field BeamTargetPos number[]
---@field Bone string
---@field DetachBeam boolean
---@field Duration number
---@field EffectName string
---@field ForgetEffect boolean
---@field IsDeleted boolean
---@field IsForgotten boolean
---@field Loop boolean
---@field Position number[]
---@field Rotation number[]
---@field Scale number
---@field Target ObjectHandle

---@class EffectManagerEsvEffect:EffectManagerEsvEffectParams
---@field NetID NETID
---@field Delete fun(self:EffectManagerEsvEffect)

---Play an effect at a position with optional parameters (looped, scaled).
---Returns the EsvEffect if v56 or higher, otherwise it returns a handle.
---If fx is a table of effects, a table or EsvEffect or table of handles will be returned.
---@param fx string|string[] The effect resource name
---@param pos number[]|EsvGameObject
---@param effectParams EffectManagerEsvEffectParams|nil
---@return EffectManagerEsvEffect|EffectManagerEsvEffect[]|integer|integer[]
function EffectManager.PlayEffectAt(fx, pos, effectParams)
	local t = type(fx)
	assert(t == "string" or t == "table", "Effect parameter must be a string or a table of strings.")
	if t == "string" then
		local pt = type(pos)
		local x,y,z = nil,nil,nil
		if pt == "table" then
			x,y,z = table.unpack(pos)
		elseif pt == "userdata" and pos.WorldPos then
			x,y,z = table.unpack(pos.WorldPos)
		end
		assert(x and y and z, "Position table is invalid - {x,y,z} required.")
		if _EXTVERSION >= 56 then
			---@type EffectManagerEsvEffect
			local effect = Ext.Effect.CreateEffect(fx, Ext.Entity.NullHandle(), "")
			if effect then
				effect.Position[1] = x
				effect.Position[2] = y
				effect.Position[3] = z
			end
			if type(effectParams) == "table" then
				for k,v in pairs(effectParams) do
					if effect[k] then
						effect[k] = v
					end
				end
				if effectParams.Loop then
					local handle = Ext.HandleToDouble(effect.Handle)
					EffectManager.SaveWorldEffectData({x,y,z}, fx, handle, effectParams)
				end
			end
			return effect
		elseif Ext.OsirisIsCallable() then
			if effectParams then
				if effectParams.Loop then
					if effectParams.Scale then
						local handle = PlayScaledLoopEffectAtPosition(fx, effectParams.Scale, x, y, z)
						EffectManager.SaveWorldEffectData({x,y,z}, fx, handle)
						return handle
					else
						local handle = PlayLoopEffectAtPosition(fx, x, y, z)
						EffectManager.SaveWorldEffectData({x,y,z}, fx, handle, effectParams)
						return handle
					end
				else
					if effectParams.Scale then
						PlayScaledEffectAtPosition(fx, effectParams.Scale, x, y, z)
						return true
					else
						PlayLoopEffectAtPosition(fx, x, y, z)
						return true
					end
				end
			else
				PlayEffectAtPosition(fx, x, y, z)
			end
		end
	elseif t == "table" then
		local results = {}
		for _,v in pairs(fx) do
			local result = EffectManager.PlayEffectAt(v, pos, effectParams)
			if result ~= nil then
				results[#results+1] = result
			end
		end
		return results
	end
end

---@param region string
---@param state REGIONSTATE
---@param levelType LEVELTYPE
RegisterListener("RegionChanged", function (region, state, levelType)
	if state == REGIONSTATE.GAME then
		EffectManager.RestoreEffects(region)
	elseif state == REGIONSTATE.ENDED then
		EffectManager.DeleteLoopEffects(region)
	end
end)