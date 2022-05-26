local _EXTVERSION = Ext.Version()

if EffectManager == nil then
	EffectManager = {}
end

local _INTERNAL = {}

EffectManager._Internal = _INTERNAL

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

local ObjectHandleEffectParams = {
	BeamTarget = true,
	Target = true
}

---@class EffectManagerEsvEffect:EffectManagerEsvEffectParams
---@field NetID NETID
---@field Delete fun(self:EffectManagerEsvEffect)
---@field Handle ObjectHandle

---@alias LeaderLibEffectManagerTarget UUID|NETID|EsvCharacter|EsvItem|number[]

---@class LeaderLibObjectLoopEffectSaveData
---@field Effect string
---@field Bone string
---@field Handle integer

---@param uuid string
---@param effect string
---@param params EffectManagerEsvEffectParams
function _INTERNAL.SaveObjectEffectData(uuid, effect, params)
	if PersistentVars.ObjectLoopEffects[uuid] == nil then
		PersistentVars.ObjectLoopEffects[uuid] = {}
	end
	local savedParams = nil
	if type(params) == "table" then
		savedParams = {}
		local hasParams = false
		for k,v in pairs(params) do
			local t = type(v)
			if t == "boolean" or t == "number" or t == "string" or t == "table" then
				savedParams[k] = v
				hasParams = true
			elseif ObjectHandleEffectParams[k] then
				local obj = Ext.GetGameObject(v)
				if obj then
					savedParams[k] = obj.MyGuid
					hasParams = true
				end
			end
		end
		if not hasParams then
			savedParams = nil
		end
	end
	table.insert(PersistentVars.ObjectLoopEffects[uuid], {
		Effect = effect,
		Params = savedParams
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
function _INTERNAL.SaveWorldEffectData(target, effect, handle, params)
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
_INTERNAL.Callbacks = {
	LoopEffectStarted = {}
}

---@alias EffectManagerLoopEffectStartedCallback fun(effect:string, target:LeaderLibEffectManagerTarget, handle:integer, bone:string|nil):void

EffectManager.Register = {
	---@param callback EffectManagerLoopEffectStartedCallback
	LoopEffectStarted = function(callback)
		table.insert(_INTERNAL.Callbacks.TagObject, callback)
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

---@class EffectManagerPlayEffectResult
---@field ID string
---@field Handle integer
---@field Effect EffectManagerEsvEffect|string
---@field Position number[]|nil

---@return EffectManagerPlayEffectResult
local function CreateEffectResult(effect, handle, id, pos)
	return {Effect = effect, Handle = handle, ID = id, Position = pos}
end

---@param fx string|string[] The effect resource name
---@param object CharacterParam|ItemParam
---@param params EffectManagerEsvEffectParams|nil
---@return EffectManagerPlayEffectResult|EffectManagerPlayEffectResult[]
function _INTERNAL.PlayEffect(fx, object, params)
	local t = type(fx)
	assert(t == "string" or t == "table", "fx parameter must be a string or a table of strings.")
	---@type EsvCharacter|EsvItem
	local object = GameHelpers.TryGetObject(object)
	assert(type(object) == "userdata", "object parameter must be a UUID, NetID, or EsvCharacter/EsvItem.")
	if t == "string" then
		local handle = nil
		if _EXTVERSION >= 56 then
			---@diagnostic disable undefined-field
			---@type EffectManagerEsvEffect
			local effect = Ext.Effect.CreateEffect(fx, object.Handle, params and params.Bone or "")
			handle = Ext.HandleToDouble(effect.Handle)
			---@diagnostic enable
			if params and type(params) == "table" then
				for k,v in pairs(params) do
					if ObjectHandleEffectParams[k] then
						local obj = GameHelpers.TryGetObject(v)
						if obj then
							effect[k] = obj.Handle
						end
					else
						effect[k] = v
					end
				end
				if params.Loop then
					InvokeListenerCallbacks(_INTERNAL.Callbacks.LoopEffectStarted, effect, object, handle, params.Bone or "")
				end
			end
			return CreateEffectResult(effect, handle, effect.EffectName)
		elseif Ext.OsirisIsCallable() then
			if params then
				if params.BeamTarget ~= nil then
					local beamTarget = GameHelpers.GetUUID(params.BeamTarget)
					handle = PlayLoopBeamEffect(object.MyGuid, beamTarget, fx, params.Bone or "", params.BeamTargetBone or "")
				else
					handle = PlayLoopEffect(object.MyGuid, fx, params.Bone or "")
				end
			else
				handle = PlayLoopEffect(object.MyGuid, fx, "")
			end
			return CreateEffectResult(fx, handle, fx)
		end
	elseif t == "table" then
		local results = {}
		for _,v in pairs(fx) do
			local result = {_INTERNAL.PlayEffect(v, object, params)}
			if result ~= nil then
				results[#results+1] = result
			end
		end
		return results
	end
end

---@param fx string|string[] The effect resource name
---@param pos number[]|EsvGameObject
---@param params EffectManagerEsvEffectParams|nil
---@return EffectManagerPlayEffectResult|EffectManagerPlayEffectResult[]
function _INTERNAL.PlayEffectAt(fx, pos, params)
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
			local handle = nil
			---@diagnostic disable undefined-field
			---@type EffectManagerEsvEffect
			local effect = Ext.Effect.CreateEffect(fx, Ext.Entity.NullHandle(), "")
			if effect then
				effect.Position[1] = x
				effect.Position[2] = y
				effect.Position[3] = z
			end
			---@diagnostic enable
			if params and type(params) == "table" then
				for k,v in pairs(params) do
					if ObjectHandleEffectParams[k] then
						local obj = GameHelpers.TryGetObject(v)
						if obj then
							effect[k] = obj.Handle
						end
					else
						effect[k] = v
					end
				end
				if params.Loop then
					handle = Ext.HandleToDouble(effect.Handle)
				end
			end
			return CreateEffectResult(effect, handle, effect.EffectName, {x,y,z})
		elseif Ext.OsirisIsCallable() then
			local handle = nil
			if params then
				if params.Loop then
					if params.Scale then
						handle = PlayScaledLoopEffectAtPosition(fx, params.Scale, x, y, z)
					else
						handle = PlayLoopEffectAtPosition(fx, x, y, z)
					end
				else
					if params.Scale then
						PlayScaledEffectAtPosition(fx, params.Scale, x, y, z)
					else
						PlayLoopEffectAtPosition(fx, x, y, z)
					end
				end
			else
				PlayEffectAtPosition(fx, x, y, z)
			end
			return CreateEffectResult(fx, handle, fx, {x,y,z})
		end
	elseif t == "table" then
		local results = {}
		for _,v in pairs(fx) do
			local result = EffectManager.PlayEffectAt(v, pos, params)
			if result ~= nil then
				results[#results+1] = result
			end
		end
		return results
	end
end

---@param fx string|string[] The effect resource name
---@param object CharacterParam|ItemParam
---@param params EffectManagerEsvEffectParams|nil
---@return EffectManagerPlayEffectResult|EffectManagerPlayEffectResult[]
function EffectManager.PlayEffect(fx, object, params)
	local uuid = GameHelpers.GetUUID(object)
	local result = _INTERNAL.PlayEffect(fx, object, params)
	if result and params and params.Loop == true then
		if type(result) == "table" then
			for i,v in pairs(result) do
				_INTERNAL.SaveObjectEffectData(uuid, v.ID, params)
			end
		else
			_INTERNAL.SaveObjectEffectData(uuid, result.ID, params)
		end
	end
	return result
end

---Play an effect at a position with optional parameters (looped, scaled).
---Returns the EsvEffect if v56 or higher, otherwise it returns a handle.
---If fx is a table of effects, a table or EsvEffect or table of handles will be returned.
---@param fx string|string[] The effect resource name
---@param pos number[]|EsvGameObject
---@param params EffectManagerEsvEffectParams|nil
---@return EffectManagerPlayEffectResult|EffectManagerPlayEffectResult[]
function EffectManager.PlayEffectAt(fx, pos, params)
	local result = _INTERNAL.PlayEffectAt(fx, pos, params)
	if result and params and params.Loop == true then
		if type(result) == "table" then
			for i,v in pairs(result) do
				_INTERNAL.SaveWorldEffectData(v.Position, v.ID, v.Handle, params)
			end
		else
			_INTERNAL.SaveWorldEffectData(pos, result.ID, result.Handle, params)
		end
	end
	return result
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

	for uuid,dataTable in pairs(PersistentVars.ObjectLoopEffects) do
		if ObjectExists(uuid) == 1 and #dataTable > 0 then
			for i,v in pairs(dataTable) do
				StopLoopEffect(v.Handle)
				v.Handle = PlayLoopEffect(uuid, v.Effect, v.Bone)
				if not v.Handle then
					table.remove(dataTable, i)
				end
			end
			if #dataTable == 0 then
				PersistentVars.ObjectLoopEffects[uuid] = nil
			end
		else
			PersistentVars.ObjectLoopEffects[uuid] = nil
		end
	end
end

function EffectManager.DeleteLoopEffects(region)
	PersistentVars.WorldLoopEffects[region] = nil
	for uuid,dataTable in pairs(PersistentVars.ObjectLoopEffects) do
		if ObjectExists(uuid) == 0 or ObjectIsGlobal(uuid) == 0 then
			PersistentVars.ObjectLoopEffects[uuid] = nil
		end
	end
end

Events.RegionChanged:Subscribe(function (e)
	if e.State == REGIONSTATE.GAME then
		EffectManager.RestoreEffects(e.Region)
	elseif e.State == REGIONSTATE.ENDED then
		EffectManager.DeleteLoopEffects(e.Region)
	end
end)