---@class LeaderLibContextMenuFlashMainTimeline:FlashMainTimeline
---@field showContextMenu fun(visible:boolean, x:number|nil, y:number|nil)
---@field clearButtons function
---@field contextMenuMC {clearButtons:function, updateDone:function}
---@field screenWidth number
---@field screenHeight number

---@alias ContextMenuActionCallback fun(self:ContextMenu, ui:UIObject, id:integer, actionID:string, handle:number, entry:ContextMenuAction)

---@class BuiltinContextMenuEntry
---@field ID integer
---@field ActionID string
---@field Visible boolean
---@field ClickSound boolean
---@field Label string
---@field Disabled boolean
---@field Legal boolean
---@field Callback ContextMenuActionCallback
---@field Handle number

local ACTION_ID = {
	HideStatus = "hideStatus",
	UnhideStatus = "unhideStatus"
}

---@class ContextStatus:table
---@field StatusId string
---@field RemoveFromList boolean
---@field CallingUI integer

---@class ContextMenu
---@field Register ContextMenuRegistration
local ContextMenu = {
	---@type UIObject
	Instance = nil,
	---@type ContextMenuAction[]
	Entries = {},
	---@type table<string, ContextMenuAction>
	Actions = {},
	---@type table<integer, ContextMenuActionCallback>
	DefaultActionCallbacks = {},
	---@type table<integer, ContextMenuActionCallback>
	TemporaryActionCallbacks = {},
	---@type ContextStatus
	ContextStatus = nil,
	IsOpening = false,
	Visible = false,
	---@private
	RegisteredListeners = false,
	---The handle of whatever was used to open the context menu, if anything.
	---@type number
	LastObjectDouble = nil,
	Icons = {}
}

local function _IsBuiltinContextMenuVisible()
	if not Vars.ControllerEnabled then
		local cm1 = Ext.UI.GetByType(Data.UIType.contextMenu.Default)
		local cm2 = Ext.UI.GetByType(Data.UIType.contextMenu.Object)
		if cm1 and Common.TableHasEntry(cm1.Flags, "OF_Visible") then
			return true
		end
		if cm2 and Common.TableHasEntry(cm2.Flags, "OF_Visible") then
			return true
		end
	end
	return false
end

local function _OnBuiltinMenuVisible(ui)
	if ContextMenu.Visible then
		ContextMenu:Close()
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.contextMenu.Default, "updateButtons", _OnBuiltinMenuVisible)
Ext.RegisterUITypeInvokeListener(Data.UIType.contextMenu.Object, "updateButtons", _OnBuiltinMenuVisible)

local self = ContextMenu

---@type BuiltinContextMenuEntry[]
local builtinEntries = {}
local lastBuiltinID = 999
---@type table<integer,BuiltinContextMenuEntry|ContextMenuAction>
local GENERATED_ID_TO_ENTRY = {}

ContextMenu.DefaultActionCallbacks[ACTION_ID.HideStatus] = function(self, ui, id, actionID, handle)
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
				StatusHider.RefreshStatusVisibility()
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
				StatusHider.RefreshStatusVisibility()
			else
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Skipping hiding status %s from the UI.", self.ContextStatus.StatusId)
			end
		end
	else
		fprint(LOGLEVEL.ERROR, "[LeaderLib] ContextStatus.StatusId is not set.")
	end
end

ContextMenu.DefaultActionCallbacks[ACTION_ID.UnhideStatus] = function(self, ui, id, actionID, handle)
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
				StatusHider.RefreshStatusVisibility()
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
				StatusHider.RefreshStatusVisibility()
			else
				fprint(LOGLEVEL.DEFAULT, "[LeaderLib] Skipping unhiding status %s from the UI.", self.ContextStatus.StatusId)
			end
		end
	else
		fprint(LOGLEVEL.ERROR, "[LeaderLib:ContextMenu] ContextStatus.StatusId is not set.")
	end
