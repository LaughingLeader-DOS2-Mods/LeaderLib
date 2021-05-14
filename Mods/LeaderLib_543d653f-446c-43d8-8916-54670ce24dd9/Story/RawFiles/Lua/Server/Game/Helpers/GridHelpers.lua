if GameHelpers.Grid == nil then
	GameHelpers.Grid = {}
end

---@param x number
---@param z number
---@param grid AiGrid|nil
---@return boolean
function GameHelpers.Grid.IsValidPosition(x, z, grid)
	---@type AiGrid
	grid = grid or Ext.GetAiGrid()
	--print("GameHelpers.Grid.IsValidPosition",x,z,grid:GetAiFlags(x, z), grid:GetAiFlags(x, z)&1==1)
	local flag = grid:GetAiFlags(x, z)
	if flag ~= nil then
		return flag & 1 ~= 1
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
	---@type AiGrid
	local grid = Ext.GetAiGrid()
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
	return table.unpack(startPos)
end

---@param startX number
---@param startZ number
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
	---@type AiGrid
	local grid = Ext.GetAiGrid()
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
	return table.unpack(startPos)
end

---@param target string
function GameHelpers.Internal.OnForceMoveTimer(timerName, target)
	if target ~= nil then
		local targetData = PersistentVars.ForceMoveData[target]
		if targetData ~= nil then
			local x,y,z = table.unpack(targetData.Position)
			if GetDistanceToPosition(target, x,y,z) < 1 then
				NRD_GameActionDestroy(targetData.Handle)
				PersistentVars.ForceMoveData[target] = nil
			else
				StartTimer(timerName, 250, target)
			end
		end
	end
end

RegisterListener("NamedTimerFinished", "Timers_LeaderLib_OnForceMoveAction", GameHelpers.Internal.OnForceMoveTimer)

---@param source EsvCharacter
---@param target EsvGameObject
---@param distanceMultiplier number|nil
---@return number,number|nil
function GameHelpers.ForceMoveObject(source, target, distanceMultiplier)
	local existingData = PersistentVars.ForceMoveData[target.MyGuid]
	if existingData ~= nil and existingData.Handle ~= nil then
		NRD_GameActionDestroy(existingData.Handle)
		PersistentVars.ForceMoveData[target.MyGuid] = nil
	end
	local startPos = GameHelpers.Math.GetForwardPosition(source.MyGuid, distanceMultiplier)
	local forwardVector = {-source.Stats.Rotation[7], 0, -source.Stats.Rotation[9]}
	local tx,ty,tz = GameHelpers.Grid.GetValidPositionAlongLine(startPos, forwardVector, distanceMultiplier)
	PrintLog("[GameHelpers.ForceMoveObject] Moving to position: x(%s) -> x(%s) y(%s) -> y(%s) z(%s) -> z(%s) target(%s) source(%s)", startPos[1], tx, startPos[2], ty, startPos[3], tz, target.MyGuid, source.MyGuid)
	if tx ~= nil and tz ~= nil then
		local handle = NRD_CreateGameObjectMove(target.MyGuid, tx, ty, tz, "", source.MyGuid)
		if handle ~= nil then
			PersistentVars.ForceMoveData[target.MyGuid] = {
				Position = {tx,ty,tz},
				Handle = handle,
				Source = source.MyGuid
			}
			StartTimer("Timers_LeaderLib_OnForceMoveAction", 250, target.MyGuid)
		end
	end
end

---@param source EsvCharacter
---@param target EsvGameObject
---@param position number[]
---@return number,number|nil
function GameHelpers.ForceMoveObjectToPosition(source, target, position)
	local existingData = PersistentVars.ForceMoveData[target.MyGuid]
	if existingData ~= nil and existingData.Handle ~= nil then
		NRD_GameActionDestroy(existingData.Handle)
		PersistentVars.ForceMoveData[target.MyGuid] = nil
	end
	local x,y,z = GetPosition(target.MyGuid)
	local tx,ty,tz = table.unpack(position)
	PrintLog("[GameHelpers.ForceMoveObjectToPosition] Moving to position: x(%s) -> x(%s) y(%s) -> y(%s) z(%s) -> z(%s) target(%s) source(%s)", x, tx, y, ty, z, tz, target.MyGuid, source.MyGuid)
	local handle = NRD_CreateGameObjectMove(target.MyGuid, tx, ty, tz, "", source.MyGuid)
	if handle ~= nil then
		PersistentVars.ForceMoveData[target.MyGuid] = {
			Position = {tx,ty,tz},
			Handle = handle,
			Source = source.MyGuid
		}
		StartTimer("Timers_LeaderLib_OnForceMoveAction", 250, target.MyGuid)
	end
