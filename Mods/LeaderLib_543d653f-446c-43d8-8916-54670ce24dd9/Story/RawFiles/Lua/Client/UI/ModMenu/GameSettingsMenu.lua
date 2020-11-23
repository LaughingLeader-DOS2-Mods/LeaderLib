---@class GameSettingsEntryData:table
---@field Data table
---@field Key string
---@field Value any

GameSettingsMenu = {
	---@type table<int, GameSettingsEntryData>
	Controls = {},
	LastControlID = 600
}
GameSettingsMenu.__index = GameSettingsMenu

---@return GameSettingsEntryData
local function CreateEntryData(parentTable, tableKey, initialValue)
	return {
		Data = parentTable,
		Key = tableKey,
		Value = initialValue
	}
end

---@return integer
local function AddControl(parentTable, tableKey)
	local entry = CreateEntryData(parentTable, tableKey, parentTable[tableKey])
	local currentID = GameSettingsMenu.LastID
	GameSettingsMenu.Controls[currentID] = entry
	GameSettingsMenu.LastID = GameSettingsMenu.LastID + 1
	return currentID
end

local CONTROL_TYPE = {
	CHECKBOX = 0,
	DROPDOWN = 1,
	DROPDOWN_ENTRY = 2,
	SELECT_DROPDOWN_ENTRY = 3,
	SLIDER = 4,
	BUTTON = 5,
	LABEL = 6,
	TITLE = 7,
	DROPDOWN_ENABLED = 8,
	SET_CHECKBOX = 9
}

local function AddTitleToArray(index, array, text)
	array[index] = CONTROL_TYPE.LABEL
	array[index+1] = text
	return index+2
end

local function AddCheckboxToArray(index, array, parentTable, key, displayName, tooltip, value, enableControl, filterBool)
	if enableControl == nil then
		enableControl = true
	end
	array[index] = CONTROL_TYPE.CHECKBOX
	array[index+1] = GameSettingsMenu.LastControlID
	array[index+2] = displayName
	array[index+3] = enableControl
	array[index+4] = value and 1 or 0
	array[index+5] = filterBool or false
	array[index+6] = tooltip or ""
	GameSettingsMenu.Controls[GameSettingsMenu.LastControlID] = CreateEntryData(parentTable, key, value)
	GameSettingsMenu.LastControlID = GameSettingsMenu.LastControlID + 1
	return index+7
end

local function AddSliderToArray(index, array, parentTable, key, displayName, tooltip, value, min, max, interval, hide)
	array[index] = CONTROL_TYPE.SLIDER
	array[index+1] = GameSettingsMenu.LastControlID
	array[index+2] = displayName
	array[index+3] = value
	array[index+4] = min or 0
	array[index+5] = max or 99
	array[index+6] = interval or 1
	array[index+7] = hide or false
	array[index+8] = tooltip or ""
	GameSettingsMenu.Controls[GameSettingsMenu.LastControlID] = property
	GameSettingsMenu.LastControlID = GameSettingsMenu.LastControlID + 1
	return index+9
end

---@param mainMenu MainMenuMC
local function AddCheckbox(mainMenu, parentTable, key, displayName, tooltip, value, enableControl, filterBool)
	mainMenu.addMenuCheckbox(GameSettingsMenu.LastControlID, displayName, enableControl, value and 1 or 0, filterBool or false, tooltip or "")
	GameSettingsMenu.Controls[GameSettingsMenu.LastControlID] = property
	GameSettingsMenu.LastControlID = GameSettingsMenu.LastControlID + 1
end

---@type TranslatedString
local ts = Classes.TranslatedString

