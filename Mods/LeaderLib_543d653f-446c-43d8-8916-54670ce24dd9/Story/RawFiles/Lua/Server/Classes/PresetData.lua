

---@class PresetData
local PresetData = {
	ClassType = "",
	Equipment = "",
	Equipment_Undead = "",
	Equipment_Preview = nil,
	SkillSet = "",
	IsPreview = false,
}
PresetData.__index = PresetData

---@param id string
---@param equipment string
---@param skillset string
---@param undeadEquipment string Optional undead equipment to use.
---@param isPreview boolean Whether this preset should use preview equipment. If previewEquipment is nil or blank, it will try to find the equipment string from the regular equipment + race suffix.
---@param previewEquipment string Optional preview equipment 
---@return PresetData
function PresetData:Create(id, equipment, skillset, undeadEquipment, isPreview, previewEquipment)
	local this =
	{
		ClassType = id,
		Equipment = equipment,
		Equipment_Undead = undeadEquipment or equipment,
		Equipment_Preview = previewEquipment or "",
		SkillSet = skillset,
		IsPreview = isPreview or false,
	}
	if undeadEquipment == nil or undeadEquipment == "" then
		this.Equipment_Undead = this.Equipment
	end
	setmetatable(this, self)
	return this
end

local previewRaceSuffixes = {
	HUMAN = "Humans",
	ELF = "Elves",
	DWARF = "Dwarves",
	LIZARD = "Lizards",
}

---Applies a preset's equipment to a character.
---This won't change a character's stats, talents, or delete their inventory like CharacterApplyPreset does.
---@param char string
---@param targetRarity string
---@param skipSlots string[] Skip generating equipment for these slots.
---@param skipIfExists boolean If an item already exists on the target character, skip creating another one.
function PresetData:AddEquipmentToCharacter(char, targetRarity, skipSlots, skipIfExists)
	if Ext.IsServer() then
		local level = CharacterGetLevel(char)
		local equipment = self.Equipment
		local presetItemStatProperties = {
			Amount = 1,
			IsIdentified = true, 
			StatsLevel = level, 
			GenerationLevel = level, 
			ItemType = targetRarity,
			GenerationItemType = targetRarity,
			HasGeneratedStats = true
		}
		if self.IsPreview then
			if self.Equipment_Preview == nil or self.Equipment_Preview == "" then
				for tag,suffix in pairs(previewRaceSuffixes) do
					if IsTagged(char, tag) == 1 then
						local racePreviewSet = self.Equipment.."_"..suffix
						local racePreviewEquipment = Ext.GetEquipmentSet(racePreviewSet)
						if racePreviewEquipment ~= nil and #racePreviewEquipment.Groups > 0 then
							equipment = racePreviewSet
							break
						end
					end
				end
			else
				equipment = self.Equipment_Preview
			end
		elseif self.Equipment_Undead ~= nil and self.Equipment_Undead ~= "" and IsTagged(char, "UNDEAD") == 1 or CharacterHasTalent(char, "Zombie") == 1 then
			equipment = self.Equipment_Undead
		end
		
		local eq = Ext.GetEquipmentSet(equipment)
		if eq ~= nil then
			for i,v in pairs(eq.Groups) do
				local stat = Ext.GetStat(v.Equipment[1], level)
				if stat ~= nil then
					local skip = false
					if skipSlots ~= nil and stat.Slot ~= nil then
						for i,slot in pairs(skipSlots) do
							if string.find(stat.Slot, slot) then
								skip = true
								break
							end
						end
					end
					---@type ItemDefinition
					local props = Common.CloneTable(presetItemStatProperties)
					if skipIfExists == true then
						local templates = GameHelpers.Item.GetRootTemplatesForStat(stat.Name)
						if templates and #templates > 0 then
							local template = templates[1]
							if not StringHelpers.IsNullOrEmpty(template) then
								skip = ItemTemplateIsInCharacterInventory(char, template) > 0
								props.RootTemplate = template
								props.OriginalRootTemplate = template
							end
						end
					end
					if not skip then
						local item = GameHelpers.Item.CreateItemByStat(stat, presetItemStatProperties)
						if item ~= nil and ObjectExists(item) == 1 then
							ItemToInventory(item, char, 1, 0, 1)
							if ItemIsEquipable(item) == 1 then
								Osi.LeaderLib_Timers_StartCharacterItemTimer(char, item, 500, string.format("LLEG%s", item), "LeaderLib_Commands_EquipItem")
								--CharacterEquipItem(char, item)
								--NRD_CharacterEquipItem(char, item, stat.Slot, 0, 0, 1, 1)
							end
						end
					end
				end
			end
		else
			Ext.PrintError("[LeaderLib] Failed to get equipment for", equipment, self.ClassType, self.Equipment, self.Equipment_Undead, self.IsPreview)
		end
	end
end

---Applies a preset's skillset to a character, optionally checking that they have the memorization requirements for each skill.
---@param char string
---@param checkMemorizationRequirements boolean
function PresetData:AddSkillsToCharacter(char, checkMemorizationRequirements)
	local skillSet = Ext.GetSkillSet(self.SkillSet)
	if skillSet ~= nil then
		for i,v in pairs(skillSet.Skills) do
			if type(v) == "table" then
				for i,skill in pairs(v) do
					if checkMemorizationRequirements ~= true or GameHelpers.Skill.CanMemorize(char, skill) then
						CharacterAddSkill(char, skill, 0)
					end
				end
			elseif type(v) == "string" then
				if checkMemorizationRequirements ~= true or GameHelpers.Skill.CanMemorize(char, v) then
					CharacterAddSkill(char, v, 0)
				end
			end
		end
	end
end

---Applies a preset's equipment and skillset to a character.
---This won't change a character's stats, talents, or delete their inventory like CharacterApplyPreset does.
---@param char string
---@param targetRarity string
---@param skipSlots string[] Skip generating equipment for these slots.
---@param checkMemorizationRequirements boolean|nil
---@param skipIfExists boolean If an item already exists on the target character, skip creating another one.
function PresetData:ApplyToCharacter(char, targetRarity, skipSlots, checkMemorizationRequirements, skipIfExists)
	--print("Applying",self.ClassType,"to",char, Ext.IsServer(), Ext.OsirisIsCallable())
	if Ext.IsServer() then
		local status,err = xpcall(function()
			self:AddEquipmentToCharacter(char, targetRarity, skipSlots, skipIfExists)
		end, debug.traceback)
		if not status then
			Ext.PrintError("[LeaderLib] Error applying preset equipment",self.ClassType,"to character",char)
			Ext.PrintError(err)
		end
		local status,err = xpcall(function()
			self:AddSkillsToCharacter(char, checkMemorizationRequirements)
		end, debug.traceback)
		if not status then
			Ext.PrintError("[LeaderLib] Error applying preset skills",self.ClassType,"to character",char)
			Ext.PrintError(err)
		end
	end
end

---@return string[]
function PresetData:GetSkills()
	return Ext.GetSkillSet(self.SkillSet)
end

Classes.PresetData = PresetData