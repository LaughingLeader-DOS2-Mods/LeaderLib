--[[
==============
    Notes
==============
The options setting menu is optionsSettings.swf
When clicking on the Controls tab, the game switches the menu to optionsInput.swf and recreates the menu buttons.

To allow the Mod Settings button to work from the Controls view (everything is set up for optionsSettings.swf), we get the game to switch to the Graphics tab, and then immediately switch to the Mod Settings tab.
This seems to be the easiest option since the engine does some weird thing to switch the GUI between both options GUI files.
]]

local OPTIONS_UI_TYPE = {
	Data.UIType.optionsSettings.Video,
	Data.UIType.optionsSettings.Audio,
	Data.UIType.optionsSettings.Game
}

local OPTIONS_UI_TYPE_C = {
	Data.UIType.optionsSettings_c.Video,
	Data.UIType.optionsSettings_c.Audio,
	Data.UIType.optionsSettings_c.Game
}

local LarianMenuID = {
	Graphics = 1,
	Audio = 2,
	Gameplay = 3,
	Controls = 4,
}

local MessageBoxButtonID = {
	ACCEPT = 3,
	CANCEL = 4,
}

local LarianButtonID = {
	Accept = 0,
	Cancel = 1,
	Apply = 2
}

local MOD_MENU_ID = 69
local lastMenu = -1
local currentMenu = 1
local switchToModMenu = false

local ModMenuTabButtonText = Classes.TranslatedString:Create("h5945db23gdaafg400ega4d6gc2ffa7a53f92", "Mod Settings")
local ModMenuTabButtonTooltip = Classes.TranslatedString:Create("hc5012999g3c27g43bfg9a89g2a6557effb94", "Various mod options for active mods.")

---@return UIObject
local function GetOptionsGUI()
	if not Vars.ControllerEnabled then
		return Ext.GetBuiltinUI("Public/Game/GUI/optionsSettings.swf")
	else
		return Ext.GetBuiltinUI("Public/Game/GUI/optionsSettings_c.swf")
	end
end

Ext.RegisterNetListener("LeaderLib_ModMenu_RunParseUpdateArrayMethod", function(cmd,payload)
	local ui = GetOptionsGUI()
	if ui ~= nil then
		ui:Invoke("parseUpdateArray")
	end
end)

local function SetCurrentMenu(id)
	if currentMenu ~= id then
		lastMenu = currentMenu
		currentMenu = math.floor(id)
		if Vars.DebugMode then
			PrintLog("[LeaderLib] Options menu changed: lastMenu(%s) currentMenu(%s)", lastMenu, currentMenu)
		end
	end
end

local function SwitchToModMenu(ui, ...)
	local main = ui:GetRoot()
	---@type MainMenuMC
	local mainMenu = main.mainMenu_mc
	SetCurrentMenu(MOD_MENU_ID)
	main.createApplyButton(false)
	main.removeItems()
	main.resetMenuButtons(MOD_MENU_ID)
	local buttonsArray = mainMenu.menuBtnList.content_array
	for i=0,#buttonsArray do
		local button = buttonsArray[i]
		if button ~= nil then
			if button.buttonID == MOD_MENU_ID then
				button.setEnabled(false)
			else
				button.setEnabled(true)
			end
		end
	end
	ModMenuManager.CreateMenu(ui, mainMenu)
	main.positionElements()
	ModMenuManager.SetScrollPosition(ui)
end

Ext.RegisterNetListener("LeaderLib_ModMenu_Open", function(cmd,payload)
	local ui = GetOptionsGUI()
	if ui ~= nil then
		SwitchToModMenu(ui)
	end
end)

---@param ui UIObject
local function CreateModMenuButton(ui, method, ...)
	local main = ui:GetRoot()
	if main ~= nil then
		if not Vars.ControllerEnabled then
			---@type MainMenuMC
			local mainMenu = main.mainMenu_mc
			mainMenu.addOptionButton(ModMenuTabButtonText.Value, "switchToModMenu", MOD_MENU_ID, switchToModMenu)
			if switchToModMenu then
				--ui:ExternalInterfaceCall("switchMenu", MOD_MENU_ID)
				main.clearAll()
				for i=0,#main.baseUpdate_Array do
					local val = main.baseUpdate_Array[i]
					if val == true then
						main.baseUpdate_Array[i] = false
						break
					end
				end
				SwitchToModMenu(ui)
				--Ext.PostMessageToServer("LeaderLib_ModMenu_RequestOpen", tostring(Client.ID))
			end
		end
	end
	if switchToModMenu then
		--Ext.PostMessageToServer("LeaderLib_ModMenu_SendParseUpdateArrayMethod", tostring(UI.ClientID))
		switchToModMenu = false
	end
