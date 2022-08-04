--[[
==============
	Notes
==============
The options setting menu is optionsSettings.swf
When clicking on the Controls tab, the game switches the menu to optionsInput.swf and recreates the menu buttons.

To allow the Mod Settings button to work from the Controls view (everything is set up for optionsSettings.swf), we get the game to switch to the Graphics tab, and then immediately switch to the Mod Settings tab.
This seems to be the easiest option since the engine does some weird thing to switch the GUI between both options GUI files.
]]

local MOD_MENU_ID = 210
local isOpening = false

OptionsSettingsHooks = {
	MOD_MENU_ID = MOD_MENU_ID,
	LastMenu = -1,
	CurrentMenu = 1,
	SwitchToModMenu = false
}

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

OptionsSettingsHooks.LarianMenuID = LarianMenuID

if Vars.ControllerEnabled then
	LarianMenuID = {
		Graphics = 1,
		Audio = 2,
		Controls = 3,
		Gameplay = 4,
	}
end

local MessageBoxButtonID = {
	ACCEPT = 3,
	CANCEL = 4,
}

local LarianButtonID = {
	Accept = 0,
	Cancel = 1,
	Apply = 2
}

local ModMenuTabButtonText = Classes.TranslatedString:Create("h5945db23gdaafg400ega4d6gc2ffa7a53f92", "Mod Settings")
local ModMenuTabButtonTooltip = Classes.TranslatedString:Create("hc5012999g3c27g43bfg9a89g2a6557effb94", "Various mod options for active mods.")

---@return UIObject
local function GetOptionsGUI()
	if not Vars.ControllerEnabled then
		return Ext.UI.GetByPath("Public/Game/GUI/optionsSettings.swf")
	else
		return Ext.UI.GetByPath("Public/Game/GUI/optionsSettings_c.swf")
	end
end

OptionsSettingsHooks.GetOptionsGUI = GetOptionsGUI

Ext.RegisterNetListener("LeaderLib_ModMenu_RunParseUpdateArrayMethod", function(cmd,payload)
	local ui = GetOptionsGUI()
	if ui ~= nil then
		local this = ui:GetRoot()
		if this then
			this.parseUpdateArray()
		end
	end
end)

local function SetCurrentMenu(id)
	if OptionsSettingsHooks.CurrentMenu ~= id then
		OptionsSettingsHooks.CurrentMenu = math.floor(id)
		OptionsSettingsHooks.LastMenu = OptionsSettingsHooks.CurrentMenu
	end
end

---@param ui UIObject
local function SwitchToModMenu(ui, ...)
	local main = ui:GetRoot()
	if not main then
		Ext.PrintError("[LeaderLib:SwitchToModMenu] Error getting root from ui.")
		return
	end
	---@type MainMenuMC
	local mainMenu = main.mainMenu_mc
	SetCurrentMenu(MOD_MENU_ID)
	main.removeItems()
	if not Vars.ControllerEnabled then
		main.createApplyButton(false)
		main.resetMenuButtons(MOD_MENU_ID)

		--[[local buttonsArray = mainMenu.menuBtnList.content_array
		for i=0,#buttonsArray do
			local button = buttonsArray[i]
			if button ~= nil then
				if button.buttonID == MOD_MENU_ID then
					button.setEnabled(false)
				else
					button.setEnabled(true)
				end
			end
		end]]
	end
	
	ModMenuManager.CreateMenu(ui, mainMenu)

	if not Vars.ControllerEnabled then
		main.positionElements()
	else
		main.mainMenu_mc.addingDone()
	end
	ModMenuManager.SetScrollPosition(ui)
	OptionsSettingsHooks.SwitchToModMenu = false
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
		---@type MainMenuMC
		local mainMenu = main.mainMenu_mc
		if mainMenu then
			mainMenu.addOptionButton(ModMenuTabButtonText.Value, "switchToModMenu", MOD_MENU_ID, OptionsSettingsHooks.SwitchToModMenu, true)
			if OptionsSettingsHooks.SwitchToModMenu then
				main.clearAll()
				for i=0,#main.baseUpdate_Array do
					local val = main.baseUpdate_Array[i]
					if val == true then
						main.baseUpdate_Array[i] = false
						break
					end
				end
				SwitchToModMenu(ui)
			end
		end
	end
	OptionsSettingsHooks.SwitchToModMenu = false
end


