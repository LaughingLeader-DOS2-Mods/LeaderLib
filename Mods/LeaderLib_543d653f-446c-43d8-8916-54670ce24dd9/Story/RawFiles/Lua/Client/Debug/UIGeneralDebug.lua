Ext.AddPathOverride("Public/Game/GUI/characterSheet.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/characterSheet.swf")
--Ext.AddPathOverride("Public/Game/GUI/contextMenu.swf", "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/contextMenu.swf")

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
-- Game Master
"GM/campaignManager.swf",
"GM/containerInventoryGM.swf",
"GM/encounterPanel.swf",
"GM/gmInventory.swf",
"GM/GMItemSheet.swf",
"GM/GMJournal.swf",
"GM/GMMetadataBox.swf",
"GM/GMMinimap.swf",
"GM/GMMoodPanel.swf",
"GM/GMPanelHUD.swf",
"GM/GMRewardPanel.swf",
"GM/GMSkills.swf",
"GM/itemGenerator.swf",
"GM/monstersSelection.swf",
"GM/overviewMap.swf",
"GM/pause.swf",
"GM/peace.swf",
"GM/possessionBar.swf",
"GM/reputationPanel.swf",
"GM/roll.swf",
"GM/statusPanel.swf",
"GM/stickiesPanel.swf",
"GM/sticky.swf",
"GM/surfacePainter.swf",
"GM/uiElementsGM.swf",
"GM/vignette.swf",
}

local customUIs = {
	--"Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_UIExtensions.swf",
	["LeaderLibUIExtensions"] = "LeaderLib_UIExtensions"
}

---@param ui UIObject
local function TryFindUI(ui, tryFindId)
	local id = tryFindId
	local t = type(ui)
	if t == "number" then
		id = ui
	else
		id = ui:GetTypeId() or tryFindId
	end
	-- if id == Data.UIType.characterSheet then
	-- 	ui:Invoke("setGameMasterMode", true, true, true)
	-- end
	-- if id == nil then
	-- 	return nil
	-- end
	for i,v in ipairs(allUIFiles) do
		local builtInUI = Ext.GetBuiltinUI("Public/Game/GUI/"..v)
		if builtInUI ~= nil then
			local builtInID = builtInUI:GetTypeId()
			--print(id, v, builtInID, builtInUI:GetRoot().stage)
			if builtInID == id or builtInUI == ui then
				fprint(LOGLEVEL.WARNING, "[TryFindUI]%s = %s,", v:gsub("GM/", ""):gsub(".swf", ""), builtInID)
				return builtInID,v
			end
		end
	end
	for k,v in pairs(customUIs) do
		local customUI = Ext.GetUI(k)
		if customUI then
			local customID = customUI:GetTypeId()
			if customID == id or customID == ui then
				fprint(LOGLEVEL.WARNING, "[TryFindUI]%s = %s,", v, customID)
				return customID,v
			end
		elseif t ~= "number" then
			local main = ui:GetRoot()
			if main and main.anchorId == v then
				return id,k
			end
		end
	end
	for k,v in pairs(Data.UIType) do
		if type(v) == "table" then
			for _,v2 in pairs(v) do
				if v2 == id then
					fprint(LOGLEVEL.WARNING, "[TryFindUI]%s = %s,", k, v2)
					return v2,k
				end
			end
		else
			if v == id then
				fprint(LOGLEVEL.WARNING, "[TryFindUI]%s = %s,", k, id)
				return id,k
			end
		end
	end
	print("Failed to find UI file for UI", ui, id)
end

Ext.RegisterListener("UIObjectCreated", function(ui)
	TryFindUI(ui)
end)

local function PrintAllUITypeID()
	for i,v in ipairs(allUIFiles) do
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/"..v)
		if ui ~= nil then
			--print(v, ui:GetTypeId())
			fprint(LOGLEVEL.TRACE, "%s = %s,", string.gsub(v, "GM/", ""):gsub(".swf", ""), ui:GetTypeId())
		end
	end
end

local foundUITypeIds = {}

Ext.RegisterConsoleCommand("printuitypeids", function(cmd, ...)
	PrintAllUITypeID()
end)

