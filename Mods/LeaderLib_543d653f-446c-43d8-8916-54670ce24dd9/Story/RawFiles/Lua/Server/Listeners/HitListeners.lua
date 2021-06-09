---@class HitPrepareData
---@field TotalDamageDone integer
---@field DamageList table<string, integer>
---@field Handle integer
---@field IsChaos boolean
---Hit Attributes
---@field Equipment integer
---@field DeathType string
---@field DamageType string
---@field AttackDirection integer
---@field ArmorAbsorption integer
---@field LifeSteal integer
---@field HitWithWeapon integer
---@field Hit boolean
---@field Blocked boolean
---@field Dodged boolean
---@field Missed boolean
---@field CriticalHit boolean
---@field Backstab boolean
---@field FromSetHP boolean
---@field DontCreateBloodSurface boolean
---@field Reflection boolean
---@field NoDamageOnOwner boolean
---@field FromShacklesOfPain boolean
---@field DamagedMagicArmor boolean
---@field DamagedPhysicalArmor boolean
---@field DamagedVitality boolean
---@field PropagatedFromOwner boolean
---@field Surface boolean
---@field DoT boolean
---@field ProcWindWalker boolean
---@field CounterAttack boolean
---@field Poisoned boolean
---@field Bleeding boolean
---@field Burning boolean
---@field NoEvents boolean

local HIT_ATTRIBUTE = {
	Equipment = "integer",
	DeathType = "string",
	DamageType = "string",
	AttackDirection = "integer",
	ArmorAbsorption = "integer",
	LifeSteal = "integer",
	HitWithWeapon = "integer",
	Hit = "boolean",
	Blocked = "boolean",
	Dodged = "boolean",
	Missed = "boolean",
	CriticalHit = "boolean",
	Backstab = "boolean",
	FromSetHP = "boolean",
	DontCreateBloodSurface = "boolean",
	Reflection = "boolean",
	NoDamageOnOwner = "boolean",
	FromShacklesOfPain = "boolean",
	DamagedMagicArmor = "boolean",
	DamagedPhysicalArmor = "boolean",
	DamagedVitality = "boolean",
	PropagatedFromOwner = "boolean",
	Surface = "boolean",
	DoT = "boolean",
	ProcWindWalker = "boolean",
	CounterAttack = "boolean",
	Poisoned = "boolean",
	Bleeding = "boolean",
	Burning = "boolean",
	NoEvents = "boolean",
}

local ChaosDamageTypes = {
	Physical = 1,
	Piercing = 2,
	Fire = 6,
	Air = 7,
	Water = 8,
	Earth = 9,
	Poison = 10,
}

---@return HitPrepareData
local function CreateHitPrepareDataTable(handle, damage)
	---@type HitPrepareData
	local data = {}
	for k,t in pairs(HIT_ATTRIBUTE) do
		if t == "integer" then
			data[k] = NRD_HitGetInt(handle, k) or nil
		elseif t == "boolean" then
			data[k] = NRD_HitGetInt(handle, k) == 1 and true or false
		elseif t == "string" then
			data[k] = NRD_HitGetString(handle, k) or ""
		end
	end
	data.TotalDamageDone = damage
	data.DamageList = {}
	data.Handle = damage
	local total = 0
	
	data.IsChaos = damage > 0 and ChaosDamageTypes[data.DamageType] ~= nil

	for i,damageType in Data.DamageTypes:Get() do
		local amount = NRD_HitGetDamage(handle, damageType)
		if amount and amount > 0 then
			total = total + amount
			data.DamageList[damageType] = amount
			if data.IsChaos and damageType ~= "None" and amount > 0 then
				data.IsChaos = false
			end
		end
	end
	if total > data.TotalDamageDone then
		if Vars.DebugMode then
			fprint(LOGLEVEL.WARNING, "Damage mismatch? Event's damage(%s) actual total(%s) handle(%s)", damage, total, handle)
		end
		data.TotalDamageDone = total
	end

	return data
end

---@type target string
---@type source string
---@type damage integer
---@type handle integer
local function OnPrepareHit(target, source, damage, handle)
	local data = CreateHitPrepareDataTable(handle, damage)
	if Features.FixChaosWeaponProjectileDamage then
		print(Ext.JsonStringify(data))
		if data.IsChaos then
			local amount = data.DamageList.None
			data.DamageList.None = nil
			data.DamageList[data.DamageType] = amount
			NRD_HitClearDamage(handle, "None")
			NRD_HitAddDamage(handle, data.DamageType, amount)
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