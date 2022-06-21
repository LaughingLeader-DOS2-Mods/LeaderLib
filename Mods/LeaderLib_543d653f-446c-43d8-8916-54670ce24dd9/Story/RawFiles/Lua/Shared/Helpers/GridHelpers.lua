if GameHelpers.Grid == nil then
	GameHelpers.Grid = {}
end

local _EXTVERSION = Ext.Version()
local _ISCLIENT = Ext.IsClient()
local _type = type

---@type fun():AiGrid
local _getGrid = function() end

if _EXTVERSION >= 56 then
	_getGrid = Ext.Entity.GetAiGrid
else
	if not _ISCLIENT then
		_getGrid = Ext.GetAiGrid
	end
end

---@param x number
---@param z number
---@param grid AiGrid|nil
---@return boolean
function GameHelpers.Grid.IsValidPosition(x, z, grid)
	---@type AiGrid
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

---@param startPos number[]
---@param directionVector number[]
---@param startDistance number|nil
---@param reverse boolean|nil Start from the smallest distance possible instead.
---@param distIncrement number|nil The number to progressively add when finding valid positions.
---@return number,number,number
function GameHelpers.Grid.GetValidPositionAlongLine(startPos, directionVector, startDistance, reverse, distIncrement)
	distIncrement = distIncrement or 0.1
	startDistance = startDistance or 12.0
	local grid = _getGrid()
	if grid then
		-- if GameHelpers.Grid.IsValidPosition(startPos[1], startPos[3], grid) then
		-- 	return startPos[1],startPos[2],startPos[3]
		if startDistance > 0 then
			local currentTravelDist = reverse ~= true and startDistance or 0
			while (reverse ~= true and currentTravelDist >= 0) or (reverse == true and currentTravelDist < startDistance) do
				local x = (directionVector[1] * currentTravelDist) + startPos[1]
				local z = (directionVector[3] * currentTravelDist) + startPos[3]
				if GameHelpers.Grid.IsValidPosition(x, z, grid) then
					local y = grid:GetCellInfo(x,z).Height
					return x,y,z
				end
				if reverse ~= true then
					currentTravelDist = currentTravelDist - distIncrement
				else
					currentTravelDist = currentTravelDist + distIncrement
				end
			end
		end
	end
	if startPos then
		return table.unpack(startPos)
	end
end

---@param startPos number[]
---@param maxRadius number|nil
---@param pointsInCircle number|nil
---@return number,number,number|nil
function GameHelpers.Grid.GetValidPositionInRadius(startPos, maxRadius, pointsInCircle)
	maxRadius = maxRadius or 30.0
	-- Convert to meters
	if maxRadius > 1000 then
		maxRadius = maxRadius / 1000
	end
	pointsInCircle = pointsInCircle or 9
	local grid = _getGrid()
	if grid then
		if GameHelpers.Grid.IsValidPosition(startPos[1], startPos[3], grid) then
			return startPos[1], startPos[2], startPos[3]
		elseif maxRadius > 0 then
			local radius = 1.0
			local slice = 2 * math.pi / pointsInCircle
			while radius <= maxRadius do
				for i=0,pointsInCircle do
					local angle = slice * i
					local x = math.floor((startPos[1] + radius * math.cos(angle))+0.5)
					local z = math.floor((startPos[3] + radius * math.sin(angle))+0.5)
					if GameHelpers.Grid.IsValidPosition(x, z, grid) then
						local y = grid:GetCellInfo(x,z).Height
						return x,y,z
					end
				end
				radius = radius + 1.0
			end
		end
	end
	if startPos then
		return table.unpack(startPos)
	end
end

