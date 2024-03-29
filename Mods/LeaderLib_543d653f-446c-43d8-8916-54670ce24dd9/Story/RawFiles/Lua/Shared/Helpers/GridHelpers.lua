if GameHelpers.Grid == nil then
	GameHelpers.Grid = {}
end

local _ISCLIENT = Ext.IsClient()
local _type = type

local _getGrid = Ext.Entity.GetAiGrid
local _getCurrentLevel = Ext.Entity.GetCurrentLevel
local _getDistance = Ext.Math.Distance

---@class GameHelpers_Grid_Bounds
---@field Radius number

---@param x number
---@param z number
---@param grid? EocAiGrid
---@return boolean
function GameHelpers.Grid.IsValidPosition(x, z, grid)
	---@type EocAiGrid
	grid = grid or _getGrid()
	if grid then
		--print("GameHelpers.Grid.IsValidPosition",x,z,grid:GetAiFlags(x, z), grid:GetAiFlags(x, z)&1==1)
		local flag = grid:GetAiFlags(x, z)
		if flag ~= nil then
			return flag & 1 ~= 1
		end
	end
	return false
end

---@param startPos vec3|ObjectParam
---@param directionVector vec3
---@param maxDistance? number
---@param reverse? boolean Start from the smallest distance possible instead.
---@param distIncrement? number The number to progressively add when finding valid positions.
---@param minDistance? number When in reverse, start from this distance instead of 0.
---@return vec3 position
---@return boolean success
function GameHelpers.Grid.GetValidPositionTableAlongLine(startPos, directionVector, maxDistance, reverse, distIncrement, minDistance)
	startPos = GameHelpers.Math.GetPosition(startPos)
	distIncrement = distIncrement or 0.1
	maxDistance = maxDistance or 12.0
	minDistance = minDistance or 0
	local grid = _getGrid()
	if grid and maxDistance > 0 then
		local currentTravelDist = reverse ~= true and maxDistance or minDistance
		while (reverse ~= true and currentTravelDist >= minDistance) or (reverse == true and currentTravelDist < maxDistance) do
			local x = (directionVector[1] * currentTravelDist) + startPos[1]
			local z = (directionVector[3] * currentTravelDist) + startPos[3]
			if GameHelpers.Grid.IsValidPosition(x, z, grid) then
				local y = grid:GetCellInfo(x,z).Height
				return {x,y,z},true
			end
			if reverse ~= true then
				currentTravelDist = currentTravelDist - distIncrement
			else
				currentTravelDist = currentTravelDist + distIncrement
			end
		end
	end
	return startPos,false
end

---@param startPos vec3|ObjectParam
---@param directionVector vec3
---@param startDistance? number
---@param reverse? boolean Start from the smallest distance possible instead.
---@param distIncrement? number The number to progressively add when finding valid positions.
---@return number x
---@return number y
---@return number z
---@return boolean success
function GameHelpers.Grid.GetValidPositionAlongLine(startPos, directionVector, startDistance, reverse, distIncrement)
	local pos,success = GameHelpers.Grid.GetValidPositionTableAlongLine(startPos, directionVector, startDistance, reverse, distIncrement)
	if success then
		local x,y,z = table.unpack(pos)
		return x,y,z,true
	end
	local x,y,z = table.unpack(startPos)
	return x,y,z,false
end

---@param startPos vec3|ObjectParam
---@param maxRadius? number
---@param pointsInCircle? number
---@param reverse? boolean Start from the largest distance possible instead.
---@param bounds? boolean Start from the largest distance possible instead.
---@return vec3 position
---@return boolean success
function GameHelpers.Grid.GetValidPositionTableInRadius(startPos, maxRadius, pointsInCircle, reverse, bounds)
	startPos = GameHelpers.Math.GetPosition(startPos)
	maxRadius = maxRadius or 30.0
	-- Convert to meters
	if maxRadius > 1000 then
		maxRadius = maxRadius / 1000
	end
	pointsInCircle = pointsInCircle or 9
	local grid = _getGrid()
	if grid then
		if GameHelpers.Grid.IsValidPosition(startPos[1], startPos[3], grid) then
			local y = grid:GetHeight(startPos[1],startPos[3]) or startPos[2]
			return {startPos[1], y, startPos[3]},true
		elseif maxRadius > 0 then
			if reverse then
				local radius = maxRadius
				local slice = 2 * math.pi / pointsInCircle
				while radius > 1.0 do
					for i=0,pointsInCircle do
						local angle = slice * i
						local x = math.floor((startPos[1] + radius * math.cos(angle))+0.5)
						local z = math.floor((startPos[3] + radius * math.sin(angle))+0.5)
						if GameHelpers.Grid.IsValidPosition(x, z, grid) then
							local y = grid:GetCellInfo(x,z).Height
							return {x,y,z},true
						end
					end
					radius = radius - 1.0
				end
			else
				local radius = 1.0
				local slice = 2 * math.pi / pointsInCircle
				while radius <= maxRadius do
					for i=0,pointsInCircle do
						local angle = slice * i
						local x = math.floor((startPos[1] + radius * math.cos(angle))+0.5)
						local z = math.floor((startPos[3] + radius * math.sin(angle))+0.5)
						if GameHelpers.Grid.IsValidPosition(x, z, grid) then
							local y = grid:GetCellInfo(x,z).Height
							return {x,y,z},true
						end
					end
					radius = radius + 1.0
				end
			end
		end
	end
	return startPos,false
