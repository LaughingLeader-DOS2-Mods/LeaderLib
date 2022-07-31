local _ISCLIENT = Ext.IsClient()

if CustomSkillProperties == nil then
	---@type table<string,CustomSkillProperty>
	CustomSkillProperties = {}
end

if GameHelpers.Skill == nil then
	GameHelpers.Skill = {}
end

local function _EMPTY_FUNC() end

--- @param id string
--- @param getDesc fun(property:StatsPropertyExtender):string|nil
--- @param onPos fun(property:StatsPropertyExtender, attacker: EsvCharacter|EsvItem, position: vec3, areaRadius: number, isFromItem: boolean, skill: StatEntrySkillData|nil, hit: StatsHitDamageInfo|nil)
--- @param onTarget fun(property:StatsPropertyExtender, attacker: EsvCharacter|EsvItem, target: EsvCharacter|EsvItem, position: vec3, isFromItem: boolean, skill: StatEntrySkillData|nil, hit: StatsHitDamageInfo|nil)
function GameHelpers.Skill.CreateSkillProperty(id, getDesc, onPos, onTarget)
	local property = {
		GetDescription = getDesc or _EMPTY_FUNC,
		ExecuteOnPosition = onPos or _EMPTY_FUNC,
		ExecuteOnTarget = onTarget or _EMPTY_FUNC,
	}
	CustomSkillProperties[id] = property
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

GameHelpers.Skill.CreateSkillProperty("SafeForce", function (property)
	local chance = property.Arg1
		local distance = GameHelpers.Math.Round(math.floor(property.Arg2/6), 1)
		local useTargetForPosition = true
		if not StringHelpers.IsNullOrWhitespace(property.Arg3) then
			useTargetForPosition = StringHelpers.Equals(property.Arg3, "true", true, true) ~= true
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
end, function (property, attacker, position, areaRadius, isFromItem, skill, hit)
	local chance = property.Arg1
		local distance = math.floor(property.Arg2/6)
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
			if not StringHelpers.IsNullOrWhitespace(property.Arg3) then
				useTargetForPosition = StringHelpers.Equals(property.Arg3, "true", true, true) ~= true
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
end, function (property, attacker, target, position, isFromItem, skill, hit)
	if attacker.MyGuid ~= target.MyGuid then
		local chance = property.Arg1
		local distance = math.floor(property.Arg2/6)
		if chance >= 1.0 or Ext.Random(0,1) <= chance then
			local startPos = attacker.WorldPos
			local useTargetForPosition = true
			if not StringHelpers.IsNullOrWhitespace(property.Arg3) then
				useTargetForPosition = StringHelpers.Equals(property.Arg3, "true", true, true) ~= true
			end
			if useTargetForPosition then
				startPos = target.WorldPos
			end
			GameHelpers.ForceMoveObject(attacker, target, distance, skill and skill.Name or nil, startPos)
			ApplyStatus(target.MyGuid, "LEADERLIB_FORCE_APPLIED", 0.0, 0, attacker.MyGuid)
		end
	end
end)

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
---@param property StatPropertyExtender
local function MoveToTarget(object, position, areaRadius, skill, property)
	local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(position, math.max(3, areaRadius))
	PrintDebug("Context", Common.JsonStringify(property.Context))
	--if not Common.TableHasValue(property.Context, "Target") then
	if ObjectIsCharacter(object.MyGuid) == 1 then
		if not PersistentVars.SkillPropertiesAction.MoveToTarget[object.MyGuid] then
			PersistentVars.SkillPropertiesAction.MoveToTarget[object.MyGuid] = {
				AP = object.Stats.CurrentAP,
				Pos = {x,y,z}
			}
			ApplyStatus(object.MyGuid, "LEADERLIB_COMBAT_MOVE", -1.0, 1, object.MyGuid)
			Timer.Start("LeaderLib_SkillProperties_MoveToTargetStart", 250, {UUID=object.MyGuid})
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

GameHelpers.Skill.CreateSkillProperty("MoveToTarget", function (property)
	return LocalizedText.SkillTooltip.MoveToTarget.Value
end, function (property, attacker, position, areaRadius, isFromItem, skill, hit)
	MoveToTarget(attacker, position, math.max(areaRadius, 3), skill, property)
end, function (property, attacker, target, position, isFromItem, skill, hit)
	MoveToTarget(attacker, position, math.max(skill.AreaRadius or 3, 3), skill, property)
end)

