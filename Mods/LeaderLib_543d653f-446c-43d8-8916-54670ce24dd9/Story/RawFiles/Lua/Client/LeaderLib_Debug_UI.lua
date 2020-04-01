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