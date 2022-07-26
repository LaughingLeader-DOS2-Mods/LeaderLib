---@class ClientCharacterPointsData
---@field Attribute integer
---@field Ability integer
---@field Civil integer
---@field Talent integer
---@field SourceBase integer
---@field SourceCurrent integer
---@field SourceMax integer

local isClient = Ext.IsClient()
local _EXTVERSION = Ext.Version()

---@class ClientCharacterData
---@field Points ClientCharacterPointsData
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
	Username = "",
	Points = {
		Attribute = 0,
		Ability = 0,
		Civil = 0,
		Talent = 0,
		SourceBase = 0,
		SourceCurrent = 0,
		SourceMax = 0
	}
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
		Points = {},
		Username = ""
	}
	if params and type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	if not isClient then
		this.Points = {}
		setmetatable(this.Points, {
			__index = function(tbl,k)
				if k == "Attribute" then return CharacterGetAttributePoints(this.UUID) end
				if k == "Ability" then return CharacterGetAbilityPoints(this.UUID) end
				if k == "Civil" then return CharacterGetCivilAbilityPoints(this.UUID) end
				if k == "Talent" then return CharacterGetTalentPoints(this.UUID) end
				if k == "SourceBase" then return CharacterGetBaseSourcePoints(this.UUID) end
				if k == "SourceCurrent" then return CharacterGetSourcePoints(this.UUID) end
				if k == "SourceMax" then return CharacterGetMaxSourcePoints(this.UUID) end
				error(string.format("[LeaderLib:ClientCharacterData] Invalid key for Points: (%s)", k), 2)
			end
		})
	end
	setmetatable(this, ClientCharacterData)
	return this
end

---@param params ClientCharacterDataParams|nil
function ClientCharacterData:Update(params)
	if params and type(params) == "table" then
		for k,v in pairs(params) do
			self[k] = v
		end
	end
	self:UpdatePoints(self.UUID)
	return self
end

---@return EclCharacter|EsvCharacter
function ClientCharacterData:GetCharacter()
	return GameHelpers.GetCharacter(self.NetID or self.UUID)
end

---@private
function ClientCharacterData:UpdatePoints(uuid)
	local uuid = uuid or self.UUID
	if not uuid then
		local character = self:GetCharacter()
		if character then
			uuid = character.MyGuid
		end
	end
	if uuid then
		self.Points.Attribute = CharacterGetAttributePoints(uuid) or 0
		self.Points.Ability = CharacterGetAbilityPoints(uuid) or 0
		self.Points.Civil = CharacterGetCivilAbilityPoints(uuid) or 0
		self.Points.Talent = CharacterGetTalentPoints(uuid) or 0
		self.Points.SourceBase = CharacterGetBaseSourcePoints(uuid) or 0
		self.Points.SourceCurrent = CharacterGetSourcePoints(uuid) or 0
		self.Points.SourceMax = CharacterGetMaxSourcePoints(uuid) or 0
	end
end

---@private
---@return ClientCharacterData
function ClientCharacterData:Export()
	self:Update()
	local data = {
		UUID = self.UUID,
		NetID = self.NetID,
		ID = self.ID,
		Profile = self.Profile,
		IsHost = self.IsHost,
		IsInCharacterCreation = self.IsInCharacterCreation,
		IsPossessed = self.IsPossessed,
		IsGameMaster = self.IsGameMaster,
		IsPlayer = self.IsPlayer,
		Username = self.Username,
		Points = {
			Attribute = self.Points.Attribute or 0,
			Ability = self.Points.Ability or 0,
			Civil = self.Points.Civil or 0,
			Talent = self.Points.Talent or 0,
			SourceBase = self.Points.SourceBase or 0,
			SourceCurrent = self.Points.SourceCurrent or 0,
			SourceMax = self.Points.SourceMax or 0
		}
	}
	return data
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
---@param id integer|nil
---@param isHost boolean|nil
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
			character = GameHelpers.GetCharacter(self.Character.NetID)
		end
		if character == nil and not StringHelpers.IsNullOrEmpty(self.Character.UUID) then
			character = GameHelpers.GetCharacter(self.Character.UUID)
		end
	end
	if character == nil then
		character = GameHelpers.Client.GetCharacter()
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
	-- if Vars.DebugMode then
	-- 	fprint(LOGLEVEL.TRACE, "[LeaderLib:ClientData:SetClientData] ID(%s) UUID(%s) Profile(%s) IsHost(%s) Character(%s)", self.ID, self.Character.UUID, self.Profile, self.Profile, self.IsHost, self.Character)
	-- end
end

---@private
---@return ClientData
function ClientData:Export()
	local data = {
		ID = self.ID,
		Profile = self.Profile,
		IsHost = self.IsHost,
		Character = self.Character:Export()
	}
	return data
end

Classes.ClientData = ClientData