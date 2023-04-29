---@class ResistancePenetrationTagEntry
---@field Tag string
---@field Amount integer

---@type table<string, ResistancePenetrationTagEntry[]>
Data.ResistancePenetrationTags = {
	Water = {
			[1] = {Tag="LeaderLib_ResistancePenetration_Water5", Amount=5},
			[2] = {Tag="LeaderLib_ResistancePenetration_Water10", Amount=10},
			[3] = {Tag="LeaderLib_ResistancePenetration_Water15", Amount=15},
			[4] = {Tag="LeaderLib_ResistancePenetration_Water20", Amount=20},
			[5] = {Tag="LeaderLib_ResistancePenetration_Water25", Amount=25},
			[6] = {Tag="LeaderLib_ResistancePenetration_Water30", Amount=30},
			[7] = {Tag="LeaderLib_ResistancePenetration_Water35", Amount=35},
			[8] = {Tag="LeaderLib_ResistancePenetration_Water40", Amount=40},
			[9] = {Tag="LeaderLib_ResistancePenetration_Water45", Amount=45},
			[10] = {Tag="LeaderLib_ResistancePenetration_Water50", Amount=50},
	},
	Physical = {
			[1] = {Tag="LeaderLib_ResistancePenetration_Physical5", Amount=5},
			[2] = {Tag="LeaderLib_ResistancePenetration_Physical10", Amount=10},
			[3] = {Tag="LeaderLib_ResistancePenetration_Physical15", Amount=15},
			[4] = {Tag="LeaderLib_ResistancePenetration_Physical20", Amount=20},
			[5] = {Tag="LeaderLib_ResistancePenetration_Physical25", Amount=25},
			[6] = {Tag="LeaderLib_ResistancePenetration_Physical30", Amount=30},
			[7] = {Tag="LeaderLib_ResistancePenetration_Physical35", Amount=35},
			[8] = {Tag="LeaderLib_ResistancePenetration_Physical40", Amount=40},
			[9] = {Tag="LeaderLib_ResistancePenetration_Physical45", Amount=45},
			[10] = {Tag="LeaderLib_ResistancePenetration_Physical50", Amount=50},
	},
	Fire = {
			[1] = {Tag="LeaderLib_ResistancePenetration_Fire5", Amount=5},
			[2] = {Tag="LeaderLib_ResistancePenetration_Fire10", Amount=10},
			[3] = {Tag="LeaderLib_ResistancePenetration_Fire15", Amount=15},
			[4] = {Tag="LeaderLib_ResistancePenetration_Fire20", Amount=20},
			[5] = {Tag="LeaderLib_ResistancePenetration_Fire25", Amount=25},
			[6] = {Tag="LeaderLib_ResistancePenetration_Fire30", Amount=30},
			[7] = {Tag="LeaderLib_ResistancePenetration_Fire35", Amount=35},
			[8] = {Tag="LeaderLib_ResistancePenetration_Fire40", Amount=40},
			[9] = {Tag="LeaderLib_ResistancePenetration_Fire45", Amount=45},
			[10] = {Tag="LeaderLib_ResistancePenetration_Fire50", Amount=50},
	},
	Piercing = {
			[1] = {Tag="LeaderLib_ResistancePenetration_Piercing5", Amount=5},
			[2] = {Tag="LeaderLib_ResistancePenetration_Piercing10", Amount=10},
			[3] = {Tag="LeaderLib_ResistancePenetration_Piercing15", Amount=15},
			[4] = {Tag="LeaderLib_ResistancePenetration_Piercing20", Amount=20},
			[5] = {Tag="LeaderLib_ResistancePenetration_Piercing25", Amount=25},
			[6] = {Tag="LeaderLib_ResistancePenetration_Piercing30", Amount=30},
			[7] = {Tag="LeaderLib_ResistancePenetration_Piercing35", Amount=35},
			[8] = {Tag="LeaderLib_ResistancePenetration_Piercing40", Amount=40},
			[9] = {Tag="LeaderLib_ResistancePenetration_Piercing45", Amount=45},
			[10] = {Tag="LeaderLib_ResistancePenetration_Piercing50", Amount=50},
	},
	Earth = {
			[1] = {Tag="LeaderLib_ResistancePenetration_Earth5", Amount=5},
			[2] = {Tag="LeaderLib_ResistancePenetration_Earth10", Amount=10},
			[3] = {Tag="LeaderLib_ResistancePenetration_Earth15", Amount=15},
			[4] = {Tag="LeaderLib_ResistancePenetration_Earth20", Amount=20},
			[5] = {Tag="LeaderLib_ResistancePenetration_Earth25", Amount=25},
			[6] = {Tag="LeaderLib_ResistancePenetration_Earth30", Amount=30},
			[7] = {Tag="LeaderLib_ResistancePenetration_Earth35", Amount=35},
			[8] = {Tag="LeaderLib_ResistancePenetration_Earth40", Amount=40},
			[9] = {Tag="LeaderLib_ResistancePenetration_Earth45", Amount=45},
			[10] = {Tag="LeaderLib_ResistancePenetration_Earth50", Amount=50},
	},
	Air = {
			[1] = {Tag="LeaderLib_ResistancePenetration_Air5", Amount=5},
			[2] = {Tag="LeaderLib_ResistancePenetration_Air10", Amount=10},
			[3] = {Tag="LeaderLib_ResistancePenetration_Air15", Amount=15},
			[4] = {Tag="LeaderLib_ResistancePenetration_Air20", Amount=20},
			[5] = {Tag="LeaderLib_ResistancePenetration_Air25", Amount=25},
			[6] = {Tag="LeaderLib_ResistancePenetration_Air30", Amount=30},
			[7] = {Tag="LeaderLib_ResistancePenetration_Air35", Amount=35},
			[8] = {Tag="LeaderLib_ResistancePenetration_Air40", Amount=40},
			[9] = {Tag="LeaderLib_ResistancePenetration_Air45", Amount=45},
			[10] = {Tag="LeaderLib_ResistancePenetration_Air50", Amount=50},
	},
	Poison = {
			[1] = {Tag="LeaderLib_ResistancePenetration_Poison5", Amount=5},
			[2] = {Tag="LeaderLib_ResistancePenetration_Poison10", Amount=10},
			[3] = {Tag="LeaderLib_ResistancePenetration_Poison15", Amount=15},
			[4] = {Tag="LeaderLib_ResistancePenetration_Poison20", Amount=20},
			[5] = {Tag="LeaderLib_ResistancePenetration_Poison25", Amount=25},
			[6] = {Tag="LeaderLib_ResistancePenetration_Poison30", Amount=30},
			[7] = {Tag="LeaderLib_ResistancePenetration_Poison35", Amount=35},
			[8] = {Tag="LeaderLib_ResistancePenetration_Poison40", Amount=40},
			[9] = {Tag="LeaderLib_ResistancePenetration_Poison45", Amount=45},
			[10] = {Tag="LeaderLib_ResistancePenetration_Poison50", Amount=50},
	},
}

