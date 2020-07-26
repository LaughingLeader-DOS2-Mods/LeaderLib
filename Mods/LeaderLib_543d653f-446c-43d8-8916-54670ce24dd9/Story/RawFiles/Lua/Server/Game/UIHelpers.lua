local MessageData = Classes.MessageData

function SetSlotEnabled(client, slot, enabled)
	Ext.PostMessageToClient(client, "LeaderLib_Hotbar_SetSlotEnabled", MessageData:CreateFromTable("SetSlotEnabled", {
		Slot = slot,
		Enabled = enabled,
		UUID = client
	}):ToString())
end

function SetSkillEnabled(client, skill, enabled)
	if type(enabled) == "string" then
		enabled = enabled == "true" or enabled == "1"
	end
	local slots = GetSkillSlots(client, skill)
	if #slots > 0 then
		Ext.PostMessageToClient(client, "LeaderLib_Hotbar_SetSlotEnabled", MessageData:CreateFromTable("SetSlotEnabled", {
			Slots = slots,
			Enabled = enabled,
			UUID = client
		}):ToString())
	end
end