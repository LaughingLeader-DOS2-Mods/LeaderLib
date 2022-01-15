---@class GameSettingsEntryData:table
---@field Data table
---@field Key string
---@field Value any
---@field Last any
---@field Name string
---@field Reversed boolean|nil

GameSettingsMenu = {
	---@type table<integer, GameSettingsEntryData>
	Controls = {},
	LastID = 2000,
	LastScrollPosition = 0
}
GameSettingsMenu.__index = GameSettingsMenu

---@return GameSettingsEntryData
local function CreateEntryData(parentTable, tableKey, initialValue, name)
	return {
		Data = parentTable,
		Key = tableKey,
		Value = initialValue,
		Last = initialValue,
		Name = name or tableKey
	}
end

local function GetNewID(controlData)
	local currentID = GameSettingsMenu.LastID
	GameSettingsMenu.Controls[currentID] = controlData
	GameSettingsMenu.LastID = GameSettingsMenu.LastID + 1
	return currentID
end

---@return integer
local function AddControl(parentTable, tableKey, name, reversed)
	local entry = CreateEntryData(parentTable, tableKey, parentTable[tableKey], name)
	if reversed then
		entry.Reversed = true
	end
	local currentID = GameSettingsMenu.LastID
	GameSettingsMenu.Controls[currentID] = entry
	GameSettingsMenu.LastID = GameSettingsMenu.LastID + 1
	return currentID
end

---@return integer
local function AddButton(name, callback)
	local entry = {
		Name = name,
		Callback = callback
	}
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
	SET_CHECKBOX = 9,
	INFOLABEL = 10,
}

local itemsArray = nil
local itemsArrayIndex = 0

local function AddTitleToArray(text)
	itemsArray[itemsArrayIndex] = CONTROL_TYPE.LABEL
	itemsArray[itemsArrayIndex+1] = text
	itemsArrayIndex = itemsArrayIndex+2
end

local function AddInfoToArray(id, titleText, infoText)
	itemsArray[itemsArrayIndex] = CONTROL_TYPE.INFOLABEL
	itemsArray[itemsArrayIndex+1] = id
	itemsArray[itemsArrayIndex+2] = titleText
	itemsArray[itemsArrayIndex+3] = infoText
	itemsArrayIndex = itemsArrayIndex+4
end

local function AddCheckboxToArray(id, displayName, enabled, state, filterBool, tooltip)
	if filterBool == nil then
		filterBool = false
	end
	itemsArray[itemsArrayIndex] = CONTROL_TYPE.CHECKBOX
	itemsArray[itemsArrayIndex+1] = id
	itemsArray[itemsArrayIndex+2] = displayName
	itemsArray[itemsArrayIndex+3] = enabled
	itemsArray[itemsArrayIndex+4] = state
	itemsArray[itemsArrayIndex+5] = filterBool
	itemsArray[itemsArrayIndex+6] = tooltip or ""
	itemsArrayIndex = itemsArrayIndex+7
end

local function AddSliderToArray(id, label, amount, min, max, snapInterval, hide, tooltip)
	if hide == nil then
		hide = false
	end
	itemsArray[itemsArrayIndex] = CONTROL_TYPE.SLIDER
	itemsArray[itemsArrayIndex+1] = id
	itemsArray[itemsArrayIndex+2] = label
	itemsArray[itemsArrayIndex+3] = amount
	itemsArray[itemsArrayIndex+4] = min or 0
	itemsArray[itemsArrayIndex+5] = max or 99
	itemsArray[itemsArrayIndex+6] = snapInterval or 1
	itemsArray[itemsArrayIndex+7] = hide
	itemsArray[itemsArrayIndex+8] = tooltip or ""
	itemsArrayIndex = itemsArrayIndex+9
end

local function AddButtonToArray(id, label, amount, soundUp, enabled, tooltip)
	if enabled == nil then
		enabled = true
	end
	--id:integer, label:string, soundUp:string, enabled:boolean, tooltip:string
	itemsArray[itemsArrayIndex] = CONTROL_TYPE.BUTTON
	itemsArray[itemsArrayIndex+1] = id
	itemsArray[itemsArrayIndex+2] = label
	itemsArray[itemsArrayIndex+3] = amount
	itemsArray[itemsArrayIndex+4] = soundUp or ""
	itemsArray[itemsArrayIndex+5] = enabled
	itemsArray[itemsArrayIndex+6] = tooltip or ""
	itemsArrayIndex = itemsArrayIndex+7