end

---@private
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

---@private
function ContextMenu:OnOpen(ui, event)
	self.Visible = true
end

---@private
function ContextMenu:OnClose(ui, call)
	self:SetContextStatus(nil)
	self.Visible = false
	self.IsOpening = false
end

---@private
function ContextMenu:OnUpdate(ui, event)

end

local _actionMap = {}

---@private
---@param ui UIObject
function ContextMenu:OnEntryClicked(ui, event, index, actionID, handle, isBuiltIn, stayOpen)
	local action = self.DefaultActionCallbacks[actionID] or _actionMap[actionID]
	local b,result = false,nil
	if action then
		b,result = xpcall(action, debug.traceback, self, ui, index, actionID, handle)
		if not b then
			Ext.PrintError(result)
		end
	elseif not stayOpen then
		fprint(LOGLEVEL.WARNING, "[LeaderLib:ContextMenu:OnEntryClicked] No action registered for (%s).", actionID)
	end
	Events.OnContextMenuEntryClicked:Invoke({
		ContextMenu = self,	
		UI = ui,
		ID = index,
		ActionID = actionID,
		Handle = handle
	})
	---@type LeaderLibContextMenuFlashMainTimeline
	local this = ui:GetRoot()
	if this and this.showContextMenu then
		if stayOpen and result == false then
			this.showContextMenu(false)
		elseif not stayOpen and result ~= true then
			this.showContextMenu(false)
		end
	end
end

---@private
function ContextMenu:OnHideTooltip(ui, event)
	if not self.Visible and not self.IsOpening then
		self:SetContextStatus(nil)
	end
end

local _enabledActionsForContext = {}

