local _EXTVERSION = Ext.Utils.Version()

---@class CCExtensionsUI
---@field Root FlashMainTimeline|table
---@field Instance UIObject
---@field Visible boolean
local CCExt = {
	ID = "LeaderLib_CharacterCreationExtensions",
	Layer = 3,
	SwfPath = "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_CharacterCreationExtensions.swf",
	Initialized = false,
	IsHost = false,
}

local _ISCCLEVEL = false

UIExtensions.CC = CCExt

local CharacterCreation = Classes.UIWrapper:CreateFromType(Data.UIType.characterCreation, {ControllerID = Data.UIType.characterCreation_c, IsControllerSupported = true})

UIExtensions.CharacterCreation = CharacterCreation

function CCExt.GetInstance(skipSetup)
	local instance = Ext.UI.GetByName(CCExt.ID) or Ext.UI.GetByPath(CCExt.SwfPath)
	if not instance and skipSetup ~= true then
		instance = CCExt.SetupInstance()
	end
	return instance
end

setmetatable(CCExt, {
	__index = function(tbl,k)
		if k == "Root" then
			local ui = CCExt.GetInstance(true)
			if ui then
				return ui:GetRoot()
			end
		elseif k == "Instance" then
			local ui = CCExt.GetInstance(true)
			if ui then
				return ui
			end
		elseif k == "Visible" then
			local ui = CCExt.GetInstance(true)
			if ui then
				return Common.TableHasValue(ui.Flags, "OF_Visible")
			end
			return false
		end
	end
})

local function DestroyInstance()
	_ISCCLEVEL = false
	local instance = CCExt.GetInstance(false)
	if instance then
		instance:Hide()
		instance:Destroy()
	end
end

Events.BeforeLuaReset:Subscribe(function()
	DestroyInstance()
end)

Events.LuaReset:Subscribe(function()
	CCExt.SetupInstance()
end)

local function GetCCVisibility()
	if not _ISCCLEVEL or Vars.ControllerEnabled then
		return false
	end
	local cc = Ext.UI.GetByType(Data.UIType.characterCreation)
	if cc then
		local this = cc:GetRoot()
		if this and this.isFinished == true then
			return false
		end
		return Common.TableHasValue(cc.Flags, "OF_Visible")
	end
	return false
end

function CCExt.ToggleVisibility()
	local visible = GetCCVisibility()
	if visible then
		local inst = CCExt.GetInstance()
		if inst then
			inst:Show()
		end
	else
		DestroyInstance()
	end
end

function CCExt.PositionButtons(ccExt)
	local ccRoot = CharacterCreation.Root
	if ccRoot then
		ccExt = ccExt or CCExt.Root
		local x = ccRoot.CCPanel_mc.x + ccRoot.CCPanel_mc.armourBtnHolder_mc.x + ccRoot.CCPanel_mc.armourBtnHolder_mc.helmetBtn_mc.x
		local y = ccRoot.CCPanel_mc.y + ccRoot.CCPanel_mc.origins_mc.height - 224
		ccExt.presetButton_mc.x = x
		ccExt.presetButton_mc.y = y
		ccExt.skipTutorial_mc.x = x
		ccExt.skipTutorial_mc.y = ccRoot.CCPanel_mc.y + ccRoot.CCPanel_mc.armourBtnHolder_mc.y + ccRoot.CCPanel_mc.armourBtnHolder_mc.armourBtn_mc.y + ccRoot.CCPanel_mc.armourBtnHolder_mc.armourBtn_mc.height + ccExt.skipTutorial_mc.height + 12

		ccExt.presetButton_mc.visible = true
		ccExt.skipTutorial_mc.visible = true
	end
end

local SkipTutorialRegions = Classes.Enum:Create({
	[0] = "None",
	[1] = "FJ_FortJoy_Main",
	[2] = "LV_HoE_Main",
	[3] = "RC_Main",
	[4] = "CoS_Main",
	[5] = "ARX_Main",
	[6] = "ARX_Endgame",
})

local SkipTutorialRegionTooltips = {
	Tutorial = Classes.TranslatedString:CreateFromKey("LeaderLib_UI_SkipTutorial_TutorialDisplayName", "[Key:TUT_Tutorial_A:The Hold] (Tutorial)", {AutoReplacePlaceholders = true}),
	Level = Classes.TranslatedString:CreateFromKey("LeaderLib_UI_SkipTutorial_Level", "Go to [1] ([2])"),
}

local DeveloperOnlyRegions = {
	LV_HoE_Main = true,
	CoS_Main = true,
	ARX_Main = true,
	ARX_Endgame = true,
}

