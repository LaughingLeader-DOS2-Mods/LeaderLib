local self = CustomStatSystem
local isClient = Ext.IsClient()

if not isClient then
	Ext.RegisterNetListener("LeaderLib_CustomStatSystem_RequestValueChange", function(cmd, payload, user)
		local data = Common.JsonParse(payload)
		if data then
			local character = Ext.GetCharacter(data.NetID)
			if character then
				CustomStatSystem:SetStatByID(character, data.ID, data.Value, data.Mod)
				Ext.PostMessageToUser(user, "LeaderLib_CustomStatSystem_SyncSuccess", "")
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
		if not self.Syncing then
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
end