---@class ClientCharacterData
local ClientCharacterData = {
	Type = "ClientCharacterData",
	UUID = "",
	ID = -1,
	Profile = "",
	IsHost = false,
	IsInCharacterCreation = false,
	NetID = -1,
	IsPossessed = false,
	IsGameMaster = false,
	IsPlayer = true,
}

ClientCharacterData.__index = ClientCharacterData

---@alias ClientCharacterDataParams ClientCharacterData

local default = Common.GetValueOrDefault

---@param params ClientCharacterDataParams|table
---@return ClientCharacterData
function ClientCharacterData:Create(params)
	local this = {
		UUID = "",
		NetID = -1,
		ID = -1,
		Profile = "",
		IsHost = false,
		IsInCharacterCreation = false,
		IsPossessed = false,
		IsGameMaster = false,
		IsPlayer = true,
	}
	if params and type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	setmetatable(this, ClientCharacterData)
	return this
end

---@param params ClientCharacterDataParams|table
function ClientCharacterData:Update(params)
	if params and type(params) == "table" then
		for k,v in pairs(params) do
			self[k] = v
		end
	end
	return self
end

---@return EclCharacter|EsvCharacter
function ClientCharacterData:GetCharacter()
	return Ext.GetCharacter(self.NetID or self.UUID)
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
	if not self then
		self = Client
	end
	local character = nil
	if self.Character ~= nil then
		if self.Character.NetID ~= -1 and self.Character.NetID ~= nil then
			character = Ext.GetCharacter(self.Character.NetID)
		end
		if character == nil and not StringHelpers.IsNullOrEmpty(self.Character.UUID) then
			character = Ext.GetCharacter(self.Character.UUID)
		end
		if character == nil then
			character = GameHelpers.Client.GetCharacter()
		end
	end
	return character
end

---@return ClientCharacterData
function ClientData:GetCharacterData()
	if not self then
		self = Client
	end
	if self.Character then
		return self.Character
	end
	return nil
end

---@param id integer
---@param profile string
---@param isHost boolean
---@param character ClientCharacterData
function ClientData:SetClientData(id, profile, isHost, character)
	if not self then
		self = Client
	end
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
	if Vars.DebugMode then
		fprint(LOGLEVEL.DEFAULT, "[LeaderLib:ClientData:SetClientData] ID(%s) UUID(%s) Profile(%s) IsHost(%s) Character(%s)", self.ID, self.Character.UUID, self.Profile, self.Profile, self.IsHost, self.Character)
	end
end

Classes.ClientData = ClientData