end

---@param startPos vec3|ObjectParam
---@param maxRadius? number
---@param pointsInCircle? number
---@param reverse? boolean Start from the largest distance possible instead.
---@return number x
---@return number y
---@return number z
---@return boolean success
function GameHelpers.Grid.GetValidPositionInRadius(startPos, maxRadius, pointsInCircle, reverse)
	local pos,success = GameHelpers.Grid.GetValidPositionTableInRadius(startPos, maxRadius, pointsInCircle, reverse)
	if success then
		local x,y,z = table.unpack(pos)
		return x,y,z,true
	end
	local x,y,z = table.unpack(startPos)
	return x,y,z,false
end

if not _ISCLIENT then
	local _INTERNAL = GameHelpers._INTERNAL

	---@param e TimerFinishedEventArgs
	function _INTERNAL.OnForceMoveTimer_Old(e)
		local target = e.Data.UUID
		if target ~= nil then
			local targetObject = e.Data.Object
			local targetData = _PV.ForceMoveData[target]
			if not GameHelpers.ObjectExists(targetObject) then
				_PV.ForceMoveData[target] = nil
				return
			end
			if targetData ~= nil and targetData.Position then
				if GameHelpers.Math.GetDistance(target, targetData.Position) <= 1 then
					pcall(Osi.NRD_GameActionDestroy,targetData.Handle)
					_PV.ForceMoveData[target] = nil
					local source = targetData.Source
					if source then
						source = GameHelpers.TryGetObject(targetData.Source)
					else
						source = targetObject
					end
					local skillData = nil
					if targetData.Skill then
						skillData = Ext.Stats.Get(targetData.Skill, nil, false)
						---@cast skillData StatEntrySkillData
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
						SkillData = skillData
					})
					if skillData then
						Osi.LeaderLib_Force_OnLanded(GameHelpers.GetUUID(target,true), GameHelpers.GetUUID(targetData.Source, true), skillData.Name)
					else
						--LeaderLib_Force_OnLanded((GUIDSTRING)_Target, (GUIDSTRING)_Source, (STRING)_Event)
						Osi.LeaderLib_Force_OnLanded(GameHelpers.GetUUID(target,true), GameHelpers.GetUUID(targetData.Source, true), "Lua")
					end
				else
					Timer.StartObjectTimer(e.ID, target, 250)
				end
			else
				fprint(LOGLEVEL.WARNING, "[LeaderLib_OnForceMoveAction_Old] No force move data for target (%s). How did this happen?", targetObject.DisplayName)
				Events.ForceMoveFinished:Invoke({
					ID = "",
					Target = targetObject,
					Source = targetObject,
					TargetGUID = targetObject.MyGuid,
					SourceGUID = targetObject.MyGuid,
					Distance = 0,
					StartingPosition = targetObject.WorldPos
				})
			end
		end
	end

	Timer.Subscribe("LeaderLib_OnForceMoveAction_Old", function(e) _INTERNAL.OnForceMoveTimer_Old(e) end)
	
	---Push or pull a target from a source object or position.  
	---Similar to the Force action, except it's grid-safe (no pushing objects out of the map).
	---@param source EsvCharacter|EsvItem
	---@param target EsvCharacter|EsvItem
	---@param distanceMultiplier? number
	---@param skill? string
	---@param startPos? vec3 If set, this will be the starting position to push from. Defaults to the source's WorldPosition otherwise.
	---@param beamEffect? string The beam effect to play with the NRD_CreateGameObjectMove action.
	---@param id? string An optional ID to associate with this move action
	---@return boolean success Returns true if the force move action has started.
	function GameHelpers.ForceMoveObject(source, target, distanceMultiplier, skill, startPos, beamEffect, id)
		---@type EsvCharacter|EsvItem
		local sourceObject = GameHelpers.TryGetObject(source)
		---@type EsvCharacter|EsvItem
		local targetObject = GameHelpers.TryGetObject(target)
		fassert(sourceObject ~= nil, "Invalid source parameter (%s)", source)
		fassert(targetObject ~= nil, "Invalid target parameter (%s)", target)
		if _type(startPos) ~= "table" then
			startPos = sourceObject.WorldPos
		end
		local dist = GameHelpers.Math.GetDistance(targetObject, startPos)
		local distMult = math.abs(distanceMultiplier)
		if dist > distMult then
			fprint(LOGLEVEL.WARNING, "[GameHelpers.ForceMoveObject] target(%s) is outside of the push distance range (%s) > (%s) from the starting position. Skipping.", targetObject.DisplayName, dist, distMult)
			return false
		end

		Timer.Cancel("LeaderLib_OnForceMoveAction", targetObject)
		Timer.Cancel("LeaderLib_CheckKnockupDistance", targetObject)
		_PV.ForceMoveData[targetObject.MyGuid] = nil

		--local startPos = GameHelpers.Math.GetForwardPosition(source.MyGuid, distMult)
		local directionalVector = GameHelpers.Math.GetDirectionalVector(targetObject, sourceObject, distanceMultiplier < 0)
		local tx,ty,tz = GameHelpers.Grid.GetValidPositionAlongLine(startPos, directionalVector, distMult)

		--NRD_CreateGameObjectMove(me.MyGuid, me.WorldPos[1] + 2, me.WorldPos[2], me.WorldPos[3] + 2, "", me.MyGuid); Mods.LeaderLib.Timer.StartOneshot("", 50, function() Ext.IO.SaveFile("Dumps/ActionMachine.json", Ext.DumpExport(Ext.Entity.GetCurrentLevel().GameActionManager)) end);
		--local x,y,z = table.unpack(me.WorldPos); NRD_CreateRain(me.MyGuid, "Rain_Water", x, y, z)
		if tx and tz then
			local handle = Osi.NRD_CreateGameObjectMove(targetObject.MyGuid, tx, ty, tz, beamEffect or "", sourceObject.MyGuid)
			if handle then
				_PV.ForceMoveData[targetObject.MyGuid] = {
					ID = id or "",
					Position = {tx,ty,tz},
					Start = TableHelpers.Clone(startPos),
					Handle = handle,
					Source = sourceObject.MyGuid,
					IsFromSkill = skill ~= nil,
					Skill = skill,
					Distance = distanceMultiplier
				}
				Timer.StartObjectTimer("LeaderLib_OnForceMoveAction_Old", targetObject.MyGuid, 250)
				return true
			end
		end

		--No valid position, or the action failed.
		return false
	end
	
	---@param source EsvCharacter
	---@param target EsvCharacter|EsvItem
	---@param position vec3
	---@param skill? string
	---@param beamEffect? string The beam effect to play with the NRD_CreateGameObjectMove action.
	---@return boolean success
	function GameHelpers.ForceMoveObjectToPosition(source, target, position, skill, beamEffect)
		local sourceObject = GameHelpers.TryGetObject(source)
		local targetObject = GameHelpers.TryGetObject(target)
		if not sourceObject and targetObject then
			fprint(LOGLEVEL.ERROR, "[GameHelpers.ForceMoveObjectToPosition] Invalid source(%s) or target(%s) parameters.", source, target)
		end

		Timer.Cancel("LeaderLib_OnForceMoveAction", targetObject)
		Timer.Cancel("LeaderLib_CheckKnockupDistance", targetObject)
		_PV.ForceMoveData[targetObject.MyGuid] = nil
		
		local x,y,z = table.unpack(targetObject.WorldPos)
		local tx,ty,tz = table.unpack(position)
		local handle = Osi.NRD_CreateGameObjectMove(targetObject.MyGuid, tx, ty, tz, beamEffect or "", sourceObject.MyGuid)
		if handle ~= nil then
			_PV.ForceMoveData[targetObject.MyGuid] = {
				Position = {tx,ty,tz},
				Start = {x,y,z},
				Handle = handle,
				Source = sourceObject.MyGuid,
				IsFromSkill = skill ~= nil,
				Skill = skill,
				Distance = GameHelpers.Math.GetDistance(targetObject.WorldPos, position)
			}
			Timer.StartObjectTimer("LeaderLib_OnForceMoveAction_Old", targetObject.MyGuid, 250)
			return true
		end
		return false
	end
