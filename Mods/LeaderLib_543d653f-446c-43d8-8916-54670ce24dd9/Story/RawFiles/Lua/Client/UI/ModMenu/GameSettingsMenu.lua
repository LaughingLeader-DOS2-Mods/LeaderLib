GameSettingsMenu = {
	Controls = {},
	LastControlID = 600
}
GameSettingsMenu.__index = GameSettingsMenu

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

local function AddCheckboxToArray(index, array, property, displayName, tooltip, enabled, enableControl, filterBool)
	array[index] = CONTROL_TYPE.CHECKBOX
	array[index+1] = GameSettingsMenu.LastControlID
	array[index+2] = displayName
	array[index+3] = enableControl or true
	array[index+4] = enabled and 1 or 0
	array[index+5] = filterBool or false
	array[index+6] = tooltip or ""
	GameSettingsMenu.Controls[GameSettingsMenu.LastControlID] = property
	GameSettingsMenu.LastControlID = GameSettingsMenu.LastControlID + 1
	return index+7
end

local function AddSliderToArray(index, array, property, displayName, tooltip, amount, min, max, interval, hide)
	array[index] = CONTROL_TYPE.SLIDER
	array[index+1] = GameSettingsMenu.LastControlID
	array[index+2] = displayName
	array[index+3] = amount
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
local function AddCheckbox(mainMenu, property, displayName, tooltip, enabled, enableControl, filterBool)
	mainMenu.addMenuCheckbox(GameSettingsMenu.LastControlID, displayName, enableControl, enabled and 1 or 0, filterBool or false, tooltip or "")
	GameSettingsMenu.Controls[GameSettingsMenu.LastControlID] = property
	GameSettingsMenu.LastControlID = GameSettingsMenu.LastControlID + 1
end

---@param ui UIObject
function GameSettingsMenu.AddSettings(ui, addDirectly)
	local settings = GameSettings.Settings
	local main = ui:GetRoot()
	if main ~= nil then
		print("Setting up Gameplay menu")
		if addDirectly == true then
			---@type MainMenuMC
			local mainMenu = main.mainMenu_mc
			mainMenu.addMenuLabel("LeaderLib Settings")
			AddCheckbox(mainMenu, "StarterTierSkillOverrides", "Enable Tier Overrides", "Override skill tiers to make them show up in character creation.", settings.StarterTierSkillOverrides)
		else
			local arr = main.update_Array
			local index = #arr
			index = AddTitleToArray(index, arr, "LeaderLib Settings")
			index = AddCheckboxToArray(index, arr, "StarterTierSkillOverrides", "Enable Tier Overrides", "Override skill tiers to make them show up in character creation.", settings.StarterTierSkillOverrides)
		end
	end
end