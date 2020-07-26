local MessageData = Classes.MessageData

function SetSlotEnabled(client, slot, enabled)
	Ext.PostMessageToClient(client, "LeaderLib_Hotbar_SetSlotEnabled", MessageData:CreateFromTable("SetSlotEnabled", {
		Slot = slot,
		Enabled = enabled,
		UUID = client
	}):ToString())
end

function GetSkillSlots(client, skill, makeLocal)
	local slots = {}
	for i=0,144,1 do
		local slot = NRD_SkillBarGetSkill(client, i)
		if slot ~= nil and slot == skill then
			if makeLocal == true then
				slots[#slots+1] = i%29
			else
				slots[#slots+1] = i
			end
		end
	end
	return slots
end

function SetSkillEnabled(client, skill, enabled)
	local slots = GetSkillSlots(client, skill)
	if #slots > 0 then
		Ext.PostMessageToClient(client, "LeaderLib_Hotbar_SetSlotEnabled", MessageData:CreateFromTable("SetSlotEnabled", {
			Slots = slots,
			Enabled = enabled,
			UUID = client
		}):ToString())
	end
end