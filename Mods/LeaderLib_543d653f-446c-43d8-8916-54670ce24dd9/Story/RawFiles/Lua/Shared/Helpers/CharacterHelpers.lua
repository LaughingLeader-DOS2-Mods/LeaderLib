if GameHelpers.Character == nil then
	GameHelpers.Character = {}
end

local _type = type
local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()

---@param character CharacterParam
---@return boolean
function GameHelpers.Character.IsPlayer(character)
	if not character then
		return false
	end
	local t = _type(character)
	if t == "userdata" and GameHelpers.Ext.ObjectIsItem(character) then
		return false
	end
	if not _ISCLIENT then
		if not _OSIRIS() then
			if t == "string" or t == "number" then
				character = GameHelpers.GetCharacter(character)
			end
			if character and (character.IsPlayer or character.IsGameMaster) then
				return true
			end
		else
			if t == "userdata" then
				if Osi.ObjectIsCharacter(character.MyGuid) == 1 and (character.IsPlayer or character.IsGameMaster) then
					return true
				end
				character = character.MyGuid
			end
			if _type(character) == "string" then
				return Osi.CharacterIsPlayer(character) == 1 or Osi.CharacterGameMaster(character) == 1 or GameHelpers.DB.HasUUID("DB_IsPlayer", character)
			end
		end
	else
		if t ~= "userdata" then
			character = GameHelpers.GetCharacter(character)
		end
		---@type EclCharacter
		local clientCharacter = character
		if clientCharacter then
			if Client.Character.NetID == clientCharacter.NetID then
				if Client.Character.IsPlayer or Client.Character.IsGameMaster then
					return true
				end
			end
			return clientCharacter.PlayerCustomData ~= nil
		end
	end
	return false
end

---Returns true if the character IsGameMaster or IsPossessed
---@param character CharacterParam
---@param ignorePossessed? boolean
---@return boolean
function GameHelpers.Character.IsGameMaster(character, ignorePossessed)
	if not character then
		return false
	end
	local t = _type(character)
	if t == "userdata" and GameHelpers.Ext.ObjectIsItem(character) then
		return false
	end
	character = GameHelpers.GetCharacter(character)
	if not character then
		return false
	end
	if not _ISCLIENT then
		return character.IsGameMaster or (not ignorePossessed and character.IsPossessed)
	else
		for uuid,data in pairs(SharedData.CharacterData) do
			if data.NetID == character.NetID and (data.IsGameMaster or (not ignorePossessed and data.IsPossessed)) then
				return true
			end
		end
		local gm = GameHelpers.Client.GetGameMaster()
		if gm and gm.NetID == character.NetID then
			return true
		end
	end
	return false
end

---@param character CharacterParam
---@return boolean
function GameHelpers.Character.IsPlayerOrPartyMember(character)
	if GameHelpers.Character.IsPlayer(character) then
		return true
	end
	if not _ISCLIENT and _OSIRIS() then
		local GUID = GameHelpers.GetUUID(character)
		return not StringHelpers.IsNullOrEmpty(GUID) and Osi.CharacterIsPartyMember(GUID) == 1
	end
	return false
end

---@param character CharacterParam
function GameHelpers.Character.IsOrigin(character)
	if not _ISCLIENT and _OSIRIS() then
		local GUID = GameHelpers.GetUUID(character)
		if not GUID then return false end
		return GameHelpers.DB.HasUUID("DB_Origins", GUID)
	else
		character = GameHelpers.GetCharacter(character)
		if _type(character) == "userdata" then
			return character.PlayerCustomData and not StringHelpers.IsNullOrWhitespace(character.PlayerCustomData.OriginName)
		end
	end
	return false
end

---@param character CharacterParam
function GameHelpers.Character.IsInCharacterCreation(character)
	if not _ISCLIENT and _OSIRIS() then
		local GUID = GameHelpers.GetUUID(character)
		if not GUID then return false end
		if GameHelpers.DB.HasUUID("DB_Illusionist", GUID, 2, 1) then
			return true
		end
		if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
			return GameHelpers.DB.HasUUID("DB_AssignedDummyForUser", GUID, 2, 2)
		end
	else
		---@type EclCharacter
		local player = GameHelpers.GetCharacter(character)
		if _type(player) == "userdata" then
			local currentCC = GameHelpers.Client.GetCharacterCreationCharacter()
			if currentCC and currentCC.NetID == player.NetID then
				return true
			end
		end
	end
	return false
end

---@param character CharacterParam
function GameHelpers.Character.IsSummonOrPartyFollower(character)
	if not _ISCLIENT then
		if _type(character) == "userdata" then
			return character.Summon or character.PartyFollower
		elseif _type(character) == "string" then
			return Osi.CharacterIsSummon(character) == 1 or Osi.CharacterIsPartyFollower(character) == 1
		end
	else
		if _type(character) ~= "userdata" then
			character = GameHelpers.GetCharacter(character)
		end
		if character then
			return character.HasOwner or character.PartyFollower
		end
	end
	return false
end

---@param character CharacterParam
---@param partyMember? CharacterParam
function GameHelpers.Character.IsAllyOfParty(character, partyMember)
	if not _ISCLIENT and _OSIRIS() then
		character = GameHelpers.GetUUID(character)
		if not character or Osi.ObjectIsCharacter(character) == 0 then return false end
		if partyMember then
			return Osi.CharacterIsAlly(character, GameHelpers.GetUUID(partyMember)) == 1
		else
			for player in GameHelpers.Character.GetPlayers(false) do
				if Osi.CharacterIsAlly(character, player.MyGuid) == 1 then
					return true
				end
			end
		end

	end
	return false
end

---@param character CharacterParam
---@param partyMember? CharacterParam
function GameHelpers.Character.IsNeutralToParty(character, partyMember)
	if not _ISCLIENT and _OSIRIS() then
		local GUID = GameHelpers.GetUUID(character)
		if not GUID then return false end
		if partyMember then
			return Osi.CharacterIsNeutral(character, GameHelpers.GetUUID(partyMember)) == 1
		else
			for player in GameHelpers.Character.GetPlayers(false) do
				if Osi.CharacterIsNeutral(GUID, player.MyGuid) == 1 then
					return true
				end
			end
		end
	end
	return false
end

---@param character CharacterParam
---@param partyMember? CharacterParam
function GameHelpers.Character.IsEnemyOfParty(character, partyMember)
	if not _ISCLIENT and _OSIRIS() then
		local GUID = GameHelpers.GetUUID(character)
		if not GUID then return false end
		if partyMember then
			return Osi.CharacterIsEnemy(character, GameHelpers.GetUUID(partyMember)) == 1
		else
			for player in GameHelpers.Character.GetPlayers(false) do
				if Osi.CharacterIsEnemy(GUID, player.MyGuid) == 1 then
					return true
				end
			end
		end
	end
	return false
end

---@param char1 CharacterParam
---@param char2 CharacterParam
function GameHelpers.Character.IsEnemy(char1, char2)
	if not _ISCLIENT then
		if _OSIRIS() then
			local a = GameHelpers.GetUUID(char1)
			local b = GameHelpers.GetUUID(char2)
			if not a or not b then return false end
			local relation = Osi.CharacterGetRelationToCharacter(a,b)
			return Osi.CharacterIsEnemy(a,b) == 1 or (relation and relation <= 0)
		else
			local alignment = Ext.Entity.GetAlignmentManager()
			local a = GameHelpers.GetCharacter(char1)
			local b = GameHelpers.GetCharacter(char2)
			if alignment and a and b then
				a = a.Handle
				b = b.Handle
				return alignment:IsPermanentEnemy(a,b) or alignment:IsTemporaryEnemy(a,b)
			end
		end
	end
	return false
end

---@param character CharacterParam
---@return boolean isInCombat
function GameHelpers.Character.IsInCombat(character)
	if not _ISCLIENT and _OSIRIS() then
		local GUID = GameHelpers.GetUUID(character)
		if not GUID then return false end
		if Osi.CharacterIsInCombat(GUID) == 1 then
			return true
		elseif GameHelpers.DB.HasUUID("DB_CombatCharacters", GUID, 2, 1) then
			return true
		end
	else
		character = GameHelpers.GetCharacter(character)
		return character and character:GetStatus("COMBAT") ~= nil
	end
	return false
