---A wrapper around common character queries with additional character-related helpers.
---@class CharacterData:EsvCharacter
---@field UUID string
---@field Region string
local CharacterData = {
	Type = "CharacterData",
}

CharacterData.__index = function(tbl, k)
	if CharacterData[k] then
		return CharacterData[k]
	end
	local uuid = rawget(tbl, "UUID")
	if uuid then
		if k == "Region" and _OSIRIS() then
			return Osi.GetRegion(uuid)
		end
		local char = GameHelpers.GetCharacter(uuid)
		if char then
			return char[k]
		end
	end
end

---@param uuid string
---@param params table<string,any>|nil
CharacterData.__call = function(_, uuid, params)
	return CharacterData:Create(uuid, params)
end
---@param self CharacterData
CharacterData.__tostring = function(self)
	local character = self:GetCharacter()
	if character then
		return string.format("[CharacterData] DisplayName(%s) UUID(%s) NetID(%s) StatsId(%s)", character.DisplayName, self.UUID, character.NetID, character.Stats.Name)
	else
		return string.format("[CharacterData] UUID(%s)", self.UUID)
	end
end


---@param uuid string
---@param params table<string,any>|nil
---@return CharacterData
function CharacterData:Create(uuid, params)
    local this =
    {
		UUID = uuid or ""
	}
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)
    return this
end

---@return boolean
function CharacterData:Exists()
	return not StringHelpers.IsNullOrEmpty(self.UUID) and Osi.ObjectExists(self.UUID) == 1
end

---Fetches the EsvCharacter associated with this character's UUID.
---@return EsvCharacter|nil
function CharacterData:GetCharacter()
	if self:Exists() then
		return GameHelpers.GetCharacter(self.UUID)
	end
	return nil
end

---@param allowPlayingDead boolean
---@return boolean
function CharacterData:IsDead(allowPlayingDead)
	return allowPlayingDead ~= true and Osi.CharacterIsDead(self.UUID) == 1 or Osi.CharacterIsDeadOrFeign(self.UUID) == 1
end

---@return boolean
function CharacterData:IsInCombat()
	return Osi.CharacterIsInCombat(self.UUID) == 1 or Common.OsirisDatabaseHasAnyEntry(Osi.DB_CombatCharacters:Get(self.UUID, nil))
end

---@return integer
function CharacterData:GetCombatID()
	local id = Osi.CombatGetIDForCharacter(self.UUID)
	if id > 0 then
		return id
	end
	local db = Osi.DB_CombatCharacters:Get(self.UUID, nil)
	if db and #db > 0 then
		id = db[1][2] --[[@as integer]]
		if id > 0 then
			return id
		end
	end
	return 0
end

---@param asVector3 boolean|nil
---@return number,number,number|Vector3
function CharacterData:GetPosition(asVector3)
	local x,y,z = Osi.GetPosition(self.UUID)
	if asVector3 == true then
		return Classes.Vector3(x,y,z)
	else
		return x,y,z
	end
end

---@param status string|string[]
---@param checkAll boolean|nil Only return true if all statuses are found.
---@return boolean
function CharacterData:HasActiveStatus(status, checkAll)
	return GameHelpers.Status.IsActive(self.UUID, status, checkAll)
end

---Checks for an object, party, or user flag on the character.
---@param flag string
---@return boolean
function CharacterData:HasFlag(flag)
	if _OSIRIS() then
		return GameHelpers.Character.HasFlag(self.UUID, flag)
	end
	return false
end

---@param force boolean|nil Forces the stage change, otherwise it's skipped if they're already on stage.
function CharacterData:SetOffStage(force)
	if self:Exists() then
		if force == true or Osi.ObjectIsOnStage(self.UUID) == 1 then
			Osi.SetOnStage(self.UUID, 0)
			return true
		end
	end
	return false
end

---@param force boolean|nil Forces the stage change, otherwise it's skipped if they're already on stage.
function CharacterData:SetOnStage(force)
	if self:Exists() then
		if force == true or Osi.ObjectIsOnStage(self.UUID) == 0 then
			Osi.SetOnStage(self.UUID, 1)
			return true
		end
	end
	return false
end

