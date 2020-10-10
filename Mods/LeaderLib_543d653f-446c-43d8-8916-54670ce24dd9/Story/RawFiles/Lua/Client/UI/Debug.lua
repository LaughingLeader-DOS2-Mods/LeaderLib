local function OnGameMenuEvent(ui, call, ...)
	local params = Common.FlattenTable({...})
	--PrintDebug("[LeaderLib_ModMenuClient.lua:OnGameMenuEvent] Event called. call("..tostring(call)..") params("..tostring(Common.Dump(params))..")")
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
		PrintDebug("[LeaderLib_ModMenuClient.lua:UIHookTest] Found hotBar.swf.")
	else
		PrintDebug("[LeaderLib_ModMenuClient.lua:UIHookTest] Failed to get Public/Game/GUI/hotBar.swf")
	end
end

local function PrintArrayValue(ui, index, arrayName)
	local val = ui:GetValue(arrayName, "number", index)
	if val == nil then
		val = ui:GetValue(arrayName, "string", index)
		if val == nil then
			val = ui:GetValue(arrayName, "boolean", index)
		else
			val = "\""..val.."\""
		end
	end
	if val ~= nil then
		print(" ["..index.."] = ["..tostring(val).."]")
	end
end

function UI.PrintArray(ui, arrayName)
	print("==============")
	print(arrayName)
	print("==============")
	local i = 0
	while i < 300 do
		PrintArrayValue(ui, i, arrayName)
		i = i + 1
	end
	print("==============")
end

local addedTalents = false
local addedAbilities = false

local function GetArrayIndexStart(ui, arrayName, offset)
	local i = 0
	while i < 9999 do
		local val = ui:GetValue(arrayName, "number", i)
		if val == nil then
			val = ui:GetValue(arrayName, "string", i)
			if val == nil then
				val = ui:GetValue(arrayName, "boolean", i)
			end
		end
		if val == nil then
			return i
		end
		i = i + offset
	end
	return -1
end

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
	local params = Common.FlattenTable({...})
	PrintDebug("[LeaderLib_ModMenuClient.lua:OnSheetEvent] Event called. call("..tostring(call)..") params("..tostring(Common.Dump(params))..")")
	--if call == "onGameMenuButtonAdded" then
	--if call == "PlaySound" and params[1] == "UI_Game_PauseMenu_Open" then
	if call == "onGameMenuSetup" then
		--local lastButtonID = params[1]
		--local lastButtonName = params[2]
	elseif call == "buttonPressed" then

	elseif call == "requestCloseUI" or call == "hideUI" then
		addedTalents = false
		addedAbilities = false
	elseif call == "showTalentTooltip" and not addedTalents then
		addTestTalents(ui)
	elseif call == "showAbilityTooltip" and not addedAbilities then
		--addMissingAbilities(ui)
	end

	if call == "selectedTab" then

	end
end

local overheadFunctions = {
	"setOverheadSize",
	"reorderTexts",
	"reorderAllTexts",
	"addOverhead",
	"addOverheadDamage",
	"addADialog",
	"repositionHolders",
	"setAPString",
	"addOverheadSelectionInfo",
	"clearOverheadSelectionInfo",
	"clearAllOverheadSelectionInfos",
	--"updateOHs",
	"cleanUpAllStatusses",
	"updateStatusses",
	"setStatus",
	"cleanupStatuses",
	"setIggyImage",
	"removeChildrenOf",
	"getCharHolderIndex",
	"getCharHolder",
	"INTnewCharacterHolder",
	"newCharacterHolder",
	"clearAD",
	"INTclearAD",
	"getOHOffset",
	"clearObsoleteOHTs",
	"findInArray",
	"removeCharHolderInt",
	"tryToPutBackInCache",
	"getCharHolderFromArrayINT",
	"findOverlaps",
	"clearAll",
	"cleanupDeleteRequests",
	"fadeOutObsoleteDialogs",
	"checkCharHolderMC",
	"getOHTPos",
	"setAction",
	"checkInfoIcons",
	--"setHPBars",
	"setCharInfoPositioning",
	"changeColour",
}

local function TraceCall(ui, ...)
	print(Ext.JsonStringify({...}))
end

local function TraceTooltip(call, val, tooltipdata)
	print(call, val, Ext.JsonStringify(tooltipdata))
end

