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

---Get the client player (the character the player becomes after CC) and the dummy (the character used for visualizing options).
---@param player EclCharacter
---@return EclCharacterCreationCharacterCustomization
function GameHelpers.CC.GetCustomization(player)
	local playerManager = Ext.Entity.GetPlayerManager()
	local cc = Ext.UI.GetCharacterCreationWizard()
	local inputID = playerManager.Players[player.UserID].InputPlayerIndex
	local customization = cc.CharacterCreationManager.Customizations[inputID]
	return customization
end

---@class GameHelpers_CC_GetCharacterDataResults
---@field Dummy EclCharacter
---@field TargetOriginCharacter EclCharacter
---@field Customization EclCharacterCreationCharacterCustomization
---@field UserId UserId
---@field ProfileGuid Guid

---Get the client player (the character the player becomes after CC) and the dummy (the character used for visualizing options).
---@param secondPlayer? boolean Get the second player in splitscreen.
---@return GameHelpers_CC_GetCharacterDataResults data
function GameHelpers.CC.GetCharacterData(secondPlayer)
	---@type {UserId:UserId, Player:EclCharacter, Customization:EclCharacterCreationCharacterCustomization, ProfileGuid:Guid}[]
	local players = {}
	local playerManager = Ext.Entity.GetPlayerManager()
	local cc = Ext.UI.GetCharacterCreationWizard()
	for userId,entry in pairs(playerManager.ClientPlayerData) do
		players[#players+1] = {
			UserId = userId,
			Player = Ext.Entity.GetCharacter(entry.CharacterNetId),
			Customization = cc.CharacterCreationManager.Customizations[playerManager.Players[userId].InputPlayerIndex],
			ProfileGuid = entry.ProfileGuid
		}
	end
	local player = players[1]
	if secondPlayer and players[2] then
		player = players[2]
	end
	local origin = player.Customization.State.Origin
	local rootTemplateGuid = player.Customization.State.RootTemplate
	local targetCharacter = nil
	local ccStats = Ext.Stats.GetCharacterCreation()
	for _,v in pairs(ccStats.OriginPresets) do
		if v.OriginName == origin and StringHelpers.IsNullOrEmpty(v.RootTemplateOverride) or v.RootTemplateOverride == rootTemplateGuid then
			targetCharacter = Ext.Entity.GetCharacter(v.CharacterUUID)
			break
		end
	end
	if targetCharacter == nil then
		for _,v in pairs(ccStats.GenericOriginPresets) do
			if v.OriginName == origin then
				targetCharacter = Ext.Entity.GetCharacter(v.CharacterUUID)
				break
			end
		end
	end
	return {
		Dummy = player.Player,
		TargetOriginCharacter = targetCharacter,
		Customization = player.Customization,
		UserId = player.UserId,
		ProfileGuid = player.ProfileGuid
	}
end