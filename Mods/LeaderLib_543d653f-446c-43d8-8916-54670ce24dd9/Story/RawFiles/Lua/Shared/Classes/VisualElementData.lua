---@class VisualResourceData
local VisualResourceData = {
	Type = "VisualResourceData",
	Resource = "",
	VisualSlot = -1,
	IfEmpty = "",
}
VisualResourceData.__visualSlot = VisualResourceData

---@param resourceName string
---@param visualSlot integer
---@param params table|nil
---@return VisualResourceData
function VisualResourceData:Create(resourceName, visualSlot, params)
	---@type VisualResourceData
    local this =
    {
		Resource = resourceName,
		VisualSlot = visualSlot,
	}
	setmetatable(this, self)
	if params ~= nil then
		for prop,value in pairs(params) do
			this[prop] = value
		end
	end
    return this
end

local editorVersion = "v3.6.51.9303"

---@param char string
---@param visualSlot integer
---@param elementName string
local function SetVisualOnCharacter(char, visualSlot, elementName)
	if Ext.GameVersion() ~= editorVersion and Ext.OsirisIsCallable() then
		CharacterSetVisualElement(char, visualSlot, elementName)
	end
end

---@param char string
function VisualResourceData:SetVisualOnCharacter(char)
	SetVisualOnCharacter(char, self.VisualSlot, self.Resource)
end

Classes.VisualResourceData = VisualResourceData

---@param self VisualElementData
---@param char EsvCharacter
---@param item EsvItem
---@param equipped boolean
local function OnEquipmentChanged(self, char, item, equipped)
	local armorType = item.Stats.ArmorType
	local slot = item.Stats.Slot
	if not equipped then
		armorType = "None"
	end
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
					Ext.Print("[LeaderLib:OnEquipmentChanged] char(%s) ArmorType(%s) Slot(%s) Resource(%s) VisualSet(%s)", char.MyGuid, armorType, slot, element.Resource, self.VisualSet)
				end
			end
		end
	end
end

---@class VisualElementData
local VisualElementData = {
	Type = "VisualElementData",
	---@type table<string, VisualResourceData>
	Visuals = {},
	VisualSet = "",
	OnEquipmentChanged = OnEquipmentChanged
}
VisualElementData.__visualSlot = VisualElementData

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
function VisualElementData:VisualForSlot(resource, armorType, slot, visualSlot, params)
	local armorTypeData = self.Visuals[armorType]
	if armorTypeData == nil then
		armorTypeData = {}
		self.Visuals[armorType] = armorTypeData
	end
	if armorTypeData[slot] == nil then
		armorTypeData[slot] = {}
	end
	table.insert(armorTypeData[slot], VisualResourceData:Create(resource, visualSlot, params))
end

---@param armorType string
---@param visuals table<string,VisualResourceData[]>
---@param params table|nil
---@return VisualElementData
function VisualElementData:AddVisualsForType(armorType, visuals)
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

Classes.VisualElementData = VisualElementData