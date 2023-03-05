if GameHelpers.Math == nil then
	GameHelpers.Math = {}
end

local _type = type
local _cos = math.cos
local _sin = math.sin
local _arccos = math.acos
local _arcsin = math.asin
local _arctan = math.atan
local _max = math.max
local _min = math.min
local _floor = math.floor
local _sqrt = math.sqrt
local _unpack = table.unpack
local _rad = math.rad
local _ran = Ext.Utils.Random

local _vecadd = Ext.Math.Add
local _vecsub = Ext.Math.Sub
local _vecnorm = Ext.Math.Normalize
local _vecmul = Ext.Math.Mul

local function _ConditionalUnpack(pos, b)
	if b then
		return _unpack(pos)
	end
	return pos
end

---Tries to get the position from whatever the variable is.
---@overload fun(obj:vec3|ObjectParam):vec3
---@param obj vec3|ObjectParam
---@param unpackResult boolean If true, the position value is returned as separate numbers.
---@param fallback vec3|nil If no position is found, this value or {0,0,0} is returned.
---@return number x
---@return number y
---@return number z
function GameHelpers.Math.GetPosition(obj, unpackResult, fallback)
	local t = _type(obj)
	if t == "table" then --[[@cast obj table]]
		if obj.Type == "Vector3" and obj.Unpack then
			if unpackResult then
				return obj:Unpack()
			else
				return {obj:Unpack()}
			end
		else
			return _ConditionalUnpack(obj, unpackResult)
		end
	elseif t == "string" or t == "number" or GameHelpers.IsValidHandle(obj) then --[[@cast obj Guid|NetId|ComponentHandle]]
		local object = GameHelpers.TryGetObject(obj)
		if object then
			t = "userdata"
			obj = object
		end
	end
	if t == "userdata" and obj.WorldPos then --[[@cast obj userdata]]
		return _ConditionalUnpack(obj.WorldPos, unpackResult)
	end
	if fallback == nil then
		if unpackResult then
			return 0,0,0
		else
			return {0,0,0}
		end
	end
	---@cast fallback vec3
	return fallback
end

local _GetPosition = GameHelpers.Math.GetPosition

---@param startPos vec3|ObjectParam
---@param angle number
---@param distanceMult number
---@param unpack boolean|nil If true, x,y,z will be returned separately.
---@return vec3|number
---@return number|nil
---@return number|nil
function GameHelpers.Math.GetPositionWithAngle(startPos, angle, distanceMult, unpack)
	local x,y,z = _GetPosition(startPos, true)
	if _type(distanceMult) ~= "number" then
		distanceMult = 1.0
	end
	angle = _rad(angle)
	--y = GameHelpers.Grid.GetY(tx,tz)

	local tx,ty,tz = GameHelpers.Grid.GetValidPositionInRadius({
		x + (_cos(angle) * distanceMult),
		y,
		z + (_sin(angle) * distanceMult)},6.0)

	if unpack then
		return tx,ty,tz
	else
		return {tx,ty,tz}
	end
end

---Get the relative angle between one position and another, from 0 to 360.  
---The backstabbing range is 150 - 210, while being in "front" would be 0 - 30 or 330 = 360.  
---@return integer A number from 0 to 360
---@param target vec3|ObjectParam
---@param attacker vec3|ObjectParam
function GameHelpers.Math.GetRelativeAngle(target, attacker)
	local targetPos = _GetPosition(target)
	local attackerPos = _GetPosition(attacker)

	local atkDir = {}
	for i=1,3 do
		atkDir[i] = attackerPos[i] - targetPos[i]
	end

	local atkAngle = math.deg(math.atan(atkDir[3], atkDir[1]))
	if atkAngle < 0 then
		atkAngle = 360 + atkAngle
	end

	local targetRot = target.Rotation
	local angle = math.deg(math.atan(-targetRot[1], targetRot[3]))
	if angle < 0 then
		angle = 360 + angle
	end

	local relAngle = atkAngle - angle
	if relAngle < 0 then
		relAngle = 360 + relAngle
	end

	return relAngle
end

---@param pos1 vec3|ObjectParam
---@param pos2 vec3|ObjectParam
---@return boolean
function GameHelpers.Math.PositionsEqual(pos1, pos2)
	local x,y,z = _GetPosition(pos1, true)
	local x2,y2,z2 = _GetPosition(pos2, true)
	return x == x2 and y == y2 and z == z2
end