end

---Get the y value of the grid at a specifix coordinate.
---@param x number
---@param z number
---@return number
function GameHelpers.Grid.GetY(x,z,grid)
	---@type EocAiGrid
	local grid = grid or _getGrid()
	if grid then
		local info = grid:GetCellInfo(x,z)
		if info and info.Height then
			return info.Height
		end
	end
	return 0.0
end

---@class ExtenderGridCellInfo:table
---@field Height number
---@field Objects ObjectHandle[]|nil
---@field GroundSurface ObjectHandle|nil
---@field CloudSurface ObjectHandle|nil

---@class LeaderLibCellSurfaceData:table
---@field Cell ExtenderGridCellInfo
---@field Ground EsvSurface|nil
---@field Cloud EsvSurface|nil
---@field HasSurface fun(name:string, containingName:boolean|nil, onlyLayer:integer|nil):boolean

---@class LeaderLibRadiusDataSurfaceEntry:table
---@field Surface EsvSurface
---@field Position vec3

---@class LeaderLibSurfaceRadiusData:table
---@field Cell table<integer, table<integer, ExtenderGridCellInfo>>
---@field Ground LeaderLibRadiusDataSurfaceEntry[]
---@field Cloud LeaderLibRadiusDataSurfaceEntry[]
---@field SurfaceMap table<string, LeaderLibRadiusDataSurfaceEntry[]>
---@field HasSurface fun(name:string, containingName:boolean|nil, onlyLayer:integer|nil):boolean

