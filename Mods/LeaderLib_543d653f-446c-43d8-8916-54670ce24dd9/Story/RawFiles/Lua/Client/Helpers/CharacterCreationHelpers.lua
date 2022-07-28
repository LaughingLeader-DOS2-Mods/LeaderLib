if GameHelpers.CC == nil then
	GameHelpers.CC = {}
end

---@param colorType RacePresetColorType
---@return _GameHelpers_Stats_GetAllRacePresetColorsResults
function GameHelpers.CC.GetClientRaceColors(colorType)
	local client = Client:GetCharacter()
	if client and client.PlayerCustomData and not StringHelpers.IsNullOrWhitespace(client.PlayerCustomData.Race) then
		if colorType == nil or colorType == "All" then
			return GameHelpers.Stats.GetAllRacePresetColors(client.PlayerCustomData.Race)
		else
			return GameHelpers.Stats.GetRacePresetColors(client.PlayerCustomData.Race, colorType)
		end
	end
	return nil
end

local SELECT_OPTION_ID = {
	SkinColor = 3,
	HairColor = 6
}

--Skin Colour is faceSelector_mc [3]
--Hair Colour is skinSelector_mc [6]

local function _UpdateUIOption(colorType, panel, index, name)
	local opts_mc = nil
	if colorType == "Skin" then
		opts_mc = panel.contentArray[3]
	elseif colorType == "Hair" then
		opts_mc = panel.contentArray[6]
	end
	if opts_mc then
		local idx = opts_mc.selection_mc.currentIdx
		opts_mc.selectOption(index)
		opts_mc.selection_mc.text_txt.htmlText = name
		return index > idx
	end
	return false
end

---@param id string|integer
---@param colorType string
---@param optionIndex integer
---@param matchType "Handle"|"Name"|"Value"|"ID"|nil The property type to match id with. If matching a string, prefer Handle over Name, as the name may be translated.
local function SelectOption(id, colorType, optionIndex, matchType, uiOnly)
	local cc = UIExtensions.CharacterCreation.Instance
	if cc then
		local client = Client:GetCharacter()
		if client and client.PlayerCustomData and not StringHelpers.IsNullOrWhitespace(client.PlayerCustomData.Race) then
			local b = false
			local this = cc:GetRoot()
			local panel = this.CCPanel_mc
			local colors = GameHelpers.Stats.GetRacePresetColors(client.PlayerCustomData.Race, colorType)
			local targetColor = nil
			if matchType == "Handle" then
				local color = colors[id]
				if color then
					targetColor = color
				end
			elseif matchType == "Name" then
				for _,color in pairs(colors) do
					if color.Name == id then
						targetColor = color
						break
					end
				end
			elseif matchType == "Value" then
				for _,color in pairs(colors) do
					if color.Value == id then
						targetColor = color
						break
					end
				end
			elseif matchType == "ID" then
				for _,color in pairs(colors) do
					if color.ID == id then
						targetColor = color
						break
					end
				end
			end
			if targetColor then
				b = _UpdateUIOption(colorType, panel, targetColor.Index, targetColor.Name)
				if not uiOnly then
					cc:ExternalInterfaceCall("selectOption", optionIndex, targetColor.Index, b)
				end
				this.selectOption(optionIndex, targetColor.Index)
				return true,targetColor
			end
		end
	end
	return false
end

local function _SetMatchType(id)
	local matchType = "Handle"
	local t = type(id)
	if t == "string" then
		if StringHelpers.IsTranslatedStringHandle(id) then
			matchType = "Handle"
		else
			matchType = "Name"
		end
	elseif t == "number" then
		matchType = "Value"
	end
	return matchType
end

---@param colorType "Hair"|"Skin"
---@param id string|integer Either the color handle, translated name, or index.
---@param matchType "Handle"|"Name"|"Value"|"ID"|nil The property type to match id with. If matching a string, prefer Handle over Name, as the name may be translated.
---@param uiOnly boolean|nil If true, the color is only selected in the UI, and the ExternalInterfaceCall is skipped.
---@return boolean
function GameHelpers.CC.SetColor(colorType, id, matchType, uiOnly)
	colorType = colorType or "Skin"
	if matchType == nil then
		matchType = _SetMatchType(id)
	end
	local optType = SELECT_OPTION_ID.SkinColor
	if colorType == "Hair" then
		optType = SELECT_OPTION_ID.HairColor
	elseif colorType == "Skin" then
		optType = SELECT_OPTION_ID.SkinColor
	end
	return SelectOption(id, colorType, optType, matchType, uiOnly)
end