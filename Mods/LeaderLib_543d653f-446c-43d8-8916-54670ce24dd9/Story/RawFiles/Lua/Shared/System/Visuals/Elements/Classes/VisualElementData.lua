---@param self VisualElementData
---@param char EsvCharacter
---@param item EsvItem
---@param equipped boolean
local function OnEquipmentChanged(self, char, item, equipped)
	local stat = Ext.Stats.Get(item.Stats.Name)
	local armorType = stat.ArmorType
	local slot = GameHelpers.Item.GetEquippedSlot(char.MyGuid, item.MyGuid) or item.Stats.Slot
	if not equipped then
		armorType = "None"
	end
	self:ApplyVisualsForArmorType(char, armorType, slot)
end

---@class VisualElementData
local VisualElementData = {
	Type = "VisualElementData",
	---@type table<string, VisualResourceData>
	Visuals = {},
	VisualSet = "",
	OnEquipmentChanged = OnEquipmentChanged,
	OnEquipmentChangedDefault = OnEquipmentChanged
}
VisualElementData.__index = VisualElementData

---@param params table|nil
---@return VisualElementData
function VisualElementData:Create(params)
	---@type VisualElementData
    local this =
    {
		Visuals = {
			None = {},
			Cloth = {},
			Leather = {},
			Mail = {},
			Plate = {},
			Robe = {}
		},
		VisualSet = ""
	}
	setmetatable(this, self)
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
    return this
end

---@param resource string
---@param armorType string
---@param slot string
---@param visualSlot integer
---@param params table|nil
---@return VisualElementData
function VisualElementData:AddVisualForSlot(resource, armorType, slot, visualSlot, params)
	local armorTypeData = self.Visuals[armorType]
	if armorTypeData == nil then
		armorTypeData = {}
		self.Visuals[armorType] = armorTypeData
	end
	if armorTypeData[slot] == nil then
		armorTypeData[slot] = {}
	end
	table.insert(armorTypeData[slot], Classes.VisualResourceData:Create(resource, visualSlot, params))
end

---@param armorType string
---@param visuals table<string,VisualResourceData[]>
---@return VisualElementData
function VisualElementData:AddVisualsForType(armorType, visuals)
	if self == nil or armorType == nil or visuals == nil then
		return
	end
	local armorTypeData = self.Visuals[armorType]
	if armorTypeData == nil then
		armorTypeData = {}
		self.Visuals[armorType] = armorTypeData
	end
	for slot,data in pairs(visuals) do
		if armorTypeData[slot] == nil then
			armorTypeData[slot] = {}
		end
		if type(data) == "table" and data.Type ~= "VisualResourceData" then
			for i,v in pairs(data) do
				table.insert(armorTypeData[slot], v)
			end
		else
			table.insert(armorTypeData[slot], data)
		end
	end
end

---@param armorType string
---@param slot string
---@return VisualResourceData[]
function VisualElementData:GetVisuals(armorType, slot)
	if self.Visuals ~= nil then
		local armorTypeData = self.Visuals[armorType]
		if armorTypeData ~= nil then
			return armorTypeData[slot]
		end
	end
	return nil
end

---@param char EsvCharacter
---@param armorType string
---@param slot string
function VisualElementData:ApplyVisualsForArmorType(char, armorType, slot)
	local visualElements = self:GetVisuals(armorType, slot)
	if visualElements ~= nil then
		for i,element in pairs(visualElements) do
			local changeVisual = true
			if armorType == "None" and element.IfEmpty ~= "" then
				local otherItem = char.Stats:GetItemBySlot(element.IfEmpty)
				if otherItem ~= nil then
					changeVisual = false
				end
			end
			if changeVisual then
				element:SetVisualOnCharacter(char.MyGuid)
				if Vars.DebugMode then
					fprint(LOGLEVEL.DEFAULT, "[LeaderLib:OnEquipmentChanged] char(%s) ArmorType(%s) Slot(%s) Resource(%s) VisualSet(%s)", char.MyGuid, armorType, slot, element.Resource, self.VisualSet)
				end
			end
		end
	end
end

Classes.VisualElementData = VisualElementData