---@param ui UIObject
local function CreateModMenuButton_Controller(ui, method, ...)
	local main = ui:GetRoot()
	if main ~= nil then
		main.addMenuButton(MOD_MENU_ID, ModMenuTabButtonText.Value, true, ModMenuTabButtonTooltip.Value)
		local arr = main.mainMenu_mc.btnList.content_array
		for i=0,#arr do
			local button = arr[i]
			if button and button.id == MOD_MENU_ID then
				button.enable = false
				break
			end
		end
	else
		ui:Invoke("addMenuButton", MOD_MENU_ID, ModMenuTabButtonText.Value, true, ModMenuTabButtonTooltip.Value)
	end
end

local function OnOptionsClosed()
	--SetCurrentMenu(1)
end

local menuWasOpen = false

local function OnSwitchMenu(ui, call, id)
	menuWasOpen = true

	local this = ui:GetRoot()

	--ui = GetOptionsGUI()
	if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
		ModMenuManager.SaveScroll(ui)
		this.mainMenu_mc.removeApplyCopy()
	elseif OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
		GameSettingsMenu.SaveScroll(ui)
	end
	SetCurrentMenu(id)

	if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
		SwitchToModMenu(ui)
	elseif OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
		--GameSettingsMenu.AddSettings(ui, true)
	end
end

local function OnParseBaseUpdateArray(ui, call)
	if OptionsSettingsHooks.CurrentMenu == -1 then
		return
	end
	local this = ui:GetRoot()
	local len = #this.baseUpdate_Array-1
	local i = 0
	while i < len do
		local t = this.baseUpdate_Array[i]
		if not type(t) == "number" then
			break
		end
		i = i + 1
		if t == 0 then
			local buttonID = this.baseUpdate_Array[i]
			this.baseUpdate_Array[i+2] = buttonID == OptionsSettingsHooks.CurrentMenu and not OptionsSettingsHooks.SwitchToModMenu
			i = i + 3
		elseif t == 1 then
			i = i + 2
		elseif t == 2 then
			i = i + 1
		end
	end
end

local function OnUpdateArrayParsed(ui, call, arrayName)
	if arrayName == "baseUpdate_Array" then
		if OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
			GameSettingsMenu.SetScrollPosition(ui)
		end
		if OptionsSettingsHooks.LastMenu == MOD_MENU_ID then
			OptionsSettingsHooks.SwitchToModMenu = true
		end
		--Update the localized name
		CreateModMenuButton(ui, call, arrayName)
		local this = ui:GetRoot()
		if this then
			this.positionElements()
		end
	elseif arrayName == "update_Array" then
		if OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
			GameSettingsMenu.AddSettings(ui, false)
		end
	end
end

local function OnAcceptChanges(ui)
	if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
		ModMenuManager.SaveScroll(ui)
		ModMenuManager.CommitChanges()
	elseif OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
		GameSettingsMenu.SaveScroll(ui)
		GameSettingsMenu.CommitChanges()
	end
	OnOptionsClosed()
end

local function SetApplyButtonClickable(ui, b)
	if ui == nil then
		ui = GetOptionsGUI()
	end
	if not ui then
		return
	end
	local this = ui:GetRoot()
	if this then
		if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
			if this.setApplyButtonCopyVisible then
				this.setApplyButtonCopyVisible(b)
			end
		elseif this.forceMenuButtonEnable then
			this.forceMenuButtonEnable(LarianButtonID.Apply, b)
		end
	end
end

ModMenuManager.SetApplyButtonClickable = SetApplyButtonClickable

local function OnApplyPressed(ui, call, ...)
	if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
		ModMenuManager.SaveScroll(ui)
		ModMenuManager.CommitChanges()
		SetApplyButtonClickable(ui, false)
	elseif OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
		GameSettingsMenu.SaveScroll(ui)
		GameSettingsMenu.CommitChanges()
	end
end

local function OnCancelChanges(ui, call)
	if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
		ModMenuManager.SaveScroll(ui)
		ModMenuManager.UndoChanges()
	elseif OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
		GameSettingsMenu.SaveScroll(ui)
		GameSettingsMenu.UndoChanges()
	end
	OnOptionsClosed()
end

local function IsLeaderLibMenuActive()
	if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID or OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
		return true
	end
	return false
end
OptionsSettingsHooks.IsLeaderLibMenuActive = IsLeaderLibMenuActive

function OptionsSettingsHooks.IsGameplayMenuActive()
	return OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay
