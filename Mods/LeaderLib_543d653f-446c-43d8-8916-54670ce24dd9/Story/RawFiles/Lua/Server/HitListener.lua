local function OnHit(target, source, handle, damage)
	local skillprototype = NRD_StatusGetString(target, handle, "SkillId")
	if skillprototype ~= "" and skillprototype ~= nil then
		OnSkillHit(source, skillprototype, target, handle, damage)
	end


end
Ext.NewCall(OnHit, "LeaderLib_Ext_OnHit", "(GUIDSTRING)_Target, (GUIDSTRING)_Source, (INTEGER)_Damage, (INTEGER64)_Handle")