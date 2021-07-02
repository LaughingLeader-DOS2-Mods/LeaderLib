---@class FlashCharacterCreationTalentsMC:FlashMovieClip
---@field addTalentElement fun(talentID:integer, talentLabel:string, isUnlocked:boolean, isChoosable:boolean, isRacial:boolean) : void

---@param ui UIObject
---@param method string
local function updateTalents(ui, method)
	local this = ui:GetRoot()
	---@type FlashCharacterCreationTalentsMC
	local talents_mc = this.CCPanel_mc.talents_mc

	local player = Ext.GetCharacter(Ext.DoubleToHandle(this.characterHandle)) or Client:GetCharacter()

	local talents = {}

	for numId,talentId in Data.Talents:Get() do
		local statAttribute = TalentManager.Data.TalentStatAttributes[talentId]
		if talents[talentId] == nil and TalentManager.CanAddTalent(talentId, player.Stats, statAttribute) then
			local talentState = TalentManager.GetTalentState(player, talentId, statAttribute)
			local name = TalentManager.GetTalentDisplayName(player, talentId, talentState)
			local id = Data.TalentEnum[talentId]
			local isRacial = TalentManager.Data.RacialTalents[talentId] ~= nil
			local isLocked = talentState == TalentManager.Data.TalentState.Locked
			local isChoosable = talentState == TalentManager.Data.TalentState.Selectable and not isLocked
			talents_mc.addTalentElement(id, name, isLocked, isChoosable, isRacial)
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