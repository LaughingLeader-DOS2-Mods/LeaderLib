---@class VisualResourceData
local VisualResourceData = {
	Type = "VisualResourceData",
	Resource = "",
	VisualSlot = -1,
	IfEmpty = "",
}
VisualResourceData.__index = VisualResourceData

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
	setmetatable(this, VisualResourceData)
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
	--fprint(LOGLEVEL.TRACE, "CharacterSetVisualElement(\"%s\", %s, \"%s\")", char, visualSlot, elementName)
	CharacterSetVisualElement(char, visualSlot, elementName)
end

---@param char string
function VisualResourceData:SetVisualOnCharacter(char)
	SetVisualOnCharacter(char, self.VisualSlot, self.Resource)
end

if Ext.GameVersion() == editorVersion then
	Ext.PrintWarning("[LeaderLib:VisualResourceData:SetVisualOnCharacter] CharacterSetVisualElement isn't availble in the editor's game version (v3.6.51.9303).")
	VisualResourceData.SetVisualOnCharacter = function() end
end

Classes.VisualResourceData = VisualResourceData