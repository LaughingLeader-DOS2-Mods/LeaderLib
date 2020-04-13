local function OnGameMenuEvent(ui, call, ...)
	local params = LeaderLib.Common.FlattenTable({...})
	--Ext.Print("[LeaderLib_ModMenuClient.lua:OnGameMenuEvent] Event called. call("..tostring(call)..") params("..tostring(LeaderLib.Common.Dump(params))..")")
	--if call == "onGameMenuButtonAdded" then
	--if call == "PlaySound" and params[1] == "UI_Game_PauseMenu_Open" then
	if call == "onGameMenuSetup" then
		--local lastButtonID = params[1]
		--local lastButtonName = params[2]
	elseif call == "buttonPressed" then

	elseif call == "requestCloseUI" then
		
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

local addedTalents = false

local function addTestTalents(ui)
	local talentId = 0
	for i=0,90,3 do
		ui:SetValue("talent_array", "Test Talent " .. tostring(talentId), i)
		ui:SetValue("talent_array", talentId, i+1)
		ui:SetValue("talent_array", 1, i+2)
		talentId = talentId + 1
		--ui:Invoke("addTalent","Test Talent " .. tostring(i), i, 0)
	end
	ui:Invoke("updateArraySystem")
	addedTalents = true
end

local function OnSheetEvent(ui, call, ...)
	local params = LeaderLib.Common.FlattenTable({...})
	Ext.Print("[LeaderLib_ModMenuClient.lua:OnSheetEvent] Event called. call("..tostring(call)..") params("..tostring(LeaderLib.Common.Dump(params))..")")
	--if call == "onGameMenuButtonAdded" then
	--if call == "PlaySound" and params[1] == "UI_Game_PauseMenu_Open" then
	if call == "onGameMenuSetup" then
		--local lastButtonID = params[1]
		--local lastButtonName = params[2]
	elseif call == "buttonPressed" then

	elseif call == "requestCloseUI" or call == "hideUI" then
		addedTalents = false
	elseif call == "showTalentTooltip" and not addedTalents then
		addTestTalents(ui)
	end
end

local function LeaderLib_ClientDebug_SessionLoaded()
	local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	if ui ~= nil then
		Ext.RegisterUICall(ui, "setPosition", OnSheetEvent)
		Ext.RegisterUICall(ui, "getStats", OnSheetEvent)
		Ext.RegisterUICall(ui, "hideTooltip", OnSheetEvent)
		Ext.RegisterUICall(ui, "openContextMenu", OnSheetEvent)
		Ext.RegisterUICall(ui, "PlaySound", OnSheetEvent)
		Ext.RegisterUICall(ui, "UIAssert", OnSheetEvent)
		Ext.RegisterUICall(ui, "inputFocus", OnSheetEvent)
		Ext.RegisterUICall(ui, "inputFocusLost", OnSheetEvent)
		Ext.RegisterUICall(ui, "hideUI", OnSheetEvent)
		Ext.RegisterUICall(ui, "selectCharacter", OnSheetEvent)
		Ext.RegisterUICall(ui, "showCustomStatTooltip", OnSheetEvent)
		Ext.RegisterUICall(ui, "showStatTooltip", OnSheetEvent)
		Ext.RegisterUICall(ui, "showTalentTooltip", OnSheetEvent)
		Ext.RegisterUICall(ui, "onGenerateTreasure", OnSheetEvent)
		Ext.RegisterUICall(ui, "onClearInventory", OnSheetEvent)
		Ext.RegisterUICall(ui, "setMcSize", OnSheetEvent)
		Ext.RegisterUICall(ui, "registerAnchorId", OnSheetEvent)
		Ext.RegisterUICall(ui, "unregisterAnchorId", OnSheetEvent)
		Ext.RegisterUICall(ui, "setAnchor", OnSheetEvent)
		Ext.RegisterUICall(ui, "keepUIinScreen", OnSheetEvent)
		Ext.RegisterUICall(ui, "clearAnchor", OnSheetEvent)
		addedTalents = false
		Ext.Print("[LeaderLib_ModMenuClient.lua:UIHookTest] Found characterSheet.swf.")
	else
		Ext.Print("[LeaderLib_ModMenuClient.lua:UIHookTest] Failed to get Public/Game/GUI/characterSheet.swf")
	end
end

if Ext.IsDeveloperMode() and Ext.Version() >= 43 then
	--Ext.RegisterListener("SessionLoaded", LeaderLib_ClientDebug_SessionLoaded)
end