end


---@param ui UIObject
local function CreateModMenuButton_Controller(ui, method, ...)
	local main = ui:GetRoot()
	print(method, main)
	if main ~= nil then
		main.addMenuButton(MOD_MENU_ID, ModMenuTabButtonText.Value, ModMenuTabButtonTooltip.Value, true)
	else
		ui:Invoke("addMenuButton", MOD_MENU_ID, ModMenuTabButtonText.Value, ModMenuTabButtonTooltip.Value, true)
	end
end

local debugEvents = {
	"onEventInit",
	"parseUpdateArray",
	"parseBaseUpdateArray",
	"onEventResize",
	"onEventUp",
	"onEventDown",
	"hideWin",
	"showWin",
	"getHeight",
	"getWidth",
	"setX",
	"setY",
	"setPos",
	"getX",
	"getY",
	"openMenu",
	"closeMenu",
	"cancelChanges",
	"addMenuInfoLabel",
	"setMenuCheckbox",
	"addMenuSelector",
	"addMenuSelectorEntry",
	"selectMenuDropDownEntry",
	"clearMenuDropDownEntries",
	"setMenuDropDownEnabled",
	"setMenuDropDownDisabledTooltip",
	"setMenuSlider",
	"addOptionButton",
	"setButtonEnabled",
	"removeItems",
	--"setButtonDisable",
	"resetMenuButtons",
}

local debugCalls = {
	"switchToModMenu",
	"switchToModMenuFromInput",
	"requestCloseUI",
	"acceptPressed",
	"applyPressed",
	"checkBoxID",
	"comboBoxID",
	"selectorID",
	"menuSliderID",
	"buttonPressed",
	"llcheckBoxID",
	"llcomboBoxID",
	"llselectorID",
	"llmenuSliderID",
	"llbuttonPressed",
	"switchMenu",
	--"PlaySound",
}

local debugEvents_c = {
	"onEventInit",
	"onEventResize",
	"onEventUp",
	"addingDone",
	"addCheckBoxOptions",
	"onEventDown",
	"addBtnHint",
	"clearBtnHints",
	"hideWin",
	"showWin",
	"getHeight",
	"getWidth",
	"setX",
	"setY",
	"setPos",
	"getX",
	"getY",
	"openMenu",
	"closeMenu",
	"addMenuLabel",
	"addMenuInfoLabel",
	"setTitle",
	"setTopTitle",
	"parseUpdateArray",
	"addMenuCheckbox",
	"setMenuCheckbox",
	"addMenuSelector",
	"addMenuSelectorEntry",
	"selectMenuSelectorEntry",
	"addMenuDropDown",
	"addMenuDropDownEntry",
	"selectMenuDropDownEntry",
	"clearMenuDropDownEntries",
	"setMenuDropDownEnabled",
	"setMenuDropDownDisabledTooltip",
	"addMenuSlider",
	"setMenuSlider",
	"addMenuButton",
	"setButtonEnabled",
	"setButtonText",
	"removeItems",
	"setButtonDisable",
	"resetMenuButtons",
}

local debugCalls_c = {
	"menuButtonOver",
	"buttonPressed",
}

Ext.RegisterNetListener("LeaderLib_ModMenu_CreateMenuButton", function(cmd, payload)
	local ui = GetOptionsGUI()
	if ui ~= nil then
		CreateModMenuButton(ui)
	end
end)

local registeredListeners = false

local function OnOptionsClosed()
	SetCurrentMenu(1)
end

local function OnSwitchMenu(ui, call, id)
	--ui = GetOptionsGUI()
	if currentMenu == MOD_MENU_ID then
		ModMenuManager.SaveScroll(ui)
		ui:GetRoot().mainMenu_mc.removeApplyCopy()
	elseif currentMenu == LarianMenuID.Gameplay then
		GameSettingsMenu.SaveScroll(ui)
	end
	SetCurrentMenu(id)

	if currentMenu == MOD_MENU_ID then
		SwitchToModMenu(ui)
	elseif currentMenu == LarianMenuID.Gameplay then
		--GameSettingsMenu.AddSettings(ui, true)
	end
