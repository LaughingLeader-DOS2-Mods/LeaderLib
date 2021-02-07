local Vector3 = Classes.Vector3
local Quaternion = Classes.Quaternion

---A wrapper around common character queries with additional character-related helpers.
---@class CharacterData
local CharacterData = {
	Type = "CharacterData",
	UUID = "",
	NetID = nil
}
CharacterData.__index = CharacterData

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

---Fetches the EsvCharacter associated with this character's UUID.
---@return EsvCharacter|nil
function CharacterData:GetCharacter()
	return Ext.GetCharacter(self.UUID)
end

---@return boolean
function CharacterData:Exists()
	return not StringHelpers.IsNullOrEmpty(self.UUID) and ObjectExists(self.UUID) == 1
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

function CharacterData:SetOffStage()
	if self:Exists() then
		SetOnStage(self.UUID, 0)
		return true
	end
	return false
end

function CharacterData:SetOnStage()
	if self:Exists() then
		SetOnStage(self.UUID, 1)
		return true
	end
	return false
end

Classes.CharacterData = CharacterData