--[[
Generate with this:
for damageType,_ in pairs(Data.DamageTypeToResistance) do
	if Data.ResistancePenetrationTags[damageType] == nil then
		Data.ResistancePenetrationTags[damageType] = {}
	end
	for amount=5,50,5 do
		local tag = string.format("LeaderLib_ResistancePenetration_%s%i", damageType,amount)
		table.insert(Data.ResistancePenetrationTags[damageType], {Tag=tag,Amount=amount})
	end
end
 ]]

Data.ResistancePenetrationAttributes = {
	PhysicalResistancePenetration = "Physical",
	PiercingResistancePenetration = "Piercing",
	CorrosiveResistancePenetration = "Corrosive",
	MagicResistancePenetration = "Magic",
	AirResistancePenetration = "Air",
	EarthResistancePenetration = "Earth",
	FireResistancePenetration = "Fire",
	PoisonResistancePenetration = "Poison",
	ShadowResistancePenetration = "Shadow",
	WaterResistancePenetration = "Water",
}

local _DamageTypeToResPen = {
	Physical = "PhysicalResistancePenetration",
	Piercing = "PiercingResistancePenetration",
	Corrosive = "CorrosiveResistancePenetration",
	Magic = "MagicResistancePenetration",
	Air = "AirResistancePenetration",
	Earth = "EarthResistancePenetration",
	Fire = "FireResistancePenetration",
	Poison = "PoisonResistancePenetration",
	Shadow = "ShadowResistancePenetration",
	Water = "WaterResistancePenetration",
}

---@param object AnyObjectInstanceType
local function _GetTaggedResistancePenetration(object)
	local results = {}
	local tags = GameHelpers.GetAllTags(object, true, true)
	for tag,_ in pairs(tags) do
		---@diagnostic disable-next-line
		local damageType,amount = GameHelpers.ParseResistancePenetrationTag(tag)
		if damageType then
			if results[damageType] == nil then
				results[damageType] = 0
			end
			results[damageType] = results[damageType] + amount
		end
	end
	return results
end

---Get the total amount of resistance penetration for a character or item.  
---This is a custom attribute added by LeaderLib (i.e. `FireResistancePenetration`).  
---@overload fun(object:ObjectParam):table<DamageType, integer>
---@overload fun(object:ObjectParam, damageType:DamageType):integer
---@param object ObjectParam
---@param damageType DamageType Get the amount for a specific damage type.
---@param skipTagCheck boolean Skip checking for the deprecated resistance pen tags when calculating the amount.
---@return table<DamageType, integer>
function GameHelpers.Stats.GetResistancePenetration(object, damageType, skipTagCheck)
	object = GameHelpers.TryGetObject(object)
	if not object then
		return damageType and 0 or {}
	end
	local taggedPen = not skipTagCheck and _GetTaggedResistancePenetration(object) or {}
	if damageType then
		local attribute = _DamageTypeToResPen[damageType]
		return (object.Stats[attribute] or 0) + (taggedPen[damageType] or 0)
	else
		local results = {}
		for attribute,dType in pairs(Data.ResistancePenetrationAttributes) do
			local amount = object.Stats[attribute] or 0
			if taggedPen[damageType] then
				amount = amount + taggedPen[damageType]
			end
			if amount > 0 then
				results[dType] = amount
			end
		end
		return results
	end
end