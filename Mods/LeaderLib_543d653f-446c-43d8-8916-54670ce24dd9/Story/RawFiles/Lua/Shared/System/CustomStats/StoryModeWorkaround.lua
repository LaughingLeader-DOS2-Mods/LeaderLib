local self = CustomStatSystem
local isClient = Ext.IsClient()

---@private
---@param character EsvCharacter|EclCharacter
---@param stat CustomStatData
function CustomStatSystem:SetStatValueOnCharacter(character, stat, value)
	if not self:GMStatsEnabled() then
		local characterId = character
		if not isClient then
			characterId = GameHelpers.GetUUID(character)
		else
			characterId = GameHelpers.GetNetID(character)
		end
		if not isClient then
			if not self.CharacterStatValues[characterId] then
				self.CharacterStatValues[characterId] = {}
			end
			if not self.CharacterStatValues[characterId][stat.Mod] then
				self.CharacterStatValues[characterId][stat.Mod] = {}
			end
			self.CharacterStatValues[characterId][stat.Mod][stat.ID] = value
		else
			Ext.PostMessageToServer("LeaderLib_CustomStatSystem_SaveStatValue", {
				Character = characterId,
				Stat = stat.ID,
				Mod = stat.Mod,
				Value = value
			})
		end
	else
		character:SetCustomStat(stat.UUID, value)
	end
end

---@private
---@param character EsvCharacter|EclCharacter
---@param stat CustomStatData
---@return integer
function CustomStatSystem:GetStatValueOnCharacter(character, stat)
	if not self:GMStatsEnabled() then
		local characterId = character
		if not isClient then
			characterId = GameHelpers.GetUUID(character)
		else
			characterId = GameHelpers.GetNetID(character)
		end
		if self.CharacterStatValues[characterId] then
			if self.CharacterStatValues[characterId][stat.Mod] then
				return self.CharacterStatValues[characterId][stat.Mod][stat.ID] or 0
			end
		end
		return 0
	else
		return character:GetCustomStat(stat.UUID) or 0
	end
end

if not isClient then
	Ext.RegisterNetListener("LeaderLib_CustomStatSystem_SaveStatValue", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			local character = Ext.GetCharacter(data.Character)
			local stat = CustomStatSystem:GetStatByID(data.Stat, data.Mod)
			if character and stat then
				CustomStatSystem:SetStatValueOnCharacter(character, stat, data.Value)
			end
		end
	end)
end