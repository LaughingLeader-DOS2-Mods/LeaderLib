---@private
---@class BasicAttackListenerEntry
---@field Priority integer

---@private
---@class BasicAttackOnStartCallbackEntry : BasicAttackListenerEntry
---@field Callback BasicAttackOnStartCallback

---@private
---@class BasicAttackOnHitCallbackEntry : BasicAttackListenerEntry
---@field Callback BasicAttackOnHitCallback

---@private
---@class BasicAttackOnWeaponTagHitCallbackEntry : BasicAttackListenerEntry
---@field Callback BasicAttackOnWeaponTagHitCallback

---@private
---@class BasicAttackOnWeaponTypeHitCallbackEntry : BasicAttackListenerEntry
---@field Callback BasicAttackOnWeaponTypeHitCallback

---@alias BasicAttackOnStartCallback fun(attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], targetIsObject:boolean):void
---@alias BasicAttackOnHitCallback fun(attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], data:HitData|DamageList, targetIsObject:boolean, skill:StatEntrySkillData):void
---@alias BasicAttackOnWeaponTagHitCallback fun(tag:string, attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], data:HitData, targetIsObject:boolean, skill:StatEntrySkillData):void
---@alias BasicAttackOnWeaponTypeHitCallback fun(weaponType:string, attacker:EsvCharacter, target:EsvCharacter|EsvItem|number[], data:HitData, targetIsObject:boolean, skill:StatEntrySkillData):void

AttackManager = {
	OnStart = {
		---@private
		---@type BasicAttackOnStartCallbackEntry[]
		Listeners = {},

		---@param callback BasicAttackOnStartCallback
		---@param priority integer Optional priority to assign to this callback.
		Register = function(callback, priority)
			if type(priority) ~= "number" then
				priority = 99
			end
			table.insert(AttackManager.OnStart.Listeners, {Callback=callback, Priority = priority})
		end
	},
	OnHit = {
		---@private
		---@type BasicAttackOnHitCallbackEntry[]
		Listeners = {},

		---@param callback BasicAttackOnHitCallback
		---@param priority integer Optional priority to assign to this callback.
		Register = function(callback, priority)
			if type(priority) ~= "number" then
				priority = 99
			end
			table.insert(AttackManager.OnHit.Listeners, {Callback=callback, Priority = priority})
		end
	},
	OnWeaponTagHit = {
		---@private
		---@type table<string,BasicAttackOnWeaponTagHitCallbackEntry[]>
		Listeners = {},

		---Register a listener that fires when a hit occurs with a specific weapon tag.
		---@param tag string|string[]
		---@param callback BasicAttackOnWeaponTagHitCallback
		---@param priority integer Optional priority to assign to this callback.
		Register = function(tag, callback, priority)
			if type(priority) ~= "number" then
				priority = 99
			end
			local t = type(tag)
			if t == "table" then
				for k,v in pairs(tag) do 
					AttackManager.OnWeaponTagHit.Register(v, callback, priority) 
				end
			elseif t == "string" then
				if not AttackManager.OnWeaponTagHit.Listeners[tag] then
					AttackManager.OnWeaponTagHit.Listeners[tag] = {}
				end
				table.insert(AttackManager.OnWeaponTagHit.Listeners[tag], {Callback=callback, Priority = priority})
			end
		end
	},
	OnWeaponTypeHit = {
		---@private
		---@type table<string,BasicAttackOnWeaponTypeHitCallbackEntry[]>
		Listeners = {},

		---Register a listener that fires when a hit occurs with a specific weapon type.
		---@param weaponType string|string[]
		---@param callback BasicAttackOnWeaponTypeHitCallback
		---@param priority integer Optional priority to assign to this callback.
		Register = function(weaponType, callback, priority)
			if type(priority) ~= "number" then
				priority = 99
			end
			local t = type(weaponType)
			if t == "table" then
				for k,v in pairs(weaponType) do 
					AttackManager.OnWeaponTypeHit.Register(v, callback, priority) 
				end
			elseif t == "string" then
				if not AttackManager.OnWeaponTypeHit.Listeners[weaponType] then
					AttackManager.OnWeaponTypeHit.Listeners[weaponType] = {}
				end
				table.insert(AttackManager.OnWeaponTypeHit.Listeners[weaponType], {Callback=callback, Priority = priority})
			end
		end
	},
}

