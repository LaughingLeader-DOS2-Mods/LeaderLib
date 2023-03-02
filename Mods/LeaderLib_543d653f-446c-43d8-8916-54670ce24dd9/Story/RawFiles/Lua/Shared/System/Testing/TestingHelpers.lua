local _ISCLIENT = Ext.IsClient()

if Testing == nil then
	Testing = {}
end

---@class LeaderLibTestingSystemUtilities
local Utils = {}
Testing.Utils = Utils

if not _ISCLIENT then
	---@return string
	local function _GetDummyTemplate()
		if Ext.Mod.IsModLoaded(Data.ModID.TrainingDummy) then
			return "985acfab-b221-4221-8263-fa00797e8883"
		end
		return "680e6e58-98f4-4684-9a84-d5a190f855d5"
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

	---@class LeaderLibTestingSystemUtilities.CreateTemporaryCharacterAndDummyParams
	---@field Position number[]|nil
	---@field EquipmentSet string|nil
	---@field UserTemplate string|nil The root template to use for the non-dummy character.
	---@field DummyTemplate string|nil The root template to use for the dummy character.
	---@field CharacterFaction string|nil Defaults to PVP_1
	---@field DummyFaction string|nil Defaults to PVP_3
	---@field TotalCharacters integer|nil Defaults to 1
	---@field TotalDummies integer|nil Defaults to 0

	---Create a test character based on the host, and a target dummy.
	---@param params LeaderLibTestingSystemUtilities.CreateTemporaryCharacterAndDummyParams|nil
	---@return Guid|Guid[] characters # If the TotalCharacters are 1, this will be the first GUID, instead of a table.
	---@return Guid|Guid[] dummies # If the TotalDummies are 1, this will be the first GUID, instead of a table.
	---@return function cleanup
	function Utils.CreateTestCharacters(params)
		params = params or {}
		--pos, equipmentSet, userTemplate, dummyTemplate, setEnemy, totalDummies
		local host = GameHelpers.GetCharacter(CharacterGetHostCharacter(), "EsvCharacter")
		local startingPos = params.Position or {GameHelpers.Grid.GetValidPositionInRadius(GameHelpers.Math.ExtendPositionWithForwardDirection(host, 6), 6.0)}

		local totalCharacters = math.max(0, params.TotalCharacters or 1)
		local characters = {}
		local userTemplate = params.UserTemplate or GameHelpers.GetTemplate(host) --[[@as string]]
		for i=1,totalCharacters do
			local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(startingPos, 6.0)
			local character = StringHelpers.GetUUID(TemporaryCharacterCreateAtPosition(x, y, z, userTemplate, 0))
			NRD_CharacterSetPermanentBoostInt(character, "Accuracy", 200)
			CharacterSetCustomName(character, "Test User1")
			SetupCharacter(character, host.MyGuid, params.EquipmentSet)
			--TeleportToRandomPosition(character, 2.0, "")
			SetFaction(character, params.CharacterFaction or "PVP_1")
			characters[#characters+1] = character
		end

		local totalDummies = math.max(0, params.TotalDummies or 0)

		local dummies = {}
		local dummyTemplate = params.DummyTemplate or _GetDummyTemplate() --[[@as string]]
		local dummyStartingPos = GameHelpers.Math.ExtendPositionWithDirectionalVector(startingPos, GameHelpers.Math.GetDirectionalVector(host), 6.0)
		for i=1,totalDummies do
			local x,y,z = GameHelpers.Grid.GetValidPositionInRadius(dummyStartingPos, 6.0)
			local dummy = StringHelpers.GetUUID(TemporaryCharacterCreateAtPosition(x, y, z, dummyTemplate, 0))
			NRD_CharacterSetPermanentBoostInt(dummy, "Dodge", -100)

			PlayEffect(dummy, "RS3_FX_GP_ScriptedEvent_Teleport_GenericSmoke_01", "")
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
end