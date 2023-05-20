local _EXTVERSION = Ext.Utils.Version()


---@param attacker EsvCharacter
---@return EsvASAttack|nil
local function _GetASAttack(attacker)
	for _,layer in pairs(attacker.ActionMachine.Layers) do
		if layer.State and layer.State.Type == "Attack" then
			return layer.State
		end
	end
	return nil
end

function Vars.ShouldOverrideBasicAttackCriticalHit()
	return Events.CCH.GetShouldApplyCriticalHit.Next ~= nil or Events.CCH.GetCanBackstab.Next ~= nil
end

---@param target ServerObject|vec3
---@param attacker EsvCharacter
---@param isPosition boolean
local function _ThrowOnBasicAttackStart(target, attacker, isPosition)
	local state = _GetASAttack(attacker)
	if state and Vars.ShouldOverrideBasicAttackCriticalHit() then
		--Here we're overriding the critical hit rolling done in esv::ASAttack::Enter, since it rolls before the hit enters.

		---@type HitRequest
		local hit = {
			ArmorAbsorption = 0,
			AttackDirection = 0,
			Backstab = false,
			Bleeding = false,
			Blocked = false,
			Burning = false,
			CounterAttack = false,
			CriticalHit = false,
			EffectFlags = 1,
			DamageDealt = 0,
			DamageList = Ext.Stats.NewDamageList(),
			DamageType = "Physical",
			DamagedMagicArmor = false,
			DamagedPhysicalArmor = false,
			DamagedVitality = false,
			DeathType = "Physical",
			DoT = false,
			Dodged = false,
			DontCreateBloodSurface = false,
			Equipment = 0,
			Flanking = false,
			FromSetHP = false,
			FromShacklesOfPain = false,
			Hit = true,
			HitWithWeapon = true,
			LifeSteal = 0,
			Missed = false,
			NoDamageOnOwner = false,
			NoEvents = false,
			Poisoned = false,
			ProcWindWalker = false,
			PropagatedFromOwner = false,
			Reflection = false,
			Surface = false,
			TotalDamageDone = 0,
		}
		local attackerStats = attacker.Stats

		if attackerStats.MainWeapon then
			---The osiris events are thrown before weapon damage is calculated
			--hit.DamageList = state.MainWeaponDamageList
			if GameHelpers.Item.CanBackstab(attackerStats.MainWeapon) then
				hit.Backstab = true
			elseif not isPosition then
				hit.Backstab = HitOverrides.CanBackstab(target.Stats, attackerStats, attackerStats.MainWeapon, "Melee")
			end
			if HitOverrides.ShouldApplyCriticalHit(hit, attackerStats, "Melee", "Roll", true) then
				state.MainHandHitType = "Critical"
			else
				state.MainHandHitType = "NotCritical"
			end
		end

		if attackerStats.OffHandWeapon then
			hit.Backstab = false
			--hit.DamageList = state.OffHandDamageList
			if GameHelpers.Item.CanBackstab(attackerStats.OffHandWeapon) then
				hit.Backstab = true
			elseif not isPosition then
				hit.Backstab = HitOverrides.CanBackstab(target.Stats, attackerStats, attackerStats.MainWeapon, "Melee")
			end
			if HitOverrides.ShouldApplyCriticalHit(hit, attackerStats, "Melee", "Roll", true) then
				state.OffHandHitType = "Critical"
			else
				state.OffHandHitType = "NotCritical"
			end
		end
	end
	local data = {
		Attacker = attacker,
		AttackerGUID = attacker.MyGuid,
		Target = target,
		TargetIsObject = not isPosition,
		State = state,
	}
	if not isPosition then
		data.TargetGUID = target.MyGuid
	end
	Events.OnBasicAttackStart:Invoke(data)
end

Ext.Osiris.RegisterListener("CharacterStartAttackObject", 3, "after", function (targetGUID, attackerOwnerGUID, attackerGUID)
	if Osi.ObjectExists(targetGUID) == 0 or Osi.ObjectExists(attackerGUID) == 0 then
		return
	end
	attacker = GameHelpers.GetCharacter(attackerGUID)
	target = GameHelpers.TryGetObject(targetGUID)
	if attacker and target then
		_ThrowOnBasicAttackStart(target, attacker, false)
	end
end)

Ext.Osiris.RegisterListener("CharacterStartAttackPosition", 5, "after", function (x, y, z, attackerOwnerGUID, attackerGUID)
	if Osi.ObjectExists(attackerGUID) == 0 then
		return
	end
	attacker = GameHelpers.GetCharacter(attackerGUID)
	if attacker then
		local target = {x,y,z}
		_PV.StartAttackPosition[attacker.MyGuid] = target
		_ThrowOnBasicAttackStart(target, attacker, true)
	end
end)

---@param target string
---@param source string
---@param damage integer
---@param handle integer
local function OnPrepareHit(target, source, damage, handle)
	if Osi.ObjectExists(target) == 0 then
		return
	end
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
		TargetGUID=target,
		Source = GameHelpers.TryGetObject(source),
		SourceGUID=source,
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
		if type(_PV.JustAppliedBonusWeaponStatuses[uuid]) ~= "table" then
			_PV.JustAppliedBonusWeaponStatuses[uuid] = {}
		end
		_PV.JustAppliedBonusWeaponStatuses[uuid][skill] = true
	elseif not _PV.JustAppliedBonusWeaponStatuses[uuid] then
		_PV.JustAppliedBonusWeaponStatuses[uuid] = true
	end
	Timer.StartObjectTimer("LeaderLib_ClearJustAppliedBonusWeaponStatuses", uuid, 400)
end

Timer.Subscribe("LeaderLib_ClearJustAppliedBonusWeaponStatuses", function(e)
	_PV.JustAppliedBonusWeaponStatuses[e.Data.UUID] = nil
end)