end

---Checks if the character is alive, on stage, and if CanFight and CanJoinCombat are true.
---@param character CharacterParam
---@return boolean combatEnabled
function GameHelpers.Character.CanEnterCombat(character)
	character = GameHelpers.GetCharacter(character)
	if character and character.CurrentTemplate and character.CurrentTemplate.CombatTemplate then
		return not character.Dead and not character.OffStage and character.CurrentTemplate.CombatTemplate.CanFight and character.CurrentTemplate.CombatTemplate.CanJoinCombat
	end
	return false
end

---@param character CharacterParam
---@param skill string|string[]
---@return boolean
function GameHelpers.Character.HasSkill(character, skill)
	character = GameHelpers.GetCharacter(character)
	if not character then
		return false
	end
	local t = _type(skill)
	if character.SkillManager then
		local _skills = character.SkillManager.Skills
		if t == "string" then
			return _skills[skill] ~= nil
		elseif t == "table" then
			for i=1,#skill do
				if _skills[skill[i]] ~= nil then
					return true
				end
			end
		end
	else
		if not _ISCLIENT and _OSIRIS() then
			if t == "string" then
				if _OSIRIS() then
					return Osi.CharacterHasSkill(character.MyGuid, skill) == 1
				else
					for _,v in pairs(character:GetSkills()) do
						if v == skill then
							return true
						end
					end
				end
			elseif t == "table" then
				if _OSIRIS() then
					for i=1,#skill do
						if Osi.CharacterHasSkill(character.MyGuid, skill[i]) == 1 then
							return true
						end
					end
				else
					local characterSkills = character:GetSkills()
					for _,v in pairs(characterSkills) do
						for i=1,#skill do
							if v == skill[i] then
								return true
							end
						end
					end
				end
			end
		end
	end
	return false
end

---Get all enemies within range.
---@param target CharacterParam The character to use for the enemy check / central point.
---@param radius? number Defaults to 2.0
---@return number total
function GameHelpers.Character.GetTotalEnemiesInRange(target,radius)
	if not _ISCLIENT then
		radius = radius or 2.0
		local character = GameHelpers.GetCharacter(target)
		if not character then
			return 0
		end
		local pos = character.WorldPos
		local totalEnemies = 0
		for _,v in pairs(Ext.Entity.GetAllCharacterGuids(SharedData.RegionData.Current)) do
			if GameHelpers.Math.GetDistance(v, pos) <= radius 
			and not GameHelpers.ObjectIsDead(v) and GameHelpers.Character.IsEnemy(character, v) then
				totalEnemies = totalEnemies + 1
			end
		end
		return totalEnemies
	end
	-- TODO Client-side relation detection isn't a thing yet
	return 0
end

---@return integer
function GameHelpers.Character.GetHighestPlayerLevel()
	local level = 1
	if not _ISCLIENT then
		for player in GameHelpers.Character.GetPlayers(false) do
			if player.Stats.Level > level then
				level = player.Stats.Level
			end
		end
	else
		for profile,data in pairs(SharedData.CharacterData) do
			local character = data:GetCharacter()
			if character and character.Stats and character.Stats.Level > level then
				level = character.Stats.Level
			end
		end
	end
	return level
end

---@param character CharacterParam
---@return boolean
function GameHelpers.Character.IsUndead(character)
	if _type(character) ~= "userdata" then
		character = GameHelpers.GetCharacter(character)
	end
	if character and character.HasTag then
		if character:HasTag("UNDEAD") or character.Stats.TALENT_Zombie then
			return true
		end
	end
	return false
end

---Returns true if the character is dead, or if it has the DYING status.
---@param character? CharacterParam
---@return boolean
function GameHelpers.Character.IsDeadOrDying(character)
	local character = GameHelpers.GetCharacter(character)
	if character then
		if character.Dead or character:GetStatus("DYING") then
			return true
		end
	end
	return false
end

---Returns the base visual race of the character, if it's one of the base 4 player races.  
---This works by first checking the character's visual resource, to see if it's a base hero skeleton.  
---Then it checks GameHelpers.Character.GetRace, before finally looking at the root template name, if nothing is found.  
---Use `GameHelpers.Character.GetRace` if you want to just find whatever the race is.  
---@param character CharacterParam
---@return BaseRace|nil
function GameHelpers.Character.GetBaseRace(character)
	character = GameHelpers.GetCharacter(character)
	if character then
		local visualRace = Data.HeroBaseSkeletonToRace[character.RootTemplate.VisualTemplate]
		if visualRace then
			return visualRace
		end
		--Fallback
		local rootTemplate = GameHelpers.GetTemplate(character, true)
		for raceId,raceData in pairs(Vars.RaceData) do
			if character:HasTag(raceData.Tag) or character:HasTag(raceData.BaseTag)
			or (character.PlayerCustomData and character.PlayerCustomData.Race == raceId)
			or (rootTemplate and string.find(rootTemplate.Name, raceId))
			then
				return raceId
			end
		end
	end
	return nil
end

---Get the character's race, if any.  
---@param character CharacterParam
---@return BaseRace|string
function GameHelpers.Character.GetRace(character)
	character = GameHelpers.GetCharacter(character)
	assert(GameHelpers.Ext.ObjectIsCharacter(character), "target parameter must be a character UUID, NetID, or Esv/EclCharacter")
	if character.PlayerCustomData and not StringHelpers.IsNullOrWhitespace(character.PlayerCustomData.Race) then
		return character.PlayerCustomData.Race
	end
	return GameHelpers.Character.GetBaseRace(character) or "None"
end

---Returns true if the character is using a dwarf/elf/lizard/human base skeleton.
---@param character CharacterParam
---@return boolean
function GameHelpers.Character.IsBaseSkeleton(character)
	character = GameHelpers.GetCharacter(character)
	if character and character.CurrentTemplate then
		local visualRace = Data.HeroBaseSkeletonToRace[character.CurrentTemplate.VisualTemplate]
		if visualRace then
			return true
		end
	end
	return false
end

