if GameHelpers.Math == nil then
	GameHelpers.Math = {}
end

---Tries to get the position from whatever the variable is.
---@param obj number[]|UUID|EsvCharacter|EsvItem|Vector3
---@param unpackResult boolean|nil If true, the position value is returned as separate numbers.
---@param fallback number[]|nil If no position is found, this value or {0,0,0} is returned.
---@return number[]|number
---@return number|nil
---@return number|nil
function GameHelpers.Math.GetPosition(obj, unpackResult, fallback)
    local t = type(obj)
    local pos = nil
    if t == "string" and Ext.OsirisIsCallable() then
        local x,y,z = GetPosition(obj)
        if x then
            pos = {x,y,z}
        end
    elseif t == "string" or t == "number" then
        obj = GameHelpers.TryGetObject(obj)
        if obj then
            t = "userdata"
        end
    end
    if t == "userdata" and obj.WorldPos then
        pos = {obj.WorldPos[1], obj.WorldPos[2], obj.WorldPos[3]}
    elseif t == "table" then
        if obj.Type == "Vector3" and obj.Unpack then
            pos = {obj:Unpack()}
        else
            pos = obj
        end
    end
    if pos then
        if unpackResult then
            return table.unpack(pos)
        end
        return pos
    end
    if fallback == nil then
        if unpackResult then
            return 0,0,0
        else
            return {0,0,0}
        end
    end
    return fallback
end

