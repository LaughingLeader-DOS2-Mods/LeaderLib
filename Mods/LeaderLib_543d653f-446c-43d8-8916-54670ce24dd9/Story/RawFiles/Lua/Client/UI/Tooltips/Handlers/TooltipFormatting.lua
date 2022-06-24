
local function ApplyLeading(tooltip_mc, element, amount)
	local val = 0
	if element then
		if amount == 0 or amount == nil then
			amount = tooltip_mc.m_Leading * 0.5
		end
		local heightPadding = 0
		if element.heightOverride then
			heightPadding = element.heightOverride / amount
		else
			heightPadding = element.height / amount
		end
		heightPadding = Ext.Round(heightPadding)
		if heightPadding <= 0 then
			heightPadding = 1
		end
		element.heightOverride = heightPadding * amount
	end
end

local function RepositionElements(tooltip_mc)
	--tooltip_mc.list.sortOnce("orderId",16,false)

	local leading = tooltip_mc.m_Leading * 0.5;
	local index = 0
	local element = nil
	local lastElement = nil
	while index < tooltip_mc.list.length do
		element = tooltip_mc.list.content_array[index]
		if element.list then
			element.list.positionElements()
		end
		if element == tooltip_mc.equipHeader then
			element.updateHeight()
		else
			if element.needsSubSection then
				if element.heightOverride == 0 or element.heightOverride == nil then
					element.heightOverride = element.height
				end
				--element.heightOverride = element.heightOverride + leading;
				element.heightOverride = element.heightOverride + leading
				if lastElement and not lastElement.needsSubSection then
					if lastElement.heightOverride == 0 or lastElement.heightOverride == nil then
						lastElement.heightOverride = lastElement.height
					end
					--lastElement.heightOverride = lastElement.heightOverride + leading;
					lastElement.heightOverride = lastElement.heightOverride + leading
				end
			end
			--tooltip_mc.applyLeading(element)
			ApplyLeading(tooltip_mc, element)
		end
		lastElement = element
		index = index + 1
	end
	--tooltip_mc.repositionElements()
	tooltip_mc.list.positionElements()
	tooltip_mc.resetBackground()
end

local replaceText = {}

---@param tag string
---@param data TagTooltipData|TranslatedString
---@return string
local function GetTagTooltipText(tag, data, tooltipType)
	local finalText = ""
	local tagName = ""
	local tagDesc = ""
	if data.Title == nil then
		tagName = GameHelpers.GetStringKeyText(tag)
	else
		local t = type(data.Title)
		if t == "string" then
			tagName = data.Title
		elseif t == "table" and data.Type == "TranslatedString" then
			tagName = data.Title.Value
		elseif t == "function" then
			local b,result = xpcall(data.Title, debug.traceback, tag, tooltipType)
			if b then
				tagName = result
			else
				Ext.PrintError(result)
			end
		end
	end
	if data.Description == nil then
		tagDesc = GameHelpers.GetStringKeyText(tag.."_Description")
	else
		local t = type(data.Description)
		if t == "string" then
			tagDesc = data.Description
		elseif t == "table" and data.Type == "TranslatedString" then
			tagDesc = data.Description.Value
		elseif t == "function" then
			local b,result = xpcall(data.Description, debug.traceback, tag, tooltipType)
			if b then
				tagDesc = result
			else
				Ext.PrintError(result)
			end
		end
	end
	if tagName ~= "" then
		finalText = tagName
	end
	if tagDesc ~= "" then
		if finalText ~= "" then
			finalText = finalText .. "<br>"
		end
		finalText = finalText .. tagDesc
	end
	return GameHelpers.Tooltip.ReplacePlaceholders(finalText)
end

local function FormatTagText(content_array, group, isControllerMode)
	local updatedText = false
	for i=0,#content_array,1 do
		local element = content_array[i]
		if element ~= nil then
			local b,result = xpcall(function()
				if element.label_txt ~= nil then
					local searchText = StringHelpers.Trim(element.label_txt.htmlText):gsub("[\r\n]", "")
					local tag = replaceText[searchText]
					local data = TooltipHandler.TagTooltips[tag]
					if data ~= nil then
						local finalText = GetTagTooltipText(tag, data, "Item")
						if not StringHelpers.IsNullOrWhitespace(finalText) then
							element.label_txt.htmlText = finalText
							updatedText = true
						end
					end
				end
				return true
			end, debug.traceback)
			if not b then
				Ext.PrintError("[LeaderLib:FormatTagText] Error:")
				Ext.PrintError(result)
			end
		end
	end
	if updatedText and group ~= nil then
		group.iconId = 16
		group.setupHeader()
	end
