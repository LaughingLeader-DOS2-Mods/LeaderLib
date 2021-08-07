local self = CustomStatSystem
local isClient = Ext.IsClient()

---@private
---@param character EsvCharacter|EclCharacter
---@param stat CustomStatData
function CustomStatSystem:SetStatValueOnCharacter(character, stat, value)
	if not self:GMStatsEnabled() then
		local last = stat:GetLastValue(character)
		local characterId = GameHelpers.GetCharacterID(character)
		if not self.CharacterStatValues[characterId] then
			self.CharacterStatValues[characterId] = {}
		end
		if not self.CharacterStatValues[characterId][stat.Mod] then
			self.CharacterStatValues[characterId][stat.Mod] = {}
		end
		self.CharacterStatValues[characterId][stat.Mod][stat.ID] = value
		if last and value ~= last then
			CustomStatSystem:InvokeStatValueChangedListeners(stat, character, last, value)
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
		local characterId = GameHelpers.GetCharacterID(character)
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
	Ext.RegisterNetListener("LeaderLib_CustomStatSystem_RequestValueChange", function(cmd, payload, user)
		print(cmd, payload, user)
		local data = Common.JsonParse(payload)
		if data then
			local character = Ext.GetCharacter(data.NetID)
			if character then
				Ext.PostMessageToClient(character.MyGuid, "LeaderLib_CustomStatSystem_SyncSuccess", "")
				CustomStatSystem:SetStat(character, data.ID, data.Value, data.Mod)
			end
		end
	end)
else
	Ext.RegisterNetListener("LeaderLib_CustomStatSystem_SyncSuccess", function(cmd, payload)
		self.Syncing = false
	end)

	---@private
	---@param character EsvCharacter|UUID|NETID
	---@param statId string A stat id.
	---@param value integer The value to set the stat to.
	---@param mod string|nil A mod UUID to use when fetching the stat by ID.
	function CustomStatSystem:RequestValueChange(character, statId, value, mod)
		self.Syncing = true
		local netid = GameHelpers.GetNetID(character)
		Ext.PostMessageToServer("LeaderLib_CustomStatSystem_RequestValueChange", Ext.JsonStringify({
			ID = statId,
			Mod = mod or "",
			NetID = netid,
			Value = value
		}))
	end
end