---Returns true if the character is one of the regular humanoid races (i.e. it's using a dwarf/elf/lizard/human base skeleton), or if it has a base race tag.
---@param character CharacterParam
---@return boolean
function GameHelpers.Character.IsHumanoid(character)
	character = GameHelpers.GetCharacter(character)
	if GameHelpers.Character.IsBaseSkeleton(character) then
		return true
	end
	if character and character.HasTag then
		for raceId,raceData in pairs(Vars.RaceData) do
			if character:HasTag(raceData.Tag) 
			or character:HasTag(raceData.BaseTag)
			or string.find(GameHelpers.GetTemplate(character), raceId)
			or (character.PlayerCustomData and character.PlayerCustomData.Race == raceId) then
				return true
			end
		end
	end
	return false
end

---@param character CharacterParam
---@return boolean
function GameHelpers.Character.GetDisplayName(character)
	if not character then
		return ""
	end
	if _type(character) ~= "userdata" then
		character = GameHelpers.GetCharacter(character)
	end
	if character then
		local name = character.DisplayName
		if not _ISCLIENT and character.CustomDisplayName ~= nil then
			return character.CustomDisplayName
		end
		if StringHelpers.IsNullOrWhitespace(name) or string.find(name, "|", 1, true) then
			if not _ISCLIENT then
				local handle,ref = Osi.CharacterGetDisplayName(character.MyGuid)
				return Ext.L10N.GetTranslatedString(handle, not StringHelpers.IsNullOrWhitespace(name) and name or ref)
			else
				return name
			end
		else
			return name
		end
	end
	return ""
end

---@overload fun():(fun():EsvCharacter|EclCharacter)
---@overload fun(includeSummons:boolean, asTable:boolean):EsvCharacter[]|EclCharacter[]
---@generic T:EsvCharacter|EclCharacter
---@param includeSummons? boolean Include player summons if true.
---@param asTable? boolean if true, a regular table is returned, which needs to be used with pairs/ipairs.
---@param castType `T` The class type to return, for auto-completion, such as "EsvCharacter".
---@return fun():T
function GameHelpers.Character.GetPlayers(includeSummons, asTable, castType)
	local players = {}
	if not _ISCLIENT then
		if SharedData.RegionData.LevelType == LEVELTYPE.GAME and _OSIRIS() then
			for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
				local player = GameHelpers.GetCharacter(db[1])
				if player then
					players[#players+1] = player
					if includeSummons == true then
						local summons = _PV.Summons[player.MyGuid]
						if summons then
							for i,v in pairs(summons) do
								if Osi.ObjectIsCharacter(v) == 1 then
									local summon = GameHelpers.GetCharacter(v)
									if summon then
										players[#players+1] = summon
									end
								end
							end
						end
					end
				end
			end
		else
			local isCC = SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION
			for _,v in pairs(Ext.Entity.GetAllCharacterGuids(SharedData.RegionData.Current)) do
				local character = GameHelpers.GetCharacter(v)
				if character and character.IsPlayer and (not isCC or (isCC and character.CharacterControl)) then
					players[#players+1] = character
				end
			end
		end
		if SharedData.GameMode == GAMEMODE.GAMEMASTER then
			local gm = StringHelpers.GetUUID(Osi.CharacterGetHostCharacter())
			if not StringHelpers.IsNullOrEmpty(gm) then
				gm = GameHelpers.GetCharacter(gm)
				if not Common.TableHasValue(players, gm) then
					players[#players+1] = gm
				end
			end
		end
	else
		for mc in StatusHider.PlayerInfo:GetCharacterMovieClips(not includeSummons) do
			local character = GameHelpers.GetCharacter(Ext.UI.DoubleToHandle(mc.characterHandle))
			if character then
				players[#players+1] = character
			end
		end
	end

	if not asTable then
		local i = 0
		local count = #players
		return function ()
			i = i + 1
			if i <= count then
				return players[i]
			end
		end
	else
		return players
	end
end

---@return EsvCharacter|EclCharacter host
function GameHelpers.Character.GetHost()
	if not _ISCLIENT and _OSIRIS() then
		return GameHelpers.GetCharacter(Osi.CharacterGetHostCharacter())
	else
		for _,v in pairs(SharedData.CharacterData) do
			if v.IsHost then
				return v:GetCharacter()
			end
		end
	end
	return nil
end

---@param includeSummons? boolean
---@return integer
function GameHelpers.Character.GetPartySize(includeSummons)
	local count = 0
	local players = {}
	if not _ISCLIENT then
		for _,db in pairs(Osi.DB_IsPlayer:Get(nil)) do
			local player = GameHelpers.GetCharacter(db[1])
			if player then
				count = count + 1
			end
			if includeSummons == true then
				local summons = _PV.Summons[player.MyGuid]
				if summons then
					for i,v in pairs(summons) do
						if Osi.ObjectIsCharacter(v) == 1 then
							local summon = GameHelpers.GetCharacter(v)
							if summon then
								count = count + 1
							end
						end
					end
				end
			end
		end
	else
		for mc in StatusHider.PlayerInfo:GetCharacterMovieClips(not includeSummons) do
			count = count + 1
		end
	end

	return count
end

---@alias GameHelpers_Character_GetSummonsResultType EsvCharacter|EclCharacter|EsvItem|EclItem

---@overload fun(owner:CharacterParam):fun():EsvCharacter|EclCharacter
---@overload fun(owner:CharacterParam, includeItems:boolean):fun():GameHelpers_Character_GetSummonsResultType
---@overload fun(owner:CharacterParam, includeItems:boolean|nil, asTable:true):fun():GameHelpers_Character_GetSummonsResultType[]
---Gets all the active summons of a character.
---@param owner CharacterParam
---@param includeItems? boolean If on the server-side, item summons can be fetched as well if this is true.
---@param asTable? boolean Return the result as a table, instead of an iterator.
---@param ignoreObjects? table<ComponentHandle|Guid, boolean> Specific Handles to ignore.
---@return fun():GameHelpers_Character_GetSummonsResultType|nil summons
function GameHelpers.Character.GetSummons(owner, includeItems, asTable, ignoreObjects)
	owner = GameHelpers.GetCharacter(owner)

	local summons = {}
	local len = 0
	local ignore = ignoreObjects or {}
	
	if not _ISCLIENT then
		local ownerGUID = GameHelpers.GetUUID(owner)
		local activeSummonsData = _PV.Summons[ownerGUID]
		if activeSummonsData then
			local activeLen = #activeSummonsData
			for i=1,activeLen do
				local summonGUID = activeSummonsData[i]
				if not ignore[summonGUID] and GameHelpers.ObjectExists(summonGUID) then
					local summon = GameHelpers.TryGetObject(summonGUID)
					if summon and (includeItems == true or GameHelpers.Ext.ObjectIsCharacter(summon)) then
						len = len + 1
						summons[len] = summon
					end
				end
			end
		else
			for _,handle in pairs(owner.SummonHandles) do
				if Ext.Utils.IsValidHandle(handle) then
					local summon = GameHelpers.TryGetObject(handle)
					if summon and ignore[summon.MyGuid] and (includeItems == true or GameHelpers.Ext.ObjectIsCharacter(summon)) then
						len = len + 1
						summons[len] = summon
					end
				end
			end
		end
	else
		--SummonHandles is empty on the client-side

		local level = Ext.ClientEntity.GetCurrentLevel()
		if level then
			local levelID = level.LevelDesc.LevelName
			for _,summon in pairs(level.EntityManager.CharacterConversionHelpers.ActivatedCharacters[levelID]) do
				if not ignore[summon.Handle] and summon.HasOwner and summon.OwnerCharacterHandle == owner.Handle then
					len = len + 1
					summons[len] = summon
				end
			end

			if includeItems then
				for _,item in pairs(level.EntityManager.ItemConversionHelpers.ActivatedItems[levelID]) do
					if not ignore[item.Handle] and item.OwnerCharacterHandle == owner.Handle and item:GetStatus("SUMMON") then
						len = len + 1
						summons[len] = item
					end
				end
			end
		end

		--@cast owner EclCharacter
		--@type number
		--[[ local ownerHandle = owner
		if _type(owner) == "userdata" and owner.Handle then
			ownerHandle = Ext.UI.HandleToDouble(owner.Handle)
		end
		--Only summons who are attached to the portrait
		for mc in StatusHider.PlayerInfo:GetSummonMovieClips(ownerHandle) do
			local summon = GameHelpers.GetCharacter(Ext.UI.DoubleToHandle(mc.characterHandle))
			if summon and not ignore[summon.NetID] then
				---@cast summon EclCharacter
				if summon and not ignore[summon.NetID] and (summon.Summon or summon.HasOwner) then
					summons[#summons+1] = summon
				end
			end
		end ]]
	end

	if asTable then
		return summons
	else
		local i = 0
		return function ()
			i = i + 1
			if i <= len then
				return summons[i]
			end
		end
	end
end

---Gets all the active summons.
---@param includeItems? boolean If on the server, item summons can be fetched as well.
---@param asTable? boolean Return the result as a table, instead of an iterator.
---@param ignoreObjects table<NetId|Guid|nil, boolean> Specific MyGuid or NetID values to ignore.
---@return GameHelpers_Character_GetSummonsResultType[]|fun():GameHelpers_Character_GetSummonsResultType summons
function GameHelpers.Character.GetAllSummons(includeItems, asTable, ignoreObjects)
	local summons = {}
	local ignore = ignoreObjects or {}
	
	if not _ISCLIENT then
		-- for _,guid in pairs(Ext.Entity.GetAllCharacterGuids()) do
		-- 	if not ignore[guid] then
		-- 		local summon = GameHelpers.GetCharacter(guid)
		-- 		if summon and summon.Summon and (includeItems == true or GameHelpers.Ext.ObjectIsCharacter(summon)) then
		-- 			summons[#summons+1] = summon
		-- 		end
		-- 	end
		-- end
		for ownerGUID,activeSummonsData in pairs(_PV.Summons) do
			local len = #activeSummonsData
			for i=1,len do
				local summonGUID = activeSummonsData[i]
				if not ignore[summonGUID] and GameHelpers.ObjectExists(summonGUID) then
					local summon = GameHelpers.TryGetObject(summonGUID)
					if summon and (includeItems == true or GameHelpers.Ext.ObjectIsCharacter(summon)) then
						summons[#summons+1] = summon
					end
				end
			end
		end
	else
		for mc in StatusHider.PlayerInfo:GetSummonMovieClips() do
			local summon = GameHelpers.GetCharacter(Ext.UI.DoubleToHandle(mc.characterHandle))
			if summon and not ignore[summon.NetID] and summon.Summon then
				summons[#summons+1] = summon
			end
		end
	end

	if asTable then
		return summons
	else
		local i = 0
		local count = #summons
		return function ()
			i = i + 1
			if i <= count then
				return summons[i]
			end
		end
	end
end

---@param character CharacterParam
---@param asMeters? boolean If true, the range is returned as meters (WeaponRange/100).
---@return number
function GameHelpers.Character.GetWeaponRange(character, asMeters)
	local noWeapon = Ext.Stats.Get("NoWeapon", nil, false)
	local range = noWeapon and noWeapon.WeaponRange or 0
	character = GameHelpers.GetCharacter(character)
	if character then
		if _ISCLIENT then
			local mainhand = character:GetItemBySlot("Weapon")
			local offhand = character:GetItemBySlot("Shield")
			if mainhand then
				range = mainhand.Stats.WeaponRange
			end
			if offhand then
				if offhand.Stats.WeaponRange > range or mainhand == nil then
					range = offhand.Stats.WeaponRange
				end
			end
		else
			local mainhand = GameHelpers.Item.GetItemInSlot(character, "Weapon")
			local offhand = GameHelpers.Item.GetItemInSlot(character, "Shield")
			if mainhand then
				range = mainhand.Stats.WeaponRange
			end
			if offhand then
				if offhand.Stats.WeaponRange > range or mainhand == nil then
					range = offhand.Stats.WeaponRange
				end
			end
		end
	end
	if asMeters then
		return GameHelpers.Math.Round(range/100, 2)
	end
	return range
end

---@param character CharacterParam
---@param target CharacterParam|vec3
---@return boolean
function GameHelpers.Character.IsWithinWeaponRange(character, target)
	local weaponRange = GameHelpers.Character.GetWeaponRange(character, true)
	return GameHelpers.Math.GetDistance(character, target) <= weaponRange
end

---@param character CharacterParam
---@return boolean
function GameHelpers.Character.HasRangedWeapon(character)
	character = GameHelpers.GetCharacter(character)
	if character then
		if character.Stats.MainWeapon and Game.Math.IsRangedWeapon(character.Stats.MainWeapon) then
			return true
		end
		if character.Stats.OffHandWeapon and Game.Math.IsRangedWeapon(character.Stats.OffHandWeapon) then
			return true
		end
	end
	return false
end

---@param character CharacterParam
function GameHelpers.Character.IsUnsheathed(character)
	if not _ISCLIENT and _OSIRIS() then
		character = GameHelpers.GetUUID(character)
		if not character then return false end
		return Osi.HasActiveStatus(character, "UNSHEATHED") == 1 or Osi.CharacterIsInFightMode(character) == 1
	else
		---@type EclCharacter
		local character = GameHelpers.GetCharacter(character)
		if character then
			return character:GetStatus("UNSHEATHED") ~= nil
		end
	end
	return false
end

---Returns true if the character is disabled by a status.
---@param character CharacterParam
---@param checkForLoseControl? boolean
---@param checkForZeroMovement? boolean
---@return boolean
function GameHelpers.Character.IsDisabled(character, checkForLoseControl, checkForZeroMovement)
	if _type(character) == "string" then
		character = GameHelpers.GetCharacter(character)
	end
	if character == nil then
		return false
	end
	if GameHelpers.Status.HasStatusType(character.MyGuid, {"KNOCKED_DOWN", "INCAPACITATED"}) then
		return true
	end
	if checkForLoseControl == true then -- LoseControl on items is a good way to crash
		for _,status in pairs(character:GetStatusObjects()) do
			if status.StatusId == "CHARMED" then
				if GameHelpers.Status.IsFromEnemy(status, character) then
					return true
				end
			end
			if Data.EngineStatus[status.StatusId] ~= true then
				local stat = Ext.Stats.Get(status.StatusId, nil, false)
				if stat and stat.LoseControl == "Yes" then
					if GameHelpers.Status.IsFromEnemy(status, character) then
						return true
					end
				end
			end
		end
	end
	if checkForZeroMovement == true then
		if GameHelpers.GetMovement(character.Stats) <= 0 then
			return true
		end
	end
	return false
end

GameHelpers.Status.IsDisabled = GameHelpers.Character.IsDisabled

---Returns true if the object is sneaking or has an INVISIBLE type status.
---@param character CharacterParam
---@return boolean
function GameHelpers.Character.IsSneakingOrInvisible(character)
	if GameHelpers.Status.IsActive(character, "SNEAKING")
	or GameHelpers.Status.IsActive(character, "INVISIBLE")
	or GameHelpers.Status.HasStatusType(character, "INVISIBLE")
	then
		return true
	end
    return false
end

if not _ISCLIENT then
	Ext.Osiris.NewQuery(GameHelpers.Character.IsSneakingOrInvisible, "LeaderLib_Ext_QRY_IsSneakingOrInvisible", "[in](GUIDSTRING)_Object, [out](INTEGER)_Bool")
end

GameHelpers.Status.IsSneakingOrInvisible = GameHelpers.Character.IsSneakingOrInvisible

---Shortcut for GameHelpers.Surface.HasSurface, using the character's position.
---@param character EsvCharacter|EclCharacter
---@param matchNames string|string[] Surface names to look for.
---@param maxRadius? number
---@param containingName? boolean Look for surfaces containing the name, instead of explicit matching.
---@param onlyLayer? integer Look only on layer 0 (ground) or 1 (clouds).
---@param grid? EocAiGrid
---@return boolean
function GameHelpers.Character.IsInSurface(character, matchNames, maxRadius, containingName, onlyLayer, grid)
	local pos = GameHelpers.Math.GetPosition(character)
	if pos then
		if containingName == nil then
			containingName = true
		end
		return GameHelpers.Surface.HasSurface(pos[1], pos[3], matchNames, maxRadius or 6.0, containingName, onlyLayer, grid)
	end
	return false
end

---Equips an item to its stats Slot using NRD_CharacterEquipItem, and moves any existing item in that slot to the character's inventory.
---@param character CharacterParam
---@param item ItemParam
---@return boolean
function GameHelpers.Character.EquipItem(character, item)
	if not _ISCLIENT then
		local uuid = GameHelpers.GetUUID(character)
		fassert(not StringHelpers.IsNullOrEmpty(uuid) and Osi.ObjectExists(uuid) == 1, "Character (%s) must be a valid UUID or EsvCharacter", character)
		item = GameHelpers.GetItem(item)
		fassert(item ~= nil and not GameHelpers.Item.IsObject(item), "Item (%s) must be a non-object item.", item and item.StatsId or "nil")
		fassert(Osi.ItemIsEquipable(item.MyGuid) == 1, "Item (%s) is not equipable.", item.StatsId)
		if item.Stats.Slot == "Weapon" then
			local mainhand = GameHelpers.Item.GetItemInSlot(uuid, "Weapon")
			local offhand = GameHelpers.Item.GetItemInSlot(uuid, "Shield")
			if item.Stats.IsTwoHanded then
				if mainhand then
					Osi.ItemLockUnEquip(mainhand.MyGuid, 0)
					Osi.ItemToInventory(mainhand.MyGuid, uuid, 1, 0, 0)
				end
				if offhand then
					Osi.ItemLockUnEquip(offhand.MyGuid, 0)
					Osi.ItemToInventory(offhand.MyGuid, uuid, 1, 0, 0)
				end
				Osi.SetOnStage(item.MyGuid, 1)
				Osi.NRD_CharacterEquipItem(uuid, item.MyGuid, "Weapon", 0, 0, 1, 1)
				return true
			else
				if mainhand then
					if not offhand then
						Osi.SetOnStage(item.MyGuid, 1)
						Osi.NRD_CharacterEquipItem(uuid, item.MyGuid, "Shield", 0, 0, 1, 1)
						return true
					else
						Osi.ItemLockUnEquip(mainhand.MyGuid, 0)
						Osi.ItemToInventory(mainhand.MyGuid, uuid, 1, 0, 0)
						Osi.SetOnStage(item.MyGuid, 1)
						Osi.NRD_CharacterEquipItem(uuid, item.MyGuid, "Weapon", 0, 0, 1, 1)
						return true
					end
				else
					Osi.NRD_CharacterEquipItem(uuid, item.MyGuid, "Weapon", 0, 0, 1, 1)
					return true
				end
			end
		elseif item.Stats.Slot == "Shield" then
			local offhand = GameHelpers.Item.GetItemInSlot(uuid, "Shield")
			if offhand then
				Osi.ItemLockUnEquip(offhand.MyGuid, 0)
				Osi.ItemToInventory(offhand.MyGuid, uuid, 1, 0, 0)
			end
			Osi.SetOnStage(item.MyGuid, 1)
			Osi.NRD_CharacterEquipItem(uuid, item.MyGuid, "Shield", 0, 0, 1, 1)
			return true
		else
			local existing = GameHelpers.Item.GetItemInSlot(uuid, item.Stats.Slot)
			if existing then
				Osi.ItemLockUnEquip(existing.MyGuid, 0)
				Osi.ItemToInventory(existing.MyGuid, uuid, 1, 0, 0)
			end
			Osi.SetOnStage(item.MyGuid, 1)
			Osi.NRD_CharacterEquipItem(uuid, item.MyGuid, item.Stats.Slot, 0, 0, 1, 1)
			return true
		end
	end
	return false
end

---@overload fun(character:CharacterParam):fun():EsvItem|EclItem
---Get a table of the character's equipment.
---@param character CharacterParam
---@param asTable? boolean Return the results as a table, instead of an iterator.
---@return EsvItem[]|EclItem[]
function GameHelpers.Character.GetEquipment(character, asTable)
	local char = GameHelpers.GetCharacter(character)
    fassert(char ~= nil, "'%s' is not a valid character", character)
	local equipment = {}
	local items = char:GetInventoryItems()
	-- Equipment is in order from 1-14, but inventory items take up earlier indexes in the table if the equipment panel isn't full
	local itemCount = math.min(#items, 14)
    for i=1,itemCount do
		local item = GameHelpers.GetItem(items[i])
		if item then
			local slot = GameHelpers.Item.GetSlot(item)
			if Data.EquipmentSlots[slot] then
				equipment[#equipment+1] = item
			end
		end
	end
	if not asTable then
		local i = 0
		local count = #equipment
		return function ()
			i = i + 1
			if i <= count then
				return equipment[i]
			end
		end
	else
		return equipment
	end
end

---@class _GameHelpers_Character_GetEquipmentOnEquipStatuses_Entry
---@field Status string
---@field Item EsvItem|EclItem

---Get all the statuses applied by a character's equipment when equipped.
---@param character CharacterParam
---@param inDictionaryForm? boolean Return the results as a statusId,data table.
---@return table<string, _GameHelpers_Character_GetEquipmentOnEquipStatuses_Entry>|_GameHelpers_Character_GetEquipmentOnEquipStatuses_Entry[]
function GameHelpers.Character.GetEquipmentOnEquipStatuses(character, inDictionaryForm)
	local char = GameHelpers.GetCharacter(character)
    fassert(char ~= nil, "'%s' is not a valid character", character)
	local entries = {}
	for item in GameHelpers.Character.GetEquipment(character) do
		local props = GameHelpers.Stats.GetExtraProperties(item.Stats.Name)
		if props and #props > 0 then
			for _,v in pairs(props) do
				if v.Type == "Status" and Common.TableHasValue(v.Context, "SelfOnEquip") then
					if inDictionaryForm then
						entries[v.Action] = {Status = v.Action, Item = item}
					else
						entries[#entries+1] = {Status = v.Action, Item = item}
					end
				end
			end
		end
	end
	return entries
end

---Check if equipped items have a skill, or table of skills, or dictionary of skills.
---@param character CharacterParam
---@param skills string|string[]|table<string,boolean>
---@return boolean
function GameHelpers.Character.EquipmentHasSkill(character, skills)
	local char = GameHelpers.GetCharacter(character)
    fassert(char ~= nil, "'%s' is not a valid character", character)
	local skillsDict = skills
	local t = type(skills)
	if t == "string" then
		---@cast skills string
		skillsDict = {[skills] = true}
	elseif t == "table" then
		---@cast skills table
		if #skills then
			skillsDict = {}
			for _,v in pairs(skills) do
				skillsDict[v] = true
			end
		end
	end
	---@cast skillsDict table<string,boolean>
	for item in GameHelpers.Character.GetEquipment(character) do
		for id,b in pairs(GameHelpers.Item.GetEquippedSkills(item)) do
			if skillsDict[id] then
				return true
			end
		end
	end
	return false
end

---Get a character's mainhand and offhand item.
---@param character CharacterParam
---@return EsvItem|EclItem|nil mainhand
---@return EsvItem|EclItem|nil offhand
function GameHelpers.Character.GetEquippedWeapons(character)
	local char = GameHelpers.GetCharacter(character)
    fassert(char ~= nil, "'%s' is not a valid character", character)
	if _ISCLIENT then
		return char:GetItemObjectBySlot("Weapon"),char:GetItemObjectBySlot("Shield")
	else
		if _OSIRIS() then
			local mainhand,offhand = nil,nil
			local mainhandId,offhandId = Osi.CharacterGetEquippedItem(char.MyGuid, "Weapon"), Osi.CharacterGetEquippedItem(char.MyGuid, "Shield")
			if not StringHelpers.IsNullOrEmpty(mainhandId) then
				mainhand = GameHelpers.GetItem(mainhandId)
			end
			if not StringHelpers.IsNullOrEmpty(offhandId) then
				offhand = GameHelpers.GetItem(offhandId)
			end
			return mainhand,offhand
		else
			local mainhand,offhand = nil,nil
			for item in GameHelpers.Character.GetEquipment(character) do
				local slot = GameHelpers.Item.GetSlot(item)
				if slot then
					if Data.EquipmentSlots[slot] == "Weapon" then
						mainhand = item
					elseif Data.EquipmentSlots[slot] == "Shield" then
						offhand = item
					end
				else
					--Fallback if slot isn't retrievable, such as in v55
					if item.Stats.Slot == "Weapon" then
						mainhand = item
					elseif item.Stats.Slot == "Shield" then
						offhand = item
					end
				end
			end
			return mainhand,offhand
		end
	end
	return nil
end

---Gets items with specific tag(s) in a character's inventory (or equipment).
---@param character CharacterParam
---@param tag string|string[]
---@param asTable? boolean
---@param equippedOnly? boolean Only return equipped items.
---@return fun():EsvItem|EsvItem[] items
function GameHelpers.Character.GetTaggedItems(character, tag, asTable, equippedOnly)
    local items = {}
    character = GameHelpers.GetCharacter(character)
    if character then
        for i,v in pairs(character:GetInventoryItems()) do
            local item = GameHelpers.GetItem(v)
            if item and GameHelpers.ItemHasTag(item, tag) then
				if not equippedOnly or GameHelpers.Item.ItemIsEquipped(character, item) then
                	items[#items+1] = item
				end
            end
        end
    end
	if not asTable then
		local i = 0
		local count = #items
		return function ()
			i = i + 1
			if i <= count then
				return items[i]
			end
		end
	else
		return items
	end
end

---@param character CharacterParam
function GameHelpers.Character.IsImmobile(character)
	local character = GameHelpers.GetCharacter(character)
	if character then
		return GameHelpers.GetMovement(character.Stats) <= 0
	end
	return false
end

---Checks if a character has a specific object/party/user flag.
---@param character CharacterParam
---@param flag string|string[]
---@return boolean
function GameHelpers.Character.HasFlag(character, flag)
	if not _ISCLIENT and _OSIRIS() then
		local uuid = GameHelpers.GetUUID(character)
		if uuid then
			local t = _type(flag)
			if t == "table" then
				for k,v in pairs(flag) do
					if GameHelpers.Character.HasFlag(character, v) then
						return true
					end
				end
			elseif t == "string" then
				return Osi.ObjectGetFlag(uuid, flag) == 1
				or Osi.PartyGetFlag(uuid, flag) == 1
				or Osi.UserGetFlag(uuid, flag) == 1
			else
				error("flag parameter must be a string or table of strings.", 2)
			end
		end
	end
	return false
end

---Returns true if the target is an enemy or Friendly Fire is enabled.
---@param target CharacterParam|ItemParam
---@param attacker? CharacterParam If not specified, then this will return true if the target is an enemy of the party.
---@param allowItems? boolean If true, this will return true if target is an item.
---@return boolean
function GameHelpers.Character.CanAttackTarget(target, attacker, allowItems)
	local target = GameHelpers.TryGetObject(target)
	if target == nil then
		return false
	end
	if GameHelpers.Ext.ObjectIsItem(target) then
		---@cast target EsvItem|EclItem
		return allowItems == true and not GameHelpers.Item.IsDestructible(target)
	end
	assert(GameHelpers.Ext.ObjectIsCharacter(target), "target parameter must be a UUID, NetID, or Esv/EclCharacter")
	---@cast target EsvCharacter|EclCharacter
	if target:HasTag("LeaderLib_FriendlyFireEnabled") then
		return true
	end
	if not attacker then
		return GameHelpers.Character.IsEnemyOfParty(target)
	end
	attacker = GameHelpers.GetCharacter(attacker)
	assert(GameHelpers.Ext.ObjectIsCharacter(attacker), "attacker parameter must be a UUID, NetID, or Esv/EclCharacter")
	return GameHelpers.Character.IsEnemy(target, attacker)
end

---Returns true if the character has a FEMALE tag or IsMale is false in PlayerCustomData.
---@param character CharacterParam
---@return boolean
function GameHelpers.Character.IsFemale(character)
	character = GameHelpers.GetCharacter(character)
	assert(GameHelpers.Ext.ObjectIsCharacter(character), "target parameter must be a character UUID, NetID, or Esv/EclCharacter")
	if character:HasTag("FEMALE") then
		return true
	end
	if GameHelpers.Character.IsPlayer(character) and character.PlayerCustomData
	and not character.PlayerCustomData.IsMale then
		return true
	end
	return false
end

---Get the character's gender, if any.  
---@param character CharacterParam
---@return "Male"|"Female"|"None"
function GameHelpers.Character.GetGender(character)
	character = GameHelpers.GetCharacter(character)
	assert(GameHelpers.Ext.ObjectIsCharacter(character), "target parameter must be a character UUID, NetID, or Esv/EclCharacter")
	if character:HasTag("FEMALE") then
		return "Female"
	elseif character:HasTag("MALE") then
		return "Male"
	end
	if GameHelpers.Character.IsPlayer(character) and character.PlayerCustomData then
		return character.PlayerCustomData.IsMale and "Male" or "Female"
	end
	return "None"
end

---Returns true if the character has a status with IsInvulnerable set.
---@param character CharacterParam
---@return boolean
function GameHelpers.Character.IsInvulnerable(character)
	character = GameHelpers.TryGetObject(character)
	if character then
		for _,v in pairs(character:GetStatusObjects()) do
			if v.IsInvulnerable then
				return true
			end
		end
	end
	return false
end

---Returns true if the character has a status with IsResistingDeath set.
---@param character CharacterParam
---@return boolean
function GameHelpers.Character.IsResistingDeath(character)
	character = GameHelpers.TryGetObject(character)
	if character then
		for _,v in pairs(character:GetStatusObjects()) do
			if v.IsResistingDeath then
				return true
			end
		end
	end
	return false
end

---Similar to GameHelpers.Math.GetHighGroundFlag, but takes into account whether the attacker or target has the MARKED status.
---@param attacker CharacterParam
---@param target CharacterParam
---@return StatsHighGroundBonus
function GameHelpers.Character.GetHighGroundFlag(attacker, target)
	local attacker = GameHelpers.TryGetObject(attacker)
	local target = GameHelpers.TryGetObject(target)
	assert(attacker ~= nil, "attacker parameter must be a character UUID, NetID, or Esv/EclCharacter")
	assert(target ~= nil, "target parameter must be a character UUID, NetID, or Esv/EclCharacter")
	local highGroundFlag = GameHelpers.Math.GetHighGroundFlag(attacker.WorldPos, target.WorldPos)
	--MARKED mechanics
    --Character no longer receives high ground bonuses. When attacked from lower ground, attackers receive no penalties.
	if highGroundFlag == "LowGround" and target:GetStatus("MARKED") then
        highGroundFlag = "EvenGround"
    elseif highGroundFlag == "HighGround" and attacker:GetStatus("MARKED") then
        highGroundFlag = "EvenGround"
    end
	return highGroundFlag
end

---Change a character's stats via CharacterSetStats in behavior scripting.
---@param character CharacterParam
---@param statID string
function GameHelpers.Character.SetStats(character, statID)
	if not _ISCLIENT and Ext.Osiris.IsCallable() and not StringHelpers.IsNullOrWhitespace(statID) then
		local characterGUID = GameHelpers.GetUUID(character)
		if characterGUID then
			assert(GameHelpers.Stats.Exists(statID), string.format("Character Stat '%s' does not exist.", statID))
			Osi.SetVarFixedString(characterGUID, "LeaderLib_CharacterSetStats_ID", statID)
			Osi.SetStoryEvent(characterGUID, "LeaderLib_Commands_CharacterSetStats")
			return true
		end
	end
	return false
end

---Change a character's equipment via an equipment stat.
---@param character CharacterParam
---@param equipmentStatID string
---@param deleteExisting? boolean Delete existing equipment.
---@param rarity? ItemDataRarity
function GameHelpers.Character.SetEquipment(character, equipmentStatID, deleteExisting, rarity)
	if not _ISCLIENT and Ext.Osiris.IsCallable() and not StringHelpers.IsNullOrWhitespace(equipmentStatID) then
		character = GameHelpers.GetCharacter(character)
		if character then
			assert(GameHelpers.Stats.Exists(equipmentStatID, "EquipmentSet"), string.format("Equipment Stat '%s' does not exist.", equipmentStatID))
			local equipment = Ext.Stats.EquipmentSet.GetLegacy(equipmentStatID)
			local equipmentStats = {}
			for _,group in pairs(equipment.Groups) do
				for _,entry in pairs(group.Equipment) do
					local statType = GameHelpers.Stats.GetStatType(entry)
					if statType == "Armor" or statType == "Weapon" or statType == "Shield" then
						equipmentStats[#equipmentStats+1] = entry
					end
				end
			end
			rarity = rarity or "Common"
			local success = false
			for _,id in pairs(equipmentStats) do
				local itemGUID,item = GameHelpers.Item.CreateItemByStat(id, {
					StatsLevel=character.Stats.Level,
					ItemType=rarity,
					GenerationItemType=rarity,
					GMFolding = false,
					IsIdentified = true,
					GenerationStatsId = id,
				})
				if item then
					local slot = item.Stats.ItemSlot
					if deleteExisting then
						local existingItem = GameHelpers.Item.GetItemInSlot(character, slot)
						if existingItem then
							Osi.ItemRemove(existingItem.MyGuid)
						end
					end
					Osi.NRD_CharacterEquipItem(character.MyGuid, itemGUID, slot, 0, 0, 1, 1)
					success = true
				end
			end
			return success
		end
	end
	return false
end

local function _TrySetProperty(character, property, value)
	character = GameHelpers.GetCharacter(character, "EsvCharacter")
	if character then
		character[property] = value
		return true
	end
	return false
end

---Try to set a property on a character without throwing errors.
---@param character CharacterParam
---@param property string
---@param value any
---@return boolean success
function GameHelpers.Character.TrySetProperty(character, property, value)
	local _,b = pcall(_TrySetProperty, debug.traceback, property, value)
	return b
end

---Clone a character's equipment to another character.
---@param from CharacterParam
---@param to CharacterParam
---@return boolean success
function GameHelpers.Character.CloneEquipment(from, to)
	if not _ISCLIENT then
		local source = GameHelpers.GetCharacter(from)
		local target = GameHelpers.GetCharacter(to)
		if source and target then
			---@cast source EsvCharacter
			---@cast target EsvCharacter
			for item in GameHelpers.Character.GetEquipment(source) do
				local clone = GameHelpers.Item.Clone(item, nil, {CopyTags=true, InvokeEvent=false})
				if clone then
					local slot = GameHelpers.Item.GetSlot(item, true)
					Osi.NRD_CharacterEquipItem(target.MyGuid, clone.MyGuid, slot, 0, 0, 1, 1)
				end
			end
			return true
		end
	end
	return false
end

---Check if it's a character's active turn in combat.
---@param character CharacterParam
function GameHelpers.Character.IsActiveTurn(character)
	local character = GameHelpers.GetCharacter(character)
	if not character then
		return false
	end
	local turnManager = _ISCLIENT and Ext.Entity.GetTurnManager() or Ext.Combat.GetTurnManager()
	if turnManager then
		for _,entity in pairs(turnManager.EntityWrappers) do
			if entity.Character and entity.Character.NetID == character.NetID then
				return entity.CombatComponentPtr.IsTicking
			end
		end
	end
	return false
end

---@param guid Guid
---@return string
local function _GetInPartyDialog(guid)
	Osi.QRY_GLO_PartyMembers_GetInPartyDialog(guid)
	local db = Osi.DB_GLO_PartyMembers_InPartyDialog:Get(guid, nil)
	if db and db[1] then
		local _,dialog = table.unpack(db[1])
		if not StringHelpers.IsNullOrEmpty(dialog) then
			return dialog
		end
	end
	return "LeaderLib_Debug_RecruitCharacter"
end

---@param guid Guid
---@return string
local function _GetDefaultFaction(guid)
	local db = Osi.DB_GLO_PartyMembers_DefaultFaction:Get(guid, nil)
	if db and db[1] then
		local _,faction = table.unpack(db[1])
		if not StringHelpers.IsNullOrEmpty(faction) then
			return faction
		end
	end
	return "Hero Player20"
end

---@class GameHelpers_Character_MakePlayerOptions
---@field SkipPartyCheck boolean Skip the party full/solo proc call.
---@field SkipAssigningFaction boolean Skip assigning the player's faction to a player-related alignment.

---Turn a character into a player.
---🔨**Server-Only**🔨  
---@param character CharacterParam
---@param recruitingPlayer CharacterParam
---@param opts GameHelpers_Character_MakePlayerOptions
---@return boolean success
function _TryMakePlayer(character, recruitingPlayer, opts)
	assert(_ISCLIENT == false, "[GameHelpers.Character.MakePlayer] can only be called from the server side!")
	local target = GameHelpers.GetCharacter(character, "EsvCharacter")
	if recruitingPlayer == nil then
		recruitingPlayer = StringHelpers.GetUUID(Osi.CharacterGetHostCharacter())
	end
	local player = GameHelpers.GetCharacter(recruitingPlayer, "EsvCharacter")
	assert(target ~= nil,  string.format("Failed to get character from parameter (%s)", character))
	assert(player ~= nil,  string.format("Failed to get player from parameter (%s)", recruitingPlayer))
	local targetGUID = target.MyGuid
	local playerGUID = player.MyGuid
	Osi.CharacterRecruitCharacter(targetGUID, playerGUID)
	Osi.QRY_GLO_PartyMembers_GetInPartyDialogReset(targetGUID)
	Osi.ProcCharacterDisableAllCrimes(targetGUID)
	Osi.ProcAssignCharacterToPlayer(targetGUID,playerGUID)
	Osi.ProcRegisterPlayerTriggers(targetGUID)
	local dialog = _GetInPartyDialog(targetGUID)
	Osi.PROC_GLO_PartyMembers_SetInpartyDialog(targetGUID, dialog)
	if not opts.SkipAssigningFaction then
		local faction = _GetDefaultFaction(targetGUID)
		Osi.SetFaction(targetGUID, faction)
		Osi.DB_GLO_PartyMembers_DefaultFaction:Delete(targetGUID, nil)
	end
	Osi.DB_IsPlayer(targetGUID)
	Osi.CharacterAttachToGroup(targetGUID,playerGUID)
	if not opts.SkipPartyCheck then
		Osi.Proc_CheckPartyFull()
	end
	Osi.Proc_CheckFirstTimeRecruited(targetGUID)
	Osi.PROC_GLO_PartyMembers_RecruiteeAvatarBond_IfDifferent(targetGUID,playerGUID)
	Osi.Proc_BondedAvatarTutorial(playerGUID)
	Osi.CharacterSetCorpseLootable(targetGUID, 0)
	Osi.PROC_GLO_PartyMembers_AddHook(targetGUID,playerGUID)
	return true
end

---Turn a character into a player.
---🔨**Server-Only**🔨  
---@param character CharacterParam
---@param recruitingPlayer CharacterParam
---@param opts? GameHelpers_Character_MakePlayerOptions
---@return boolean success
function GameHelpers.Character.MakePlayer(character, recruitingPlayer, opts)
	local b,err = xpcall(_TryMakePlayer, debug.traceback, character, recruitingPlayer, opts or {})
	if not b then
		if not _ISCLIENT then
			local guid = GameHelpers.GetUUID(character)
			if guid then
				Osi.PROC_GLO_PartyMembers_Remove(guid, 1)
			end
		end
		error(err, 2)
	end
	return true
end

---Turn a character into a player.
---🔨**Server-Only**🔨  
---@param character CharacterParam
function GameHelpers.Character.RemoveTemporyCharacter(character)
	assert(_ISCLIENT == false, "[GameHelpers.Character.RemoveTemporyCharacter] can only be called from the server side!")
	local guid = GameHelpers.GetUUID(character)
	local netid = GameHelpers.GetNetID(character)
	if guid then
		Osi.RemoveTemporaryCharacter(guid)
	end
	Events.TemporaryCharacterRemoved:Invoke({CharacterGUID = guid, NetID=netid})
end

---Set a character's permanent boosts, and syncs it to the client if on the server-side.
---@param character CharacterParam
---@param opts StatsCharacterDynamicStat
---@param index? integer Defaults to 2. Set to -1 to set `character.Stats` instead.
function GameHelpers.Character.SetPermanentBoosts(character, opts, index)
	character = GameHelpers.GetCharacter(character)
	index = index or 2
	if character and character.Stats ~= nil then
		if index == -1 then
			for k,v in pairs(opts) do
				character.Stats[k] = v
			end
		else
			for k,v in pairs(opts) do
				character.Stats.DynamicStats[index][k] = v
			end
		end
		if not _ISCLIENT then
			GameHelpers.Net.Broadcast("LeaderLib_Character_SetPermanentBoosts", {NetID=character.NetID, Data=opts, Index=index})
		end
	end
end

---@param character CharacterObject
---@param animType? AnimType The AnimType to use. Leave nil to 'reset' the current AnimType.
function GameHelpers.Character.SetAnimType(character, animType)
	if animType == nil then
		if character:GetStatus("UNSHEATHED") then
			local main,off = GameHelpers.Character.GetEquippedWeapons(character)
			local weapon = main or off
			if weapon then
				animType = weapon.Stats.AnimType
				if animType == Data.AnimType.None then
					local weaponType = weapon.Stats.WeaponType
					if weaponType == "Bow" then
						animType = Data.AnimType.Bow
					elseif weaponType == "Crossbow" then
						animType = Data.AnimType.CrossBow
					elseif weaponType == "Rifle" then
						animType = Data.AnimType.CrossBow
					elseif weaponType == "Staff" then
						animType = Data.AnimType.Staves
					elseif weaponType == "None" then
						animType = Data.AnimType.Unarmed
					else
						if weapon.Stats.IsTwoHanded then
							animType = Data.AnimType.TwoHanded
							if weaponType == "Sword" then
								animType = Data.AnimType.TwoHanded_Sword
							end
						else
							if off ~= nil and main ~= off then
								animType = Data.AnimType.DualWield
								if off.Stats.ItemType == "Shield" then
									if weaponType == "Wand"	then
										animType = Data.AnimType.ShieldWands
									end
								else
									local offType = off.Stats.WeaponType
									if offType == weaponType and weaponType == "Knife" then
										animType = Data.AnimType.DualWieldSmall
									elseif offType == weaponType and weaponType == "Wand" then
										animType = Data.AnimType.DualWieldWands
									end
								end
							else
								animType = Data.AnimType.OneHanded
								if weaponType == "Knife" then
									animType = Data.AnimType.SmallWeapons
								elseif weaponType == "Wand" then
									animType = Data.AnimType.Wands
								end
							end
						end
					end
				end
			end
		end
	end
	local t = _type(animType)
	if t == "string" then
		animType = Data.AnimType[animType]
	elseif t ~= "number" then
		animType = -1
	end
	character.AnimType = animType
	if not _ISCLIENT then
		GameHelpers.Net.Broadcast("LeaderLib_Character_SetAnimType", {NetID=character.NetID, AnimType=animType})
	end
end

---@class LeaderLib_Character_SetPermanentBoosts
---@field NetID NetId
---@field Data StatsCharacterDynamicStat
---@field Index integer

---@class LeaderLib_Character_SetAnimType
---@field NetID NetId
---@field AnimType AnimType The value used to set EsvCharacter/EclCharacter.AnimType

if _ISCLIENT then
	--Register net subscriptions after scripts are done loading
	Events.Loaded:Subscribe(function (e)
		GameHelpers.Net.Subscribe("LeaderLib_Character_SetPermanentBoosts", function (e, data)
			GameHelpers.Character.SetPermanentBoosts(data.NetID, data.Data, data.Index)
		end)

		GameHelpers.Net.Subscribe("LeaderLib_Character_SetAnimType", function (e, data)
			if data.NetID then
				local character = GameHelpers.GetCharacter(data.NetID)
				if character then
					GameHelpers.Character.SetAnimType(character, data.AnimType)
				end
			end
		end)
	end, {Once=true})
end

local _STAT_TALENT_ID = {
	TALENT_ItemMovement = 1,
	TALENT_ItemCreation = 2,
	TALENT_Flanking = 3,
	TALENT_AttackOfOpportunity = 4,
	TALENT_Backstab = 5,
	TALENT_Trade = 6,
	TALENT_Lockpick = 7,
	TALENT_ChanceToHitRanged = 8,
	TALENT_ChanceToHitMelee = 9,
	TALENT_Damage = 10,
	TALENT_ActionPoints = 11,
	TALENT_ActionPoints2 = 12,
	TALENT_Criticals = 13,
	TALENT_IncreasedArmor = 14,
	TALENT_Sight = 15,
	TALENT_ResistFear = 16,
	TALENT_ResistKnockdown = 17,
	TALENT_ResistStun = 18,
	TALENT_ResistPoison = 19,
	TALENT_ResistSilence = 20,
	TALENT_ResistDead = 21,
	TALENT_Carry = 22,
	TALENT_Throwing = 23,
	TALENT_Repair = 24,
	TALENT_ExpGain = 25,
	TALENT_ExtraStatPoints = 26,
	TALENT_ExtraSkillPoints = 27,
	TALENT_Durability = 28,
	TALENT_Awareness = 29,
	TALENT_Vitality = 30,
	TALENT_FireSpells = 31,
	TALENT_WaterSpells = 32,
	TALENT_AirSpells = 33,
	TALENT_EarthSpells = 34,
	TALENT_Charm = 35,
	TALENT_Intimidate = 36,
	TALENT_Reason = 37,
	TALENT_Luck = 38,
	TALENT_Initiative = 39,
	TALENT_InventoryAccess = 40,
	TALENT_AvoidDetection = 41,
	TALENT_AnimalEmpathy = 42,
	TALENT_Escapist = 43,
	TALENT_StandYourGround = 44,
	TALENT_SurpriseAttack = 45,
	TALENT_LightStep = 46,
	TALENT_ResurrectToFullHealth = 47,
	TALENT_Scientist = 48,
	TALENT_Raistlin = 49,
	TALENT_MrKnowItAll = 50,
	TALENT_WhatARush = 51,
	TALENT_FaroutDude = 52,
	TALENT_Leech = 53,
	TALENT_ElementalAffinity = 54,
	TALENT_FiveStarRestaurant = 55,
	TALENT_Bully = 56,
	TALENT_ElementalRanger = 57,
	TALENT_LightningRod = 58,
	TALENT_Politician = 59,
	TALENT_WeatherProof = 60,
	TALENT_LoneWolf = 61,
	TALENT_Zombie = 62,
	TALENT_Demon = 63,
	TALENT_IceKing = 64,
	TALENT_Courageous = 65,
	TALENT_GoldenMage = 66,
	TALENT_WalkItOff = 67,
	TALENT_FolkDancer = 68,
	TALENT_SpillNoBlood = 69,
	TALENT_Stench = 70,
	TALENT_Kickstarter = 71,
	TALENT_WarriorLoreNaturalArmor = 72,
	TALENT_WarriorLoreNaturalHealth = 73,
	TALENT_WarriorLoreNaturalResistance = 74,
	TALENT_RangerLoreArrowRecover = 75,
	TALENT_RangerLoreEvasionBonus = 76,
	TALENT_RangerLoreRangedAPBonus = 77,
	TALENT_RogueLoreDaggerAPBonus = 78,
	TALENT_RogueLoreDaggerBackStab = 79,
	TALENT_RogueLoreMovementBonus = 80,
	TALENT_RogueLoreHoldResistance = 81,
	TALENT_NoAttackOfOpportunity = 82,
	TALENT_WarriorLoreGrenadeRange = 83,
	TALENT_RogueLoreGrenadePrecision = 84,
	TALENT_WandCharge = 85,
	TALENT_DualWieldingDodging = 86,
	TALENT_Human_Inventive = 87,
	TALENT_Human_Civil = 88,
	TALENT_Elf_Lore = 89,
	TALENT_Elf_CorpseEating = 90,
	TALENT_Dwarf_Sturdy = 91,
	TALENT_Dwarf_Sneaking = 92,
	TALENT_Lizard_Resistance = 93,
	TALENT_Lizard_Persuasion = 94,
	TALENT_Perfectionist = 95,
	TALENT_Executioner = 96,
	TALENT_ViolentMagic = 97,
	TALENT_QuickStep = 98,
	TALENT_Quest_SpidersKiss_Str = 99,
	TALENT_Quest_SpidersKiss_Int = 100,
	TALENT_Quest_SpidersKiss_Per = 101,
	TALENT_Quest_SpidersKiss_Null = 102,
	TALENT_Memory = 103,
	TALENT_Quest_TradeSecrets = 104,
	TALENT_Quest_GhostTree = 105,
	TALENT_BeastMaster = 106,
	TALENT_LivingArmor = 107,
	TALENT_Torturer = 108,
	TALENT_Ambidextrous = 109,
	TALENT_Unstable = 110,
	TALENT_ResurrectExtraHealth = 111,
	TALENT_NaturalConductor = 112,
	TALENT_Quest_Rooted = 113,
	TALENT_PainDrinker = 114,
	TALENT_DeathfogResistant = 115,
	TALENT_Sourcerer = 116,
	TALENT_Rager = 117,
	TALENT_Elementalist = 118,
	TALENT_Sadist = 119,
	TALENT_Haymaker = 120,
	TALENT_Gladiator = 121,
	TALENT_Indomitable = 122,
	TALENT_WildMag = 123,
	TALENT_Jitterbug = 124,
	TALENT_Soulcatcher = 125,
	TALENT_MasterThief = 126,
	TALENT_GreedyVessel = 127,
	TALENT_MagicCycles = 128,
}

---@overload fun(character:CharacterParam):table<TalentType, EclItem|EsvItem>
---Get a dictionary of the talents from equipped items.
---@param character CharacterParam
---@param asBaseID boolean Remove the `TALENT_` part of the ID.
---@return table<TalentType, EclItem|EsvItem>
function GameHelpers.Character.GetEquipmentTalents(character, asBaseID)
	local tbl = {}
	local talents = TableHelpers.Clone(_STAT_TALENT_ID)
	for equipment in GameHelpers.Character.GetEquipment(character) do
		for talent,enumID in pairs(talents) do
			if equipment.Stats[talent] then
				if asBaseID then
					tbl[Data.Talents[enumID]] = equipment
				else
					tbl[talent] = equipment
				end
				talents[talent] = nil
			end
		end
	end
	return tbl
end