---Get a position derived from a character's forward facing direction.
---@param char UUID|EsvCharacter
---@param distanceMult number|nil
---@param fromPosition number[]|nil
function GameHelpers.Math.GetForwardPosition(char, distanceMult, fromPosition)
    ---@type EsvCharacter
    local character = GameHelpers.GetCharacter(char)
    local x,y,z = table.unpack(character.WorldPos)
    if character ~= nil then
        if distanceMult == nil then
            distanceMult = 1.0
        end
        local forwardVector = {
            -character.Stats.Rotation[7] * distanceMult,
            0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
            -character.Stats.Rotation[9] * distanceMult,
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

---@param source UUID|EsvCharacter
---@param distanceMult number
---@param x number
---@param y number
---@param z number
---@param forwardVector number[]|nil
---@return number[] position
function GameHelpers.Math.ExtendPositionWithForwardDirection(source, distanceMult, x,y,z, forwardVector)
    local character = GameHelpers.GetCharacter(source)
    if character then
        if not x and not y and not z then
            x,y,z = table.unpack(character.WorldPos)
        end
        if not forwardVector then
            forwardVector = {
                character.Stats.Rotation[7],
                0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
                character.Stats.Rotation[9],
            }
        end
    end
    if type(distanceMult) ~= "number" then
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

---Sets an object's rotation.
---@param object UUID|EsvCharacter|EsvItem|EclCharacter|EclItem
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
        Ext.PostMessageToServer("LeaderLib_Helpers_SetRotation", Common.JsonStringify({
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
---@param pos1 number[]|ObjectParam First position array, or an object with a WorldPos.
---@param pos2 number[]|ObjectParam Second position array, or an object with a WorldPos.
---@return number distance
function GameHelpers.Math.GetDistance(pos1, pos2)
    local x,y,z = GameHelpers.Math.GetPosition(pos1, true)
    local tx,ty,tz = GameHelpers.Math.GetPosition(pos2, true)
    local xDiff = x - tx
    local yDiff = y - ty
    local zDiff = z - tz
    return math.sqrt((xDiff^2) + (yDiff^2) + (zDiff^2))
end

---Get the directional vector between two Vector3 points.
---@param pos1 number[]
---@param pos2 number[]
---@param reverse boolean|nil Multiply the result by -1,-1,-1.
---@param asVector3 boolean|nil Optionally return the result as a Vector3
---@return number[]|Vector3
function GameHelpers.Math.GetDirectionalVectorBetweenPositions(pos1, pos2, reverse, asVector3)
    local vec = Classes.Vector3
    ---@type Vector3
    local a = vec(table.unpack(pos1))
    ---@type Vector3
    local b = vec(table.unpack(pos2))
    a:Sub(b)
    a:Normalize()
    if reverse then
        a:Mul(vec(-1,-1,-1))
    end
    if asVector3 then
        return a
    else
        return {a:Unpack()}
    end
end

---Get the directional vector between two objects' WorldPos.
---@param obj1 EsvCharacter|EsvItem
---@param obj2 EsvCharacter|EsvItem
---@param reverse boolean|nil
---@param asVector3 boolean|nil Optionally return the result as a Vector3
---@return number[]|Vector3
function GameHelpers.Math.GetDirectionalVectorBetweenObjects(obj1, obj2, reverse, asVector3)

    local dir = GameHelpers.Math.GetDirectionalVectorBetweenPositions(obj1.WorldPos, obj2.WorldPos, reverse, true)
    -- if GameHelpers.Ext.ObjectIsCharacter(obj2) then
    --     ---@type Quaternion
    --     local angle = Classes.Quaternion(obj2.Stats.Rotation[7], obj2.Stats.Rotation[8], obj2.Stats.Rotation[9], 1)
    --     a:Rotate(angle)
    -- end

    if asVector3 then
        return dir
    else
        return {dir:Unpack()}
    end
end

---Get the directional vector between two Vector3 points.
---@param pos1 number[]|string
---@param pos2 number[]|string
---@return number[]
function GameHelpers.Math.GetDirectionVector(pos1, pos2, reverse)
    local vec = Classes.Vector3
    local x,y,z = GameHelpers.Math.GetPosition(pos1, true)
    local x2,y2,z2 = GameHelpers.Math.GetPosition(pos2, true)
    local a = vec(x,y,z)
    local b = vec(x2,y2,z2)
    a:Sub(b)
    a:Normalize()
    if not reverse then
        return {a:Unpack()}
    else
        return {-a.x,-a.y,-a.z}
    end
end

function GameHelpers.Math.Round(num, numPlaces)
	local mult = 10^(numPlaces or 0)
	return math.floor(num * mult + 0.5) / mult
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
    return math.min(maxScale, math.max(result, minScale))
end

---Returns true if a number is NaN, probably.
---@param x number
function GameHelpers.Math.IsNaN(x)
    if type(x) == "number" then
        local str = tostring(x)
        return str == "nan" or str == tostring(0/0)
    end
    return true
end

---@param value number
---@param minValue number
---@param maxValue number
function GameHelpers.Math.Clamp(value, minValue, maxValue)
    return math.max(math.min(value, maxValue), minValue)
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
    local t = type(hex)
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
---@return number[]
function GameHelpers.Math.HexToMaterialRGBA(hex)
    local r,g,b = GameHelpers.Math.HexToRGB(hex)
    return GameHelpers.Math.ScaleRGB(r, g, b, 0)
end

---Scales RGB to the 0-1 range, using Game.Math.Normalize.
---@param r number
---@param g number
---@param b number
---@param a number|nil Optional alpha
---@return number[]
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

---@class EulerAngle
---@field X number
---@field Y number
---@field Z number

local cos = math.cos
local sin = math.sin
local arccos = math.acos
local arcsin = math.asin
local arctan = math.atan

---Convert xyz angle values to a rotation matrix.
---@param x number
---@param y number
---@param z number
---@return number[]
function GameHelpers.Math.XYZToRotationMatrix(x, y, z)
    local cy,cx,cz = cos(y), cos(x), cos(z)
    local sy,sx,sz = sin(y), sin(x), sin(z)
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
---@param euler number[]|Vector3
---@return number[] rotation 3x3 matrix, i.e. {0,0,0,0,0,0,0,0,0}
function GameHelpers.Math.EulerToRotationMatrix(euler)
    return GameHelpers.Math.XYZToRotationMatrix(table.unpack(euler))
end

---@param rot number[]
---@return number[]
function GameHelpers.Math.RotationMatrixToEuler(rot)
    local beta = -arcsin(rot[7])
    local alpha = arctan(rot[8]/cos(beta), rot[9]/cos(beta))
    local gamma = arctan(rot[4]/cos(beta), rot[1]/cos(beta))
    local euler = {
        beta,
        alpha,
        gamma,
    }
    return euler
end

--Ext.Dump(Mods.LeaderLib.GameHelpers.Math.ObjectRotationToEuler(me.Stats.Rotation)) Ext.Dump({GetRotation(me.MyGuid)})

---@param rot number[]
---@return number[]
function GameHelpers.Math.ObjectRotationToEuler(rot)
    local x,y,z = 0,0,0
    local cosy = 1 / cos(arcsin(rot[2]))
    x = arctan(rot[5] * cosy, rot[8] * cosy)
    y = rot[2]
    z = arctan(rot[1] * cosy, rot[7] * cosy)
    return {x*57.295776,y*57.295776,z*57.295776}
end

---@param startPos number[]
---@param angle number
---@param distanceMult number
---@param unpack boolean|nil If true, x,y,z will be returned separately.
---@return number[]|number
---@return number|nil
---@return number|nil
function GameHelpers.Math.GetPositionWithAngle(startPos, angle, distanceMult, unpack)
    if type(distanceMult) ~= "number" then
        distanceMult = 1.0
    end
    angle = math.rad(angle)
    local x,y,z = table.unpack(startPos)
    --y = GameHelpers.Grid.GetY(tx,tz)

    local tx,ty,tz = GameHelpers.Grid.GetValidPositionInRadius({
        x + (math.cos(angle) * distanceMult),
        y,
        z + (math.sin(angle) * distanceMult)},6.0)

    if unpack then
        return tx,ty,tz
    else
        return {tx,ty,tz}
    end
end

---@param sourcePos number[]|ObjectParam
---@param targetPos number[]|ObjectParam
---@return HighGroundFlag
function GameHelpers.Math.GetHighGroundFlag(sourcePos, targetPos)
    local sourcePos = GameHelpers.Math.GetPosition(sourcePos)
    local targetPos = GameHelpers.Math.GetPosition(targetPos)
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
---@param minValue integer|nil Minimum value for the random range. Defaults to 1.
---@param maxValue integer|nil Maximum value for the random range. Defaults to 100.
---@return boolean success
function GameHelpers.Math.Roll(chance, bonusRolls, minValue, maxValue)
    minValue = minValue or 1
    maxValue = maxValue or 100
    if chance <= minValue then
        return false
    end
    if chance == maxValue then
        return true
    end
    bonusRolls = bonusRolls or 0
    --Increase random range to increase randomness (low ranges tend to give more successes)
    if maxValue == 100 then
        minValue = minValue * 100
        maxValue = maxValue * 100
        chance = chance * 100
    end
    for i=bonusRolls+1,0,-1 do
        local roll = Ext.Random(minValue, maxValue)
        if roll > 0 and roll <= chance then
            return true
        end
    end
    return false
end