Ext.RegisterConsoleCommand("tryfindui", function(cmd, uiType)
	uiType = tonumber(uiType)
	local ui = Ext.GetUIByType(uiType)
	TryFindUI(ui, uiType)
end)

local worldTooltipMethods = {
	"updateTooltips",
	"setObjPos",
	"setTooltip",
	"setWindow",
	"setControllerMode",
	"removeNotUpdatedTooltips",
	"showTooltipLong",
	"removeTooltipLong",
	"removeTooltip",
	"clearAll",
	"removedTooltipMc",
	"getTooltip",
	"checkBoundaries",
	"checkTooltipBoundaries",
	"setToTop",
	"noOverlapAll",
	"cheaperCollisionCheck",
}

local worldTooltipCalls = {
	"tooltipClicked",
	"tooltipOver",
	"tooltipOut",
	"hideTooltip",
	"showItemTooltip",
	"showTooltip",
	"showStatusTooltip",
	"startDragging",
}

Ext.RegisterConsoleCommand("tooltiptest", function(cmd, delay)
	local removeOld = false
	delay = tonumber(delay or "250")
	UIExtensions.StartTimer("worldTooltipTest", delay, function(timerName, isComplete)
		print(timerName, isComplete)
		local worldTooltip = Ext.GetUIByType(Data.UIType.worldTooltip)
		if worldTooltip then
			removeOld = not removeOld
			worldTooltip:Invoke("updateTooltips", removeOld)
		end
	end, 50)
end)

Ext.RegisterListener("SessionLoaded", function()
	--Ext.UIEnableCustomDrawCallDebugging(true)
	--Ext.GetUIByType(Data.UIType.characterSheet):SetCustomIcon("LL_characterSheetIcon_99", "Tag_Jester_inv", 28, 28)
	--local this = Ext.GetUIByType(119):GetRoot().stats_mc; this.customStatIconOffsetX = -2; this.customStatIconOffsetX = -2;

	--Ext.GetUIByType(Data.UIType.characterSheet):SetCustomIcon("LL_characterSheetIcon_99", "Tag_Jester_inv", 28, 28)
	--Ext.GetUIByType(44):SetCustomIcon("LL_skillSchool_99", "Tag_Jester_inv", 28, 28)
	--Ext.GetUIByType(44):SetCustomIcon("LL_skillSchool_99", "Ability_DualWielding", 64, 64)
	--print(Ext.GetUIByType(44):GetRoot().formatTooltip.tooltip_mc.footer_mc.labels_mc.skillSchoolIcon_mc)
	-- local lastSkillIconName = ""
	-- Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", function(ui)
	-- 	local skillIcon = ui:GetRoot().formatTooltip.tooltip_mc.footer_mc.labels_mc.skillSchoolIcon_mc
	-- 	lastSkillIconName = skillIcon.name
	-- 	skillIcon.name = "iggy_LL_skillSchool_99"
	-- end)
	-- Ext.RegisterUINameInvokeListener("hideTooltip", function(ui)
	-- 	local skillIcon = ui:GetRoot().formatTooltip.tooltip_mc.footer_mc.labels_mc.skillSchoolIcon_mc
	-- 	skillIcon.name = lastSkillIconName
	-- end)
	-- Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", function(ui, event)
	-- 	local this = ui:GetRoot()
	-- 	-- Icon test by replacing Fire Resistance's frame to trigger a custom icon
	-- 	if #this.secStat_array > 0 and this.secStat_array[89] then
	-- 		this.secStat_array[89] = 99
	-- 	end
	-- end)
	--PrintAllUITypeID()
	local tryFindUI = function(ui, ...)
		if not foundUITypeIds[ui:GetTypeId()] then
			local id,file = TryFindUI(ui)
			if file ~= nil then
				foundUITypeIds[id] = file
			end
		end
	end

	local worldTooltip = Ext.GetUIByType(Data.UIType.worldTooltip)
	if worldTooltip then
		worldTooltip:Invoke("setControllerMode", true)
	end
	Ext.RegisterUITypeInvokeListener(Data.UIType.worldTooltip, "setControllerMode", function(ui, method, isEnabled)
		print(ui:GetTypeId(), method, isEnabled)
		if not isEnabled then
			ui:GetRoot().isControllerMode = true
		end
	end)
	for _,v in pairs(worldTooltipMethods) do
		Ext.RegisterUITypeInvokeListener(Data.UIType.worldTooltip, v, function(ui, method, ...)
			print("worldTooltip", ui:GetTypeId(), method, Common.Dump({...}))
		end)
	end
	for _,v in pairs(worldTooltipCalls) do
		Ext.RegisterUITypeCall(Data.UIType.worldTooltip, v, function(ui, method, ...)
			print("worldTooltip", ui:GetTypeId(), method, Common.Dump({...}))
		end)
	end
	--print(Ext.GetBuiltinUI("Public/Game/GUI/mainMenu.swf"))
	
	Ext.RegisterUINameCall("PlaySound", tryFindUI)
	Ext.RegisterUINameCall("UIAssert", tryFindUI)
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
	if Vars.ControllerEnabled then
		local areaInteractCalls = {
			"itemOver",
			"itemOut",
			"itemSelected",
			"showContext",
		}
		local printCall = function(ui, ...)
			Ext.Print(Ext.MonotonicTime(), ui:GetTypeId(), Ext.JsonStringify({...}))
		end
		for _,v in pairs(areaInteractCalls) do
			Ext.RegisterUITypeCall(Data.UIType.areaInteract_c, v, printCall)
			--Ext.RegisterUINameCall(v, printCall)
		end
	end
