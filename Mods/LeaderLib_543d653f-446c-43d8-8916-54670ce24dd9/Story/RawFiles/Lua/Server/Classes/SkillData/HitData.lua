---Data passed to hit callbacks, such as the various functions in SkillListeners.lua
---@class HitData
---@field Damage integer
---@field Handle ObjectHandle
---@field TargetObject EsvGameObject
---@field Target string
---@field AttackerObject EsvGameObject
---@field Attacker string
local HitData = {
	ID = "HitData",
	Skill = "",
	---@type StatEntrySkillData
	SkillData = nil,
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

local function CreateDamageMetaList(target, handle)
	local damageList = Ext.NewDamageList()
	for _,damageType in Data.DamageTypes:Get() do
		damageList:Add(damageList, NRD_HitStatusGetDamage(target, handle, damageType) or 0)
	end
	return damageList
end

local canUseRawFunctions = Ext.Version() >= 55
local readOnlyProperties = {
	Handle = true,
	Target = true,
	Attacker = true,
}

---@param this HitData
local function SetMeta(this)
	setmetatable(this, {
		__index = function(tbl, k)
			if k == "Damage" then
				if this.HitRequest then
					return this.HitRequest.TotalDamageDone
				end
				return 0
			elseif k == "Handle" then
				return this.HitStatus.StatusHandle
			elseif k == "Success" then
				if this.TargetObject == nil then
					tbl.Success = false
					return false
				end
				return GameHelpers.Hit.Succeeded(this.HitRequest)
			elseif k == "Target" then
				local target = GameHelpers.GetUUID(this.TargetObject, true)
				tbl.Target = target
				return target
			elseif k == "Attacker" then
				local source = GameHelpers.GetUUID(this.AttackerObject, true)
				tbl.Attacker = source
				return source
			end
			return HitData[k]
		end,
		__newindex = function(tbl,k,v)
			if k == "Damage" then
				this.HitRequest.TotalDamageDone = v
				return
			elseif k == "Success" then
				--this:SetHitFlag("Missed", true)
				return
			end
			if canUseRawFunctions and not readOnlyProperties[k] then
				rawset(tbl, k, v)
			end
		end
	})
end

---@param target EsvGameObject
---@param source EsvGameObject
---@param hitStatus EsvStatusHit
---@param hitContext HitContext
---@param hitRequest HitRequest
---@param skill StatEntrySkillData|nil
---@return HitData
function HitData:Create(target, source, hitStatus, hitContext, hitRequest, skill)
	---@type HitData
    local this =
    {
		TargetObject = target,
		AttackerObject = source,
		HitStatus = hitStatus,
		HitContext = hitContext,
		HitRequest = hitRequest,
		SkillData = skill
	}
	if this.HitRequest then
		this.DamageList = this.HitRequest.DamageList
	else
		this.DamageList = CreateDamageMetaList(target, this.HitStatus.StatusHandle)
	end
	if this.SkillData ~= nil then
		this.Skill = skill.Name
		this.IsFromSkll = true
	else
		this.Skill = ""
		this.IsFromSkll = false
	end
	SetMeta(this)
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
	if self.HitRequest then
		self.HitRequest.TotalDamageDone = total
	end
	if self.HitContext and self.HitRequest then
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

---Multiplies all damage by a value.
---@param damageType string Target damage type to convert.
---@param toDamageType string Damage type to convert to.
---@param aggregate boolean|nil Combine multiple entries for the same damage types into one.
function HitData:ConvertDamageTypeTo(damageType, toDamageType, aggregate)
	if aggregate then
		self.DamageList:AggregateSameTypeDamages()
	end
	local damages = self.DamageList:ToTable()
	local damageList = Ext.NewDamageList()
	for k,v in pairs(damages) do
		if v.DamageType == damageType then
			v.DamageType = toDamageType
		end
		damageList:Add(v.DamageType, v.Amount)
	end
	self.DamageList:Clear()
	self.DamageList:Merge(damageList)
	if self.HitRequest then
		self.HitRequest.DamageList = self.DamageList
	end
	self:Recalculate(false)
end

---@param flag string|string[]
---@param value boolean
function HitData:SetHitFlag(flag, value)
	GameHelpers.Hit.SetFlag(self.HitRequest, flag, value)
end

---@param flag string|string[]
---@param value boolean
function HitData:HasHitFlag(flag, value)
	if value == nil then
		value = true
	end
	return GameHelpers.Hit.HasFlag(self.HitRequest, flag) == value
end

function HitData:IsFromWeapon()
	return GameHelpers.Hit.IsFromWeapon(self.HitStatus, self.SkillData)
end

Classes.HitData = HitData