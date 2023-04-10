local _EXTVERSION = Ext.Utils.Version()

if EffectManager == nil then
	EffectManager = {}
end

Managers.FX = EffectManager

local _INTERNAL = {}

EffectManager._Internal = _INTERNAL

---@class EffectManagerEsvEffectParams
---@field BeamTarget ComponentHandle
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
---@field Target ComponentHandle

---@class EffectManagerCreateEffectParams:EffectManagerEsvEffectParams
---@field ID string The ID to associate the effect with. This is purely used for the EffectManager.

local ObjectHandleEffectParams = {
	BeamTarget = true,
	Target = true
}

---@class LeaderLibObjectLoopEffectSaveData
---@field ID string May be the same as Effect, is no ID was set.
---@field Effect string
---@field Handle integer
---@field Params EffectManagerCreateEffectParams

---@param uuid string
---@param id string
---@param effect string
---@param handle integer
---@param params EffectManagerCreateEffectParams
function _INTERNAL.SaveObjectEffectData(uuid, id, effect, handle, params)
	if _PV.ObjectLoopEffects[uuid] == nil then
		_PV.ObjectLoopEffects[uuid] = {}
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
				local obj = GameHelpers.TryGetObject(v)
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
	table.insert(_PV.ObjectLoopEffects[uuid], {
		ID = id,
		Effect = effect,
		Params = savedParams,
		Handle = handle
	})
end

---@class LeaderLibWorldLoopEffectSaveData
---@field Effect string
---@field Position number[]
---@field Handle integer
---@field Params EffectManagerCreateEffectParams|nil

---@param target number[]
---@param effect string
---@param handle integer
---@param params EffectManagerCreateEffectParams|nil
function _INTERNAL.SaveWorldEffectData(target, effect, handle, params)
	local region = SharedData.RegionData.Current

	if _PV.WorldLoopEffects[region] == nil then
		_PV.WorldLoopEffects[region] = {}
	end

	local data = {
		Effect = effect,
		Position = target,
		Handle = handle
	}
	if params then
		data.Params = params
	end

	table.insert(_PV.WorldLoopEffects[region], data)
end

---@private
_INTERNAL.Callbacks = {
	LoopEffectStarted = {}
}

---@alias EffectManagerLoopEffectStartedCallback fun(effect:string, target:ObjectParam|number[], handle:integer, bone:string|nil)

EffectManager.Register = {
	---@param callback EffectManagerLoopEffectStartedCallback
	LoopEffectStarted = function(callback)
		table.insert(_INTERNAL.Callbacks.TagObject, callback)
	end
}

CustomParams = {
	ID = true,
}

---@class EffectManagerPlayEffectResult
---@field ID string
---@field Handle integer
---@field Effect EsvEffect|string
---@field Position number[]|nil

---@param effect EsvEffect|string
---@param handle integer
---@param id string
---@param pos number[]|nil
---@return EffectManagerPlayEffectResult
local function CreateEffectResult(effect, handle, id, pos)
	return {Effect = effect, Handle = handle, ID = id, Position = pos}
end

local function _ValidateParams(params)
	params = type(params) == "table" and params or {}
	--Default to false, otherwise the effect will loop
	if params.Loop == nil then
		params.Loop = false
	end
	return params
end