end

local switchingToMenu = -1
local blockNext = 0

Ext.Events.UIInvoke:Subscribe(function (e)
	local uiName = Data.UITypeToName[e.UI.Type]
	if e.When == "Before" and (uiName == "optionsSettings" or uiName == "optionsInput") then
		if e.Function == "parseBaseUpdateArray" then
			OnParseBaseUpdateArray(e.UI, e.Function)
		elseif e.Function == "parseUpdateArray" then
			if isOpening then
				isOpening = false
				if (OptionsSettingsHooks.SwitchToModMenu or 
				(OptionsSettingsHooks.LastMenu > 1 and OptionsSettingsHooks.CurrentMenu ~= OptionsSettingsHooks.LastMenu)) then
					e:PreventAction()
					e:StopPropagation()
					blockNext = 1
					switchingToMenu = OptionsSettingsHooks.LastMenu
					OptionsSettingsHooks.SwitchToModMenu = switchingToMenu == MOD_MENU_ID
					SetCurrentMenu(switchingToMenu)
					Timer.Cancel("LeaderLib_OptionsMenu_SwitchToLastMenu")
					Timer.StartOneshot("LeaderLib_OptionsMenu_SwitchToLastMenu", 2, function()
						local ui = GetOptionsGUI()
						if switchingToMenu == MOD_MENU_ID then
							OptionsSettingsHooks.SwitchToModMenu = true
							SwitchToModMenu(ui)
						else
							if ui then
								ui:ExternalInterfaceCall("switchMenu", switchingToMenu)
							end
						end
					end)
				end
			else
				local this = e.UI:GetRoot()
				if blockNext > 0 or (this.currentMenuID ~= MOD_MENU_ID and OptionsSettingsHooks.SwitchToModMenu) then
					blockNext = blockNext - 1
					e:PreventAction()
				end
			end
		end
	end
end)

