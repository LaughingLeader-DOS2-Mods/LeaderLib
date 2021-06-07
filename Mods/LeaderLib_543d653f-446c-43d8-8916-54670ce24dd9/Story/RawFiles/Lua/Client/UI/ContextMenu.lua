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
		if not GameSettings.Settings.Client.StatusOptions.HideAll then
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
				GameSettingsManager.Save()
				UI.RefreshStatusVisibility()
			else
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Skipping hiding status %s from the UI.", self.ContextStatus.StatusId)
			end
		else
			local removedFromList = false
			local whitelist = {}
			for i,v in pairs(GameSettings.Settings.Client.StatusOptions.Whitelist) do
				if v ~= self.ContextStatus.StatusId then
					table.insert(whitelist, v)
				else
					removedFromList = true
				end
			end
			if removedFromList then
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Hiding status %s from the UI.", self.ContextStatus.StatusId)
				GameSettings.Settings.Client.StatusOptions.Whitelist = whitelist
				GameSettingsManager.Save()
				UI.RefreshStatusVisibility()
			else
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Skipping hiding status %s from the UI.", self.ContextStatus.StatusId)
			end
		end
	else
		fprint(LOGLEVEL.ERROR, "[LeaderLib] ContextStatus.StatusId is not set.")
	end
end

ContextMenu.Actions[ACTIONS.UnhideStatus] = function(self, ui, id, actionID, handle)
	if self.ContextStatus and not StringHelpers.IsNullOrWhitespace(self.ContextStatus.StatusId) then
		if not GameSettings.Settings.Client.StatusOptions.HideAll then
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
				GameSettingsManager.Save()
				UI.RefreshStatusVisibility()
			else
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Skipping unhiding status %s from the UI.", self.ContextStatus.StatusId)
			end
		else
			local addToList = true
			local whitelist = {}
			for i,v in pairs(GameSettings.Settings.Client.StatusOptions.Whitelist) do
				if v == self.ContextStatus.StatusId then
					addToList = false
				end
			end
			if addToList then
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Unhiding status %s from the UI.", self.ContextStatus.StatusId)
				table.insert(GameSettings.Settings.Client.StatusOptions.Whitelist, self.ContextStatus.StatusId)
				GameSettingsManager.Save()
				UI.RefreshStatusVisibility()
			else
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Skipping unhiding status %s from the UI.", self.ContextStatus.StatusId)
			end
		end
	else
		fprint(LOGLEVEL.ERROR, "[LeaderLib:ContextMenu] ContextStatus.StatusId is not set.")
	end
end

function ContextMenu:SetContextStatus(status, uiType)
	if status then
		--fprint(LOGLEVEL.WARNING, "[ContextMenu:SetContextStatus] Status(%s) UI(%s)", status.StatusId, uiType)
		self.ContextStatus = {
			StatusId = status.StatusId,
			CallingUI = uiType,
		}
		if not GameSettings.Settings.Client.StatusOptions.HideAll then
			self.ContextStatus.RemoveFromList = Common.TableHasEntry(GameSettings.Settings.Client.StatusOptions.Blacklist, status.StatusId, false)
		else
			self.ContextStatus.RemoveFromList = Common.TableHasEntry(GameSettings.Settings.Client.StatusOptions.Whitelist, status.StatusId, false)
		end
	else
		--fprint(LOGLEVEL.WARNING, "[ContextMenu:SetContextStatus] Cleared.")
		self.ContextStatus = nil
	end
end

function ContextMenu:OnOpen(ui, event)
	self.Visible = true
end

function ContextMenu:OnClose(ui, call)
	self:SetContextStatus(nil)
	self.Visible = false
	self.IsOpening = false
end

function ContextMenu:OnUpdate(ui, event)

end

---@param ui UIObject
function ContextMenu:OnEntryClicked(ui, event, id, actionID, handle)
	local entry = self.Entries[id]
	local action = self.Actions[actionID] or (entry and entry.Callback)
	if action then
		local b,err = xpcall(action, debug.traceback, self, ui, id, actionID, handle)
		if not b then
			Ext.PrintError(err)
		end
	else
		fprint(LOGLEVEL.WARNING, "[LeaderLib:ContextMenu:OnEntryClicked] No action registered for (%s).", actionID)
	end
	InvokeListenerCallbacks(Listeners.OnContextMenuEntryClicked, self, ui, id, actionID, handle)
	if not entry or (entry and not entry.StayOpen) then
		ui:Invoke("showContextMenu", false)
	end
