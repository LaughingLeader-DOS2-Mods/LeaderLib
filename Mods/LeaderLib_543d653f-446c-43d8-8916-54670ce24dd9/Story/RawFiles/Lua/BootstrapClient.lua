Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "BootstrapShared.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Client/LeaderLib_ModMenuClient.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Client/LeaderLib_CharacterSheet.lua")
Ext.Require("LeaderLib_7e737d2f-31d2-4751-963f-be6ccc59cd0c", "Client/LeaderLib_Debug_UI.lua")

local function LeaderLib_Debug_OnDebugUIEvent(ui, event, ...)
	local params = {...}
	PrintDebug("[LeaderLib:BootstrapClient.lua:OnDebugUIEvent] Event (" .. tostring(event) .. ") Params(".. Common.Dump(params) .. ")")

	local eventParam = params[1]
	local param1 = params[2]
	local param2 = params[3]
	local param3 = params[4]
	local cc = Ext.GetBuiltinUI("Public/Game/GUI/characterCreation.swf")
	if cc ~= nil then
		cc:Invoke(eventParam, param1, param2, param3)
		PrintDebug("[LeaderLib:BootstrapClient.lua:OnDebugUIEvent] Called function on characterCreation.swf.")
	else
		PrintDebug("[LeaderLib:BootstrapClient.lua:OnDebugUIEvent] Failed to get Public/Game/GUI/characterCreation.swf")
	end
end

-- this.contentArray = new Array(this.origins_mc.originSelector_mc,this.origins_mc.presetSelector_mc,this.root_mc.header_mc.textFieldName_mc,this.appearance_mc.faceSelector_mc,this.appearance_mc.facialSelector_mc,this.appearance_mc.hairSelector_mc,this.appearance_mc.skinSelector_mc,this.appearance_mc.hairColourSelector_mc,this.appearance_mc.voiceSelector_mc,this.class_mc.classSelector_mc);
local function LeaderLib_Client_OpenDebugWindow()
	local ui = Ext.GetUI("LeaderLib_DebugMenu")
	if ui == nil then
		ui = Ext.CreateUI("LeaderLib_DebugMenu", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/DebugConsole.swf", 99)
	end
	if ui ~= nil then
		Ext.RegisterUICall(ui, "onEvent", LeaderLib_Debug_OnDebugUIEvent)
		PrintDebug("[LeaderLib:BootstrapClient.lua] Showing debug window.")
		ui:Show()
		ui:SetPosition(200,200)
	end
	--local ui = Ext.CreateUI("Test", "Public/ModMenu_a40f91f5-a520-4857-a954-0e0365eafa98/GUI/optionsSettings.swf", 20)
	--ui:Invoke("addMenuInfoLabel", 0, "Test", "Info")
	--ui:Invoke("addMenuCheckbox", 1, "Test", true, 0, false, "Tooltip")
	--ui:Invoke("addOptionButton", "Test 2", "switchMenu", nil, false)
	--ui:Invoke("addOptionButton", "Test 3", "switchMenu", nil, false)
end

local function LeaderLib_Client_ModuleSetup()
	LeaderLib_Client_OpenDebugWindow()
end

local function LeaderLib_SyncRanSeed(call, seedstr)
	_G["LEADERLIB_RAN_SEED"] = math.tointeger(seedstr)
	PrintDebug("[LeaderLib:BootstrapClient.lua:LeaderLib_SyncRanSeed] Set [LEADERLIB_RAN_SEED] to ("..tostring(_G["LEADERLIB_RAN_SEED"])..").")
end

Ext.RegisterNetListener("LeaderLib_SyncRanSeed", LeaderLib_SyncRanSeed)

if Ext.IsDeveloperMode() then
	-- Ext.RegisterListener("ModuleLoading", LeaderLib_Client_ModuleSetup)
	-- Ext.RegisterListener("ModuleResume", LeaderLib_Client_ModuleSetup)
	-- Ext.RegisterListener("SessionLoading", LeaderLib_Client_ModuleSetup)
end