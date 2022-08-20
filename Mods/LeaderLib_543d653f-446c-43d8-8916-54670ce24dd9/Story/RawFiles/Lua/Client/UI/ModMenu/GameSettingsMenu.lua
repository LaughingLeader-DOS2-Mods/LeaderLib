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

local _ds = {AutoReplacePlaceholders=true}
--Don't replace placeholders in tooltips - Let the generic listener do that
local _dst = {AutoReplacePlaceholders=Vars.ControllerEnabled}

local text = {
	MainTitle = ts:CreateFromKey("LeaderLib_UI_GameSettings_MainTitle", "", _ds),
	MainTitle_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_MainTitle_Description", "", _dst),
	StarterTierOverrides = ts:CreateFromKey("LeaderLib_UI_GameSettings_StarterTierOverrides", "", _ds),
	StarterTierOverrides_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_StarterTierOverrides_Description", "", _dst),
	SpellsCanCritWithoutTalent = ts:CreateFromKey("LeaderLib_UI_GameSettings_SpellsCanCritWithoutTalent", "", _ds),
	SpellsCanCritWithoutTalent_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_SpellsCanCritWithoutTalent_Description", "", _dst),
	LowerMemorizationRequirements = ts:CreateFromKey("LeaderLib_UI_GameSettings_LowerMemorizationRequirements", "", _ds),
	LowerMemorizationRequirements_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_LowerMemorizationRequirements_Description", "", _dst),
	APSettings_Group_Player = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_AP_Player", "", _ds),
	APSettings_Group_NPC = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_AP_NPC", "", _ds),
	APSettings_Enabled = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Enabled", "", _ds),
	APSettings_Enabled_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Enabled_Description", "", _dst),
	APSettings_Max = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Max", "", _ds),
	APSettings_Max_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Max_Description", "", _dst),
	APSettings_Start = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Start", "", _ds),
	APSettings_Start_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Start_Description", "", _dst),
	APSettings_Recovery = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Recovery", "", _ds),
	APSettings_Recovery_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_APSettings_Recovery_Description", "", _dst),
	Section_Backstab = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_BackstabSettings_General", "", _ds),
	BackstabSettings_Group_Player = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_BackstabSettings_Player", "", _ds),
	BackstabSettings_Group_NPC = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_BackstabSettings_NPC", "", _ds),
	BackstabSettings_AllowTwoHandedWeapons = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_AllowTwoHandedWeapons", "", _ds),
	BackstabSettings_AllowTwoHandedWeapons_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_AllowTwoHandedWeapons_Description", "", _dst),
	BackstabSettings_MeleeSpellBackstabMaxDistance = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_MeleeSpellBackstabMaxDistance", "", _ds),
	BackstabSettings_MeleeSpellBackstabMaxDistance_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_MeleeSpellBackstabMaxDistance_Description", "", _dst),
	BackstabSetting_Enabled = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSetting_Enabled", "", _ds),
	BackstabSettings_Enabled_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_Enabled_Description", "", _dst),
	BackstabSettings_TalentRequired = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_TalentRequired", "", _ds),
	BackstabSettings_TalentRequired_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_TalentRequired_Description", "", _dst),
	BackstabSettings_MeleeOnly = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_MeleeOnly", "", _ds),
	BackstabSettings_MeleeOnly_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_MeleeOnly_Description", "", _dst),
	BackstabSettings_SpellsCanBackstab = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_SpellsCanBackstab", "", _ds),
	BackstabSettings_SpellsCanBackstab_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_BackstabSettings_SpellsCanBackstab_Description", "", _dst),
	Section_Client = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_Client", "Client-Side Settings", _ds),
	Section_Client_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_Client_Description", "These settings only affect you. In multiplayer, these settings can be set independently from the host.", _dst),
	Section_StatusHider = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_StatusHider", "Status Hiding", _ds),
	Section_Tooltips_Delay = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_TooltipsDelay", "Tooltip Delays", _ds),
	Section_InventoryFade = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_InventoryFade", "Inventory Item Fading"),
	Section_UI = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_UI", "UI"),
	Section_UI_Tooltips = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_UI_Tooltips", "Tooltips"),
	Section_Gameplay = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_Gameplay", "Gameplay Host Settings"),
	Section_Gameplay_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Section_Gameplay_Description", "These settings affect all players. In multiplayer, only the host can adjust these options.", _dst),
	Button_ClearWhitelist = ts:CreateFromKey("LeaderLib_UI_GameSettings_Button_ClearWhitelist", "", _ds),
	Button_ClearWhitelist_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Button_ClearWhitelist_Description", "", _dst),
	Button_ClearBlacklist = ts:CreateFromKey("LeaderLib_UI_GameSettings_Button_ClearBlacklist", "", _ds),
	Button_ClearBlacklist_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Button_ClearBlacklist_Description", "", _dst),
	Client = {
		AlwaysDisplayWeaponScalingText = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_AlwaysDisplayWeaponScalingText", "", _ds),
		AlwaysDisplayWeaponScalingText_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_AlwaysDisplayWeaponScalingText_Description", "", _dst),
		AlwaysShowBarText = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_AlwaysShowBarText", "Always Show Bar Values", _ds),
		AlwaysShowBarText_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_AlwaysShowBarText_Description", "If enabled, the health and armor bars will always show their values, instead of only on mouse hover.", _dst),
		DivineTalentsEnabled = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_DivineTalentsEnabled", "", _ds),
		HideStatuses = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_HideStatuses", "", _ds),
		HideStatuses_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_HideStatuses_Description", "", _dst),
		StatusOptions_AffectHealthbar = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_StatusOptions_AffectHealthbar", "", _ds),
		StatusOptions_AffectHealthbar_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_StatusOptions_AffectHealthbar_Description", "", _dst),
		DivineTalentsEnabled_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_DivineTalentsEnabled_Description", "", _dst),
		AlwaysExpandTooltips = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_AlwaysExpandTooltips", "", _ds),
		AlwaysExpandTooltips_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_AlwaysExpandTooltips_Description", "", _dst),
		HideChatLog = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_HideChatLog", "Hide Chat Log", _ds),
		HideChatLog_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_HideChatLog_Description", "Aggressively prevent the chat log from being visible or toggleable.", _dst),
		ToggleCombatLog = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_ToggleCombatLog", "Toggle Combat Log", _ds),
		ToggleCombatLog_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_ToggleCombatLog_Description", "Make the combat log visible initially.", _dst),
		CondenseItemTooltips = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_CondenseItemTooltips", "Condense Item Tooltips", _ds),
		CondenseItemTooltips_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_CondenseItemTooltips_Description", "Try to reduce max item tooltip size by combining elements, such as \"On Hit\" actions.", _dst),
		CondenseStatusTooltips = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_CondenseStatusTooltips", "Condense Status Tooltips", _ds),
		CondenseStatusTooltips_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_CondenseStatusTooltips_Description", "Try to reduce max status tooltip size by combining elements, such as immunities.", _dst),
		FixStatusTooltips = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_FixStatusTooltips", "Fix Status Tooltips", _ds),
		FixStatusTooltips_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_FixStatusTooltips_Description", "Removes the status malus icon and extra spacing, caused by a typo in Larian's UI code, and organizes bonuses and maluses together, while also sorting them alphabetically.", _dst),
		HideConsumableEffects = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_HideConsumableEffects", "Show Consumable Effects", _ds),
		HideConsumableEffects_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_HideConsumableEffects_Description", "If <font color='#33FF66'>[Key:LeaderLib_ShowConsumableEffectsEnabled:Show Consumable Effects]</font> is enabled in the global Mod Settings, disable this setting to hide these effects for yourself only.", _dst),
		HideStatusSource = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_HideStatusSource", "Show Status Source", _ds),
		HideStatusSource_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_HideStatusSource_Description", "Show the source of a status, if any, in status tooltips.", _dst),
		KeepTooltipInScreen = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_KeepTooltipInScreen", "Keep Tooltip in Screen", _ds),
		KeepTooltipInScreen_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_KeepTooltipInScreen_Description", "If enabled, tooltips will be forced to stay on the screen, instead of clipping out of bounds.", _dst),
		ShowModInTooltips = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_ShowModInTooltips", "Show Mod Source", _ds),
		ShowModInTooltips_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_ShowModInTooltips_Description", "Show the mod a status, item, or skill originates from in tooltips.", _dst),
		EnableTooltipDelay = {
			GlobalDelay = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_GlobalTooltipDelay", "Delay Override", _ds),
			GlobalDelay_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_GlobalTooltipDelay_Description", "Delay tooltip creation by this amount in milliseconds. This value will override the usual 500ms delay. Set to 0 to re-enable the regular delay created by the tooltip UI.<br>Default: 0<br>Recommended: 500", _dst),
			CharacterSheet = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_EnableTooltipDelay_CharacterSheet", "Delay Character Sheet Tooltips", _ds),
			CharacterSheet_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_EnableTooltipDelay_CharacterSheet_Description", "Enable a 0.5 second delay for abilities, stats, and talents. May affect the examine window as well.", _dst),
			Generic = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_EnableTooltipDelay_Generic", "Delay Generic Tooltips", _ds),
			Generic_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_EnableTooltipDelay_Generic_Description", "Enable a 0.5 second delay for generic tooltips (things like button tooltips).", _dst),
			Item = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_EnableTooltipDelay_Item", "Delay Item Tooltips", _ds),
			Item_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_EnableTooltipDelay_Item_Description", "Enable a 0.5 second delay for item tooltips (includes the hotbar).", _dst),
			Status = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_EnableTooltipDelay_Status", "Delay Status Tooltips", _ds),
			Status_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_EnableTooltipDelay_Status_Description", "Enable a 0.5 second delay for status tooltips (statuses next to portraits, and the examine window).", _dst),
			Skill = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_EnableTooltipDelay_Skill", "Delay Skill Tooltips", _ds),
			Skill_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_EnableTooltipDelay_Skill_Description", "Enable a 0.5 second delay for skill tooltips.", _dst),
		},
		Fade = {
			Enabled = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_FadeInventory_Enabled", "Enabled", _ds),
			Enabled_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_FadeInventory_Description", "If enabled, specific items will be less visible in the inventory, such as memorized skillsbooks being less opaque.", _dst),
			FadeDescriptionInfo = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_Fade_DescriptionInfo", "<br>Default: 30%<br><font color='#FF9900'>Fading is disabled at 100 (fully visible), while 0 makes the item completely invisible.</font>", _ds),
			KnownSkillbooks = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_Fade_KnownSkillbooks", "Known Skillbooks", _ds),
			KnownSkillbooks_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_Fade_KnownSkillbooks_Description", "Fade skillbooks that have already been memorized by this amount.[Key:LeaderLib_UI_GameSettings_Client_Fade_DescriptionInfo]", _dst),
			ReadBooks = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_Fade_ReadBooks", "Books Read", _ds),
			ReadBooks_Description = ts:CreateFromKey("LeaderLib_UI_GameSettings_Client_Fade_ReadBooks_Description", "Fade books (recipes, lore) that have already been read by this amount.<br><font color='#FF33FF'>Note: This setting isn't retroactive, so previous books read in the save may need to be read again, once.</font>[Key:LeaderLib_UI_GameSettings_Client_Fade_DescriptionInfo]", _dst),
		},
	},
}

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
	local controlsEnabled = type(extraParam1) ~= "boolean" or extraParam1 == true or Client.IsHost
	local main = ui:GetRoot()
	if main ~= nil then
		---@type MainMenuMC
		local mainMenu = main.mainMenu_mc
		local list = mainMenu[listProperty]
		if list ~= nil then
			local element = list.content_array[listIndex]
			if element ~= nil then
				if controlType == "slider" then
					local enabled = element.amount_txt.visible
					element.alpha = enabled and 1.0 or 0.3
					element.slider_mc.m_disabled = not enabled
				elseif controlType == "menuLabel" then
					if extraParam1 == text.MainTitle.Value then
						element.tooltip = text.MainTitle_Description.Value
					end
				else
					element.enable = controlsEnabled
					element.alpha = controlsEnabled and 1.0 or 0.3				
				end
			end
		end
	end
