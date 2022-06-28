local _EXTVERSION = Ext.Version()

---Data passed to hit callbacks, such as the various functions in SkillListeners.lua
---@class HitData
---@field Damage integer
---@field Handle ObjectHandle
---@field TargetObject EsvCharacter|EsvItem
---@field Target string
---@field AttackerObject EsvCharacter|EsvItem
---@field Attacker string
---@field DamageList DamageList
---@field HitContext HitContext
---@field HitRequest HitRequest
---@field HitStatus EsvStatusHit
---@field SkillData StatEntrySkillData
---@field Success boolean True if the hit has a target, and the hit wasn't Dodged, Blocked, or Missed.
local HitData = {
	Type = "HitData",
	Skill = "",
	IsFromSkill = false,
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
				if this.Target == nil then
					return false
				end
				return GameHelpers.Hit.Succeeded(this.HitRequest)
			elseif k == "TargetObject" then
				return GameHelpers.TryGetObject(tbl.Target)
			elseif k == "AttackerObject" then
				if not StringHelpers.IsNullOrEmpty(tbl.Attacker) then
					return GameHelpers.TryGetObject(tbl.Attacker)
				end
				return nil
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
---@param params table|nil
---@return HitData
function HitData:Create(target, source, hitStatus, hitContext, hitRequest, skill, params)
	---@type HitData
    local this =
    {
		Target = target.MyGuid,
		Attacker = source and source.MyGuid or "",
		HitStatus = hitStatus,
		HitContext = hitContext,
		HitRequest = hitRequest,
		SkillData = skill
	}
	if params then
		for k,v in pairs(params) do
			this[k] = v
		end
	end
	if this.HitRequest then
		this.DamageList = this.HitRequest.DamageList
	else
		this.DamageList = CreateDamageMetaList(target, this.HitStatus.StatusHandle)
	end
	if this.SkillData ~= nil then
		this.Skill = this.SkillData.Name
		this.IsFromSkill = true
	else
		this.Skill = ""
		this.IsFromSkill = false
	end
	SetMeta(this)
    return this
end

function HitData:PrintTargets()
	PrintDebug("[LeaderLib:HitData]")
	PrintDebug("============")
	fprint(LOGLEVEL.TRACE, "[HitData:%s] Target(%s)", self.Handle, self.Target)
	PrintDebug("============")
end

---@param target DamageList
---@param source DamageList
local function CopyDamageList(target, source)
	if not target or target == source then
		return
	end
	if _EXTVERSION < 56 then
		for _,damageType in Data.DamageTypes:Get() do
			target:Clear(damageType)
		end
		target:Merge(source)
	else
		target:CopyFrom(source)
	end
end

---Updates HitStatus.Hit and HitContext.Hit to HitRequest, so property changes are applied.
function HitData:UpdateHitRequest()
	if self.HitRequest then
		--No longer needed in v56 since Hit is a reference type now.
		if _EXTVERSION < 56 then
			self.HitStatus.Hit = self.HitRequest
			if self.HitContext and self.HitContext.Hit then
				self.HitContext.Hit = self.HitRequest
			end
		else
			-- Ext.Dump({
			-- 	HitRequest = self.HitRequest and self.HitRequest.DamageList:ToTable() or "nil",
			-- 	HitContext = (self.HitContext and self.HitContext.CharacterHitDamageList) and self.HitContext.CharacterHitDamageList:ToTable() or "nil",
			-- 	HitStatus = (self.HitStatus and self.HitStatus.Hit) and self.HitStatus.Hit.DamageList:ToTable() or "nil",
			-- })
		end
		-- Ext.IO.SaveFile("Dumps/HitCrap.json", Ext.DumpExport({
		-- 	HitStatus = self.HitStatus,
		-- 	HitRequest = self.HitRequest,
		-- 	HitContext = self.HitContext
		-- }))
	end
end

---Applies any DamageList changes to the actual hit.
---@param recalculate boolean|nil If true, lifesteal is recalculated.
function HitData:ApplyDamageList(recalculate)
	if _EXTVERSION < 56 then
		self.HitRequest.DamageList = self.DamageList
		NRD_HitStatusClearAllDamage(self.Target, self.Handle)
		local damages = self.DamageList:ToTable()
		for i=1,#damages do
			local v = damages[i]
			NRD_HitStatusAddDamage(self.Target, self.Handle, v.DamageType, v.Amount)
		end
	else
		self.HitStatus.Hit.DamageList:CopyFrom(self.DamageList)
	end
	if recalculate then
		self:Recalculate(true, true)
	else
		self:UpdateHitRequest()
	end
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
		self.HitRequest.ArmorAbsorption = 0
		if self.HitRequest.TotalDamageDone ~= total
		and total ~= 0
		and GameHelpers.Ext.ObjectIsCharacter(self.TargetObject)
		then
			self.HitRequest.ArmorAbsorption = self.HitRequest.ArmorAbsorption + Game.Math.ComputeArmorDamage(self.DamageList, self.TargetObject.Stats.CurrentArmor)
			self.HitRequest.ArmorAbsorption = self.HitRequest.ArmorAbsorption + Game.Math.ComputeMagicArmorDamage(self.DamageList, self.TargetObject.Stats.CurrentMagicArmor)
		end
		self.HitRequest.TotalDamageDone = total
	end
	if self.HitContext and self.HitRequest then
		if recalcLifeSteal and ObjectIsCharacter(self.Target) == 1 and ObjectIsCharacter(self.Attacker) == 1 then
			GameHelpers.Hit.RecalculateLifeSteal(self.HitRequest, Ext.GetCharacter(self.Target).Stats, Ext.GetCharacter(self.Attacker).Stats, self.HitContext.HitType, setLifeStealFlags, allowArmorDamageTypesToLifeSteal)
		end
	end
	self:UpdateHitRequest()
end

---Adds damage.
---@param damageType string
---@param amount number
---@param skipApplying boolean|nil If true, self:ApplyDamageList is skipped.
function HitData:AddDamage(damageType, amount, skipApplying)
	self.DamageList:Add(damageType, amount)
	if skipApplying ~= true then
		self:ApplyDamageList(true)
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
	self:ApplyDamageList(true)
end

---Redirects damage to another target.
---@param target UUID|EsvCharacter|EsvItem
---@param multiplier number Multiplier value to reduce damage by (0.01 - 1.0), i.e 0.15 would multiply damage by 0.85 and deal 0.15 of the original damage to the target.
---@param aggregate boolean|nil Combine multiple entries for the same damage types into one.
function HitData:RedirectDamage(target, multiplier, aggregate)
	if aggregate then
		self.DamageList:AggregateSameTypeDamages()
	end
	local newDamage = Ext.NewDamageList()
	for _,v in pairs(self.DamageList:ToTable()) do
		newDamage:Add(v.DamageType, Ext.Round(v.Amount * multiplier))
	end
	local reduceBy = math.max(0, 1.0 - multiplier)
	if reduceBy == 0 then
		for damageType,_ in pairs(Data.DamageTypeEnums) do
			self.DamageList:Clear(damageType)
		end
	else
		self.DamageList:Multiply(reduceBy)
	end
	self:ApplyDamageList(true)

	local uuid = GameHelpers.GetUUID(target)
	local handle = NRD_HitPrepare(uuid, self.Attacker)
	if self.HitContext then
		NRD_HitSetString(handle, "CriticalRoll", self.HitContext.CriticalRoll)
		NRD_HitSetString(handle, "HitType", self.HitContext.HitType)
	else
		NRD_HitSetInt(handle, "CriticalRoll", 0)
	end
	NRD_HitSetInt(handle, "SimulateHit", 1)
	NRD_HitSetInt(handle, "HitType", 6)
	NRD_HitSetInt(handle, "NoHitRoll", 1)
	for _,v in pairs(newDamage:ToTable()) do
		NRD_HitAddDamage(handle, v.DamageType, v.Amount)
	end
	NRD_HitExecute(handle)
end

local function DamageTypeEquals(damageType, compare, compareType, negate)
	if negate then
		if compareType == "table" then
			return not Common.TableHasEntry(compare, damageType, true)
		else
			return damageType ~= compare
		end
	else
		if compareType == "table" then
			return Common.TableHasEntry(compare, damageType, true)
		else
			return damageType == compare
		end
	end
end

---@alias HitData.ConvertDamageTypeTo.MathRoundFunction fun(x:number):integer

---Converts specific damage types to another.
---@param damageType DamageType|DamageType[] Damage type(s) to convert.
---@param toDamageType string Damage type to convert to.
---@param aggregate boolean|nil Combine multiple entries for the same damage types into one.
---@param percentage number|nil How much of the damage amount to convert, from 0 to 1.
---@param negate boolean|nil If true, convert damage types that *don't* match the damageType param.
---@param mathRoundFunction HitData.ConvertDamageTypeTo.MathRoundFunction|nil Optional function to use when rounding amounts (Ext.Round, math.ceil, etc)
function HitData:ConvertDamageTypeTo(damageType, toDamageType, aggregate, percentage, negate, mathRoundFunction)
	if aggregate then
		self.DamageList:AggregateSameTypeDamages()
	end
	percentage = percentage or 1
	mathRoundFunction = mathRoundFunction or Ext.Round
	local damages = self.DamageList:ToTable()
	local damageList = Ext.NewDamageList()
	local t = type(damageType)
	for k,v in pairs(damages) do
		local dType = v.DamageType
		local amount = mathRoundFunction(v.Amount * percentage)
		if DamageTypeEquals(dType, damageType, t, negate) then
			damageList:Add(toDamageType, amount)
			damageList:Add(v.DamageType, amount)
		else
			damageList:Add(dType, amount)
		end
	end
	self.DamageList:Clear()
	self.DamageList:Merge(damageList)
	self:ApplyDamageList(false)
end

---Converts all damage to a specific type.
---@param damageType string Damage type to convert everything to.
---@param aggregate boolean|nil Combine multiple entries for the same damage types into one.
function HitData:ConvertAllDamageTo(damageType, aggregate)
	self.DamageList:ConvertDamageType(damageType)
	if aggregate then
		self.DamageList:AggregateSameTypeDamages()
	end
	self:ApplyDamageList(false)
end

---Clears all damage, or damage from a specific type, from the damage list and recalculates totals / lifesteal.
---@param damageType string|nil If set, only damage from this specific type is cleared.
function HitData:ClearDamage(damageType)
	if damageType == nil then
		self:ClearAllDamage()
	else
		self.DamageList:Clear(damageType)
		self:ApplyDamageList(true)
	end
end

---Clears all damage, or damage from a specific type, from the damage list and recalculates totals / lifesteal.
function HitData:ClearAllDamage()
	for damageType,_ in pairs(Data.DamageTypeEnums) do
		self.DamageList:Clear(damageType)
	end
	self:ApplyDamageList(true)
end

---Sets the amount of LifeSteal done.
---@param amount integer
function HitData:SetLifeSteal(amount)
	if self.HitRequest then
		self.HitRequest.LifeSteal = amount
	end
	self:UpdateHitRequest()
end

---@param flag HitFlagID|HitFlagID[]
---@param value boolean
function HitData:SetHitFlag(flag, value)
	GameHelpers.Hit.SetFlag(self.HitRequest, flag, value)
	self:UpdateHitRequest()
end

---@param flag HitFlagID|HitFlagID[]
---@param value boolean
function HitData:HasHitFlag(flag, value)
	if value == nil then
		value = true
	end
	return GameHelpers.Hit.HasFlag(self.HitRequest, flag) == value
end

function HitData:IsFromWeapon()
	if self.HitType then
		return GameHelpers.Hit.TypesAreFromWeapon(self.HitType, self.DamageSourceType, self.WeaponHandle, self.SkillData)
	end
	return GameHelpers.Hit.IsFromWeapon(self.HitContext, self.SkillData, self.HitStatus)
end

---Returns true if the hit isn't from a surface, DoT, status tick, etc.
function HitData:IsDirect()
	return GameHelpers.Hit.IsDirect(self.HitContext.HitType)
end

Classes.HitData = HitData