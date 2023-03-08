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
			CharacterTransformAppearanceToWithEquipmentSet(character, transformTarget, equipmentSet, false)
		else
			CharacterTransformAppearanceTo(character, transformTarget, 1, 1)
		end
		SetStoryEvent(character, "ClearPeaceReturn")
		CharacterSetReactionPriority(character, "StateManager", 0)
		CharacterSetReactionPriority(character, "ResetInternalState", 0)
		CharacterSetReactionPriority(character, "ReturnToPeacePosition", 0)
		CharacterSetReactionPriority(character, "CowerIfNeutralSeeCombat", 0)
		SetTag(character, "LeaderLib_TemporaryCharacter")
		SetTag(character, "LLWEAPONEX_MasteryTestCharacter")
		SetTag(character, "NO_ARMOR_REGEN")
		SetFaction(character, "Good NPC")
	end

	Utils.SetupCharacter = SetupCharacter

	---@param pos number[]|nil
	---@param equipmentSet string|nil
	---@return EsvCharacter
	function Utils.CreateCharacterFromHost(pos, equipmentSet)
		local host = Ext.Entity.GetCharacter(CharacterGetHostCharacter())
		local pos = pos or GameHelpers.Math.ExtendPositionWithForwardDirection(host, 10)
		local character = TemporaryCharacterCreateAtPosition(pos[1], pos[2], pos[3], host.RootTemplate.Id, 0)
		SetupCharacter(character, host.MyGuid, equipmentSet)
		SetTag(character, "LeaderLib_TemporaryCharacter")
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
		local host = GameHelpers.GetCharacter(CharacterGetHostCharacter(), "EsvCharacter")
		local startingPos = params.Position or {GameHelpers.Grid.GetValidPositionInRadius(GameHelpers.Math.ExtendPositionWithForwardDirection(host, params.AutoPositionStartDistance), 6.0)}

		local totalCharacters = math.max(0, params.TotalCharacters or 1)
		local characters = {}
		local userTemplate = params.UserTemplate or Testing.Vars.DefaultCharacterTemplate or GameHelpers.GetTemplate(host) --[[@as string]]
		for i=1,totalCharacters do
			local pos = params.CharacterPositions[i] or startingPos
			local x,y,z = table.unpack(pos)
			local character = StringHelpers.GetUUID(TemporaryCharacterCreateAtPosition(x, y, z, userTemplate, 0))
			NRD_CharacterSetPermanentBoostInt(character, "Accuracy", 200)
			CharacterSetCustomName(character, "Test User1")
			SetupCharacter(character, host.MyGuid, params.EquipmentSet)
			--TeleportToRandomPosition(character, 2.0, "")
			SetFaction(character, params.CharacterFaction or "PVP_1")
			characters[#characters+1] = character
		end

		local totalDummies = math.max(0, params.TotalDummies or 1)

		local dummies = {}
		local dummyTemplate = params.DummyTemplate or _GetDummyTemplate() --[[@as string]]
		local dummyStartingPos = GameHelpers.Math.ExtendPositionWithDirectionalVector(startingPos, GameHelpers.Math.GetDirectionalVector(host), 6.0)
		for i=1,totalDummies do
			local pos = params.DummyPositions[i] or dummyStartingPos
			local x,y,z = table.unpack(pos)
			local dummy = StringHelpers.GetUUID(TemporaryCharacterCreateAtPosition(x, y, z, dummyTemplate, 0))
			NRD_CharacterSetPermanentBoostInt(dummy, "Dodge", -200)

			--PlayEffect(dummy, "RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_01", "")
			SetTag(dummy, "LeaderLib_TemporaryCharacter")
			SetTag(dummy, "NO_ARMOR_REGEN")
			if Ext.Mod.IsModLoaded(Data.ModID.TrainingDummy) then
				SetVarObject(dummy, "LLDUMMY_Owner", host.MyGuid)
				Osi.LLDUMMY_LevelUpTrainingDummy(dummy)
			else
				CharacterLevelUpTo(dummy, host.Stats.Level)
			end
			SetFaction(dummy, params.DummyFaction or "PVP_3")
			--TeleportToRandomPosition(dummy, 1.0, "")
			dummies[#dummies+1] = dummy
		end

		local cleanup = function ()
			for _,v in pairs(characters) do
				if ObjectExists(v) == 1 then
					RemoveTemporaryCharacter(v)
				end
			end
			for _,v in pairs(dummies) do
				if ObjectExists(v) == 1 then
					if Ext.Mod.IsModLoaded(Data.ModID.TrainingDummy) then
						SetStoryEvent(v, "LLDUMMY_TrainingDummy_DieNow")
					else
						RemoveTemporaryCharacter(v)
					end
				end
			end
		end
		Events.BeforeLuaReset:Subscribe(function (e)
			cleanup()
		end)
		Timer.StartOneshot("", 60000, cleanup)
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
			SetVarFixedString(charGUID, "Test_Skill", opts.Skill)
		end
		if opts.IgnoreHasSkill ~= nil then
			SetVarInteger(charGUID, "Test_IgnoreHasSkill", opts.IgnoreHasSkill == true and 1 or 0)
		end
		if opts.Position1 then
			SetVarFloat3(charGUID, "Test_SkillPos1", table.unpack(opts.Position1))
		end
		if opts.Position2 then
			SetVarFloat3(charGUID, "Test_SkillPos2", table.unpack(opts.Position2))
		end
		if opts.SecondTargetCharacter then
			SetVarFixedString(charGUID, "Test_SkillCharacterTarget2", GameHelpers.GetUUID(opts.SecondTargetCharacter))
		end
		if opts.SecondTargetItem then
			SetVarFixedString(charGUID, "Test_SkillItemTarget2", GameHelpers.GetUUID(opts.SecondTargetItem))
		end
		if opts.SkillItem then
			SetVarFixedString(charGUID, "Test_SkillItem", GameHelpers.GetUUID(opts.SkillItem))
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
		SetStoryEvent(character.MyGuid, "LeaderLib_Testing_ResetVariables")
		SetVarFixedString(character.MyGuid, "Test_Skill", skill[1])
		SetVarFixedString(character.MyGuid, "Test_SkillItem", item.MyGuid)
		_ApplyOpts(character.MyGuid, opts)

		local t = type(target)
		if t == "table" then
			assert(_IsVec3(target) == true, "Target table is not a valid vector3 position.")
			local x,y,z = table.unpack(target)
			SetVarFloat3(character.MyGuid, "Test_SkillPos1", x, y, z)
			CharacterSetReactionPriority(character.MyGuid, "LeaderLib_Testing_UseSkillOnPosition", 9999)
		else
			target = GameHelpers.TryGetObject(target)
			assert(target ~= nil, "Failed to get target")
			if GameHelpers.Ext.ObjectIsCharacter(target) then
				SetVarFixedString(character.MyGuid, "Test_SkillCharacterTarget1", target.MyGuid)
				CharacterSetReactionPriority(character.MyGuid, "LeaderLib_Testing_UseSkillOnCharacter", 9999)
			elseif GameHelpers.Ext.ObjectIsItem(target) then
				SetVarFixedString(character.MyGuid, "Test_SkillItemTarget1", target.MyGuid)
				CharacterSetReactionPriority(character.MyGuid, "LeaderLib_Testing_UseSkillOnItem", 9999)
			else
				error("Target is not a valid character or item", 2)
			end
		end
	end
end