if not _ISCLIENT then
	local _INTERNAL = GameHelpers._INTERNAL

	---@param e TimerFinishedEventArgs
	function _INTERNAL.OnForceMoveTimer(e)
		local target = e.Data.UUID
		if target ~= nil then
			local targetObject = e.Data.Object
			local targetData = PersistentVars.ForceMoveData[target]
			if targetData ~= nil and targetData.Position then
				if GameHelpers.Math.GetDistance(target, targetData.Position) <= 1 then
					pcall(NRD_GameActionDestroy,targetData.Handle)
					PersistentVars.ForceMoveData[target] = nil
					local source = targetData.Source
					if source then
						source = Ext.GetGameObject(targetData.Source)
					else
						source = targetObject
					end
					local skill = nil
					if targetData.Skill then
						skill = Ext.GetStat(targetData.Skill)
					end
					Events.ForceMoveFinished:Invoke({
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
					Timer.StartObjectTimer(e.ID, target, 250)
				end
			elseif targetObject then
				fprint(LOGLEVEL.WARNING, "[LeaderLib_OnForceMoveAction] No force move data for target (%s). How did this happen?", targetObject.DisplayName)
				Events.ForceMoveFinished:Invoke({
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
	
	---Push or pull a target from a source object or position.  
	---Similar to the Force action, except it's grid-safe (no pushing objects out of the map).
	---@param source EsvCharacter|EsvItem
	---@param target EsvCharacter|EsvItem
	---@param distanceMultiplier number|nil
	---@param skill string|nil
	---@param startPos number[]|nil If set, this will be the starting position to push from. Defaults to the source's WorldPosition otherwise.
	---@param beamEffect string|nil The beam effect to play with the NRD_CreateGameObjectMove action.
	---@return boolean success Returns true if the force move action has started.
	function GameHelpers.ForceMoveObject(source, target, distanceMultiplier, skill, startPos, beamEffect)
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
		local existingData = PersistentVars.ForceMoveData[targetObject.MyGuid]
		if existingData ~= nil and existingData.Handle ~= nil then
			--NRD_GameActionDestroy(existingData.Handle)
			PersistentVars.ForceMoveData[targetObject.MyGuid] = nil
		end
		--local startPos = GameHelpers.Math.GetForwardPosition(source.MyGuid, distMult)
		local directionalVector = GameHelpers.Math.GetDirectionalVectorBetweenObjects(targetObject, sourceObject, distanceMultiplier < 0)
		local tx,ty,tz = GameHelpers.Grid.GetValidPositionAlongLine(startPos, directionalVector, distMult)
	
		if tx and tz then
			local handle = NRD_CreateGameObjectMove(targetObject.MyGuid, tx, ty, tz, beamEffect or "", sourceObject.MyGuid)
			if handle then
				PersistentVars.ForceMoveData[targetObject.MyGuid] = {
					Position = {tx,ty,tz},
					Start = TableHelpers.Clone(startPos),
					Handle = handle,
					Source = sourceObject.MyGuid,
					IsFromSkill = skill ~= nil,
					Skill = skill,
					Distance = distanceMultiplier
				}
				Timer.StartObjectTimer("LeaderLib_OnForceMoveAction", targetObject.MyGuid, 250)
				return true
			end
		end

		--No valid position, or the action failed.
		return false
	end
	
	---@param source EsvCharacter
	---@param target EsvCharacter|EsvItem
	---@param position number[]
	---@param skill string|nil
	---@return number,number|nil
	function GameHelpers.ForceMoveObjectToPosition(source, target, position, skill)
		local existingData = PersistentVars.ForceMoveData[target.MyGuid]
		if existingData ~= nil and existingData.Handle ~= nil then
			--NRD_GameActionDestroy(existingData.Handle)
			PersistentVars.ForceMoveData[target.MyGuid] = nil
		end
		local x,y,z = table.unpack(target.WorldPos)
		local tx,ty,tz = table.unpack(position)
		local handle = NRD_CreateGameObjectMove(target.MyGuid, tx, ty, tz, "", source.MyGuid)
		if handle ~= nil then
			PersistentVars.ForceMoveData[target.MyGuid] = {
				Position = {tx,ty,tz},
				Start = TableHelpers.Clone(target.WorldPos),
				Handle = handle,
				Source = source.MyGuid,
				IsFromSkill = skill ~= nil,
				Skill = skill,
				Distance = GameHelpers.Math.GetDistance(target.WorldPos, position)
			}
			Timer.StartObjectTimer("LeaderLib_OnForceMoveAction", target.MyGuid, 250)
		end
	end
end

---Get the y value of the grid at a specifix coordinate.
---@param x number
---@param z number
---@return number
function GameHelpers.Grid.GetY(x,z,grid)
	---@type AiGrid
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
---@field Position number[]

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
---@param grid AiGrid|nil
---@param maxRadius number|nil
---@param pointsInCircle number|nil The precision when checking in a radius. Defaults to 9.
---@return LeaderLibCellSurfaceData|LeaderLibSurfaceRadiusData
function GameHelpers.Grid.GetSurfaces(x, z, grid, maxRadius, pointsInCircle)
	---@type AiGrid
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
				data.HasSurface = function(s, name, containingName, onlyLayer)
					return HasSurfaceSingle(s, name, containingName, onlyLayer)
				end
				if not _ISCLIENT then
					if cell.GroundSurface then
						data.Ground = Ext.GetSurface(cell.GroundSurface)
					end
					if cell.CloudSurface then
						data.Cloud = Ext.GetSurface(cell.CloudSurface)
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
										Surface = Ext.GetSurface(cell.GroundSurface),
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
										Surface = Ext.GetSurface(cell.CloudSurface),
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
---@field CanAdd fun(target:EsvCharacter|EsvItem, source:EsvCharacter|EsvItem|number[]):boolean Optional function that will be used to filter targets.

---@class GameHelpers_Grid_GetNearbyObjectsOptions
---@field Radius number The max distance between the source and objects. Defaults to 3.0 if not set.
---@field Position number[]|nil Use this position for distance checks, instead of the source.
---@field AsTable boolean|nil Return the result as a table, instead of an iterator.
---@field Type GameHelpers_Grid_GetNearbyObjectsOptionsTargetType|nil
---@field AllowDead boolean|nil Allow returning dead characters/destroyed items.
---@field AllowOffStage boolean|nil Allow returning offstage objects.
---@field Relation GameHelpers_Grid_GetNearbyObjectsOptionsRelationOptions|nil Filter returned characters by this relation, such as "Ally" "Neutral".

---@type GameHelpers_Grid_GetNearbyObjectsOptions
local _defaultGetNearbyObjectsOptions = {
	Radius = 3.0,
	Type = "Character"
}

---@alias GameHelpers_Grid_GetNearbyObjectsFunctionResult fun():EsvCharacter|EsvItem
---@alias GameHelpers_Grid_GetNearbyObjectsTableResult EsvCharacter[]|EsvItem[]

---@param source ObjectParam|number[] An object or position.
---@param opts GameHelpers_Grid_GetNearbyObjectsOptions
---@return GameHelpers_Grid_GetNearbyObjectsFunctionResult|GameHelpers_Grid_GetNearbyObjectsTableResult objects
function GameHelpers.Grid.GetNearbyObjects(source, opts)
	local opts = opts

	if not opts then
		opts = _defaultGetNearbyObjectsOptions
	else
		if not opts.Radius then
			opts.Radius = _defaultGetNearbyObjectsOptions.Radius
		end
		if not opts.Type then
			opts.Type = _defaultGetNearbyObjectsOptions.Type
		end
	end

	local objects = {}

	local GUID = GameHelpers.GetUUID(source, true)
	local sourceIsCharacter = GameHelpers.Ext.ObjectIsCharacter(source)

	local pos = GameHelpers.Math.GetPosition(source)
	if opts.Position then
		pos = opts.Position
	end

	if opts.Type == "All" or opts.Type == "Item" then
		local entries = Ext.GetAllItems(SharedData.RegionData.Current)
		local len = #entries
		for i=1,len do
			local v = entries[i]
			if v ~= GUID and GameHelpers.Math.GetDistance(v, pos) <= opts.Radius then
				local obj = GameHelpers.GetItem(v)
				if obj then
					if opts.AllowDead or not GameHelpers.ObjectIsDead(obj) and opts.AllowOffStage or not obj.OffStage then
						if opts.Relation and opts.Relation.CanAdd then
							local b,result = xpcall(opts.Relation.CanAdd, debug.traceback, obj, source)
							if not b then
								Ext.PrintError(result)
							elseif result == true then
								objects[#objects+1] = obj
							end
						else
							objects[#objects+1] = obj
						end
					end
				end
			end
		end
	end
	if opts.Type == "All" or opts.Type == "Character" then
		local entries = Ext.GetAllCharacters(SharedData.RegionData.Current)
		local len = #entries
		for i=1,len do
			local v = entries[i]
			if v ~= GUID and GameHelpers.Math.GetDistance(v, pos) <= opts.Radius then
				local obj = GameHelpers.GetCharacter(v)
				if obj and (opts.AllowDead or not GameHelpers.ObjectIsDead(obj) and opts.AllowOffStage or not obj.OffStage) then
					if opts.Relation and sourceIsCharacter then
						if opts.Relation.Ally and CharacterIsAlly(GUID, v) == 1 then
							objects[#objects+1] = obj
						elseif opts.Relation.Enemy and GameHelpers.Character.CanAttackTarget(GUID, v, true) then
							objects[#objects+1] = obj
						elseif opts.Relation.Neutral and CharacterIsNeutral(GUID, v) == 1 then
							objects[#objects+1] = obj
						elseif opts.Relation.CanAdd then
							local b,result = xpcall(opts.Relation.CanAdd, debug.traceback, obj, source)
							if not b then
								Ext.PrintError(result)
							elseif result == true then
								objects[#objects+1] = obj
							end
						end
					else
						objects[#objects+1] = obj
					end
				end
			end
		end
	else
		fprint(LOGLEVEL.WARNING, "[GameHelpers.Grid.GetNearbyObjects] opts.Type(%s) is not a valid target type. Should be All, Item, or Character")
		if not opts.AsTable then
			return function() end
		else
			return {}
		end
	end

	if not opts.AsTable then
		local i = 0
		local count = #objects
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