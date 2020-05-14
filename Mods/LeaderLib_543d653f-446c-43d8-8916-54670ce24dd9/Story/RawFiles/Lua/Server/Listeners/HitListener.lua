local function OnHit(target, source, damage, handle)
	local skillprototype = NRD_StatusGetString(target, handle, "SkillId")
	if skillprototype ~= "" and skillprototype ~= nil then
		OnSkillHit(source, skillprototype, target, handle, damage)
	end

	if source ~= nil and Features.ApplyBonusWeaponStatuses == true and Game.HitWithWeapon(target, handle) then
		--PrintDebug("Basic Attack Hit on", target, ". Checking for statuses with a BonusWeapon")
		---@type EsvCharacter
		local character = Ext.GetCharacter(source)
		for i,status in pairs(character:GetStatuses()) do
			if NRD_StatAttributeExists(status, "StatsId") == 1 then
				local potion = Ext.StatGetAttribute(status, "StatsId")
				if potion ~= nil and potion ~= "" then
					local bonusWeapon = Ext.StatGetAttribute(potion, "BonusWeapon")
					if bonusWeapon ~= nil and bonusWeapon ~= "" then
						local extraProps = Ext.StatGetAttribute(bonusWeapon, "ExtraProperties")
						if extraProps ~= nil then
							Game.ApplyProperties(target, source, extraProps)
						end
					end
				end
			end
		end
	end

	if #Listeners.OnHit > 0 then
		for i,callback in ipairs(Listeners.OnHit) do
			local status,err = xpcall(callback, debug.traceback, target, source, damage, handle)
			if not status then
				Ext.PrintError("Error calling function for 'OnHit':\n", err)
			end
		end
	end
end
Ext.NewCall(OnHit, "LeaderLib_Ext_OnHit", "(GUIDSTRING)_Target, (GUIDSTRING)_Source, (INTEGER)_Damage, (INTEGER64)_Handle")