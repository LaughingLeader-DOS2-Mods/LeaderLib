
local MODMENU_BUTTON_ID = 734634
local ModButtons = {}
local addedModMenuToOptions = false
local modMenuOpen = false

LeaderLib_ModMenu_Listeners = {
	SwitchMenu = {},
	Clicked = {}
}
local OpenModMenu = function () end

local function OnGameMenuEvent(ui, call, ...)
	local params = Common.FlattenTable({...})
	--PrintDebug("[LeaderLib_ModMenuClient.lua:OnGameMenuEvent] Event called. call("..tostring(call)..") params("..tostring(Common.Dump(params))..")")
	--if call == "onGameMenuButtonAdded" then
	--if call == "PlaySound" and params[1] == "UI_Game_PauseMenu_Open" then
	if call == "onGameMenuSetup" then
		--local lastButtonID = params[1]
		--local lastButtonName = params[2]
		if addedModMenuToOptions == false then
			ui:Invoke("insertMenuButton", MODMENU_BUTTON_ID, "Mod Settings", true, 8)
			PrintDebug("[LeaderLib_ModMenuClient.lua:SetupOptionsSettings] Added mod menu option to the escape menu.")
			addedModMenuToOptions = true
		end
	elseif call == "buttonPressed" then
		if params[1] == MODMENU_BUTTON_ID then
			OpenModMenu()
			addedModMenuToOptions = false
		end
	elseif call == "requestCloseUI" then
		addedModMenuToOptions = false
	end
end

local function SetupOptionsSettings()
	addedModMenuToOptions = false
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/gameMenu.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "registeranchorId", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "setAnchor", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "PlaySound", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "requestCloseUI", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "buttonPressed", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "onEventInit", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "openMenu", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "executeSelected", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "setCursorPosition", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "onGameMenuButtonAdded", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "onGameMenuSetup", OnGameMenuEvent)
	else
		PrintDebug("[LeaderLib_ModMenuClient.lua:SetupOptionsSettings] Failed to get Public/Game/GUI/gameMenu.swf")
	end
end

local function CloseMenu()
	Ext.DestroyUI("LeaderLibModMenu")
	modMenuOpen = false
end

local function SwitchMenu(ui, call, ...)
	local params = Common.FlattenTable({...})
	local buttonId = params[1]
	PrintDebug("LeaderLib_ModMenuClient.lua:SwitchMenu] Switching menu to: " .. tostring(Common.Dump(params)))
	ui:Invoke("removeItems")
	ui:Invoke("resetMenuButtons", buttonId)

	local menuTitle = ModButtons[buttonId]
	if menuTitle ~= nil then
		ui:Invoke("modMenuSetTitle", menuTitle)
	end
	ui:Invoke("setButtonDisable", buttonId, true)
	
	ui:Invoke("modMenuAddMenuLabel", "General")
	ui:Invoke("modMenuAddMenuButton", 1, "Test Button", "", true, "This is a tooltip!")
	ui:Invoke("addMenuInfoLabel", 2, "Thing", "Info here!")
	ui:Invoke("modMenuAddCheckbox", 3, "", true, 0, false, "Checkbox tooltip!")
	ui:Invoke("modMenuAddMenuDropDown", 4, "Test Dropdown", "Dropdown tooltip!")
	ui:Invoke("modMenuAddMenuDropDownEntry", 4, "Entry 1")
	ui:Invoke("modMenuAddMenuDropDownEntry", 4, "Entry 2")
	ui:Invoke("modMenuAddMenuDropDownEntry", 4, "Entry 3")
	ui:Invoke("modMenuAddMenuDropDownEntry", 4, "Entry 4")
	ui:Invoke("selectMenuDropDownEntry", 4, 0)
	ui:Invoke("modMenuAddMenuSlider", 5, "Test Slider", 0, 0, 10, 1, false, "Test menu slider")
end

local function addTestButton(ui, buttonInt)
	local modName = "Test " .. tostring(buttonInt)
	ui:Invoke("addOptionButton", modName, "switchMenu", buttonInt, false, -1)
	ModButtons[buttonInt] = modName .. " Settings"
	buttonInt = buttonInt + 1
	return buttonInt
end