end

function ContextMenu:OnHideTooltip(ui, event)
	if not self.Visible and not self.IsOpening then
		self:SetContextStatus(nil)
	end
end

local function GetShouldOpen(self,x,y)
	local callbacks = Listeners.ShouldOpenContextMenu
	local length = callbacks and #callbacks or 0
	if length > 0 then
		for i=1,length do
			local callback = callbacks[i]
			local success,b = xpcall(callback, debug.traceback, self, x, y)
			if not success then
				Ext.PrintError(b)
			elseif b then
				return true
			end
		end
	end
	return false
end

function ContextMenu:OnRightClick(eventName, pressed, id, inputMap, controllerEnabled)
	local settings = GameSettings.Settings.Client.StatusOptions
	--fprint(LOGLEVEL.DEFAULT, "[ContextMenu:OnRightClick] IsOpening(%s) Visible(%s) pressed(%s)", self.IsOpening, self.Visible, pressed)
	if not self.IsOpening then
		local x,y = UIExtensions.GetMousePosition()
		local openRequested = GetShouldOpen(self, x, y)

		local hideText,showText = "",""
		if self.ContextStatus then
			hideText = (settings.AffectHealthbar or self.ContextStatus.CallingUI ~= Data.UIType.examine) and LocalizedText.ContextMenu.HideStatus.Value or LocalizedText.ContextMenu.HideStatus_Examine.Value
			showText = (settings.AffectHealthbar or self.ContextStatus.CallingUI ~= Data.UIType.examine) and LocalizedText.ContextMenu.ShowStatus.Value or LocalizedText.ContextMenu.ShowStatus_Examine.Value
		end

		if self.Visible then
			local status,uiType = self:GetCursorStatus(x,y)
			if status then
				self:SetContextStatus(status, uiType)
				self.Entries = {}

				if self.ContextStatus then
					if not settings.HideAll then
						if self.ContextStatus.RemoveFromList then
							self:AddEntry(ACTIONS.UnhideStatus, nil, showText)
						else
							self:AddEntry(ACTIONS.HideStatus, nil, hideText)
						end
					else
						if self.ContextStatus.RemoveFromList then
							self:AddEntry(ACTIONS.HideStatus, nil, hideText)
						else
							self:AddEntry(ACTIONS.UnhideStatus, nil, showText)
						end
					end
				end

				InvokeListenerCallbacks(Listeners.OnContextMenuOpening, self, x, y)
				self:MoveAndRebuild(x,y)
				return
			elseif not openRequested then
				self:Close()
				return
			end
		end
		if openRequested or self.ContextStatus then
			self.Entries = {}
			if self.ContextStatus then
				if not settings.HideAll then
					if self.ContextStatus.RemoveFromList then
						self:AddEntry(ACTIONS.UnhideStatus, nil, showText)
					else
						self:AddEntry(ACTIONS.HideStatus, nil, hideText)
					end
				else
					if self.ContextStatus.RemoveFromList then
						self:AddEntry(ACTIONS.HideStatus, nil, hideText)
					else
						self:AddEntry(ACTIONS.UnhideStatus, nil, showText)
					end
				end
			end
			InvokeListenerCallbacks(Listeners.OnContextMenuOpening, self, x, y)
			self:Open()
		end
	end
end

function ContextMenu:OnShowStatusTooltip(ui, event, characterDouble, statusDouble, x, y, width, height, side)
	if self.ContextStatus == nil or not self.Visible then
		if characterDouble and statusDouble then
			local characterHandle = Ext.DoubleToHandle(characterDouble)
			local statusHandle = Ext.DoubleToHandle(statusDouble)
			if characterHandle and statusHandle then
				local status = Ext.GetStatus(characterHandle, statusHandle)
				if status then
					self:SetContextStatus(status, ui:GetTypeId())
				end
			end
		end
	end
end

function ContextMenu:OnShowExamineStatusTooltip(ui, event, typeIndex, statusDouble)
	if typeIndex == 7 and (self.ContextStatus == nil or not self.Visible) then
		local characterHandle = ui:GetPlayerHandle()
		local statusHandle = Ext.DoubleToHandle(statusDouble)
		if characterHandle and statusHandle then
			local status = Ext.GetStatus(characterHandle, statusHandle)
			if status then
				self:SetContextStatus(status, ui:GetTypeId())
			end
		end
	end
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
		Ext.RegisterUITypeCall(Data.UIType.examine, "hideTooltip", function(...) self:OnHideTooltip(...) end)
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