local text = {
	MainTitle = ts:CreateFromKey("LeaderLib_UI_GameSettings_MainTitle"),
	StarterTierOverrides = ts:CreateFromKey("LeaderLib_UI_GameSettings_StarterTierOverrides"),
	StarterTierOverrides_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_StarterTierOverrides_Description"),
	Section_AP = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_AP"),
	Group_Player = ts:CreateFromKey("LeaderLib_UI_GameSettings_Group_Player"),
	Group_NPC = ts:CreateFromKey("LeaderLib_UI_GameSettings_Group_NPC"),
	APSettings_Enabled = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Enabled"),
	APSettings_Enabled_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Enabled_Description"),
	APSettings_Max = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Max"),
	APSettings_Max_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Max_Description"),
	APSettings_Start = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Start"),
	APSettings_Start_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Start_Description"),
	APSettings_Recovery = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Recovery"),
	APSettings_Recovery_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Recovery_Description"),
	Section_Backstab = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_Backstab"),
	BackstabSettings_AllowTwoHandedWeapons = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_AllowTwoHandedWeapons"),
	BackstabSettings_AllowTwoHandedWeapons_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_AllowTwoHandedWeapons_Description"),
	BackstabSettings_MeleeSpellBackstabMaxDistance = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_MeleeSpellBackstabMaxDistance"),
	BackstabSettings_MeleeSpellBackstabMaxDistance_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_MeleeSpellBackstabMaxDistance_Description"),
	BackstabSetting_Enabled = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSetting_Enabled"),
	BackstabSettings_Enabled_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_Enabled_Description"),
	BackstabSettings_TalentRequired = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_TalentRequired"),
	BackstabSettings_TalentRequired_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_TalentRequired_Description"),
	BackstabSettings_MeleeOnly = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_MeleeOnly"),
	BackstabSettings_MeleeOnly_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_MeleeOnly_Description"),
	BackstabSettings_SpellsCanBackstab = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_SpellsCanBackstab"),
	BackstabSettings_SpellsCanBackstab_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_SpellsCanBackstab_Description"),
}

