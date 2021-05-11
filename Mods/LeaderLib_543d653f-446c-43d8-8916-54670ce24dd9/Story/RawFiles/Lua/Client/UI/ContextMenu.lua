---@alias ContextMenuActionCallback fun(self:ContextMenu, ui:UIObject, id:integer, actionID:integer, handle:number)

---@class ContextMenuEntry:table
---@field ID number
---@field ActionID number
---@field Visible boolean
---@field ClickSound boolean
---@field Label string
---@field Disabled boolean
---@field Legal boolean
---@field Callback ContextMenuActionCallback
---@field StayOpen boolean|nil

local ACTIONS = {
	HideStatus = "hideStatus",
	UnhideStatus = "unhideStatus"
}

---@class ContextStatus:table
---@field StatusId string
---@field RemoveFromList boolean
---@field CallingUI integer

---@class ContextMenu:table
local ContextMenu = {
	---@type UIObject
	Instance = nil,
	---@type ContextMenuEntry[]
	Entries = {},
	---@type table<integer, ContextMenuActionCallback> 
	Actions = {},
	---@type ContextStatus
	ContextStatus = nil,
	IsOpening = false,
	Visible = false
}
ContextMenu.__index = ContextMenu

ContextMenu.Actions[ACTIONS.HideStatus] = function(self, ui, id, actionID, handle)
	if self.ContextStatus and not StringHelpers.IsNullOrWhitespace(self.ContextStatus.StatusId) then
		local addToList = true
		local blacklist = GameSettings.Settings.Client.StatusOptions.Blacklist or {}
		for i,v in pairs(blacklist) do
			if v == self.ContextStatus.StatusId then
				addToList = false
				break
			end
		end
		if addToList then
			fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Hiding status %s from the UI.", self.ContextStatus.StatusId)
			table.insert(GameSettings.Settings.Client.StatusOptions.Blacklist, self.ContextStatus.StatusId)
			SaveGameSettings()
		else
			fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Skipping hiding status %s from the UI.", self.ContextStatus.StatusId)
		end
	else
		fprint(LOGLEVEL.ERROR, "[LeaderLib] ContextStatus.StatusId is not set.")
	end
end

ContextMenu.Actions[ACTIONS.UnhideStatus] = function(self, ui, id, actionID, handle)
	if self.ContextStatus and not StringHelpers.IsNullOrWhitespace(self.ContextStatus.StatusId) then
		local removedFromList = false
		local blacklist = {}
		for i,v in pairs(GameSettings.Settings.Client.StatusOptions.Blacklist) do
			if v ~= self.ContextStatus.StatusId then
				table.insert(blacklist, v)
			else
				removedFromList = true
			end
		end
		if removedFromList then
			fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Unhiding status %s from the UI.", self.ContextStatus.StatusId)
			GameSettings.Settings.Client.StatusOptions.Blacklist = blacklist
			SaveGameSettings()
		else
			fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Skipping unhiding status %s from the UI.", self.ContextStatus.StatusId)
		end
	else
		fprint(LOGLEVEL.ERROR, "[LeaderLib] ContextStatus.StatusId is not set.")
	end
end

function ContextMenu:OnOpen(ui, event)
	self.Visible = true
end

function ContextMenu:OnClose(ui, call)
	print("ContextMenu:OnClose", call)
	self.ContextStatus = nil
	self.Visible = false
end

function ContextMenu:OnUpdate(ui, event)

end

---@param ui UIObject
function ContextMenu:OnEntryClicked(ui, event, id, actionID, handle)
	local entry = self.Entries[id]
	local action = self.Actions[actionID] or (entry and entry.Callback)
	print("ContextMenu:OnEntryClicked", event, id, actionID, handle, entry, action, Ext.JsonStringify(self.Entries))
	if action then
		local b,err = xpcall(action, debug.traceback, self, ui, id, actionID, handle)
		if not b then
			Ext.PrintError(err)
		end
	end
	InvokeListenerCallbacks(Listeners.OnContextMenuEntryClicked, self, ui, id, actionID, handle)
	if not entry or (entry and not entry.StayOpen) then
		ui:Invoke("showContextMenu", false)
	end
end

function ContextMenu:OnHideTooltip(ui, event)
	if not self.Visible and not self.IsOpening then
		self.ContextStatus = nil
	end
	print("ContextMenu:OnHideTooltip", event, self.Visible, self.ContextStatus and self.ContextStatus.StatusId or "")