---@param fx string|string[] The effect resource name
---@param object CharacterParam|ItemParam
---@param params EffectManagerCreateEffectParams|nil
---@return EffectManagerPlayEffectResult|EffectManagerPlayEffectResult[]|nil
function _INTERNAL.PlayEffect(fx, object, params)
	local t = type(fx)
	assert(t == "string" or t == "table", "fx parameter must be a string or a table of strings.")
	local params = _ValidateParams(params)
	local object = GameHelpers.TryGetObject(object)
	---@cast object EsvCharacter|EsvItem

	assert(type(object) == "userdata", "object parameter must be a UUID, NetID, or EsvCharacter/EsvItem.")
	if t == "string" then
		local id = fx
		if params.ID then
			id = params.ID
		end

		local handle = nil
		local b,effect = xpcall(Ext.Effect.CreateEffect, debug.traceback, fx, object.Handle, params.Bone or "")
		if b and effect then
			effect.Loop = false
			--TODO Ext.HandleToDouble is client-side
			--handle = Ext.UI.HandleToDouble(effect.Component.Handle)
			handle = Ext.Utils.HandleToInteger(effect.Component.Handle)
			---@diagnostic enable
			for k,v in pairs(params) do
				if not CustomParams[k] then
					if ObjectHandleEffectParams[k] then
						local obj = GameHelpers.TryGetObject(v)
						if obj then
							effect[k] = obj.Handle
						end
					else
						effect[k] = v
					end
				end
			end
			if params.Loop then
				InvokeListenerCallbacks(_INTERNAL.Callbacks.LoopEffectStarted, effect, object, effect.Component.Handle, params.Bone or "")
			end
			return CreateEffectResult(effect, handle, id)
		else
			if not b then
				Ext.Utils.PrintError(effect)
			end
			fprint(LOGLEVEL.ERROR, "[EffectManager.PlayEffect] Failed to create effect (%s) with params:\n%s", fx, Lib.serpent.block(params))
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
---@param pos number[]|ObjectParam
---@param params EffectManagerCreateEffectParams|nil
---@return EffectManagerPlayEffectResult|EffectManagerPlayEffectResult[]|nil
function _INTERNAL.PlayEffectAt(fx, pos, params)
	local t = type(fx)
	assert(t == "string" or t == "table", "Effect parameter must be a string or a table of strings.")
	local params = _ValidateParams(params)
	if t == "string" then
		local id = fx
		if params.ID then
			id = params.ID
			params.ID = nil
		end

		local pt = type(pos)
		local x,y,z = nil,nil,nil
		if pt == "table" then
			x,y,z = table.unpack(pos)
		elseif pt == "userdata" and pos.WorldPos then
			x,y,z = table.unpack(pos.WorldPos)
		end
		assert(x and y and z, "Position table is invalid - {x,y,z} required.")
		local handle = nil
		local b,effect = xpcall(Ext.Effect.CreateEffect, debug.traceback, fx, Ext.Entity.NullHandle(), "")
		---@diagnostic enable
		if b and effect then
			effect.Position = {x,y,z}
			effect.ForgetEffect = true
			effect.Loop = false

			if params and type(params) == "table" then
				for k,v in pairs(params) do
					if not CustomParams[k] then
						if ObjectHandleEffectParams[k] then
							local obj = GameHelpers.TryGetObject(v)
							if obj then
								effect[k] = obj.Handle
							end
						else
							effect[k] = v
						end
					end
				end
				if params.Loop then
					handle = Ext.Utils.HandleToInteger(effect.Component.Handle)
				end
			end
			return CreateEffectResult(effect, handle, id, {x,y,z})
		else
			if not b then
				Ext.Utils.PrintError(effect)
			end
			fprint(LOGLEVEL.ERROR, "[EffectManager.PlayEffectAt] Failed to create effect (%s) with params:\n%s", fx, Lib.serpent.block(params))
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
---@param params EffectManagerCreateEffectParams|nil
---@param skipSaving boolean|nil Skip saving if the params.Loop is true.
---@return EffectManagerPlayEffectResult|EffectManagerPlayEffectResult[]|nil
function EffectManager.PlayEffect(fx, object, params, skipSaving)
	local uuid = GameHelpers.GetUUID(object)
	local result = _INTERNAL.PlayEffect(fx, object, params)
	if result and params and params.Loop == true and not skipSaving then
		if type(result) == "table" and #result > 0 then
			for i,v in pairs(result) do
				_INTERNAL.SaveObjectEffectData(uuid, v.ID, fx, v.Handle, params)
			end
		else
			_INTERNAL.SaveObjectEffectData(uuid, result.ID, fx, result.Handle, params)
		end
	end
	return result
end

---Play an effect at a position with optional parameters (looped, scaled).
---Returns the EsvEffect if v56 or higher, otherwise it returns a handle.
---If fx is a table of effects, a table or EsvEffect or table of handles will be returned.
---@param fx string|string[] The effect resource name
---@param pos number[]|ObjectParam
---@param params EffectManagerCreateEffectParams|nil
---@param skipSaving boolean|nil
---@return EffectManagerPlayEffectResult|EffectManagerPlayEffectResult[]
function EffectManager.PlayEffectAt(fx, pos, params, skipSaving)
	local result = _INTERNAL.PlayEffectAt(fx, pos, params)
	if result and params and params.Loop == true and not skipSaving then
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

