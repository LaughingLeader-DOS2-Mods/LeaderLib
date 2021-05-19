if GameHelpers.Math == nil then
	GameHelpers.Math = {}
end

---Get a position derived from a character's forward facing direction.
---@param char string
---@param distanceMult number
---@param fromPosition number[]
function GameHelpers.Math.GetForwardPosition(char, distanceMult, fromPosition)
    ---@type EsvCharacter
    local character = char
    if type(char) == "string" then
        character = Ext.GetCharacter(char)
    end
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

function GameHelpers.Math.ExtendPositionWithForwardDirection(source, distanceMult, x,y,z, forwardVector)
    local character = nil
    if type(source) == "string" then
        character = Ext.GetCharacter(source)
    else
        character = source
    end
    if character ~= nil then
        if not x and not y and not z then
            x,y,z = table.unpack(character.WorldPos)
        end
    end
    if distanceMult == nil then
        distanceMult = 1.0
    end
    if forwardVector then
        x = x + (-forwardVector[7] * distanceMult)
        z = z + (-forwardVector[9] * distanceMult)
    elseif (character and character.Stats) then
        forwardVector = {
            -character.Stats.Rotation[7] * distanceMult,
            0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
            -character.Stats.Rotation[9] * distanceMult,
        }
        x = x + forwardVector[1]
        z = z + forwardVector[3]
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
        x,y,z = GetPosition(pos1)
    end
    if type(pos2) == "table" then
        tx,ty,tz = table.unpack(pos2)
    elseif type(pos2) == "string" then
        tx,ty,tz = GetPosition(pos2)
    end
    local diff = {
        x - tx,
        y - ty,
        z - tz
    }
    return math.sqrt((diff[1]^2) + (diff[2]^2) + (diff[3]^2))
end

---Get the directional vector between two Vector3 points.
---@param pos1 number[]|string
---@param pos2 number[]|string
---@return number[]
function GameHelpers.Math.GetDirectionVector(pos1, pos2)
    local x,y,z = 0,0,0
    local x2,y2,z2 = 0,0,0
    if type(pos1) == "table" then
        x,y,z = table.unpack(pos1)
    elseif type(pos2) == "string" then
        x,y,z = GetPosition(pos1)
    end
    if type(pos2) == "table" then
        x2,y2,z2 = table.unpack(pos2)
    elseif type(pos2) == "string" then
        x2,y2,z2 = GetPosition(pos2)
    end
    return {
        x - x2,
        y - y2,
        z - z2
    }
end