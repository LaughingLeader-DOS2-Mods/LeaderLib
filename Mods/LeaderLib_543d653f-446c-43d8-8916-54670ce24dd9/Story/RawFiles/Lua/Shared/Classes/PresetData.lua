

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
function PresetData:Create(id,equipment,skillset,undeadEquipment, isPreview, previewEquipment)
    local this =
    {
		ClassType = id,
		Equipment = equipment,
		Equipment_Undead = undeadEquipment or "",
		Equipment_Preview = previewEquipment or nil,
		SkillSet = skillset,
		isPreview = isPreview or false,
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

---Applies a preset's equipment and skillset to a character.
---This won't change a character's stats, talents, or delete their inventory like CharacterApplyPreset does.
---@param char string
---@param targetRarity string
---@param skipSlots string[] Skip generating equipment for these slots.
---@return PresetData
function PresetData:ApplyToCharacter(char, targetRarity, skipSlots)
	if Ext.IsServer() and Ext.OsirisIsCallable() then
		local level = CharacterGetLevel(char)
		local equipment = self.Equipment

		if self.IsPreview then
			if self.Equipment_Preview == nil then
				for tag,suffix in pairs(previewRaceSuffixes) do
					if IsTagged(char, tag) == 1 then
						local racePreviewEquipment = Ext.GetEquipmentSet(self.Equipment .. suffix)
						if racePreviewEquipment ~= nil and #racePreviewEquipment > 0 then
							equipment = racePreviewEquipment
							break
						end
					end
				end
			else
				equipment = self.Equipment_Preview
			end
		else
			if IsTagged(char, "UNDEAD") == 1 or CharacterHasTalent(char, "Zombie") == 1 then
				equipment = self.Equipment_Undead
			end
		end

		for i,statName in pairs(Ext.GetEquipmentSet(equipment)) do
			local stat = Ext.GetStat(statName, level)
			local skip = false
			if skipSlots ~= nil and stat.Slot ~= nil then
				for i,slot in pairs(skipSlots) do
					if stat.Slot == slot then
						skip = true
					break
				end
			end
			if not skip then
				local item = GameHelpers.CreateItemByStat(stat, level, targetRarity, 1)
				if item ~= nil then
					ItemToInventory(item, char, 1, 0, 1)
					CharacterEquipItem(char, item)
				end
			end
		end
		for i,skill in pairs(Ext.GetSkillSet(self.SkillSet)) do
			CharacterAddSkill(char, skill, 0)
		end
	end
end

Classes["PresetData"] = PresetData