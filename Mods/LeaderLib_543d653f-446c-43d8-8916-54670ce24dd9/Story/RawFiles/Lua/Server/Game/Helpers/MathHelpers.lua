function GameHelpers.Math.GetForwardPosition(source, distanceMult)
    local x,y,z = GetPosition(source)
    local character = Ext.GetCharacter(source)
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
    end
    return {x,y,z}
end

function GameHelpers.Math.ExtendPositionWithForwardDirection(source, distanceMult, x,y,z)
    local character = Ext.GetCharacter(source)
    if character ~= nil then
        if distanceMult == nil then
            distanceMult = 1.0
        end
        local forwardVector = {
            -character.Stats.Rotation[7] * distanceMult,
            0,---rot[8] * distanceMult, -- Rot Y is never used since objects can't look "up"
            -character.Stats.Rotation[9] * distanceMult,
        }
        x = x + forwardVector[1]
        z = z + forwardVector[3]
    end
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