---Play a client-side effect, which has support for weapon bones, and parsing an effect string like in skills/statuses.
---@param fx string|string[] The effect string or name.
---@param target ObjectParam|number[]
---@param params EffectManagerCreateEffectParams|nil
---@param client CharacterParam|integer|nil A specific client to play the effect for. Leave nil to broadcast it to all clients.
---@return EffectManagerPlayEffectResult|EffectManagerPlayEffectResult[]
function EffectManager.PlayClientEffect(fx, target, params, client)
	if params then
		params = TableHelpers.SanitizeTable(params, nil, true)
	end
	if not client then
		GameHelpers.Net.Broadcast("LeaderLib_EffectManager_PlayClientEffect", {Target = GameHelpers.GetNetID(target), FX = fx, Params = params})
	else
		GameHelpers.Net.PostToUser(client, "LeaderLib_EffectManager_PlayClientEffect", {Target = GameHelpers.GetNetID(target), FX = fx, Params = params})
	end
end

---@param handle integer|ComponentHandle
function _INTERNAL.StopEffect(handle)
	local t = type(handle)
	if t == "number" then
		local fxHandle = Ext.Utils.IntegerToHandle(handle)
		if fxHandle and Ext.Utils.IsValidHandle(fxHandle) then
			local effect = Ext.Effect.GetEffect(fxHandle)
			if effect then
				effect:Delete()
				return true
			end
		end
	end
	if t == "userdata" then
		local effect = Ext.Effect.GetEffect(handle)
		if effect then
			effect:Delete()
			return true
		end
	end
	return false
end

