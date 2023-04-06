if HotbarFixer == nil then
	HotbarFixer = {}
end

if Vars.IsClient then
	local slotArrayMap = {
		slotNum = {Index=0, Type="number"},
		amount = {Index=1, Type="number"},
		tooltip = {Index=2, Type="string"},
		isEnabled = {Index=3, Type="boolean"},
		handle = {Index=4, Type="number"},
		slotType = {Index=5, Type="number"},
		visible = {Index=6, Type="boolean"},
	}

	local disabledTagSkills = {}

	---@param ui UIObject
	local function OnHotbarUpdating(ui)
		local character = Client:GetCharacter()
		if not character or not Features.FixSkillTagRequirements then
			return
		end
		disabledTagSkills[character.NetID] = {}

		local this = ui:GetRoot()
		local slotholder_mc = this.hotbar_mc.slotholder_mc
		local arr = this.slotUpdateList
		local length = #arr
		local i = 0
		while i < length do
			--local slotNum = arr[i]
			local skillId = arr[i+2]
			if not StringHelpers.IsNullOrEmpty(skillId) 
			and string.find(skillId, "_") 
			and not GameHelpers.Stats.IsAction(skillId) then
				--IsEnabled
				if arr[i+3] == true then
					---@type StatEntrySkillData
					local skillData = Ext.Stats.Get(skillId, nil, false)
					if skillData then
						local isDisabled = false
						for _,prop in pairs(skillData.Requirements) do
							if prop.Requirement == "Tag" then
								if character:HasTag(prop.Param) == prop.Not then
									isDisabled = true
									break
								end
							end
						end
						if isDisabled then
							disabledTagSkills[character.NetID][skillId] = true
							arr[i+3] = false
						else
							disabledTagSkills[character.NetID][skillId] = nil
						end
					end
				end
			end
			i = i + 7
		end
	end

	Ext.RegisterUITypeInvokeListener(Data.UIType.hotBar, "updateSlots", OnHotbarUpdating)

	local function HasTagElement(tooltip, tagName)
		for i,v in pairs(tooltip:GetElements("SkillRequiredEquipment")) do
			if string.find(v.Label, tagName) then
				return true
			end
		end
		return false
	end

	---@param character EclCharacter
	---@param skill string
	---@param tooltip TooltipData
	function HotbarFixer.UpdateSkillRequirements(character, skill, tooltip)
		if not Features.FixSkillTagRequirements then
			return
		end
		local disabledTagSkillData = disabledTagSkills[character.NetID]
		if disabledTagSkillData and disabledTagSkillData[skill] then
			---@type StatEntrySkillData
			local skillData = Ext.Stats.Get(skill, nil, false)
			for _,prop in pairs(skillData.Requirements) do
				if prop.Requirement == "Tag" then
					local tagName = GameHelpers.GetStringKeyText(prop.Param)
					if not HasTagElement(tooltip, tagName) then
						tooltip:AppendElement({
							Type = "SkillRequiredEquipment",
							Label = LocalizedText.Tooltip.Requires:ReplacePlaceholders(tagName),
							RequirementMet = character:HasTag(prop.Param),
						})
					end
				end
			end
		end
	end
else
	RegisterProtectedOsirisListener("ObjectWasTagged", 2, "after", function(uuid, tag)
		if Osi.ObjectIsCharacter(uuid) == 1
		and Osi.CharacterIsControlled(uuid) == 1
		and Features.FixSkillTagRequirements
		and Data.SkillRequirementTags[tag] then
			--Delay slightly to aggregate quick changes
			GameHelpers.UI.RefreshSkillBarAfterDelay(uuid, 50)
		end
	end)
	RegisterProtectedOsirisListener("ObjectLostTag", 2, "after", function(uuid, tag)
		if Osi.ObjectIsCharacter(uuid) == 1
		and Osi.CharacterIsControlled(uuid) == 1
		and Features.FixSkillTagRequirements
		and Data.SkillRequirementTags[tag] then
			GameHelpers.UI.RefreshSkillBarAfterDelay(uuid, 50)
		end
	end)

	RegisterProtectedOsirisListener("ItemEquipped", Data.OsirisEvents.ItemEquipped, "after", function(item,character)
		if Osi.ObjectExists(character) == 0 or Osi.ObjectExists(item) == 0 then
			return
		end
		if Osi.ObjectIsCharacter(character) == 1
		and Osi.CharacterIsControlled(character) == 1
		and Features.FixSkillTagRequirements then
			local item = GameHelpers.GetItem(item)
			if item and not StringHelpers.IsNullOrWhitespace(item.Stats.Tags) then
				local tags = StringHelpers.Split(item.Stats.Tags, ";")
				for i,tag in pairs(tags) do
					if Data.SkillRequirementTags[tag] then
						--Delay slightly to aggregate quick changes
						GameHelpers.UI.RefreshSkillBarAfterDelay(character, 250)
						break
					end
				end
			end
		end
	end)
	RegisterProtectedOsirisListener("ItemUnEquipped", Data.OsirisEvents.ItemUnEquipped, "after", function(item,character)
		if Osi.ObjectExists(character) == 0 or Osi.ObjectExists(item) == 0 then
			return
		end
		if Osi.ObjectIsCharacter(character) == 1
		and Osi.CharacterIsControlled(character) == 1
		and Features.FixSkillTagRequirements then
			local item = GameHelpers.GetItem(item)
			if item and not StringHelpers.IsNullOrWhitespace(item.Stats.Tags) then
				local tags = StringHelpers.Split(item.Stats.Tags, ";")
				for i,tag in pairs(tags) do
					if Data.SkillRequirementTags[tag] and Osi.IsTagged(character, tag) ~= 1 then
						GameHelpers.UI.RefreshSkillBarAfterDelay(character, 250)
						break
					end
				end
			end
		end
	end)

	Ext.Events.SessionLoaded:Subscribe(function()
		for skill in GameHelpers.Stats.GetSkills(true) do
			for _,prop in pairs(skill.Requirements) do
				if prop.Requirement == "Tag" then
					if not Data.SkillRequirementTags[prop.Param] then
						Data.SkillRequirementTags[prop.Param] = {}
					end
					Data.SkillRequirementTags[prop.Param][skill.Name] = true
				end
			end
		end
	end)
end