end

---@type TranslatedString
local ts = Classes.TranslatedString

local text = {
	MainTitle = ts:CreateFromKey("LeaderLib_UI_GameSettings_MainTitle"),
	MainTitle_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_MainTitle_Description"),
	StarterTierOverrides = ts:CreateFromKey("LeaderLib_UI_GameSettings_StarterTierOverrides"),
	StarterTierOverrides_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_StarterTierOverrides_Description"),
	SpellsCanCritWithoutTalent = ts:CreateFromKey("LeaderLib_UI_GameSettings_SpellsCanCritWithoutTalent"),
	SpellsCanCritWithoutTalent_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_SpellsCanCritWithoutTalent_Description"),
	LowerMemorizationRequirements = ts:CreateFromKey("LeaderLib_UI_GameSettings_LowerMemorizationRequirements"),
	LowerMemorizationRequirements_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_LowerMemorizationRequirements_Description"),
	APSettings_Group_Player = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_AP_Player"),
	APSettings_Group_NPC = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_AP_NPC"),
	APSettings_Enabled = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Enabled"),
	APSettings_Enabled_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Enabled_Description"),
	APSettings_Max = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Max"),
	APSettings_Max_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Max_Description"),
	APSettings_Start = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Start"),
	APSettings_Start_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Start_Description"),
	APSettings_Recovery = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Recovery"),
	APSettings_Recovery_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Recovery_Description"),
	Section_Backstab = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_BackstabSettings_General"),
	BackstabSettings_Group_Player = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_BackstabSettings_Player"),
	BackstabSettings_Group_NPC = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_BackstabSettings_NPC"),
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
	Section_Client = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_Client"),
	Client_AlwaysDisplayWeaponScalingText = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_AlwaysDisplayWeaponScalingText"),
	Client_AlwaysDisplayWeaponScalingText_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_AlwaysDisplayWeaponScalingText_Description"),
	Client_HideStatuses = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_HideStatuses"),
	Client_HideStatuses_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_HideStatuses_Description"),
	Client_StatusOptions_AffectHealthbar = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_StatusOptions_AffectHealthbar"),
	Client_StatusOptions_AffectHealthbar_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_StatusOptions_AffectHealthbar_Description"),
	Button_ClearWhitelist = ts:CreateFromKey("LeaderLib_UI_GameSettings_Button_ClearWhitelist"),
	Button_ClearWhitelist_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Button_ClearWhitelist_Description"),
	Button_ClearBlacklist = ts:CreateFromKey("LeaderLib_UI_GameSettings_Button_ClearBlacklist"),
	Button_ClearBlacklist_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Button_ClearBlacklist_Description"),
	Client_DivineTalentsEnabled = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_DivineTalentsEnabled"),
	Client_DivineTalentsEnabled_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_DivineTalentsEnabled_Description"),
	Client_AlwaysExpandTooltips = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_AlwaysExpandTooltips"),
	Client_AlwaysExpandTooltips_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_AlwaysExpandTooltips_Description"),
}

for k,v in pairs(text) do
	v.AutoReplacePlaceholders = true
end

local mainMenuArrayAccess = {
	addMenuLabel = AddTitleToArray,
	addMenuInfoLabel = AddInfoToArray,
	addMenuCheckbox = AddCheckboxToArray,
	addMenuSlider = AddSliderToArray,
	addMenuButton = AddButtonToArray,
}

