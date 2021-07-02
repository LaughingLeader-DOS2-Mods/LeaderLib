---@private
TalentManager.CC = {}

---@class FlashCharacterCreationTalentsMC:FlashMovieClip
---@field addTalentElement fun(talentID:integer, talentLabel:string, isUnlocked:boolean, isChoosable:boolean, isRacial:boolean) : void

---@param ui UIObject
---@param method string
local function updateTalents(ui, method)
	local this = ui:GetRoot()
	---@type FlashCharacterCreationTalentsMC
	local talents_mc = this.CCPanel_mc.talents_mc

	local player = Ext.GetCharacter(Ext.DoubleToHandle(this.characterHandle)) or Client:GetCharacter()

	for numId,talentId in Data.Talents:Get() do
		local hasTalent = player.Stats[TalentManager.Data.TalentStatAttributes[talentId]] == true
		if TalentManager.CanAddTalent(talentId, hasTalent) then
			local talentState = TalentManager.GetTalentState(player, talentId, hasTalent)
			local name = TalentManager.GetTalentDisplayName(talentId, talentState)
			local id = Data.TalentEnum[talentId]
			local isRacial = TalentManager.Data.RacialTalents[talentId] ~= nil
			local isChoosable = not isRacial and talentState ~= TalentManager.Data.TalentState.Locked
			if hasTalent then 
				fprint(LOGLEVEL.WARNING, "[%s] Name(%s) State(%s) hasTalent(%s) isChoosable(%s) isRacial(%s)", talentId, name, talentState, hasTalent, isChoosable, isRacial)
			end
			talents_mc.addTalentElement(id, name, hasTalent, isChoosable, isRacial)
		end
	end

	talents_mc.positionLists()
end

---@param ui UIObject
---@param method string
local function updateTalents_c(ui, method)
	if GameSettings.Default == nil then
		-- This function may run before the game is "Running" and the settings load normally.
		GameSettingsManager.Load()
	end

	---@type EsvCharacter
	local player = nil
	local handle = ui:GetPlayerHandle()
	if handle ~= nil then
		player = Ext.GetCharacter(handle)
	elseif  Client.Character ~= nil then
		player = Client:GetCharacter()
	end
	if player ~= nil then
		local root = ui:GetRoot()
		local talent_mc = root.CCPanel_mc.talents_mc
		TalentManager.Update_CC(ui, talent_mc, player)
		local typeid = ui:GetTypeId()
		UIExtensions.StartTimer("LeaderLib_HideTalents_CharacterCreation", 5, function(timerName, isComplete)
			TalentManager.HideTalents(typeid)
		end)
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation, "updateTalents", updateTalents)
Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation_c, "updateTalents", updateTalents_c)

---@private
function TalentManager.CC.HideTalents()
	local list = nil
	local idProperty = nil
	if not Vars.ControllerEnabled then
		local this = GameHelpers.UI.TryGetRoot(Data.UIType.characterCreation)
		if this then
			list = this.CCPanel_mc.talents_mc.talentList
			idProperty = "talentID"
		end
	else
		local this = GameHelpers.UI.TryGetRoot(Data.UIType.characterCreation_c)
		if this then
			list = this.CCPanel_mc.talents_mc.contentList
			idProperty = "contentID"
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