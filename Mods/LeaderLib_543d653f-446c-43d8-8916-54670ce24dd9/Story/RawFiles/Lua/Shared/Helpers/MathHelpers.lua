if GameHelpers.Math == nil then
	GameHelpers.Math = {}
end

---@return number,number,number
local function TryGetPos(x)
    local t = type(x)
    if t == "string" then
        if Ext.IsServer() then
            return GetPosition(x)
        else
            local obj = Ext.GetGameObject(x)
            if obj and obj.WorldPos then
                return table.unpack(obj.WorldPos)
            end
        end
    elseif t == "userdata" and t.WorldPos then
        return table.unpack(x.WorldPos)
    elseif t == "table" and #x == 3 then
        table.unpack(x)
    end
    return nil
end

---Get a position derived from a character's forward facing direction.
---@param char UUID|EsvCharacter
---@param distanceMult number
---@param fromPosition number[]
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
function GameHelpers.Math.ExtendPositionWithForwardDirection(source, distanceMult, x,y,z, forwardVector)
    local character = GameHelpers.GetCharacter(source)
    if character then
        if not x and not y and not z then
            x,y,z = table.unpack(character.WorldPos)
        end
        if not forwardVector then
            forwardVector = {
                -character.Stats.Rotation[7],
                0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
                -character.Stats.Rotation[9],
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
---@param uuid string
---@param rotx number
---@param rotz number
---@param turnTo boolean
function GameHelpers.Math.SetRotation(uuid, rotx, rotz, turnTo)
    if Ext.IsServer() then
        if ObjectIsCharacter(uuid) == 1 then
            local x,y,z = 0.0,0.0,0.0
            if rotx ~= nil and rotz ~= nil then
                local character = Ext.GetCharacter(uuid)
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
                Osi.LeaderLib_Timers_StartObjectTimer(target, 250, "LLMIME_Timers_LeaderLib_Commands_RemoveItem", "LeaderLib_Commands_RemoveItem")
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
        Ext.PostMessageToServer("LeaderLib_Helpers_SetRotation", Ext.JsonStringify({
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

---Get the distance between two Vector3 points.
---@param pos1 number[]|string
---@param pos2 number[]|string
---@return number
function GameHelpers.Math.GetDistance(pos1, pos2)
    local x,y,z = 0,0,0
    local tx,ty,tz = 0,0,0
    if type(pos1) == "table" then
        x,y,z = table.unpack(pos1)
    elseif type(pos2) == "string" then
        x,y,z = TryGetPos(pos1)
    end
    if type(pos2) == "table" then
        tx,ty,tz = table.unpack(pos2)
    elseif type(pos2) == "string" then
        tx,ty,tz = TryGetPos(pos2)
    end
    local diff = {
        x - tx,
        y - ty,
        z - tz
    }
    return math.sqrt((diff[1]^2) + (diff[2]^2) + (diff[3]^2))
end

---Get the directional vector between two Vector3 points.
---@param obj1 EsvCharacter|EsvItem
---@param obj2 EsvCharacter|EsvItem
---@return number[]
function GameHelpers.Math.GetDirectionalVectorBetweenObjects(obj1, obj2, reverse)
    local vec = Classes.Vector3
    local a = vec(table.unpack(obj1.WorldPos))
    local b = vec(table.unpack(obj2.WorldPos))
    a:Sub(b)
    
    if getmetatable(obj2) == "esv::Character" then
        ---@type Quaternion
        local angle = Classes.Quaternion(obj2.Stats.Rotation[7], obj2.Stats.Rotation[8], obj2.Stats.Rotation[9], 1)
        a:Rotate(angle)
    end

    a:Normalize()
    if not reverse then
        return {a:Unpack()}
    else
        return {-a.x,-a.y,-a.z}
    end
end

---Get the directional vector between two Vector3 points.
---@param pos1 number[]|string
---@param pos2 number[]|string
---@return number[]
function GameHelpers.Math.GetDirectionVector(pos1, pos2, reverse)
    local vec = Classes.Vector3
    local x,y,z = 0,0,0
    local x2,y2,z2 = 0,0,0
    if type(pos1) == "table" then
        x,y,z = table.unpack(pos1)
    elseif type(pos2) == "string" then
        x,y,z = TryGetPos(pos1)
    end
    if type(pos2) == "table" then
        x2,y2,z2 = table.unpack(pos2)
    elseif type(pos2) == "string" then
        x2,y2,z2 = TryGetPos(pos2)
    end
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

function GameHelpers.Math.GetPosition(obj, unpack, fallback)
    local t = type(obj)
    if t == "table" then
        if #obj >= 3 then
            return unpack and table.unpack(obj) or obj
        end
        for k,v in pairs(obj) do
            if type(k) == "string" and string.find(k, "Pos") then
                return unpack and table.unpack(v) or v
            end
        end
    elseif t == "userdata" and obj.WorldPos then
        return unpack and table.unpack(obj.WorldPos) or obj.WorldPos
    end
    if unpack and fallback and type(fallback) == "table" then
        return table.unpack(fallback)
    end
    return fallback
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