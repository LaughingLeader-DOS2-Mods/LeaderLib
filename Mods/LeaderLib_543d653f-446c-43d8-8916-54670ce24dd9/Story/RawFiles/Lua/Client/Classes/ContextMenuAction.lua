---@class ContextMenuActionSettings
---@field ID string
---@field ShouldOpen ShouldOpenContextMenuCallback
---@field Callback ContextMenuActionCallback
---@field Visible boolean
---@field DisplayName string|TranslatedString
---@field Tooltip string|TranslatedString
---@field Icon string
---@field UseClickSound boolean
---@field Disabled boolean
---@field IsLegal boolean
---@field StayOpen boolean
---@field Children ContextMenuActionSettings[]

---@class ContextMenuAction:ContextMenuActionSettings
---@field Handle any
local ContextMenuAction = {
	Type = "ContextMenuAction",
	Visible = true,
	UseClickSound = true,
	Disabled = false,
	StayOpen = false,
	IsLegal = true
}

local function GetIndex(tbl, k)
	return ContextMenuAction[k]
end

ContextMenuAction.__index = GetIndex

---@param params ContextMenuActionSettings
function ContextMenuAction:Create(params)
	---@type ContextMenuAction
	local this = {
		ID = "",
		ShouldOpen = nil,
		Callback = nil,
		Tooltip = ""
	}
	if type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	if this.Children then
		if this.UseClickSound == nil then
			this.UseClickSound = false
		end
		if this.StayOpen == nil then
			this.StayOpen = true
		end
	end
	setmetatable(this, ContextMenuAction)

	assert(not StringHelpers.IsNullOrEmpty(this.ID), "ID must be a valid string.")

	return this
end

---@param character ?EclCharacter
---@return string
function ContextMenuAction:GetDisplayName(character)
	local t = type(self.DisplayName)
	if t == "string" then
		if string.find(self.DisplayName, "_") then
			return GameHelpers.GetStringKeyText(self.DisplayName)
		end
		return self.DisplayName
	elseif t == "table" and self.DisplayName.Type == "TranslatedString" then
		return GameHelpers.Tooltip.ReplacePlaceholders(self.DisplayName.Value, character)
	end
	return ""
end

---@param character ?EclCharacter
---@return string
function ContextMenuAction:GetTooltip(character)
	local t = type(self.Tooltip)
	if t == "string" then
		if string.find(self.Tooltip, "_") then
			return GameHelpers.GetStringKeyText(self.Tooltip)
		end
		return self.Tooltip
	elseif t == "table" and self.Tooltip.Type == "TranslatedString" then
		return GameHelpers.Tooltip.ReplacePlaceholders(self.Tooltip.Value, character)
	end
	return ""
end

---@param contextMenu ContextMenu
---@param x number
---@param y number
function ContextMenuAction:GetCanOpen(contextMenu, x, y)
	if self.ShouldOpen then
		return self.ShouldOpen(contextMenu, x, y) == true
	end
	return false
end

function ContextMenuAction:GetAsEntry()
	local entry = {
		ID = self.ID,
		ClickSound = self.UseClickSound,
		DisplayName = self.DisplayName,
		Disabled = self.Disabled,
		Visible = self.Visible,
		Legal = self.IsLegal,
		Callback = self.Callback,
		Handle = self.Handle,
		Children = self.Children
	}
	return entry
end

Classes.ContextMenuAction = ContextMenuAction