local function GetSurfaceType(data)
	if not _ISCLIENT then
		return data.SurfaceType
	else
		return data
	end
end

---@param data LeaderLibCellSurfaceData
local function HasSurfaceSingle(data, name, containingName, onlyLayer)
	local t = _type(name)
	if t == "table" then
		for _,v in pairs(name) do
			if data.HasSurface(v, containingName, onlyLayer) then
				return true
			end
		end
	elseif t == "string" then
		local matchName = string.lower(name)
		if data.Ground and onlyLayer ~= 1 then
			local st = GetSurfaceType(data.Ground)
			if st == name or (containingName and string.find(string.lower(st), matchName)) then
				return true
			end
		end
		if data.Cloud and onlyLayer ~= 0 then
			local st = GetSurfaceType(data.Cloud)
			if st == name or (containingName and string.find(string.lower(st), matchName)) then
				return true
			end
		end
	else
		ferror("Wrong type for parameter 'name': (%s). Should be string or a table.", t)
	end

	return false
end

---@param data LeaderLibSurfaceRadiusData
local function HasSurfaceRadius(data, name, containingName, onlyLayer)
	if _type(name) == "table" then
		for _,v in pairs(name) do
			if HasSurfaceRadius(data, v, containingName, onlyLayer) then
				return true
			end
		end
	else
		if containingName then
			local matchName = string.lower(name)
			if not onlyLayer then
				for k,tbl in pairs(data.SurfaceMap) do
					if string.find(string.lower(k), matchName) and #tbl > 0 then
						return true
					end
				end
			else
				if onlyLayer == 1 then
					for _,v in pairs(data.Cloud) do
						if string.find(string.lower(GetSurfaceType(v.Surface)), matchName) then
							return true
						end
					end
				else
					for _,v in pairs(data.Ground) do
						if string.find(string.lower(GetSurfaceType(v.Surface)), matchName) then
							return true
						end
					end
				end
			end
		else
			return data.SurfaceMap[name] and #data.SurfaceMap[name] > 0
		end
	end
	return false
end

local SurfaceFlags = {
	Ground = {
		Type = {
			Fire = 0x1000000,
			Water = 0x2000000,
			Blood = 0x4000000,
			Poison = 0x8000000,
			Oil = 0x10000000,
			Lava = 0x20000000,
			Source = 0x40000000,
			Web = 0x80000000,
			Deepwater = 0x100000000,
			Sulfurium = 0x200000000,
			--UNUSED = 0x400000000
		},
		State = {
			Blessed = 0x400000000000,
			Cursed = 0x800000000000,
			Purified = 0x1000000000000,
			--??? = 0x2000000000000
		},
		Modifier = {
			Electrified = 0x40000000000000,
			Frozen = 0x80000000000000,
		},
	},
	Cloud = {
		Type = {
			FireCloud = 0x800000000,
			WaterCloud = 0x1000000000,
			BloodCloud = 0x2000000000,
			PoisonCloud = 0x4000000000,
			SmokeCloud = 0x8000000000,
			ExplosionCloud = 0x10000000000,
			FrostCloud = 0x20000000000,
			Deathfog = 0x40000000000,
			ShockwaveCloud = 0x80000000000,
			--UNUSED = 0x100000000000
			--UNUSED = 0x200000000000
		},
		State = {
			Blessed = 0x4000000000000,
			Cursed = 0x8000000000000,
			Purified = 0x10000000000000,
			--UNUSED = 0x20000000000000
		},
		Modifier = {
			Electrified = 0x100000000000000,
			-- ElectrifiedDecay = 0x200000000000000,
			-- SomeDecay = 0x400000000000000,
			--UNUSED = 0x800000000000000
		}
	},
	--AI grid painted flags
	-- Irreplaceable = 0x4000000000000000,
	-- IrreplaceableCloud = 0x800000000000000,
}

