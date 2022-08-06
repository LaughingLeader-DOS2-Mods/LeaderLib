if GameHelpers.Utils == nil then
	---@class LeaderLibGameHelpersUtilities
	GameHelpers.Utils = {}
end

local _EXTVERSION = Ext.Version()
local _ISCLIENT = Ext.IsClient()
local _type = type

local _INTERNAL = GameHelpers._INTERNAL

if not _ISCLIENT then
	_INTERNAL.FORCE_MOVE_UPDATE_MS = 250

	---@param e TimerFinishedEventArgs
	function _INTERNAL.OnForceMoveTimer(e)
		local target = e.Data.UUID
		if target ~= nil then
			local targetObject = e.Data.Object
			local targetData = _PV.ForceMoveData[target]
			if targetData ~= nil and targetData.Position then
				Ext.Print("ForceMoveData", Ext.DumpExport(targetData))
				print(GameHelpers.Math.GetDistance(target, targetData.Position))
				if GameHelpers.Math.GetDistance(target, targetData.Position) <= 1 then
					pcall(NRD_GameActionDestroy,targetData.Handle)
					_PV.ForceMoveData[target] = nil
					local source = targetData.Source
					if source then
						source = Ext.GetGameObject(targetData.Source)
					else
						source = targetObject
					end
					local skill = nil
					if targetData.Skill then
						skill = Ext.Stats.Get(targetData.Skill)
					end
					if targetData.EndAnimation and not StringHelpers.IsNullOrWhitespace(targetData.EndAnimation) then
						CharacterSetAnimationOverride(targetObject.MyGuid, "")
						targetObject.AnimationOverride = ""
						print("PlayAnimation", targetObject.MyGuid, targetData.EndAnimation)
						PlayAnimation(targetObject.MyGuid, targetData.EndAnimation, "")
					end
					Events.ForceMoveFinished:Invoke({
						ID = targetData.ID or "",
						Target = targetObject,
						Source = source,
						Distance = targetData.Distance,
						StartingPosition = targetData.Start,
						Skill = skill
					})
					if skill then
						Osi.LeaderLib_Force_OnLanded(GameHelpers.GetUUID(target,true), GameHelpers.GetUUID(targetData.Source, true), targetData.Skill or "Skill")
					else
						--LeaderLib_Force_OnLanded((GUIDSTRING)_Target, (GUIDSTRING)_Source, (STRING)_Event)
						Osi.LeaderLib_Force_OnLanded(GameHelpers.GetUUID(target,true), GameHelpers.GetUUID(targetData.Source, true), "Lua")
					end
				else
					Timer.StartObjectTimer(e.ID, target, _INTERNAL.FORCE_MOVE_UPDATE_MS)
				end
			elseif targetObject then
				fprint(LOGLEVEL.WARNING, "[LeaderLib_OnForceMoveAction] No force move data for target (%s). How did this happen?", targetObject.DisplayName)
				Events.ForceMoveFinished:Invoke({
					ID = "",
					Target = targetObject,
					Distance = 0,
					StartingPosition = targetObject.WorldPos
				})
			end
		end
	end

	Timer.Subscribe("LeaderLib_OnForceMoveAction", function(e) _INTERNAL.OnForceMoveTimer(e) end)

	---Checks if an object can be force moved with GameHelpers.ForceMoveObject.  
	---Looks for specific tags and statuses, such as the LeaderLib_ForceImmune tag and the LEADERLIB_FORCE_IMMUNE status.
	---@param target ObjectParam
	---@return boolean canBeForceMoved
	function GameHelpers.CanForceMove(target)
		local t = _type(target)
		if t == "string" and Ext.OsirisIsCallable() then
			if CharacterIsDead(target) == 1 then
				return false
			end
			if IsTagged(target, "LeaderLib_Dummy") == 1 or IsTagged(target, "LeaderLib_ForceImmune") == 1 or HasActiveStatus(target, "LEADERLIB_FORCE_IMMUNE") == 1 then
				return false
			end
		elseif t == "userdata" and target.HasTag then
			if target.Dead then
				return false
			end
			if target:HasTag("LeaderLib_Dummy") or target:HasTag("LeaderLib_ForceImmune") or HasActiveStatus(target.MyGuid, "LEADERLIB_FORCE_IMMUNE") == 1 then
				return false
			end
		end
		return true
	end

	---@class ForceMoveObjectToPositionParameters
	---@field ID string An optional string to identify this movement. Used in Events.ForceMoveFinished.
	---@field Source ObjectParam|nil The source object that caused this movement, if any. Defaults to the target if not set.
	---@field Skill string|nil The source skill of the movement, if any.
	---@field BeamEffect string|nil Optional beam effect to play with the NRD_CreateGameObjectMove action.

	---@class ForceMoveObjectParameters:ForceMoveObjectToPositionParameters
	---@field DistanceMultiplier number|nil The distance to push the target, relative to where the Source or StartPos is.
	---@field StartPos number[]|nil If set, this will be the starting position to push from. Defaults to the source's WorldPosition otherwise.
	
	---Push or pull a target from a source object or position.  
	---Similar to the Force action, except it's grid-safe (no pushing objects out of the map).
	---@param target EsvCharacter|EsvItem
	---@param opts ForceMoveObjectParameters|nil
	---@return boolean success Returns true if the force move action has started.
	function GameHelpers.Utils.ForceMoveObject(target, opts)
		local targetObject = GameHelpers.TryGetObject(target)
		fassert(targetObject ~= nil, "Invalid target parameter (%s)", target)
		if not opts then
			opts = {}
		end
		local sourceObject = targetObject
		if opts.Source then
			sourceObject = GameHelpers.TryGetObject(opts.Source) or targetObject
		end
		local startPos = sourceObject.WorldPos
		if _type(opts.StartPos) == "table" then
			startPos = opts.StartPos
		end
		local dist = GameHelpers.Math.GetDistance(targetObject, startPos)
		local distMult = 2
		if opts.DistanceMultiplier then
			distMult = opts.DistanceMultiplier
		end
		if dist > math.abs(distMult) then
			fprint(LOGLEVEL.WARNING, "[GameHelpers.ForceMoveObject] target(%s) is outside of the push distance range (%s) > (%s) from the starting position. Skipping.", targetObject.DisplayName, dist, distMult)
			return false
		end
		Timer.Cancel("LeaderLib_OnForceMoveAction", targetObject)
		Timer.Cancel("LeaderLib_CheckKnockupDistance", targetObject)
		_PV.ForceMoveData[targetObject.MyGuid] = nil
		--local startPos = GameHelpers.Math.GetForwardPosition(source.MyGuid, distMult)
		local directionalVector = GameHelpers.Math.GetDirectionalVectorBetweenObjects(targetObject, sourceObject, distMult < 0)
		local tx,ty,tz = GameHelpers.Grid.GetValidPositionAlongLine(startPos, directionalVector, distMult)
	
		if tx and tz then
			local handle = NRD_CreateGameObjectMove(targetObject.MyGuid, tx, ty, tz, opts.BeamEffect or "", sourceObject.MyGuid)
			if handle then
				_PV.ForceMoveData[targetObject.MyGuid] = {
					ID = opts.ID or "",
					Position = {tx,ty,tz},
					Start = TableHelpers.Clone(startPos),
					Handle = handle,
					Source = sourceObject.MyGuid,
					IsFromSkill = opts.Skill ~= nil,
					Skill = opts.Skill,
					Distance = distMult
				}
				Timer.StartObjectTimer("LeaderLib_OnForceMoveAction", targetObject.MyGuid, _INTERNAL.FORCE_MOVE_UPDATE_MS)
				return true
			end
		end

		--No valid position, or the action failed.
		return false
	end
	
	---@param target EsvCharacter|EsvItem
	---@param position number[]
	---@param opts ForceMoveObjectToPositionParameters|nil
	---@return number,number|nil
	function GameHelpers.Utils.ForceMoveObjectToPosition(target, position, opts)
		fassert(_type(position) == "table" and position[1] and position[2] and position[3], "Invalid position parameter (%s)", Lib.serpent.line(position))
		local targetObject = GameHelpers.TryGetObject(target)
		fassert(targetObject ~= nil, "Invalid target parameter (%s)", Lib.serpent.line(target))
		if not opts then
			opts = {}
		end
		local sourceObject = targetObject
		if opts.Source then
			sourceObject = GameHelpers.TryGetObject(opts.Source) or targetObject
		end

		Timer.Cancel("LeaderLib_OnForceMoveAction", targetObject)
		Timer.Cancel("LeaderLib_CheckKnockupDistance", targetObject)
		_PV.ForceMoveData[targetObject.MyGuid] = nil

		local dist = GameHelpers.Math.GetDistance(targetObject, position)
		local x,y,z = table.unpack(targetObject.WorldPos)
		local tx,ty,tz = table.unpack(position)
		local handle = NRD_CreateGameObjectMove(targetObject.MyGuid, tx, ty, tz, opts.BeamEffect or "", sourceObject.MyGuid)
		if handle ~= nil then
			_PV.ForceMoveData[targetObject.MyGuid] = {
				Position = {tx,ty,tz},
				Start = {x,y,z},
				Handle = handle,
				Source = sourceObject.MyGuid,
				IsFromSkill = opts.Skill ~= nil,
				Skill = opts.Skill,
				Distance = dist
			}
			Timer.StartObjectTimer("LeaderLib_OnForceMoveAction", targetObject.MyGuid, 250)
		end
	end

	---@class KnockUpObjectObjectParameters
	---@field ID string An optional string to identify this movement. Used in Events.ForceMoveFinished.
	---@field Source ObjectParam|nil The source object that caused this movement, if any. Defaults to the target if not set.
	---@field Skill string|nil The source skill of the movement, if any.
	---@field BeamEffect string|nil Optional beam effect to play with the NRD_CreateGameObjectMove action.
	---@field StartAnimation string|nil The animation to play when the movement starts. Defaults to "knockdown_fall". Set to "" to disable.
	---@field ActiveAnimation string|nil The animation to play when the movement is happening, after StartAnimation. Defaults to "knockdown_loop". Set to "" to disable.
	---@field EndAnimation string|nil The animation to play when the movement ends. Defaults to "knockdown_getup". Set to "" to disable.
	---@field Gravity number|nil Overrides the default gravity amount of 12.

	local function HasKnockupData(uuid)
		uuid = GameHelpers.GetUUID(uuid)
		if not uuid then
			return false
		end
		for i,v in pairs(_PV.KnockupData.ObjectData) do
			if v.GUID == uuid then
				return true
			end
		end
	end

	local _GRAVITY = 12
	local _FALLMULT = 1.6

	---@param target ObjectParam
	---@param height number
	---@param opts KnockUpObjectObjectParameters|nil
	function GameHelpers.Utils.KnockUpObject(target, height, opts)
		if _EXTVERSION < 56 then
			return
		end
		fassert(_type(height) == "number", "Invalid height parameter (%s)", Lib.serpent.line(height))
		local tobj = GameHelpers.TryGetObject(target)
		fassert(tobj ~= nil, "Invalid target parameter (%s)", Lib.serpent.line(target))
		if not opts then
			opts = {}
		end
		local sobj = tobj
		if opts.Source then
			sobj = GameHelpers.TryGetObject(opts.Source) or tobj
		end

		Timer.Cancel("LeaderLib_OnForceMoveAction", tobj)
		Timer.Cancel("LeaderLib_CheckKnockupDistance", tobj)
		_PV.ForceMoveData[tobj.MyGuid] = nil

		for i,v in pairs(_PV.KnockupData.ObjectData) do
			if v.GUID == tobj.MyGuid then
				table.remove(_PV.KnockupData.ObjectData, i)
			end
		end

		local tx,ty,tz = table.unpack(tobj.WorldPos)
		local startPos = {tx,ty,tz}
		ty = ty + height
		if opts.StartAnimation == nil then
			opts.StartAnimation = "knockdown_fall"
		end
		if opts.ActiveAnimation == nil then
			opts.ActiveAnimation = "knockdown_loop"
		end
		if opts.EndAnimation == nil then
			opts.EndAnimation = "knockdown_getup"
		end
		if not StringHelpers.IsNullOrWhitespace(opts.StartAnimation) then
			local eventId = string.format("LeaderLib_OnForceMoveAction_PlayActiveAnimation_%s", tobj.MyGuid)
			Events.ObjectEvent:Subscribe(function (e)
				local uuid = GameHelpers.GetUUID(e.Objects[1])
				if uuid and HasKnockupData(uuid) then
					CharacterPurgeQueue(uuid)
					CharacterSetAnimationOverride(uuid, opts.ActiveAnimation)
				end
			end, {Once=true, MatchArgs={Event = eventId}})
			CharacterPurgeQueue(tobj.MyGuid)
			PlayAnimation(tobj.MyGuid, "knockdown_fall", eventId)
		end
		GameHelpers.Status.Apply(tobj, "LEADERLIB_IN_AIR", 30.0, true, sobj)
		_PV.KnockupData.ObjectData[#_PV.KnockupData.ObjectData+1] = {
			ID = opts.ID or "",
			GUID = tobj.MyGuid,
			Falling = false,
			Start = startPos,
			End = {tx,ty,tz},
			Height = height,
			Source = sobj.MyGuid,
			Skill = opts.Skill,
			EndAnimation = opts.EndAnimation,
			Gravity = opts.Gravity or _GRAVITY,
		}
		_PV.KnockupData.Active = true
	end

	if _EXTVERSION >= 56 then
		local function _OnTick(e)
			local knockupData = _PV.KnockupData
			if Ext.GetGameState() == "Running" and knockupData and knockupData.Active then
				local len = #knockupData.ObjectData
				local positionSync = {}
				local positionSyncLen = 0
				local grid = Ext.GetAiGrid()
				for i=1,len do
					local data = knockupData.ObjectData[i]
					---@type EsvCharacter|EsvItem
					local obj = Ext.GetGameObject(data.GUID)
					if not obj then
						table.remove(knockupData.ObjectData, i)
					end
					local gravity = data.Gravity or _GRAVITY
					local x,y,z = table.unpack(obj.Translate)
					local currentY = y
					if data.Falling then
						local floorY = GameHelpers.Grid.GetY(x, z, grid)
						if y > data.Start[2] then
							y = y - ((_FALLMULT * gravity) * e.Time.DeltaTime)
							if y < floorY then
								y = floorY
							end
							if y ~= currentY then
								positionSync[positionSyncLen+1] = {NetID = obj.NetID, Y = y}
								positionSyncLen = positionSyncLen + 1
							end
							obj.Translate = {x,y,z}
						else
							table.remove(knockupData.ObjectData, i)
							obj.Translate = {x,floorY,z}
							positionSync[positionSyncLen+1] = {NetID = obj.NetID, Y = floorY}
							positionSyncLen = positionSyncLen + 1
							if data.EndAnimation then
								CharacterSetAnimationOverride(obj.MyGuid, "")
								CharacterPurgeQueue(obj.MyGuid)
								PlayAnimation(obj.MyGuid, data.EndAnimation, "")
							end
							GameHelpers.Status.Remove(obj, "LEADERLIB_IN_AIR")
						end
					else
						local dist = math.abs(data.End[2]) - math.abs(y)
						if dist > 0 then
							local apexMult = math.max(0.2, dist/data.Height)
							y = y + ((gravity * apexMult) * e.Time.DeltaTime)
							if y ~= currentY then
								positionSync[positionSyncLen+1] = {NetID = obj.NetID, Y = y}
								positionSyncLen = positionSyncLen + 1
							end
							obj.Translate = {x,y,z}
						else
							data.Falling = true
						end
					end
				end
				if #knockupData.ObjectData == 0 then
					knockupData.Active = false
				end
				if positionSyncLen > 0 then
					GameHelpers.Net.Broadcast("LeaderLib_KnockUp_SyncPositions", positionSync)
				end
			end
		end
		local _registeredTickListener = false
		Events.PersistentVarsLoaded:Subscribe(function ()
			if not _registeredTickListener then
				_registeredTickListener = true
				Ext.Events.Tick:Subscribe(_OnTick)
			end
		end)
	end
else
	Ext.RegisterNetListener("LeaderLib_KnockUp_SyncPositions", function (cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			for i=1,#data do
				local entry = data[i]
				local obj = GameHelpers.TryGetObject(entry.NetID)
				if obj then
					local pos = obj.Translate
					pos[2] = entry.Y
					obj.Translate = pos
				end
			end
		end
	end)
end