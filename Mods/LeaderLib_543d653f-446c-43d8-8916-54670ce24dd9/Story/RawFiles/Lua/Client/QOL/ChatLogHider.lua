local _currentState = Ext.GetGameState()

Ext.Events.GameStateChanged:Subscribe(function (e)
	_currentState = e.ToState
end)

local _ticksSince = 0

--Ext.UI.GetByType(6):GetRoot().log_mc.enableInput(false)


RegisterListener("BeforeLuaReset", function()
	local chatlog = Ext.UI.GetByType(Data.UIType.chatLog)
	if chatlog and not Common.TableHasValue(chatlog.Flags, "OF_Visible") then
		chatlog:Show()
		-- local this = chatlog:GetRoot()
		-- this.log_mc.enableInput(true)
	end
	local hotbar = Ext.UI.GetByType(Data.UIType.hotBar)
	if hotbar then
		hotbar:GetRoot().hotbar_mc.chatBtn_mc.visible = true
	end
end)

local lastDisabled = nil

Ext.Events.Tick:Subscribe(function (e)
	if not Vars.Resetting and _currentState == "Running" then
		if GameSettings.Settings.Client.HideChatLog then
			lastDisabled = true
			local chatlog = Ext.UI.GetByType(Data.UIType.chatLog)
			if chatlog and Common.TableHasValue(chatlog.Flags, "OF_Visible") then
				chatlog:Hide()
			end
			local hotbar = Ext.UI.GetByType(Data.UIType.hotBar)
			if hotbar then
				hotbar:GetRoot().hotbar_mc.chatBtn_mc.visible = false
			end
		elseif lastDisabled ~= false then
			local chatlog = Ext.UI.GetByType(Data.UIType.chatLog)
			if chatlog and not Common.TableHasValue(chatlog.Flags, "OF_Visible") then
				chatlog:Show()
			end
			local hotbar = Ext.UI.GetByType(Data.UIType.hotBar)
			if hotbar then
				hotbar:GetRoot().hotbar_mc.chatBtn_mc.visible = true
			end
			lastDisabled = false
		end
		-- if _ticksSince <= 0 then
		-- 	_ticksSince = 20
		-- else
		-- 	_ticksSince = _ticksSince - (1 * e.Time.DeltaTime)
		-- end
	end
end)