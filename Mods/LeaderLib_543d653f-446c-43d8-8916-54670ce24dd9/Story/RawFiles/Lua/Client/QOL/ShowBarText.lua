
local function SetBarTextVisible(b)
	local ui = Ext.UI.GetByType(Data.UIType.statusConsole)
	if ui then
		---@type {fightButtons_mc:{showTxtHitBox_mc:FlashMovieClip}, console_mc:{hbTxt_mc:FlashMovieClip, abTxt_mc:FlashMovieClip, mabTxt_mc:FlashMovieClip}}
		local this = ui:GetRoot()
		
		---@type FlashMovieClip
		this.fightButtons_mc.showTxtHitBox_mc.mouseEnabled = not b
		this.console_mc.hbTxt_mc.visible = b
		this.console_mc.abTxt_mc.visible = b
		this.console_mc.mabTxt_mc.visible = b
	end
end

local wasDisabled = false

Events.GameSettingsChanged:Subscribe(function (e)
	if e.Settings.Client.AlwaysShowBarText then
		SetBarTextVisible(true)
		wasDisabled = true
	elseif wasDisabled then
		SetBarTextVisible(false)
	end
end)

Events.BeforeLuaReset:Subscribe(function (e)
	if wasDisabled then
		SetBarTextVisible(false)
	end
end)