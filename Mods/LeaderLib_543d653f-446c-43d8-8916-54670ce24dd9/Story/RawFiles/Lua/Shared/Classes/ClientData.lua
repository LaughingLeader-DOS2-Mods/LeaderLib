---@class ClientCharacterData
local ClientCharacterData = {
	Type = "ClientCharacterData",
	UUID = "",
	ID = "",
	Profile = "",
	IsHost = false,
	IsInCharacterCreation = false,
}

ClientCharacterData.__index = ClientCharacterData

function ClientCharacterData:Create(uuid, id, profile, netid, isHost, isInCharacterCreation)
	local this = {
		UUID = uuid,
		NetID = netid or -1,
		ID = id,
		Profile = profile,
		IsHost = isHost,
		IsInCharacterCreation = isInCharacterCreation
	}
	if this.IsHost == nil then
		this.IsHost = false
	end
	if this.IsInCharacterCreation == nil then
		this.IsInCharacterCreation = false
	end
	setmetatable(this, ClientCharacterData)
	return this
end

---@param character EsvCharacter|EclCharacter
function ClientCharacterData:CreateFromCharacter(character, id, profile, isHost, isInCharacterCreation)
	local this = self:Create(character.MyGuid, id, profile, isHost, isInCharacterCreation)
	this.NetID = character.NetID
	return this
end

function ClientCharacterData:Set(id, profile, uuid, netid, isHost, isInCharacterCreation)
	if id ~= nil then
		self.ID = id
	end
	if profile ~= nil then
		self.Profile = profile
	end
	if uuid ~= nil then
		self.UUID = uuid
	end
	if netid ~= nil then
		self.NetID = netid
	end
	if isHost ~= nil then
		self.IsHost = isHost
	end
	if isInCharacterCreation ~= nil then
		self.IsInCharacterCreation = isInCharacterCreation
	end
end

Classes.ClientCharacterData = ClientCharacterData

---@class ClientData
local ClientData = {
	Type = "ClientData",
	Profile = "",
	ID = -1,
	---@type ClientCharacterData
	Character = {},
	IsHost = false,
}
ClientData.__index = ClientData

setmetatable(ClientData.Character, ClientCharacterData)

---@param profile string Unique profile ID.
---@param isHost boolean
---@return ClientData
function ClientData:Create(profile, id, isHost)
	---@type ClientData
    local this =
    {
		Profile = profile,
		IsHost = isHost,
		ID = id or -1,
	}
	if this.IsHost == nil then
		this.IsHost = false
	end
	setmetatable(this, self)
    return this
end

---@return EclCharacter
function ClientData:GetCharacter()
	local character = nil
	if self.Character ~= nil then
		if self.Character.NetID ~= -1 then
			character = Ext.GetCharacter(self.Character.NetID)
		end
		if character == nil and not StringHelpers.IsNullOrEmpty(self.Character.UUID) then
			character = Ext.GetCharacter(self.Character.UUID)
		end
	end
	return character
end

function ClientData:Set(id, profile, isHost, character)
	if id ~= nil then
		self.ID = id
	end
	if profile ~= nil then
		self.Profile = profile
	end
	if isHost ~= nil then
		self.IsHost = isHost
	end
	if character ~= nil then
		self.Character = character
	end
end

Classes.ClientData = ClientData