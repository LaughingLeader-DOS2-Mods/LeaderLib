local _TOOLTIP_REQUEST_CALLS = {
	pyramidOver = "Pyramid",
	requestAbilityTooltip = "Ability",
	requestAttributeTooltip = "Stat",
	requestSkillTooltip = "Skill",
	requestTagTooltip = "Tag",
	requestTalentTooltip = "Talent",
	showAbilityTooltip = "Ability",
	showCharTooltip = "PlayerPortrait",
	showCustomStatTooltip = "CustomStat",
	showItemTooltip = "Item",
	showRuneTooltip = "Rune",
	showSkillTooltip = "Skill",
	showStatTooltip = "Stat",
	showStatusTooltip = "Status",
	showTagTooltip = "Tag",
	showTalentTooltip = "Talent",
	showTooltip = "Generic",
	--CharacterExpansionLib
	showAbilityTooltipCustom = "Ability",
	showTalentTooltipCustom = "Talent",
	showStatTooltipCustom = "Stat",
}

local lastCall = ""
local lastMouseX = 0
local lastMouseY = 0

local skipCreationDelay = false
local _ENABLED = false
local _DELAY = 0

local _itemTypeTooltips = {
	Item = true,
	Rune = true,
	Pyramid = true
}

--Check the UI Type so we don't delay item tools in the hotbar
local _itemTypeTooltipsUIs = {
	[Data.UIType.partyInventory] = true,
	[Data.UIType.partyInventory_c] = true,
	[Data.UIType.containerInventory.Default] = true,
	[Data.UIType.containerInventory.Pickpocket] = true,
	[Data.UIType.containerInventoryGM] = true,
	[Data.UIType.reward] = true,
	[Data.UIType.reward_c] = true,
}

local _sheetTypeTooltips = {
	Ability = true,
	Stat = true,
	CustomStat = true,
	Talent = true,
	Tag = true,
}

local function CanDelayTooltip(requestType)
	local settings = GameSettingsManager.GetSettings()
	if not settings then
		return
	end
	if settings.Client.EnableTooltipDelay.Item and _itemTypeTooltips[requestType] then
		return true
	elseif settings.Client.EnableTooltipDelay.Skill and requestType == "Skill" then
		return true
	elseif settings.Client.EnableTooltipDelay.Status and requestType == "Status" then
		return true
	elseif settings.Client.EnableTooltipDelay.CharacterSheet and _sheetTypeTooltips[requestType] then
		return true
	elseif settings.Client.EnableTooltipDelay.Generic and requestType == "Generic" then
		return true
	end

	return false
end

---@param e EclLuaUICallEventParams
local function OnUICall(e)
	if e.When == "Before" then
		-- if e.Function == "showTooltip" and OptionsSettingsHooks.IsLeaderLibMenuActive() then
		--- Doesn't work since tooltip.swf ignores these params
		-- 	e.Args[4] = e.Args[4] + 400
		-- end
		if e.Function == "hideTooltip" then
			Timer.Cancel("LeaderLib_ModMenu_DelayShowTooltip")
			skipCreationDelay = false
			lastCall = ""
		elseif _ENABLED and not skipCreationDelay and e.Args[1] ~= nil then
			local tooltipType = _TOOLTIP_REQUEST_CALLS[e.Function]
			local canDelay = tooltipType and CanDelayTooltip(tooltipType)
			if canDelay then
				if tooltipType == "Item" and e.Function == lastCall then
					local this = e.UI:GetRoot()
					if not this then
						return
					end
					local mx = this.mouseX
					local my = this.mouseY
					if math.abs(lastMouseX - mx) + math.abs(lastMouseY - my) <= 30 then
						--Comparison tooltips
						skipCreationDelay = false
						Timer.Cancel("LeaderLib_ModMenu_DelayShowTooltip")
						lastMouseX = mx
						lastMouseY = my
						return
					end
				end
				if not skipCreationDelay then
					local this = e.UI:GetRoot()
					if not this then
						return
					end
					local mx = this.mouseX
					local my = this.mouseY
					local uiType = e.UI.Type
					local call = e.Function
					lastCall = call
					local args = {table.unpack(e.Args)}
					lastMouseX = mx
					lastMouseY = my
					e:PreventAction()
					e:StopPropagation()
					Timer.Cancel("LeaderLib_ModMenu_DelayShowTooltip")
					Timer.StartOneshot("LeaderLib_ModMenu_DelayShowTooltip", _DELAY, function (e)
						local ui = Ext.UI.GetByType(uiType)
						if ui then
							skipCreationDelay = true
							ui:ExternalInterfaceCall(call, table.unpack(args))
						end
					end)
				end
				skipCreationDelay = false
			end
		end
	end
end

Events.GameSettingsChanged:Subscribe(function (e)
	_DELAY = e.Settings.Client.EnableTooltipDelay.GlobalDelay
	_ENABLED = _DELAY > 0
end)

Ext.Events.SessionLoaded:Subscribe(function (e)
	if not Vars.ControllerEnabled then
		Ext.Events.UICall:Subscribe(function (e)
			OnUICall(e)
		end, {Priority=9999})
	end
end)