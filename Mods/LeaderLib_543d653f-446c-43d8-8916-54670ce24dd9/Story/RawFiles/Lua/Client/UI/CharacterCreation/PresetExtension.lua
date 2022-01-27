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
local PresetData = {}
---@type table<string,integer>
local PresetToID = {}

local function BuildPresetData()
	local cc = Ext.Stats.GetCharacterCreation()
	for i,v in pairs(cc.ClassPresets) do
		PresetData[v.ClassType] = v
		PresetToID[v.ClassType] = i-1
	end
end

Ext.RegisterUINameCall("LeaderLib_UIExtensions_PresetSelected", function (ui, event, selectedId, selectedIndex)
	print(event, selectedId, selectedIndex)
	if selectedId then
		--ExternalInterface.call("selectOption",(parent as MovieClip).contentID,this.optionsList[this.currentIdx].optionID,true);
		CharacterCreation.Instance:ExternalInterfaceCall("selectOption", 1.0, selectedId, true)
	end
end)

local function CreatePresetDropdown()
	local inst = CharacterCreation.Instance
	local extInst = UIExtensions.Instance
	local uiExt = extInst:GetRoot()
	local this = inst:GetRoot()
	local x,y = 600, 200
	if this then
		uiExt.layout = "fitVertical"
		extInst:ExternalInterfaceCall("setAnchor","center","screen","center")
		extInst:Resize(inst.FlashMovieSize[1], inst.FlashMovieSize[2])
		local panelWidth = this.CCPanel_mc.origins_mc.width
		--x = this.PanelButtonX
		x = this.CCPanel_mc.x + this.CCPanel_mc.armourBtnHolder_mc.x + this.CCPanel_mc.armourBtnHolder_mc.helmetBtn_mc.x
		y = this.CCPanel_mc.y + this.CCPanel_mc.origins_mc.height - 224
		--y = this.CCPanel_mc.y + this.CCPanel_mc.origins_mc.height - 225
		--local widthDiff = this.stage.stageWidth - uiExt.stage.stageWidth
		--x = x + ((panelWidth/2) - (319.75/2))
		Ext.Dump({
			x = x,
			y = y,	
			panelWidth = panelWidth,
			widthDiff = widthDiff,
			["this.CCPanel_mc.x"] = this.CCPanel_mc.x,
			CC_screenWidth = this.screenWidth,
			UIExt_screenWidth = uiExt.screenWidth,
			PanelButtonX = this.PanelButtonX,
			CC = inst,
			UIExtensions = extInst
		})
	end
	local presets = {}
	for k,v in pairs(PresetData) do
		presets[#presets+1] = {
			Label = Ext.L10N.GetTranslatedString(v.ClassName, k),
			ID = PresetToID[k]
		}
	end
	table.sort(presets, function (a,b)
		return a.Label < b.Label
	end)

	uiExt.presetButton.x = x
	uiExt.presetButton.y = y
	uiExt.presetButton.setText("Set Preset")
	uiExt.togglePresetButton(true);
	--local dropdown_mc = UIExtensions.AddDropdown(OnPresetSelected, x, y, {Dropdown = "Presets", Tooltip = "Select a Class Preset"}, presets)
	for i=1,#presets do
		local entry = presets[i]
		print(uiExt.presetButton.addEntry(entry.Label, entry.ID))
	end

	local player = GameHelpers.Client.GetCharacterCreationCharacter(this)
	if player and player.PlayerCustomData and player.PlayerCustomData.ClassType then
		local id = PresetToID[player.PlayerCustomData.ClassType]
		uiExt.presetButton.selectItemByID(id)
	end
end

RegisterListener("RegionChanged", function (region, state, levelType)
	if levelType == LEVELTYPE.CHARACTER_CREATION then
		if state ~= REGIONSTATE.ENDED then
			BuildPresetData()
			CreatePresetDropdown()
		else
			UIExtensions.Root.togglePresetButton(false, true);
		end
		local this = CharacterCreation.Root
		if this then

		end
	end
end)