---@param ui UIObject
function GameSettingsMenu.AddSettings(ui, addDirectly)
	local settings = GameSettings.Settings
	local main = ui:GetRoot()
	if main ~= nil then
		if addDirectly == true then
			---@type MainMenuMC
			local mainMenu = main.mainMenu_mc
			mainMenu.addMenuLabel(text.MainTitle.Value)

			mainMenu.addMenuCheckbox(AddControl(settings, "StarterTierSkillOverrides"), text.StarterTierOverrides.Value, true, settings.StarterTierSkillOverrides and 1 or 0, false, text.StarterTierOverrides_Description.Value)
			
			mainMenu.addMenuLabel(text.Section_AP.Value)

			local apSliderMax = 30

			mainMenu.addMenuLabel(text.Group_Player.Value)
			mainMenu.addMenuCheckbox(AddControl(settings.APSettings.Player, "Enabled"), text.APSettings_Enabled.Value, true, settings.APSettings.Player.Enabled and 1 or 0, false, text.APSettings_Enabled_Description.Value)
			mainMenu.addMenuSlider(AddControl(settings.APSettings.Player, "Start"), text.APSettings_Start.Value, settings.APSettings.Player.Start.Value, -1, apSliderMax, 1, false, text.APSettings_Start_Description.Value)
			mainMenu.addMenuSlider(AddControl(settings.APSettings.Player, "Recovery"), text.APSettings_Recovery.Value, settings.APSettings.Player.Start, -1, apSliderMax, 1, false, text.APSettings_Recovery_Description.Value)
			mainMenu.addMenuSlider(AddControl(settings.APSettings.Player, "Max"), text.APSettings_Max.Value, settings.APSettings.Player.Max, -1, apSliderMax, 1, false, text.APSettings_Max_Description.Value)

			mainMenu.addMenuLabel(text.Group_NPC.Value)
			mainMenu.addMenuCheckbox(AddControl(settings.APSettings.NPC, "Enabled"), text.APSettings_Enabled.Value, true, settings.APSettings.NPC.Enabled and 1 or 0, false, text.APSettings_Enabled_Description.Value)
			mainMenu.addMenuSlider(AddControl(settings.APSettings.NPC, "Start"), text.APSettings_Start.Value, settings.APSettings.NPC.Start.Value, -1, apSliderMax, 1, false, text.APSettings_Start_Description.Value)
			mainMenu.addMenuSlider(AddControl(settings.APSettings.NPC, "Recovery"), text.APSettings_Recovery.Value, settings.APSettings.NPC.Start, -1, apSliderMax, 1, false, text.APSettings_Recovery_Description.Value)
			mainMenu.addMenuSlider(AddControl(settings.APSettings.NPC, "Max"), text.APSettings_Max.Value, settings.APSettings.NPC.Max, -1, apSliderMax, 1, false, text.APSettings_Max_Description.Value)

			mainMenu.addMenuLabel(text.Section_Backstab.Value)

			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings, "AllowTwoHandedWeapons"), text.BackstabSettings_AllowTwoHandedWeapons.Value, true, settings.BackstabSettings.AllowTwoHandedWeapons and 1 or 0, false, text.BackstabSettings_AllowTwoHandedWeapons_Description.Value)
			mainMenu.addMenuSlider(AddControl(settings.BackstabSettings, "MeleeSpellBackstabMaxDistance"), text.BackstabSettings_MeleeSpellBackstabMaxDistance.Value, settings.BackstabSettings.MeleeSpellBackstabMaxDistance, 0.1, 30.0, 0.1, false, text.BackstabSettings_MeleeSpellBackstabMaxDistance_Description.Value)

			mainMenu.addMenuLabel(text.Group_Player.Value)
			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "Enabled"), text.BackstabSetting_Enabled.Value, true, settings.BackstabSettings.Player.Enabled and 1 or 0, false, text.BackstabSettings_Enabled_Description.Value)
			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "TalentRequired"), text.BackstabSettings_TalentRequired.Value, true, settings.BackstabSettings.Player.TalentRequired and 1 or 0, false, text.BackstabSettings_TalentRequired_Description.Value)
			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "MeleeOnly"), text.BackstabSettings_MeleeOnly.Value, true, settings.BackstabSettings.Player.MeleeOnly and 1 or 0, false, text.BackstabSettings_MeleeOnly_Description.Value)
			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "SpellsCanBackstab"), text.BackstabSettings_SpellsCanBackstab.Value, true, settings.BackstabSettings.Player.SpellsCanBackstab and 1 or 0, false, text.BackstabSettings_SpellsCanBackstab_Description.Value)

			mainMenu.addMenuLabel(text.Group_NPC.Value)
			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "Enabled"), text.BackstabSetting_Enabled.Value, true, settings.BackstabSettings.NPC.Enabled and 1 or 0, false, text.BackstabSettings_Enabled_Description.Value)
			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "TalentRequired"), text.BackstabSettings_TalentRequired.Value, true, settings.BackstabSettings.NPC.TalentRequired and 1 or 0, false, text.BackstabSettings_TalentRequired_Description.Value)
			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "MeleeOnly"), text.BackstabSettings_MeleeOnly.Value, true, settings.BackstabSettings.NPC.MeleeOnly and 1 or 0, false, text.BackstabSettings_MeleeOnly_Description.Value)
			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "SpellsCanBackstab"), text.BackstabSettings_SpellsCanBackstab.Value, true, settings.BackstabSettings.NPC.SpellsCanBackstab and 1 or 0, false, text.BackstabSettings_SpellsCanBackstab_Description.Value)
		else
			local arr = main.update_Array
			local index = #arr
			index = AddTitleToArray(index, arr, GameSettingsText.MainTitle.Value)
			index = AddCheckboxToArray(index, arr, "StarterTierSkillOverrides", GameSettingsText.StarterTierSkillOverrides.Value, GameSettingsText.StarterTierSkillOverrides.Description.Value, settings.StarterTierSkillOverrides)
		end
	end
end

function GameSettingsMenu.OnCheckbox(id, state)
	local controlData = GameSettingsMenu.Controls[id]
	if controlData ~= nil then
		controlData = state ~= 1
	end
end

function GameSettingsMenu.OnComboBox(id, index)
	local controlData = GameSettingsMenu.Controls[id]
	if controlData ~= nil then
		controlData = index
	end
end

function GameSettingsMenu.OnSelector(id, currentSelection)
	local controlData = GameSettingsMenu.Controls[id]
	if controlData ~= nil then
		--controlData = currentSelection
	end
end

function GameSettingsMenu.OnSlider(id, value)
	local controlData = GameSettingsMenu.Controls[id]
	if controlData ~= nil then
		controlData = value
	end
end

function GameSettingsMenu.OnButtonPressed(id)
	--local controlData = GameSettingsMenu.Controls[id]
end