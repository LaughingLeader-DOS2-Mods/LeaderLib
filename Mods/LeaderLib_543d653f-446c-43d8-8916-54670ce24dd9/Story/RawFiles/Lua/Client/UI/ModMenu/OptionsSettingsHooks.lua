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
	print(method, main)
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

local OPTIONS_SETTINGS = 45

Ext.RegisterListener("SessionLoaded", function()
	for i,v in pairs(debugEvents) do
		--Ext.RegisterUITypeInvokeListener(OPTIONS_SETTINGS, v, function(ui, ...)
		---@param ui UIObject
		Ext.RegisterUINameInvokeListener(v, function(ui, ...)
			print(Ext.MonotonicTime(), ui:GetTypeId(), Ext.JsonStringify({...}))
		end)
	end
	-- Ext.RegisterUITypeInvokeListener(OPTIONS_SETTINGS, "setButtonDisable", function(ui, method, ...)
	-- 	if not addedModMenuButton then
	-- 		CreateModMenuButton(ui, method)
	-- 		addedModMenuButton = true
	-- 	end
	-- end)

	--Ext.RegisterUITypeCall(OPTIONS_SETTINGS, "switchToModMenu", function(ui, call, ...)
	Ext.RegisterUINameCall("switchToModMenu", function(ui, call, ...)
		SwitchToModMenu(ui)
	end)
	Ext.RegisterUITypeCall(OPTIONS_SETTINGS, "requestCloseUI", function(ui, call, ...)
		addedModMenuButton = false
	end)
	Ext.RegisterUITypeCall(OPTIONS_SETTINGS, "acceptPressed", function(ui, call, ...)
		addedModMenuButton = false
	end)

	--local ui = Ext.GetBuiltinUI("Public/Game/GUI/optionsSettings.swf")
	--Ext.RegisterUITypeInvokeListener(OPTIONS_SETTINGS, "parseUpdateArray", function(ui, ...)
	-- Ext.RegisterUINameInvokeListener("parseUpdateArray", function(ui, ...)
	-- 	print(ui:GetTypeId(), Ext.JsonStringify({...}))
	-- 	--UI.PrintArray(ui, "update_Array")
	-- 	local main = ui:GetRoot()
	-- 	if main ~= nil then
	-- 		local total = #main.update_Array
	-- 		print("update_Array")
	-- 		for i=0,total do
	-- 			local val = main.update_Array[i]
	-- 			print(string.format("[%i] = %s", i, val))
	-- 		end
	-- 	end
	-- end)
	--Ext.RegisterUITypeInvokeListener(OPTIONS_SETTINGS, "parseBaseUpdateArray", function(ui, method, ...)
	Ext.RegisterUINameInvokeListener("parseBaseUpdateArray", function(ui, method, ...)
		CreateModMenuButton(ui, method, ...)
		-- print(ui:GetTypeId(), Ext.JsonStringify({...}))
		-- --UI.PrintArray(ui, "update_Array")
		-- local main = ui:GetRoot()
		-- local total = #main.baseUpdate_Array
		-- print("baseUpdate_Array")
		-- for i=0,total do
		-- 	local val = main.baseUpdate_Array[i]
		-- 	print(string.format("[%i] = %s", i, val))
		-- end
	end)
end)