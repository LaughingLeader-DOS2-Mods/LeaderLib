local isClient = Ext.IsClient()

---@class STAT_DISPLAY_MODE
local STAT_DISPLAY_MODE = {
	Default = "Integer",
	Percentage = "Percentage"
}

---@class CustomStatData:CustomStatDataBase
local CustomStatData = {
	Type="CustomStatData",
	ID = "",
	---@type UUID
	UUID = "",
	---@type MOD_UUID
	Mod = "",
	DisplayName = "",
	Description = "",
	Icon = "",
	IconWidth = 128,
	IconHeight = 128,
	Visible = true,
	---@type CustomStatTooltipType
	TooltipType = "Stat",
	Create = false,
	Category = "",
	---@type number
	Double = nil,
	PointID = "",
	---@type table<NETID,table<string,integer>>
	LastValue = {},
	---@type table<NETID,table<string,integer>>
	AvailablePoints = {},
	DisplayMode = STAT_DISPLAY_MODE.Default,
	STAT_DISPLAY_MODE = STAT_DISPLAY_MODE
}

CustomStatData.__index = function(t,k)
	local v = Classes.CustomStatData[k] or Classes.CustomStatDataBase[k]
	if v then
		t[k] = v
	end
	return v
end

local canUseRawFunctions = Ext.Version() >= 55

Classes.UnregisteredCustomStatData = {
	Type = "UnregisteredCustomStatData",
	IsUnregistered = true,
	LastValue = {},
	__index = function(tbl,k)
		if k == "Type" then
			return "UnregisteredCustomStatData"
		end
		if canUseRawFunctions then
			local v = rawget(Classes.UnregisteredCustomStatData, k)
			if v then
				tbl[k] = v
				return v
			end
		end
		return Classes.CustomStatData[k] or Classes.CustomStatDataBase[k]
	end
}

local defaults = {
	ID = "",
	UUID = "",
	Mod = "",
	DisplayName = "",
	Description = "",
	Icon = "",
	Visible = true,
	TooltipType = "Stat",
	Create = false,
	Category = "",
	Double = nil,
	PointID = "",
	LastValue = {},
	AvailablePoints = {},
	--DisplayValueInTooltip = false -- Should be nil by default if not set by user
}

---@protected
function CustomStatData.SetDefaults(data)
	for k,v in pairs(defaults) do
		if data[k] == nil then
			if type(v) == "table" then
				data[k] = {}
			else
				data[k] = v
			end
		end
	end
end

---@param character UUID|NETID|EsvCharacter|EclCharacter
---@return integer
function CustomStatData:GetValue(character)
	if StringHelpers.IsNullOrWhitespace(self.UUID) then
		return 0
	end
	if type(character) == "userdata" then
		return character:GetCustomStat(self.UUID) or 0
	else
		character = Ext.GetCharacter(character)
		if character then
			return character:GetCustomStat(self.UUID) or 0
		end
	end
	return 0
end

---@param character UUID|NETID|EsvCharacter|EclCharacter
---@return integer|boolean Returns false if it's never been set.
function CustomStatData:GetLastValue(character)
	local characterId = character
	if not isClient then
		characterId = GameHelpers.GetUUID(character)
	else
		characterId = GameHelpers.GetNetID(character)
	end
	return self.LastValue[characterId] or false
end

---[SERVER]
---@param character EsvCharacter|string|number
---@param value integer
function CustomStatData:SetValue(character, value)
	if not isClient then
		return CustomStatSystem:SetStat(character, self.ID, value, self.Mod)
	end
	fprint(LOGLEVEL.WARNING, "[CustomStatData:SetValue(%s, %s)] This function only works on the server-side.", self.ID, value)
	return false
end

---[SERVER]
---Adds an amount to the value. Can be negative.
---@param character EsvCharacter|string|number
---@param amount integer
function CustomStatData:ModifyValue(character, amount)
	if not isClient then
		return CustomStatSystem:ModifyStat(character, self.ID, amount, self.Mod)
	end
	fprint(LOGLEVEL.WARNING, "[CustomStatData:ModifyValue(%s, %s)] This function only works on the server-side.", self.ID, amount)
	return false
end

---[SERVER]
---@param character EsvCharacter|string|number
---@param amount integer
function CustomStatData:AddAvailablePoints(character, amount)
	if not isClient then
		return CustomStatSystem:AddAvailablePoints(character, self, amount)
	else
		fprint(LOGLEVEL.WARNING, "[CustomStatData:AddAvailablePoints(%s, %s, %s)] [WARNING] - This function is server-side only!", self.ID, character, amount)
	end
end

---Get the amount of available points for this stat's PointID or ID for a specific character.
---Server-side uses MyGuid for the character, client-side uses NetID.
---@param character EsvCharacter|EclCharacter|UUID|NETID
---@return integer
function CustomStatData:GetAvailablePoints(character)
	if isClient then
		return self.AvailablePoints[GameHelpers.GetNetID(character)]
	else
		return self.AvailablePoints[GameHelpers.GetUUID(character)]
	end
end

---@protected
---Sets the stat's last value for a character.
---@param character EsvCharacter|EclCharacter|UUID|NETID
function CustomStatData:UpdateLastValue(character)
	if not StringHelpers.IsNullOrWhitespace(self.UUID) then
		local characterId = character
		if not isClient then
			characterId = GameHelpers.GetUUID(character)
		else
			characterId = GameHelpers.GetNetID(character)
		end
		local value = self:GetValue(type(character) == "userdata" and character or characterId)
		if value then
			if Vars.DebugMode and Vars.Print.CustomStats then
				fprint(LOGLEVEL.WARNING, "[CustomStatData:UpdateLastValue:%s] Set LastValue for (%s) to (%s) [%s]", self.Type, characterId, value, Ext.IsServer() and "SERVER" or "CLIENT")
			end
			self.LastValue[characterId] = value
		end
	end
end

--setmetatable(CustomStatData, CustomStatData)
Classes.CustomStatData = CustomStatData