function CCExt.SetupSkipTutorialButton(this)
	this.skipTutorial_mc.isEnabled = CCExt.IsHost
	local settings = GameSettingsManager.GetSettings()
	local activeText = settings.SkipTutorial.Enabled and LocalizedText.UI.Active.Value or LocalizedText.UI.Inactive.Value
	local tooltip = string.format("%s<br>%s", GameHelpers.GetStringKeyText("LeaderLib_UI_SkipTutorial_Description", "<font color='#77DDFF' size'22'>Skip Tutorial</font><br>Skip the tutorial and go straight to a specific level."), activeText)
	this.skipTutorial_mc.setText(tooltip)
	this.skipTutorial_mc.title_mc.setText(GameHelpers.GetStringKeyText("LeaderLib_UI_SkipTutorial_DisplayName", "Select Starting Level"));
	
	for i,level in pairs(SkipTutorialRegions) do
		if Vars.DebugMode or DeveloperOnlyRegions[level] ~= true then
			if level ~= "None" then
				local name = GameHelpers.GetStringKeyText(level)
				local tooltip = SkipTutorialRegionTooltips.Level:ReplacePlaceholders(name, i)
				if not Vars.DebugMode then
					this.skipTutorial_mc.addEntry(name, i, tooltip)
				else
					this.skipTutorial_mc.addEntry(name, i, string.format("%s [%s]", tooltip, level))
				end
			else
				local tutorial = GameHelpers.GetStringKeyText("LeaderLib_Tutorial", "Tutorial")
				local name = GameHelpers.GetStringKeyText("TUT_Tutorial_A")
				local tooltip = SkipTutorialRegionTooltips.Level:ReplacePlaceholders(name, tutorial)
				name = string.format("%s (%s)", name, tutorial)
				if not Vars.DebugMode then
					this.skipTutorial_mc.addEntry(name, i, tooltip)
				else
					this.skipTutorial_mc.addEntry(name, i, string.format("%s [TUT_Tutorial_A]", tooltip))
				end
			end
		end
	end
	if not settings.SkipTutorial.Enabled then
		this.skipTutorial_mc.selectItemByID(1, true)
		this.skipTutorial_mc.graphics_mc.activated = false
	else
		local dest = settings.SkipTutorial.Destination
		local index = SkipTutorialRegions[dest]
		if not index or (DeveloperOnlyRegions[dest] and not Vars.DebugMode) then
			index = SkipTutorialRegions.FJ_FortJoy_Main
		end
		this.skipTutorial_mc.selectItemByID(index, true)
		this.skipTutorial_mc.graphics_mc.activated = true
	end
end

function CCExt.SetupInstance(force)
	if Vars.ControllerEnabled then
		force = false
	end
	local visible = force or GetCCVisibility()
	if visible then
		local instance = Ext.UI.GetByName(CCExt.ID) or Ext.UI.GetByPath(CCExt.SwfPath)
		if not instance then
			CCExt.Initialized = false
			instance = Ext.UI.Create(CCExt.ID, CCExt.SwfPath, CCExt.Layer)
		end
		if instance then
			instance:Show()
			local this = instance:GetRoot()
			if not CCExt.Initialized then
				local title = string.format("%s %s", LocalizedText.UI.Select.Value, LocalizedText.UI.Preset.Value)
				local tooltip = GameHelpers.GetStringKeyText("LeaderLib_UI_PresetDropdown_Tooltip", "<font color='#BB77FF' size='22'>Preset Selection</font><br>Toggle the the Preset Selection dropdown.")
				this.presetButton_mc.setText(tooltip)
				this.presetButton_mc.title_mc.setText(title)
				UIExtensions.CC.PresetExt.CreatePresetDropdown()

				CCExt.SetupSkipTutorialButton(this)
				CCExt.PositionButtons(this)
				CCExt.Initialized = true
			end
			return instance
		else
			Ext.Utils.PrintError("[LeaderLib] Failed to create UI:", UIExtensions.SwfPath)
		end
	end
end

local function UpdateVisibility(forceVisible)
	local ccVisible = forceVisible or GetCCVisibility()
	local inst = CCExt.GetInstance(true)
	if inst then
		if not ccVisible then
			inst:Hide()
		else
			inst:Show()
			CCExt.PositionButtons(inst:GetRoot())
		end
	end
end