function GameSettingsMenu.OnControlAdded(ui, controlType, id, listIndex, listProperty, extraParam1)
	if GameSettingsMenu.Controls[id] == nil and controlType ~= "menuLabel" then
		return
	end
	local controlsEnabled = Client.IsHost == true
	local main = ui:GetRoot()
	if main ~= nil then
		---@type MainMenuMC
		local mainMenu = main.mainMenu_mc
		local list = mainMenu[listProperty]
		if list ~= nil then
			local element = list.content_array[listIndex]
			if element ~= nil then
				if controlType == "slider" then
					element.alpha = controlsEnabled and 1.0 or 0.3
					element.slider_mc.m_disabled = not controlsEnabled
				elseif controlType == "menuLabel" then
					if extraParam1 == text.MainTitle.Value then
						element.tooltip = text.MainTitle_Description.Value
						--element.heightOverride = element.height * 2
						--element.label_txt.y = element.height / 2
						--print("Set textFormat for", element.name, main.setTextFormat(listIndex, true, true, false, 36))
					end
					--print(id, controlType, element.height, element.y, list.EL_SPACING, list.TOP_SPACING, main.getElementHeight(listIndex))
				else
					element.enable = controlsEnabled
					element.alpha = controlsEnabled and 1.0 or 0.3				
				end
				--print(id, controlType, element.height, element.y, list.EL_SPACING, list.TOP_SPACING, main.getElementHeight(id))
			end
		end
	end
end

