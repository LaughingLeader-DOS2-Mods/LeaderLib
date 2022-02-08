---@class CCExtensionsUI
---@field Root FlashMainTimeline
---@field Instance UIObject
local CCExt = {
	ID = "LeaderLib_CharacterCreationExtensions",
	Layer = 3,
	SwfPath = "Public/LeaderLib_543d653f-446c-43d8-8916-54670ce24dd9/GUI/LeaderLib_CharacterCreationExtensions.swf",
	Initialized = false,
	Visible = false
}

UIExtensions.CC = CCExt

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
			local ui = CCExt.GetInstance()
			if ui then
				return ui:GetRoot()
			end
		elseif k == "Instance" then
			local ui = CCExt.GetInstance()
			if ui then
				return ui
			end
		end
	end
})

local function DestroyInstance()
	local instance = CCExt.GetInstance(false)
	if instance then
		instance:Hide()
		instance:Destroy()
		CCExt.Visible = false
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
		return Common.TableHasValue(cc.Flags, "OF_Visible")
	end
	return false
end

function CCExt.ToggleVisibility()
	CCExt.Visible = GetCCVisibility()
	if CCExt.Visible then
		local inst = CCExt.GetInstance()
		if inst then
			inst:Show()
		end
	else
		DestroyInstance()
	end
end

function CCExt.SetupInstance()
	CCExt.Visible = GetCCVisibility()
	if CCExt.Visible then
		local instance = Ext.GetUI(CCExt.ID)
		if not instance then
			instance = Ext.CreateUI(CCExt.ID, CCExt.SwfPath, CCExt.Layer)
		end
		if instance then
			instance:Show()
			local this = instance:GetRoot()
			this.skipTutorial_mc.visible = SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION
			this.presetButton_mc.setText("Set Preset")
		else
			Ext.PrintError("[LeaderLib] Failed to create UI:", UIExtensions.SwfPath)
		end
	end
end

RegisterListener("RegionChanged", function (region, state, levelType)
	if levelType ~= LEVELTYPE.CHARACTER_CREATION or state == REGIONSTATE.ENDED then
		DestroyInstance()
	else
		local inst = CCExt.GetInstance(true)
		if inst then
			CCExt.SetupInstance()
		end
	end
end)