---A helper table for NRD_OnPrepareHit that retrieves all relevant flags and damage values.
---@class HitPrepareData
---@field TotalDamageDone integer
---@field DamageList table<string, integer>
---@field Handle integer
---@field Target string
---@field Source string
---@field Cached boolean Whether attributes/damage has been cached/saved in the table.
---Hit API Attributes
---@field SimulateHit boolean
---@field HitType string
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
	--Hit Prepare Attributes
	SimulateHit = "boolean",
	HitType = "string",
	NoHitRoll = "boolean",
	CriticalRoll = "string",
	ForceReduceDurability = "boolean",
	HighGround = "string",
	--Hit Attributes
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

---@type HitPrepareData
local HitPrepareData = {
	Type = "HitPrepareData",
	TotalDamageDone = 0,
	DamageList = {},
	Handle = -1,
}

HitPrepareData.__index = function(tbl,k)
	if tbl.Handle then
		local t = HIT_ATTRIBUTE[k]
		if t == "integer" then
			return NRD_HitGetInt(tbl.Handle, k) or nil
		elseif t == "boolean" then
			return NRD_HitGetInt(tbl.Handle, k) == 1 and true or false
		elseif t == "string" then
			return NRD_HitGetString(tbl.Handle, k) or ""
		end
	end
	return rawget(HitPrepareData, k)
end

HitPrepareData.__newindex = function(tbl,k,v)
	if tbl.Handle then
		local t = HIT_ATTRIBUTE[k]
		if t == "integer" then
			NRD_HitSetInt(tbl.Handle, k, v)
			return
		elseif t == "boolean" then
			NRD_HitSetInt(tbl.Handle, k, v)
			return
		elseif t == "string" then
			NRD_HitSetString(tbl.Handle, k, v)
			return
		end
	end
	rawset(tbl, k, v)
end

HitPrepareData.__call = function(_, ...)
	return HitPrepareData:Create(...)
end

local function CreateDamageMetaList(handle)
	local damageList = {}
	local meta = {}
	meta.__index = function(tbl,k)
		if Data.DamageTypeEnums[k] then
			return NRD_HitGetDamage(handle, k)
		else
			error(string.format("%s is not a valid damage type!", k), 2)
		end
	end
	meta.__newindex = function(tbl,k,value)
		if Data.DamageTypeEnums[k] then
			if value == nil or value == 0 then
				NRD_HitClearDamage(handle, k)
			elseif type(value) == "number" then
				NRD_HitClearDamage(handle, k)
				NRD_HitAddDamage(handle, k, value)
			else
				error(string.format("%s is not a valid integer amount!", value), 2)
			end
		else
			error(string.format("%s is not a valid damage type!", k), 2)
		end
	end
	setmetatable(damageList, meta)
	return damageList
end

local function SaveHitAttributes(handle, data)
	for k,t in pairs(HIT_ATTRIBUTE) do
		if t == "integer" then
			data[k] = NRD_HitGetInt(handle, k) or nil
		elseif t == "boolean" then
			data[k] = NRD_HitGetInt(handle, k) == 1 and true or false
		elseif t == "string" then
			data[k] = NRD_HitGetString(handle, k) or ""
		end
	end
	local total = 0

	for i,damageType in Data.DamageTypes:Get() do
		local amount = NRD_HitGetDamage(handle, damageType)
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

	setmetatable(data, self)

	return data
end

---Returns true if the hit isn't blocked, dodged, or missed.
---@return boolean
function HitPrepareData:Succeeded()
	return self.Blocked == false and self.Missed == false and self.Dodged == false
end

---Returns true if the hit isn't blocked, dodged, or missed.
---@return boolean
function HitPrepareData:ClearAllDamage()
	NRD_HitClearAllDamage(self.Handle)
	if self.Cached then
		self.DamageList = {}
	end
	self.TotalDamageDone = 0
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
			local amount = NRD_HitGetDamage(self.Handle, damageType) or 0
			if isChaos and damageType ~= "None" and amount > 0 then
				isChaos = false
			end
		end
	end
	return isChaos
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
			Cached = false
		}
		SaveHitAttributes(self.Handle, target)
	end
	local keys = {}
	for k,v in pairs(target) do
		keys[#keys+1] = k
	end
	table.sort(keys)
	local data = {}
	for _,k in ipairs(keys) do
		data[k] = target[k]
	end
	--return Ext.JsonStringify(data)
	return Lib.inspect(data)
end

Classes.HitPrepareData = HitPrepareData