end

---Get the y value of the grid at a specifix coordinate.
---@param x number
---@param z number
---@return number
function GameHelpers.Grid.GetY(x,z)
	---@type AiGrid
	local grid = Ext.GetAiGrid()
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

---@class LeaderLibRadiusDataSurfaceEntry:table
---@field Surface EsvSurface
---@field Position number[]

---@class LeaderLibSurfaceRadiusData:table
---@field Cell table<integer, table<integer, ExtenderGridCellInfo>>
---@field Ground LeaderLibRadiusDataSurfaceEntry[]
---@field Cloud LeaderLibRadiusDataSurfaceEntry[]
---@field SurfaceMap table<string, EsvSurface>
---@field HasSurface fun(name:string, containingName:boolean|nil, onlyLayer:integer|nil):boolean

---@param data LeaderLibCellSurfaceData
local function HasSurfaceSingle(data, name, containingName, onlyLayer)
	if type(name) == "table" then
		for _,v in pairs(name) do
			if data.HasSurface(v, containingName, onlyLayer) then
				return true
			end
		end
	else
		local matchName = string.lower(name)
		if data.Ground and onlyLayer ~= 1 then
			if data.Ground.SurfaceType == name or (containingName and string.find(string.lower(data.Ground.SurfaceType), matchName)) then
				return true
			end
		end
		if data.Cloud and onlyLayer ~= 0 then
			if data.Cloud.SurfaceType == name or (containingName and string.find(string.lower(data.Cloud.SurfaceType), matchName)) then
				return true
			end
		end
	end

	return false
end

---@param data LeaderLibSurfaceRadiusData
local function HasSurfaceRadius(data, name, containingName, onlyLayer)
	if type(name) == "table" then
		for _,v in pairs(name) do
			if HasSurfaceRadius(data, v, containingName, onlyLayer) then
				return true
			end
		end
	else
		print("HasSurfaceRadius", data, name, containingName, onlyLayer, #data.Ground)
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
						if string.find(string.lower(v.Surface.SurfaceType), matchName) then
							return true
						end
					end
				else
					for _,v in pairs(data.Ground) do
						if string.find(string.lower(v.Surface.SurfaceType), matchName) then
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

---@param x number
---@param z number
---@param grid AiGrid|nil
---@param maxRadius number|nil
---@return LeaderLibCellSurfaceData|LeaderLibSurfaceRadiusData
function GameHelpers.Grid.GetSurfaces(x, z, grid, maxRadius)
	---@type AiGrid
	grid = grid or Ext.GetAiGrid()

	if not maxRadius or maxRadius <= 0 then
		local cell = grid:GetCellInfo(x, z)
		if cell then
			local data = {
				Cell=cell,
				Ground = nil,
				Cloud = nil,
			}
			data.HasSurface = function(name, containingName, onlyLayer)
				return HasSurfaceSingle(data, name, containingName, onlyLayer)
			end
			if cell.GroundSurface then
				data.Ground = Ext.GetSurface(cell.GroundSurface)
			end
			if cell.CloudSurface then
				data.Cloud = Ext.GetSurface(cell.CloudSurface)
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
		local pointsInCircle = 9
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
							
						if cell.GroundSurface then
							local surfaceData = 
							{
								Surface = Ext.GetSurface(cell.GroundSurface),
								Position = {tx,cell.Height,tz}
							}
							data.Ground[#data.Ground+1] = surfaceData
							if not data.SurfaceMap[surfaceData.Surface.SurfaceType] then
								data.SurfaceMap[surfaceData.Surface.SurfaceType] = {}
							end
							table.insert(data.SurfaceMap[surfaceData.Surface.SurfaceType], surfaceData.Surface)
						end
						if cell.CloudSurface then
							local cloudData = 
							{
								Surface = Ext.GetSurface(cell.CloudSurface),
								Position = {tx,cell.Height,tz}
							}
							data.Cloud[#data.Cloud+1] = cloudData
							if not data.SurfaceMap[cloudData.Surface.SurfaceType] then
								data.SurfaceMap[cloudData.Surface.SurfaceType] = {}
							end
							table.insert(data.SurfaceMap[cloudData.Surface.SurfaceType], cloudData.Surface)
						end
					end
				end
			end
			radius = radius + 1.0
		end
		return data
	end
	return nil
end