---@return fun():ContextMenuAction,string
local function GetOrderedContextMenuActions()
	local ids = {}
	for id,action in pairs(ContextMenu.Actions) do
		ids[#ids+1] = {Name=action:GetDisplayName(),ID=id}
	end
	table.sort(ids, function(a,b)
		return a.Name < b.Name
	end)
	local i = 0
	local count = #ids
	return function ()
		i = i + 1
		if i <= count then
			local entry = ids[i]
			return ContextMenu.Actions[entry.ID],entry.ID
		end
	end
end

local function GetShouldOpen(contextMenu, x, y)
	local success = false
	for actionId,action in pairs(ContextMenu.Actions) do
		if action:GetCanOpen(contextMenu, x, y) then
			_enabledActionsForContext[actionId] = true
			success = true
		end
	end

	if success then
		return true
	end

	---@type SubscribableEventInvokeResult<ShouldOpenContextMenuEventArgs>
	local invokeResult = Events.ShouldOpenContextMenu:Invoke({
		ContextMenu = contextMenu,
		X = x,
		Y = y,
		ShouldOpen = false
	})
	if invokeResult.ResultCode ~= "Error" then
		local shouldOpen = invokeResult.Args.ShouldOpen == true
        if invokeResult.Results then
            for i=1,#invokeResult.Results do
                local b = invokeResult.Results[i]
                if type(b) == "boolean" then
                    shouldOpen = b
                end
            end
        end
		if shouldOpen then
			return true
		end
    end

	return false
end

function ContextMenu:OnRightClick()
	if _IsBuiltinContextMenuVisible() then
		if self.Visible then
			self:Close()
		end
		return
	end
	local settings = GameSettings.Settings.Client.StatusOptions
	--fprint(LOGLEVEL.DEFAULT, "[ContextMenu:OnRightClick] IsOpening(%s) Visible(%s) pressed(%s)", self.IsOpening, self.Visible, pressed)
	if not self.IsOpening then
		local x,y = UIExtensions.GetMousePosition()
		_enabledActionsForContext = {}
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
							self:AddEntry(ACTION_ID.UnhideStatus, nil, showText)
						else
							self:AddEntry(ACTION_ID.HideStatus, nil, hideText)
						end
					else
						if self.ContextStatus.RemoveFromList then
							self:AddEntry(ACTION_ID.HideStatus, nil, hideText)
						else
							self:AddEntry(ACTION_ID.UnhideStatus, nil, showText)
						end
					end
				end

				for action,actionId in GetOrderedContextMenuActions() do
					if _enabledActionsForContext[actionId] then
						self.Entries[#self.Entries+1] = action
						_enabledActionsForContext[actionId] = nil
					end
				end

				Events.OnContextMenuOpening:Invoke({
					ContextMenu = self,	
					X = x,
					Y = y
				})

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
						self:AddEntry(ACTION_ID.UnhideStatus, nil, showText)
					else
						self:AddEntry(ACTION_ID.HideStatus, nil, hideText)
					end
				else
					if self.ContextStatus.RemoveFromList then
						self:AddEntry(ACTION_ID.HideStatus, nil, hideText)
					else
						self:AddEntry(ACTION_ID.UnhideStatus, nil, showText)
					end
				end
			end
			for action,actionId in GetOrderedContextMenuActions() do
				if _enabledActionsForContext[actionId] then
					self.Entries[#self.Entries+1] = action
					_enabledActionsForContext[actionId] = nil
				end
			end
			Events.OnContextMenuOpening:Invoke({
				ContextMenu = self,	
				X = x,
				Y = y
			})
			self:Open()
		end
	end
end

---@private
function ContextMenu:OnShowStatusTooltip(ui, event, characterDouble, statusDouble, x, y, width, height, side)
	if self.ContextStatus == nil or not self.Visible then
		if characterDouble and statusDouble then
			local characterHandle = Ext.UI.DoubleToHandle(characterDouble)
			local statusHandle = Ext.UI.DoubleToHandle(statusDouble)
			if characterHandle and statusHandle then
				local status = Ext.GetStatus(characterHandle, statusHandle)
				if status then
					self:SetContextStatus(status, ui:GetTypeId())
				end
			end
		end
	end
end

---@private
function ContextMenu:OnShowExamineStatusTooltip(ui, event, typeIndex, statusDouble)
	if typeIndex == 7 and (self.ContextStatus == nil or not self.Visible) then
		local characterHandle = ui:GetPlayerHandle()
		local statusHandle = Ext.UI.DoubleToHandle(statusDouble)
		if characterHandle and statusHandle then
			local status = Ext.GetStatus(characterHandle, statusHandle)
			if status then
				self:SetContextStatus(status, ui:GetTypeId())
			end
		end
	end
end

Ext.RegisterUINameCall("openContextMenu", function (ui, call, doubleHandle, x, y)
	ContextMenu.LastObjectDouble = doubleHandle
end, "Before")


local function GetVar(var, fallback)
	if var == nil or type(var) ~= type(fallback) then
		return fallback
	end
	return var
end

local BuiltinContextMenuEntry = {
	Type = "BuiltinContextMenuEntry",
	Visible = true,
	Disabled = false,
	Legal = true,
	ClickSound = true,
	ActionID = "",
	DisplayName = "",
}
BuiltinContextMenuEntry.__index = BuiltinContextMenuEntry

---@param actionId string
---@param callback ContextMenuActionCallback
---@param label string
---@param visible boolean
---@param useClickSound boolean
---@param disabled boolean
---@param isLegal boolean
---@param handle any
function ContextMenu:AddBuiltinEntry(actionId, callback, label, visible, useClickSound, disabled, isLegal, handle)
	local entry = {
		ID = lastBuiltinID,
		ActionID = GetVar(actionId, string.format("Entry%s", lastBuiltinID)),
		ClickSound = GetVar(useClickSound, true),
		Label = GetVar(label, "Entry"),
		Disabled = GetVar(disabled, false),
		Visible = GetVar(visible, false),
		Legal = GetVar(isLegal, true),
		Callback = callback,
		Handle = handle
	}
	setmetatable(entry, BuiltinContextMenuEntry)
	builtinEntries[#builtinEntries+1] = entry
	GENERATED_ID_TO_ENTRY[entry.ID] = entry
	lastBuiltinID = lastBuiltinID + 1
end

---A wrapper around contextMenu.buttonArr entries. Supports getting/setting the individual entries in the array.
---@class ContextMenuBuiltinOpeningArrayEntry
---@field Index integer The beginning index in the array. Read-only.
---@field ID integer
---@field ActionID string
---@field UseClickSound boolean Whether to use a click sound when the context menu entry is clicked.
---@field Unused boolean Whether to use a click sound when the context menu entry is clicked.
---@field Label string
---@field Disabled boolean
---@field Visible boolean
---@field Legal boolean If this is false, the entry uses red text (like pickpocketing).

---@private
function ContextMenu:OnBuiltinMenuUpdating(ui, event)
	local targetObject = nil
	if ContextMenu.LastObjectDouble ~= nil then
		local handle = Ext.UI.DoubleToHandle(ContextMenu.LastObjectDouble)
		targetObject = GameHelpers.TryGetObject(handle)
	end

	local x,y = UIExtensions.GetMousePosition()

	local this = ui:GetRoot()
	local buttonArr = this.buttonArr
	local buttons = {}
	local length = #buttonArr
	for i=0,length-1,7 do
		--[[ id = Number(this.buttonArr[i]);
		actionID = Number(this.buttonArr[i + 1]);
		clickSound = Boolean(this.buttonArr[i + 2]);
		unused = String(this.buttonArr[i + 3]);
		text = String(this.buttonArr[i + 4]);
		disabled = Boolean(this.buttonArr[i + 5]);
		legal = Boolean(this.buttonArr[i + 6]); ]]
		local entry = {}
		setmetatable(entry, {
			__index = function (_, k)
				if k == "Index" then
					return i
				elseif k == "ID" then
					return this.buttonArr[i]
				elseif k == "ActionID" then
					return this.buttonArr[i+1]
				elseif k == "UseClickSound" then
					return this.buttonArr[i+2]
				elseif k == "Unused" then
					return this.buttonArr[i+3]
				elseif k == "Text" then
					return this.buttonArr[i+4]
				elseif k == "Disabled" then
					return this.buttonArr[i+5]
				elseif k == "Legal" then
					return this.buttonArr[i+6]
				end
			end,
			__newindex = function (_, k, v)
				if k == "ID" then
					this.buttonArr[i] = v
				elseif k == "ActionID" then
					this.buttonArr[i+1] = v
				elseif k == "UseClickSound" then
					this.buttonArr[i+2] = v
				elseif k == "Unused" then
					this.buttonArr[i+3] = v
				elseif k == "Text" then
					this.buttonArr[i+4] = v
				elseif k == "Disabled" then
					this.buttonArr[i+5] = v
				elseif k == "Legal" then
					this.buttonArr[i+6] = v
				elseif k == "Index" then
					return
				end
			end
		})
		buttons[#buttons+1] = entry
		--ContextMenu:AddEntry()
	end

	Events.OnBuiltinContextMenuOpening:Invoke({
		ContextMenu = self,
		UI = ui,
		Root = this,
		ButtonArray = buttonArr,
		Entries = buttons,
		Target = targetObject,
		X = x,
		Y = y,
	})

	for action,actionId in GetOrderedContextMenuActions() do
		if action.AutomaticallyAddToBuiltin and action:GetCanOpen(self, x, y) then
			self:AddBuiltinEntry(action.ID, action.Callback, action:GetDisplayName(), action.Visible, action.UseClickSound, action.Disabled, action.IsLegal, action.Handle)
		end
	end

	local i = length
	for _,v in ipairs(builtinEntries) do
		buttonArr[i] = v.ID
		buttonArr[i+1] = v.ID
		buttonArr[i+2] = v.ClickSound
		buttonArr[i+3] = ""
		buttonArr[i+4] = v.Label
		buttonArr[i+5] = v.Disabled
		buttonArr[i+6] = v.Legal
		i = i + 7
	end

	builtinEntries = {}
end

---@private
function ContextMenu:OnBuiltinMenuClicked(ui, event, id, actionID, handleAlwaysZero)
	local action = nil
	local entry = GENERATED_ID_TO_ENTRY[id]
	local handle = handleAlwaysZero
	if entry then
		action = entry.Callback
		handle = entry.Handle
	end
	if not action then
		action = self.DefaultActionCallbacks[actionID]
	end
	if action then
		local b,err = xpcall(action, debug.traceback, self, ui, id, actionID, handle, entry)
		if not b then
			Ext.Utils.PrintError(err)
		end
	elseif entry and Vars.DebugMode then
		fprint(LOGLEVEL.WARNING, "[LeaderLib:ContextMenu:OnEntryClicked] No action registered for (%s).", actionID)
	end
	Events.OnContextMenuEntryClicked:Invoke({
		ContextMenu = self,	
		UI = ui,
		ID = id,
		ActionID = actionID,
		Handle = handle
	})
end

---@private
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

		local onClose = function ()
			ContextMenu.LastObjectDouble = nil
			builtinEntries = {}
			GENERATED_ID_TO_ENTRY = {}
			lastBuiltinID = 999
		end

		local registerBuiltins = function (typeId)
			Ext.RegisterUITypeInvokeListener(typeId, "updateButtons", function(...) self:OnBuiltinMenuUpdating(...) end)
			Ext.RegisterUITypeCall(typeId, "buttonPressed", function(...) self:OnBuiltinMenuClicked(...) end)
			Ext.RegisterUITypeCall(typeId, "menuClosed", onClose)
			Ext.RegisterUITypeInvokeListener(typeId, "close", onClose)
		end

		for _,v in pairs(Data.UIType.contextMenu) do
			registerBuiltins(v)
		end
		for _,v in pairs(Data.UIType.contextMenu_c) do
			registerBuiltins(v)
		end
		
		self.RegisteredListeners = true
	end
end

---@param id string
---@param callback ContextMenuActionCallback|nil
---@param label string|nil
---@param visible string|nil
---@param useClickSound boolean|nil
---@param disabled boolean|nil
---@param isLegal boolean|nil
---@param handle any|nil
---@param children ContextMenuAction[]|nil
---@return ContextMenuAction
function ContextMenu:AddEntry(id, callback, label, visible, useClickSound, disabled, isLegal, handle, children)
	if not self.Entries then
		self.Entries = {}
	end
	local entry = Classes.ContextMenuAction:Create({
		ID = id,
		Callback = callback,
		DisplayName = label,
		Visible = visible,
		UseClickSound = useClickSound,
		Disabled = disabled,
		IsLegal = isLegal,
		Handle = handle,
		Children = children
	})
	self.Entries[#self.Entries+1] = entry
	return entry
end

function ContextMenu:Close()
	self.Visible = false
	self.IsOpening = false
	local instance = UIExtensions.GetInstance()
	if instance then
		self:ClearCustomIcons()
		---@type LeaderLibContextMenuFlashMainTimeline
		local main = instance:GetRoot()
		if main and main.showContextMenu then
			main.showContextMenu(false)
		end
	end
end

function ContextMenu:ClearCustomIcons()
	local inst = UIExtensions.Instance
	for id,icon in pairs(self.Icons) do
		inst:ClearCustomIcon(id)
	end
	self.Icons = {}
end

function ContextMenu:SaveCustomIcon(iconId, iconName, w, h)
	self.Icons[iconId] = iconName
	UIExtensions.Instance:SetCustomIcon(iconId, iconName, w, h)
end

---@param targetContextMenu {addEntry:function, list:FlashListDisplay}
---@param entry ContextMenuAction
---@param depth integer
local function AddEntryMC(targetContextMenu, entry, depth)
	if not entry then
		return
	end
	entry:Update()
	_actionMap[entry.ID] = entry.Callback
	local index = targetContextMenu.addEntry(entry.ID, entry.UseClickSound, entry:GetDisplayName(), entry.Disabled, entry.IsLegal, entry.Handle, entry:GetTooltip())
	local menuItem = targetContextMenu.list.content_array[index]
	menuItem.depth = depth
	if not StringHelpers.IsNullOrEmpty(entry.Icon) then
		local iconId = string.format("LeaderLib_UIExtensions_%s", entry.Icon)
		menuItem.setIcon("iggy_" .. iconId)
		ContextMenu:SaveCustomIcon(iconId, entry.Icon, 24, 24)
	end
	menuItem.stayOpen = entry.StayOpen or false
	
	if entry.Children then
		menuItem.createSubmenu()
		for j=1,#entry.Children do
			local child = entry.Children[j]
			AddEntryMC(menuItem.childCM, child, depth + 1)
		end
		menuItem.childCM.updateDone()
	end
end

---@private
function ContextMenu:MoveAndRebuild(x,y)
	local instance = UIExtensions.GetInstance()
	if instance then
		_actionMap = {}

		---@type LeaderLibContextMenuFlashMainTimeline
		local main = instance:GetRoot()
		local contextMenu = main.contextMenuMC
		if contextMenu then
			contextMenu.clearButtons()

			local totalEntries = #self.Entries
			if totalEntries == 0 then
				self:Close()
				return
			end
			for i=1,totalEntries do
				local entry = self.Entries[i]
				AddEntryMC(contextMenu, entry, 0)
			end
	
			contextMenu.updateDone()
		end
		
		local paddingX,paddingY = 8,-24
		if self.ContextStatus.CallingUI == Data.UIType.examine then
			paddingX,paddingY = 8,-16
		elseif self.ContextStatus.CallingUI == Data.UIType.playerInfo then
			
		end

		if self.ContextStatus.CallingUI then
			local caller = Ext.UI.GetByType(self.ContextStatus.CallingUI)
			if caller then
				caller:ExternalInterfaceCall("hideTooltip")
			end
		end
		
		x = x + paddingX
		y = y + paddingY
		
		main.showContextMenu(true, x,y)
		self.Visible = true
		--main.showContextMenu(true)
	end
end

function ContextMenu:Open()
	self.IsOpening = false
	self:Init()
	local instance = UIExtensions.GetInstance()
	if instance then
		---@type LeaderLibContextMenuFlashMainTimeline
		local main = instance:GetRoot()
		local contextMenu = main.contextMenuMC
		contextMenu.clearButtons()

		_actionMap = {}

		local totalEntries = #self.Entries
		for i=1,totalEntries do
			local entry = self.Entries[i]
			AddEntryMC(contextMenu, entry, 0)
		end

		contextMenu.updateDone()
		
		local x,y = UIExtensions.GetMousePosition()
		local paddingX,paddingY = 8,-24
		if self.ContextStatus then
			if self.ContextStatus.CallingUI == Data.UIType.examine then
				paddingX,paddingY = 8,-16
			--elseif self.ContextStatus.CallingUI == Data.UIType.playerInfo then
			end
		end
		self.IsOpening = true
		if self.ContextStatus then
			Ext.UI.GetByType(self.ContextStatus.CallingUI):ExternalInterfaceCall("hideTooltip")
		else
			instance:ExternalInterfaceCall("hideTooltip")
			local textDisplay = Ext.UI.GetByType(Data.UIType.textDisplay)
			if textDisplay then
				local textDisplayRoot = textDisplay:GetRoot()
				if textDisplayRoot and textDisplayRoot.clearTooltipText then
					textDisplayRoot.clearTooltipText()
				end
			end
		end
		if x+contextMenu.width > main.screenWidth then
			x = x - contextMenu.width - paddingX
		else
			x = x + paddingX
		end
		if y+contextMenu.height > main.screenHeight then
			y = y - contextMenu.height - paddingY
		else
			y = y + paddingY
		end

		main.showContextMenu(true, x,y)
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
	local ui = Ext.UI.GetByType(Data.UIType.examine) or Ext.UI.GetByType(Data.UIType.examine_c)
	if not ui then
		return nil
	end
	---@type {examine_mc:{statusContainer_mc:{list:FlashListDisplay}}}
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
			return Ext.UI.DoubleToHandle(status.id), ui:GetPlayerHandle(), ui:GetTypeId()
		end
	end
	return nil
end

local function GetPlayerInfoCursorStatus(x,y)
	if not x then
		x,y = UIExtensions.GetMousePosition()
	end
	local ui = Ext.UI.GetByType(Data.UIType.playerInfo) or Ext.UI.GetByType(Data.UIType.playerInfo_c)
	if not ui then
		return nil
	end
	---@alias PlayerInfoFlashPlayerArrayEntry {statusHolder_mc:FlashMovieClip, status_array:FlashArray<{hitTestPoint:fun(x:number, y:number, shapeFlag:boolean), id:number, owner:number}>, summonList:FlashListDisplay}
	---@type {player_array:FlashArray<PlayerInfoFlashPlayerArrayEntry>}
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
					return Ext.UI.DoubleToHandle(status.id), Ext.UI.DoubleToHandle(status.owner), ui:GetTypeId()
				end
			end
			if player_mc.summonList then
				for j=0,#player_mc.summonList.content_array do
					---@type PlayerInfoFlashPlayerArrayEntry
					local summon_mc = player_mc.summonList.content_array[j]
					if summon_mc then
						for k=0,#summon_mc.status_array do
							local status = summon_mc.status_array[k]
							if status and status.hitTestPoint(x, y, false) then
								return Ext.UI.DoubleToHandle(status.id), Ext.UI.DoubleToHandle(status.owner), ui:GetTypeId()
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

---@class ContextMenuRegistration
local Register = {}

ContextMenu.Register = Register

---@deprecated
---@param callback fun(contextMenu:ContextMenu, mouseX:number, mouseY:number):boolean
function Register.ShouldOpenListener(callback)
	---@param e LeaderLibRuntimeSubscribableEventArgs
	Events.ShouldOpenContextMenu:Subscribe(function (e)
		callback(e:Unpack())
	end)
end

---@deprecated
---@param callback fun(contextMenu:ContextMenu, mouseX:number, mouseY:number)
function Register.OpeningListener(callback)
	---@param e LeaderLibRuntimeSubscribableEventArgs
	Events.OnContextMenuOpening:Subscribe(function (e)
		callback(e:Unpack())
	end)
end

---@deprecated
---@param callback fun(contextMenu:ContextMenu, ui:UIObject, this:FlashMainTimeline, buttonArr:FlashArray<FlashMovieClip>, buttons:table, targetObject:EclCharacter|EclItem|nil)
function Register.BuiltinOpeningListener(callback)
	---@param e LeaderLibRuntimeSubscribableEventArgs
	Events.OnBuiltinContextMenuOpening:Subscribe(function (e)
		callback(e:Unpack())
	end)
end

---@deprecated
---@param callback fun(contextMenu:ContextMenu, ui:UIObject, entryID:integer, actionID:string, handle:string|number|boolean|nil)
function Register.EntryClickedListener(callback)
	---@param e LeaderLibRuntimeSubscribableEventArgs
	Events.OnContextMenuEntryClicked:Subscribe(function (e)
		callback(e:Unpack())
	end)
end

---@param action ContextMenuAction
function Register.Action(action)
	ContextMenu.Actions[action.ID] = action
end

UI.ContextMenu = ContextMenu