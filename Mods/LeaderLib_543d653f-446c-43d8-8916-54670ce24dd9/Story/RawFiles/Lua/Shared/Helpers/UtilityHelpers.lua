if GameHelpers.Utils == nil then
	---@class LeaderLibGameHelpersUtilities
	GameHelpers.Utils = {}
end

local _EXTVERSION = Ext.Utils.Version()
local _ISCLIENT = Ext.IsClient()
local _type = type

local _INTERNAL = GameHelpers._INTERNAL

if not _ISCLIENT then
	_INTERNAL.FORCE_MOVE_UPDATE_MS = 250

	---@param handleINT integer
	local function _DestroyMoveAction(handleINT)
		--pcall(NRD_GameActionDestroy, handleINT)
		local handle = Ext.Utils.IntegerToHandle(handleINT)
		if Ext.Utils.IsValidHandle(handle) then
			for _,v in pairs(Ext.ServerEntity.GetCurrentLevel().GameActionManager.GameActions) do
				if v.ActionType == "GameObjectMoveAction" and v.Handle == handle then
					Ext.Action.DestroyGameAction(v)
				end
			end
		end
	end

	---@param e TimerFinishedEventArgs
	function _INTERNAL.OnForceMoveTimer(e)
		local target = e.Data.UUID
		if target ~= nil then
			local targetObject = e.Data.Object
			local targetData = _PV.ForceMoveData[target]
			if targetData ~= nil and targetData.Position then
				if GameHelpers.Math.GetDistance(target, targetData.Position) <= 1 then
					_DestroyMoveAction(targetData.Handle)
					_PV.ForceMoveData[target] = nil
					local source = targetData.Source
					if source then
						source = GameHelpers.TryGetObject(targetData.Source)
					else
						source = targetObject
					end
					local skill = nil
					if not StringHelpers.IsNullOrEmpty(targetData.Skill) then
						skill = Ext.Stats.Get(targetData.Skill, nil, false)
					end
					if targetData.EndAnimation and not StringHelpers.IsNullOrWhitespace(targetData.EndAnimation) then
						Osi.CharacterSetAnimationOverride(targetObject.MyGuid, "")
						targetObject.AnimationOverride = ""
						Osi.PlayAnimation(targetObject.MyGuid, targetData.EndAnimation, "")
					end
					Events.ForceMoveFinished:Invoke({
						ID = targetData.ID or "",
						Target = targetObject,
						Source = source,
						TargetGUID = targetObject.MyGuid,
						SourceGUID = GameHelpers.GetUUID(source),
						Distance = targetData.Distance,
						StartingPosition = targetData.Start,
						Skill = targetData.Skill,
						SkillData = skill
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
					Source = targetObject,
					TargetGUID = targetObject.MyGuid,
					SourceGUID = GameHelpers.GetUUID(targetObject),
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
		if t == "string" and _OSIRIS() then
			if Osi.CharacterIsDead(target) == 1 then
				return false
			end
			if Osi.IsTagged(target, "LeaderLib_Dummy") == 1 or Osi.IsTagged(target, "LeaderLib_ForceImmune") == 1 or Osi.HasActiveStatus(target, "LEADERLIB_FORCE_IMMUNE") == 1 then
				return false
			end
		elseif t == "userdata" and target.HasTag then
			if target.Dead then
				return false
			end
			if target:HasTag("LeaderLib_Dummy") or target:HasTag("LeaderLib_ForceImmune") or Osi.HasActiveStatus(target.MyGuid, "LEADERLIB_FORCE_IMMUNE") == 1 then
				return false
			end
		end
		return true
	end

	---@class ForceMoveObjectToPositionParameters
	---@field ID string An optional string to identify this movement. Used in Events.ForceMoveFinished.
	---@field Source ObjectParam|nil The source object that caused this movement, if any. Defaults to the target if not set.
	---@field Skill string|nil The source skill of the movement, if any.
	---@field BeamEffect string|nil Optional beam effect to play.

	---@class ForceMoveObjectParameters:ForceMoveObjectToPositionParameters
	---@field DistanceMultiplier number|nil The distance to push the target, relative to where the Source or StartPos is.
	---@field StartPos number[]|nil If set, this will be the starting position to push from. Defaults to the source's WorldPosition otherwise.
	---@field IgnoreDistance boolean Disable skipping pushing the target if they're outside the distance multiplier.
	
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
		local dist = GameHelpers.Math.GetOuterDistance(sourceObject, targetObject)
		local distMult = 2
		if opts.DistanceMultiplier then
			distMult = opts.DistanceMultiplier
		end
		local distMultAbs = math.abs(distMult)
		---@type vec3
		local startPos = nil
		if opts.IgnoreDistance then
			startPos = targetObject.WorldPos
		else
			if distMult < 0 then
				startPos = targetObject.WorldPos
			else
				startPos = sourceObject.WorldPos
			end
			if dist > distMultAbs then
				fprint(LOGLEVEL.WARNING, "[GameHelpers.Utils.ForceMoveObject] target(%s) is outside of the push distance range (%s) > (%s) from the starting position. Skipping.", targetObject.DisplayName, dist, distMult)
				return false
			end
		end

		if distMult < 0 and distMultAbs > dist then
			--Limit distance to just infront of the source if pulling would pull the target through them
			distMultAbs = dist - sourceObject.AI.AIBoundsRadius
		end

		if GameHelpers.Math.IsPosition(opts.StartPos) then
			startPos = opts.StartPos
		end

		Timer.Cancel("LeaderLib_OnForceMoveAction", targetObject)
		Timer.Cancel("LeaderLib_CheckKnockupDistance", targetObject)
		local lastData = _PV.ForceMoveData[targetObject.MyGuid]
		if lastData and lastData.Handle then
			Osi.NRD_GameActionDestroy(lastData.Handle)
			Events.ForceMoveFinished:Invoke({
				ID = lastData.ID or "",
				Target = targetObject,
				Source = GameHelpers.TryGetObject(lastData.Source),
				TargetGUID = targetObject.MyGuid,
				SourceGUID = lastData.Source,
				Distance = lastData.Distance,
				StartingPosition = lastData.Start,
				Skill = lastData.Skill,
				SkillData = lastData.Skill and Ext.Stats.Get(lastData.Skill, nil, false) or nil
			})
		end
		
		_PV.ForceMoveData[targetObject.MyGuid] = nil
		--local startPos = GameHelpers.Math.GetForwardPosition(source.MyGuid, distMult)
		local directionalVector = GameHelpers.Math.GetDirectionalVector(targetObject, sourceObject, distMult < 0)
		local targetPos,b = GameHelpers.Grid.GetValidPositionTableAlongLine(startPos, directionalVector, distMultAbs, nil, nil, sourceObject.AI.AIBoundsRadius)

		if not b then
			local tx,ty,tz = table.unpack(GameHelpers.Math.ExtendPositionWithDirectionalVector(startPos, directionalVector, distMult, false))
			ty = ty + (targetObject.AI.AIBoundsHeight * 0.8) -- "Eye"-level?
			local vx, vy, vz = Osi.FindValidPosition(tx, ty, tz, targetObject.AI.AIBoundsRadius * 3, targetObject.MyGuid)
			if vx then
				targetPos = {vx,vy,vz}
				b = true
			end
		end
	
		if b then
			-- local action = Ext.Action.CreateGameAction("GameObjectMoveAction", opts.Skill or "", targetObject)--[[@as EsvGameObjectMoveAction]]
			-- action.CasterCharacterHandle = sourceObject.Handle
			-- action.BeamEffectName = opts.BeamEffect or ""
			-- action.PathMover.DestinationPos = pos
			-- action.PathMover.StartingPosition = targetObject.WorldPos
			local handle = Osi.NRD_CreateGameObjectMove(targetObject.MyGuid, targetPos[1], targetPos[2], targetPos[3], opts.BeamEffect or "", sourceObject.MyGuid)
			if handle then
				_PV.ForceMoveData[targetObject.MyGuid] = {
					ID = opts.ID or "",
					Position = targetPos,
					Start = TableHelpers.Clone(startPos),
					--Handle = Ext.Utils.HandleToInteger(action.Handle),
					Handle = handle,
					Source = sourceObject.MyGuid,
					IsFromSkill = opts.Skill ~= nil,
					Skill = opts.Skill,
					Distance = distMult
				}
				--Ext.Action.ExecuteGameAction(action, pos)
				Timer.StartObjectTimer("LeaderLib_OnForceMoveAction", targetObject.MyGuid, _INTERNAL.FORCE_MOVE_UPDATE_MS)
				return true
			end
		else
			fprint(LOGLEVEL.WARNING, "[GameHelpers.Utils.ForceMoveObject] Failed to find valid position for target (%s). Skipping.", targetObject.DisplayName)
		end

		--No valid position, or the action failed.
		return false
	end
	
	---@param target EsvCharacter|EsvItem
	---@param pos number[]
	---@param opts ForceMoveObjectToPositionParameters|nil
	function GameHelpers.Utils.ForceMoveObjectToPosition(target, pos, opts)
		fassert(_type(pos) == "table" and #pos == 3, "Invalid position parameter (%s)", Lib.serpent.line(pos))
		local targetObject = GameHelpers.TryGetObject(target)
		fassert(targetObject ~= nil, "Invalid target parameter (%s)", Lib.serpent.line(target))
		---@cast targetObject EsvCharacter|EsvItem
		if not opts then
			opts = {}
		end
		local sourceObject = targetObject
		if opts.Source then
			sourceObject = GameHelpers.TryGetObject(opts.Source) or targetObject --[[@as EsvCharacter|EsvItem]]
		end

		Timer.Cancel("LeaderLib_OnForceMoveAction", targetObject)
		Timer.Cancel("LeaderLib_CheckKnockupDistance", targetObject)

		local lastData = _PV.ForceMoveData[targetObject.MyGuid]
		if lastData and lastData.Handle then
			Osi.NRD_GameActionDestroy(lastData.Handle)
			Events.ForceMoveFinished:Invoke({
				ID = lastData.ID or "",
				Target = targetObject,
				Source = GameHelpers.TryGetObject(lastData.Source),
				TargetGUID = targetObject.MyGuid,
				SourceGUID = lastData.Source,
				Distance = lastData.Distance,
				StartingPosition = lastData.Start,
				Skill = lastData.Skill,
				SkillData = lastData.Skill and Ext.Stats.Get(lastData.Skill, nil, false) or nil
			})
		end
		_PV.ForceMoveData[targetObject.MyGuid] = nil

		local dist = GameHelpers.Math.GetDistance(targetObject, pos)
		local x,y,z = table.unpack(targetObject.WorldPos)
		local tx,ty,tz = table.unpack(pos)
		-- local action = Ext.Action.CreateGameAction("GameObjectMoveAction", opts.Skill or "", sourceObject)--[[@as EsvGameObjectMoveAction]]
		-- action.CasterCharacterHandle = sourceObject.Handle
		-- action.BeamEffectName = opts.BeamEffect or ""
		-- action.PathMover.DestinationPos = pos
		-- action.PathMover.StartingPosition = targetObject.WorldPos

		local handle = Osi.NRD_CreateGameObjectMove(targetObject.MyGuid, tx, ty, tz, opts.BeamEffect or "", sourceObject.MyGuid)
		if handle ~= nil then
			_PV.ForceMoveData[targetObject.MyGuid] = {
				ID = opts.ID,
				Position = pos,
				Start = {x,y,z},
				--Handle = Ext.Utils.HandleToInteger(action.Handle),
				Handle = handle,
				Source = sourceObject.MyGuid,
				IsFromSkill = opts.Skill ~= nil,
				Skill = opts.Skill,
				Distance = dist
			}
			--Ext.Action.ExecuteGameAction(action, pos)
			Timer.StartObjectTimer("LeaderLib_OnForceMoveAction", targetObject.MyGuid, 250)
			return true
		end
		return false
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
		local tobj = GameHelpers.TryGetObject(target, "EsvCharacter")
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
					Osi.CharacterPurgeQueue(uuid)
					Osi.CharacterSetAnimationOverride(uuid, opts.ActiveAnimation)
				end
			end, {Once=true, MatchArgs={Event = eventId}})
			Osi.CharacterPurgeQueue(tobj.MyGuid)
			Osi.PlayAnimation(tobj.MyGuid, "knockdown_fall", eventId)
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

	local function _OnTick(e)
		local knockupData = _PV.KnockupData
		if Ext.GetGameState() == "Running" and knockupData and knockupData.Active then
			local len = #knockupData.ObjectData
			local positionSync = {}
			local positionSyncLen = 0
			local grid = Ext.Entity.GetAiGrid()
			for i=1,len do
				local data = knockupData.ObjectData[i]
				local obj = GameHelpers.TryGetObject(data.GUID, "EsvCharacter")
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
							Osi.CharacterSetAnimationOverride(obj.MyGuid, "")
							Osi.CharacterPurgeQueue(obj.MyGuid)
							Osi.PlayAnimation(obj.MyGuid, data.EndAnimation, "")
						end
						GameHelpers.Status.Remove(obj, "LEADERLIB_IN_AIR")
						Events.ForceMoveFinished:Invoke({
							ID = data.ID or "",
							Target = obj,
							Source = GameHelpers.TryGetObject(data.Source),
							TargetGUID = obj.MyGuid,
							SourceGUID = GameHelpers.GetUUID(data.Source),
							Distance = data.Height,
							StartingPosition = data.Start,
							Skill = data.Skill,
							SkillData = data.Skill and Ext.Stats.Get(data.Skill, nil, false) or nil
						})
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

---@param obj ObjectParam
---@param pos vec3
function GameHelpers.Utils.SetPosition(obj, pos)
	assert(GameHelpers.Math.IsPosition(pos), "Param 2 is not a position")
	local object = GameHelpers.TryGetObject(obj)
	if object and object.Translate then
		object.Translate = pos
		if not _ISCLIENT then
			GameHelpers.Net.Broadcast("LeaderLib_GameHelpers_Utils_SetPosition", {NetID=object.NetID,Pos=pos,IsItem=GameHelpers.Ext.ObjectIsItem(object)})
		end
	end
end

---@param obj ObjectParam
---@param rot mat3
function GameHelpers.Utils.SetRotation(obj, rot)
	local object = GameHelpers.TryGetObject(obj)
	if object and object.Rotation then
		object.Rotation = rot
		if not _ISCLIENT then
			GameHelpers.Net.Broadcast("LeaderLib_GameHelpers_Utils_SetRotation", {NetID=object.NetID,Rot=rot,IsItem=GameHelpers.Ext.ObjectIsItem(object)})
		end
	end
end

if _ISCLIENT then
	Ext.RegisterNetListener("LeaderLib_GameHelpers_Utils_SetPosition", function (channel, payload, user)
		local data = Common.JsonParse(payload)
		if data then
			local object = nil
			if data.IsItem then
				object = GameHelpers.GetItem(data.NetID)
			else
				object = GameHelpers.GetCharacter(data.NetID)
			end
			if object then
				GameHelpers.Utils.SetPosition(object, data.Pos)
			end
		end
	end)
	
	Ext.RegisterNetListener("LeaderLib_GameHelpers_Utils_SetRotation", function (channel, payload, user)
		local data = Common.JsonParse(payload)
		if data then
			local object = nil
			if data.IsItem then
				object = GameHelpers.GetItem(data.NetID)
			else
				object = GameHelpers.GetCharacter(data.NetID)
			end
			if object then
				GameHelpers.Utils.SetRotation(object, data.Rot)
			end
		end
	end)
end

---@class GameHelpers_Utils_SetPlayerCameraPositionOptions
---@field CurrentLookAt number[] The current position of the camera. If you set this together with TargetLookAt, the camera will snap to the new position instantly.
---@field TargetLookAt number[] The target position to move the camera to.

---@param player NetId
---@param opts GameHelpers_Utils_SetPlayerCameraPositionOptions
local function _TryUpdateCamera(player, opts)
	local cameraID = nil
	for _,v in pairs(Ext.Entity.GetPlayerManager().ClientPlayerData) do
		if v.CharacterNetId == player then
			cameraID = v.CameraControllerId
			break
		end
	end
	if cameraID then
		---@cast cameraID FixedString
		local camera = Ext.Client.GetCameraManager().Controllers[cameraID]
		if camera then
			---@cast camera EclGameCamera

			if opts.CurrentLookAt then
				camera.CurrentLookAt = opts.CurrentLookAt
			end

			if opts.TargetLookAt then
				camera.TargetLookAt = opts.TargetLookAt
			end

			return true
		end
	end
	return false
end

---@param player CharacterParam
---@param opts GameHelpers_Utils_SetPlayerCameraPositionOptions
function GameHelpers.Utils.SetPlayerCameraPosition(player, opts)
	player = GameHelpers.GetCharacter(player)
	assert(GameHelpers.Character.IsPlayer(player), "player must be a valid player character.")
	assert(_type(opts) == "table", "opts must be a table")
	local currentLookAtValid = _type(opts.CurrentLookAt) == "table"
	local targetLookAtValid = _type(opts.TargetLookAt) == "table"
	assert(currentLookAtValid or targetLookAtValid, "Either CurrentLookAt and/or TargetLookAt must be set.")
	if not _ISCLIENT then
		local payloadData = {NetID=player.NetID, Opts={}}
		if currentLookAtValid then
			payloadData.Opts.CurrentLookAt = opts.CurrentLookAt
		end
		if targetLookAtValid then
			payloadData.Opts.TargetLookAt = opts.TargetLookAt
		end
		GameHelpers.Net.PostToUser(player, "LeaderLib_SetPlayerCameraPosition", payloadData)
	else
		local b,err = xpcall(_TryUpdateCamera, debug.traceback, player.NetID, opts)
		if not b then
			Ext.Utils.PrintError(err)
		end
	end
end

---Set a player's CustomData, and syncs it to the client if on the server-side.
---@param player CharacterParam
---@param opts EocPlayerCustomData
function GameHelpers.Utils.SetPlayerCustomData(player, opts)
	player = GameHelpers.GetCharacter(player)
	if player and player.PlayerCustomData ~= nil then
		for k,v in pairs(opts) do
			player.PlayerCustomData[k] = v
		end
		if not _ISCLIENT then
			GameHelpers.Net.Broadcast("LeaderLib_SetPlayerCustomData", {NetID=player.NetID, Data = opts})
		end
	end
end

---Ensures PlayerCustomData values are set (IsMale, Race, Icon etc).
---Automatically assigns `PlayerCustomData.SkinColor` etc using the character's visual set, then syncs those changes to the client.
---@param player CharacterParam
function GameHelpers.Utils.UpdatePlayerCustomData(player)
	player = GameHelpers.GetCharacter(player)
	if player and player.PlayerCustomData ~= nil then
		local visualSet = GameHelpers.Visual.GetVisualSet(player, true)
		local vs = player.CurrentTemplate.VisualSetIndices
		local skinColorIndex = vs:GetColor(0) + 1
		local hairColorIndex = vs:GetColor(1) + 1
		local clothColorIndex = vs:GetColor(2) + 1
		
		-- local raceData = GameHelpers.Visual.GetRacePreset(player)
		-- player.PlayerCustomData.HairColor = raceData.HairColors[hairColorIndex].Value
		-- player.PlayerCustomData.SkinColor = raceData.SkinColors[skinColorIndex].Value
		-- player.PlayerCustomData.ClothColor1 = raceData.ClothColors[clothColorIndex].Value

		player.PlayerCustomData.SkinColor = visualSet.Colors[1][skinColorIndex]
		player.PlayerCustomData.HairColor = visualSet.Colors[2][hairColorIndex]
		player.PlayerCustomData.ClothColor1 = visualSet.Colors[3][clothColorIndex]
		player.PlayerCustomData.ClothColor2 = player.PlayerCustomData.ClothColor1
		player.PlayerCustomData.ClothColor3 = player.PlayerCustomData.ClothColor1
		player.PlayerCustomData.IsMale = player.PlayerCustomData.IsMale or player:HasTag("MALE")

		local opts = {
			SkinColor = player.PlayerCustomData.SkinColor,
			HairColor = player.PlayerCustomData.HairColor,
			ClothColor1 = player.PlayerCustomData.ClothColor1,
			ClothColor2 = player.PlayerCustomData.ClothColor2,
			ClothColor3 = player.PlayerCustomData.ClothColor3,
			IsMale = player.PlayerCustomData.IsMale
		}

		if player.PlayerCustomData.Icon == "" then
			player.PlayerCustomData.Icon = player.CurrentTemplate.Icon
			opts.Icon = player.CurrentTemplate.Icon
		end

		if not _ISCLIENT then
			GameHelpers.Net.Broadcast("LeaderLib_SetPlayerCustomData", {NetID=player.NetID, Data = opts})
		end
	end
end

---@class LeaderLib_SetPlayerCameraPosition
---@field NetID NetId
---@field Opts GameHelpers_Utils_SetPlayerCameraPositionOptions

---@class LeaderLib_SetPlayerCustomData
---@field NetID NetId
---@field Data EocPlayerCustomData

if _ISCLIENT then
	GameHelpers.Net.Subscribe("LeaderLib_SetPlayerCameraPosition", function (e, data)
		GameHelpers.Utils.SetPlayerCameraPosition(data.NetID, data.Opts)
	end)

	GameHelpers.Net.Subscribe("LeaderLib_SetPlayerCustomData", function (e, data)
		local player = GameHelpers.GetCharacter(data.NetID)
		if player then
			GameHelpers.Utils.SetPlayerCustomData(player, data.Data)
		end
	end)
end