---Get a position derived from a character's forward facing direction.
---@param char CharacterParam
---@param distanceMult number|nil
---@param fromPosition vec3|nil
---@return vec3
function GameHelpers.Math.GetForwardPosition(char, distanceMult, fromPosition)
	---@type EsvCharacter
	local character = GameHelpers.GetCharacter(char)
	local x,y,z = _unpack(character.WorldPos)
	if character ~= nil then
		if distanceMult == nil then
			distanceMult = 1.0
		end
		local forwardVector = {
			-character.Rotation[7] * distanceMult,
			0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
			-character.Rotation[9] * distanceMult,
		}
		x = character.Stats.Position[1] + forwardVector[1]
		z = character.Stats.Position[3] + forwardVector[3]
		if fromPosition ~= nil then
			x = fromPosition[1] + forwardVector[1] or x
			y = fromPosition[2] or y
			z = fromPosition[3] + forwardVector[3] or z
		end
	end
	
	y = GameHelpers.Grid.GetY(x,z)
	return {x,y,z}
end

---@param source CharacterParam
---@param distanceMult number|nil
---@param x number|nil
---@param y number|nil
---@param z number|nil
---@param forwardVector vec3|nil
---@return vec3 position
function GameHelpers.Math.ExtendPositionWithForwardDirection(source, distanceMult, x,y,z, forwardVector)
	local character = GameHelpers.GetCharacter(source)
	if character then
		if not x or not y or not z then
			x,y,z = _unpack(character.WorldPos)
		end
		if not forwardVector then
			forwardVector = {
				character.Rotation[7],
				0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
				character.Rotation[9],
			}
		end
	end
	if _type(distanceMult) ~= "number" then
		distanceMult = 1.0
	end
	if forwardVector then
		if #forwardVector >= 9 then
			x = x + (-forwardVector[7] * distanceMult)
			z = z + (-forwardVector[9] * distanceMult)
		else
			x = x + (-forwardVector[1] * distanceMult)
			z = z + (-forwardVector[3] * distanceMult)
		end
	end

	y = GameHelpers.Grid.GetY(x,z)
	return {x,y,z}
end

---@param pos vec3|ObjectParam
---@param distanceMult number
---@param directionalVector vec3
---@param skipSnapToGrid boolean|nil Skip snapping the y value to the grid height at the resulting position.
---@return vec3 position
function GameHelpers.Math.ExtendPositionWithDirectionalVector(pos, directionalVector, distanceMult, skipSnapToGrid)
	local x,y,z = _GetPosition(pos, true)
	x = x + (-directionalVector[1] * distanceMult)
	z = z + (-directionalVector[3] * distanceMult)
	if not skipSnapToGrid then
		y = GameHelpers.Grid.GetY(x,z)
	end
	return {x,y,z}
end

---@param pos1 vec3|ObjectParam
---@param pos2 vec3|ObjectParam
---@param percentage number The distance percentage to apply to the position between two targets, such as 0.5 to get the middle point.
---@param skipSnapToGrid? boolean Skip snapping the y value to the grid height at the resulting position.
---@return vec3
function GameHelpers.Math.GetPositionBetween(pos1, pos2, percentage, skipSnapToGrid)
	local pos1 = _GetPosition(pos1)
	local pos2 = _GetPosition(pos2)
	local dir = GameHelpers.Math.GetDirectionalVector(pos1, pos2)
	local distMult = GameHelpers.Math.GetDistance(pos1, pos2) * percentage
	local newPos = GameHelpers.Math.ExtendPositionWithDirectionalVector(pos1, dir, distMult, skipSnapToGrid)
	return newPos
end

---Sets an object's rotation.
---@param object ObjectParam
---@param rotx number
---@param rotz number
---@param turnTo boolean
function GameHelpers.Math.SetRotation(object, rotx, rotz, turnTo)
	local uuid = GameHelpers.GetUUID(object)
	if Ext.IsServer() then
		if ObjectIsCharacter(uuid) == 1 then
			local x,y,z = 0.0,0.0,0.0
			if rotx ~= nil and rotz ~= nil then
				local character = GameHelpers.GetCharacter(object)
				local pos = character.Stats.Position
				local forwardVector = {
					-rotx * 4.0,
					0,
					-rotz * 4.0,
				}
				x = pos[1] + forwardVector[1]
				y = pos[2]
				z = pos[3] + forwardVector[3]
				local target = CreateItemTemplateAtPosition("98fa7688-0810-4113-ba94-9a8c8463f830", x, y, z)
				if turnTo ~= true then
					CharacterLookAt(uuid, target, 1)
				end
				Osi.LeaderLib_Timers_StartObjectTimer(target, 250, "Timers_LeaderLib_Commands_RemoveItem", "LeaderLib_Commands_RemoveItem")
			end
		else
			local x,y,z = GetPosition(uuid)
			local amount = ItemGetAmount(uuid)
			local owner = ItemGetOwner(uuid)
	
			local pitch = 0.0174533 * rotx
			local roll = 0.0174533 * rotz
	
			ItemToTransform(uuid, x, y, z, pitch, 0.0, roll, amount, owner)
		end
	else
		Ext.Net.PostMessageToServer("LeaderLib_Helpers_SetRotation", Common.JsonStringify({
			UUID = uuid,
			X = rotx,
			Z = rotz,
			TurnTo = turnTo
		}))
	end
