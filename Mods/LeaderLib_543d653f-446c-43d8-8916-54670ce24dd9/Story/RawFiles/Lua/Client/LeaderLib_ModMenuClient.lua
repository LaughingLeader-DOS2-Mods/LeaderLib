
local MODMENU_BUTTON_ID = 1337
local ModButtons = {}
local addedModMenuToOptions = false
local OpenMenu = function () end

local function OnGameMenuEvent(ui, call, arg1, arg2, arg3)
	Ext.Print("[LeaderLib_ModMenuClient.lua:OnGameMenuEvent] Event called. call("..tostring(call)..") arg1("..tostring(arg1)..") arg2("..tostring(arg2)..") arg3("..tostring(arg3)..")")
	if call == "LeaderLibModMenu_Initialized" then
		if addedModMenuToOptions == false then
			ui:Invoke("addMenuButton", MODMENU_BUTTON_ID, "Mod Settings", true)
			Ext.Print("[LeaderLib_ModMenuClient.lua:SetupOptionsSettings] Added mod menu option to the escape menu.")
		end
	elseif call == "buttonPressed" then
		if arg1 == MODMENU_BUTTON_ID then
			OpenMenu()
		end
	end
end

local function UIHookTest()
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/hotBar.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "updateSlots", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "hideTooltip", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "showCharTooltip", OnGameMenuEvent)
		ui:Invoke("setExp", 3333, false)
		ui:Invoke("allowActionsButton", false)
		ui:Invoke("toggleActionSkillHolder")
		--local actionSkills = ui:GetValue("actionSkillArray", "Array")
		--actionSkills[#actionSkills+1] = "Test"
		--actionSkills[#actionSkills+1] = true
		ui:SetValue("actionSkillArray", "Test", 1)
		ui:SetValue("actionSkillArray", true, 2)
		ui:Invoke("updateActionSkills")
		Ext.Print("[LeaderLib_ModMenuClient.lua:UIHookTest] Found hotBar.swf.")
	else
		Ext.Print("[LeaderLib_ModMenuClient.lua:UIHookTest] Failed to get Public/Game/GUI/hotBar.swf")
	end
end

local function SetupOptionsSettings()
	--UIHookTest()
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/gameMenu.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "registeranchorId", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "setAnchor", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "LeaderLibModMenu_Initialized", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "PlaySound", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "requestCloseUI", OnGameMenuEvent)
		Ext.RegisterUICall(ui, "buttonPressed", OnGameMenuEvent)
	else
		Ext.Print("[LeaderLib_ModMenuClient.lua:SetupOptionsSettings] Failed to get Public/Game/GUI/gameMenu.swf")
	end
end

local function CloseMenu()
	Ext.DestroyUI("LeaderLibModMenu")
end

local function SwitchMenu(ui, call, buttonId)
	Ext.Print("LeaderLib_ModMenuClient.lua:SwitchMenu] Switching menu to: " .. tostring(buttonId))
	ui:Invoke("removeItems")

	ui:Invoke("resetMenuButtons", buttonId)

	local menuTitle = ModButtons[buttonId]
	if menuTitle ~= nil then
		ui:Invoke("uiSetTitle", menuTitle)
	end
	ui:Invoke("setButtonDisable", buttonId, true)
	
	ui:Invoke("uiAddMenuLabel", "General")
	ui:Invoke("uiAddMenuButton", 1, "Test Button", "", true, "This is a tooltip!")
	ui:Invoke("addMenuInfoLabel", 2, "Thing", "Info here!")
	ui:Invoke("uiAddCheckbox", 3, "", true, 0, false, "Checkbox tooltip!")
	ui:Invoke("uiAddMenuDropDown", 4, "Test Dropdown", "Dropdown tooltip!")
	ui:Invoke("uiAddMenuDropDownEntry", 4, "Entry 1")
	ui:Invoke("uiAddMenuDropDownEntry", 4, "Entry 2")
	ui:Invoke("uiAddMenuDropDownEntry", 4, "Entry 3")
	ui:Invoke("uiAddMenuDropDownEntry", 4, "Entry 4")
	ui:Invoke("selectMenuDropDownEntry", 4, 0)
	ui:Invoke("uiAddMenuSlider", 5, "Test Slider", 0, 0, 10, 1, false, "Test menu slider")
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
	for _,uuid in ipairs(loadOrder) do
		if LeaderLib.IgnoredMods[uuid] ~= true then
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

OpenMenu = function ()
	local ui = Ext.GetUI("LeaderLibModMenu")
	if ui == nil then
		ui = Ext.CreateUI("LeaderLibModMenu", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_ModMenu.swf", 20)
	end
	if ui ~= nil then
		Ext.RegisterUICall(ui, "switchMenu", SwitchMenu)
		Ext.RegisterUICall(ui, "requestCloseUI", CloseMenu)
		ui:Invoke("uiSetTopTitle", "Mods")
		BuildMenu(ui)
		Ext.Print("LeaderLib_ModMenuClient.lua:OpenMenu] Showing mod menu.")
		
		ui:Show()
		ui:Invoke("setMenuScrolling", true)
		ui:Invoke("openMenu")
	end
	--local ui = Ext.CreateUI("Test", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/optionsSettings.swf", 20)
	--ui:Invoke("addMenuInfoLabel", 0, "Test", "Info")
	--ui:Invoke("addMenuCheckbox", 1, "Test", true, 0, false, "Tooltip")
	--ui:Invoke("addOptionButton", "Test 2", "switchMenu", nil, false)
	--ui:Invoke("addOptionButton", "Test 3", "switchMenu", nil, false)
end

local function OnClientMessage(event, data)
	if data == "OpenModMenu" then
		--OpenMenu()
		SetupOptionsSettings()
	end
	if Ext.IsDeveloperMode() then
		Ext.Print("LeaderLib_ModMenuClient.lua:OnClientMessage] Received client message.")
		Ext.Print("======")
		Ext.Print(data)
		Ext.Print("======")
	end
end

Ext.RegisterNetListener("LeaderLib_OnClientMessage", OnClientMessage)

local function Client_ModuleSetup()
	SetupOptionsSettings()
end

--Ext.RegisterListener("ModuleLoading", Client_ModuleSetup)
--Ext.RegisterListener("ModuleResume", Client_ModuleSetup)

local function SessionLoaded()
	SetupOptionsSettings()
end

Ext.RegisterListener("SessionLoaded", SetupOptionsSettings)