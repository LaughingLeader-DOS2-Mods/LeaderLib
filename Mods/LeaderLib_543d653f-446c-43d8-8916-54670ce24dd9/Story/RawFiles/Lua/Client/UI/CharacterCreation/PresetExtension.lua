local CharacterCreation = Classes.UIWrapper:CreateFromType(Data.UIType.characterCreation, {ControllerID = Data.UIType.characterCreation_c, IsControllerSupported = true})

---@private
---@class CCAbilityChangeEntry
---@field Ability string
---@field AmountIncreased integer

---@private
---@class CCAttributeChangeEntry
---@field Attribute string
---@field AmountIncreased integer

---@private
---@class CCEquipmentPropertiesEntry
---@field PreviewEquipmentSet string
---@field RaceName string
---@field StartingEquipmentSet string

---@private
---@class CCPresetData
---@field ClassType string
---@field ClassName string Localization handle
---@field ClassLongDescription string Localization handle
---@field ClassDescription string Localization handle
---@field AreStatsWeighted boolean
---@field Icon integer
---@field NumStartingAttributePoints integer
---@field NumStartingCivilAbilityPoints integer
---@field NumStartingCombatAbilityPoints integer
---@field NumStartingTalentPoints integer
---@field Price integer
---@field Voice integer
---@field SkillSet string
---@field TalentsAdded string[]
---@field AbilityChanges CCAbilityChangeEntry[]
---@field AttributeChanges CCAttributeChangeEntry[]
---@field EquipmentProperties CCEquipmentPropertiesEntry[]

---@type table<string,integer>
local PresetToID = {}

local PresetExt = {}
UIExtensions.CC.PresetExt = PresetExt

Ext.RegisterUINameCall("LeaderLib_PresetDropdown_PresetSelected", function (ui, event, selectedId, selectedIndex)
	if selectedId then
		--ExternalInterface.call("selectOption",(parent as MovieClip).contentID,this.optionsList[this.currentIdx].optionID,true);
		CharacterCreation.Instance:ExternalInterfaceCall("selectOption", 1.0, selectedId, true)
	end
end)

function PresetExt.BuildModAssociation(findModForPreset, presets)
	local remaining = Common.TableLength(findModForPreset, true)
	local order = Ext.Mod.GetLoadOrder()
	for i=1,#order do
		local uuid = order[i]
		local mod = Ext.Mod.GetMod(uuid)
		if mod then
			local info = mod.Info
			for classType,index in pairs(findModForPreset) do
				local filePath = string.format("Mods/%s/CharacterCreation/ClassPresets/%s.lsx", info.Directory, classType)
				--local filePathWithoutSpaces = string.format("Mods/%s/CharacterCreation/ClassPresets/%s.lsx", info.Directory, StringHelpers.RemoveWhitespace(classType))
				if Ext.IO.LoadFile(filePath, "data") then
					presets[index].Mod = info.Name
					presets[index].ModUUID = uuid
					if info.Name == "Shared" then
						presets[index].Mod = "Divinity: Original Sin 2"
					end
					findModForPreset[classType] = nil
					remaining = remaining - 1
				end
				if remaining <= 0 then
					return
				end
			end
		end
	end
end

function PresetExt.SelectCurrentPreset(ccExt)
	local ccRoot = CharacterCreation.Root
	if ccRoot then
		local player = GameHelpers.Client.GetCharacterCreationCharacter(ccRoot)
		if player and player.PlayerCustomData and player.PlayerCustomData.ClassType then
			local id = PresetToID[player.PlayerCustomData.ClassType]
			ccExt.presetButton_mc.selectItemByID(id, true)
		end
	end
end

function PresetExt.CreatePresetDropdown()
	local ccExt = UIExtensions.CC.Root
	
	if not ccExt or ccExt.presetButton_mc.visible and ccExt.presetButton_mc.length > 0 then
		return
	end

	local cachedPresetToMod = GameHelpers.IO.LoadJsonFile("LeaderLib_PresetToModCache.json", {})
	local cc = Ext.Stats.GetCharacterCreation()
	local presets = {}
	local findModForPreset = {}
	PresetToID = {}
	for i,v in pairs(cc.ClassPresets) do
		PresetToID[v.ClassType] = i-1
		local index = #presets+1
		local entry = {
			ClassType = v.ClassType,
			Label = GameHelpers.GetTranslatedStringValue(v.ClassName),
			ID = i-1
		}
		
		if StringHelpers.IsNullOrWhitespace(entry.Label) then
			entry.Label = v.ClassType
		end
		local desc1 = GameHelpers.GetTranslatedStringValue(v.ClassDescription)
		local desc2 = GameHelpers.GetTranslatedStringValue(v.ClassLongDescription)
		local isEmpty1 = StringHelpers.IsNullOrEmpty(desc1)
		local isEmpty2 = StringHelpers.IsNullOrEmpty(desc2)
		if isEmpty1 and not isEmpty2 then
			entry.Tooltip = desc2
		else
			entry.Tooltip = desc1
		end
		if cachedPresetToMod[v.ClassType] then
			entry.ModUUID = cachedPresetToMod[v.ClassType]
			local mod = Ext.Mod.GetMod(entry.ModUUID)
			if mod then
				entry.Mod = mod.Info.Name
			end
		elseif entry.Tooltip ~= "" then
			--FIXME Most mods don't follow ClassType -> Filename conventions, or localize their text with proper handles.
			findModForPreset[v.ClassType] = index
		end
		presets[index] = entry
	end

	PresetExt.BuildModAssociation(findModForPreset, presets)
	findModForPreset = {}
	
	table.sort(presets, function (a,b)
		return a.Label < b.Label
	end)

	ccExt.presetButton_mc.removeAll()
	ccExt.togglePresetButton(true)
	--local dropdown_mc = UIExtensions.AddDropdown(OnPresetSelected, x, y, {Dropdown = "Presets", Tooltip = "Select a Class Preset"}, presets)
	for i=1,#presets do
		local entry = presets[i]
		if entry.Mod then
			local modName = entry.Mod
			findModForPreset[entry.ClassType] = entry.ModUUID
			if modName == "Shared" then
				modName = "Divinity: Original Sin 2"
			end
			entry.Tooltip = string.format("%s<br><font color='#77FFCC'>%s</font>", entry.Tooltip, modName)
		end
		ccExt.presetButton_mc.addEntry(entry.Label, entry.ID, entry.Tooltip)
	end

	GameHelpers.IO.SaveJsonFile("LeaderLib_PresetToModCache.json", findModForPreset)

	PresetExt.SelectCurrentPreset(ccExt)
end