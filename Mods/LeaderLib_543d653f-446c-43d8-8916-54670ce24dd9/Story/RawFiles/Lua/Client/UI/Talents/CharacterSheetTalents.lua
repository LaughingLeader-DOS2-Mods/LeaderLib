---@private
TalentManager.Sheet = {}

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
		local hasTalent = player.Stats[TalentManager.Data.TalentStatAttributes[talentId]] == true
		if TalentManager.CanAddTalent(talentId, hasTalent) then
			local talentState = TalentManager.GetTalentState(player, talentId, hasTalent)
			local name = TalentManager.GetTalentDisplayName(talentId, talentState)
			this.stats_mc.addTalent(name, Data.TalentEnum[talentId], talentState)
		end
	end

	this.stats_mc.talentHolder_mc.list.positionElements()

	--[[ -- Old/Needs a second look
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

local function onTalentAdded(ui, call, index)
	---@type CharacterSheetMainTimeline
	local this = ui:GetRoot()
	local talent_mc = this.stats_mc.talentHolder_mc.list.content_array[index]
	if talent_mc then
		local talentState = talent_mc.talentState
		local talentId = Data.Talents[talent_mc.statId]
		local statAttribute = TalentManager.Data.TalentStatAttributes[talentId]
		if talentId and statAttribute then
			local player = Client:GetCharacter()
			local points = this.stats_mc.pointsWarn[3].avPoints
	
			local hasTalent = player.Stats[statAttribute] == true
			local canAdd = false
			local canRemove = false
	
			if not TalentManager.Data.RacialTalents[talentId] then
				--TalentManager.HasRequirements(player, talentId)
				if not hasTalent and points > 0 and talentState == TalentManager.Data.TalentState.Selectable then
					canAdd = true
				elseif hasTalent then
					canRemove = GameHelpers.Client.IsGameMaster(ui, this)
				end
			end
	
			talent_mc.plus_mc.visible = canAdd
			talent_mc.minus_mc.visible = canRemove
	
			--fprint(LOGLEVEL.DEFAULT, "[%s] Talent(%s)[%s] Label(%s) StatAttribute(%s) canAdd(%s) canRemove(%s) Index[%s] State(%s)", call, talentId, talent_mc.statId, talent_mc.label, statAttribute, canAdd, canRemove, index, talentState)
		end
	end
end
Ext.RegisterUITypeCall(Data.UIType.characterSheet, "talentAdded", onTalentAdded)

---@private
function TalentManager.Sheet.HideTalents()
	local list = nil
	local idProperty = nil
	if not Vars.ControllerEnabled then
		---@type CharacterSheetMainTimeline
		local this = GameHelpers.UI.TryGetRoot(Data.UIType.characterSheet)
		if this then
			list = this.stats_mc.talentHolder_mc.list
			idProperty = "statId"
		end
	else
		local this = GameHelpers.UI.TryGetRoot(Data.UIType.statsPanel_c)
		if this then
			list = this.mainpanel_mc.stats_mc.talents_mc.statList
			idProperty = "id"
		end
	end

	local removedTalent = false
	if list and idProperty then
		local count = #list.content_array-1
		for i=0,count do
			local talent_mc = list.content_array[i]
			if talent_mc then
				local talentId = Data.Talents[talent_mc[idProperty]]
				if talentId and TalentManager.TalentIsHidden(talentId) then
					--public function removeElement(index:Number, repositionElements:Boolean = true, toPosition:Boolean = false, yPos:Number = 0.3) : *
					list.removeElement(i, false, false)
					removedTalent = true
				end
			end
		end
	
		if removedTalent then
			list.positionElements()
		end
	end
end