local isClient = Ext.IsClient()

---@class SheetAbilityData:SheetBaseData
local SheetAbilityData = {
	Type = "SheetAbilityData",
	TooltipType = "Ability",
	Value = 0,
	Icon = "",
	IconWidth = 128,
	IconHeight = 128,
	GroupID = 0,
	IsCivil = false
}

SheetAbilityData.__index = function(t,k)
	local v = Classes.SheetAbilityData[k] or Classes.SheetBaseData[k]
	if v then
		t[k] = v
	end
	return v
end

local defaults = {
	Icon = "",
	IconWidth = SheetAbilityData.IconWidth,
	IconHeight = SheetAbilityData.IconHeight,
	Value = 0,
	GroupID = 0,
	IsCivil = false
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
	if not isClient then
		return SheetManager:GetValue(GameHelpers.GetUUID(character, self.ID, self.Mod))
	else
		return SheetManager:GetValue(GameHelpers.GetNetID(character, self.ID, self.Mod))
	end
end

---[SERVER]
---@param character EsvCharacter|string|number
---@param value integer
function SheetAbilityData:SetValue(character, value)
	if not isClient then
		return SheetManager:SetEntryValue(character, self, value)
	end
	fprint(LOGLEVEL.WARNING, "[SheetBaseData:SetValue(%s, %s)] This function only works on the server-side.", self.ID, value)
	return false
end

Classes.SheetAbilityData = SheetAbilityData