end

function ContextMenu:OnRightClick(eventName, pressed, id, inputMap, controllerEnabled)
	if not pressed and not self.IsOpening then
		if self.ContextStatus then
			self.IsOpening = true
		end
		local x,y = UIExtensions.GetMousePosition()
		local callbacks = Listeners.ShouldOpenContextMenu
		local length = callbacks and #callbacks or 0
		if length > 0 then
			for i=1,length do
				local callback = callbacks[i]
				local success,b = xpcall(callback, debug.traceback, self, x, y)
				if not success then
					Ext.PrintError(b)
				elseif b then
					self.IsOpening = true
				end
			end
		end

		if self.IsOpening then
			self.Entries = {}
			if self.ContextStatus then
				if self.ContextStatus.RemoveFromList then
					self:AddEntry(ACTIONS.UnhideStatus, nil, LocalizedText.ContextMenu.ShowStatus.Value)
				else
					if self.ContextStatus.CallingUI == Data.UIType.examine then
						self:AddEntry(ACTIONS.HideStatus, nil, LocalizedText.ContextMenu.HideStatus_Examine.Value)
					else
						self:AddEntry(ACTIONS.HideStatus, nil, LocalizedText.ContextMenu.HideStatus.Value)
					end
				end
			end
			InvokeListenerCallbacks(Listeners.OnContextMenuOpening, self, x, y)
			self:Open()
		end
	end
end

function ContextMenu:OnShowStatusTooltip(ui, event, characterDouble, statusDouble, x, y, width, height, side)
	if self.ContextStatus == nil then
		if characterDouble and statusDouble then
			local characterHandle = Ext.DoubleToHandle(characterDouble)
			local statusHandle = Ext.DoubleToHandle(statusDouble)
			if characterHandle and statusHandle then
				local status = Ext.GetStatus(characterHandle, statusHandle)
				if status then
					---@type StatEntryStatusData
					--local stat = Ext.GetStat(status.StatusId)
					self.ContextStatus = {
						StatusId = status.StatusId,
						--DisplayName = Ext.GetTranslatedStringFromKey(stat.DisplayName) or stat.DisplayNameRef or status.StatusId
						RemoveFromList = false,
						CallingUI = ui:GetTypeId()
					}
				end
			end
		end
	end
	print("ContextMenu:OnShowStatusTooltip", event, self.Visible, self.ContextStatus, self.ContextStatus and self.ContextStatus.StatusId or "")
end

function ContextMenu:OnShowExamineStatusTooltip(ui, event, typeIndex, statusDouble)
	if self.ContextStatus == nil then
		if typeIndex == 7 then
			local characterHandle = ui:GetPlayerHandle()
			local statusHandle = Ext.DoubleToHandle(statusDouble)
			if characterHandle and statusHandle then
				local status = Ext.GetStatus(characterHandle, statusHandle)
				if status then
					---@type StatEntryStatusData
					--local stat = Ext.GetStat(status.StatusId)
					self.ContextStatus = {
						StatusId = status.StatusId,
						RemoveFromList = Common.TableHasEntry(GameSettings.Settings.Client.StatusOptions.Blacklist, status.StatusId, false),
						CallingUI = ui:GetTypeId()
						--DisplayName = Ext.GetTranslatedStringFromKey(stat.DisplayName) or stat.DisplayNameRef or status.StatusId
					}
				end
			end
		end
	end
	print("ContextMenu:OnShowExamineStatusTooltip", event, self.Visible, self.ContextStatus, self.ContextStatus and self.ContextStatus.StatusId or "")
end

