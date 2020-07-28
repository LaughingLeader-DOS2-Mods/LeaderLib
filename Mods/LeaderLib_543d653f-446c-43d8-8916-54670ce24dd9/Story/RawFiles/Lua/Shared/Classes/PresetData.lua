

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
---@return PresetData
function PresetData:Create(id,equipment,skillset,undeadEquipment,previewEquipment)
    local this =
    {
		ClassType = id,
		Equipment = equipment,
		Equipment_Undead = undeadEquipment or "",
		Equipment_Preview = previewEquipment or nil,
		SkillSet = skillset,
		isPreview = previewEquipment ~= nil,
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
---@return PresetData
function PresetData:ApplyToCharacter(char, targetRarity)
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
			if IsTagged(char, "UNDEAD") == 1 or CharacterHasTalent(char, "ZOMBIE") == 1 then
				equipment = self.Equipment_Undead
			end
		end

		for i,stat in pairs(Ext.GetEquipmentSet(equipment)) do
			local item = GameHelpers.CreateItemByStat(stat, level, targetRarity, 1)
			if item ~= nil then
				ItemToInventory(item, char, 1, 0, 1)
				CharacterEquipItem(char, item)
			end
		end
		for i,skill in pairs(Ext.GetSkillSet(self.SkillSet)) do
			CharacterAddSkill(char, skill, 0)
		end
	end
end

Classes["PresetData"] = PresetData