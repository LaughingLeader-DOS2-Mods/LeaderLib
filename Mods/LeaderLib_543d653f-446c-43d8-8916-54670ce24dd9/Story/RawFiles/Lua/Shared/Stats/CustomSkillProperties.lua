if CustomSkillProperties == nil then
	---@type table<string,CustomSkillProperty>
	CustomSkillProperties = {}
end

---@type CustomSkillProperty
CustomSkillProperties.SafeForce = {
	GetDescription = function(prop)
		local chance = prop.Arg1
		local distance = math.floor(prop.Arg2/6)
		if chance >= 1 then
			return LocalizedText.SkillTooltip.SafeForce:ReplacePlaceholders(GameHelpers.Math.Round(distance, 1))
		else
			chance = Ext.Round(chance * 100)
			return LocalizedText.SkillTooltip.SafeForceRandom:ReplacePlaceholders(GameHelpers.Math.Round(distance, 1), chance)
		end
	end,
	ExecuteOnPosition = function(prop, attacker, position, areaRadius, isFromItem, skill, hit)
		local chance = prop.Arg1
		local distance = math.floor(prop.Arg2/6)
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local x,y,z = table.unpack(position)
			for i,v in pairs(Ext.GetCharactersAroundPosition(x,y,z, areaRadius)) do
				GameHelpers.ForceMoveObject(attacker, Ext.GetGameObject(v), distance)
			end
		end
	end,
	ExecuteOnTarget = function(prop, attacker, target, position, isFromItem, skill, hit)
		local chance = prop.Arg1
		local distance = math.floor(prop.Arg2/6)
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			GameHelpers.ForceMoveObject(attacker, target, distance)
		end
	end
}

local tping = {}
local function tpSelf(attacker, position, areaRadius)
	local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(position, math.max(3, areaRadius))
	if not tping[attacker.MyGuid] then
		tping[attacker.MyGuid] = true
		ApplyStatus(attacker.MyGuid, "ETHEREAL_SOLES", 6.0, 1, attacker.MyGuid)
		ApplyStatus(attacker.MyGuid, "LEADERLIB_COMBAT_MOVE", 6.0, 1, attacker.MyGuid)
		local ap = attacker.Stats.CurrentAP
		StartOneshotTimer("", 600, function()
			tping[attacker.MyGuid] = nil
			-- PlayEffectAtPosition("RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_02", table.unpack(attacker.WorldPos))
			-- TeleportToPosition(attacker.MyGuid, x, y, z, "", 0, 1)
			-- PlayEffectAtPosition("RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_02", x, y, z)
			CharacterMoveToPosition(attacker.MyGuid, x, y, z, 1, "")
			--NRD_CreateGameObjectMove(attacker.MyGuid, x, y, z, "", attacker.MyGuid)
			print("TeleportSelf.ExecuteOnPosition", attacker.MyGuid, x, y, z, "from", table.unpack(attacker.WorldPos))
			StartOneshotTimer("MoveDone", 1500, function()
				if attacker.Stats.CurrentAP ~= ap then
					attacker.Stats.CurrentAP = ap
					CharacterAddActionPoints(attacker.MyGuid, 0)
				end
				RemoveStatus(attacker.MyGuid, "ETHEREAL_SOLES")
				RemoveStatus(attacker.MyGuid, "LEADERLIB_COMBAT_MOVE")
			end)
		end)
	end
end

---@param object EsvCharacter|EsvItem|EsvGameObject
---@param position number[]
---@param areaRadius number
---@param skill StatEntrySkillData
---@param prop StatPropertyExtender
local function MoveToTarget(object, position, areaRadius, skill, prop)
	local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(position, math.max(3, areaRadius))
	print("Context", Ext.JsonStringify(prop.Context))
	--if not Common.TableHasValue(prop.Context, "Target") then
	if ObjectIsCharacter(object.MyGuid) == 1 then
		if not PersistentVars.SkillPropertiesAction.MoveToTarget[object.MyGuid] then
			PersistentVars.SkillPropertiesAction.MoveToTarget[object.MyGuid] = {
				AP = object.Stats.CurrentAP,
				Pos = {x,y,z}
			}
			ApplyStatus(object.MyGuid, "LEADERLIB_COMBAT_MOVE", -1.0, 1, object.MyGuid)
			StartTimer("LeaderLib_SkillProperties_MoveToTargetStart", 250, object.MyGuid)
			--object.Floating = true
			-- local status = Ext.PrepareStatus(object.MyGuid, "LEADERLIB_COMBAT_MOVE", 6.0)
			-- status.StatusSourceHandle = object.Handle
			-- status.TargetHandle = object.Handle
			-- status.TargetPos = object.WorldPos
			-- status.KeepAlive = true
			-- status.RequestDeleteAtTurnEnd = true
			-- status.StatsMultiplier = 2.0
			-- Ext.ApplyStatus(status)
			
			--CharacterMoveToPosition(object.MyGuid, x, y, z, 1, "LeaderLib_SkillProperties_MoveToTargetDone")
			--Osi.ProcCharacterMoveToPosition(object.MyGuid, x, y, z, 1, "LeaderLib_SkillProperties_MoveToTargetDone")
		end
	else
		PersistentVars.SkillPropertiesAction.MoveToTarget[object.MyGuid] = -1
		ItemMoveToPosition(object.MyGuid, x, y, z, 12.0, 24.0, "LeaderLib_SkillProperties_MoveToTargetDone", 0)
	end
end

CustomSkillProperties.MoveToTarget = {
	GetDescription = function(prop)
		return LocalizedText.SkillTooltip.MoveToTarget.Value
	end,
	ExecuteOnPosition = function(prop, attacker, position, areaRadius, isFromItem, skill, hit)
		MoveToTarget(attacker, position, math.max(areaRadius, 3), skill, prop)
	end,
	ExecuteOnTarget = function(prop, attacker, target, position, isFromItem, skill, hit)
		MoveToTarget(attacker, position, math.max(skill.AreaRadius or 3, 3), skill, prop)
	end
}

for k,v in pairs(CustomSkillProperties) do
	Ext.RegisterSkillProperty(k, v)
end

if Ext.IsServer() then
	Timer.RegisterListener("LeaderLib_SkillProperties_MoveToTargetStart", function(event, uuid)
		local data = PersistentVars.SkillPropertiesAction.MoveToTarget[uuid]
		if data then
			local x,y,z = table.unpack(data.Pos)
			Osi.ProcCharacterMoveToPosition(uuid, x, y, z, 1, "LeaderLib_SkillProperties_MoveToTargetDone")
		end
	end)

	function SkillPropertiesActionDone(action, uuid)
		if action == "MoveToTarget" then
			RemoveStatus(uuid, "LEADERLIB_COMBAT_MOVE")
			local data = PersistentVars.SkillPropertiesAction.MoveToTarget[uuid]
			if data then
				local restoreAP = data.AP
				if data.AP and data.AP > 0 then
					local character = Ext.GetCharacter(uuid)
					--character.Floating = false
					if character.Stats.CurrentAP ~= data.AP then
						character.Stats.CurrentAP = data.AP
						CharacterAddActionPoints(uuid, 0)
					end
				end
			end
			PersistentVars.SkillPropertiesAction.MoveToTarget[uuid] = nil
		end
	end

	if Vars.DebugMode then
		RegisterListener("BeforeLuaReset", function()
			PersistentVars.SkillPropertiesAction.MoveToTarget = {}
		end)
	end
end