end

if Ext.IsServer() then
	Ext.RegisterNetListener("LeaderLib_Helpers_SetRotation", function(cmd, payload)
		local data = Common.JsonParse(payload)
		GameHelpers.Math.SetRotation(data.UUID, data.X, data.Z, data.TurnTo)
	end)
end

---Get the distance between two Vector3 points, or objects.
---@param pos1 vec3|ObjectParam First position array, or an object with a WorldPos.
---@param pos2 vec3|ObjectParam Second position array, or an object with a WorldPos.
---@param ignoreHeight boolean|nil Ignore the Y value when fetching the distance.
---@return number distance
function GameHelpers.Math.GetDistance(pos1, pos2, ignoreHeight)
	local x,y,z = _GetPosition(pos1, true)
	local tx,ty,tz = _GetPosition(pos2, true)
	local xDiff = x - tx
	local yDiff = not ignoreHeight and (y - ty) or 0
	local zDiff = z - tz
	return _sqrt((xDiff^2) + (yDiff^2) + (zDiff^2))
end

---Get the distance between two Vector3 points, or objects, including the AI bounds radius of any objects
---@param pos1 vec3|ObjectParam First position array, or an object with a WorldPos.
---@param pos2 vec3|ObjectParam Second position array, or an object with a WorldPos.
---@param ignoreHeight boolean|nil Ignore the Y value when fetching the distance.
---@return number distance
function GameHelpers.Math.GetOuterDistance(pos1, pos2, ignoreHeight)
	local x,y,z = _GetPosition(pos1, true)
	local tx,ty,tz = _GetPosition(pos2, true)
	local dir = GameHelpers.Math.GetDirectionalVector(pos1,pos2)
	if GameHelpers.Ext.IsObjectType(pos1) then
		---@cast pos1 EsvCharacter|EsvItem
		x = x + (-dir[1] * pos1.AI.AIBoundsRadius)
		z = z + (-dir[3] * pos1.AI.AIBoundsRadius)
	end
	if GameHelpers.Ext.IsObjectType(pos2) then
		---@cast pos2 EsvCharacter|EsvItem
		tx = tx + (-dir[1] * pos2.AI.AIBoundsRadius)
		tz = tz + (-dir[3] * pos2.AI.AIBoundsRadius)
	end
	local xDiff = x - tx
	local yDiff = not ignoreHeight and (y - ty) or 0
	local zDiff = z - tz
	return _sqrt((xDiff^2) + (yDiff^2) + (zDiff^2))
end

---@overload fun(pos1:vec3|ObjectParam, pos2:vec3|ObjectParam, reverse:boolean|nil):vec3
---@overload fun(pos1:vec3|ObjectParam, pos2:vec3|ObjectParam):vec3
---@overload fun(object:ObjectParam):vec3
---Get the directional vector between two Vector3 points.
---@param pos1 vec3|ObjectParam
---@param pos2 vec3|ObjectParam
---@param reverse boolean|nil Multiply the result by -1,-1,-1.
---@param asVector3 boolean|nil Optionally return the result as a Vector3
---@return Vector3
function GameHelpers.Math.GetDirectionalVector(pos1, pos2, reverse, asVector3)
	if GameHelpers.Ext.IsObjectType(pos1) and pos2 == nil and pos1.Rotation then
		local rot = pos1.Rotation
		return {rot[7],0,rot[9]}
	end
	local directionalVector = _vecnorm(_vecsub(_GetPosition(pos1), _GetPosition(pos2)))
	if reverse then
		directionalVector = _vecmul(directionalVector, {-1,-1,-1})
	end
	if asVector3 then
		return Classes.Vector3.Create(table.unpack(directionalVector))
	else
		return directionalVector
	end
