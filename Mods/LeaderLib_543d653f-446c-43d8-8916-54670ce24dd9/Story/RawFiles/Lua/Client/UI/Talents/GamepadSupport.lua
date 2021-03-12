TalentManager.Gamepad = {
	SelectedTalents = {},
	AvailablePoints = 0
}

local msgBox_c_ButtonPressed = {
	Yes = 1,
	No = 2,
	Cancel = 3
}

---@param talentId string
---@return boolean
local function IsSelectedInMenu(talentId)
	if TalentManager.Gamepad.SelectedTalents[talentId] then
		return true
	end
	return false
end

---@param talentId string
local function UnselectTalent(talentId)
	TalentManager.Gamepad.SelectedTalents[talentId] = false
end

function TalentManager.Gamepad.PreUpdate(ui, main)
	if main.mainpanel_mc.stats_mc.currentPanel.name ~= "talents_mc" then
		TalentManager.Gamepad.SelectedTalents = {}
	end
end

function TalentManager.Gamepad.AddButton(lvlBtnTalent_array, talentEnum, isSelected, isSelectable)
	local index = #lvlBtnTalent_array
	lvlBtnTalent_array[index] = false
	lvlBtnTalent_array[index+1] = talentEnum
	lvlBtnTalent_array[index+2] = isSelected
	lvlBtnTalent_array[index+3] = true
	lvlBtnTalent_array[index+4] = talentEnum
	lvlBtnTalent_array[index+5] = isSelectable
end

function TalentManager.Gamepad.UpdateTalent_CC(ui, player, talentId, talentEnum)

end

function TalentManager.Gamepad.UpdateTalent(ui, player, talentId, talentEnum, lvlBtnTalent_array, talentState)
	if TalentManager.HasTalent(player, talentId) then
		UnselectTalent(talentId)
	end
	local isSelected = IsSelectedInMenu(talentId)
	local notSelectedHasPointsAndIsSelectable = (not isSelected and TalentManager.Gamepad.AvailablePoints > 0 and talentState == TalentManager.TalentState.Selectable)
	TalentManager.Gamepad.AddButton(lvlBtnTalent_array, talentEnum, isSelected, notSelectedHasPointsAndIsSelectable)
end

function TalentManager.Gamepad.RegisterListeners()
	Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, "removePointsTalent", function(ui, call, talentEnum, ...)
		local talentId = Data.Talents[talentEnum]
		if TalentManager.IsRegisteredTalent(talentId) and IsSelectedInMenu(talentId) then
			local talents_mc = ui:GetRoot().mainpanel_mc.stats_mc.talents_mc
			talents_mc.setBtnVisible(false, talentId, false)
			talents_mc.setBtnVisible(true, talentId, false)
			TalentManager.Gamepad.SelectedTalents[talentId] = false
		end
	end, "After")

	Ext.RegisterUITypeInvokeListener(Data.UIType.statsPanel_c, "ButtonPressed", function(ui, call, buttonPressedType, deviceId)
		if buttonPressedType == msgBox_c_ButtonPressed.No then
			TalentManager.Gamepad.SelectedTalents = {}
		end
	end, "After")

	Ext.RegisterUINameInvokeListener("setStatPoints", function(ui, call, statsType, pointsAmount)
		if statsType == 3 then
			TalentManager.Gamepad.AvailablePoints = pointsAmount
		end
	end, "After")

	Ext.RegisterUITypeCall(Data.UIType.statsPanel_c, "addPointsTalent", function(ui, call, talentEnum, ...)
		local talentId = Data.Talents[talentEnum]
		if TalentManager.IsRegisteredTalent(talentId) then
			ui:GetRoot().mainpanel_mc.stats_mc.talents_mc.setBtnVisible(false, talentId, false)
			ui:GetRoot().mainpanel_mc.stats_mc.talents_mc.setBtnVisible(false, talentId, true)
			TalentManager.Gamepad.SelectedTalents[talentId] = true
		end
	end, "After")
end

local function EnableTestingTalents()
	TalentManager.EnableTalent("SpillNoBlood", "OpenTalents", function (player) return true end)
	TalentManager.EnableTalent("FolkDancer", "OpenTalents", function (player) return true end)
	TalentManager.EnableTalent("Scientist", "OpenTalents", function (player) return false end)
	TalentManager.EnableTalent("Jitterbug", "OpenTalents", function (player) return false end)
	TalentManager.EnableTalent("GoldenMage", "OpenTalents")
	TalentManager.EnableTalent("GoldenMage", "OpenTalents2", function (player) return false end)
	TalentManager.EnableTalent("GoldenMage", "OpenTalents3", function (player) return true end)
end

Ext.RegisterConsoleCommand("addControllerTalents", function(cmd)
	EnableTestingTalents()
end)