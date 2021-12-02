---@type target string
---@type source string
---@type damage integer
---@type handle integer
local function OnPrepareHit(target, source, damage, handle)
	local data = Classes.HitPrepareData:Create(handle, damage, target, source, true)
	if Features.FixChaosWeaponProjectileDamage and data:IsBuggyChaosDamage() then
		local amount = data.DamageList.None
		data.DamageList.None = nil
		data.DamageList[data.DamageType] = amount
		if Vars.DebugMode and Vars.Print.HitPrepare then
			fprint(LOGLEVEL.DEFAULT, "Fixing bad damage type in Chaos basic ranged attack None => %s (%s)", data.DamageType, amount)
		end
	end
	-- if Vars.DebugMode and (Vars.Print.HitPrepare or Vars.LeaderDebugMode) 
	-- and (Vars.Print.SpammyHits or (data.HitType ~= "Surface" --[[ and data.HitType ~= "DoT" ]])) then
	-- 	Ext.Print("[HitPrepareData]", data:ToDebugString())
	-- end
	InvokeListenerCallbacks(Listeners.OnPrepareHit, target, source, damage, handle, data)
end

RegisterProtectedOsirisListener("NRD_OnPrepareHit", 4, "before", function(target, attacker, damage, handle)
	OnPrepareHit(StringHelpers.GetUUID(target), StringHelpers.GetUUID(attacker), damage, handle)
end)

---@private
---@param uuid string
function GameHelpers.TrackBonusWeaponPropertiesApplied(uuid, skill)
	if not PersistentVars.JustAppliedBonusWeaponStatuses[uuid] or skill then
		PersistentVars.JustAppliedBonusWeaponStatuses[uuid] = skill or true
	end
	Timer.StartObjectTimer("LeaderLib_ClearJustAppliedBonusWeaponStatuses", uuid, 250)
end

Timer.RegisterListener("LeaderLib_ClearJustAppliedBonusWeaponStatuses", function(timerName, uuid)
	PersistentVars.JustAppliedBonusWeaponStatuses[uuid] = nil
end)

---@param source EsvCharacter|EsvItem|UUID|NETID
---@param target EsvCharacter|EsvItem|UUID|NETID
---@param fromSkill string If this is resulting from a skill hit.
function GameHelpers.ApplyBonusWeaponStatuses(source, target, fromSkill)
	if type(source) ~= "userdata" then
		source = GameHelpers.TryGetObject(source)
	end
	if source and source.GetStatuses then
		if PersistentVars.JustAppliedBonusWeaponStatuses[source.MyGuid] == true 
		or (fromSkill and PersistentVars.JustAppliedBonusWeaponStatuses[source.MyGuid] == fromSkill) then
			return false
		end
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
					if not Ext.OsirisIsCallable() or NRD_StatExists(potion) then
						local bonusWeapon = Ext.StatGetAttribute(potion, "BonusWeapon")
						if bonusWeapon ~= nil and bonusWeapon ~= "" then
							local extraProps = GameHelpers.Stats.GetExtraProperties(bonusWeapon)
							if extraProps and #extraProps > 0 then
								GameHelpers.ApplyProperties(source, target, extraProps, nil, nil, fromSkill)
							end
						end
					end
				end
			end
		end
	end
end

---@return EsvCharacter|EsvItem
local function TryGetObject(data, property)
	local b,result = xpcall(function()
		local b2,result2 = xpcall(Ext.GetGameObject, debug.traceback, data[property])
		if b2 then
			return result2
		else
			fprint(LOGLEVEL.ERROR, "[LeaderLib] Error calling Ext.GetGameObject:\n%s", result2)
		end
	end, debug.traceback)
	if b then
		return result
	else
		fprint(LOGLEVEL.ERROR, "[LeaderLib] Error calling Ext.GetGameObject:\n%s", result)
	end
end