end

local function OnUpdateArrayParsed(ui, call, arrayName)
	if arrayName == "baseUpdate_Array" then
		if currentMenu == LarianMenuID.Gameplay then
			GameSettingsMenu.SetScrollPosition(ui)
		end
		ui:GetRoot().positionElements()
	end
end

local function OnAcceptChanges(ui, call)
	if currentMenu == MOD_MENU_ID then
		ModMenuManager.SaveScroll(ui)
		ModMenuManager.CommitChanges()
		registeredListeners = false
	elseif currentMenu == LarianMenuID.Gameplay then
		GameSettingsMenu.SaveScroll(ui)
		GameSettingsMenu.CommitChanges()
	end
	OnOptionsClosed()
end

local function SetApplyButtonClickable(ui, b)
	--local mainMenu_mc = ui:GetRoot().mainMenu_mc
	--mainMenu_mc.applyCopy.text_txt.htmlText = mainMenu_mc.apply_mc.text_txt.htmlText
	--mainMenu_mc.applyCopy.text_txt.visible = b
	ui:Invoke("setApplyButtonCopyVisible", b)
end

local function OnApplyPressed(ui, call, ...)
	if currentMenu == MOD_MENU_ID then
		ModMenuManager.SaveScroll(ui)
		ModMenuManager.CommitChanges()
		SetApplyButtonClickable(ui, false)
	elseif currentMenu == LarianMenuID.Gameplay then
		GameSettingsMenu.SaveScroll(ui)
		GameSettingsMenu.CommitChanges()
	end
end

local function OnCancelChanges(ui, call)
	if currentMenu == MOD_MENU_ID then
		ModMenuManager.SaveScroll(ui)
		ModMenuManager.UndoChanges()
		registeredListeners = false
	elseif currentMenu == LarianMenuID.Gameplay then
		GameSettingsMenu.SaveScroll(ui)
		GameSettingsMenu.UndoChanges()
	end
	OnOptionsClosed()
end