local function OnCharacterCreation(isCC, region)
	if isCC == false then
		DestroyInstance()
	elseif GameHelpers.IsLevelType(LEVELTYPE.CHARACTER_CREATION, region) then
		CCExt.SetupInstance(true)
		UpdateVisibility()
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.tutorialBox, "setIsCharacterCreation", function (ui, method, isCC)
	OnCharacterCreation(isCC)
end)

Ext.RegisterUITypeInvokeListener(Data.UIType.tutorialBox_c, "setIsCharacterCreation", function (ui, method, isCC)
	OnCharacterCreation(isCC)
end)

UI.RegisterUICreatedListener({Data.UIType.characterCreation, Data.UIType.characterCreation_c}, function (e)
	if GameHelpers.IsLevelType(LEVELTYPE.CHARACTER_CREATION) then
		UpdateVisibility(true)
	end
end)

Ext.Events.GameStateChanged:Subscribe(function (e)
	if e.ToState == "Menu" then
		DestroyInstance()
	end
end)

Ext.RegisterUINameCall("LeaderLib_CCExt_RepositionButtons", function (ui, call)
	CCExt.PositionButtons(ui:GetRoot())
end)

Ext.RegisterUINameCall("LeaderLib_SkipTutorialButton_LevelSelected", function (ui, call, id, selectedIndex)
	local level = SkipTutorialRegions[id]
	if level then
		if level == "None" then
			GameSettings.Settings.SkipTutorial.Enabled = false
		else
			GameSettings.Settings.SkipTutorial.Enabled = true
			GameSettings.Settings.SkipTutorial.Destination = level
		end
		Ext.Net.PostMessageToServer("LeaderLib_SetSkipTutorial", level)
		GameSettingsManager.Save()

		local this = ui:GetRoot()
		if this then
			this.skipTutorial_mc.graphics_mc.activated = GameSettings.Settings.SkipTutorial.Enabled
			local activeText = GameSettings.Settings.SkipTutorial.Enabled and LocalizedText.UI.Active.Value or LocalizedText.UI.Inactive.Value
			local tooltip = string.format("%s<br>%s", GameHelpers.GetStringKeyText("LeaderLib_UI_SkipTutorial_Description", "<font color='#77DDFF' size'22'>Skip Tutorial</font><br>Skip the tutorial and go straight to a specific level."), activeText)
			this.skipTutorial_mc.setText(tooltip)
		end
	end
end)

Ext.RegisterNetListener("LeaderLib_EnableSkipTutorialUI", function (cmd, payload)
	CCExt.IsHost = true
	local this = CCExt.Root
	if this then
		this.skipTutorial_mc.isEnabled = CCExt.IsHost
		this.skipTutorial_mc.visible = true
	end
end)

Events.ClientDataSynced:Subscribe(function (e)
	CCExt.IsHost = Client.IsHost
	if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
		local this = CCExt.Root
		if this then
			this.skipTutorial_mc.isEnabled = CCExt.IsHost
		end
	end
end)

Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation, "updateTags", function (ui, call)
	if UIExtensions.CC.Visible then
		local ccExt = UIExtensions.CC.Root
		CCExt.PositionButtons(ccExt)
		if ccExt.presetButton_mc.visible then
			UIExtensions.CC.PresetExt.SelectCurrentPreset(ccExt)
		end
	end
end, "After")

Events.RegionChanged:Subscribe(function (e)
	if e.LevelType == LEVELTYPE.CHARACTER_CREATION then
		_ISCCLEVEL = true
		if e.State == REGIONSTATE.ENDED then
			DestroyInstance()
		end
	elseif CCExt.Visible then
		DestroyInstance()
	end
end)

--CharacterCreation.Register:Invoke("selectOption", function (self, ui, event, selectorId, optId)
CharacterCreation.Register:Invoke("setPanel", function (self, e, ui, event, panelId)
	Timer.Cancel("LeaderLib_CC_CheckColors")
	if panelId == 1 then
		Timer.StartOneshot("LeaderLib_CC_CheckColors", 10, function (e)
			--Workaround for the color names not updating if you change the skin color before the appearance panel is selected
			local this = CharacterCreation.Root
			if this then
				local player = Client:GetCharacter()
				if player and player.PlayerCustomData then
					local skinColor = player.PlayerCustomData.SkinColor
					if skinColor and skinColor > 0 then
						GameHelpers.CC.SetColor("Skin", skinColor, "Value", true)
					end
					local hairColor = player.PlayerCustomData.HairColor
					if hairColor and hairColor > 0 then
						GameHelpers.CC.SetColor("Hair", hairColor, "Value", true)
					end
				end
			end
		end)
	end
end, "After", "All")