Ext.Events.SessionLoaded:Subscribe(function()
	--Override here so the settings in the main menu works
	Ext.IO.AddPathOverride("Public/Game/GUI/optionsSettings.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/Overrides/optionsSettings.swf")
	Ext.IO.AddPathOverride("Public/Game/GUI/optionsSettings_c.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/Overrides/optionsSettings_c.swf")

	local onMessageBoxButton = function(ui, call, id, device)
		-- Are you sure you want to discard your changes?
		if OptionsSettingsHooks.LastMenu == MOD_MENU_ID or OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
			if id == MessageBoxButtonID.CANCEL then

			elseif id == MessageBoxButtonID.ACCEPT then
				ModMenuManager.UndoChanges()
			end
		elseif OptionsSettingsHooks.LastMenu == LarianMenuID.Gameplay or OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
			if id == MessageBoxButtonID.CANCEL then

			elseif id == MessageBoxButtonID.ACCEPT then
				GameSettingsMenu.UndoChanges()
			end
		end
	end

	local OnOpenMenu = function(ui, ...)
		if not menuWasOpen then
			LoadGlobalSettings()
		end
		isOpening = true
		menuWasOpen = false
		OptionsSettingsHooks.CurrentMenu = LarianMenuID.Graphics
	end

	if not Vars.ControllerEnabled then
		local switchToModMenuFunc = function(ui, ...)
			OptionsSettingsHooks.SwitchToModMenu = true
			if OptionsSettingsHooks.CurrentMenu ~= 1 then
				ui:ExternalInterfaceCall("switchMenu", 1)
			else
				OptionsSettingsHooks.SwitchToModMenu = true
				SwitchToModMenu(ui)
			end
		end
		Ext.RegisterUINameCall("switchToModMenu", switchToModMenuFunc)
		Ext.RegisterUINameCall("switchToModMenuFromInput", switchToModMenuFunc)

		Ext.RegisterUITypeCall(Data.UIType.msgBox, "ButtonPressed", onMessageBoxButton)

		---optionsInput.swf version.
		---@param ui UIObject
		Ext.RegisterUINameInvokeListener("addMenuButtons", function(ui, method, ...)
			local ui = Ext.UI.GetByPath("Public/Game/GUI/optionsInput.swf")
			if ui then
				local main = ui:GetRoot()
				if main then
					---@type MainMenuMC
					local mainMenu = main.controlsMenu_mc
					mainMenu.addMenuButton(ModMenuTabButtonText.Value, "switchToModMenuFromInput", MOD_MENU_ID, false)
				end
			end
		end)
	
		Ext.RegisterUITypeInvokeListener(Data.UIType.gameMenu, "openMenu", OnOpenMenu)
		Ext.RegisterUITypeCall(Data.UIType.gameMenu, "requestCloseUI", OnOptionsClosed)
		Ext.RegisterUITypeCall(Data.UIType.optionsInput, "switchMenu", OnSwitchMenu)
	else
		Ext.RegisterUITypeCall(Data.UIType.mainMenu_c, "disabledButtonPressed", function(ui, call, id)
			if id == MOD_MENU_ID then
				OptionsSettingsHooks.SwitchToModMenu = true
				ui:ExternalInterfaceCall("buttonOver", 1)
				ui:ExternalInterfaceCall("buttonPressed", 1)
				SetCurrentMenu(MOD_MENU_ID)
			end
		end)
		Ext.RegisterUITypeCall(Data.UIType.mainMenu_c, "buttonPressed", function(ui, call, id)
			SetCurrentMenu(id)
		end)

		Ext.RegisterUITypeCall(Data.UIType.msgBox_c, "ButtonPressed", onMessageBoxButton)

		local gameButtonText = Ext.GetTranslatedString("h12fb7af4ga5abg47f4g9120ga63d33b2b71d", "Game")
		Ext.RegisterUINameInvokeListener("addMenuButton", function(invokedUI, method, id, label, tooltip, enabled)
			if id == 4 and label == gameButtonText then
				local typeId = invokedUI:GetTypeId()
				Timer.StartOneshot("addModMenuOptionsButton", 10, function()
					local ui = Ext.GetUIByType(Data.UIType.mainMenu_c) or Ext.GetUIByType(typeId)
					if ui ~= nil then
						CreateModMenuButton_Controller(ui, method)
					end
				end)
				--Ext.GetBuiltinUI("Public/Game/GUI/gameMenu_c.swf")
			end
		end)
		Ext.RegisterUINameInvokeListener("addingDone", function(invokedUI, method, id, label, tooltip, enabled)
			if OptionsSettingsHooks.SwitchToModMenu then
				OptionsSettingsHooks.SwitchToModMenu = false
				local uiType = invokedUI.Type
				Timer.Cancel("createModSettingsMenu")
				Timer.StartOneshot("createModSettingsMenu", 10, function()
					local ui = GetOptionsGUI() or Ext.UI.GetByType(uiType)
					if ui then
						SwitchToModMenu(ui)
					end
				end)
			end
		end)

		Ext.RegisterUITypeInvokeListener(Data.UIType.gameMenu_c, "openMenu", OnOpenMenu)
	end

	local controlOriginalCalls = {
		llbuttonPressed = "buttonPressed",
		llmenuSliderID = "menuSliderID",
		llselectorID = "selectorID",
		llcheckBoxID = "checkBoxID",
		llcomboBoxID = "comboBoxID",
	}

	local function getOriginalCall(call)
		local originalCall = controlOriginalCalls[call]
		if originalCall then
			return originalCall
		elseif string.find(call, "^ll", 1) then -- safeguard
			return string.sub(call, 3)
		end
		return false
	end

	local OnCheckBox = function(ui, call, id, value)
		local originalCall = getOriginalCall(call)
		if originalCall then
			if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
				ModMenuManager.OnCheckbox(id, value)
				SetApplyButtonClickable(ui, true)
			elseif OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
				if not GameSettingsMenu.OnCheckbox(id, value) then
					ui:ExternalInterfaceCall(originalCall, id, value)
				else
					SetApplyButtonClickable(ui, true)
				end
			else
				ui:ExternalInterfaceCall(originalCall, id, value)
			end
		end
	end
	
	local OnComboBox = function(ui, call, id, value)
		local originalCall = getOriginalCall(call)
		if originalCall then
			if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
				ModMenuManager.OnComboBox(id, value)
				SetApplyButtonClickable(ui, true)
			elseif OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
				if not GameSettingsMenu.OnComboBox(id, value) then
					ui:ExternalInterfaceCall(originalCall, id, value)
				else
					SetApplyButtonClickable(ui, true)
				end
			else
				ui:ExternalInterfaceCall(originalCall, id, value)
			end
		end
	end

	local OnSelector = function(ui, call, id, value)
		local originalCall = getOriginalCall(call)
		if originalCall then
			if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
				ModMenuManager.OnSelector(id, value)
				SetApplyButtonClickable(ui, true)
			elseif OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
				if not GameSettingsMenu.OnSelector(id, value) then
					ui:ExternalInterfaceCall(originalCall, id, value)
				else
					SetApplyButtonClickable(ui, true)
				end
			else
				ui:ExternalInterfaceCall(originalCall, id, value)
			end
		end
	end

	local OnSlider = function(ui, call, id, value)
		local originalCall = getOriginalCall(call)
		if originalCall then
			if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
				ModMenuManager.OnSlider(id, value)
				SetApplyButtonClickable(ui, true)
			elseif OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
				if not GameSettingsMenu.OnSlider(id, value) then
					ui:ExternalInterfaceCall(originalCall, id, value)
				else
					SetApplyButtonClickable(ui, true)
				end
			else
				ui:ExternalInterfaceCall(originalCall, id, value)
			end
		end
	end

	---@param ui UIObject
	local OnButton = function(ui, call, id)
		local originalCall = getOriginalCall(call)
		if originalCall then
			if OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
				ModMenuManager.OnButtonPressed(id)
				SetApplyButtonClickable(ui, true)
			elseif OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
				if GameSettingsMenu.OnButtonPressed(id) == false then
					ui:ExternalInterfaceCall(originalCall, id)
				else
					SetApplyButtonClickable(ui, true)
				end
			else
				ui:ExternalInterfaceCall(originalCall, id)
			end
		end
	end
	
	local onControlAdded = function(ui, call, controlType, id, listIndex, listProperty, ...)
		if OptionsSettingsHooks.CurrentMenu == LarianMenuID.Gameplay then
			GameSettingsMenu.OnControlAdded(ui, controlType, id, listIndex, listProperty, ...)
		end
	end

	local uiTypes = not Vars.ControllerEnabled and OPTIONS_UI_TYPE or OPTIONS_UI_TYPE_C
	for _,uiType in pairs(uiTypes) do
		Ext.RegisterUITypeCall(uiType, "requestCloseUI", OnCancelChanges)

		Ext.RegisterUITypeCall(uiType, "applyPressed", OnApplyPressed)
		Ext.RegisterUITypeCall(uiType, "applyModMenuChanges", OnApplyPressed)
		Ext.RegisterUITypeCall(uiType, "acceptPressed", OnAcceptChanges)
		Ext.RegisterUITypeCall(uiType, "commitModMenuChanges", function(ui, call, ...)
			OnAcceptChanges(ui)
			ui:ExternalInterfaceCall("requestCloseUI");
		end)

		if not Vars.ControllerEnabled then
			Ext.RegisterUITypeCall(uiType, "switchMenu", OnSwitchMenu)
		end

		-- LeaderLib additions
		Ext.RegisterUITypeCall(uiType, "controlAdded", onControlAdded)
		Ext.RegisterUITypeCall(uiType, "arrayParsed", OnUpdateArrayParsed)
		Ext.RegisterUITypeCall(uiType, "llbuttonPressed", OnButton)
		Ext.RegisterUITypeCall(uiType, "llmenuSliderID", OnSlider)
		Ext.RegisterUITypeCall(uiType, "llselectorID", OnSelector)
		Ext.RegisterUITypeCall(uiType, "llcheckBoxID", OnCheckBox)
		Ext.RegisterUITypeCall(uiType, "llcomboBoxID", OnComboBox)
	end
end)

--Mods.LeaderLib.Events.GameSettingsChanged:Invoke({Settings=Mods.LeaderLib.GameSettingsManager.GetSettings(), FromSync=true})

Events.GameSettingsChanged:Subscribe(function (e)
	if e.FromSync and OptionsSettingsHooks.IsGameplayMenuActive() then
		local ui = OptionsSettingsHooks.GetOptionsGUI()
		if ui then
			ui:ExternalInterfaceCall("switchMenu", LarianMenuID.Gameplay)
		end
	end
end)

--Mods.LeaderLib.Events.GlobalSettingsLoaded:Invoke({Settings=Mods.LeaderLib.GlobalSettings, FromSync=true})

Events.GlobalSettingsLoaded:Subscribe(function (e)
	if e.FromSync and OptionsSettingsHooks.CurrentMenu == MOD_MENU_ID then
		local ui = OptionsSettingsHooks.GetOptionsGUI()
		if ui then
			SwitchToModMenu(ui)
		end
	end
end)