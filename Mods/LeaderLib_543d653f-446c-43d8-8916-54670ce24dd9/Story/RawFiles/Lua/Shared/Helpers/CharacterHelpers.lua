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
				if ObjectIsCharacter(character.MyGuid) == 1 and (character.IsPlayer or character.IsGameMaster) then
					return true
				end
				character = character.MyGuid
			end
			if _type(character) == "string" then
				return CharacterIsPlayer(character) == 1 or CharacterGameMaster(character) == 1 or GameHelpers.DB.HasUUID("DB_IsPlayer", character)
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
---@param ignorePossessed boolean|nil
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
		return not StringHelpers.IsNullOrEmpty(GUID) and CharacterIsPartyMember(GUID) == 1
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
			return CharacterIsSummon(character) == 1 or CharacterIsPartyFollower(character) == 1
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
function GameHelpers.Character.IsAllyOfParty(character)
	if not _ISCLIENT and _OSIRIS() then
		character = GameHelpers.GetUUID(character)
		if not character or ObjectIsCharacter(character) == 0 then return false end
		for player in GameHelpers.Character.GetPlayers(false) do
			if CharacterIsAlly(character, player.MyGuid) == 1 then
				return true
			end
		end
	end
	return false
end

---@param character CharacterParam
function GameHelpers.Character.IsEnemyOfParty(character)
	if not _ISCLIENT and _OSIRIS() then
		local GUID = GameHelpers.GetUUID(character)
		if not GUID then return false end
		for player in GameHelpers.Character.GetPlayers(false) do
			if CharacterIsEnemy(GUID, player.MyGuid) == 1 then
				return true
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
			local relation = CharacterGetRelationToCharacter(a,b)
			return CharacterIsEnemy(a,b) == 1 or (relation and relation <= 0)
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
function GameHelpers.Character.IsNeutralToParty(character)
	if not _ISCLIENT and _OSIRIS() then
		local GUID = GameHelpers.GetUUID(character)
		if not GUID then return false end
		for player in GameHelpers.Character.GetPlayers(false) do
			if CharacterIsNeutral(GUID, player.MyGuid) == 1 then
				return true
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
		if CharacterIsInCombat(GUID) == 1 then
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
					return CharacterHasSkill(character.MyGuid, skill) == 1
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
						if CharacterHasSkill(character.MyGuid, skill[i]) == 1 then
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
---@param radius number|nil Defaults to 2.0
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
---@param character CharacterParam
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
---Use GameHelpers.Character.GetRace if you want to just find whatever the race is.  
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

---Returns true if the character is one of the regular humanoid races.
---@param character CharacterParam
---@return boolean
function GameHelpers.Character.IsHumanoid(character)
	character = GameHelpers.GetCharacter(character)
	if character and character.HasTag then
		for raceId,raceData in pairs(Vars.RaceData) do
			if character:HasTag(raceData.Tag) 
			or character:HasTag(raceData.BaseTag)
			or string.find(character.RootTemplate.TemplateName, raceId)
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
				local handle,ref = CharacterGetDisplayName(character.MyGuid)
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

---@param includeSummons boolean|nil
---@param asTable boolean|nil if true, a regular table is returned, which needs to be used with pairs/ipairs.
---@return fun():EsvCharacter|EclCharacter
function GameHelpers.Character.GetPlayers(includeSummons, asTable)
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
								if ObjectIsCharacter(v) == 1 then
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
			local gm = StringHelpers.GetUUID(CharacterGetHostCharacter())
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
	if not _ISCLIENT then
		return GameHelpers.GetCharacter(CharacterGetHostCharacter())
	else
		for _,v in pairs(SharedData.CharacterData) do
			if v.IsHost then
				return v:GetCharacter()
			end
		end
	end
	return nil
end

