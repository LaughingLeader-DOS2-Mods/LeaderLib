---@type target string
---@type source string
---@type damage integer
---@type handle integer
local function OnPrepareHit(target, source, damage, handle)
	-- if Vars.DebugMode then
	-- 	Ext.Print(string.format("[NRD_OnPrepareHit] Target(%s) Source(%s) damage(%i) Handle(%s) HitType(%s)", target, source, damage, handle, NRD_HitGetString(handle, "HitType")))
	-- 	--Debug_TraceHitPrepare(target, source, damage, handle)
	-- end
	InvokeListenerCallbacks(Listeners.OnPrepareHit, target, source, damage, handle)
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
							GameHelpers.ApplyProperties(GameHelpers.GetUUID(target), GameHelpers.GetUUID(source), extraProps)
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
	fprint(LOGLEVEL.TRACE, "context.Hit(%s) hitStatus.Hit(%s) context.HitId(%s)", context.Hit, hitStatus.Hit, context.HitId)

	local skillId = not StringHelpers.IsNullOrWhitespace(hitStatus.SkillId) and string.gsub(hitStatus.SkillId, "_%-?%d+$", "") or nil
	local skill = nil
	if skillId then
		skill = Ext.GetStat(skillId)
		OnSkillHit(skill, target, source, hit.TotalDamageDone, hit, context, hitStatus)
	end

	if Features.ApplyBonusWeaponStatuses == true and source ~= nil then
		if skill then
			if skill.UseWeaponProperties == "Yes" and GameHelpers.Hit.IsFromWeapon(hitStatus, true) then
				GameHelpers.ApplyBonusWeaponStatuses(source, target)
			end
		else
			if GameHelpers.Hit.IsFromWeapon(hitStatus) then
				GameHelpers.ApplyBonusWeaponStatuses(source, target)
			end
		end
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
	local statusObj = nil
	if ObjectIsCharacter(target) == 1 then
		---@type EsvStatusHit
		statusObj = Ext.GetStatus(target, handle)
	else
		local item = Ext.GetItem(target)
		if item then
			statusObj = item:GetStatus("HIT")
		end
	end

	if statusObj == nil then
		return
	end

	local skillprototype = statusObj.SkillId
	local skill = nil
	if not StringHelpers.IsNullOrEmpty(statusObj.SkillId) then
		skill = string.gsub(statusObj.SkillId, "_%-?%d+$", "")
		OnSkillHit(source, skill, target, handle, damage)
	end

	if Features.ApplyBonusWeaponStatuses == true and not StringHelpers.IsNullOrEmpty(source) then
		if skill ~= nil then
			if Ext.StatGetAttribute(skill, "UseWeaponProperties") == "Yes" and GameHelpers.Hit.IsFromWeapon(statusObj, true) then
				GameHelpers.ApplyBonusWeaponStatuses(source, target)
			end
		else
			if GameHelpers.Hit.IsFromWeapon(statusObj) then
				GameHelpers.ApplyBonusWeaponStatuses(source, target)
			end
		end
	end

	InvokeListenerCallbacks(Listeners.OnHit, target, source, damage, handle, skill)
end

-- RegisterProtectedOsirisListener("NRD_OnHit", 4, "before", function(target, attacker, damage, handle)
-- 	OnHit(StringHelpers.GetUUID(target), StringHelpers.GetUUID(attacker), damage, handle)
-- end)