function ContextMenu:Init()
	if not self.RegisteredListeners then
		-- for i,v in pairs(Data.UIType.contextMenu) do
		-- 	Ext.RegisterUITypeInvokeListener(v, "open", function(...) self:OnOpen(...) end)
		-- 	Ext.RegisterUITypeInvokeListener(v, "updateButtons", function(...) self:OnUpdate(...) end)
		-- 	Ext.RegisterUITypeInvokeListener(v, "close", function(...) self:OnClose(...) end)
		-- 	Ext.RegisterUITypeCall(v, "menuClosed", function(...) self:OnClose(...) end)
		-- 	Ext.RegisterUITypeCall(v, "buttonPressed", function(...) self:OnEntryClicked(...) end)
		-- end

		Ext.RegisterUINameCall("LeaderLib_ContextMenu_Opened", function(...) self:OnOpen(...) end)
		Ext.RegisterUINameCall("LeaderLib_ContextMenu_Closed", function(...) self:OnClose(...) end)
		Ext.RegisterUINameCall("LeaderLib_ContextMenu_EntryPressed", function(...) self:OnEntryClicked(...) end)

		Ext.RegisterUITypeCall(Data.UIType.playerInfo, "showStatusTooltip", function(...) self:OnShowStatusTooltip(...) end)
		Ext.RegisterUITypeCall(Data.UIType.examine, "showTooltip", function(...) self:OnShowExamineStatusTooltip(...) end)
		Ext.RegisterUITypeCall(Data.UIType.playerInfo, "hideTooltip", function(...) self:OnHideTooltip(...) end)
		Input.RegisterListener("ContextMenu", function(...) self:OnRightClick(...) end)
		--Input.RegisterMouseListener(UIExtensions.MouseEvent.RightMouseUp, function(...) self:OnRightClick(...) end)
		
		self.RegisteredListeners = true
	end
end

local function GetVar(var, fallback)
	if var == nil or type(var) ~= type(fallback) then
		return fallback
	end
	return var
end

local ContextMenuEntry = {
	StayOpen = false,
	Disabled = false,
	Legal = true,
	ClickSound = true,
	ID = -1,
	ActionID = -1,
}
ContextMenuEntry.__index = ContextMenuEntry

---@param actionId string
---@param callback ContextMenuActionCallback
---@param label string
---@param useClickSound boolean
---@param disabled boolean
---@param isLegal boolean
function ContextMenu:AddEntry(actionId, callback, label, visible, useClickSound, disabled, isLegal)
	if not self.Entries then
		self.Entries = {}
	end
	local id = #self.Entries+1
	local entry = {
		ID = id,
		ActionID = GetVar(actionId, string.format("Entry%s", id)),
		ClickSound = GetVar(useClickSound, true),
		Label = GetVar(label, "Entry"),
		Disabled = GetVar(disabled, false),
		Legal = GetVar(isLegal, true),
		Callback = callback
	}
	setmetatable(entry, ContextMenuEntry)
	self.Entries[id] = entry
end

function ContextMenu:Open()
	self.IsOpening = false
	self:Init()
	local instance = UIExtensions.GetInstance()
	if instance then
		local main = instance:GetRoot()
		local contextMenu = main.context_menu
		contextMenu.clearButtons()

		if #self.Entries > 1 then
			local i = 0
			for _,v in ipairs(self.Entries) do
				contextMenu.buttonArr[i] = v.ID
				contextMenu.buttonArr[i+1] = v.ActionID
				contextMenu.buttonArr[i+2] = v.ClickSound
				contextMenu.buttonArr[i+3] = "" -- Unused
				contextMenu.buttonArr[i+4] = v.Label
				contextMenu.buttonArr[i+5] = v.Disabled
				contextMenu.buttonArr[i+6] = v.Legal
				i = i + 7
			end
			contextMenu.updateButtons()
		else
			local entry = self.Entries[1]
			contextMenu.addEntry(entry.ID, entry.ActionID, entry.ClickSound, entry.Label, entry.Disabled, entry.Legal)
			contextMenu.updateDone()
		end
		
		local x,y = UIExtensions.GetMousePosition()
		local paddingX,paddingY = 8,-24
		if self.ContextStatus.CallingUI == Data.UIType.examine then
			paddingX,paddingY = 8,-16
		elseif self.ContextStatus.CallingUI == Data.UIType.playerInfo then
			
		end
		Ext.GetUIByType(self.ContextStatus.CallingUI):ExternalInterfaceCall("hideTooltip")
		x = x + paddingX
		y = y + paddingY
		
		contextMenu.open(x,y)
		self.Visible = true
		--main.showContextMenu(true)
	end
end

---@param mc FlashMovieClip
function ContextMenu:CursorIsOverlappingMC(mc)
	if mc and mc.hitTest then
		local x,y = UIExtensions.GetMousePosition()
		return mc.hitTest(x, y, true) == true
	end
	return false
end

ContextMenu:Init()