end

local function _AddMenuButton(this, id, displayName, soundUp, enableControl, tooltip)
	if not Vars.ControllerEnabled then
		this.addMenuButton(id, displayName, soundUp, enableControl, tooltip)
	else
		this.addMenuButton(id, displayName, enableControl, tooltip)
	end
end

---@param ui UIObject
function GameSettingsMenu.AddSettings(ui, addToArray)
	GameSettingsMenu.Controls = {}
	GameSettingsMenu.LastID = 600
	local settings,b = GameSettingsManager.GetSettings()
	if not b then
		GameSettingsManager.LoadClientSettings()
	end
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

		local client = Client:GetCharacter()
		local controlsEnabled = Client.IsHost == true
		local backstabTalentSupported = Mods.CharacterExpansionLib ~= nil or (client and (client.Stats.TALENT_Backstab or client.Stats.TALENT_RogueLoreDaggerBackStab))

		local _lh = 40

		mainMenu.addMenuLabel(text.MainTitle.Value, "", 60, 30)

		mainMenu.addMenuLabel(text.Section_Client.Value, text.Section_Client_Description.Value, _lh)
		
		mainMenu.addMenuLabel(text.Section_UI.Value, "", _lh)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "AlwaysShowBarText"), text.Client.AlwaysShowBarText.Value, true, settings.Client.AlwaysShowBarText and 1 or 0, false, text.Client.AlwaysShowBarText_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "HideChatLog"), text.Client.HideChatLog.Value, true, settings.Client.HideChatLog and 1 or 0, false, text.Client.HideChatLog_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "ToggleCombatLog"), text.Client.ToggleCombatLog.Value, true, settings.Client.ToggleCombatLog and 1 or 0, false, text.Client.ToggleCombatLog_Description.Value)
		if Mods.CharacterExpansionLib then
			mainMenu.addMenuCheckbox(AddControl(settings.Client, "DivineTalentsEnabled"), text.Client.DivineTalentsEnabled.Value, true, settings.Client.DivineTalentsEnabled and 1 or 0, false, text.Client.DivineTalentsEnabled_Description.Value)
		end
		
		mainMenu.addMenuLabel(text.Section_UI_Tooltips.Value, "", _lh)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "HideConsumableEffects", nil, true), text.Client.HideConsumableEffects.Value, true, settings.Client.HideConsumableEffects and 0 or 1, false, text.Client.HideConsumableEffects_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "HideStatusSource", nil, true), text.Client.HideStatusSource.Value, true, settings.Client.HideStatusSource and 0 or 1, false, text.Client.HideStatusSource_Description.Value)
		if Ext.Utils.Version() >= 57 then
			mainMenu.addMenuCheckbox(AddControl(settings.Client, "ShowModInTooltips"), text.Client.ShowModInTooltips.Value, true, settings.Client.ShowModInTooltips and 1 or 0, false, text.Client.ShowModInTooltips_Description.Value)
		end

		mainMenu.addMenuCheckbox(AddControl(settings.Client, "AlwaysExpandTooltips"), text.Client.AlwaysExpandTooltips.Value, true, settings.Client.AlwaysExpandTooltips and 1 or 0, false, text.Client.AlwaysExpandTooltips_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "AlwaysDisplayWeaponScalingText"), text.Client.AlwaysDisplayWeaponScalingText.Value, true, settings.Client.AlwaysDisplayWeaponScalingText and 1 or 0, false, text.Client.AlwaysDisplayWeaponScalingText_Description.Value)
		
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "CondenseItemTooltips"), text.Client.CondenseItemTooltips.Value, true, settings.Client.CondenseItemTooltips and 1 or 0, false, text.Client.CondenseItemTooltips_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "CondenseStatusTooltips"), text.Client.CondenseStatusTooltips.Value, true, settings.Client.CondenseStatusTooltips and 1 or 0, false, text.Client.CondenseStatusTooltips_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client, "FixStatusTooltips"), text.Client.FixStatusTooltips.Value, true, settings.Client.FixStatusTooltips and 1 or 0, false, text.Client.FixStatusTooltips_Description.Value)

		mainMenu.addMenuCheckbox(AddControl(settings.Client, "KeepTooltipInScreen"), text.Client.KeepTooltipInScreen.Value, true, settings.Client.KeepTooltipInScreen and 1 or 0, false, text.Client.KeepTooltipInScreen_Description.Value)

		mainMenu.addMenuLabel(text.Section_Tooltips_Delay.Value, "", _lh)
		mainMenu.addMenuSlider(AddControl(settings.Client.EnableTooltipDelay, "GlobalDelay"), text.Client.EnableTooltipDelay.GlobalDelay.Value, GameHelpers.Math.Clamp(settings.Client.EnableTooltipDelay.GlobalDelay, 0, 2000), 0, 2000, 5, false, text.Client.EnableTooltipDelay.GlobalDelay_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client.EnableTooltipDelay, "CharacterSheet"), text.Client.EnableTooltipDelay.CharacterSheet.Value, true, settings.Client.EnableTooltipDelay.CharacterSheet and 1 or 0, false, text.Client.EnableTooltipDelay.CharacterSheet_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client.EnableTooltipDelay, "Generic"), text.Client.EnableTooltipDelay.Generic.Value, true, settings.Client.EnableTooltipDelay.Generic and 1 or 0, false, text.Client.EnableTooltipDelay.Generic_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client.EnableTooltipDelay, "Item"), text.Client.EnableTooltipDelay.Item.Value, true, settings.Client.EnableTooltipDelay.Item and 1 or 0, false, text.Client.EnableTooltipDelay.Item_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client.EnableTooltipDelay, "Skill"), text.Client.EnableTooltipDelay.Skill.Value, true, settings.Client.EnableTooltipDelay.Skill and 1 or 0, false, text.Client.EnableTooltipDelay.Skill_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client.EnableTooltipDelay, "Status"), text.Client.EnableTooltipDelay.Status.Value, true, settings.Client.EnableTooltipDelay.Status and 1 or 0, false, text.Client.EnableTooltipDelay.Status_Description.Value)

		local fadeMin = 1
		local fadeMax = 100
		local fadeStep = 1
		local clamp = function(v) return GameHelpers.Math.Clamp(v, fadeMin, fadeMax) end

		mainMenu.addMenuLabel(text.Section_InventoryFade.Value, "", _lh)
		mainMenu.addMenuCheckbox(AddControl(settings.Client.FadeInventoryItems, "Enabled"), text.Client.Fade.Enabled.Value, true, settings.Client.FadeInventoryItems.Enabled and 1 or 0, false, text.Client.Fade.Enabled_Description.Value)

		mainMenu.addMenuSlider(AddControl(settings.Client.FadeInventoryItems, "KnownSkillbooks"), text.Client.Fade.KnownSkillbooks.Value, clamp(settings.Client.FadeInventoryItems.KnownSkillbooks), fadeMin, fadeMax, fadeStep, false, text.Client.Fade.KnownSkillbooks_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.Client.FadeInventoryItems, "ReadBooks"), text.Client.Fade.ReadBooks.Value, clamp(settings.Client.FadeInventoryItems.ReadBooks), fadeMin, fadeMax, fadeStep, false, text.Client.Fade.ReadBooks_Description.Value)

		mainMenu.addMenuLabel(text.Section_StatusHider.Value, "", _lh)
		mainMenu.addMenuCheckbox(AddControl(settings.Client.StatusOptions, "HideAll"), text.Client.HideStatuses.Value, true, settings.Client.StatusOptions.HideAll and 1 or 0, false, text.Client.HideStatuses_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.Client.StatusOptions, "AffectHealthbar"), text.Client.StatusOptions_AffectHealthbar.Value, true, settings.Client.StatusOptions.AffectHealthbar and 1 or 0, false, text.Client.StatusOptions_AffectHealthbar_Description.Value)

		_AddMenuButton(mainMenu, AddButton("ClearBlacklist", function()
			GameSettings.Settings.Client.StatusOptions.Blacklist = {}
			GameSettingsManager.Save()
		end), text.Button_ClearBlacklist.Value, "", true, text.Button_ClearBlacklist_Description.Value)
		_AddMenuButton(mainMenu, AddButton("ClearWhitelist", function()
			GameSettings.Settings.Client.StatusOptions.Whitelist = {}
			GameSettingsManager.Save()
		end), text.Button_ClearWhitelist.Value, "", true, text.Button_ClearWhitelist_Description.Value)

		mainMenu.addMenuLabel(text.Section_Gameplay.Value, text.Section_Gameplay_Description.Value, _lh)

		mainMenu.addMenuCheckbox(AddControl(settings, "StarterTierSkillOverrides"), text.StarterTierOverrides.Value, controlsEnabled, settings.StarterTierSkillOverrides and 1 or 0, false, text.StarterTierOverrides_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings, "LowerMemorizationRequirements"), text.LowerMemorizationRequirements.Value, controlsEnabled, settings.LowerMemorizationRequirements and 1 or 0, false, text.LowerMemorizationRequirements_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings, "SpellsCanCritWithoutTalent"), text.SpellsCanCritWithoutTalent.Value, controlsEnabled, settings.SpellsCanCritWithoutTalent and 1 or 0, false, text.SpellsCanCritWithoutTalent_Description.Value)
		
		local apSliderMax = 30
		
		mainMenu.addMenuLabel(text.APSettings_Group_Player.Value, "", _lh)
		--mainMenu.addMenuInfoLabel(GetNewID({Value=text.APSettings_Group_Player}), text.APSettings_Group_Player.Value, "TesT")
		mainMenu.addMenuCheckbox(AddControl(settings.APSettings.Player, "Enabled"), text.APSettings_Enabled.Value, controlsEnabled, settings.APSettings.Player.Enabled and 1 or 0, false, text.APSettings_Enabled_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.Player, "Start"), text.APSettings_Start.Value, settings.APSettings.Player.Start, -1, apSliderMax, 1, not controlsEnabled, text.APSettings_Start_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.Player, "Recovery"), text.APSettings_Recovery.Value, settings.APSettings.Player.Recovery, -1, apSliderMax, 1, not controlsEnabled, text.APSettings_Recovery_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.Player, "Max"), text.APSettings_Max.Value, settings.APSettings.Player.Max, -1, apSliderMax, 1, not controlsEnabled, text.APSettings_Max_Description.Value)

		mainMenu.addMenuLabel(text.APSettings_Group_NPC.Value, "", _lh)
		mainMenu.addMenuCheckbox(AddControl(settings.APSettings.NPC, "Enabled"), text.APSettings_Enabled.Value, controlsEnabled, settings.APSettings.NPC.Enabled and 1 or 0, false, text.APSettings_Enabled_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.NPC, "Start"), text.APSettings_Start.Value, settings.APSettings.NPC.Start, -1, apSliderMax, 1, not controlsEnabled, text.APSettings_Start_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.NPC, "Recovery"), text.APSettings_Recovery.Value, settings.APSettings.NPC.Recovery, -1, apSliderMax, 1, not controlsEnabled, text.APSettings_Recovery_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.APSettings.NPC, "Max"), text.APSettings_Max.Value, settings.APSettings.NPC.Max, -1, apSliderMax, 1, not controlsEnabled, text.APSettings_Max_Description.Value)

		mainMenu.addMenuLabel(text.Section_Backstab.Value, "", _lh)

		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings, "AllowTwoHandedWeapons"), text.BackstabSettings_AllowTwoHandedWeapons.Value, controlsEnabled, settings.BackstabSettings.AllowTwoHandedWeapons and 1 or 0, false, text.BackstabSettings_AllowTwoHandedWeapons_Description.Value)
		mainMenu.addMenuSlider(AddControl(settings.BackstabSettings, "MeleeSpellBackstabMaxDistance"), text.BackstabSettings_MeleeSpellBackstabMaxDistance.Value, settings.BackstabSettings.MeleeSpellBackstabMaxDistance, 0.1, 30.0, 0.1, not controlsEnabled, text.BackstabSettings_MeleeSpellBackstabMaxDistance_Description.Value)

		mainMenu.addMenuLabel(text.BackstabSettings_Group_Player.Value, "", _lh)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "Enabled", "BackstabSettings.Player.Enabled"), text.BackstabSetting_Enabled.Value, controlsEnabled, settings.BackstabSettings.Player.Enabled and 1 or 0, false, text.BackstabSettings_Enabled_Description.Value)
		if backstabTalentSupported then
			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "TalentRequired"), text.BackstabSettings_TalentRequired.Value, controlsEnabled, settings.BackstabSettings.Player.TalentRequired and 1 or 0, false, text.BackstabSettings_TalentRequired_Description.Value)
		end
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "MeleeOnly"), text.BackstabSettings_MeleeOnly.Value, controlsEnabled, settings.BackstabSettings.Player.MeleeOnly and 1 or 0, false, text.BackstabSettings_MeleeOnly_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.Player, "SpellsCanBackstab"), text.BackstabSettings_SpellsCanBackstab.Value, controlsEnabled, settings.BackstabSettings.Player.SpellsCanBackstab and 1 or 0, false, text.BackstabSettings_SpellsCanBackstab_Description.Value)

		mainMenu.addMenuLabel(text.BackstabSettings_Group_NPC.Value, "", _lh)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "Enabled"), text.BackstabSetting_Enabled.Value, controlsEnabled, settings.BackstabSettings.NPC.Enabled and 1 or 0, false, text.BackstabSettings_Enabled_Description.Value)
		if backstabTalentSupported then
			mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "TalentRequired"), text.BackstabSettings_TalentRequired.Value, controlsEnabled, settings.BackstabSettings.NPC.TalentRequired and 1 or 0, false, text.BackstabSettings_TalentRequired_Description.Value)
		end
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "MeleeOnly"), text.BackstabSettings_MeleeOnly.Value, controlsEnabled, settings.BackstabSettings.NPC.MeleeOnly and 1 or 0, false, text.BackstabSettings_MeleeOnly_Description.Value)
		mainMenu.addMenuCheckbox(AddControl(settings.BackstabSettings.NPC, "SpellsCanBackstab"), text.BackstabSettings_SpellsCanBackstab.Value, controlsEnabled, settings.BackstabSettings.NPC.SpellsCanBackstab and 1 or 0, false, text.BackstabSettings_SpellsCanBackstab_Description.Value)
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
			Ext.Utils.PrintError(err)
		end
		return true
	end
	return false
end

function GameSettingsMenu.CommitChanges()
	for i,v in pairs(GameSettingsMenu.Controls) do
		if v.Data ~= nil and v.Value ~= v.Last then
			v.Data[v.Key] = v.Value
			--Ext.Utils.Print(string.format("[LeaderLib:GameSettingsMenu.CommitChanges] Set %s to %s Data(%s) EqualsLast(%s)", v.Name, v.Value, v.Data, v.Value ~= v.Last))
		end
	end
	GameSettingsManager.Save()
	GameSettings:Apply()
	if Client.IsHost then
		Ext.PostMessageToServer("LeaderLib_GameSettingsChanged", GameSettings:ToString(true))
	end
	Events.GameSettingsChanged:Invoke({Settings = GameSettings.Settings, FromSync=false})
	--Ext.PostMessageToServer("LeaderLib_ModMenu_SaveChanges", Common.JsonStringify(changes))
end

function GameSettingsMenu.UndoChanges()
	if Client.IsHost then
		for i,v in pairs(GameSettingsMenu.Controls) do
			if v.Value ~= v.Last then
				v.Value = v.Last
				Ext.Utils.Print(string.format("[LeaderLib:GameSettingsMenu.UndoChanges] Reverted %s back to %s", v.Key, v.Value))
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