GameHelpers.Skill.CreateSkillProperty("ToggleStatus", function (property)
	local statusDisplayName = ""
	local statusId = property.Arg3
	local duration = property.Arg2
	local turns = duration > 0 and Ext.Round(duration / 6.0) or duration
	if not StringHelpers.IsNullOrWhitespace(statusId) then
		if Data.EngineStatus[statusId] then
			local engineStatusName = LocalizedText.Status[statusId]
			if engineStatusName then
				statusDisplayName = engineStatusName.Value
			end
		elseif GameHelpers.Stats.Exists(statusId, "StatusData") then
			statusDisplayName = GameHelpers.GetStringKeyText(Ext.Stats.GetAttribute(statusId, "DisplayName"), Ext.Stats.GetAttribute(statusId, "DisplayNameRef"))
		end
	end
	if not StringHelpers.IsNullOrWhitespace(statusDisplayName) then
		if statusId == "SPIRIT_VISION" then
			local settings = SettingsManager.GetMod(ModuleUUID, false, false)
			if settings.Global:FlagEquals("LeaderLib_PermanentSpiritVisionEnabled", false) then
				local overrideProp = Vars.Overrides.SPIRIT_VISION_PROPERTY
				if overrideProp and property.Arg1 == overrideProp.Arg1 and property.Arg2 == overrideProp.Arg2 and property.Arg4 == overrideProp.Arg4 then
					turns = overrideProp.Arg5 > 0 and Ext.Round(overrideProp.Arg5 / 6.0) or overrideProp.Arg5
					if turns > 0 then
						return LocalizedText.Tooltip.ExtraPropertiesWithTurns:ReplacePlaceholders(statusDisplayName, "", "", turns)
					else
						return LocalizedText.Tooltip.ExtraPropertiesPermanent:ReplacePlaceholders(statusDisplayName, "", "")
					end
				end
			end
		end
		if property.Arg2 > 0 then
			return LocalizedText.SkillTooltip.ToggleStatusDuration:ReplacePlaceholders(statusDisplayName, turns)
		else
			return LocalizedText.SkillTooltip.ToggleStatus:ReplacePlaceholders(statusDisplayName)
		end
	end
end, function (property, attacker, position, areaRadius, isFromItem, skill, hit)
	local statusId = property.Arg3
	local duration = property.Arg2
	local isPermanent = property.Arg4 > -1
	if skill.Name == "Shout_SpiritVision" and statusId == "SPIRIT_VISION" then
		local settings = SettingsManager.GetMod(ModuleUUID, false, false)
		if settings.Global:FlagEquals("LeaderLib_PermanentSpiritVisionEnabled", false) then
			-- isPermanent = false
			-- duration = 60
			return
		end
	end
	if not StringHelpers.IsNullOrWhitespace(statusId) then
		local targetRadius = false
		local targetSelf = false
		for _,v in pairs(property.Context) do
			if v == "Self" then
				targetSelf = true
			elseif v == "AoE" then
				targetRadius = true
			end
		end

		local applyStatus = not isPermanent and GameHelpers.Status.Apply or function(target, id, duration, force, source) 
			StatusManager.ApplyPermanentStatus(target, id, source)
		end
		local removeStatus = not isPermanent and GameHelpers.Status.Remove or StatusManager.RemovePermanentStatus

		if targetSelf then
			local GUID = attacker.MyGuid
			local timerName = string.format("LeaderLib_ToggleStatus_%s%s", statusId, GUID)
			local shouldRemove = attacker:GetStatus(statusId)
			Timer.Cancel(timerName)
			Timer.StartOneshot(timerName, 20, function (e)
				local target = GameHelpers.TryGetObject(GUID)
				if target then
					if shouldRemove then
						removeStatus(target, statusId)
					else
						applyStatus(target, statusId, duration, true, attacker)
					end
				end
			end)
		end
		if targetRadius then
			local canTargetCharacters = skill.CanTargetCharacters
			local canTargetItems = skill.CanTargetItems
			local targetType = canTargetCharacters and "Character"
			if canTargetCharacters and canTargetItems then
				targetType = "All"
			elseif canTargetCharacters then
				targetType = "Character"
			elseif canTargetItems then
				targetType = "Item"
			end
			for target in GameHelpers.Grid.GetNearbyObjects(position, {Radius=areaRadius, Type=targetType}) do
				if target.MyGuid ~= attacker.MyGuid then
					local shouldRemove = target:GetStatus(statusId)
					local GUID = target.MyGuid
					local SOURCE_GUID = attacker.MyGuid
					local timerName = string.format("LeaderLib_ToggleStatus_%s%s", statusId, GUID)
					Timer.Cancel(timerName)
					Timer.StartOneshot(timerName, 20, function (e)
						local target = GameHelpers.TryGetObject(GUID)
						if target then
							if shouldRemove then
								removeStatus(target, statusId)
							else
								applyStatus(target, statusId, duration, true, SOURCE_GUID)
							end
						end
					end)
				end
			end
		end
	end
end, function (property, attacker, target, position, isFromItem, skill, hit)
	local statusId = property.Arg3
	if not StringHelpers.IsNullOrWhitespace(statusId) then
		local duration = property.Arg2

		if skill.Name == "Shout_SpiritVision" and statusId == "SPIRIT_VISION" then
			local settings = SettingsManager.GetMod(ModuleUUID, false, false)
			if settings.Global:FlagEquals("LeaderLib_PermanentSpiritVisionEnabled", false) then
				--Previous duration is stored in Arg5
				duration = property.Arg5 or 60
				local GUID = target.MyGuid
				Timer.Cancel("LeaderLib_SetSpiritVision", GUID)
				Timer.StartObjectTimer("LeaderLib_SetSpiritVision", GUID, 20, {Duration = duration})
				return
			end
		end

		local isPermanent = property.Arg4 > -1
		local applyStatus = not isPermanent and GameHelpers.Status.Apply or function(target, id, duration, force, source) 
			StatusManager.ApplyPermanentStatus(target, id, source) 
		end
		local removeStatus = not isPermanent and GameHelpers.Status.Remove or StatusManager.RemovePermanentStatus

		local shouldRemove = target:GetStatus(statusId)

		local SOURCE_GUID = attacker.MyGuid
		local GUID = target.MyGuid
		local timerName = string.format("LeaderLib_ToggleStatus_%s%s", statusId, GUID)
		Timer.Cancel(timerName)
		Timer.StartOneshot(timerName, 20, function (e)
			local target = GameHelpers.TryGetObject(GUID)
			if target then
				if shouldRemove then
					removeStatus(target, statusId)
				else
					applyStatus(target, statusId, duration, true, SOURCE_GUID)
				end
			end
		end)
	end
end)