local allUIFiles = {
"actionProgression.swf",
"addContent.swf",
"addContent_c.swf",
"areaInteract_c.swf",
"arenaResult.swf",
"book.swf",
"bottomBar_c.swf",
"buttonLayout_c.swf",
"calibrationScreen.swf",
"characterAssign.swf",
"characterAssign_c.swf",
"characterCreation.swf",
"characterCreation_c.swf",
"characterSheet.swf",
"chatLog.swf",
"combatLog.swf",
"combatLog_c.swf",
"combatTurn.swf",
"connectionMenu.swf",
"connectivity_c.swf",
"consoleHints_c.swf",
"consoleHintsPS_c.swf",
"containerInventory.swf",
"containerInventory_lib.swf",
"contextMenu.swf",
"contextMenu_c.swf",
"craftPanel_c.swf",
"credits.swf",
"dialog.swf",
"dialog_c.swf",
"diplomacy.swf",
"dummyOverhead.swf",
"enemyHealthBar.swf",
"engrave.swf",
"equipmentPanel_c.swf",
"examine.swf",
"examine_c.swf",
"feedback_c.swf",
"fonts_en.swf",
"formation.swf",
"formation_c.swf",
"fullScreenHUD.swf",
"gameMenu.swf",
"gameMenu_c.swf",
"giftBagContent.swf",
"giftBagsMenu.swf",
"hotBar.swf",
"installScreen_c.swf",
"inventorySkillPanel_c.swf",
"itemAction.swf",
"itemSplitter.swf",
"itemSplitter_c.swf",
"journal.swf",
"journal_c.swf",
"journal_csp.swf",
"loadingScreen.swf",
"LSClasses.swf",
"mainMenu.swf",
"mainMenu_c.swf",
"menuBG.swf",
"minimap.swf",
"minimap_c.swf",
"mods.swf",
"mods_c.swf",
"mouseIcon.swf",
"msgBox.swf",
"msgBox_c.swf",
"notification.swf",
"npcInfo.swf",
"optionsInput.swf",
"optionsSettings.swf",
"optionsSettings_c.swf",
"overhead.swf",
"panelSelect_c.swf",
"partyInventory.swf",
"partyInventory_c.swf",
"partyManagement_c.swf",
"playerInfo.swf",
"pyramid.swf",
"pyramid_c.swf",
"reward.swf",
"reward_c.swf",
"saveLoad.swf",
"saveLoad_c.swf",
"saving.swf",
"serverlist.swf",
"serverlist_c.swf",
"skills.swf",
"skillsSelection.swf",
"sortBy_c.swf",
"startTurnRequest.swf",
"startTurnRequest_c.swf",
"statsPanel_c.swf",
"statusConsole.swf",
"storyElement.swf",
"subtitles.swf",
"textDisplay.swf",
"texture_lib.swf",
"texture_lib_c.swf",
"tooltip.swf",
"tooltipHelper.swf",
"tooltipHelper_kb.swf",
"trade.swf",
"trade_c.swf",
"tutorialBox.swf",
"tutorialBox_c.swf",
"uiCraft.swf",
"uiElements.swf",
"uiFade.swf",
"userProfile.swf",
"voiceNotification_c.swf",
"watermark.swf",
"waypoints.swf",
"waypoints_c.swf",
"worldTooltip.swf",
}