end

---@deprecated
---[Deprecated] - Use GameHelpers.Math.GetDirectionalVector
function GameHelpers.Math.GetDirectionalVectorBetweenPositions(...)
	return GameHelpers.Math.GetDirectionalVector(...)
end

---@deprecated
---[Deprecated] - Use GameHelpers.Math.GetDirectionalVector
function GameHelpers.Math.GetDirectionalVectorBetweenObjects(...)
	return GameHelpers.Math.GetDirectionalVector(...)
end

function GameHelpers.Math.Round(num, numPlaces)
	local mult = 10^(numPlaces or 0)
	return _floor(num * mult + 0.5) / mult
end

function GameHelpers.Math.ScaleToRange(val, minRange, maxRange, minScale, maxScale)
	if val == minRange then
		return minScale
	elseif val >= maxRange then
		return maxScale
	end
	local diff = maxRange - val
	local diffMult = diff/(maxRange - minRange)
	local result = diffMult*(maxScale - minScale)
	return _min(maxScale, _max(result, minScale))
end

---Returns true if a number is NaN, probably.
---@param x number
function GameHelpers.Math.IsNaN(x)
	if _type(x) == "number" then
		local str = tostring(x)
		return str == "nan" or str == tostring(0/0)
	end
	return true
end

---@param value number
---@param minValue number
---@param maxValue number
function GameHelpers.Math.Clamp(value, minValue, maxValue)
	return _max(_min(value, maxValue), minValue)
end

---@param v number
---@param min number|nil
---@param max number|nil
---@return number
local function _normalize(v, min, max)
	min = min or 0
	max = max or 1
	return (v - min) / (max - min)
end

GameHelpers.Math.Normalize = _normalize

---Converts a hex string to RGB.
---@param hex string
---@return integer,integer,integer
function GameHelpers.Math.HexToRGB(hex)
	local t = _type(hex)
	if t == "number" then
		hex = tostring(hex)
		t = "string"
	end
	if t == "string" then
		local hex = hex:gsub("#","")
		if hex:len() == 3 then
		  return (tonumber("0x"..hex:sub(1,1))*17)/255, (tonumber("0x"..hex:sub(2,2))*17)/255, (tonumber("0x"..hex:sub(3,3))*17)/255
		else
		  return tonumber("0x"..hex:sub(1,2))/255, tonumber("0x"..hex:sub(3,4))/255, tonumber("0x"..hex:sub(5,6))/255
		end
	end
end

---Converts a hex string to an RGBA table, scaled to the 0-1 for material Vec4 usage.
---@param hex string
---@return vec3
function GameHelpers.Math.HexToMaterialRGBA(hex)
	local r,g,b = GameHelpers.Math.HexToRGB(hex)
	return GameHelpers.Math.ScaleRGB(r, g, b, 0)
end

---Scales RGB to the 0-1 range, using Game.Math.Normalize.
---@param r number
---@param g number
---@param b number
---@param a number|nil Optional alpha
---@return vec3
function GameHelpers.Math.ScaleRGB(r,g,b,a)
	if a then
		return {_normalize(r), _normalize(g), _normalize(b), _normalize(a)}
	else
		return {_normalize(r), _normalize(g), _normalize(b)}
	end
end

---@param fromX number
---@param fromY number
---@param fromWidth number
---@param fromHeight number
---@param toWidth number
---@param toHeight number
---@return number,number
function GameHelpers.Math.ConvertScreenCoordinates(fromX, fromY, fromWidth, fromHeight, toWidth, toHeight)
	local newX = fromX / fromWidth * toWidth
	local newY = fromY / fromHeight * toHeight
	return newX, newY
end

---@param totalWidth number
---@param totalHeight number
---@param width number
---@param height number
---@return number x
---@return number y
function GameHelpers.Math.Center(totalWidth, totalHeight, width, height)
	local x = (totalWidth - width)/2
	local y = (totalHeight - height)/2
	return x, y
end

---@class EulerAngle
---@field X number
---@field Y number
---@field Z number

---Convert xyz angle values to a rotation matrix.
---@param x number
---@param y number
---@param z number
---@return vec3
function GameHelpers.Math.XYZToRotationMatrix(x, y, z)
	local cy,cx,cz = _cos(y), _cos(x), _cos(z)
	local sy,sx,sz = _sin(y), _sin(x), _sin(z)
	local rot = {
		cy*cz,
		sx*sy*cz - sz*cx,
		sy*cx*cz + sx*sz,
		sz*cy,
		sx*sy*sz + cx*cz,
		sy*sz*cx - sx*cz,
		-sy,
		sx*cy,
		cx*cy,
	}
	return rot
