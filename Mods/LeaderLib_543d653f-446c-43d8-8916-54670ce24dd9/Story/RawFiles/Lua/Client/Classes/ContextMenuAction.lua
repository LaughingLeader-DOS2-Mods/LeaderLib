---@class ContextMenuActionSettings
---@field ID string
---@field ShouldOpen fun(contextMenu:ContextMenu, x:number, y:number):boolean Called when the context menu is looking to open. If this returns true, the context menu will be visible.
---@field OnUpdate fun(self:ContextMenuAction) Called before this action is added to the context menu. Use it to set Disabled/Legal etc.
---@field Callback ContextMenuActionCallback
---@field Visible boolean
---@field DisplayName ContextMenuActionDisplayNameType
---@field SortName ContextMenuActionDisplayNameType The name to use when sorting. Defaults to the initial value of DisplayName.
---@field Tooltip ContextMenuActionDisplayNameType
---@field Icon string
---@field UseClickSound boolean
---@field Disabled boolean
---@field IsLegal boolean Results in the label being red if true (used for actions like pickpocketing).
---@field Handle any
---@field StayOpen boolean
---@field Children ContextMenuActionSettings[]
---@field AutomaticallyAddToBuiltin boolean If true, this action will be added to the builtin context menu, if conditions are met. Note that the builtin menu does not support icons or nested actions.

---@alias ContextMenuActionGetTextCallback (fun(character:EclCharacter):string|TranslatedString|nil,boolean|nil)
---@alias ContextMenuActionDisplayNameType string|TranslatedString|ContextMenuActionGetTextCallback

---@class ContextMenuAction:ContextMenuActionSettings
---@field Handle any A specific value that will be passed along to the callback on click.
local ContextMenuAction = {
	Type = "ContextMenuAction",
	Visible = true,
	UseClickSound = true,
	Disabled = false,
	StayOpen = false,
	IsLegal = true,
	AutomaticallyAddToBuiltin = false,
}

---@param params ContextMenuActionSettings
function ContextMenuAction:Create(params)
	---@type ContextMenuAction
	local this = {
		ID = "",
		Icon = "",
		DisplayName = "",
		Tooltip = "",
		ShouldOpen = nil,
		Callback = nil,
		OnUpdate = nil
	}
	if type(params) == "table" then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	if this.SortName == nil then
		this.SortName = this.DisplayName
	end
	if this.Children then
		if this.UseClickSound == nil then
			this.UseClickSound = false
		end
		if this.StayOpen == nil then
			this.StayOpen = true
		end
	end
	setmetatable(this, {
		__index = function (_,k)
			return ContextMenuAction[k]
		end
	})

	assert(not StringHelpers.IsNullOrEmpty(this.ID), "ID must be a valid string.")

	return this
end

---@param character? EclCharacter
---@param displayName? ContextMenuActionDisplayNameType Override what would normally be `self.DisplayName`
---@return string
function ContextMenuAction:GetDisplayName(character, displayName)
	displayName = displayName or self.DisplayName
	local t = type(displayName)
	if t == "string" then
		if string.find(displayName, "_") then
			return GameHelpers.GetStringKeyText(displayName)
		end
		return displayName
	elseif t == "table" and displayName.Type == "TranslatedString" then
		return GameHelpers.Tooltip.ReplacePlaceholders(displayName.Value, character)
	elseif t == "function" then
		local b,result,skipReplace = xpcall(displayName, debug.traceback, character)
		if not b then
			error(result, 2)
		elseif result then
			if not skipReplace then
				return GameHelpers.Tooltip.ReplacePlaceholders(result, character)
			else
				return result
			end
		end
	end
	return ""
end

---@param character? EclCharacter
---@return string
function ContextMenuAction:GetSortName(character)
	if StringHelpers.IsNullOrEmpty(self.SortName) then
		self.SortName = self:GetDisplayName(character)
		return self.SortName
	end
	return self:GetDisplayName(character, self.SortName)
end

---@param character EclCharacter|nil
---@return string
function ContextMenuAction:GetTooltip(character)
	return self:GetDisplayName(character, self.Tooltip)
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

function ContextMenuAction:Update()
	if self.OnUpdate then
		self:OnUpdate()
	end
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