---@param hitStatus EsvStatusHit
---@param context HitContext
RegisterProtectedExtenderListener("StatusHitEnter", function(hitStatus, hitContext)
	local target,source = TryGetObject(hitStatus, "TargetHandle"),TryGetObject(hitStatus, "StatusSourceHandle")

	if not target then
		return
	end

	local targetId = GameHelpers.GetUUID(target, true)
	local sourceId = GameHelpers.GetUUID(source, true)

	local applySkillProperties = Vars.ApplyZoneSkillProperties[hitStatus.SkillId]
	if applySkillProperties and applySkillProperties[sourceId] then
		Ext.ExecuteSkillPropertiesOnTarget(hitStatus.SkillId, sourceId, targetId, target.WorldPos, "Target", GameHelpers.Ext.ObjectIsItem(source))
		Timer.RestartOneShot(applySkillProperties[sourceId], 1)
	end

	---@type HitRequest
	local hitRequest = hitContext.Hit or hitStatus.Hit

	local skillId = not StringHelpers.IsNullOrWhitespace(hitStatus.SkillId) and string.gsub(hitStatus.SkillId, "_%-?%d+$", "") or nil
	local skill = skillId and Ext.GetStat(skillId) or nil

	local data = Classes.HitData:Create(target, source, hitStatus, hitContext, hitRequest, skill)

	if skillId then
		OnSkillHit(skill, target, source, hitRequest.TotalDamageDone, hitRequest, hitContext, hitStatus, data)
	end

	if Features.ApplyBonusWeaponStatuses == true and source then
		if skill then
			local canApplyStatuses = skill.UseWeaponProperties == "Yes"
			if canApplyStatuses then
				GameHelpers.ApplyBonusWeaponStatuses(source, target, skillId)
			end
		elseif GameHelpers.Hit.IsFromWeapon(hitStatus) then
			GameHelpers.ApplyBonusWeaponStatuses(source, target)
		end
	end

	-- if Vars.LeaderDebugMode then
	-- 	local dataString = "local data = " .. Lib.serpent.block({
	-- 		EsvStatusHit = hitStatus,
	-- 		HitContext = hitContext, 	
	-- 	})
	-- 	if skill then
	-- 		Ext.SaveFile(string.format("Logs/HitTracing/%s_%s.lua", skill.Name, Ext.MonotonicTime()), dataString)
	-- 	else
	-- 		Ext.SaveFile(string.format("Logs/HitTracing/%s_%s.lua", hitStatus.DamageSourceType, Ext.MonotonicTime()), dataString)
	-- 	end
	-- 	--Ext.Print("hitStatus", getmetatable(hitStatus), Lib.serpent.block(hitStatus))
	-- 	--Ext.Print("hitContext", getmetatable(hitContext), hitContext, Lib.serpent.block(hitContext))
	-- end

	if Vars.DebugMode and Vars.Print.Hit then
		local wpn = hitStatus.WeaponHandle and Ext.GetItem(hitStatus.WeaponHandle) or nil
		fprint(LOGLEVEL.DEFAULT, "[StatusHitEnter:%s] Damage(%s) HitReason[%s](%s) DamageSourceType(%s) WeaponHandle(%s) Skill(%s)", hitContext.HitId, hitRequest.TotalDamageDone, hitStatus.HitReason, Data.HitReason[hitStatus.HitReason] or "", hitStatus.DamageSourceType, wpn and wpn.DisplayName or "nil", skillId or "nil")
		fprint(LOGLEVEL.TRACE, "hitRequest.HitWithWeapon(%s) hitRequest.Equipment(%s) hitContext.Weapon(%s), hitRequest.LifeSteal(%s)", hitRequest.HitWithWeapon, hitRequest.Equipment, hitContext.Weapon, hitRequest.LifeSteal)
		fprint(LOGLEVEL.TRACE, "hitRequest.DamageType(%s) hitRequest.TotalDamageDone(%s) DamageList:\n%s", hitRequest.DamageType, hitRequest.TotalDamageDone, Lib.inspect(hitRequest.DamageList:ToTable()))
	end

	InvokeListenerCallbacks(Listeners.StatusHitEnter, target, source, data, hitStatus)
	--Old listener
	InvokeListenerCallbacks(Listeners.OnHit, targetId, sourceId, hitRequest.TotalDamageDone, hitStatus.StatusHandle, skillId, hitStatus, hitContext, data)
end)