--- Applies a status or sets its duration if it's still active, for all instances of the status.
---@param status string|string[]
---@param duration number
---@param force boolean
---@param source string
function CharacterData:ApplyOrSetStatus(status, duration, force, source)
	if type(status) == "table" then
		for i,v in pairs(status) do
			self:ApplyOrSetStatus(v, duration, force, source)
		end
	else
		if not self:HasActiveStatus(status) then
			GameHelpers.Status.Apply(self.UUID, status, duration or 6.0, force, source or self.UUID)
		else
			local char = self:GetCharacter()
			if char then
				duration = duration or 6.0
				for i,v in pairs(char:GetStatusObjects()) do
					if v.StatusId == status then
						if v.CurrentLifeTime ~= duration and (v.CurrentLifeTime >= 0 or force == true) then
							v.CurrentLifeTime = duration
							v.RequestClientSync = true
						end
					end
				end
			end
		end
	end
end

--- Removes a status or array of statuses, or 'all'.
---@param status string|string[]
---@param ignorePermanent boolean|nil Ignore permanent statuses when removing 'all'.
function CharacterData:RemoveStatus(status, ignorePermanent)
	if type(status) == "table" then
		for i,v in pairs(status) do
			self:RemoveStatus(v)
		end
	else
		if StringHelpers.Equals(status, "all", true) then
			local character = self:GetCharacter()
			if character then
				if ignorePermanent == true then
					for i,v in pairs(character:GetStatusObjects()) do
						if v.CurrentLifeTime ~= -1 then
							Osi.RemoveStatus(self.UUID, v.StatusId)
						end
					end
				else
					for i,v in pairs(character:GetStatuses()) do
						Osi.RemoveStatus(self.UUID, v)
					end
				end
			end
		else
			if ignorePermanent == true then
				local character = self:GetCharacter()
				if character then
					for i,v in pairs(character:GetStatusObjects()) do
						if v.StatusId == status and v.CurrentLifeTime ~= -1 then
							Osi.RemoveStatus(self.UUID, v.StatusId)
						end
					end
				end
			else
				Osi.RemoveStatus(self.UUID, status)
			end
		end
	end
end

---Shortcut for calling RemoveStatus with 'all'.
---@param ignorePermanent boolean|nil Ignore permanent statuses when removing 'all'.
function CharacterData:RemoveAllStatuses(ignorePermanent)
	self:RemoveStatus("all", ignorePermanent)
end

---A better alternative to RemoveHarmfulStatuses since it actually checks for debuffs.
---@param ignorePermanent boolean|nil Ignore permanent statuses.
function CharacterData:RemoveHarmfulStatuses(ignorePermanent)
	local character = self:GetCharacter()
	if character then
		GameHelpers.Status.RemoveHarmful(character, ignorePermanent)
	end
end

