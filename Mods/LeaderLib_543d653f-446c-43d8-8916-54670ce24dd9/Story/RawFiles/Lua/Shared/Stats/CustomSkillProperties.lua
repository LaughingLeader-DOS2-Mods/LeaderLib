if CustomSkillProperties == nil then
	---@type table<string,CustomSkillProperty>
	CustomSkillProperties = {}
end

---@param attacker EsvCharacter
---@param skill StatEntrySkillData
local function ShouldUseTargetPositionForForce(attacker, skill)
	local skillTargetDist = 0
	if skill.SkillType == "Shout" or skill.SkillType == "Quake" then
		skillTargetDist = skill.AreaRadius
	elseif skill.SkillType == "Cone" or skill.SkillType == "Zone" then
		skillTargetDist = skill.Range
	else
		skillTargetDist = skill.TargetRadius or 0
	end
	local attackerDist = GameHelpers.Character.GetWeaponRange(attacker, false)
	local isRangedSkill = skillTargetDist > attackerDist or skill.Requirement == "RangedWeapon" or skill.Requirement == "RifleWeapon"
	if skill.SkillType == "Target" and skill.IsMelee == "Yes" then
		return false
	end
	return isRangedSkill
end

---@type CustomSkillProperty
CustomSkillProperties.SafeForce = {
	GetDescription = function(prop)
		local chance = prop.Arg1
		local distance = GameHelpers.Math.Round(math.floor(prop.Arg2/6), 1)
		local useTargetForPosition = true
		if not StringHelpers.IsNullOrWhitespace(prop.Arg3) then
			useTargetForPosition = StringHelpers.Equals(prop.Arg3, "true", true, true) ~= true
		end
		
		local fromText = useTargetForPosition and LocalizedText.SkillTooltip.FromTarget.Value or LocalizedText.SkillTooltip.FromSelf.Value
		if distance >= 0 then
			if chance >= 1 then
				return LocalizedText.SkillTooltip.SafeForce:ReplacePlaceholders(distance, fromText)
			else
				chance = Ext.Round(chance * 100)
				return LocalizedText.SkillTooltip.SafeForceRandom:ReplacePlaceholders(distance, fromText, chance)
			end
		else
			if chance >= 1 then
				return LocalizedText.SkillTooltip.SafeForce_Negative:ReplacePlaceholders(math.abs(distance), fromText)
			else
				chance = Ext.Round(chance * 100)
				return LocalizedText.SkillTooltip.SafeForceRandom_Negative:ReplacePlaceholders(math.abs(distance), fromText, chance)
			end
		end
	end,
	ExecuteOnPosition = function(prop, attacker, position, areaRadius, isFromItem, skill, hit)
		local chance = prop.Arg1
		local distance = math.floor(prop.Arg2/6)
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local x,y,z = table.unpack(position)
			--local characters = Ext.GetCharactersAroundPosition(x,y,z, areaRadius)
			local characters = {}
			for i,v in pairs(Ext.GetAllCharacters()) do
				if v ~= attacker.MyGuid and GetDistanceToPosition(v, x,y,z) <= areaRadius then
					characters[#characters+1] = v
				end
			end
			local startPos = attacker.WorldPos
			local useTargetForPosition = true
			if not StringHelpers.IsNullOrWhitespace(prop.Arg3) then
				useTargetForPosition = StringHelpers.Equals(prop.Arg3, "true", true, true) ~= true
			end
			for i,v in pairs(characters) do
				local target = Ext.GetCharacter(v)
				if useTargetForPosition then
					startPos = target.WorldPos
				end
				GameHelpers.ForceMoveObject(attacker, target, distance, skill and skill.Name or nil, startPos)
				ApplyStatus(target.MyGuid, "LEADERLIB_FORCE_APPLIED", 0.0, 0, attacker.MyGuid)
			end
		end
	end,
	ExecuteOnTarget = function(prop, attacker, target, position, isFromItem, skill, hit)
		if attacker.MyGuid ~= target.MyGuid then
			local chance = prop.Arg1
			local distance = math.floor(prop.Arg2/6)
			if chance >= 1.0 or Ext.Random(0,1) <= chance then
				local startPos = attacker.WorldPos
				local useTargetForPosition = true
				if not StringHelpers.IsNullOrWhitespace(prop.Arg3) then
					useTargetForPosition = StringHelpers.Equals(prop.Arg3, "true", true, true) ~= true
				end
				if useTargetForPosition then
					startPos = target.WorldPos
				end
				GameHelpers.ForceMoveObject(attacker, target, distance, skill and skill.Name or nil, startPos)
				ApplyStatus(target.MyGuid, "LEADERLIB_FORCE_APPLIED", 0.0, 0, attacker.MyGuid)
			end
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
		Timer.StartOneshot("", 600, function()
			tping[attacker.MyGuid] = nil
			-- PlayEffectAtPosition("RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_02", table.unpack(attacker.WorldPos))
			-- TeleportToPosition(attacker.MyGuid, x, y, z, "", 0, 1)
			-- PlayEffectAtPosition("RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_02", x, y, z)
			CharacterMoveToPosition(attacker.MyGuid, x, y, z, 1, "")
			--NRD_CreateGameObjectMove(attacker.MyGuid, x, y, z, "", attacker.MyGuid)
			PrintDebug("TeleportSelf.ExecuteOnPosition", attacker.MyGuid, x, y, z, "from", table.unpack(attacker.WorldPos))
			Timer.StartOneshot("MoveDone", 1500, function()
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
	PrintDebug("Context", Common.JsonStringify(prop.Context))
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