---@param flags integer
---@return string|nil
function GameHelpers.Grid.GetSurfaceFromAiFlags(flags)
	local groundType = nil
	for k,f in pairs(SurfaceFlags.Ground.Type) do
		if (flags & f) ~= 0 then
			groundType = k
		end
	end
	if groundType then
		local groundSurface = groundType
		for k,f in pairs(SurfaceFlags.Ground.Modifier) do
			if (flags & f) ~= 0 then
				groundSurface = groundSurface .. k
			end
		end
		for k,f in pairs(SurfaceFlags.Ground.State) do
			if (flags & f) ~= 0 then
				groundSurface = groundSurface .. k
			end
		end
		return groundSurface
	end
	local cloudType = nil
	for k,f in pairs(SurfaceFlags.Cloud.Type) do
		if (flags & f) ~= 0 then
			cloudType = k
		end
	end
	if cloudType then
		local cloudSurface = cloudType
		for k,f in pairs(SurfaceFlags.Cloud.Modifier) do
			if (flags & f) ~= 0 then
				cloudSurface = cloudSurface .. k
			end
		end
		for k,f in pairs(SurfaceFlags.Cloud.State) do
			if (flags & f) ~= 0 then
				cloudSurface = cloudSurface .. k
			end
		end
		return cloudSurface
	end
	return nil
end

local function SetSurfaceFromFlags(flags, data)
	for k,f in pairs(SurfaceFlags.Ground.Type) do
		if (flags & f) ~= 0 then
			data.Ground = k
		end
	end
	if data.Ground then
		for k,f in pairs(SurfaceFlags.Ground.Modifier) do
			if (flags & f) ~= 0 then
				data.Ground = data.Ground .. k
			end
		end
		for k,f in pairs(SurfaceFlags.Ground.State) do
			if (flags & f) ~= 0 then
				data.Ground = data.Ground .. k
			end
		end
	end
	for k,f in pairs(SurfaceFlags.Cloud.Type) do
		if (flags & f) ~= 0 then
			data.Cloud = k
		end
	end
	if data.Cloud then
		for k,f in pairs(SurfaceFlags.Cloud.Modifier) do
			if (flags & f) ~= 0 then
				data.Cloud = data.Cloud .. k
			end
		end
		for k,f in pairs(SurfaceFlags.Cloud.State) do
			if (flags & f) ~= 0 then
				data.Cloud = data.Cloud .. k
			end
		end
	end
end