local function BuildMenu(ui)
	local loadOrder = Ext.GetModLoadOrder()

	table.sort(loadOrder, function(a,b)
		local moda = Ext.GetModInfo(a)
		local modb = Ext.GetModInfo(b)
		return string.upper(moda.Name) < string.upper(modb.Name)
	end)

	local buttonInt = 0
	for _,uuid in pairs(loadOrder) do
		if IgnoredMods[uuid] ~= true then
			local mod = Ext.GetModInfo(uuid)
			local modName = mod.Name:gsub(" %- Definitive Edition", "")
			local fontSize = -1
			if string.len(modName) > 24 then
				--modName = string.sub(modName, 0, 24)
				fontSize = 12
			end
			ui:Invoke("addOptionButton", modName, "switchMenu", buttonInt, false, fontSize)
			ModButtons[buttonInt] = modName .. " Settings"
			buttonInt = buttonInt + 1
		end
	end

	buttonInt = addTestButton(ui, buttonInt)
	buttonInt = addTestButton(ui, buttonInt)
	buttonInt = addTestButton(ui, buttonInt)
	buttonInt = addTestButton(ui, buttonInt)
	buttonInt = addTestButton(ui, buttonInt)
	buttonInt = addTestButton(ui, buttonInt)
	buttonInt = addTestButton(ui, buttonInt)
	buttonInt = addTestButton(ui, buttonInt)
	buttonInt = addTestButton(ui, buttonInt)

	ui:Invoke("setButtonEnabled", 0, true)
end

local function OnModMenuEvent(ui, call, ...)
	local params = {...}
	PrintDebug("[LeaderLib_ModMenuClient.lua:OnModMenuEvent] Event called. call("..tostring(call)..") params("..tostring(Common.Dump(params))..")")
	if call == "switchMenu" then
		SwitchMenu(ui, call, ...)
	elseif call == "requestCloseUI" then
		ui:Hide()
		CloseMenu()
	end
end

OpenModMenu = function ()
	local ui = Ext.GetUI("LeaderLibModMenu")
	if ui == nil then
		ui = Ext.CreateUI("LeaderLibModMenu", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_ModMenu.swf", 99)
	end
	if ui ~= nil and modMenuOpen == false then
		Ext.RegisterUICall(ui, "switchMenu", OnModMenuEvent)
		Ext.RegisterUICall(ui, "requestCloseUI", OnModMenuEvent)
		--ui:Invoke("updateAddBaseTopTitleText", "Mods")
		ui:Invoke("modMenuSetTopTitle", "Mods")
		BuildMenu(ui)
		PrintDebug("LeaderLib_ModMenuClient.lua:OpenModMenu] Showing mod menu.")

		local gameMenu = Ext.GetBuiltinUI("Public/Game/GUI/gameMenu.swf")
		gameMenu:ExternalInterfaceCall("focusLost")
		gameMenu:ExternalInterfaceCall("inputFocusLost")
		gameMenu:Hide()
		
		ui:Invoke("modMenuSetTitle", "Select a Mod")
		ui:Show()
		ui:Invoke("setMenuScrolling", true)
		ui:Invoke("openMenu")
		ui:ExternalInterfaceCall("requestOpenUI")
		ui:ExternalInterfaceCall("inputFocus")
		ui:ExternalInterfaceCall("show")
		ui:ExternalInterfaceCall("focus")
		modMenuOpen = true
	end
	--local ui = Ext.CreateUI("Test", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/optionsSettings.swf", 20)
	--ui:Invoke("addMenuInfoLabel", 0, "Test", "Info")
	--ui:Invoke("addMenuCheckbox", 1, "Test", true, 0, false, "Tooltip")
	--ui:Invoke("addOptionButton", "Test 2", "switchMenu", nil, false)
	--ui:Invoke("addOptionButton", "Test 3", "switchMenu", nil, false)
end

local function OnClientMessage(event, data)
	if data == "OpenModMenu" then
		--OpenModMenu()
		SetupOptionsSettings()
	end
	if Ext.IsDeveloperMode() then
		PrintDebug("LeaderLib_ModMenuClient.lua:OnClientMessage] Received client message.")
		PrintDebug("======")
		PrintDebug(data)
		PrintDebug("======")
	end
end

local function Client_ModuleSetup()
	--Ext.AddPathOverride("Public/Game/GUI/gameMenu.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/gameMenu.swf")
	--PrintDebug("LeaderLib_ModMenuClient.lua:Client_ModuleSetup] Overrode gameMenu.swf with LeaderLib version.")
end

local function SessionLoaded()
	SetupOptionsSettings()
end

if Ext.IsDeveloperMode() then
	--Ext.RegisterNetListener("LeaderLib_OnClientMessage", OnClientMessage)
	--Ext.RegisterListener("ModuleLoading", Client_ModuleSetup)
	--Ext.RegisterListener("ModuleResume", Client_ModuleSetup)
	if Ext.Version() >= 43 then
		--Ext.RegisterListener("SessionLoaded", SetupOptionsSettings)
	end
end