---@param ui UIObject
function GameSettingsMenu.AddSettings(ui, addToArray)
	GameSettingsMenu.Controls = {}
	GameSettingsMenu.LastID = 600
	local settings = GameSettings.Settings
	local main = ui:GetRoot()
	if main ~= nil then
		---@type MainMenuMC
		local mainMenu = main.mainMenu_mc
		if addToArray == true then
			itemsArray = main.update_Array
			if itemsArray == nil then
				return false
			end
			itemsArrayIndex = #itemsArray
			mainMenu = mainMenuArrayAccess
		end

		local controlsEnabled = Client.IsHost == true

		mainMenu.addMenuLabel(text.MainTitle.Value)

		mainMenu.addMenuCheckbox(AddControl(settings, "StarterTierSkillOverrides"), text.StarterTierOverrides.Value, controlsEnabled, settings.StarterTierSkillOverrides and 1 or 0, false, text.StarterTierOverrides_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings, "LowerMemorizationRequirements"), text.LowerMemorizationRequirements.Value, controlsEnabled, settings.LowerMemorizationRequirements and 1 or 0, false, text.LowerMemorizationRequirements_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings, "SpellsCanCritWithoutTalent"), text.SpellsCanCritWithoutTalent.Value, controlsEnabled, settings.SpellsCanCritWithoutTalent and 1 or 0, false, text.SpellsCanCritWithoutTalent_Description.Value)
		
		local apSliderMax = 30
		
		mainMenu.addMenuLabel(text.APSettings_Group_Player.Value)
		--mainMenu.addMenuInfoLabel(GetNewID({Value=text.APSettings_Group_Player}), text.APSettings_Group_Player.Value, "TesT")
		mainMenu.addMenuCheckbox(AddControl(settings.APSettings.Player, "Enabled"), text.APSettings_Enabled.Value, controlsEnabled, settings.APSettings.Player.Enabled and 1 or 0, false, text.APSettings_Enabled_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.Player, "Start"), text.APSettings_Start.Value, settings.APSettings.Player.Start, -1, apSliderMax, 1, false, text.APSettings_Start_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.Player, "Recovery"), text.APSettings_Recovery.Value, settings.APSettings.Player.Recovery, -1, apSliderMax, 1, false, text.APSettings_Recovery_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.Player, "Max"), text.APSettings_Max.Value, settings.APSettings.Player.Max, -1, apSliderMax, 1, false, text.APSettings_Max_Description.Value)

		mainMenu.addMenuLabel(text.APSettings_Group_NPC.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.APSettings.NPC, "Enabled"), text.APSettings_Enabled.Value, controlsEnabled, settings.APSettings.NPC.Enabled and 1 or 0, false, text.APSettings_Enabled_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.NPC, "Start"), text.APSettings_Start.Value, settings.APSettings.NPC.Start, -1, apSliderMax, 1, false, text.APSettings_Start_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.NPC, "Recovery"), text.APSettings_Recovery.Value, settings.APSettings.NPC.Recovery, -1, apSliderMax, 1, false, text.APSettings_Recovery_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.NPC, "Max"), text.APSettings_Max.Value, settings.APSettings.NPC.Max, -1, apSliderMax, 1, false, text.APSettings_Max_Description.Value)

		mainMenu.addMenuLabel(text.Section_Backstab.Value)

		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings, "AllowTwoHandedWeapons"), text.BackstabSettings_AllowTwoHandedWeapons.Value, controlsEnabled, settings.BackstabSettings.AllowTwoHandedWeapons and 1 or 0, false, text.BackstabSettings_AllowTwoHandedWeapons_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.BackstabSettings, "MeleeSpellBackstabMaxDistance"), text.BackstabSettings_MeleeSpellBackstabMaxDistance.Value, settings.BackstabSettings.MeleeSpellBackstabMaxDistance, 0.1, 30.0, 0.1, false, text.BackstabSettings_MeleeSpellBackstabMaxDistance_Description.Value)

		mainMenu.addMenuLabel(text.BackstabSettings_Group_Player.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "Enabled", "BackstabSettings.Player.Enabled"), text.BackstabSetting_Enabled.Value, controlsEnabled, settings.BackstabSettings.Player.Enabled and 1 or 0, false, text.BackstabSettings_Enabled_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "TalentRequired"), text.BackstabSettings_TalentRequired.Value, controlsEnabled, settings.BackstabSettings.Player.TalentRequired and 1 or 0, false, text.BackstabSettings_TalentRequired_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "MeleeOnly"), text.BackstabSettings_MeleeOnly.Value, controlsEnabled, settings.BackstabSettings.Player.MeleeOnly and 1 or 0, false, text.BackstabSettings_MeleeOnly_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "SpellsCanBackstab"), text.BackstabSettings_SpellsCanBackstab.Value, controlsEnabled, settings.BackstabSettings.Player.SpellsCanBackstab and 1 or 0, false, text.BackstabSettings_SpellsCanBackstab_Description.Value)

		mainMenu.addMenuLabel(text.BackstabSettings_Group_NPC.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "Enabled"), text.BackstabSetting_Enabled.Value, controlsEnabled, settings.BackstabSettings.NPC.Enabled and 1 or 0, false, text.BackstabSettings_Enabled_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "TalentRequired"), text.BackstabSettings_TalentRequired.Value, controlsEnabled, settings.BackstabSettings.NPC.TalentRequired and 1 or 0, false, text.BackstabSettings_TalentRequired_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "MeleeOnly"), text.BackstabSettings_MeleeOnly.Value, controlsEnabled, settings.BackstabSettings.NPC.MeleeOnly and 1 or 0, false, text.BackstabSettings_MeleeOnly_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "SpellsCanBackstab"), text.BackstabSettings_SpellsCanBackstab.Value, controlsEnabled, settings.BackstabSettings.NPC.SpellsCanBackstab and 1 or 0, false, text.BackstabSettings_SpellsCanBackstab_Description.Value)

		mainMenu.addMenuLabel(text.Section_Client.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "AlwaysExpandTooltips"), text.Client_AlwaysExpandTooltips.Value, true, settings.Client.AlwaysExpandTooltips and 1 or 0, false, text.Client_AlwaysExpandTooltips_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "AlwaysDisplayWeaponScalingText"), text.Client_AlwaysDisplayWeaponScalingText.Value, true, settings.Client.AlwaysDisplayWeaponScalingText and 1 or 0, false, text.Client_AlwaysDisplayWeaponScalingText_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "DivineTalentsEnabled"), text.Client_DivineTalentsEnabled.Value, true, settings.Client.DivineTalentsEnabled and 1 or 0, false, text.Client_DivineTalentsEnabled_Description.Value)

		mainMenu.addMenuCheckbox(AddControl(settings.Client.StatusOptions, "HideAll"), text.Client_HideStatuses.Value, true, settings.Client.StatusOptions.HideAll and 1 or 0, false, text.Client_HideStatuses_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client.StatusOptions, "AffectHealthbar"), text.Client_StatusOptions_AffectHealthbar.Value, true, settings.Client.StatusOptions.AffectHealthbar and 1 or 0, false, text.Client_StatusOptions_AffectHealthbar_Description.Value)

		mainMenu.addMenuButton(AddButton("ClearBlacklist", function()
			GameSettings.Settings.Client.StatusOptions.Blacklist = {}
			GameSettingsManager.Save()
		end), text.Button_ClearBlacklist.Value, "", true, text.Button_ClearBlacklist_Description.Value)
		mainMenu.addMenuButton(AddButton("ClearWhitelist", function()
			GameSettings.Settings.Client.StatusOptions.Whitelist = {}
			GameSettingsManager.Save()
		end), text.Button_ClearWhitelist.Value, "", true, text.Button_ClearWhitelist_Description.Value)
	end
