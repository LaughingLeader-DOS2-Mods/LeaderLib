local _EXTVERSION = Ext.Version()

---@param target string
---@param source string
---@param damage integer
---@param handle integer
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

	Events.OnPrepareHit:Invoke({
		Target=GameHelpers.TryGetObject(target),
		Source = GameHelpers.TryGetObject(source),
		Damage=damage,
		Handle=handle,
		Data=data
	})
end

RegisterProtectedOsirisListener("NRD_OnPrepareHit", 4, "before", function(target, attacker, damage, handle)
	OnPrepareHit(StringHelpers.GetUUID(target), StringHelpers.GetUUID(attacker), damage, handle)
end)

---@private
---@param uuid string
function GameHelpers.TrackBonusWeaponPropertiesApplied(uuid, skill)
	--[[If a skill is specified, switch into "block skills" mode to 
	skip applying BonusWeapon if the source skill was already applied via BonusWeapon.
	This is to prevent infinite loops from an exploded skill procing GameHelpers.ApplyBonusWeaponStatuses
	]]
	if skill then
		if type(PersistentVars.JustAppliedBonusWeaponStatuses[uuid]) ~= "table" then
			PersistentVars.JustAppliedBonusWeaponStatuses[uuid] = {}
		end
		PersistentVars.JustAppliedBonusWeaponStatuses[uuid][skill] = true
	elseif not PersistentVars.JustAppliedBonusWeaponStatuses[uuid] then
		PersistentVars.JustAppliedBonusWeaponStatuses[uuid] = true
	end
	Timer.StartObjectTimer("LeaderLib_ClearJustAppliedBonusWeaponStatuses", uuid, 400)
end

Timer.Subscribe("LeaderLib_ClearJustAppliedBonusWeaponStatuses", function(e)
	PersistentVars.JustAppliedBonusWeaponStatuses[e.Data.UUID] = nil
end)

---@param source EsvCharacter|EsvItem|UUID|NETID
---@param target EsvCharacter|EsvItem|UUID|NETID
---@param fromSkill string|nil If this is resulting from a skill hit.
function GameHelpers.ApplyBonusWeaponStatuses(source, target, fromSkill)
	if type(source) ~= "userdata" then
		source = GameHelpers.TryGetObject(source)
	end
	if source and source.GetStatuses then
		local justApplied = PersistentVars.JustAppliedBonusWeaponStatuses[source.MyGuid]
		if justApplied == true 
		or (fromSkill and type(justApplied) == "table" and justApplied[fromSkill] == true) then
			return false
		end
		for i,status in pairs(source:GetStatuses()) do
			if not Data.EngineStatus[status] then
				local potion = Ext.StatGetAttribute(status, "StatsId")
				if not StringHelpers.IsNullOrWhitespace(potion) then
					if not Ext.OsirisIsCallable() or NRD_StatExists(potion) then
						local bonusWeapon = Ext.StatGetAttribute(potion, "BonusWeapon")
						if not StringHelpers.IsNullOrWhitespace(bonusWeapon) then
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
---@param hitContext HitContext
local function GetHitRequest(hitStatus, hitContext)
	if _EXTVERSION < 56 then
		return hitContext.Hit or hitStatus.Hit
	end
	return hitStatus.Hit
end

---@param hitStatus EsvStatusHit
---@param hitContext HitContext
local function OnHit(hitStatus, hitContext)
	local target = TryGetObject(hitStatus, "TargetHandle")
	local source = TryGetObject(hitStatus, "StatusSourceHandle")

	-- if hitContext.HitType ~= "Surface" and hitContext.HitType ~= "DoT" then
	-- 	Ext.Dump({Context="StatusHitEnter", Damage=hitStatus.Hit.DamageList:ToTable(), TotalDamageDone=hitStatus.Hit.TotalDamageDone, HitType=hitContext.HitType})
	-- end

	if not target then
		return
	end

	local targetId = GameHelpers.GetUUID(target, true)
	local sourceId = GameHelpers.GetUUID(source, true)

	if source then
		--This is set if ApplySkillProperties is true during GameHelpers.Skill.ShootZoneAt
		---@see GameHelpers.Skill.ShootZoneAt
		local applySkillProperties = Vars.ApplyZoneSkillProperties[hitStatus.SkillId]
		if applySkillProperties and applySkillProperties[sourceId] then
			Ext.ExecuteSkillPropertiesOnTarget(hitStatus.SkillId, sourceId, targetId, target.WorldPos, "Target", GameHelpers.Ext.ObjectIsItem(source))
			Timer.Restart(applySkillProperties[sourceId], 1)
		end
	end

	---@type HitRequest
	local hitRequest = GetHitRequest(hitStatus, hitContext)

	---@type StatEntrySkillData
	local skill = nil
	if not StringHelpers.IsNullOrEmpty(hitStatus.SkillId) then
		skill = Ext.GetStat(GetSkillEntryName(hitStatus.SkillId))
	end

	local data = Classes.HitData:Create(target, source, hitStatus, hitContext, hitRequest, skill)

	if skill and source then
		OnSkillHit(skill.Name, target, source, hitRequest.TotalDamageDone, hitRequest, hitContext, hitStatus, data)
	end

	local isFromWeapon = GameHelpers.Hit.IsFromWeapon(hitContext, skill, hitStatus)

	if isFromWeapon then
		AttackManager.InvokeOnHit(true, source, target, data, skill)
	end

	if Features.ApplyBonusWeaponStatuses == true and source then
		if skill then
			local canApplyStatuses = skill.UseWeaponProperties == "Yes"
			if canApplyStatuses then
				GameHelpers.ApplyBonusWeaponStatuses(source, target, skill.Name)
			end
		elseif isFromWeapon then
			GameHelpers.ApplyBonusWeaponStatuses(source, target)
		end
	end

	Events.OnHit:Invoke({
		Target=target,
		Source=source,
		Data=data,
		HitStatus=hitStatus
	})
end

if _EXTVERSION < 56 then
	RegisterProtectedExtenderListener("StatusHitEnter", OnHit)
else
	Ext.Events.StatusHitEnter:Subscribe(function (event)
		OnHit(event.Hit, event.Context)
	end)
end