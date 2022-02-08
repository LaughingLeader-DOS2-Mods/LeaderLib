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

---@type table<string, CCPresetData>
--local PresetData = {}
---@type table<string,integer>
local PresetToID = {}

-- local function BuildPresetData()
-- 	local cc = Ext.Stats.GetCharacterCreation()
-- 	for i,v in pairs(cc.ClassPresets) do
-- 		PresetData[v.ClassType] = v
-- 		PresetToID[v.ClassType] = i-1
-- 	end
-- end

Ext.RegisterUINameCall("LeaderLib_UIExtensions_PresetSelected", function (ui, event, selectedId, selectedIndex)
	if selectedId then
		--ExternalInterface.call("selectOption",(parent as MovieClip).contentID,this.optionsList[this.currentIdx].optionID,true);
		CharacterCreation.Instance:ExternalInterfaceCall("selectOption", 1.0, selectedId, true)
	end
end)

local function BuildModAssociation(findModForPreset, presets)
	local remaining = Common.TableLength(findModForPreset, true)
	local order = Ext.GetModLoadOrder()
	for i=1,#order do
		local uuid = order[i]
		local info = Ext.GetModInfo(uuid)
		if info ~= nil then
			for classType,index in pairs(findModForPreset) do
				local filePath = string.format("Mods/%s/CharacterCreation/ClassPresets/%s.lsx", info.Directory, classType)
				--local filePathWithoutSpaces = string.format("Mods/%s/CharacterCreation/ClassPresets/%s.lsx", info.Directory, StringHelpers.RemoveWhitespace(classType))
				if Ext.IO.LoadFile(filePath, "data") then
					presets[index].Mod = info.Name
					presets[index].ModUUID = info.UUID
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

local function PositionPresetButton()
	local this = CharacterCreation.Root
	local extRoot = UIExtensions.CC.Root
	if this then
		local x = this.CCPanel_mc.x + this.CCPanel_mc.armourBtnHolder_mc.x + this.CCPanel_mc.armourBtnHolder_mc.helmetBtn_mc.x
		local y = this.CCPanel_mc.y + this.CCPanel_mc.origins_mc.height - 224
		extRoot.presetButton_mc.x = x
		extRoot.presetButton_mc.y = y
	end
end

local function CreatePresetDropdown()
	PositionPresetButton()

	local this = CharacterCreation.Root
	local extRoot = UIExtensions.CC.Root

	if extRoot.presetButton_mc.visible and extRoot.presetButton_mc.length > 0 then
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
		if desc1 == "" and desc2 ~= "" or string.len(desc2) > string.len(desc1) then
			entry.Tooltip = desc2
		else
			entry.Tooltip = desc1
		end
		if cachedPresetToMod[v.ClassType] then
			entry.ModUUID = cachedPresetToMod[v.ClassType]
			local info = Ext.GetModInfo(entry.ModUUID)
			if info then
				entry.Mod = info.Name
			end
		elseif entry.Tooltip ~= "" then
			--FIXME Most mods don't follow ClassType -> Filename conventions, or localize their text with proper handles.
			findModForPreset[v.ClassType] = index
		end
		presets[index] = entry
	end

	BuildModAssociation(findModForPreset, presets)
	findModForPreset = {}
	
	table.sort(presets, function (a,b)
		return a.Label < b.Label
	end)

	extRoot.presetButton_mc.setText("Set Preset")
	extRoot.presetButton_mc.removeAll()
	extRoot.togglePresetButton(true)
	--local dropdown_mc = UIExtensions.AddDropdown(OnPresetSelected, x, y, {Dropdown = "Presets", Tooltip = "Select a Class Preset"}, presets)
	for i=1,#presets do
		local entry = presets[i]
		if entry.Mod then
			findModForPreset[entry.ClassType] = entry.ModUUID
			entry.Tooltip = string.format("%s<br><font color='#77FFCC'>%s</font>", entry.Tooltip, entry.Mod)
		end
		extRoot.presetButton_mc.addEntry(entry.Label, entry.ID, entry.Tooltip)
	end

	GameHelpers.IO.SaveJsonFile("LeaderLib_PresetToModCache.json", findModForPreset)

	local player = GameHelpers.Client.GetCharacterCreationCharacter(this)
	if player and player.PlayerCustomData and player.PlayerCustomData.ClassType then
		local id = PresetToID[player.PlayerCustomData.ClassType]
		extRoot.presetButton_mc.selectItemByID(id, true)
	end
end

Ext.RegisterUITypeInvokeListener(Data.UIType.characterCreation, "updateTags", function (ui, call)
	if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
		CreatePresetDropdown()
	end
end, "After")

RegisterListener("LuaReset", function ()
	local level = Ext.Entity.GetCurrentLevel()
	if level and level.LevelDesc.UniqueKey == "SYS_Character_Creation_A" then
		CreatePresetDropdown()
	end
end)

Ext.RegisterUINameCall("LeaderLib_UIExtensions_OnEventResolution", function ()
	if SharedData.RegionData.LevelType == LEVELTYPE.CHARACTER_CREATION then
		PositionPresetButton()
	end
end, "After")