end

function GameSettingsMenu.OnCheckbox(id, state)
	local controlData = GameSettingsMenu.Controls[id]
	if controlData ~= nil then
		if not controlData.Reversed then
			controlData.Value = state == 1
		else
			controlData.Value = state == 0
		end
		return true
	end
	return false
end

function GameSettingsMenu.OnComboBox(id, index)
	local controlData = GameSettingsMenu.Controls[id]
	if controlData ~= nil then
		controlData.Value = index
		return true
	end
	return false
end

function GameSettingsMenu.OnSelector(id, currentSelection)
	local controlData = GameSettingsMenu.Controls[id]
	if controlData ~= nil then
		--controlData = currentSelection
		return true
	end
	return false
end

function GameSettingsMenu.OnSlider(id, value)
	local controlData = GameSettingsMenu.Controls[id]
	if controlData ~= nil then
		controlData.Value = value
		return true
	end
	return false
end

function GameSettingsMenu.OnButtonPressed(id)
	local controlData = GameSettingsMenu.Controls[id]
	if controlData and controlData.Callback then
		local b,err = xpcall(controlData.Callback, debug.traceback)
		if not b then
			Ext.PrintError(err)
		end
		return true
	end
	return false
end

function GameSettingsMenu.CommitChanges()
	for i,v in pairs(GameSettingsMenu.Controls) do
		if v.Data ~= nil and v.Value ~= v.Last then
			v.Data[v.Key] = v.Value
			--Ext.Print(string.format("[LeaderLib:GameSettingsMenu.CommitChanges] Set %s to %s Data(%s) EqualsLast(%s)", v.Name, v.Value, v.Data, v.Value ~= v.Last))
		end
	end
	Ext.Print("Committed LeaderLib_GameSettings changes.")
	GameSettingsManager.Save()
	GameSettings:Apply()
	if Client.IsHost then
		Ext.PostMessageToServer("LeaderLib_GameSettingsChanged", GameSettings:ToString())
	end
	--Ext.PostMessageToServer("LeaderLib_ModMenu_SaveChanges", Common.JsonStringify(changes))
end

function GameSettingsMenu.UndoChanges()
	if Client.IsHost then
		for i,v in pairs(GameSettingsMenu.Controls) do
			if v.Value ~= v.Last then
				v.Value = v.Last
				Ext.Print(string.format("[LeaderLib:GameSettingsMenu.UndoChanges] Reverted %s back to %s", v.Key, v.Value))
			end
		end
	end
end

function GameSettingsMenu.SetScrollPosition(ui)
	if GameSettingsMenu.LastScrollPosition ~= 0 then
		local main = ui:GetRoot()
		if main ~= nil then
			local scrollbar_mc = main.mainMenu_mc.list.m_scrollbar_mc
			if scrollbar_mc ~= nil then
				scrollbar_mc.m_tweenY = GameSettingsMenu.LastScrollPosition
				scrollbar_mc.m_scrollAnimToY = GameSettingsMenu.LastScrollPosition
				scrollbar_mc.INTScrolledY(GameSettingsMenu.LastScrollPosition)
			end
		end
	end
	--print("[SetScrollPosition] GameSettingsMenu.LastScrollPosition", GameSettingsMenu.LastScrollPosition)
end

function GameSettingsMenu.SaveScroll(ui)
	local main = ui:GetRoot()
	if main ~= nil then
		local scrollbar_mc = main.mainMenu_mc.list.m_scrollbar_mc
		if scrollbar_mc ~= nil then
			GameSettingsMenu.LastScrollPosition = scrollbar_mc.m_scrolledY
		end
	end
	--print("[SaveScroll] GameSettingsMenu.LastScrollPosition", GameSettingsMenu.LastScrollPosition)
end