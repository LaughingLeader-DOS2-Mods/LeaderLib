---A helper table for Osi.NRD_OnPrepareHit that retrieves all relevant flags and damage values.
---@class HitPrepareData
---@field TotalDamageDone integer
---@field DamageList DamageList
---@field Handle integer
---@field Target string
---@field Source string
---@field Cached boolean Whether attributes/damage has been cached/saved in the table.
---Hit API Attributes
---@field SimulateHit boolean
---@field HitType HitType
---@field NoHitRoll boolean
---@field CriticalRoll string
---@field ForceReduceDurability boolean
---@field HighGround string
---Hit Attributes
---@field Equipment integer
---@field DeathType string
---@field DamageType string
---@field AttackDirection integer
---@field ArmorAbsorption integer
---@field LifeSteal integer
---@field HitWithWeapon boolean
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
local HitPrepareData = {
	Type = "HitPrepareData",
	TotalDamageDone = 0,
	DamageList = {},
	Handle = -1,
}

local HIT_ATTRIBUTE = {
	--Hit Prepare Attributes
	SimulateHit = "boolean",
	HitType = "string",
	NoHitRoll = "boolean",
	CriticalRoll = "string",
	ForceReduceDurability = "boolean",
	HighGround = "string",
	--Hit Attributes
	Equipment = "number",
	DeathType = "string",
	DamageType = "string",
	AttackDirection = "number",
	ArmorAbsorption = "number",
	LifeSteal = "number",
	HitWithWeapon = "boolean",
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

HitPrepareData.HIT_ATTRIBUTE = HIT_ATTRIBUTE

local ChaosDamageTypes = {
	Physical = 1,
	Piercing = 2,
	Fire = 6,
	Air = 7,
	Water = 8,
	Earth = 9,
	Poison = 10,
}

HitPrepareData.__call = function(_, ...)
	return HitPrepareData:Create(...)
end

local function CreateDamageMetaList(handle)
	local damageList = {}
	local meta = {}
	local function _GetByType(self, damageType)
		return Osi.NRD_HitGetDamage(handle, damageType)
	end
	local function _ToTable()
		local newTable = {}
		for _,damageType in Data.DamageTypes:Get() do
			if Osi.NRD_HitGetDamage(handle, damageType) > 0 then
				newTable[#newTable+1] = {
					Amount = Osi.NRD_HitGetDamage(handle, damageType),
					DamageType = damageType
				}
			end
		end
		return newTable
	end
	meta.__index = function(tbl,k)
		if k == "ToTable" then
			return _ToTable
		elseif k == "GetByType" then
			return _GetByType
		else
			if Data.DamageTypes[k] then
				return Osi.NRD_HitGetDamage(handle, k)
			else
				error(string.format("%s is not a valid damage type!", k), 2)
			end
		end
	end
	meta.__newindex = function(tbl,k,value)
		local dt = tostring(k)
		if Data.DamageTypes[dt] then
			if value == nil or value == 0 then
				Osi.NRD_HitClearDamage(handle, dt)
			elseif type(value) == "number" then
				Osi.NRD_HitClearDamage(handle, dt)
				Osi.NRD_HitAddDamage(handle, dt, value)
			else
				error(string.format("%s is not a valid integer amount!", value), 2)
			end
		else
			error(string.format("%s is not a valid damage type!", k), 2)
		end
	end
	meta.__pairs = function (tbl)
		local i = 0
		local function iter(tbl)
			local damageType = Data.DamageTypes[i]
			if damageType ~= nil then
				i = i + 1
				return damageType,Osi.NRD_HitGetDamage(handle, damageType) or 0
			end
		end
		return iter, tbl, 0
	end
	setmetatable(damageList, meta)
	return damageList
end

local function SaveHitAttributes(handle, data)
	for k,t in pairs(HIT_ATTRIBUTE) do
		if t == "number" then
			data[k] = Osi.NRD_HitGetInt(handle, k) or nil
		elseif t == "boolean" then
			data[k] = Osi.NRD_HitGetInt(handle, k) == 1 and true or false
		elseif t == "string" then
			data[k] = Osi.NRD_HitGetString(handle, k) or ""
		end
	end
	local total = 0

	for i,damageType in Data.DamageTypes:Get() do
		local amount = Osi.NRD_HitGetDamage(handle, damageType)
		if amount and amount > 0 then
			total = total + amount
			data.DamageList[damageType] = amount
		end
	end
	if total > data.TotalDamageDone then
		if Vars.DebugMode then
			fprint(LOGLEVEL.WARNING, "Damage mismatch? Event's damage(%s) actual total(%s) handle(%s)", data.TotalDamageDone, total, handle)
		end
		data.TotalDamageDone = total
	end
end

local function SetMeta(data)
	local meta = {
		__index = function(tbl,k)
			if tbl.Handle then
				local t = HIT_ATTRIBUTE[k]
				if t == "number" then
					return Osi.NRD_HitGetInt(tbl.Handle, k)
				elseif t == "boolean" then
					return Osi.NRD_HitGetInt(tbl.Handle, k) == 1 and true or false
				elseif t == "string" then
					return Osi.NRD_HitGetString(tbl.Handle, k) or ""
				end
			end
			return HitPrepareData[k]
		end,
		__newindex = function(tbl,k,v)
			if tbl.Handle then
				local t = HIT_ATTRIBUTE[k]
				if t == "number" then
					Osi.NRD_HitSetInt(tbl.Handle, k, v)
					return
				elseif t == "boolean" then
					Osi.NRD_HitSetInt(tbl.Handle, k, v and 1 or 0)
					return
				elseif t == "string" then
					Osi.NRD_HitSetString(tbl.Handle, k, v)
					return
				end
			end
			rawset(tbl, k, v)
		end
	}
	setmetatable(data, meta)
end

---@param handle integer The hit handle.
---@param damage integer Total damage passed in by the event listener.
---@param target string|nil
---@param source string|nil
---@param skipAttributeLoading boolean If true, all the various hit attributes won't be retrieved, and will rely on the __index method to retrieve them from the handle.
---@return HitPrepareData
function HitPrepareData:Create(handle, damage, target, source, skipAttributeLoading)
	---@type HitPrepareData
	local data = {
		Handle = handle or -1,
		TotalDamageDone = damage or 0,
		Target = target or "",
		Source = source or "",
		DamageList = {},
		Cached = skipAttributeLoading ~= true
	}
	if not skipAttributeLoading then
		if handle > -1 then
			SaveHitAttributes(handle, data)
		end
	else
		data.DamageList = CreateDamageMetaList(handle)
	end

	SetMeta(data)

	return data
end

---Returns true if the hit isn't blocked, dodged, or missed.
---@return boolean
function HitPrepareData:Succeeded()
	return self.Blocked == false and self.Missed == false and self.Dodged == false
end

---Cleats all damage from the hit.
function HitPrepareData:ClearAllDamage()
	Osi.NRD_HitClearAllDamage(self.Handle)
	if self.Cached then
		self.DamageList = {}
	end
	self.TotalDamageDone = 0
end

---Adds damage.
---@param damageType string
---@param amount number
---@param skipRecalculate boolean|nil If true, self:Recalculate is skipped.
function HitPrepareData:AddDamage(damageType, amount, skipRecalculate)
	Osi.NRD_HitAddDamage(self.Handle, tostring(damageType), amount)
	if skipRecalculate ~= true then
		self:Recalculate()
	end
end

---Multiplies all damage by a value.
---@param multiplier number Value to multiply every damage type by.
---@param skipRecalculate boolean|nil If true, self:Recalculate is skipped.
function HitPrepareData:MultiplyDamage(multiplier, skipRecalculate)
	for damageType,amount in pairs(self.DamageList) do
		local dt = tostring(damageType)
		Osi.NRD_HitClearDamage(self.Handle, dt)
		Osi.NRD_HitAddDamage(self.Handle, dt, Ext.Utils.Round(amount * multiplier))
	end
	if skipRecalculate ~= true then
		self:Recalculate()
	end
end

---Recalculates total damage done and updates all related variables.
function HitPrepareData:Recalculate()
	local total = 0
	for damageType,amount in pairs(self.DamageList) do
		total = total + amount
	end
	self.TotalDamageDone = total
end

---Make the hit miss the target by setting `Hit = false` and `Missed = true`.  
---This also clears the damage / updates the related properties to represent a missed hit.  
---@param skipUpdatingProperties? boolean Skip clearing the damage and adjusting the other hit properties.
function HitPrepareData:ForceMiss(skipUpdatingProperties)
	if not self.Missed then
		self.Missed = true
		self.Hit = false
		if not skipUpdatingProperties then
			for k,v in pairs(Vars.HitConfig.MissedProperties) do
				self[k] = v
			end
		end
	end
	if not skipUpdatingProperties then
		self:ClearAllDamage()
		self.Damage = 0
	end
end

---Returns true if this hit has all the signs of a projectile weapon with Chaos damage.
---DamageType will be a random type, while the actual damage in the list will be "None" type.
function HitPrepareData:IsBuggyChaosDamage()
	local isChaos = self.TotalDamageDone > 0 and ChaosDamageTypes[self.DamageType] ~= nil
	if self.Cached then
		for damageType,amount in pairs(self.DamageList) do
			if isChaos and damageType ~= "None" and amount > 0 then
				isChaos = false
			end
		end
	else
		for i,damageType in Data.DamageTypes:Get() do
			local amount = Osi.NRD_HitGetDamage(self.Handle, damageType) or 0
			if isChaos and damageType ~= "None" and amount > 0 then
				isChaos = false
			end
		end
	end
	return isChaos
end

---Returns true if the hit is probably from a weapon (HitType is Melee, Ranged, or WeaponDamage).
---@param ignoreSkills boolean|nil Require Melee/Ranged hit reasons only (basic attacks).
---@param ignoreUnarmed boolean|nil If true and ignoreSkills is true, only return true if HitWithWeapon is set.
function HitPrepareData:IsFromWeapon(ignoreSkills, ignoreUnarmed)
	local hitReason = self.HitType
	if ignoreSkills then
		return (hitReason == "Melee" or hitReason == "Ranged") and (not ignoreUnarmed or self.HitWithWeapon)
	else
		return (hitReason == "Melee" or hitReason == "Ranged" or hitReason == "WeaponDamage")
	end
end

local _INDIRECT_HIT_TYPE = {
	Surface = true,
	DoT = true,
	Reflected = true
}

---Returns true if the HitType is Magic, WeaponDamage, Melee, or Ranged. Surface, DoT and Reflected is ignored.
function HitPrepareData:IsDirect()
	return _INDIRECT_HIT_TYPE[self.HitType] ~= true
end

function HitPrepareData:ToDebugString(indentChar)
	local target = self
	if not self.Cached then
		target = {
			DamageList={}, 
			TotalDamageDone = self.TotalDamageDone, 
			Handle = self.Handle,
			Target = self.Target,
			Source = self.Source,
			Cached = false,
			IsFromWeapon = target.IsFromWeapon
		}
		SaveHitAttributes(self.Handle, target)
	end
	local keys = {
		"IsFromWeapon"
	}
	for k,v in pairs(target) do
		keys[#keys+1] = k
	end
	table.sort(keys)
	local data = {}
	for _,k in ipairs(keys) do
		if type(target[k]) == "function" then
			local b,result = pcall(target[k], target)
			if b then
				data[k] = result
			end
		else
			data[k] = target[k]
		end
	end
	--return Common.JsonStringify(data)
	return Lib.inspect(data)
end

Classes.HitPrepareData = HitPrepareData