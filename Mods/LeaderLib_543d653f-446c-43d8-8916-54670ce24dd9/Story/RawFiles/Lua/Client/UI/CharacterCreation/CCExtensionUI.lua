---@class CCExtensionsUI
---@field Root FlashMainTimeline
---@field Instance UIObject
---@field Visible boolean
local CCExt = {
	ID = "LeaderLib_CharacterCreationExtensions",
	Layer = 3,
	SwfPath = "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_CharacterCreationExtensions.swf",
	Initialized = false,
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
			local ui = CCExt.GetInstance(false)
			if ui then
				return ui:GetRoot()
			end
		elseif k == "Instance" then
			local ui = CCExt.GetInstance(false)
			if ui then
				return ui
			end
		elseif k == "Visible" then
			local ui = CCExt.GetInstance(false)
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
		if cc:GetRoot().isFinished == true then
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

function CCExt.SetupInstance(force)
	local visible = force or GetCCVisibility()
	if visible then
		local instance = Ext.GetUI(CCExt.ID)
		if not instance then
			CCExt.Initialized = false
			instance = Ext.CreateUI(CCExt.ID, CCExt.SwfPath, CCExt.Layer)
		end
		if instance then
			instance:Show()
			local this = instance:GetRoot()
			if not CCExt.Initialized then
				this.presetButton_mc.setText(string.format("%s %s", LocalizedText.UI.Change.Value, LocalizedText.UI.Preset.Value))
				SkipTutorial.SetupSkipTutorialCheckbox(this)
				UIExtensions.CC.PresetExt.CreatePresetDropdown()
				CCExt.Initialized = true
			end
			return instance
		else
			Ext.PrintError("[LeaderLib] Failed to create UI:", UIExtensions.SwfPath)
		end
	end
end

local function UpdateVisibility()
	local ccVisible = GetCCVisibility()
	if not ccVisible then
		DestroyInstance()
	else
		local inst = CCExt.GetInstance(true)
		if inst then
			CCExt.SetupInstance()
		end
	end
end

local function OnCharacterCreation(isCC)
	if isCC == false then
		DestroyInstance()
	elseif GameHelpers.IsLevelType(nil, LEVELTYPE.CHARACTER_CREATION) then
		CCExt.SetupInstance(true)
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.tutorialBox, "setIsCharacterCreation", function (ui, method, isCC)
	OnCharacterCreation(isCC)
end)

Ext.RegisterUITypeInvokeListener(Data.UIType.tutorialBox_c, "setIsCharacterCreation", function (ui, method, isCC)
	OnCharacterCreation(isCC)
end)

UI.RegisterUICreatedListener({Data.UIType.characterCreation, Data.UIType.characterCreation_c}, function (ui, this, player)
	if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
		CCExt.SetupInstance(true)
	end
end)

Ext.RegisterListener("GameStateChanged", function (from, to)
	if to == "Menu" then
		DestroyInstance()
	end
end)