function ContextMenu:Close()
	self.Visible = false
	self.IsOpening = false
	local instance = UIExtensions.GetInstance()
	if instance then
		local main = instance:GetRoot()
		local contextMenu = main.context_menu
		contextMenu.close()
	end
end

function ContextMenu:MoveAndRebuild(x,y)
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
		
		local paddingX,paddingY = 8,-24
		if self.ContextStatus.CallingUI == Data.UIType.examine then
			paddingX,paddingY = 8,-16
		elseif self.ContextStatus.CallingUI == Data.UIType.playerInfo then
			
		end

		if self.ContextStatus.CallingUI then
			local caller = Ext.GetUIByType(self.ContextStatus.CallingUI)
			if caller then
				caller:ExternalInterfaceCall("hideTooltip")
			end
		end
		
		x = x + paddingX
		y = y + paddingY
		
		contextMenu.open(x,y)
		self.Visible = true
		--main.showContextMenu(true)
	end
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
		self.IsOpening = true
		Ext.GetUIByType(self.ContextStatus.CallingUI):ExternalInterfaceCall("hideTooltip")
		x = x + paddingX
		y = y + paddingY
		
		contextMenu.open(x,y)
		self.Visible = true
		self.IsOpening = false
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

local function PosIsWithinBounds(x, y, w, h, tx, ty)
	if x < 0 or y < 0 then
		return false
	end
	tx = tx or 0
	ty = ty or 0
	return x >= tx and x < w and y >= ty and y < h
end

local function GetExamineCursorStatus(x,y)
	if not x then
		x,y = UIExtensions.GetMousePosition()
	end
	local ui = Ext.GetUIByType(Data.UIType.examine) or Ext.GetUIByType(Data.UIType.examine_c)
	if not ui then
		return nil
	end
	local main = ui:GetRoot()
	if not main then
		return nil
	end
	local array = main.examine_mc.statusContainer_mc.list.content_array
	for i=0,#array do
		local status = array[i]
		-- if status then
		-- 	print("examine.status hitTestPoint", status.hitTestPoint(x, y, false), x, y)
		-- 	print("examine.status hitTestPoint local", status.hitTestPoint(status.mouseX, status.mouseY, false), status.mouseX, status.mouseY)
		-- 	print("examine.status PosIsWithinBounds", PosIsWithinBounds(status.mouseX, status.mouseY, status.width, status.height))
		-- 	print(status.x, status.y, status.width, status.height)
		-- end
		if status and PosIsWithinBounds(status.mouseX, status.mouseY, status.width, status.height) then
			return Ext.DoubleToHandle(status.id), ui:GetPlayerHandle(), ui:GetTypeId()
		end
	end
	return nil
end

local function GetPlayerInfoCursorStatus(x,y)
	if not x then
		x,y = UIExtensions.GetMousePosition()
	end
	local ui = Ext.GetUIByType(Data.UIType.playerInfo) or Ext.GetUIByType(Data.UIType.playerInfo_c)
	if not ui then
		return nil
	end
	local main = ui:GetRoot()
	if not main then
		return nil
	end
	for i=0,#main.player_array do
		local player_mc = main.player_array[i]
		if player_mc and player_mc.statusHolder_mc then
			for s=0,#player_mc.status_array do
				local status = player_mc.status_array[s]
				if status and status.hitTestPoint(x, y, false) then
					return Ext.DoubleToHandle(status.id), Ext.DoubleToHandle(status.owner), ui:GetTypeId()
				end
			end
			if player_mc.summonList then
				for j=0,#player_mc.summonList.content_array do
					local summon_mc = player_mc.summonList.content_array[j]
					if summon_mc then
						for k=0,#summon_mc.status_array do
							local status = summon_mc.status_array[k]
							if status and status.hitTestPoint(x, y, false) then
								return Ext.DoubleToHandle(status.id), Ext.DoubleToHandle(status.owner), ui:GetTypeId()
							end
						end
					end
				end
			end
		end
	end
	return nil
end

---@return EsvStatus|nil
function ContextMenu:GetCursorStatus(x,y)
	local statusHandle,ownerHandle,uiType = GetExamineCursorStatus(x,y)
	if not statusHandle then
		statusHandle,ownerHandle,uiType = GetPlayerInfoCursorStatus(x,y)
	end
	if statusHandle then
		local status = Ext.GetStatus(ownerHandle, statusHandle)
		if status then
			return status,uiType
		end
	end
	return nil
end

ContextMenu:Init()