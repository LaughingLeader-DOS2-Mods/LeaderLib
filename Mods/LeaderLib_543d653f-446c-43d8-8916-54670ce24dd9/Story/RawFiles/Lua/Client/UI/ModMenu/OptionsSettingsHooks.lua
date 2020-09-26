--[[
[0] = 2.0
[1] = SETTINGS
[2] = 1.0
[3] = 0.0
[4] = Accept
[5] = 1.0
[6] = 1.0
[7] = Cancel
[8] = 1.0
[9] = 2.0
[10] = Apply
[11] = 0.0
[12] = 1.0
[13] = GRAPHICS
[14] = true
[15] = 0.0
[16] = 2.0
[17] = AUDIO
[18] = false
[19] = 0.0
[20] = 3.0
[21] = GAMEPLAY
[22] = false
[23] = 0.0
[24] = 4.0
[25] = CONTROLS
[26] = false
[27] = nil
]]

local MOD_MENU_ID = 69
local addedModMenuButton = false

---@param ui UIObject
local function CreateModMenuButton(ui, method, ...)
	local addToIndex = -1
	local main = ui:GetRoot()
	if main ~= nil then
		---@type MainMenuMC
		local mainMenu = main.mainMenu_mc
		local total = #main.baseUpdate_Array
		if total == 0 then
			mainMenu.addOptionButton("MOD SETTINGS", "switchToModMenu", MOD_MENU_ID, false)
		elseif total > 0 then
			-- local index = total-1
			-- main.baseUpdate_Array[index] = 0
			-- main.baseUpdate_Array[index+1] = MOD_MENU_ID
			-- main.baseUpdate_Array[index+2] = "MOD SETTINGS"
			-- main.baseUpdate_Array[index+3] = false
			mainMenu.addOptionButton("MOD SETTINGS", "switchToModMenu", MOD_MENU_ID, false)
			--local button = mainMenu.menuBtnList.getLastElement()
		end
	else
		ui:SetValue("baseUpdate_Array", 0, 27)
		ui:SetValue("baseUpdate_Array", MOD_MENU_ID, 28)
		ui:SetValue("baseUpdate_Array", "MOD SETTINGS", 29)
		ui:SetValue("baseUpdate_Array", false, 30)
	end

	-- local total = #main.baseUpdate_Array
	-- for i=0,total do
	-- 	local val = main.baseUpdate_Array[i]
	-- 	print(i,val)
	-- 	if val == "CONTROLS" then
	-- 		addToIndex = i - 2
	-- 	elseif val == "MOD SETTINGS" or val == MOD_MENU_ID then
	-- 		addToIndex = -1
	-- 		break
	-- 	end
	-- end

	-- if addToIndex > -1 then
	-- 	local controlID = main.baseUpdate_Array[addToIndex] + 1
	-- 	main.baseUpdate_Array[addToIndex] = 0
	-- 	main.baseUpdate_Array[addToIndex+1] = MOD_MENU_ID
	-- 	main.baseUpdate_Array[addToIndex+2] = "MOD SETTINGS"
	-- 	main.baseUpdate_Array[addToIndex+3] = false
	-- 	main.baseUpdate_Array[addToIndex+4] = 0
	-- 	main.baseUpdate_Array[addToIndex+5] = controlID
	-- 	main.baseUpdate_Array[addToIndex+6] = "CONTROLS"
	-- 	main.baseUpdate_Array[addToIndex+7] = false
	-- 	--main.baseUpdate_Array[addToIndex+8] = nil
	-- end
end

local function SwitchToModMenu(ui, ...)
	print("Switching to mod menu")
	local main = ui:GetRoot()
	---@type MainMenuMC
	local mainMenu = main.mainMenu_mc
	mainMenu.removeItems()
	mainMenu.resetMenuButtons(MOD_MENU_ID)
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
	ModMenuManager.SetScrollPosition(ui)
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
	"requestCloseUI",
	"acceptPressed",
	"applyPressed",
	"checkBoxID",
	"comboBoxID",
	"selectorID",
	"menuSliderID",
	"buttonPressed",
}

local OPTIONS_SETTINGS = 45
local OPTIONS_SETTINGS2 = 17
local OPTIONS_ACCEPT = 1

Ext.RegisterNetListener("LeaderLib_ModMenu_CreateMenuButton", function(cmd, payload)
	--local ui = Ext.GetUIByType(OPTIONS_SETTINGS2) or Ext.GetBuiltinUI("Public/Game/GUI/optionsSettings.swf")
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/optionsSettings.swf")
	print(cmd,payload,ui)
	if ui ~= nil then
		CreateModMenuButton(ui)
	end
end)

local registeredListeners = false

Ext.RegisterListener("SessionLoaded", function()
	if Ext.IsDeveloperMode() then
		for i,v in pairs(debugEvents) do
			---@param ui UIObject
			Ext.RegisterUINameInvokeListener(v, function(ui, ...)
				print(ui:GetTypeId(), Common.Dump({...}), Ext.MonotonicTime())
			end)
		end
		for i,v in pairs(debugCalls) do
			---@param ui UIObject
			Ext.RegisterUINameCall(v, function(ui, ...)
				print(ui:GetTypeId(), Common.Dump({...}), Ext.MonotonicTime())
			end)
		end
	end

	Ext.RegisterUINameCall("switchToModMenu", function(ui, call, ...)
		SwitchToModMenu(ui)
	end)
	Ext.RegisterUITypeCall(45, "requestCloseUI", function(ui, call, ...)
		ModMenuManager.SaveScroll(ui)
		ModMenuManager.UndoChanges()
		registeredListeners = false
	end)
	Ext.RegisterUITypeCall(45, "acceptPressed", function(ui, call, ...)
		ModMenuManager.SaveScroll(ui)
		ModMenuManager.CommitChanges()
		registeredListeners = false
	end)
	Ext.RegisterUITypeCall(1, "applyPressed", function(ui, call, ...)
		--ModMenuManager.CommitChanges()
	end)

	---@param ui UIObject
	Ext.RegisterUINameInvokeListener("parseBaseUpdateArray", function(ui, method, ...)
		-- Initial setup
		if ui:GetTypeId() == nil then
			local ui2 = Ext.GetBuiltinUI("Public/Game/GUI/optionsSettings.swf")
			if ui2 ~= nil then
				ui = ui2
			end
			--Ext.PostMessageToServer("LeaderLib_ModMenu_CreateMenuButtonAfterDelay", tostring(UI.ClientID))
		end
		
		CreateModMenuButton(ui, method, ...)
		if not registeredListeners then
			Ext.RegisterUICall(ui, "checkBoxID", function(ui, call, id, state)
				print(call,id,state)
				ModMenuManager.OnCheckbox(id, state)
			end)
			Ext.RegisterUICall(ui, "comboBoxID", function(ui, call, id, index)
				print(call,id,index)
				ModMenuManager.OnComboBox(id, index)
			end)
			Ext.RegisterUICall(ui, "selectorID", function(ui, call, id, currentSelection)
				print(call,id,currentSelection)
				ModMenuManager.OnSelector(id, currentSelection)
			end)
			Ext.RegisterUICall(ui, "menuSliderID", function(ui, call, id, value)
				print(call,id,value)
				ModMenuManager.OnSlider(id, value)
			end)
			Ext.RegisterUICall(ui, "buttonPressed", function(ui, call, id)
				print(call,id)
				ModMenuManager.OnButtonPressed(id)
			end)
			registeredListeners = true
		end
	end)
end)