end

UI.FormatArrayTagText = FormatTagText

local function FormatTagTooltip(ui, tooltip_mc, ...)
	local length = #tooltip_mc.list.content_array
	if length > 0 then
		for i=0,length,1 do
			local group = tooltip_mc.list.content_array[i]
			if group ~= nil then
				--print(string.format("[%i] groupID(%i) orderId(%s) icon(%s) list(%s)", i, group.groupID or -1, group.orderId or -1, group.iconId, group.list))
				if group.list ~= nil then
					FormatTagText(group.list.content_array, group, false)
				end
			end
		end
	end
end

local _itemTypeTooltips = {
	Item = true,
	Rune = true,
	Pyramid = true
}

--Check the UI Type so we don't delay item tools in the hotbar
local _itemTypeTooltipsUIs = {
	[Data.UIType.partyInventory] = true,
	[Data.UIType.partyInventory_c] = true,
	[Data.UIType.containerInventory] = true,
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

--Fires after TooltipHooks.NextRequest is processed and made nil.
function TooltipHandler.OnTooltipPositioned(ui, ...)
	local root = ui:GetRoot()
	if root ~= nil then
		local lastRequestType = ""
		local lastRequest = Game.Tooltip.GetCurrentOrLastRequest()
		local lastRequestUIType = nil
		if lastRequest then
			lastRequestType = lastRequest.Type
			lastRequestUIType = lastRequest.UIType
		end
		local settings = GameSettingsManager.GetSettings()
		if root.tf then
			if settings.Client.EnableTooltipDelay.Item and _itemTypeTooltips[lastRequestType] then
				root.tf.allowDelay = true
			elseif settings.Client.EnableTooltipDelay.Skill and lastRequestType == "Skill" then
				root.tf.allowDelay = true
			elseif settings.Client.EnableTooltipDelay.Status and lastRequestType == "Status" then
				root.tf.allowDelay = true
			elseif settings.Client.EnableTooltipDelay.CharacterSheet and _sheetTypeTooltips[lastRequestType] then
				root.tf.allowDelay = true
			elseif settings.Client.EnableTooltipDelay.Generic and lastRequestType == "Generic" then
				root.tf.allowDelay = true
			elseif root.tf.allowDelay == true then
				root.tf.allowDelay = false
			end
		end

		if lastRequestType == "Item" and TooltipHandler.HasTagTooltipData or #Listeners.OnTooltipPositioned > 0 then
			local tooltips = {}

			if root.formatTooltip ~= nil then
				tooltips[#tooltips+1] = root.formatTooltip.tooltip_mc
			end
			if root.compareTooltip ~= nil then
				tooltips[#tooltips+1] = root.compareTooltip.tooltip_mc
			end
			if root.offhandTooltip ~= nil then
				tooltips[#tooltips+1] = root.offhandTooltip.tooltip_mc
			end

			local len = #tooltips
			if len > 0 then
				for i=1,len do
					local tooltip_mc = tooltips[i]
					if Features.FormatTagElementTooltips then
						FormatTagTooltip(ui, tooltip_mc)
					end
					InvokeListenerCallbacks(Listeners.OnTooltipPositioned, ui, tooltip_mc, false, TooltipHandler.LastItem, ...)
				end
			end
		end
	end
end

function TooltipHandler.AddTooltipTags(item, tooltip)
	for tag,data in pairs(TooltipHandler.TagTooltips) do
		if GameHelpers.ItemHasTag(item, tag) then
			local finalText = GetTagTooltipText(tag, data, "Item")
			if not StringHelpers.IsNullOrWhitespace(finalText) then
				tooltip:AppendElement({
					Type="StatsTalentsBoost",
					Label=finalText
				})
				local searchText = finalText:gsub("<font.->", ""):gsub("</font>", ""):gsub("<br>", "")
				replaceText[searchText] = tag
			end
		end
	end
end

Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", TooltipHandler.OnTooltipPositioned)