if not _ISCLIENT then
	Ext.Events.OnExecutePropertyDataOnTarget:Subscribe(function (e)
		local prop = e.Property
		local propType = CustomSkillProperties[prop.Action]
		if propType ~= nil and propType.ExecuteOnTarget ~= nil then
			propType.ExecuteOnTarget(e.Property, e.Attacker, e.Target, e.ImpactOrigin, e.IsFromItem, e.Skill, e.Hit)
		end
	end)
	
	Ext.Events.OnExecutePropertyDataOnPosition:Subscribe(function (e)
		local prop = e.Property
		local propType = CustomSkillProperties[prop.Action]
		if propType ~= nil and propType.ExecuteOnPosition ~= nil then
			propType.ExecuteOnPosition(e.Property, e.Attacker, e.Position, e.AreaRadius, e.IsFromItem, e.Skill, e.Hit)
		end
	end)
	
	Timer.Subscribe("LeaderLib_SetSpiritVision", function(e)
		if e.Data.UUID then
			GameHelpers.Status.Apply(e.Data.UUID, "SPIRIT_VISION", e.Data.Duration or 60, true, e.Data.UUID)
		end
	end)

	Timer.Subscribe("LeaderLib_SkillProperties_MoveToTargetStart", function(e)
		local data = PersistentVars.SkillPropertiesAction.MoveToTarget[e.Data.UUID]
		if data then
			local x,y,z = table.unpack(data.Pos)
			Osi.ProcCharacterMoveToPosition(e.Data.UUID, x, y, z, 1, "LeaderLib_SkillProperties_MoveToTargetDone")
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
		Events.BeforeLuaReset:Subscribe(function()
			PersistentVars.SkillPropertiesAction.MoveToTarget = {}
		end)
	end
else
	Ext.Events.SkillGetPropertyDescription:Subscribe(function (e)
		local propType = CustomSkillProperties[e.Property.Action]
		if propType ~= nil and propType.GetDescription ~= nil then
			local desc = propType.GetDescription(e.Property)
			if desc ~= nil then
				e.Description = desc
			end
		end
	end)
end