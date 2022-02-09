local _EXTVERSION = Ext.Version()

---@class CCExtensionsUI
---@field Root FlashMainTimeline
---@field Instance UIObject
---@field Visible boolean
local CCExt = {
	ID = "LeaderLib_CharacterCreationExtensions",
	Layer = 3,
	SwfPath = "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_CharacterCreationExtensions.swf",
	Initialized = false,
	IsHost = false,
}

UIExtensions.CC = CCExt

local CharacterCreation = Classes.UIWrapper:CreateFromType(Data.UIType.characterCreation, {ControllerID = Data.UIType.characterCreation_c, IsControllerSupported = true})

function CCExt.GetInstance(skipSetup)
	local instance = Ext.GetUI(CCExt.ID)
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
	local instance = CCExt.GetInstance(false)
	if instance then
		instance:Hide()
		instance:Destroy()
	end
end

RegisterListener("BeforeLuaReset", function()
	DestroyInstance()
end)

RegisterListener("LuaReset", function()
	CCExt.SetupInstance()
end)

local function GetCCVisibility()
	local cc = Ext.GetUIByType(Vars.ControllerEnabled and Data.UIType.characterCreation_c or Data.UIType.characterCreation)
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
		ccExt.skipTutorial_mc.y = y - 194

		ccExt.presetButton_mc.visible = _EXTVERSION >= 56
	end
end

local SkipTutorialRegions = {
	[0] = "None",
	"FJ_FortJoy_Main",
	"LV_HoE_Main",
	"RC_Main",
	"CoS_Main",
	"ARX_Main",
	"ARX_Endgame",
}

local SkipTutorialRegionTooltips = {
	None = "Go to the tutorial.",
	FJ_FortJoy_Main = "Go to the first Act, Fort Joy.",
	LV_HoE_Main = "Go to the Lady Vengeance inbetween Act 1 and 2.",
	RC_Main = "Go to Act 2, Reaper's Coast.",
	CoS_Main = "Go to Act 3 Part 1, the Nameless Isles.",
	ARX_Main = "Go to Act 3 Part 2, Arx.",
	ARX_Endgame = "Go to the end of the game.",
}

Classes.Enum:Create(SkipTutorialRegions)

function CCExt.SetupSkipTutorialButton(this)
	this.skipTutorial_mc.isEnabled = CCExt.IsHost
	GameSettingsManager.Load(false)
	this.skipTutorial_mc.setText(GameHelpers.GetStringKeyText("LeaderLib_UI_SkipTutorial_Description", "<font color='#77DDFF'>Skip Tutorial</font><br>Skip the tutorial and go straight to a specific level."))
	this.skipTutorial_mc.title_mc.setText(GameHelpers.GetStringKeyText("LeaderLib_UI_SkipTutorial_DisplayName", "Skip Tutorial"));
	for i=0,#SkipTutorialRegions-1 do
		local level = SkipTutorialRegions[i]
		if level ~= "None" then
			local name = GameHelpers.GetStringKeyText(level)
			this.skipTutorial_mc.addEntry(name, i, SkipTutorialRegionTooltips[level])
		else
			this.skipTutorial_mc.addEntry("Tutorial", i, SkipTutorialRegionTooltips.None)
		end
	end
	if not GameSettings.Settings.SkipTutorial.Enabled then
		this.skipTutorial_mc.selectItemByID(1, true)
	else
		local index = SkipTutorialRegions[GameSettings.Settings.SkipTutorial.Destination]
		if not index then
			index = SkipTutorialRegions.FJ_FortJoy_Main
		end
		this.skipTutorial_mc.selectItemByID(index, true)
	end
end

function CCExt.SetupInstance(force)
	local visible = force or GetCCVisibility()
	if visible then
		local instance = Ext.GetUI(CCExt.ID) or Ext.GetBuiltinUI(CCExt.SwfPath)
		if not instance then
			CCExt.Initialized = false
			instance = Ext.CreateUI(CCExt.ID, CCExt.SwfPath, CCExt.Layer)
		end
		if instance then
			instance:Show()
			local this = instance:GetRoot()
			if not CCExt.Initialized then
				local title = string.format("%s %s", LocalizedText.UI.Change.Value, LocalizedText.UI.Preset.Value)
				this.presetButton_mc.setText(title)
				this.presetButton_mc.title_mc.setText(title)
				if _EXTVERSION >= 56 then
					UIExtensions.CC.PresetExt.CreatePresetDropdown()
				end

				CCExt.SetupSkipTutorialButton(this)
				CCExt.PositionButtons(this)
				CCExt.Initialized = true
			end
			return instance
		else
			Ext.PrintError("[LeaderLib] Failed to create UI:", UIExtensions.SwfPath)
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

local function OnCharacterCreation(isCC)
	if isCC == false then
		DestroyInstance()
	elseif GameHelpers.IsLevelType(nil, LEVELTYPE.CHARACTER_CREATION) then
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

UI.RegisterUICreatedListener({Data.UIType.characterCreation, Data.UIType.characterCreation_c}, function (ui, this, player)
	if GameHelpers.IsLevelType(nil, LEVELTYPE.CHARACTER_CREATION) then
		UpdateVisibility(true)
	end
end)

Ext.RegisterListener("GameStateChanged", function (from, to)
	if to == "Menu" then
		DestroyInstance()
	end
end)

Ext.RegisterUINameCall("LeaderLib_SkipTutorialButton_LevelSelected", function (ui, call, id, index)
	local level = SkipTutorialRegions[index]
	if level then
		if level == "None" then
			GameSettings.Settings.SkipTutorial.Enabled = false
		else
			GameSettings.Settings.SkipTutorial.Enabled = true
			GameSettings.Settings.SkipTutorial.Destination = level
		end
		Ext.PostMessageToServer("LeaderLib_SetSkipTutorial", level)
		GameSettingsManager.Save()
	end
end)

Ext.RegisterNetListener("LeaderLib_EnableSkipTutorialUI", function (cmd, payload)
	CCExt.IsHost = true
	local this = CCExt.Root
	if this then
		this.skipTutorial_mc.isEnabled = true
	end
end)