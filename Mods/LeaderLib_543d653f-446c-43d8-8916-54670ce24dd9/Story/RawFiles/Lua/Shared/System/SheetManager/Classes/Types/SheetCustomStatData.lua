local isClient = Ext.IsClient()

---@class STAT_DISPLAY_MODE
local STAT_DISPLAY_MODE = {
	Default = "Integer",
	Percentage = "Percentage"
}

---@class SheetCustomStatData:SheetCustomStatBase
local SheetCustomStatData = {
	Type="SheetCustomStatData",
	StatType = "Custom",
	---If true, the custom stat is created automatically on the server.
	Create = false,
	---A category ID this stat belongs to, if any.
	Category = "",
	---A generated ID assigned by the SheetManager, used to associate a stat in the UI with this data. In GM mode, this is also the double handle.
	GeneratedID = -1,
	---An ID to use for a common pool of available points.
	PointID = "",
	---@private
	---@type table<NETID,table<string,integer>>
	LastValue = {},
	---@private
	---@type table<NETID,table<string,integer>>
	AvailablePoints = {},
	---Alternative display modes for a stat, such as percentage display.
	DisplayMode = STAT_DISPLAY_MODE.Default,
	---Enum values for DisplayMode.
	STAT_DISPLAY_MODE = STAT_DISPLAY_MODE,
	---If set, the add button logic will check the current amount against this value when determining if the stat can be added to.
	---@type integer
	MaxAmount = nil,
	---Text to append to the value display, such as a percentage sign.
	Suffix = "",
	AutoAddAvailablePointsOnRemove = true,
}

SheetCustomStatData.__index = function(tbl,k)
	local v = SheetCustomStatData[k] or Classes.SheetCustomStatBase[k]
	return v
end

local defaults = {
	Create = SheetCustomStatData.Create,
	Category = SheetCustomStatData.Category,
	GeneratedID = SheetCustomStatData.GeneratedID,
	PointID = SheetCustomStatData.PointID,
	LastValue = {},
	AvailablePoints = {},
	DisplayMode = SheetCustomStatData.DisplayMode,
	MaxAmount = SheetCustomStatData.MaxAmount,
	Suffix = SheetCustomStatData.Suffix,
	AutoAddAvailablePointsOnRemove = SheetCustomStatData.AutoAddAvailablePointsOnRemove,
}

local ID_MAP = 0

---@protected
function SheetCustomStatData.SetDefaults(data)
	Classes.SheetCustomStatBase.SetDefaults(data)
	for k,v in pairs(defaults) do
		if data[k] == nil then
			if type(v) == "table" then
				data[k] = {}
			else
				data[k] = v
			end
		end
	end
	if not CustomStatSystem:GMStatsEnabled() then
		data.GeneratedID = ID_MAP
		ID_MAP = ID_MAP + 1
	end
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
		return Classes.SheetCustomStatData[k] or Classes.SheetCustomStatBase[k]
	end
}

---@param character UUID|NETID|EsvCharacter|EclCharacter
---@return integer
function SheetCustomStatData:GetValue(character)
	if type(character) == "userdata" then
		return CustomStatSystem:GetStatValueForCharacter(character, self) or 0
	else
		character = Ext.GetCharacter(character)
		if character then
			return CustomStatSystem:GetStatValueForCharacter(character, self) or 0
		end
	end
	return 0
end

---@param character UUID|NETID|EsvCharacter|EclCharacter
---@return integer|boolean Returns false if it's never been set.
function SheetCustomStatData:GetLastValue(character)
	local characterId = character
	if not isClient then
		characterId = GameHelpers.GetUUID(character)
	else
		characterId = GameHelpers.GetNetID(character)
	end
	return self.LastValue[characterId] or false
end

local STAT_VALUE_MAX = 2147483647

---[SERVER]
---@param character EsvCharacter|string|number
---@param value integer
function SheetCustomStatData:SetValue(character, value)
	if value > STAT_VALUE_MAX then
		value = STAT_VALUE_MAX
	end
	return CustomStatSystem:SetStat(character, self, value)
end

---[SERVER]
---Adds an amount to the value. Can be negative.
---@param character EsvCharacter|string|number
---@param amount integer
function SheetCustomStatData:ModifyValue(character, amount)
	return self:SetValue(character, self:GetValue(character) + amount)
end

---[SERVER]
---@param character EsvCharacter|string|number
---@param amount integer
function SheetCustomStatData:AddAvailablePoints(character, amount)
	if not isClient then
		return CustomStatSystem:AddAvailablePoints(character, self, amount)
	else
		fprint(LOGLEVEL.WARNING, "[SheetCustomStatData:AddAvailablePoints(%s, %s, %s)] [WARNING] - This function is server-side only!", self.ID, character, amount)
	end
end

---Get the amount of available points for this stat's PointID or ID for a specific character.
---Server-side uses MyGuid for the character, client-side uses NetID.
---@param character EsvCharacter|EclCharacter|UUID|NETID
---@return integer
function SheetCustomStatData:GetAvailablePoints(character)
	if isClient then
		return self.AvailablePoints[GameHelpers.GetNetID(character)]
	else
		return self.AvailablePoints[GameHelpers.GetUUID(character)]
	end
end

---@protected
---Sets the stat's last value for a character.
---@param character EsvCharacter|EclCharacter|UUID|NETID
function SheetCustomStatData:UpdateLastValue(character)
	local characterId = character
	if not isClient then
		characterId = GameHelpers.GetUUID(character)
	else
		characterId = GameHelpers.GetNetID(character)
	end
	local value = self:GetValue(type(character) == "userdata" and character or characterId)
	if value then
		if Vars.DebugMode and Vars.Print.CustomStats then
			fprint(LOGLEVEL.WARNING, "[SheetCustomStatData:UpdateLastValue:%s] Set LastValue for (%s) to (%s) [%s]", self.Type, characterId, value, Ext.IsServer() and "SERVER" or "CLIENT")
		end
		self.LastValue[characterId] = value
	end
end

--setmetatable(SheetCustomStatData, SheetCustomStatData)
Classes.SheetCustomStatData = SheetCustomStatData