---@private
---@param a BasicAttackListenerEntry
---@param b BasicAttackListenerEntry
function AttackManager.PrioritySort(a, b)
	return a.Priority < b.Priority
end

---@private
function AttackManager.SortCallbacks()
	table.sort(AttackManager.OnHit.Listeners, AttackManager.PrioritySort)
	table.sort(AttackManager.OnStart.Listeners, AttackManager.PrioritySort)
	table.sort(AttackManager.OnWeaponTagHit.Listeners, AttackManager.PrioritySort)
	table.sort(AttackManager.OnWeaponTypeHit.Listeners, AttackManager.PrioritySort)
end

---@private
function AttackManager.InvokeCallbacks(tbl, ...)
	for k,v in pairs(tbl) do
		local b,err = xpcall(v.Callback, debug.traceback, ...)
		if not b then
			Ext.PrintError(err)
		end
	end
end

---@param attacker string
---@param target string
local function SaveBasicAttackTarget(attacker, target)
	if PersistentVars.BasicAttackData[attacker] == nil then
		PersistentVars.BasicAttackData[attacker] = {}
	end
	PersistentVars.BasicAttackData[attacker].Target = target
end

---@param attacker string
local function GetBasicAttackTarget(attacker)
	if PersistentVars.BasicAttackData ~= nil and PersistentVars.BasicAttackData[attacker] ~= nil then
		return PersistentVars.BasicAttackData[attacker]
	end
	return nil
end

local function OnBasicAttackTarget(target, owner, attacker)
	attacker = GameHelpers.GetCharacter(attacker)
	target = GameHelpers.TryGetObject(target)
	if attacker and target then
		AttackManager.InvokeCallbacks(AttackManager.OnStart.Listeners, attacker, target, true)
	end
end
Ext.RegisterOsirisListener("CharacterStartAttackObject", 3, "after", OnBasicAttackTarget)

local function OnBasicAttackPosition(x, y, z, owner, attacker)
	attacker = GameHelpers.GetCharacter(attacker)
	local target = {x,y,z}
	PersistentVars.StartAttackPosition[attacker.MyGuid] = target
	if attacker then
		AttackManager.InvokeCallbacks(AttackManager.OnStart.Listeners, attacker, target, false)
	end
end
Ext.RegisterOsirisListener("CharacterStartAttackPosition", 5, "after", OnBasicAttackPosition)

--- @param isFromHit boolean
--- @param attacker EsvCharacter|EsvItem
--- @param target EsvCharacter|EsvItem|number[]
--- @param data HitData|DamageList
--- @param skill StatEntrySkillData
function AttackManager.InvokeOnHit(isFromHit, attacker, target, data, skill)
	local targetIsObject = type(target) == "userdata"
	AttackManager.InvokeCallbacks(AttackManager.OnHit.Listeners, attacker, target, data, targetIsObject, skill)
	if GameHelpers.Ext.ObjectIsCharacter(attacker) then
		for tag,callbacks in pairs(AttackManager.OnWeaponTagHit.Listeners) do
			if GameHelpers.CharacterOrEquipmentHasTag(attacker, tag) then
				AttackManager.InvokeCallbacks(callbacks, tag, attacker, target, data, targetIsObject, skill)
			end
		end
		local weaponTypes = {}
		if attacker.Stats.MainWeapon then
			weaponTypes[attacker.Stats.MainWeapon.WeaponType] = true
		end
		if attacker.Stats.OffHandWeapon then
			weaponTypes[attacker.Stats.OffHandWeapon.WeaponType] = true
		end
		for weaponType,_ in pairs(weaponTypes) do
			local callbacks = AttackManager.OnWeaponTypeHit.Listeners[weaponType]
			if callbacks then
				AttackManager.InvokeCallbacks(callbacks, weaponType, attacker, target, data, targetIsObject, skill)
			end
		end
	end
end

--- @param caster EsvGameObject
--- @param position number[]
--- @param damageList DamageList
RegisterProtectedExtenderListener("GroundHit", function(caster, position, damageList)
	--Also fires when a projectile hits the ground (exploding projectiles too!), so we need this table entry
	if caster and PersistentVars.StartAttackPosition[caster.MyGuid] then
		PersistentVars.StartAttackPosition[caster.MyGuid] = nil
		AttackManager.InvokeOnHit(false, caster, position, damageList)
	end
end)