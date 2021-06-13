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
	Visible = true,
	---@type CustomStatTooltipType
	TooltipType = "Stat",
	Create = false,
	Category = "",
	---@type number
	Double = nil,
	PointID = "",
	LastValue = {},
	AvailablePoints = {},
}

CustomStatData.__index = function(t,k)
	local v = Classes.CustomStatData[k] or Classes.CustomStatDataBase[k]
	if v then
		t[k] = v
	end
	return v
end

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

---Sets the stat's last value for a character.
---@param character UUID|NETID|EsvCharacter|EclCharacter
function CustomStatData:UpdateLastValue(character)
	if not StringHelpers.IsNullOrWhitespace(self.UUID) then
		if type(character) == "userdata" then
			self.LastValue[character.MyGuid] = character:GetCustomStat(self.UUID) or 0
		else
			character = Ext.GetCharacter(character)
			if character then
				self.LastValue[character.MyGuid] = character:GetCustomStat(self.UUID) or 0
			end
		end
	end
end

---@param character EsvCharacter|string|number
---@param value integer
function CustomStatData:SetValue(character, value)
	return CustomStatSystem:SetStat(character, self.ID, value, self.Mod)
end

--setmetatable(CustomStatData, CustomStatData)
Classes.CustomStatData = CustomStatData