Ext.RegisterListener("SessionLoaded", function()
	if Vars.DebugMode then
		for i,v in pairs(debugEvents_c) do
			Ext.RegisterUINameInvokeListener(v, function(ui, ...)
				print(ui:GetTypeId(), Common.Dump({...}), Ext.MonotonicTime())
			end)
		end
		for i,v in pairs(debugCalls_c) do
			Ext.RegisterUINameCall(v, function(ui, ...)
				print(ui:GetTypeId(), Common.Dump({...}), Ext.MonotonicTime())
			end)
		end
		-- for i,v in pairs(debugEvents) do
		-- 	---@param ui UIObject
		-- 	Ext.RegisterUINameInvokeListener(v, function(ui, ...)
		-- 		print(ui:GetTypeId(), Common.Dump({...}), Ext.MonotonicTime())
		-- 	end)
		-- end
		-- for i,v in pairs(debugCalls) do
		-- 	---@param ui UIObject
		-- 	Ext.RegisterUINameCall(v, function(ui, ...)
		-- 		print(ui:GetTypeId(), Common.Dump({...}), Ext.MonotonicTime())
		-- 	end)
		-- end
	end

	Ext.RegisterUINameCall("switchToModMenu", function(ui, call, ...)
		switchToModMenu = true
		ui:ExternalInterfaceCall("switchMenu", 1)
		-- SetCurrentMenu(MOD_MENU_ID)
		-- SwitchToModMenu(ui)
		--Ext.PostMessageToServer("LeaderLib_ModMenu_RequestOpen", tostring(Client.ID))
	end)
	---@param ui UIObject
	Ext.RegisterUINameCall("switchToModMenuFromInput", function(ui, call, ...)
		switchToModMenu = true
		ui:ExternalInterfaceCall("switchMenu", 1)
		--ui:ExternalInterfaceCall("switchMenu", MOD_MENU_ID)
		--ui:ExternalInterfaceCall("requestCloseUI")
	end)
	if Vars.ControllerEnabled then
		Ext.RegisterUITypeCall(Data.UIType.mainMenu_c, "menuButtonOver", function(ui, call, id)
			if id == MOD_MENU_ID then
				switchToModMenu = true
			end
		end)
	end

	Ext.RegisterUITypeCall(Data.UIType.msgBox, "ButtonPressed", function(ui, call, id)
		-- Are you sure you want to discard your changes?
		if lastMenu == MOD_MENU_ID or currentMenu == MOD_MENU_ID then
			if id == MessageBoxButtonID.CANCEL then

			elseif id == MessageBoxButtonID.ACCEPT then
				ModMenuManager.UndoChanges()
			end
		elseif lastMenu == LarianMenuID.Gameplay or currentMenu == LarianMenuID.Gameplay then
			if id == MessageBoxButtonID.CANCEL then

			elseif id == MessageBoxButtonID.ACCEPT then
				GameSettingsMenu.UndoChanges()
			end
		end
	end)

	---@param ui UIObject
	Ext.RegisterUINameInvokeListener("parseUpdateArray", function(invokedUI, method, ...)
		print(method, Ext.JsonStringify({...}))
		local ui = GetOptionsGUI() or invokedUI
		if ui ~= nil then
			local main = ui:GetRoot()
			if main then
				for i=0,#main.update_Array do
					local entry = main.update_Array[i]
					if entry then
						print(i, entry)
					end
				end
			end
			if currentMenu == LarianMenuID.Gameplay then
				GameSettingsMenu.AddSettings(ui, true)
			end
		end
	end)

	print("parseBaseUpdateArray", Vars.ControllerEnabled)

	if not Vars.ControllerEnabled then
		Ext.RegisterUINameInvokeListener("parseBaseUpdateArray", function(invokedUI, method, ...)
			local ui = GetOptionsGUI() or invokedUI
			if ui ~= nil then
				CreateModMenuButton(ui, method, ...)
			end
		end)
	else
		local gameButtonText = Ext.GetTranslatedString("h12fb7af4ga5abg47f4g9120ga63d33b2b71d", "Game")
		Ext.RegisterUINameInvokeListener("addMenuButton", function(invokedUI, method, id, label, tooltip, enabled)
			if id == 4 and label == gameButtonText then
				UIExtensions.StartTimer("addModMenuOptionsButton", 10, function()
					local ui = Ext.GetUIByType(Data.UIType.mainMenu_c) or invokedUI
					if ui ~= nil then
						CreateModMenuButton_Controller(ui, method)
					end
				end)
				--Ext.GetBuiltinUI("Public/Game/GUI/gameMenu_c.swf")
			end
		end)
	end

	---optionsInput.swf version.
	---@param ui UIObject
	Ext.RegisterUINameInvokeListener("addMenuButtons", function(ui, method, ...)
		ui = Ext.GetBuiltinUI("Public/Game/GUI/optionsInput.swf")
		local main = ui:GetRoot()
		if main ~= nil then
			---@type MainMenuMC
			local mainMenu = main.controlsMenu_mc
			mainMenu.addMenuButton(ModMenuTabButtonText.Value, "switchToModMenuFromInput", MOD_MENU_ID, false)
		end
	end)

	local OnCheckBox = function(ui, call, id, value)
		local originalCall = string.sub(call, 3)
		if currentMenu == MOD_MENU_ID then
			ModMenuManager.OnCheckbox(id, value)
			SetApplyButtonClickable(ui, true)
		elseif currentMenu == LarianMenuID.Gameplay then
			if not GameSettingsMenu.OnCheckbox(id, value) then
				ui:ExternalInterfaceCall(originalCall, id, value)
			else
				SetApplyButtonClickable(ui, true)
			end
		else
			ui:ExternalInterfaceCall(originalCall, id, value)
		end
	end
	
	local OnComboBox = function(ui, call, id, value)
		local originalCall = string.sub(call, 3)
		if currentMenu == MOD_MENU_ID then
			ModMenuManager.OnComboBox(id, value)
			SetApplyButtonClickable(ui, true)
		elseif currentMenu == LarianMenuID.Gameplay then
			if not GameSettingsMenu.OnComboBox(id, value) then
				ui:ExternalInterfaceCall(originalCall, id, value)
			else
				SetApplyButtonClickable(ui, true)
			end
		else
			ui:ExternalInterfaceCall(originalCall, id, value)
		end
	end

	local OnSelector = function(ui, call, id, value)
		local originalCall = string.sub(call, 3)
		if currentMenu == MOD_MENU_ID then
			ModMenuManager.OnSelector(id, value)
			SetApplyButtonClickable(ui, true)
		elseif currentMenu == LarianMenuID.Gameplay then
			if not GameSettingsMenu.OnSelector(id, value) then
				ui:ExternalInterfaceCall(originalCall, id, value)
			else
				SetApplyButtonClickable(ui, true)
			end
		else
			ui:ExternalInterfaceCall(originalCall, id, value)
		end
	end

	local OnSlider = function(ui, call, id, value)
		local originalCall = string.sub(call, 3)
		if currentMenu == MOD_MENU_ID then
			ModMenuManager.OnSlider(id, value)
			SetApplyButtonClickable(ui, true)
		elseif currentMenu == LarianMenuID.Gameplay then
			if not GameSettingsMenu.OnSlider(id, value) then
				ui:ExternalInterfaceCall(originalCall, id, value)
			else
				SetApplyButtonClickable(ui, true)
			end
		else
			ui:ExternalInterfaceCall(originalCall, id, value)
		end
	end

	---@param ui UIObject
	local OnButton = function(ui, call, id)
		local originalCall = string.sub(call, 3)
		if currentMenu == MOD_MENU_ID then
			ModMenuManager.OnButtonPressed(id)
			SetApplyButtonClickable(ui, true)
		elseif currentMenu == LarianMenuID.Gameplay then
			if not GameSettingsMenu.OnButtonPressed(id) then
				ui:ExternalInterfaceCall(originalCall, id)
			else
				SetApplyButtonClickable(ui, true)
			end
		else
			ui:ExternalInterfaceCall(originalCall, id)
		end
	end
	
	local onControlAdded = function(ui, call, controlType, id, listIndex, listProperty, ...)
		--ui = GetOptionsGUI() or ui
		if Vars.DebugMode then
			--print(ui:GetTypeId(), call, controlType, id, listIndex, listProperty)
		end
		if currentMenu == LarianMenuID.Gameplay then
			GameSettingsMenu.OnControlAdded(ui, controlType, id, listIndex, listProperty, ...)
		end
	end

	Ext.RegisterUITypeCall(Data.UIType.gameMenu, "requestCloseUI", OnOptionsClosed)

	local onOpenMenu = function(ui, ...)
		registeredListeners = false
		SetCurrentMenu(1)
	end

	--Ext.RegisterUINameCall("openMenu", onOpenMenu)
	Ext.RegisterUITypeInvokeListener(Data.UIType.gameMenu, "openMenu", onOpenMenu)
	Ext.RegisterUITypeInvokeListener(Data.UIType.gameMenu_c, "openMenu", onOpenMenu)

	Ext.RegisterUITypeCall(Data.UIType.optionsInput, "switchMenu", OnSwitchMenu)

	local uiTypes = not Vars.ControllerEnabled and OPTIONS_UI_TYPE or OPTIONS_UI_TYPE_C
	for _,uiType in pairs(uiTypes) do
		Ext.RegisterUITypeCall(uiType, "applyPressed", OnApplyPressed)
		Ext.RegisterUITypeCall(uiType, "acceptPressed", OnAcceptChanges)
		Ext.RegisterUITypeCall(uiType, "requestCloseUI", OnCancelChanges)

		Ext.RegisterUITypeCall(uiType, "switchMenu", OnSwitchMenu)

		Ext.RegisterUITypeCall(uiType, "controlAdded", onControlAdded)

		Ext.RegisterUITypeCall(uiType, "llbuttonPressed", OnButton)
		Ext.RegisterUITypeCall(uiType, "llmenuSliderID", OnSlider)
		Ext.RegisterUITypeCall(uiType, "llselectorID", OnSelector)
		Ext.RegisterUITypeCall(uiType, "llcheckBoxID", OnCheckBox)
		Ext.RegisterUITypeCall(uiType, "llcomboBoxID", OnComboBox)

		Ext.RegisterUITypeCall(uiType, "arrayParsed", OnUpdateArrayParsed)

		-- Ext.RegisterUITypeCall(uiType, "onSetButtonDisable", function(ui, call, buttonId, bDisabled)
		-- 	if buttonId ~= LarianButtonID.Apply or currentMenu ~= MOD_MENU_ID then
		-- 		ui:Invoke("setButtonDisableOriginal", buttonId, bDisabled)
		-- 	end
		-- end)
	end
end)