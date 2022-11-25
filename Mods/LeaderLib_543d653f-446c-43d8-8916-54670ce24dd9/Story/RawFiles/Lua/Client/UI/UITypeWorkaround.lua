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
		fprint(LOGLEVEL.TRACE, " ["..index.."] = ["..tostring(val).."]")
	end
end

function UI.PrintArray(ui, arrayName)
	fprint(LOGLEVEL.TRACE, "==============")
	fprint(LOGLEVEL.TRACE, arrayName)
	fprint(LOGLEVEL.TRACE, "==============")
	local i = 0
	while i < 300 do
		PrintArrayValue(ui, i, arrayName)
		i = i + 1
	end
	fprint(LOGLEVEL.TRACE, "==============")
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
function UI.TryFindUIByType(ui, tryFindId)
	local id = tryFindId
	local t = type(ui)
	if t == "number" then
		id = ui
	else
		id = ui.Type or tryFindId
	end
	for i,v in ipairs(allUIFiles) do
		local path = "Public/Game/GUI/"..v
		local builtInUI = Ext.UI.GetByPath(path)
		if builtInUI ~= nil then
			local builtInID = builtInUI.Type
			if builtInID == id or builtInUI == ui then
				return builtInID,v,path
			end
		end
	end
	
	for k,v in pairs(customUIs) do
		local customUI = Ext.UI.GetByName(k)
		if customUI then
			local customID = customUI.Type
			if customID == id or customUI == ui then
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
					return v2,k
				end
			end
		else
			if v == id then
				return id,k
			end
		end
	end
end