local _ISCLIENT = Ext.IsClient()

if Testing == nil then
	Testing = {}
end

---@class LeaderLibTestingSystemUtilities
local Utils = {}
Testing.Utils = Utils

Testing.Vars = {
	DefaultCharacterTemplate = "2ac80a2a-8326-4131-a03c-53906927f935",
	DefaultDummyTemplate = "680e6e58-98f4-4684-9a84-d5a190f855d5",
	TrainingDummyTemplate = "985acfab-b221-4221-8263-fa00797e8883",
}

if not _ISCLIENT then
	---@return string
	local function _GetDummyTemplate()
		if Ext.Mod.IsModLoaded(Data.ModID.TrainingDummy) then
			return Testing.Vars.TrainingDummyTemplate
		end
		return Testing.Vars.DefaultDummyTemplate
	end

	---@param character Guid
	---@param transformTarget Guid
	---@param equipmentSet string|nil
	local function SetupCharacter(character, transformTarget, equipmentSet)
		if equipmentSet then
			Osi.CharacterTransformAppearanceToWithEquipmentSet(character, transformTarget, equipmentSet, 0)
		else
			Osi.CharacterTransformAppearanceTo(character, transformTarget, 1, 1)
		end
		Osi.SetStoryEvent(character, "ClearPeaceReturn")
		Osi.CharacterSetReactionPriority(character, "StateManager", 0)
		Osi.CharacterSetReactionPriority(character, "ResetInternalState", 0)
		Osi.CharacterSetReactionPriority(character, "ReturnToPeacePosition", 0)
		Osi.CharacterSetReactionPriority(character, "CowerIfNeutralSeeCombat", 0)
		Osi.SetTag(character, "LeaderLib_TemporaryCharacter")
		Osi.SetTag(character, "LLWEAPONEX_MasteryTestCharacter")
		Osi.SetTag(character, "NO_ARMOR_REGEN")
		Osi.SetFaction(character, "Good NPC")
	end

	Utils.SetupCharacter = SetupCharacter

	---@param pos number[]|nil
	---@param equipmentSet string|nil
	---@return EsvCharacter
	function Utils.CreateCharacterFromHost(pos, equipmentSet)
		local host = Ext.Entity.GetCharacter(Osi.CharacterGetHostCharacter())
		local pos = pos or GameHelpers.Math.ExtendPositionWithForwardDirection(host, 10)
		local character = Osi.TemporaryCharacterCreateAtPosition(pos[1], pos[2], pos[3], host.RootTemplate.Id, 0)
		SetupCharacter(character, host.MyGuid, equipmentSet)
		Osi.SetTag(character, "LeaderLib_TemporaryCharacter")
		return Ext.Entity.GetCharacter(character)
	end

	---@class LeaderLibTestingSystemUtilities_CreateTemporaryCharacterAndDummyParams
	---@field Position vec3 Starting position.
	---@field DummyPositions vec3[] Optional positions to use for all dummies.
	---@field CharacterPositions vec3[] Optional positions to use for all characters.
	---@field EquipmentSet string
	---@field UserTemplate string The root template to use for the non-dummy character.
	---@field DummyTemplate string The root template to use for the dummy character.
	---@field CharacterFaction string Defaults to PVP_1
	---@field DummyFaction string Defaults to PVP_3
	---@field TotalCharacters integer Defaults to 1
	---@field TotalDummies integer Defaults to 0
	---@field AutoPositionStartDistance number Used when getting a defualt starting position from this host. This is the distance extended from the host's forward facing direction.
	---@field Test LuaTest The test to automatically set the Cleanup function on.

	local _DefaultParams = {
		CharacterPositions = {},
		DummyPositions = {},
		AutoPositionStartDistance = 8,
	}

	---Create a test character based on the host, and a target dummy.
	---@param params LeaderLibTestingSystemUtilities_CreateTemporaryCharacterAndDummyParams|nil
	---@return Guid|Guid[] characters # If the TotalCharacters are 1, this will be the first GUID, instead of a table.
	---@return Guid|Guid[] dummies # If the TotalDummies are 1, this will be the first GUID, instead of a table.
	---@return function cleanup
	function Utils.CreateTestCharacters(params)
		params = params or {}
		setmetatable(params, {__index = _DefaultParams})
		--pos, equipmentSet, userTemplate, dummyTemplate, setEnemy, totalDummies
		local host = GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter(), "EsvCharacter")
		local startingPos = params.Position or {GameHelpers.Grid.GetValidPositionInRadius(GameHelpers.Math.ExtendPositionWithForwardDirection(host, params.AutoPositionStartDistance), 6.0)}

		local totalCharacters = math.max(0, params.TotalCharacters or 1)
		local characters = {}
		local userTemplate = params.UserTemplate or Testing.Vars.DefaultCharacterTemplate or GameHelpers.GetTemplate(host) --[[@as string]]
		for i=1,totalCharacters do
			local pos = params.CharacterPositions[i] or startingPos
			local x,y,z = table.unpack(pos)
			local character = StringHelpers.GetUUID(Osi.TemporaryCharacterCreateAtPosition(x, y, z, userTemplate, 0))
			Osi.SetTag(character, "NO_ARMOR_REGEN")
			Osi.NRD_CharacterSetPermanentBoostInt(character, "Accuracy", 200)
			Osi.CharacterSetCustomName(character, "Test User1")
			SetupCharacter(character, host.MyGuid, params.EquipmentSet)
			--TeleportToRandomPosition(character, 2.0, "")
			Osi.SetFaction(character, params.CharacterFaction or "PVP_1")
			characters[#characters+1] = character
		end

		local totalDummies = math.max(0, params.TotalDummies or 1)

		local dummies = {}
		local dummyTemplate = params.DummyTemplate or _GetDummyTemplate() --[[@as string]]
		local dummyStartingPos = GameHelpers.Math.ExtendPositionWithDirectionalVector(startingPos, GameHelpers.Math.GetDirectionalVector(host), 6.0)
		for i=1,totalDummies do
			local pos = params.DummyPositions[i] or dummyStartingPos
			local x,y,z = table.unpack(pos)
			local dummy = StringHelpers.GetUUID(Osi.TemporaryCharacterCreateAtPosition(x, y, z, dummyTemplate, 0))
			Osi.NRD_CharacterSetPermanentBoostInt(dummy, "Dodge", -200)

			--PlayEffect(dummy, "RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_01", "")
			Osi.SetTag(dummy, "LeaderLib_TemporaryCharacter")
			Osi.SetTag(dummy, "NO_ARMOR_REGEN")
			if Ext.Mod.IsModLoaded(Data.ModID.TrainingDummy) then
				Osi.SetVarObject(dummy, "LLDUMMY_Owner", host.MyGuid)
				Osi.LLDUMMY_LevelUpTrainingDummy(dummy)
			else
				Osi.CharacterLevelUpTo(dummy, host.Stats.Level)
			end
			Osi.SetFaction(dummy, params.DummyFaction or "PVP_3")
			--TeleportToRandomPosition(dummy, 1.0, "")
			dummies[#dummies+1] = dummy
		end

		local cleanup = function ()
			for _,v in pairs(characters) do
				if Osi.ObjectExists(v) == 1 then
					GameHelpers.Character.RemoveTemporyCharacter(v)
				end
			end
			for _,v in pairs(dummies) do
				if Osi.ObjectExists(v) == 1 then
					if Ext.Mod.IsModLoaded(Data.ModID.TrainingDummy) then
						local netid = GameHelpers.GetNetID(v)
						Events.TemporaryCharacterRemoved:Invoke({CharacterGUID = v, NetID=netid})
						Osi.SetStoryEvent(v, "LLDUMMY_TrainingDummy_DieNow")
					else
						GameHelpers.Character.RemoveTemporyCharacter(v)
					end
				end
			end
		end
		Events.BeforeLuaReset:Subscribe(function (e)
			cleanup()
		end)
		Timer.StartOneshot("", 60000, cleanup)
		if params.Test then
			params.Test.Cleanup = cleanup
		end
		return totalCharacters > 1 and characters or characters[1],totalDummies > 1 and dummies or dummies[1],cleanup
	end

	local function _IsVec3(tbl)
		for i=1,3 do
			if type(tbl) ~= "number" then
				return false
			end
		end
		return tbl[4] == nil
	end

	---@class Testing_Utils_UseItemOnTargetOptions
	---@field Skill FixedString
	---@field SkillItem ItemParam
	---@field Position1 vec3
	---@field Position2 vec3
	---@field SecondTargetCharacter CharacterParam
	---@field SecondTargetItem ItemParam
	---@field IgnoreHasSkill boolean

	---@param charGUID Guid
	---@param opts Testing_Utils_UseItemOnTargetOptions
	local function _ApplyOpts(charGUID, opts)
		if opts.Skill then
			Osi.SetVarFixedString(charGUID, "Test_Skill", opts.Skill)
		end
		if opts.IgnoreHasSkill ~= nil then
			Osi.SetVarInteger(charGUID, "Test_IgnoreHasSkill", opts.IgnoreHasSkill == true and 1 or 0)
		end
		if opts.Position1 then
			Osi.SetVarFloat3(charGUID, "Test_SkillPos1", table.unpack(opts.Position1))
		end
		if opts.Position2 then
			Osi.SetVarFloat3(charGUID, "Test_SkillPos2", table.unpack(opts.Position2))
		end
		if opts.SecondTargetCharacter then
			Osi.SetVarFixedString(charGUID, "Test_SkillCharacterTarget2", GameHelpers.GetUUID(opts.SecondTargetCharacter))
		end
		if opts.SecondTargetItem then
			Osi.SetVarFixedString(charGUID, "Test_SkillItemTarget2", GameHelpers.GetUUID(opts.SecondTargetItem))
		end
		if opts.SkillItem then
			Osi.SetVarFixedString(charGUID, "Test_SkillItem", GameHelpers.GetUUID(opts.SkillItem))
		end
	end

	---@param character CharacterParam This should be a character with the LeaderLib_TestCharacter script, as it has reactions to make an NPC use an item on a target.
	---@param target ObjectParam|vec3
	---@param item ItemParam And item with a cast skill use action.
	---@param opts? Testing_Utils_UseItemOnTargetOptions
	function Utils.UseItemSkillOnTarget(character, target, item, opts)
		opts = opts or {}
		character = GameHelpers.GetCharacter(character, "EsvCharacter")
		item = GameHelpers.GetItem(item, "EsvItem")

		assert(character ~= nil, "Failed to get character")
		assert(item ~= nil, "Failed to get item")

		local skill,data = GameHelpers.Item.GetUseActionSkills(item)

		assert(data.CastsSkill == true, "Item does not have a skill cast action")
		Osi.SetStoryEvent(character.MyGuid, "LeaderLib_Testing_ResetVariables")
		Osi.SetVarFixedString(character.MyGuid, "Test_Skill", skill[1])
		Osi.SetVarFixedString(character.MyGuid, "Test_SkillItem", item.MyGuid)
		_ApplyOpts(character.MyGuid, opts)

		local t = type(target)
		if t == "table" then
			assert(_IsVec3(target) == true, "Target table is not a valid vector3 position.")
			local x,y,z = table.unpack(target)
			Osi.SetVarFloat3(character.MyGuid, "Test_SkillPos1", x, y, z)
			Osi.CharacterSetReactionPriority(character.MyGuid, "LeaderLib_Testing_UseSkillOnPosition", 9999)
		else
			target = GameHelpers.TryGetObject(target)
			assert(target ~= nil, "Failed to get target")
			if GameHelpers.Ext.ObjectIsCharacter(target) then
				Osi.SetVarFixedString(character.MyGuid, "Test_SkillCharacterTarget1", target.MyGuid)
				Osi.CharacterSetReactionPriority(character.MyGuid, "LeaderLib_Testing_UseSkillOnCharacter", 9999)
			elseif GameHelpers.Ext.ObjectIsItem(target) then
				Osi.SetVarFixedString(character.MyGuid, "Test_SkillItemTarget1", target.MyGuid)
				Osi.CharacterSetReactionPriority(character.MyGuid, "LeaderLib_Testing_UseSkillOnItem", 9999)
			else
				error("Target is not a valid character or item", 2)
			end
		end
	end
end


---@class Testing_Utils_GetPositionsInLineParams
---@field Target ObjectParam|vec3 Defaults to a position extendef from the host if not set. The line position is offset from the target's forward position, if it is an object.
---@field StartDistance number The distance to apply to the host if Target isn't set, when determining the start position.
---@field Distance number The total distance of the line.
---@field Total integer
---@field DirectionalVector vec3
local _GetPositionsInLineDefaultParams = {
	StartDistance = 6,
	Distance = 12,
	Total = 4,
}
setmetatable(_GetPositionsInLineDefaultParams, {
	__index = function (tbl,k)
		local startDistance = rawget(tbl, "StartDistance") or 6
		if k == "Target" then
			return GameHelpers.Math.ExtendPositionWithForwardDirection(GameHelpers.Character.GetHost(), startDistance)
		elseif k == "DirectionalVector" then
			return GameHelpers.Math.GetDirectionalVector(GameHelpers.Character.GetHost())
		end
	end
})

---@param opts? Testing_Utils_GetPositionsInLineParams
---@return vec3[] positions
---@return vec3 centerPosition
function Utils.GetPositionsInLine(opts)
	local options = TableHelpers.SetDefaultOptions(opts, _GetPositionsInLineDefaultParams)
	local startPos = options.Target
	if type(startPos) ~= "table" then
		startPos = GameHelpers.Math.ExtendPositionWithForwardDirection(options.Target, options.StartDistance)
	end
	local dir = options.DirectionalVector
	local total = options.Total
	local positions = {}
	local distPer = options.Distance / total
	local dist = 0
	for i=1,total do
		local pos = GameHelpers.Math.ExtendPositionWithDirectionalVector(startPos, dir, dist, false)
		positions[i] = pos
		dist = dist + distPer
	end
	return positions,startPos
end


---@class Testing_Utils_GetPositionsInCircleParams
---@field Target ObjectParam|vec3 Defaults to a position extendef from the host if not set. The circle position is offset from the target's forward position, if it is an object.
---@field StartDistance number
---@field Radius number
---@field Total integer
local _GetPositionsInCircleDefaultParams = {
	StartDistance = 12,
	Radius = 6,
	Total = 5,
}
setmetatable(_GetPositionsInCircleDefaultParams, {
	__index = function (tbl,k)
		local startDistance = rawget(tbl, "StartDistance") or 12
		if k == "Target" then
			return GameHelpers.Math.ExtendPositionWithForwardDirection(GameHelpers.Character.GetHost(), startDistance)
		end
	end
})

---@param opts? Testing_Utils_GetPositionsInCircleParams
---@return vec3[] positions
---@return vec3 centerPosition
function Utils.GetPositionsInCircle(opts)
	local options = TableHelpers.SetDefaultOptions(opts, _GetPositionsInCircleDefaultParams)
	local startPos = options.Target
	if type(startPos) ~= "table" then
		startPos = GameHelpers.Math.ExtendPositionWithForwardDirection(options.Target, options.StartDistance)
	end
	local total = options.Total
	local positions = {}
	local anglePer = 360 / total
	local angle = 0
	local radius = options.Radius
	local clampRadius = radius+0.2
	for i=1,total do
		local pos = GameHelpers.Grid.GetValidPositionTableInRadius(GameHelpers.Math.GetPositionWithAngle(startPos, angle, radius), clampRadius)
		positions[i] = pos
		angle = angle + anglePer
	end
	return positions,startPos
end