---@param handle integer
function EffectManager.StopLoopEffectByHandle(handle)
	_INTERNAL.StopEffect(handle)
	local nextWorldLoopEffects = {}
	local changed = false
	for region,dataTable in pairs(_PV.WorldLoopEffects) do
		nextWorldLoopEffects[region] = {}
		for i=1,#dataTable do
			local v = dataTable[i]
			if v.Handle ~= handle then
				nextWorldLoopEffects[region][#nextWorldLoopEffects[region]+1] = v
			else
				changed = true
			end
		end
	end
	if changed then
		_PV.WorldLoopEffects = nextWorldLoopEffects
	end

	local nextObjectLoopEffects = {}
	changed = false
	for uuid,dataTable in pairs(_PV.ObjectLoopEffects) do
		nextObjectLoopEffects[uuid] = {}
		for i=1,#dataTable do
			local v = dataTable[i]
			if v.Handle ~= handle then
				nextObjectLoopEffects[uuid][#nextObjectLoopEffects[uuid]+1] = v
			else
				changed = true
			end
		end
	end
	if changed then
		_PV.ObjectLoopEffects = nextObjectLoopEffects
	end
end

local function _TargetsMatch(effect, uuid, uuidType)
	if effect.Target ~= nil then
		local obj = GameHelpers.TryGetObject(effect.Target)
		if obj then
			if uuidType == "string" then
				return uuid == obj.MyGuid
			elseif uuidType == "table" then
				for _,v in pairs(uuid) do
					if obj.MyGuid == v then
						return true
					end
				end
			end
		end
	end
	return false
end

---@param fx string|string[]|nil Optional effect ID to filter effects for.
---@param target Guid|number[]|NetId|EsvCharacter|EsvItem Optional target to filter effects for.
---@param distanceThreshold number|nil The maximum distance between an effect position and a target position before it's considered a match. Defaults to 0.1
---@return EsvEffect[]
function EffectManager.GetAllEffects(fx, target, distanceThreshold)
	local effects = {}
	distanceThreshold = distanceThreshold or 0.1

	---@type fun(effect:EsvEffect):boolean
	local targetsMatch = nil
	local t = type(target)
	if t == "table" then
		local firstParamType = type(target[1])
		--Position
		if firstParamType == "number" then
			targetsMatch = function (effect)
				return GameHelpers.Math.GetDistance(effect.Position, target) <= distanceThreshold
			end
		elseif firstParamType == "string" then --Table of UUIDs?
			targetsMatch = function (effect)
				return _TargetsMatch(effect, target, "table")
			end
		elseif firstParamType == "userdata" then --Table of EsvCharacter\EsvItem?
			targetsMatch = function (effect)
				for _,v in pairs(target) do
					if _TargetsMatch(effect, GameHelpers.GetUUID(target), "string") then
						return true
					end
				end
				return false
			end
		end
	elseif t == "number" or t == "string" or t == "userdata" then
		local uuid = GameHelpers.GetUUID(target)
		targetsMatch = function (effect)
			return _TargetsMatch(effect, uuid, "string")
		end
	end
	for _,handle in pairs(Ext.Effect.GetAllEffectHandles()) do
		local effect = Ext.Effect.GetEffect(handle)
		if effect then
			if not fx or effect.EffectName == fx then
				if not targetsMatch or targetsMatch(effect) then
					effects[#effects+1] = effect
				end
			end
		end
	end
	return effects
end

---Get the first effect for a given ID.
---@param id string
---@param object ObjectParam
---@return EsvEffect
function EffectManager.GetEffectByIDForObject(id, object)
	local uuid = GameHelpers.GetUUID(object)
	fassert(uuid ~= nil, "Failed to get UUID for object parameter %s", object)
	local dataTable = _PV.ObjectLoopEffects[uuid]
	local handleInt = nil
	if dataTable then
		for i,v in pairs(dataTable) do
			if v.ID == id then
				handleInt = v.Handle
			end
		end
	end

	if handleInt then
		for _,handle in pairs(Ext.Effect.GetAllEffectHandles()) do
			if Ext.Utils.HandleToInteger(handle) == handleInt then
				local effect = Ext.Effect.GetEffect(handle)
				if effect then
					return effect
				end
			end
		end
	end
end

---@param effect string|string[]
---@param target ObjectParam
function EffectManager.StopEffectsByNameForObject(effect, target)
	local success = false
	if type(effect) == "table" then
		for _,v in pairs(effect) do
			if EffectManager.StopEffectsByNameForObject(v, target) then
				success = true
			end
		end
		return success
	else
		local uuid = GameHelpers.GetUUID(target)
		fassert(uuid ~= nil, "Failed to get UUID for target parameter %s", target)
		if _OSIRIS() then
			if uuid then
				Osi.CharacterStopAllEffectsWithName(uuid, effect)
				success = true
			end
		else
			for _,fx in pairs(EffectManager.GetAllEffects(effect, target)) do
				fx:Delete()
				success = true
			end
		end

		local dataTable = _PV.ObjectLoopEffects[uuid]
		if dataTable then
			for i,v in pairs(dataTable) do
				if v.Effect == effect then
					table.remove(dataTable, i)
				end
			end
			if #dataTable == 0 then
				_PV.ObjectLoopEffects[uuid] = nil
			end
		end
	end
	return success
end

---@param id string|string[]
---@param target ObjectParam
function EffectManager.StopEffectsByIDForObject(id, target)
	local success = false
	if type(id) == "table" then
		for _,v in pairs(id) do
			if EffectManager.StopEffectsByIDForObject(v, target) then
				success = true
			end
		end
		return success
	else
		local uuid = GameHelpers.GetUUID(target)
		fassert(uuid ~= nil, "Failed to get UUID for target parameter %s", target)
		local dataTable = _PV.ObjectLoopEffects[uuid]
		if dataTable then
			local len = #dataTable
			local nextTotal = len
			for i=1,len do
				local v = dataTable[i]
				if v and v.ID == id then
					for _,fx in pairs(EffectManager.GetAllEffects(v.Effect, uuid)) do
						fx:Delete()
						success = true
					end
					table.remove(dataTable, i)
					nextTotal = nextTotal - 1
				end
			end
			if nextTotal <= 0 then
				_PV.ObjectLoopEffects[uuid] = nil
			end
		end
	end
	return success
end

---@param effect string|string[]
---@param target number[]
---@param distanceThreshold number|nil The maximum distance between an effect position and a target position before it should be deleted. Defaults to 0.1
function EffectManager.StopEffectsByNameForPosition(effect, target, distanceThreshold)
	local success = false
	distanceThreshold = type(distanceThreshold) == "number" and distanceThreshold or 0.1
	if type(effect) == "table" then
		for _,v in pairs(effect) do
			if EffectManager.StopEffectsByNameForPosition(v, target) then
				success = true
			end
		end
		return success
	else
		for _,effect in pairs(EffectManager.GetAllEffects(effect, target, distanceThreshold)) do
			effect:Delete()
			success = true
		end

		for region,dataTable in pairs(_PV.WorldLoopEffects) do
			for i,v in pairs(dataTable) do
				if v.Effect == effect then
					if GameHelpers.Math.GetDistance(v.Position, target) <= distanceThreshold then
						_INTERNAL.StopEffect(v.Handle)
						table.remove(dataTable, i)
					end
				end
			end
			if #dataTable == 0 then
				_PV.WorldLoopEffects[region] = nil
			end
		end
	end
	return success
end


---@param target ObjectParam
function EffectManager.DeleteEffectsForObject(target)
	local success = false
	local uuid = GameHelpers.GetUUID(target)
	fassert(uuid ~= nil, "Failed to get UUID for target parameter %s", target)
	local dataTable = _PV.ObjectLoopEffects[uuid]
	if dataTable then
		local len = #dataTable
		for i=1,len do
			local v = dataTable[i]
			if v and v.Effect then
				for _,fx in pairs(EffectManager.GetAllEffects(v.Effect, uuid)) do
					fx:Delete()
				end
			end
		end
		_PV.ObjectLoopEffects[uuid] = nil
		success = true
	end
	return success
end

local function InvalidateLoopEffects(region)
	local worldEffects = _PV.WorldLoopEffects[region]
	if worldEffects then
		for i,v in pairs(worldEffects) do
			v.Handle = nil
		end
	end
end

function EffectManager.RestoreEffects(region)
	local worldEffects = _PV.WorldLoopEffects[region]
	if worldEffects then
		for i,v in pairs(worldEffects) do
			if v.Handle and v.Handle ~= -1 then
				Osi.StopLoopEffect(v.Handle)
			end
			if v.Params then
				EffectManager.PlayEffectAt(v.Effect, v.Position, v.Params)
			else
				EffectManager.PlayEffectAt(v.Effect, v.Position, {Loop=true})
			end
		end
	end

	for uuid,dataTable in pairs(_PV.ObjectLoopEffects) do
		if Osi.ObjectExists(uuid) == 1 and #dataTable > 0 then
			local restoredEffects = {}
			for i,v in pairs(dataTable) do
				if not StringHelpers.IsNullOrEmpty(v.Effect) then
					local params = v.Params or {}
					if v.Handle then
						Osi.StopLoopEffect(v.Handle)
					end
					v.Handle = Osi.PlayLoopEffect(uuid, v.Effect, params.Bone or "")
					if v.Handle then
						restoredEffects[#restoredEffects+1] = {Handle=v.Handle, ID=v.ID, Effect=v.Effect, Params = params}
					end
				end
			end
			if #restoredEffects == 0 then
				_PV.ObjectLoopEffects[uuid] = nil
			else
				_PV.ObjectLoopEffects[uuid] = restoredEffects
			end
		else
			_PV.ObjectLoopEffects[uuid] = nil
		end
	end
end

function EffectManager.DeleteLoopEffects(region)
	_PV.WorldLoopEffects[region] = nil
	for uuid,dataTable in pairs(_PV.ObjectLoopEffects) do
		if Osi.ObjectExists(uuid) == 0 or Osi.ObjectIsGlobal(uuid) == 0 then
			_PV.ObjectLoopEffects[uuid] = nil
		end
	end
end

Events.RegionChanged:Subscribe(function (e)
	if e.State == REGIONSTATE.STARTED then
		if Vars.PersistentVarsLoaded then
			InvalidateLoopEffects(e.Region)
		end
	elseif e.State == REGIONSTATE.GAME then
		if Vars.PersistentVarsLoaded then
			EffectManager.RestoreEffects(e.Region)
		else
			Events.PersistentVarsLoaded:Subscribe(function (e)
				EffectManager.RestoreEffects(SharedData.RegionData.Current)
			end, {MatchArgs={ID=ModuleUUID}, Once=true})
		end
	elseif e.State == REGIONSTATE.ENDED then
		EffectManager.DeleteLoopEffects(e.Region)
	end
end)