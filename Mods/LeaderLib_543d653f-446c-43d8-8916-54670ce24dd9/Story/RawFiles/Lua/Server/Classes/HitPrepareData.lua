---A helper table for NRD_OnPrepareHit that retrieves all relevant flags and damage values.
---@class HitPrepareData
---@field TotalDamageDone integer
---@field DamageList table<string, integer>
---@field Handle integer
---@field IsChaos boolean
---@field Target string
---@field Source string
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
			if type(value) == "number" then
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
		source = source or "",
		DamageList = {}
	}
	if not skipAttributeLoading then
		if handle > -1 then
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
		end
	else
		data.DamageList = CreateDamageMetaList(handle)
	end

	setmetatable(data, self)

	return data
end

Classes.HitPrepareData = HitPrepareData