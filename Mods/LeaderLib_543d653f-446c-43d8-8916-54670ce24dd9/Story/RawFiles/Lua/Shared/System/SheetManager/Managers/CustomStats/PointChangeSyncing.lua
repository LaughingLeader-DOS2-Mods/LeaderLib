local self = CustomStatSystem
local isClient = Ext.IsClient()

---@private
---@param character EsvCharacter|EclCharacter
---@param stat SheetCustomStatData
function CustomStatSystem:SetStatValueOnCharacter(character, stat, value, skipSync)
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

		if not skipSync and not isClient then
			if Ext.OsirisIsCallable() then
				Timer.StartOneshot("CustomStatSystem_SyncValues", 2, function()
					CustomStatSystem:SyncData()
				end)
			else
				CustomStatSystem:SyncData()
			end
		end
	else
		character:SetCustomStat(stat.UUID, value)
	end
end

if not isClient then
	Ext.RegisterNetListener("LeaderLib_CustomStatSystem_RequestValueChange", function(cmd, payload, user)
		local data = Common.JsonParse(payload)
		if data then
			local character = Ext.GetCharacter(data.NetID)
			if character then
				CustomStatSystem:SetStatByID(character, data.ID, data.Value, data.Mod)
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