end)

--print("Pre Session Loaded UI:")
--PrintAllUITypeID()
local function iggyTrace()
	local ui = not Vars.ControllerEnabled and Ext.GetUIByType(Data.UIType.hotBar) or Ext.GetBuiltinUI(Data.UIType.bottomBar_c)
	if ui then
		local this = ui:GetRoot()
		if this then
			-- local slotHolder = this.hotbar_mc.slotholder_mc
			-- for i=0,#slotHolder.slot_array do
			-- 	local slot = slotHolder.slot_array[i]
			-- 	if slot then
			-- 		fprint(LOGLEVEL.TRACE, "SLOT[%s] name(%s) numChildren(%s) disable_mc.name(%s)", i, slot.name, slot.numChildren, slot.disable_mc.name)
			-- 	end
			-- end
			local actionSkillHolder_mc = this.actionSkillHolder_mc
			local list = actionSkillHolder_mc.actionList.content_array
			fprint(LOGLEVEL.TRACE, "actionSkillHolder_mc.iggy_actions.numChildren(%s)", actionSkillHolder_mc.iggy_actions.numChildren)
			for i=0,#list do
				local action_mc = list[i]
				if action_mc then
					fprint(LOGLEVEL.TRACE, "action_mc[%s] name(%s) numChildren(%s) actionID(%s)", i, action_mc.name, action_mc.numChildren, action_mc.actionID)
					fprint(LOGLEVEL.TRACE, "  hit_mc.name(%s) scaleX(%s) scaleY(%s) width(%s) height(%s)", action_mc.hit_mc.name, action_mc.hit_mc.scaleX, action_mc.hit_mc.scaleY, action_mc.hit_mc.width, action_mc.hit_mc.height)
				end
			end
		end
	end
end

--Ext.RegisterListener("SessionLoaded", iggyTrace)

Ext.RegisterUITypeInvokeListener(Data.UIType.enemyHealthBar, "updateStatuses", function(ui)
	local this = ui:GetRoot()
	if not this.status_array[0] then
		return
	end
	local character = Ext.GetCharacter(Ext.DoubleToHandle(this.status_array[0]))
	if character then
		fprint(LOGLEVEL.DEFAULT, "DisplayName(%s) DisplayNameOverride(%s) StoryDisplayName(%s) OriginalDisplayName(%s) PlayerCustomData.Name(%s) RootTemplate.DisplayName(%s) RootTemplate.Id(%s) UUID(%s)", character.DisplayName, character.DisplayNameOverride, character.StoryDisplayName, character.OriginalDisplayName, character.PlayerCustomData and character.PlayerCustomData.Name or "nil", character.RootTemplate and character.RootTemplate.DisplayName or "nil", character.RootTemplate and character.RootTemplate.Id or "nil", character.MyGuid)
	end
end)