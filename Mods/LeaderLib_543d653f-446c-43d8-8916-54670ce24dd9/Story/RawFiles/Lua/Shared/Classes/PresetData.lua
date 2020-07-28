

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
function PresetData:AddEquipmentToCharacter(char, targetRarity, skipSlots)
	if Ext.IsServer() then
		local level = CharacterGetLevel(char)
		local equipment = self.Equipment
		
		if self.IsPreview then
			if self.Equipment_Preview == nil or self.Equipment_Preview == "" then
				for tag,suffix in pairs(previewRaceSuffixes) do
					if IsTagged(char, tag) == 1 then
						local racePreviewSet = self.Equipment.."_"..suffix
						local racePreviewEquipment = Ext.GetEquipmentSet(racePreviewSet)
						if racePreviewEquipment ~= nil and #racePreviewEquipment > 0 then
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
		
		local equipmentEntries = Ext.GetEquipmentSet(equipment)
		if equipmentEntries ~= nil then
			for i,statName in pairs(equipmentEntries) do
				local stat = Ext.GetStat(statName, level)
				local skip = false
				if skipSlots ~= nil and stat.Slot ~= nil then
					for i,slot in pairs(skipSlots) do
						if string.find(stat.Slot, slot) then
							skip = true
							break
						end
					end
				end
				if not skip then
					local item = GameHelpers.CreateItemByStat(stat, level, targetRarity, true, 1)
					if item ~= nil then
						ItemToInventory(item, char, 1, 0, 1)
						if ItemIsEquipable(item) == 1 then
							CharacterEquipItem(char, item)
						end
					end
				end
			end
		else
			Ext.PrintError("[LeaderLib] Failed to get equipment for", equipment, self.ClassType, self.Equipment, self.Equipment_Undead, self.IsPreview)
		end
	end
end

---Applies a preset's equipment and skillset to a character.
---This won't change a character's stats, talents, or delete their inventory like CharacterApplyPreset does.
---@param char string
---@param targetRarity string
---@param skipSlots string[] Skip generating equipment for these slots.
function PresetData:ApplyToCharacter(char, targetRarity, skipSlots)
	--print("Applying",self.ClassType,"to",char, Ext.IsServer(), Ext.OsirisIsCallable())
	if Ext.IsServer() then
		local status,err = xpcall(function()
			self:AddEquipmentToCharacter(char, targetRarity, skipSlots)
		end, debug.traceback)
		if not status then
			Ext.PrintError("[LeaderLib] Error applying preset",self.ClassType,"to character",char)
			Ext.PrintError(err)
		end
		local skills = Ext.GetSkillSet(self.SkillSet)
		if skills ~= nil then
			for i,skill in pairs() do
				CharacterAddSkill(char, skill, 0)
			end
		end
	end
end

---@return string[]
function PresetData:GetSkills()
	return Ext.GetSkillSet(self.SkillSet)
end

Classes["PresetData"] = PresetData