---@param includeSummons boolean|nil
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
						if ObjectIsCharacter(v) == 1 then
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
---@overload fun(owner:CharacterParam, includeItems:true):fun():GameHelpers_Character_GetSummonsResultType
---@overload fun(owner:CharacterParam, includeItems:boolean|nil, asTable:true):fun():GameHelpers_Character_GetSummonsResultType[]
---Gets all the active summons of a character.
---@param owner CharacterParam
---@param includeItems boolean|nil If on the server-side, item summons can be fetched as well if this is true.
---@param asTable boolean|nil Return the result as a table, instead of an iterator.
---@param ignoreObjects table<NETID|UUID, boolean>|nil Specific MyGuid or NetID values to ignore.
---@return fun():GameHelpers_Character_GetSummonsResultType|nil summons
function GameHelpers.Character.GetSummons(owner, includeItems, asTable, ignoreObjects)
	owner = GameHelpers.GetCharacter(owner)

	local summons = {}
	local ignore = ignoreObjects or {}
	
	if not _ISCLIENT then
		local ownerGUID = GameHelpers.GetUUID(owner)
		local activeSummonsData = _PV.Summons[ownerGUID]
		if activeSummonsData then
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
		else
			for _,handle in pairs(owner.SummonHandles) do
				if Ext.Utils.IsValidHandle(handle) then
					local summon = GameHelpers.TryGetObject(handle)
					if summon and ignore[summon.MyGuid] and (includeItems == true or GameHelpers.Ext.ObjectIsCharacter(summon)) then
						summons[#summons+1] = summon
					end
				end
			end
		end
	else
		---@cast owner EclCharacter
		---@type number
		local ownerHandle = owner
		if _type(owner) == "userdata" and owner.Handle then
			ownerHandle = Ext.UI.HandleToDouble(owner.Handle)
		end
		--Only summons who are attached to the portrait
		for mc in StatusHider.PlayerInfo:GetSummonMovieClips(ownerHandle) do
			local summon = GameHelpers.GetCharacter(Ext.UI.DoubleToHandle(mc.characterHandle))
			if summon and not ignore[summon.NetID] then
				---@cast summon EclCharacter
				if summon and not ignore[summon.NetID] and summon.Summon then
					summons[#summons+1] = summon
				end
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

---Gets all the active summons.
---@param includeItems boolean|nil If on the server, item summons can be fetched as well.
---@param asTable boolean|nil Return the result as a table, instead of an iterator.
---@param ignoreObjects table<NETID|UUID, boolean>|nil Specific MyGuid or NetID values to ignore.
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

---@param character EsvCharacter|EclCharacter
---@param asMeters boolean|nil If true, the range is returned as meters (WeaponRange/100).
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

---@param character EsvCharacter|EclCharacter
---@param target EsvCharacter|EsvItem|number[]
---@return boolean
function GameHelpers.Character.IsWithinWeaponRange(character, target)
	local weaponRange = GameHelpers.Character.GetWeaponRange(target, true)
	return GameHelpers.Math.GetDistance(character, target) <= weaponRange
end

---@param character CharacterParam
function GameHelpers.Character.IsUnsheathed(character)
	if not _ISCLIENT and _OSIRIS() then
		character = GameHelpers.GetUUID(character)
		if not character then return false end
		return HasActiveStatus(character, "UNSHEATHED") == 1 or CharacterIsInFightMode(character) == 1
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
---@param character EsvCharacter|string
---@param checkForLoseControl boolean
---@param checkForZeroMovement boolean
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
	Ext.NewQuery(GameHelpers.Character.IsSneakingOrInvisible, "LeaderLib_Ext_QRY_IsSneakingOrInvisible", "[in](GUIDSTRING)_Object, [out](INTEGER)_Bool")
end

GameHelpers.Status.IsSneakingOrInvisible = GameHelpers.Character.IsSneakingOrInvisible

---Shortcut for GameHelpers.Surface.HasSurface, using the character's position.
---@param character EsvCharacter|EclCharacter
---@param matchNames string|string[] Surface names to look for.
---@param maxRadius number|nil
---@param containingName boolean Look for surfaces containing the name, instead of explicit matching.
---@param onlyLayer integer Look only on layer 0 (ground) or 1 (clouds).
---@param grid AiGrid|nil
---@return boolean
function GameHelpers.Character.IsInSurface(character, matchNames, maxRadius, containingName, onlyLayer, grid)
	local pos = GameHelpers.Math.GetPosition(character, false, false)
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
		fassert(not StringHelpers.IsNullOrEmpty(uuid) and ObjectExists(uuid) == 1, "Character (%s) must be a valid UUID or EsvCharacter", character)
		item = GameHelpers.GetItem(item)
		fassert(item ~= nil and not GameHelpers.Item.IsObject(item), "Item (%s) must be a non-object item.", item and item.StatsId or "nil")
		fassert(ItemIsEquipable(item.MyGuid) == 1, "Item (%s) is not equipable.", item.StatsId)
		if item.Stats.Slot == "Weapon" then
			local mainhand = GameHelpers.Item.GetItemInSlot(uuid, "Weapon")
			local offhand = GameHelpers.Item.GetItemInSlot(uuid, "Shield")
			if item.Stats.IsTwoHanded then
				if mainhand then
					ItemLockUnEquip(mainhand.MyGuid, 0)
					ItemToInventory(mainhand.MyGuid, uuid, 1, 0, 0)
				end
				if offhand then
					ItemLockUnEquip(offhand.MyGuid, 0)
					ItemToInventory(offhand.MyGuid, uuid, 1, 0, 0)
				end
				SetOnStage(item.MyGuid, 1)
				NRD_CharacterEquipItem(uuid, item.MyGuid, "Weapon", 0, 0, 1, 1)
				return true
			else
				if mainhand then
					if not offhand then
						SetOnStage(item.MyGuid, 1)
						NRD_CharacterEquipItem(uuid, item.MyGuid, "Shield", 0, 0, 1, 1)
						return true
					else
						ItemLockUnEquip(mainhand.MyGuid, 0)
						ItemToInventory(mainhand.MyGuid, uuid, 1, 0, 0)
						SetOnStage(item.MyGuid, 1)
						NRD_CharacterEquipItem(uuid, item.MyGuid, "Weapon", 0, 0, 1, 1)
						return true
					end
				else
					NRD_CharacterEquipItem(uuid, item.MyGuid, "Weapon", 0, 0, 1, 1)
					return true
				end
			end
		elseif item.Stats.Slot == "Shield" then
			local offhand = GameHelpers.Item.GetItemInSlot(uuid, "Shield")
			if offhand then
				ItemLockUnEquip(offhand.MyGuid, 0)
				ItemToInventory(offhand.MyGuid, uuid, 1, 0, 0)
			end
			SetOnStage(item.MyGuid, 1)
			NRD_CharacterEquipItem(uuid, item.MyGuid, "Shield", 0, 0, 1, 1)
			return true
		else
			local existing = GameHelpers.Item.GetItemInSlot(uuid, item.Stats.Slot)
			if existing then
				ItemLockUnEquip(existing.MyGuid, 0)
				ItemToInventory(existing.MyGuid, uuid, 1, 0, 0)
			end
			SetOnStage(item.MyGuid, 1)
			NRD_CharacterEquipItem(uuid, item.MyGuid, item.Stats.Slot, 0, 0, 1, 1)
			return true
		end
	end
	return false
end

---@overload fun(character:CharacterParam):fun():EsvItem|EclItem
---Get a table of the character's equipment.
---@param character CharacterParam
---@param asTable boolean|nil Return the results as a table, instead of an iterator.
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
---@param inDictionaryForm boolean|nil Return the results as a statusId,data table.
---@return table<string, _GameHelpers_Character_GetEquipmentOnEquipStatuses_Entry>|_GameHelpers_Character_GetEquipmentOnEquipStatuses_Entry[]
function GameHelpers.Character.GetEquipmentOnEquipStatuses(character, inDictionaryForm)
	local char = GameHelpers.GetCharacter(character)
    fassert(char ~= nil, "'%s' is not a valid character", character)
	local entries = {}
	for item in GameHelpers.Character.GetEquipment(character) do
		---@type StatPropertyStatus[]
		local props = Ext.Stats.GetAttribute(item.Stats.Name, "ExtraProperties")
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
			local mainhandId,offhandId = CharacterGetEquippedItem(char.MyGuid, "Weapon"), CharacterGetEquippedItem(char.MyGuid, "Shield")
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
---@param asTable boolean|nil
---@param equippedOnly boolean|nil Only return equipped items.
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
				return ObjectGetFlag(uuid, flag) == 1
				or PartyGetFlag(uuid, flag) == 1
				or UserGetFlag(uuid, flag) == 1
			else
				error("flag parameter must be a string or table of strings.", 2)
			end
		end
	end
	return false
end

---Returns true if the target is an enemy or Friendly Fire is enabled.
---@param target CharacterParam
---@param attacker CharacterParam|nil If not specified, then this will return true if the target is an enemy of the party.
---@param allowItems boolean|nil If true, this will return true if target is an item.
---@return boolean
function GameHelpers.Character.CanAttackTarget(target, attacker, allowItems)
	local target = GameHelpers.TryGetObject(target)
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
			SetVarFixedString(characterGUID, "LeaderLib_CharacterSetStats_ID", statID)
			SetStoryEvent(characterGUID, "LeaderLib_Commands_CharacterSetStats")
			return true
		end
	end
	return false
end

---Change a character's equipment via an equipment stat.
---@param character CharacterParam
---@param equipmentStatID string
---@param deleteExisting boolean|nil Delete existing equipment.
---@param rarity ItemDataRarity|nil
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
							ItemRemove(existingItem.MyGuid)
						end
					end
					NRD_CharacterEquipItem(character.MyGuid, itemGUID, slot, 0, 0, 1, 1)
					success = true
				end
			end
			return success
		end
	end
	return false
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
					NRD_CharacterEquipItem(target.MyGuid, clone.MyGuid, slot, 0, 0, 1, 1)
				end
			end
			return true
		end
	end
	return false
end