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

function ClientCharacterData:Create(uuid, id, profile, isHost, isInCharacterCreation)
	local this = {
		UUID = uuid,
		ID = id,
		Profile = profile,
		IsHost = isHost or false,
		IsInCharacterCreation = isInCharacterCreation or false
	}
	setmetatable(this, ClientCharacterData)
	return this
end

Classes.ClientCharacterData = ClientCharacterData

---@class ClientData
local ClientData = {
	Type = "ClientData",
	Profile = "",
	---@type ClientCharacterData
	Character = {},
	IsHost = false,
}
ClientData.__index = ClientData

setmetatable(ClientData.Character, ClientCharacterData)

---@param profile string Unique profile ID.
---@param isHost boolean
---@return ClientData
function ClientData:Create(profile, isHost)
	---@type ClientData
    local this =
    {
		Profile = profile,
		IsHost = isHost or false,
	}
	setmetatable(this, self)
    return this
end

---@return EclCharacter
function ClientData:GetCharacter()
	if self.Character ~= nil and self.Character.UUID ~= "" then
		return Ext.GetCharacter(self.Character.UUID)
	end
	return nil
end

Classes.ClientData = ClientData