---Data passed to hit callbacks, such as the various functions in SkillListeners.lua
---@class HitData
local HitData = {
	ID = "HitData",
	Target = "",
	Attacker = "",
	Skill = "",
	Damage = 0,
	Handle = 0,
	IsFromSkll = false,
	---@type boolean The hit did not miss.
	Success = true,
	---@type EsvStatusHit
	HitStatus = nil,
	---@type HitContext
	HitContext = nil,
	---@type HitRequest
	HitRequest = nil,
	---@type DamageList
	DamageList = {}
}
HitData.__index = HitData

local function CreateDamageMetaList(target, handle)
	local damageList = Ext.NewDamageList()
	for _,damageType in Data.DamageTypes:Get() do
		damageList:Add(damageList, NRD_HitStatusGetDamage(target, handle, damageType) or 0)
	end
	return damageList
end

---@param target string The source of the skill.
---@param attacker string
---@param damage integer
---@param handle integer
---@param skill string|nil
---@param success boolean|nil
---@param hitStatus EsvStatusHit|nil
---@param hitContext HitContext|nil
---@param hitRequest HitRequest|nil
---@return HitData
function HitData:Create(target, attacker, damage, handle, skill, success, hitStatus, hitContext, hitRequest)
	---@type HitData
    local this =
    {
		Target = target,
		Attacker = attacker,
		Damage = damage,
		Handle = handle,
		Success = true,
		HitContext = hitContext,
		HitRequest = hitRequest
	}
	---@type EsvStatusHit
	local status = hitStatus or Ext.GetStatus(target, handle)
	if status then
		this.HitStatus = status
	end
	if this.HitRequest then
		this.DamageList = this.HitRequest.DamageList
	else
		this.DamageList = CreateDamageMetaList(target, handle)
	end
	if success ~= nil then
		this.Success = success
	else
		if this.HitStatus then
			if this.HitStatus.Hit then
				this.Success = GameHelpers.Hit.Succeeded(this.HitStatus.Hit)
			else
				this.Success = GameHelpers.HitSucceeded(target, handle, 0)
			end
		else
			this.Success = GameHelpers.HitSucceeded(target, handle, 1)
		end
	end
	if StringHelpers.IsNullOrEmpty(this.Target) then
		this.Success = false
	end
	if skill ~= nil then
		this.Skill = skill
		this.IsFromSkll = true
	end
	setmetatable(this, self)
    return this
end

function HitData:PrintTargets()
	PrintDebug("[LeaderLib:HitData]")
	PrintDebug("============")
	self:PrintTargets()
	PrintDebug("============")
end

function HitData:PrintTargets()
	fprint(LOGLEVEL.TRACE, "[HitData:%s] Target(%s)", self.Handle, self.Target)
end

---Recalculates total damage done and updates all related variables.
---@param recalcLifeSteal boolean|nil Recalculate LifeSteal as well, using Game.Math.ApplyLifeSteal.
---@param setLifeStealFlags boolean|nil If recalcLifeSteal is true, also set effect flags on the hit.
---@param allowArmorDamageTypesToLifeSteal boolean|nil Allows Magic/Corrosive damage to affect LifeSteal if true and recalcLifeSteal is true.
function HitData:Recalculate(recalcLifeSteal, setLifeStealFlags, allowArmorDamageTypesToLifeSteal)
	local total = 0
	for k,v in pairs(self.DamageList:ToTable()) do
		total = total + v.Amount
	end
	self.Damage = total

	--Recalculate LifeSteal
	if self.HitContext and self.HitRequest then
		self.HitContext.TotalDamageDone = total
		self.HitRequest.TotalDamageDone = total
		if recalcLifeSteal and ObjectIsCharacter(self.Target) == 1 and ObjectIsCharacter(self.Attacker) == 1 then
			GameHelpers.Hit.RecalculateLifeSteal(self.HitRequest, Ext.GetCharacter(self.Target).Stats, Ext.GetCharacter(self.Attacker).Stats, self.HitContext.HitType, setLifeStealFlags, allowArmorDamageTypesToLifeSteal)
		end
	end
end

---Multiplies all damage by a value.
---@param multiplier number Value to multiply every damage type by.
---@param aggregate boolean|nil Combine multiple entries for the same damage types into one.
function HitData:MultiplyDamage(multiplier, aggregate)
	if aggregate then
		self.DamageList:AggregateSameTypeDamages()
	end
	self.DamageList:Multiply(multiplier)
	NRD_HitStatusClearAllDamage(self.Target, self.Handle)
	for k,v in pairs(self.DamageList:ToTable()) do
		NRD_HitStatusAddDamage(self.Target, self.Handle, v.DamageType, v.Amount)
	end
	self:Recalculate(true)
end

Classes.HitData = HitData