local _cachedBonusWeapon = {}
setmetatable(_cachedBonusWeapon, {__mode = "kv"})

local _SelfPropertyContext = {"Self", "SelfOnHit"}

---@param source ObjectParam
---@param target ObjectParam
---@param fromSkill string|nil If this is resulting from a skill hit.
function GameHelpers.ApplyBonusWeaponStatuses(source, target, fromSkill)
	target = GameHelpers.TryGetObject(target)
	if type(source) ~= "userdata" then
		source = GameHelpers.TryGetObject(source)
	end
	if target and source and source.GetStatuses then
		local justApplied = _PV.JustAppliedBonusWeaponStatuses[source.MyGuid]
		if justApplied == true 
		or (fromSkill and type(justApplied) == "table" and justApplied[fromSkill] == true) then
			return false
		end
		---@type table<integer, EsvStatusConsumeBase>
		local statuses = source:GetStatusObjects()
		for _,status in pairs(statuses) do
			if Data.StatusStatsIdTypes[status.StatusType] then
				local potion = status.StatsId
				if not StringHelpers.IsNullOrWhitespace(potion) and not string.find(potion, ";") then
					local bonusWeapon = _cachedBonusWeapon[potion] or GameHelpers.Stats.GetAttribute(potion, "BonusWeapon", "")
					if not StringHelpers.IsNullOrWhitespace(bonusWeapon) then
						_cachedBonusWeapon[potion] = bonusWeapon
						local extraProps = GameHelpers.Stats.GetExtraProperties(bonusWeapon)
						if extraProps and #extraProps > 0 then
							Ext.PropertyList.ExecuteExtraPropertiesOnTarget(bonusWeapon, "ExtraProperties", source, target, target.WorldPos, "Target", false, fromSkill)
							--Basic attacks don't apply SELF statuses in ExtraProperties, but skills do
							if fromSkill then
								Ext.PropertyList.ExecuteExtraPropertiesOnTarget(bonusWeapon, "ExtraProperties", source, source, source.WorldPos, _SelfPropertyContext, false, fromSkill)
							else
								--Basic attacks do apply Self:OnHit
								Ext.PropertyList.ExecuteExtraPropertiesOnTarget(bonusWeapon, "ExtraProperties", source, source, source.WorldPos, Data.PropertyContext.SelfOnHit, false, fromSkill)
							end
						end
					end
				end
			end
		end
	end
end

Ext.Events.StatusHitEnter:Subscribe(function (e)
	local hitStatus = e.Hit
	local hitContext = e.Context
	if not hitStatus or not hitContext then
		return
	end
	local hitRequest = e.Hit.Hit
	local target = GameHelpers.GetObjectFromHandle(hitStatus.TargetHandle)
	local source = GameHelpers.GetObjectFromHandle(hitStatus.StatusSourceHandle)

	if not target then
		return
	end

	local targetGUID = GameHelpers.GetUUID(target, true)
	local sourceGUID = GameHelpers.GetUUID(source, true)

	if source then
		--This is set if ApplySkillProperties is true during GameHelpers.Skill.ShootZoneAt
		---@see GameHelpers.Skill.ShootZoneAt
		local applySkillProperties = Vars.ApplyZoneSkillProperties[hitStatus.SkillId]
		if applySkillProperties and applySkillProperties[sourceGUID] then
			Ext.PropertyList.ExecuteSkillPropertiesOnTarget(hitStatus.SkillId, sourceGUID, targetGUID, target.WorldPos, "Target", GameHelpers.Ext.ObjectIsItem(source))
			Ext.PropertyList.ExecuteSkillPropertiesOnTarget(hitStatus.SkillId, sourceGUID, sourceGUID, source.WorldPos, _SelfPropertyContext, GameHelpers.Ext.ObjectIsItem(source))
			Timer.Start(applySkillProperties[sourceGUID], 1)
		end
	end

	local skill = nil
	if not StringHelpers.IsNullOrEmpty(hitStatus.SkillId) then
		skill = Ext.Stats.Get(GetSkillEntryName(hitStatus.SkillId), nil, false)
		---@cast skill StatEntrySkillData
	end

	local hitType = GameHelpers.Hit.GetHitType(hitContext)
	local damageSourceType = hitStatus.DamageSourceType
	local weaponHandle = hitStatus.WeaponHandle

	local data = Classes.HitData:Create(target, source, hitStatus, hitContext, hitRequest, skill, {
		HitType = hitType,
		DamageSourceType = damageSourceType,
		WeaponHandle = weaponHandle
	})

	local eventData = {
		Target=target,
		Source=source,
		TargetGUID=targetGUID,
		SourceGUID=sourceGUID,
		Data=data,
		HitStatus=hitStatus,
		HitContext=hitContext
	}

	Events.BeforeOnHit:Invoke(eventData)
	
	--Update skill in case a mod sets/changes it during BeforeOnHit
	if skill ~= data.SkillData then
		skill = data.SkillData
	end

	if skill and source then
		OnSkillHit(skill.Name, target, source, data.Damage, hitRequest, hitContext, hitStatus, data)
	end
	
	local isFromWeapon = data:IsFromWeapon()

	if isFromWeapon then
		AttackManager.InvokeOnHit(true, source, target, data, skill)
	end

	if Features.ApplyBonusWeaponStatuses == true and source then
		if skill then
			if skill.UseWeaponProperties == "Yes" then
				GameHelpers.ApplyBonusWeaponStatuses(source, target, skill.Name)
			end
		elseif isFromWeapon then
			GameHelpers.ApplyBonusWeaponStatuses(source, target)
		end
	end

	Events.OnHit:Invoke(eventData)
end)