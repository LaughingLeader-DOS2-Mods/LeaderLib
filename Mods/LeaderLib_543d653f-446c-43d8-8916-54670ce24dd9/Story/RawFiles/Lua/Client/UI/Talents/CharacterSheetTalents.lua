---@class FlashCharacterCreationTalentsMC:FlashMovieClip
---@field addTalentElement fun(talentID:integer, talentLabel:string, isUnlocked:boolean, isChoosable:boolean, isRacial:boolean) : void

---@param ui UIObject
---@param event string
local function updateTalents(ui, event)
	---@type CharacterSheetMainTimeline
	local this = ui:GetRoot()

	local handle = ui:GetPlayerHandle() or Client.Character.NetID
	---@type EclCharacter
	local player = Ext.GetCharacter(handle) or Client:GetCharacter()

	for numId,talentId in Data.Talents:Get() do
		local statAttribute = TalentManager.Data.TalentStatAttributes[talentId]
		if TalentManager.CanAddTalent(talentId, player.Stats, statAttribute) then
			local talentState = TalentManager.GetTalentState(player, talentId, statAttribute)
			local name = TalentManager.GetTalentDisplayName(player, talentId, talentState)
			print(call, name, Data.TalentEnum[talentId], talentState)
			this.stats_mc.addTalent(name, Data.TalentEnum[talentId], talentState)
		end
	end

	--[[
		TalentManager.Update(ui, call, player)
		local length = #Listeners.OnTalentArrayUpdating
		if length > 0 then
			for i=1,length do
				local callback = Listeners.OnTalentArrayUpdating[i]
				local talentArrayStartIndex = UI.GetArrayIndexStart(ui, "talent_array", 3)
				local b,err = xpcall(callback, debug.traceback, ui, player, talentArrayStartIndex, Data.TalentEnum)
				if not b then
					Ext.PrintError("Error calling function for 'OnTalentArrayUpdating':\n", err)
				end
			end
		end

		local typeid = ui:GetTypeId()
		UIExtensions.StartTimer("LeaderLib_HideTalents_Sheet", 5, function(timerName, isComplete)
			TalentManager.HideTalents(typeid)
		end)
	]]

	this.stats_mc.talentHolder_mc.list.positionElements()
end

---@param ui UIObject
---@param event string
local function updateTalents_c(ui, event)
	local main = ui:GetRoot()
	local lvlBtnTalent_array = main.lvlBtnTalent_array
	local talent_array = main.talent_array

	if Vars.ControllerEnabled then
		TalentManager.Gamepad.PreUpdate(ui, main)
	end

	local i = #talent_array

	for talentId,talentStat in pairs(TalentManager.Data.DOSTalents) do
		if not TalentIsHidden(talentId) and TalentManager.RegisteredCount[talentId] > 0 then
			i = AddTalentToArray(ui, player, talent_array, talentId, lvlBtnTalent_array, i)
		end
	end

	if Features.RacialTalentsDisplayFix then
		i = #talent_array
		for talentId,talentStat in pairs(TalentManager.Data.RacialTalents) do
			if not TalentIsHidden(talentId) and player.Stats[talentStat] == true then
				i = AddTalentToArray(ui, player, talent_array, talentId, lvlBtnTalent_array, i, true)
			end
		end
	end

	if not TalentIsHidden("RogueLoreDaggerBackStab") and player.Stats.TALENT_RogueLoreDaggerBackStab or 
	(GameSettings.Settings.BackstabSettings.Player.Enabled and GameSettings.Settings.BackstabSettings.Player.TalentRequired) then
		i = #talent_array
		AddTalentToArray(ui, player, talent_array, "RogueLoreDaggerBackStab", lvlBtnTalent_array, i)
	end
end

Ext.RegisterUITypeCall(Data.UIType.characterSheet, "characterSheetUpdateDone", updateTalents)
Ext.RegisterUITypeInvokeListener(Data.UIType.statsPanel_c, "updateArraySystem", updateTalents_c)

--Ext.RegisterUITypeInvokeListener(Data.UIType.characterSheet, "updateArraySystem", DisplayTalents)