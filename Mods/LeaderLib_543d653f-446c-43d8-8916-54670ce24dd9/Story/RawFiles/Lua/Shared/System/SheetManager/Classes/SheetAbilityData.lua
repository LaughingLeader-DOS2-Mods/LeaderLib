local isClient = Ext.IsClient()

---@class SheetAbilityData:SheetBaseData
local SheetAbilityData = {
	Type = "SheetAbilityData",
	TooltipType = "Ability",
	StatType = "Ability",
	Value = 0,
	Icon = "",
	IconWidth = 128,
	IconHeight = 128,
	GroupID = 0,
	IsCivil = false,
}

Classes.SheetAbilityData = SheetAbilityData

SheetAbilityData.__index = function(t,k)
	local v = Classes.SheetAbilityData[k] or Classes.SheetBaseData[k]
	if v then
		t[k] = v
	end
	return v
end

local defaults = {
	Value = 0,
	GroupID = 0,
	IsCivil = false,
	Icon = "",
	IconWidth = SheetAbilityData.IconWidth,
	IconHeight = SheetAbilityData.IconHeight,
}

---@protected
function SheetAbilityData.SetDefaults(data)
	Classes.SheetBaseData.SetDefaults(data)
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
function SheetAbilityData:GetValue(character)
	if StringHelpers.IsNullOrWhitespace(self.ID) then
		return 0
	end
	if not StringHelpers.IsNullOrWhitespace(self.BoostAttribute) then
		return self:GetBoostValue(character, 0)
	else
		if not isClient then
			return SheetManager:GetValueByEntry(self, GameHelpers.GetUUID(character))
		else
			return SheetManager:GetValueByEntry(self, GameHelpers.GetNetID(character))
		end
	end
end

---[SERVER]
---@param character EsvCharacter|EclCharacter|string|number
---@param value integer
---@param skipListenerInvoke boolean|nil If true, Listeners.OnEntryChanged invoking is skipped.
---@param skipSync boolean|nil If on the client and this is true, the value change won't be sent to the server.
function SheetAbilityData:SetValue(character, value, skipListenerInvoke, skipSync)
	return SheetManager:SetEntryValue(self, character, value, skipListenerInvoke, skipSync)
end

---@param character EsvCharacter|EclCharacter|string|number
---@param amount integer
function SheetAbilityData:ModifyValue(character, amount)
	local nextValue = self:GetValue(character) + amount
	if not isClient then
		return SheetManager:SetEntryValue(character, self, nextValue)
	else
		SheetManager:RequestValueChange(self, character, nextValue)
	end
	return false
end