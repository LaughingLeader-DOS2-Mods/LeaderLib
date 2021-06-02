---A global table used to update instances of CharacterData with the character's NetID.
MonitoredCharacterData = {
	---@type CharacterData[]
	Entries = {}
}
MonitoredCharacterData.__index = MonitoredCharacterData

---@param region string
function MonitoredCharacterData:Update(region)
	for i=1,#self.Entries do
		local entry = self.Entries[i]
		if entry then
			local character = entry:GetCharacter()
			if character then
				entry.Region = region
				entry.NetID = character.NetID
			end
		end
	end
end

---A wrapper around common character queries with additional character-related helpers.
---@class CharacterData
local CharacterData = {
	Type = "CharacterData",
	UUID = "",
	NetID = -1,
	Region = ""
}

setmetatable(CharacterData, {
	__index = CharacterData,
	---@param uuid string
	---@param params table<string,any>|nil
	__call = function(_, uuid, params)
		return CharacterData:Create(uuid, params)
	end,
	---@param self CharacterData
	__tostring = function(self)
		local character = self:GetCharacter()
		if character then
			return string.format("[CharacterData] DisplayName(%s) UUID(%s) NetID(%s) StatsId(%s)", character.DisplayName, self.UUID, character.NetID, character.Stats.Name)
		else
			return string.format("[CharacterData] UUID(%s)", self.UUID)
		end
	end
})
-- CharacterData.__index = function(tbl, key)
-- 	if key == "NetID" and tbl.NetID == -1 and tbl.UUID ~= "" then
-- 		local character = Ext.GetCharacter(tbl.UUID)
-- 		if character then
-- 			tbl.NetID = character.NetID
-- 			return character.NetID
-- 		end
-- 	elseif key == "Region" and tbl.Region == "" and tbl.UUID ~= "" then
-- 		local region = GetRegion(tbl.UUID) or ""
-- 		tbl.Region = region
-- 		return region
-- 	end
-- 	return tbl[key]
-- end

---@param uuid string
---@param params table<string,any>|nil
---@return CharacterData
function CharacterData:Create(uuid, params)
    local this =
    {
		UUID = uuid or "",
		--AutoUpdate properties
		NetID = -1,
		Region = ""
	}
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
	setmetatable(this, self)
	if this.AutoUpdate == true then
		MonitoredCharacterData.Entries[#MonitoredCharacterData.Entries+1] = this
	end
    return this
end

---@return boolean
function CharacterData:Exists()
	return not StringHelpers.IsNullOrEmpty(self.UUID) and ObjectExists(self.UUID) == 1
end

---Fetches the EsvCharacter associated with this character's UUID.
---@return EsvCharacter|nil
function CharacterData:GetCharacter()
	if self:Exists() then
		return Ext.GetCharacter(self.UUID)
	end
	return nil
end

---@param allowPlayingDead boolean
---@return boolean
function CharacterData:IsDead(allowPlayingDead)
	return allowPlayingDead ~= true and CharacterIsDead(self.UUID) == 1 or CharacterIsDeadOrFeign(self.UUID) == 1
end

---@return boolean
function CharacterData:IsInCombat()
	return CharacterIsInCombat(self.UUID) == 1 or Common.OsirisDatabaseHasAnyEntry(Osi.DB_CombatCharacters:Get(self.UUID, nil))
end

---@return integer
function CharacterData:GetCombatID()
	local id = CombatGetIDForCharacter(self.UUID)
	if id > 0 then
		return id
	end
	local db = Osi.DB_CombatCharacters:Get(self.UUID, nil)
	if db and #db > 0 then
		id = db[1][2]
		if id > 0 then
			return id
		end
	end
	return 0
end

---@param asVector3 boolean|nil
---@return number,number,number|Vector3
function CharacterData:GetPosition(asVector3)
	local x,y,z = GetPosition(self.UUID)
	if asVector3 == true then
		return Classes.Vector3(x,y,z)
	else
		return x,y,z
	end
end

---@param status string|string[]
---@return boolean
function CharacterData:HasActiveStatus(status)
	if type(status) == "table" then
		for i,v in pairs(status) do
			if self:IsStatusActive(v) then
				return true
			end
		end
	else
		return HasActiveStatus(self.UUID, status) == 1
	end
	return false
end

---@param force boolean|nil Forces the stage change, otherwise it's skipped if they're already on stage.
function CharacterData:SetOffStage(force)
	if self:Exists() then
		if force == true or ObjectIsOnStage(self.UUID) == 1 then
			SetOnStage(self.UUID, 0)
			return true
		end
	end
	return false
end

---@param force boolean|nil Forces the stage change, otherwise it's skipped if they're already on stage.
function CharacterData:SetOnStage(force)
	if self:Exists() then
		if force == true or ObjectIsOnStage(self.UUID) == 0 then
			SetOnStage(self.UUID, 1)
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
		if HasActiveStatus(self.UUID, status) == 0 then
			ApplyStatus(self.UUID, status, duration or 6.0, force and 1 or 0, source or self.UUID)
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

---Equips a root template, or creates and equips one if the item doesn't exist.
---@param template string
---@param all boolean|nil Equip all instances.
---@return EsvItem|EsvItem[]
function CharacterData:EquipTemplate(template, all)
	local character = self:GetCharacter()
	if character then
		local items = character:GetInventoryItems()
		-- Slots 1-13 are equipment slots
		if items and #items > 13 then
			local foundItems
			if all == true then
				foundItems = {}
			end
			for i=14,#items do
				local v = items[i]
				local item = Ext.GetItem(v)
				if item and item.RootTemplate and item.RootTemplate.Id == template then
					if ItemIsEquipable(v) == 1 then
						NRD_CharacterEquipItem(self.UUID, v, item.Stats.Slot, 0, 0, 1, 1)
						--CharacterEquipItem(self.UUID, v)
						if all ~= true then
							return item
						else
							foundItems[#foundItems+1] = item
						end
						--NRD_CharacterEquipItem(self.UUID, v, item.Stats.ItemSlot, 0, 0, 1, 1)
					end
				end
			end
			return foundItems
		end
		local item = GameHelpers.Item.CreateItemByTemplate(template)
		if item then
			ItemToInventory(item.MyGuid, self.UUID)
			if ItemIsEquipable(item.MyGuid) == 1 then
				--CharacterEquipItem(self.UUID, item.MyGuid)
				NRD_CharacterEquipItem(self.UUID, item.MyGuid, item.Stats.Slot, 0, 0, 1, 1)
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
			CharacterResurrect(self.UUID)
		end
		CharacterSetHitpointsPercentage(self.UUID, 100.0)
		CharacterSetArmorPercentage(self.UUID, 100.0)
		CharacterSetMagicArmorPercentage(self.UUID, 100.0)
		ApplyStatus(self.UUID, "LEADERLIB_RECALC", 0.0, 1, self.UUID)
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
function CharacterData:SetScale(scale)
	if self:Exists() then
		GameHelpers.SetScale(self:GetCharacter(), scale)
		return true
	end
	return false
end

---Teleports to a position or object.
---This uses the behavior scripting teleport function so it doesn't force-teleport connected summons like Osiris' TeleportToPosition does.
---Supports a string/EsvGameObject/number array as the target, or separate x,y,z values.
---@param targetOrX number|number[]|string|EsvGameObject
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
			local combat = Ext.GetCombat(id)
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