end

---Convert an {X,Y,Z} table using euler angle values to a rotation matrix.
---@param euler vec3|Vector3
---@return vec3 rotation 3x3 matrix, i.e. {0,0,0,0,0,0,0,0,0}
function GameHelpers.Math.EulerToRotationMatrix(euler)
	local x,y,z = _unpack(euler)
	return GameHelpers.Math.XYZToRotationMatrix(x,y,z)
end

---@param rot vec3
---@return vec3
function GameHelpers.Math.RotationMatrixToEuler(rot)
	local beta = -_arcsin(rot[7])
	local alpha = _arctan(rot[8]/_cos(beta), rot[9]/_cos(beta))
	local gamma = _arctan(rot[4]/_cos(beta), rot[1]/_cos(beta))
	local euler = {
		beta,
		alpha,
		gamma,
	}
	return euler
end

--local rot = Mods.LeaderLib.GameHelpers.Math.RotationMatrixToEuler(me.Rotation); local angle = rot[2]; local effectRot = Mods.LeaderLib.GameHelpers.Math.AngleToEffectRotationMatrix(angle); Mods.LeaderLib.EffectManager.PlayEffectAt("RS3_FX_Skills_Warrior_GroundSmash_Cast_01", me.WorldPos, {Rotation=effectRot})
--Ext.Dump(Mods.LeaderLib.GameHelpers.Math.ObjectRotationToEuler(me.Rotation)) Ext.Dump({GetRotation(me.MyGuid)})

---@param rot vec3
---@return vec3
function GameHelpers.Math.ObjectRotationToEuler(rot)
	local x,y,z = 0,0,0
	local cosy = 1 / _cos(_arcsin(rot[2]))
	x = _arctan(rot[5] * cosy, rot[8] * cosy)
	y = rot[2]
	z = _arctan(rot[1] * cosy, rot[7] * cosy)
	return {x*57.295776,y*57.295776,z*57.295776}
end

---Takes an angle value, like from the query GetRotation, and returns a 3x3 matrix that can be used with effects like ones created with Ext.Effect.CreateEffect.
---@param angle number Angle in degrees
---@return vec3 matrix 3x3 matrix, i.e. {0,0,0,0,0,0,0,0,0}
function GameHelpers.Math.AngleToEffectRotationMatrix(angle)
	angle = _rad(angle)
	return {
		_cos(angle), 0, -_sin(angle), 0, 1, 0, _sin(angle), 0, _cos(angle)
	}
end

---@param sourcePos vec3|ObjectParam
---@param targetPos vec3|ObjectParam
---@return StatsHighGroundBonus
function GameHelpers.Math.GetHighGroundFlag(sourcePos, targetPos)
	local sourcePos = _GetPosition(sourcePos)
	local targetPos = _GetPosition(targetPos)
	if not sourcePos or not targetPos then
		return "EvenGround"
	end
	local heightDiff = sourcePos[2] - targetPos[2]
	local threshold = GameHelpers.GetExtraData("HighGroundThreshold", 2.4)
	if heightDiff < threshold then
		if -threshold >= heightDiff then
			return "LowGround"
		end
	else
		return "HighGround"
	end
	return "EvenGround"
end

---@param chance integer The roll must be below or equal to this number.
---@param bonusRolls integer|nil How many times to roll if the first roll is unsuccessful. Defaults to 0.
---@param minValue integer|nil Minimum value for the random range. Defaults to 0.
---@param maxValue integer|nil Maximum value for the random range. Defaults to 100.
---@return boolean success
---@return integer roll
function GameHelpers.Math.Roll(chance, bonusRolls, minValue, maxValue)
	minValue = minValue or 0
	maxValue = maxValue or 100
	if chance < minValue then
		return false,minValue
	end
	if chance >= maxValue then
		return true,maxValue
	end
	bonusRolls = bonusRolls or 0
	--Increase random range to increase randomness (low ranges tend to give more successes)
	if maxValue == 100 and minValue == 0 then
		maxValue = maxValue * 100
		if chance <= 100 then
			chance = chance * 100
		end
	end
	for i=bonusRolls+1,0,-1 do
		local roll = _ran(minValue, maxValue)
		if roll > minValue and roll <= chance then
			return true,roll
		end
	end
	return false,0
end