local isClient = Ext.IsClient()

---@class SheetStatData:SheetStatData
local SheetStatData = {
	Type = "SheetStatData",
	TooltipType = "Stat",
	Value = 0,
}

SheetStatData.__index = function(t,k)
	local v = Classes.SheetStatData[k] or Classes.SheetBaseData[k]
	if v then
		t[k] = v
	end
	return v
end

local defaults = {
	Value = 0
}

---@protected
function SheetStatData.SetDefaults(data)
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
function SheetStatData:GetValue(character)
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
function SheetStatData:SetValue(character, value)
	if not isClient then
		return SheetManager:SetEntryValue(character, self, value)
	end
	fprint(LOGLEVEL.WARNING, "[SheetBaseData:SetValue(%s, %s)] This function only works on the server-side.", self.ID, value)
	return false
end