local isClient = Ext.IsClient()

---@class SheetEntryData:SheetEntryDataBase
local SheetEntryData = {
	Type="SheetEntryData",
	ID = "",
	---@type MOD_UUID
	Mod = "",
	DisplayName = "",
	Description = "",
	Icon = "",
	IconWidth = 128,
	IconHeight = 128,
	Visible = true,
	TooltipType = "Stat",
	---@type table<NETID,table<string,boolean>>
	Enabled = {}
}

local defaults = {
	ID = "",
	Mod = "",
	DisplayName = "",
	Description = "",
	Icon = "",
	IconWidth = SheetEntryData.IconWidth,
	IconHeight = SheetEntryData.IconHeight,
	Visible = true,
	TooltipType = "Talent",
	Enabled = {},
	--DisplayValueInTooltip = false -- Should be nil by default if not set by user
}

---@protected
function SheetEntryData.SetDefaults(data)
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
function SheetEntryData:GetValue(character)
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
function SheetEntryData:GetLastValue(character)
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
function SheetEntryData:SetValue(character, value)
	if not isClient then
		if value > STAT_VALUE_MAX then
			value = STAT_VALUE_MAX
		end
		return CustomStatSystem:SetStat(character, self.ID, value, self.Mod)
	end
	fprint(LOGLEVEL.WARNING, "[SheetEntryData:SetValue(%s, %s)] This function only works on the server-side.", self.ID, value)
	return false
end

---[SERVER]
---Adds an amount to the value. Can be negative.
---@param character EsvCharacter|string|number
---@param amount integer
function SheetEntryData:ModifyValue(character, amount)
	if not isClient then
		return CustomStatSystem:ModifyStat(character, self.ID, amount, self.Mod)
	end
	fprint(LOGLEVEL.WARNING, "[SheetEntryData:ModifyValue(%s, %s)] This function only works on the server-side.", self.ID, amount)
	return false
end

---[SERVER]
---@param character EsvCharacter|string|number
---@param amount integer
function SheetEntryData:AddAvailablePoints(character, amount)
	if not isClient then
		return CustomStatSystem:AddAvailablePoints(character, self, amount)
	else
		fprint(LOGLEVEL.WARNING, "[SheetEntryData:AddAvailablePoints(%s, %s, %s)] [WARNING] - This function is server-side only!", self.ID, character, amount)
	end
end

---Get the amount of available points for this stat's PointID or ID for a specific character.
---Server-side uses MyGuid for the character, client-side uses NetID.
---@param character EsvCharacter|EclCharacter|UUID|NETID
---@return integer
function SheetEntryData:GetAvailablePoints(character)
	if isClient then
		return self.AvailablePoints[GameHelpers.GetNetID(character)]
	else
		return self.AvailablePoints[GameHelpers.GetUUID(character)]
	end
end

---@protected
---Sets the stat's last value for a character.
---@param character EsvCharacter|EclCharacter|UUID|NETID
function SheetEntryData:UpdateLastValue(character)
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
				fprint(LOGLEVEL.WARNING, "[SheetEntryData:UpdateLastValue:%s] Set LastValue for (%s) to (%s) [%s]", self.Type, characterId, value, Ext.IsServer() and "SERVER" or "CLIENT")
			end
			self.LastValue[characterId] = value
		end
	end
end

Classes.SheetEntryData = SheetEntryData