local Vector3 = Classes.Vector3
local Quaternion = Classes.Quaternion

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
CharacterData.__index = CharacterData

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

---@param asVector3 boolean|nil
---@return number,number,number|Vector3
function CharacterData:GetPosition(asVector3)
	local x,y,z = GetPosition(self.UUID)
	if asVector3 == true then
		return Vector3(x,y,z)
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


--- Equips a root template, or creates and equips one if the item doesn't exist.
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
						CharacterEquipItem(self.UUID, v)
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
				CharacterEquipItem(self.UUID, item.MyGuid)
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
	end
	return false
end

Classes.CharacterData = CharacterData