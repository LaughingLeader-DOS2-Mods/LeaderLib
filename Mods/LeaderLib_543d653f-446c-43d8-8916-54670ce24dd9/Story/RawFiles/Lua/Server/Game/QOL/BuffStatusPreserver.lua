--local c = Ext.GetCharacter(CharacterGetHostCharacter()); for i,s in pairs(c:GetStatusObjects()) do print(getmetatable(s));print(s.StatusType);print(s.StatsId); end

local potionProperties = {
"VitalityBoost",
"Strength",
"Finesse",
"Intelligence",
"Constitution",
"Memory",
"Wits",
"SingleHanded",
"TwoHanded",
"Ranged",
"DualWielding",
"RogueLore",
"WarriorLore",
"RangerLore",
"FireSpecialist",
"WaterSpecialist",
"AirSpecialist",
"EarthSpecialist",
"Sourcery",
"Necromancy",
"Polymorph",
"Summoning",
"PainReflection",
"Perseverance",
"Leadership",
"Telekinesis",
"Sneaking",
"Thievery",
"Loremaster",
"Repair",
"Barter",
"Persuasion",
"Luck",
"FireResistance",
"EarthResistance",
"WaterResistance",
"AirResistance",
"PoisonResistance",
"PhysicalResistance",
"PiercingResistance",
"Sight",
"Hearing",
"Initiative",
"Vitality",
"VitalityPercentage",
"MagicPoints",
"ActionPoints",
"ChanceToHitBoost",
"AccuracyBoost",
"DodgeBoost",
"DamageBoost",
"APCostBoost",
"SPCostBoost",
"APMaximum",
"APStart",
"APRecovery",
"Movement",
"MovementSpeedBoost",
"Armor",
"MagicArmor",
"ArmorBoost",
"MagicArmorBoost",
"CriticalChance",
--"Reflection",
"RangeBoost",
"LifeSteal",
}

---@param potion StatEntryPotion
local function IsBuffPotion(potion)
	if potion.IsFood == "Yes" or potion.IsConsumable == "Yes" then
		return false
	end
	for _,k in pairs(potionProperties) do
		local v = potion[k]
		if v and type(v) == "number" and v > 0 then
			return true
		end
	end
	return false
end

---@param character EsvCharacter
---@param status EsvStatus
local function PreserveBuffStatus(character, status)
	print(status.StatusId, status.CurrentLifeTime, status.LifeTime, status.KeepAlive, status.IsLifeTimeSet)
	if status.CurrentLifeTime > 0 then
		if GetStatusType(status.StatusId) == "CONSUME" and not StringHelpers.IsNullOrWhitespace(status.StatsId) then
			local potion = Ext.GetStat(status.StatsId)
			print("IsBuffPotion(potion)", IsBuffPotion(potion))
			if potion and IsBuffPotion(potion) then
				if not PersistentVars.ScriptData then
					PersistentVars.ScriptData = {}
				end
				if not PersistentVars.ScriptData[character.MyGuid] then
					PersistentVars.ScriptData[character.MyGuid] = {}
				end
				PersistentVars.ScriptData[character.MyGuid][status.StatusId] = status.CurrentLifeTime
				local nextStatus = Ext.PrepareStatus(character.MyGuid, status.StatusId, -1.0)
				nextStatus.CurrentLifeTime = -1.0
				nextStatus.LifeTime = -1.0
				nextStatus.ForceStatus = true
				nextStatus.StatusSourceHandle = status.StatusSourceHandle
				Ext.ApplyStatus(nextStatus)
				-- status.CurrentLifeTime = -1.0
				-- status.LifeTime = -1.0
				-- status.RequestClientSync = true
				-- status.KeepAlive = false
				-- status.IsLifeTimeSet = true
				-- print("Preserving", status.StatusId, potion.Name, status.CurrentLifeTime)
				-- local handle = NRD_StatusGetHandle(character.MyGuid, status.StatusId)
				-- NRD_StatusSetReal(character.MyGuid, handle, "CurrentLifeTime", -1.0)
				-- NRD_StatusSetReal(character.MyGuid, handle, "LifeTime", -1.0)
			end
		end
	end
end

---@param character EsvCharacter
local function PreserveBuffStatuses(character)
	for _,status in pairs(character:GetStatusObjects()) do
		PreserveBuffStatus(character, status)
	end
end

-- Ext.RegisterOsirisListener("ObjectLeftCombat", 2, "after", function(obj)
-- 	if GameHelpers.Character.IsPlayerOrPartyMember(obj) then
-- 		PreserveBuffStatuses(Ext.GetCharacter(obj))
-- 	end
-- end)

-- Ext.RegisterOsirisListener("ObjectEnteredCombat", 2, "after", function(obj)
-- 	local character = Ext.GetCharacter(obj)
-- 	local data = PersistentVars.ScriptData and PersistentVars.ScriptData[character.MyGuid] or nil
-- 	if data then
-- 		for id,duration in pairs(data) do
-- 			local status = character:GetStatus(id)
-- 			if status then
-- 				status.CurrentLifeTime = duration
-- 				status.LifeTime = duration
-- 				status.RequestClientSync = true
-- 			end
-- 		end
-- 		PersistentVars.ScriptData[character.MyGuid] = nil
-- 	end
-- end)

-- Ext.RegisterOsirisListener("CharacterStatusApplied", 3, "after", function(obj,id,source)
-- 	if CharacterIsInCombat(obj) == 0 and GameHelpers.Character.IsPlayerOrPartyMember(obj) then
-- 		local character = Ext.GetCharacter(obj)
-- 		PreserveBuffStatus(character, character:GetStatus(id))
-- 	end
-- end)