---@param x number
---@param z number
---@param grid? EocAiGrid
---@param maxRadius? number
---@param pointsInCircle? number The precision when checking in a radius. Defaults to 9.
---@return LeaderLibCellSurfaceData|LeaderLibSurfaceRadiusData
function GameHelpers.Grid.GetSurfaces(x, z, grid, maxRadius, pointsInCircle)
	---@type EocAiGrid
	grid = grid or _getGrid()
	if grid then
		if _type(maxRadius) ~= "number" or maxRadius <= 0 then
			local cell = grid:GetCellInfo(x, z)
			if cell then
				local data = {
					Cell=cell,
					Ground = nil,
					Cloud = nil,
				}
				data.HasSurface = function(...)
					return HasSurfaceSingle(data, ...)
				end
				if not _ISCLIENT then
					if cell.GroundSurface then
						data.Ground = Ext.Entity.GetSurface(cell.GroundSurface)
					end
					if cell.CloudSurface then
						data.Cloud = Ext.Entity.GetSurface(cell.CloudSurface)
					end
				else
					if cell.Flags then
						data.Flags = cell.Flags
						SetSurfaceFromFlags(cell.Flags, data)
					end
				end
				return data
			end
		else
			---@type LeaderLibSurfaceRadiusData
			local data = {
				Cell = {},
				Ground = {},
				Cloud = {},
				SurfaceMap = {}
			}
			data.HasSurface = function(name, containingName, onlyLayer)
				return HasSurfaceRadius(data, name, containingName, onlyLayer)
			end
			pointsInCircle = pointsInCircle or 9
			local radius = 0
			local slice = 2 * math.pi / pointsInCircle
			while radius <= maxRadius do
				for i=0,pointsInCircle do
					local angle = slice * i
					local tx = math.floor((x + radius * math.cos(angle))+0.5)
					local tz = math.floor((z + radius * math.sin(angle))+0.5)
					local cell = grid:GetCellInfo(tx, tz)
					if cell then
						if not data.Cell[tx] then
							data.Cell[tx] = {}
						end
						if not data.Cell[tx][tz] then
							data.Cell[tx][tz] = cell

							if not _ISCLIENT then
								if cell.GroundSurface then
									local surfaceData = {
										Surface = Ext.Entity.GetSurface(cell.GroundSurface),
										Position = {tx,cell.Height,tz}
									}
									data.Ground[#data.Ground+1] = surfaceData
									if not data.SurfaceMap[surfaceData.Surface.SurfaceType] then
										data.SurfaceMap[surfaceData.Surface.SurfaceType] = {}
									end
									table.insert(data.SurfaceMap[surfaceData.Surface.SurfaceType], surfaceData)
								end
								if cell.CloudSurface then
									local cloudData = {
										Surface = Ext.Entity.GetSurface(cell.CloudSurface),
										Position = {tx,cell.Height,tz}
									}
									data.Cloud[#data.Cloud+1] = cloudData
									if not data.SurfaceMap[cloudData.Surface.SurfaceType] then
										data.SurfaceMap[cloudData.Surface.SurfaceType] = {}
									end
									table.insert(data.SurfaceMap[cloudData.Surface.SurfaceType], cloudData)
								end
							else
								if cell.Flags then
									local tempData = {}
									SetSurfaceFromFlags(cell.Flags, tempData)
									if tempData.Ground then
										local surfaceData = {
											Surface = tempData.Ground,
											Position = {tx,cell.Height,tz}
										}
										data.Ground[#data.Ground+1] = surfaceData
										if not data.SurfaceMap[tempData.Ground] then
											data.SurfaceMap[tempData.Ground] = {}
										end
										table.insert(data.SurfaceMap[tempData.Ground], surfaceData)
									end
									if tempData.Cloud then
										local cloudData = {
											Surface = tempData.Cloud,
											Position = {tx,cell.Height,tz}
										}
										data.Cloud[#data.Cloud+1] = cloudData
										if not data.SurfaceMap[tempData.Cloud] then
											data.SurfaceMap[tempData.Cloud] = {}
										end
										table.insert(data.SurfaceMap[tempData.Cloud], cloudData)
									end
								end
							end
						end
					end
				end
				radius = radius + 1.0
			end
			return data
		end
	end
	return nil
end

---@alias GameHelpers_Grid_GetNearbyObjectsOptionsTargetType string|"Character"|"Item"|"All"

---@class GameHelpers_Grid_GetNearbyObjectsOptionsRelationOptions
---@field Ally boolean|nil
---@field Neutral boolean|nil
---@field Enemy boolean|nil
---@field CanAdd fun(target:ServerObject, source:ServerObject|vec3):boolean Optional function that will be used to filter targets.

---@class GameHelpers_Grid_GetNearbyObjectsOptions
---@field Radius number The max distance between the source and objects. Defaults to 3.0 if not set.
---@field Position vec3 Use this position for distance checks, instead of the source.
---@field AsTable boolean Return the result as a table, instead of an iterator.
---@field Type GameHelpers_Grid_GetNearbyObjectsOptionsTargetType
---@field AllowDead boolean Allow returning dead characters/destroyed items.
---@field AllowOffStage boolean Allow returning offstage objects.
---@field Relation GameHelpers_Grid_GetNearbyObjectsOptionsRelationOptions Filter returned characters by this relation, such as "Ally" "Neutral".
---@field Sort string|"Distance"|"Random"|"LowestHP"|"HighestHP"|"None"|fun(a:ServerObject,b:ServerObject):boolean
---@field IgnoreHeight boolean If true, the y value of positions is ignored when comparing distance.
---@field ActivatedOnly boolean If true, only activated items/characters will be checked (objects within 30m of a player). Enable this for a more performant search.

---@type GameHelpers_Grid_GetNearbyObjectsOptions
local _defaultGetNearbyObjectsOptions = {
	Radius = 3.0,
	Type = "Character",
	Sort = "None",
	AllowDead = false,
	AllowOffStage = false,
	IgnoreHeight = false,
	ActivatedOnly = false
}

local _ValidObjectType = {
	All = true,
	Character = true,
	Item = true,
}

---@param distances table<Guid,number>
---@return fun(a:ServerObject, b:ServerObject):boolean
local function _SortDistance(distances)
	---@param a ServerObject
	---@param b ServerObject
	return function (a,b)
		local d1 = distances[GameHelpers.GetObjectID(a)] or 9999
		local d2 = distances[GameHelpers.GetObjectID(b)] or 9999
		return d1 < d2
	end
end

---@param reverse? boolean
---@return fun(a:ServerObject, b:ServerObject):boolean
local function _SortVitality(reverse)
	---@param a ServerObject
	---@param b ServerObject
	return function (a,b)
		local d1 = a.Stats and a.Stats.CurrentVitality or 999999
		local d2 = b.Stats and b.Stats.CurrentVitality or 999999
		return not reverse and (d1 < d2) or (d1 > d2)
	end
end

---@alias GameHelpers_Grid_GetNearbyObjectsFunctionResult fun():ServerObject
---@alias GameHelpers_Grid_GetNearbyObjectsTableResult ServerObject[]

---@param level EsvLevel|EclLevel
---@param activatedOnly boolean
---@param isItem boolean
local function _GetEntities(level, activatedOnly, isItem)
	level = level or _getCurrentLevel()
	if not level then
		return {}
	end
	local levelName = level.LevelDesc.LevelName
	local entries = nil
	if isItem then
		if activatedOnly then
			entries = level.EntityManager.ItemConversionHelpers.ActivatedItems[levelName]
		else
			entries = level.EntityManager.ItemConversionHelpers.RegisteredItems[levelName]
		end
	else
		if activatedOnly then
			entries = level.EntityManager.CharacterConversionHelpers.ActivatedCharacters[levelName]
		else
			entries = level.EntityManager.CharacterConversionHelpers.RegisteredCharacters[levelName]
		end
	end
	return entries or {}
end

---@param distances table
---@param objects table
---@param level EsvLevel|EclLevel
---@param options GameHelpers_Grid_GetNearbyObjectsOptions
---@param source ServerObject|ClientObject
---@param pos vec3
---@return integer total
local function _GetNearbyObjects_ObjectSource(distances, objects, level, options, source, pos)
	local sourceID = GameHelpers.GetObjectID(source)
	local sourceIsCharacter = GameHelpers.Ext.ObjectIsCharacter(source)
	local total = 0
	if options.Type == "All" or options.Type == "Item" then
		local entries = _GetEntities(level, options.ActivatedOnly, true)
		local len = #entries
		for i=1,len do
			local obj = entries[i]
			local objID = _ISCLIENT and obj.NetID or obj.MyGuid
			local dist = GameHelpers.Math.GetDistance(obj, pos, options.IgnoreHeight)
			distances[objID] = dist
			if objID ~= sourceID and dist <= options.Radius then
				if (options.AllowDead or not GameHelpers.ObjectIsDead(obj)) and (options.AllowOffStage or not obj.OffStage) then
					if options.Relation and options.Relation.CanAdd then
						local b,result = xpcall(options.Relation.CanAdd, debug.traceback, obj, source)
						if not b then
							Ext.Utils.PrintError(result)
						elseif result == true then
							total = total + 1
							objects[total] = obj
						end
					elseif GameHelpers.Character.CanAttackTarget(obj, source, true) then
						total = total + 1
						objects[total] = obj
					end
				end
			end
		end
	end
	if options.Type == "All" or options.Type == "Character" then
		local entries = _GetEntities(level, options.ActivatedOnly, false)
		local len = #entries
		for i=1,len do
			local obj = entries[i]
			local objID = _ISCLIENT and obj.NetID or obj.MyGuid
			local dist = GameHelpers.Math.GetDistance(obj, pos, options.IgnoreHeight)
			distances[objID] = dist
			if objID ~= sourceID and dist <= options.Radius then
				if (options.AllowDead or not GameHelpers.ObjectIsDead(obj)) and (options.AllowOffStage or not obj.OffStage) then
					if options.Relation and sourceIsCharacter then
						if options.Relation.Ally and GameHelpers.Character.IsAllyOfParty(obj, source) then
							total = total + 1
							objects[total] = obj
						elseif options.Relation.Enemy and GameHelpers.Character.CanAttackTarget(obj, source) then
							total = total + 1
							objects[total] = obj
						elseif options.Relation.Neutral and GameHelpers.Character.IsNeutralToParty(obj, source) then
							total = total + 1
							objects[total] = obj
						elseif options.Relation.CanAdd then
							local b,result = xpcall(options.Relation.CanAdd, debug.traceback, obj, source)
							if not b then
								Ext.Utils.PrintError(result)
							elseif result == true then
								total = total + 1
								objects[total] = obj
							end
						end
					else
						total = total + 1
						objects[total] = obj
					end
				end
			end
		end
	end
	return total
end

---@param distances table
---@param objects table
---@param level EsvLevel|EclLevel
---@param options GameHelpers_Grid_GetNearbyObjectsOptions
---@param pos vec3
---@return integer total
local function _GetNearbyObjects_PositionSource(distances, objects, level, options, pos)
	local total = 0
	if options.Type == "All" or options.Type == "Item" then
		local entries = _GetEntities(level, options.ActivatedOnly, true)
		local len = #entries
		for i=1,len do
			local obj = entries[i]
			local objID = _ISCLIENT and obj.NetID or obj.MyGuid
			local dist = GameHelpers.Math.GetDistance(obj, pos, options.IgnoreHeight)
			distances[objID] = dist
			if dist <= options.Radius then
				if (options.AllowDead or not GameHelpers.ObjectIsDead(obj)) and (options.AllowOffStage or not obj.OffStage) then
					if options.Relation and options.Relation.CanAdd then
						local b,result = xpcall(options.Relation.CanAdd, debug.traceback, obj, pos)
						if not b then
							Ext.Utils.PrintError(result)
						elseif result == true then
							total = total + 1
							objects[total] = obj
						end
					else
						total = total + 1
						objects[total] = obj
					end
				end
			end
		end
	end
	if options.Type == "All" or options.Type == "Character" then
		local entries = _GetEntities(level, options.ActivatedOnly, false)
		local len = #entries
		for i=1,len do
			local obj = entries[i]
			local objID = _ISCLIENT and obj.NetID or obj.MyGuid
			local dist = GameHelpers.Math.GetDistance(obj, pos, options.IgnoreHeight)
			distances[objID] = dist
			if dist <= options.Radius then
				if (options.AllowDead or not GameHelpers.ObjectIsDead(obj)) and (options.AllowOffStage or not obj.OffStage) then
					if options.Relation and options.Relation.CanAdd then
						local b,result = xpcall(options.Relation.CanAdd, debug.traceback, obj, pos)
						if not b then
							Ext.Utils.PrintError(result)
						elseif result == true then
							total = total + 1
							objects[total] = obj
						end
					else
						total = total + 1
						objects[total] = obj
					end
				end
			end
		end
	end
	return total
end

---@param source ObjectParam|vec3 An object or position.
---@param opts GameHelpers_Grid_GetNearbyObjectsOptions
---@return GameHelpers_Grid_GetNearbyObjectsFunctionResult|GameHelpers_Grid_GetNearbyObjectsTableResult objects
function GameHelpers.Grid.GetNearbyObjects(source, opts)
	local options = TableHelpers.SetDefaultOptions(opts, _defaultGetNearbyObjectsOptions)

	local objects = {}
	local distances = {}

	local sourceObject = GameHelpers.TryGetObject(source)

	local pos = GameHelpers.Math.GetPosition(source)
	if options.Position then
		pos = options.Position
	end

	local level = _getCurrentLevel()
	if not level then
		if not options.AsTable then
			return function () return nil end
		else
			return objects
		end
	end

	if not _ValidObjectType[options.Type] then
		error(string.format("[GameHelpers.Grid.GetNearbyObjects] opts.Type(%s) is not a valid target type. Should be All, Item, or Character", options.Type), 2)
	end

	local count = 0
	if sourceObject then
		count = _GetNearbyObjects_ObjectSource(distances, objects, level, options, sourceObject, pos)
	else
		count = _GetNearbyObjects_PositionSource(distances, objects, level, options, pos)
	end

	if options.Sort and options.Sort ~= "None" then
		if options.Sort == "Random" then
			objects = Common.ShuffleTable(objects)
		elseif options.Sort == "Distance" then
			table.sort(objects, _SortDistance(distances))
		elseif options.Sort == "LowestHP" then
			table.sort(objects, _SortVitality(false))
		elseif options.Sort == "HighestHP" then
			table.sort(objects, _SortVitality(true))
		elseif type(options.Sort) == "function" then
			table.sort(objects, options.Sort)
		end
	end

	if not options.AsTable then
		local i = 0
		return function ()
			i = i + 1
			if i <= count then
				return objects[i]
			end
		end
	else
		return objects
	end
end

local function _GetObjectsWithinDistance(pos, radius, list)
	local total = 0
	local objects = {}
	for _,v in pairs(list) do
		if _getDistance(v.WorldPos, pos) <= radius then
			total = total + 1
			objects[total] = v
		end
	end
	return objects,total
end

---@overload fun(pos:vec3, radius:number, activeOnly?:boolean):(fun():CharacterObject)
---A faster way to get nearby characters that lacks any type/param safeguards.  
---@param pos vec3
---@param radius number
---@param activeOnly boolean
---@param asTable boolean
---@return CharacterObject[]
function GameHelpers.Grid.GetNearbyCharactersFast(pos, radius, activeOnly, asTable)
	local level = _getCurrentLevel()
	if not level then
		if not asTable then
			return function () return nil end
		else
			return {}
		end
	end
	local levelName = level.LevelDesc.LevelName
	local list = nil
	if activeOnly then
		list = level.EntityManager.CharacterConversionHelpers.ActivatedCharacters[levelName]
	else
		list = level.EntityManager.CharacterConversionHelpers.RegisteredCharacters[levelName]
	end
	local objects,total = _GetObjectsWithinDistance(pos, radius, list)

	if not asTable then
		local i = 0
		return function ()
			i = i + 1
			if i <= total then
				return objects[i]
			end
		end
	else
		return objects
	end
end

---@overload fun(pos:vec3, radius:number, activeOnly?:boolean):(fun():ItemObject)
---A faster way to get nearby items that lacks any type/param safeguards.  
---@param pos vec3
---@param radius number
---@param activeOnly boolean
---@param asTable boolean
---@return ItemObject[]
function GameHelpers.Grid.GetNearbyItemsFast(pos, radius, activeOnly, asTable)
	local level = _getCurrentLevel()
	if not level then
		if not asTable then
			return function () return nil end
		else
			return {}
		end
	end
	local levelName = level.LevelDesc.LevelName
	local list = nil
	if activeOnly then
		list = level.EntityManager.ItemConversionHelpers.ActivatedItems[levelName]
	else
		list = level.EntityManager.ItemConversionHelpers.RegisteredItems[levelName]
	end
	local objects,total = _GetObjectsWithinDistance(pos, radius, list)

	if not asTable then
		local i = 0
		return function ()
			i = i + 1
			if i <= total then
				return objects[i]
			end
		end
	else
		return objects
	end
end