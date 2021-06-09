---@type target string
---@type source string
---@type damage integer
---@type handle integer
local function OnPrepareHit(target, source, damage, handle)
	local data = Classes.HitPrepareData:Create(handle, damage, target, source, false)
	if Features.FixChaosWeaponProjectileDamage then
		if data:IsBuggyChaosDamage() then
			local amount = data.DamageList.None
			data.DamageList.None = nil
			data.DamageList[data.DamageType] = amount
			NRD_HitClearDamage(handle, "None")
			NRD_HitAddDamage(handle, data.DamageType, amount)
			NRD_HitSetString(handle, "DamageType", "Chaos")
			data.DamageType = "Chaos"
		end
	end
	InvokeListenerCallbacks(Listeners.OnPrepareHit, target, source, damage, handle, data)
end

RegisterProtectedOsirisListener("NRD_OnPrepareHit", 4, "before", function(target, attacker, damage, handle)
	OnPrepareHit(StringHelpers.GetUUID(target), StringHelpers.GetUUID(attacker), damage, handle)
end)

function GameHelpers.ApplyBonusWeaponStatuses(source, target)
	if type(source) ~= "userdata" then
		source = Ext.GetGameObject(source)
	end
	if source and source.GetStatuses then
		for i,status in pairs(source:GetStatuses()) do
			if type(status) ~= "string" and status.StatusId ~= nil then
				status = status.StatusId
			end
			if not Data.EngineStatus[status] then
				local potion = nil
				if type(status) == "string" then
					potion = Ext.StatGetAttribute(status, "StatsId")
				elseif status.StatusId ~= nil then
					potion = Ext.StatGetAttribute(status.StatusId, "StatsId")
				end
				if potion ~= nil and potion ~= "" then
					local bonusWeapon = Ext.StatGetAttribute(potion, "BonusWeapon")
					if bonusWeapon ~= nil and bonusWeapon ~= "" then
						local extraProps = GameHelpers.Stats.GetExtraProperties(bonusWeapon)
						if extraProps and #extraProps > 0 then
							GameHelpers.ApplyProperties(source, target, extraProps)
						end
					end
				end
			end
		end
	end
end

---@param hitStatus EsvStatusHit
---@param context HitContext
Ext.RegisterListener("StatusHitEnter", function(hitStatus, context)
	local target,source = Ext.GetGameObject(hitStatus.TargetHandle),Ext.GetGameObject(hitStatus.StatusSourceHandle)

	if not target or not source then
		return
	end

	---@type HitRequest
	local hit = context.Hit or hitStatus.Hit
	if Vars.DebugMode then
		fprint(LOGLEVEL.TRACE, "[%s] hit.HitWithWeapon(%s) hit.Equipment(%s) context.Weapon(%s)", context.HitId, hit.HitWithWeapon, hit.Equipment, context.Weapon)
		fprint(LOGLEVEL.TRACE, "hit.DamageType(%s) hit.TotalDamageDone(%s) DamageList:\n%s", hit.DamageType, hit.TotalDamageDone, Ext.JsonStringify(hit.DamageList:ToTable()))
	end

	local skillId = not StringHelpers.IsNullOrWhitespace(hitStatus.SkillId) and string.gsub(hitStatus.SkillId, "_%-?%d+$", "") or nil
	local skill = nil
	if skillId then
		skill = Ext.GetStat(skillId)
		OnSkillHit(skill, target, source, hit.TotalDamageDone, hit, context, hitStatus)
	end

	if Features.ApplyBonusWeaponStatuses == true and source then
		if GameHelpers.Hit.IsFromWeapon(hitStatus, skill) then
			GameHelpers.ApplyBonusWeaponStatuses(source, target)
		end
	end

	if Vars.DebugMode then
		local wpn = hitStatus.WeaponHandle and Ext.GetItem(hitStatus.WeaponHandle) or nil
		fprint(LOGLEVEL.DEFAULT, "[StatusHitEnter:%s] Damage(%s) HitReason[%s](%s) DamageSourceType(%s) WeaponHandle(%s) Skill(%s)", context.HitId, hit.TotalDamageDone, hitStatus.HitReason, Data.HitReason[hitStatus.HitReason] or "", hitStatus.DamageSourceType, wpn and wpn.DisplayName or "nil", skillId or "nil")
	end


	--Old listener
	InvokeListenerCallbacks(Listeners.OnHit, target.MyGuid, source.MyGuid, hit.TotalDamageDone, context.HitId, skillId, hitStatus, context)
	InvokeListenerCallbacks(Listeners.StatusHitEnter, target, source, hit.TotalDamageDone, hit, context, hitStatus, skill)
end)

---@type target string
---@type source string
---@type damage integer
---@type handle integer
local function OnHit(target, source, damage, handle)
	if ObjectExists(target) == 0 then
		return
	end

	---@type EsvStatusHit
	local hitStatus = nil
	if ObjectIsCharacter(target) == 1 then
		---@type EsvStatusHit
		hitStatus = Ext.GetStatus(target, handle)
	else
		local item = Ext.GetItem(target)
		if item then
			hitStatus = item:GetStatus("HIT")
		end
	end

	if hitStatus == nil then
		return
	end

	local skillprototype = hitStatus.SkillId
	local skill = nil
	if not StringHelpers.IsNullOrEmpty(hitStatus.SkillId) then
		skill = string.gsub(hitStatus.SkillId, "_%-?%d+$", "")
		OnSkillHit(source, skill, target, handle, damage)
	end

	if Features.ApplyBonusWeaponStatuses == true and source ~= nil then
		if GameHelpers.Hit.IsFromWeapon(hitStatus, skill) then
			GameHelpers.ApplyBonusWeaponStatuses(source, target)
		end
	end

	InvokeListenerCallbacks(Listeners.OnHit, target, source, damage, handle, skill)
end

-- RegisterProtectedOsirisListener("NRD_OnHit", 4, "before", function(target, attacker, damage, handle)
-- 	OnHit(StringHelpers.GetUUID(target), StringHelpers.GetUUID(attacker), damage, handle)
-- end)