---Equips a root template, or creates and equips one if the item doesn't exist.
---@param template string
---@param all boolean|nil Equip all instances.
---@return EsvItem|EsvItem[]
function CharacterData:EquipTemplate(template, all)
	local character = self:GetCharacter()
	if character then
		local foundItems = {}
		for item in GameHelpers.Character.GetEquipment(character) do
			if GameHelpers.GetTemplate(item) == template and Osi.ItemIsEquipable(item.MyGuid) == 1 then
				Osi.SetOnStage(item.MyGuid, 1)
				--TODO Swap with a way to get the slot name for the item, like Weapon/Shield
				Osi.NRD_CharacterEquipItem(self.UUID, item.MyGuid, item.StatsFromName.StatsEntry.Slot, 0, 0, 1, 1)
				--CharacterEquipItem(self.UUID, v)
				if all ~= true then
					return item
				else
					foundItems[#foundItems+1] = item
				end
				--NRD_CharacterEquipItem(self.UUID, v, item.Stats.ItemSlot, 0, 0, 1, 1)
			end
		end
		if all and #foundItems > 0 then
			return foundItems
		end
		local item = GameHelpers.Item.CreateItemByTemplate(template)
		if item then
			Osi.ItemToInventory(item.MyGuid, self.UUID, 1, 0, 0)
			if Osi.ItemIsEquipable(item.MyGuid) == 1 then
				Osi.SetOnStage(item.MyGuid, 1)
				Osi.NRD_CharacterEquipItem(self.UUID, item.MyGuid, item.StatsFromName.StatsEntry.Slot, 0, 0, 1, 1)
			end
			return item
		end
	end
	return nil
end

---@param resurrect boolean|nil
function CharacterData:FullRestore(resurrect)
	if self:Exists() then
		if resurrect and self:IsDead(false) then
			Osi.CharacterResurrect(self.UUID)
		end
		Osi.CharacterSetHitpointsPercentage(self.UUID, 100.0)
		Osi.CharacterSetArmorPercentage(self.UUID, 100.0)
		Osi.CharacterSetMagicArmorPercentage(self.UUID, 100.0)
		GameHelpers.Status.Apply(self.UUID, "LEADERLIB_RECALC", 0.0, true, self.UUID)
		Timer.StartOneshot(nil, 500, function(e)
			local character = self:GetCharacter()
			if character then
				if Vars.DebugMode then
					fprint(LOGLEVEL.DEFAULT, "[CharacterData:FullRestore] (%s) Vitality(%s/%s) Armor(%s/%s) Magic Armor(%s/%s) ", character.DisplayName,
					StringHelpers.CommaNumber(character.Stats.CurrentVitality or 0),
					StringHelpers.CommaNumber(character.Stats.MaxVitality or 0),
					StringHelpers.CommaNumber(character.Stats.CurrentArmor or 0),
					StringHelpers.CommaNumber(character.Stats.MaxArmor or 0),
					StringHelpers.CommaNumber(character.Stats.CurrentMagicArmor or 0),
					StringHelpers.CommaNumber(character.Stats.MaxMagicArmor or 0))
				end
				character.Stats.CurrentVitality = character.Stats.MaxVitality
				character.Stats.CurrentArmor = character.Stats.MaxArmor or 0
				character.Stats.CurrentMagicArmor = character.Stats.MaxMagicArmor or 0
			end
		end)
		return true
	end
	return false
end

---@param level integer
function CharacterData:SetLevel(level)
	if self:Exists() then
		GameHelpers.Character.SetLevel(self:GetCharacter(), level)
		return true
	end
	return false
end

---Sets a character's scale and syncs it to clients.
---@param scale number
---@param persist boolean|nil Whether to persist the scale change through saves.
function CharacterData:SetScale(scale, persist)
	if self:Exists() then
		GameHelpers.SetScale(self:GetCharacter(), scale, persist)
		return true
	end
	return false
end

---Teleports to a position or object.
---This uses the behavior scripting teleport function so it doesn't force-teleport connected summons like Osiris' TeleportToPosition does.
---Supports a string/GameObject/number array as the target, or separate x,y,z values.
---@param targetOrX ObjectParam|vec3|number
---@param y number|nil
---@param z number|nil
function CharacterData:TeleportTo(targetOrX,y,z)
	if self:Exists() then
		local t = type(targetOrX)
		if t == "number" and y and z then
			Osi.LeaderLib_Behavior_TeleportTo(self.UUID, targetOrX, y, z)
			return true
		elseif t == "table" then
			targetOrX,y,z = table.unpack(targetOrX)
			if targetOrX and y and z  then
				Osi.LeaderLib_Behavior_TeleportTo(self.UUID, targetOrX, y, z)
				return true
			end
		elseif (t == "userdata" and targetOrX.MyGuid) or t == "string" then
			Osi.LeaderLib_Behavior_TeleportTo(self.UUID, targetOrX.MyGuid)
			return true
		end
	end
	return false
end

---Moves the character to the top of the next or current turn order.
---@param currentRound boolean|nil If true, the current turn order is updated, otherwise the next turn order is updated.
function CharacterData:JumpToTurn(currentRound)
	if self:Exists() then
		local id = self:GetCombatID()
		if id > 0 then
			local combat = Ext.Entity.GetCombat(id)
			if combat then
				---@type EsvCombatTeam[]
				local order = nil
				if currentRound == true then
					order = combat:GetCurrentTurnOrder()
				else
					order = combat:GetNextTurnOrder()
				end
				if order then
					local orderMap = {}
					for i,v in ipairs(order) do
						if v.Character.MyGuid == self.UUID then
							orderMap[v.Character.MyGuid] = -1
						else
							orderMap[v.Character.MyGuid] = i
						end
					end
					table.sort(order, function(a,b)
						return orderMap[a.Character.MyGuid] < orderMap[b.Character.MyGuid]
					end)
					if currentRound == true then
						combat:UpdateCurrentTurnOrder(order)
					else
						combat:UpdateNextTurnOrder(order)
					end
					return true
				end
			end
		end
	end
	return false
end

Classes.CharacterData = CharacterData