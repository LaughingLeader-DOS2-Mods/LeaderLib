local isClient = Ext.IsClient()

---@class SheetTalentData:SheetTalentData
local SheetTalentData = {
	Type = "SheetTalentData",
	TooltipType = "Talent",
	Value = false,
	Icon = "",
	IconWidth = 128,
	IconHeight = 128,
}

SheetTalentData.__index = function(t,k)
	local v = Classes.SheetTalentData[k] or Classes.SheetTalentData[k]
	if v then
		t[k] = v
	end
	return v
end

local defaults = {
	Icon = "",
	IconWidth = SheetTalentData.IconWidth,
	IconHeight = SheetTalentData.IconHeight,
	Value = false
}

---@protected
function SheetTalentData.SetDefaults(data)
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
---@return boolean
function SheetTalentData:GetValue(character)
	if StringHelpers.IsNullOrWhitespace(self.ID) then
		return false
	end
	if not isClient then
		return SheetManager:GetValue(GameHelpers.GetUUID(character, self.Type, self.ID, self.Mod))
	else
		return SheetManager:GetValue(GameHelpers.GetNetID(character, self.Type, self.ID, self.Mod))
	end
end

---[SERVER]
---@param character EsvCharacter|string|number
---@param value boolean
function SheetTalentData:SetValue(character, value)
	if not isClient then
		return SheetManager:SetEntryValue(character, self, value)
	end
	fprint(LOGLEVEL.WARNING, "[SheetTalentData:SetValue(%s, %s)] This function only works on the server-side.", self.ID, value)
	return false
end

Classes.SheetTalentData = SheetTalentData