local function SessionLoaded()
	for i,v in pairs(allUIFiles) do
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/"..v)
		if ui ~= nil then
			print(v, ui:GetTypeId())
		end
	end
	-- Game.Tooltip.RegisterListener("Stat", nil, function(char,stat,tooltipdata) pcall(TraceTooltip, "Stat", stat, tooltipdata) end)
	--Game.Tooltip.RegisterListener("Skill", nil, function(char,skill,tooltipdata) pcall(TraceTooltip, "Skill", skill, tooltipdata) end)
	-- Game.Tooltip.RegisterListener("Status", nil, function(char,status,tooltipdata) pcall(TraceTooltip, "Status", status.StatusId, tooltipdata) end)
	-- Game.Tooltip.RegisterListener("Item", nil, function(item,tooltipdata) pcall(TraceTooltip, "Item", item.StatsId, tooltipdata) end)
	-- local ui = Ext.GetBuiltinUI("Public/Game/GUI/textDisplay.swf")
	-- if ui ~= nil then
	-- 	Ext.RegisterUIInvokeListener(ui, "addText", TraceCall)
	-- 	Ext.RegisterUIInvokeListener(ui, "displaySurfaceText", TraceCall)
	-- 	Ext.RegisterUIInvokeListener(ui, "addLabel", TraceCall)
	-- 	Ext.RegisterUIInvokeListener(ui, "moveText", TraceCall)
	-- end
	-- local ui = Ext.GetBuiltinUI("Public/Game/GUI/overhead.swf")
	-- if ui ~= nil then
	-- 	Ext.RegisterUIInvokeListener(ui, "setHPBars", function(ui, call, ...)
	-- 		print(call)
	-- 		print(Ext.JsonStringify({...}))
	-- 	end)
	-- 	-- Ext.RegisterUIInvokeListener(ui, "updateOHs", function(ui, call, ...)
	-- 	-- 	PrintArray(ui, "addOH_array")
	-- 	-- 	PrintArray(ui, "selectionInfo_array")
	-- 	-- 	PrintArray(ui, "hp_array")
	-- 	-- end)
	-- 	for i,v in pairs(overheadFunctions) do
	-- 		Ext.RegisterUIInvokeListener(ui, v, function(ui, ...)
	-- 			Ext.Print(Ext.JsonStringify({...}))
	-- 		end)
	-- 	end
	-- end
	-- local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	-- if ui ~= nil then
	-- 	Ext.RegisterUIInvokeListener(ui, "updateArraySystem", function(ui, call, ...)
	-- 		--PrintArray(ui, "tags_array")
	-- 		local i = GetArrayIndexStart(ui, "talent_array", 1)
	-- 		ui:SetValue("talent_array", "Undead", i)
	-- 		ui:SetValue("talent_array", Data.TalentEnum.Zombie, i+1)
	-- 		ui:SetValue("talent_array", 0, i+2)
	-- 		ui:SetValue("talent_array", "Corpse Eater", i+3)
	-- 		ui:SetValue("talent_array", Data.TalentEnum.Elf_CorpseEating, i+4)
	-- 		ui:SetValue("talent_array", 0, i+5)
	-- 		PrintArray(ui, "talent_array")
	-- 	end)
	-- end
	-- local ui = Ext.GetBuiltinUI("Public/Game/GUI/characterSheet.swf")
	-- if ui ~= nil then
	-- 	Ext.RegisterUICall(ui, "setPosition", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "getStats", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "selectedTab", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "hideTooltip", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "openContextMenu", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "PlaySound", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "UIAssert", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "inputFocus", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "inputFocusLost", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "hideUI", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "selectCharacter", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "showCustomStatTooltip", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "showStatTooltip", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "showTalentTooltip", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "showAbilityTooltip", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "onGenerateTreasure", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "onClearInventory", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "setMcSize", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "registerAnchorId", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "unregisterAnchorId", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "setAnchor", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "keepUIinScreen", OnSheetEvent)
	-- 	Ext.RegisterUICall(ui, "clearAnchor", OnSheetEvent)
	-- 	addedTalents = false
	-- 	addedAbilities = false
	-- 	PrintDebug("[LeaderLib_ModMenuClient.lua:UIHookTest] Found characterSheet.swf.")
	-- else
	-- 	PrintDebug("[LeaderLib_ModMenuClient.lua:UIHookTest] Failed to get Public/Game/GUI/characterSheet.swf")
	-- end
	-- local ui = Ext.GetBuiltinUI("Public/Game/GUI/playerInfo.swf")
	-- if ui ~= nil then
	-- 	Ext.RegisterUIInvokeListener(ui, "updateStatuses", function(ui, call, ...)
	-- 		local root = ui:GetRoot()
	-- 		local status_array = root.status_array
	-- 		if #status_array > 0 then
	-- 			UI.PrintArray(ui, "status_array")
	-- 			for i=0,#status_array,6 do
	-- 				local playerHandle = Ext.DoubleToHandle(status_array[i])
	-- 				local statusHandle = Ext.DoubleToHandle(status_array[i+1])
	-- 				local iconId = status_array[i+2]
	-- 				local turns = status_array[i+3]
	-- 				local cooldown = status_array[i+4]
	-- 				local tooltip = status_array[i+5] or ""

	-- 				if playerHandle ~= nil and statusHandle ~= nil then
	-- 					local character = Ext.GetCharacter(playerHandle)
	-- 					local status = Ext.GetStatus(character.MyGuid, statusHandle)
	-- 					if status ~= nil then
	-- 						print(string.format("[%s] (%s) CurrentLifeTime(%s) LifeTime(%s) TurnTimer(%s) StartTimer(%s)", i, status.StatusId, status.CurrentLifeTime, status.LifeTime, status.TurnTimer, status.StartTimer))
	-- 						print(string.format(" turns(%s) cooldown(%s)", turns, cooldown))
	-- 					end
	-- 				end
	-- 			end
	-- 		end
	-- 	end)
	-- end
end

if Ext.IsDeveloperMode() then
	for i,v in pairs(allUIFiles) do
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/"..v)
		if ui ~= nil then
			print("Pre Session Loaded:", v, ui:GetTypeId())
		end
	end
	--Ext.RegisterListener("SessionLoaded", SessionLoaded)
end