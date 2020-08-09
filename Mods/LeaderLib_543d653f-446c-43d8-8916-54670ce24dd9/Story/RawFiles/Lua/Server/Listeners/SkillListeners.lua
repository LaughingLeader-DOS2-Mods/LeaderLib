--- Gets the base skill from a skill.
--- @param skill string The skill entry to check.
--- @return string The base skill, if any, otherwise the skill that was passed in.
local function GetBaseSkill(skill, match)
	if skill ~= nil then
		local checkParent = true
		if match ~= nil and match ~= "" and not string.find(skill, match) then
			checkParent = false
		end
		if checkParent then
			local skill = Ext.StatGetAttribute(skill, "Using")
			if skill ~= nil then
				return GetBaseSkill(skill, match)
			end
		end
	end
	return skill
end

local function GetListeners(skill)
	local parsingAllTable = false
	local listeners = SkillListeners[skill]
	if listeners == nil then
		listeners = SkillListeners["All"] 
		parsingAllTable = true
	end
	if listeners ~= nil then
		local i = 0
		local count = #listeners
		return function ()
			i = i + 1
			if not parsingAllTable and i == count+1 then
				if SkillListeners["All"] ~= nil then
					listeners = SkillListeners["All"] 
					i = 1
					count = #listeners
					parsingAllTable = true
				end
			end

			if i <= count then
				return listeners[i]
			end
		end
	end
	return function() end
end

---A temporary table used to store data for a skill, including targets / skill information.
---@type table<string,SkillEventData>
local skillEventDataTable = {}

---@return SkillEventData
local function GetCharacterSkillData(skill, uuid, createIfMissing, skillType, skillAbility)
	local data = nil
	local skillDataHolder = skillEventDataTable[skill]
	if skillDataHolder ~= nil then
		data = skillDataHolder[uuid]
	elseif createIfMissing == true then
		skillDataHolder = {}
		skillEventDataTable[skill] = skillDataHolder
	end

	if data == nil and createIfMissing == true then
		data = Classes.SkillEventData:Create(uuid, skill, skillType, skillAbility)
		skillDataHolder[uuid] = data
	end
	return data
end

local function RemoveCharacterSkillData(uuid, skill)
	if skill ~= nil then
		local skillDataHolder = skillEventDataTable[skill]
		if skillDataHolder ~= nil then
			skillDataHolder[uuid] = nil
		end
	else
		-- Remove everything for this character
		for skill,data in pairs(skillEventDataTable) do
			if data[uuid] ~= nil then
				data[uuid] = nil
			end
		end
	end
end

function StoreSkillEventData(char, skill, skillType, skillAbility, ...)
	local listeners = SkillListeners[skill]
	if listeners ~= nil or SkillListeners["All"] ~= nil then
		local uuid = GetUUID(char)
		local eventParams = {...}
		---@type SkillEventData
		local data = GetCharacterSkillData(skill, uuid, true, skillType, skillAbility)
		if eventParams ~= nil then
			if #eventParams == 1 and not StringHelpers.IsNullOrEmpty(eventParams[1]) then
				data:AddTargetObject(eventParams[1])
			elseif #eventParams >= 3 then -- Position
				local x,y,z = table.unpack(eventParams)
				if x ~= nil and y ~= nil and z ~= nil then
					data:AddTargetPosition(x,y,z)
				end
			end
		end
	end
end

-- Example: Finding the base skill of an enemy skill
-- GetBaseSkill(skill, "Enemy")

function OnSkillPreparing(char, skillprototype)
	local skill = string.gsub(skillprototype, "_%-?%d+$", "")
	if CharacterIsControlled(char) == 0 then
		Osi.LeaderLib_LuaSkillListeners_IgnorePrototype(char, skillprototype, skill)
	end
	for callback in GetListeners(skill) do
		--PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillPreparing] char(",char,") skillprototype(",skillprototype,") skill(",skill,")")
		local status,err = xpcall(callback, debug.traceback, skill, GetUUID(char), SKILL_STATE.PREPARE)
		if not status then
			Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
		end
	end

	-- Clear previous data for this character in case SkillCast never fired (interrupted)
	RemoveCharacterSkillData(GetUUID(char))
end

-- Fires when CharacterUsedSkill fires. This happens after all the target events.
function OnSkillUsed(char, skill, ...)
	if skill ~= nil then
		Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char, skill)
	else
		Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char)
	end
	local uuid = GetUUID(char)
	local data = GetCharacterSkillData(skill, uuid)
	if data ~= nil then
		local status,err = nil,nil
		for callback in GetListeners(skill) do
			if Ext.IsDeveloperMode() then
				--PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillUsed] char(",char,") skill(",skill,") data(",data:ToString(),")")
				--PrintDebug("params(",Ext.JsonStringify({...}),")")
			end
			status,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.USED, data)
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end
end

function OnSkillCast(char, skill, ...)
	local uuid = GetUUID(char)
	---@type SkillEventData
	local data = GetCharacterSkillData(skill, uuid)
	if data ~= nil then
		local status,err = nil,nil
		for callback in GetListeners(skill) do
			if Ext.IsDeveloperMode() then
				--PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillCast] char(",char,") skill(",skill,") data(",data:ToString(),")")
				--PrintDebug("params(",Ext.JsonStringify({...}),")")
			end
			status,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.CAST, data)
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
		data:Clear()
		RemoveCharacterSkillData(uuid, skill)
	end
end

---@param source string
---@param skillprototype string
---@param target string
---@param handle integer
---@param damage integer
function OnSkillHit(source, skill, target, handle, damage)
	if skill ~= "" and skill ~= nil then
		local listeners = SkillListeners[skill]
		if listeners ~= nil then
			local uuid = GetUUID(source)
			---@type HitData
			local data = Classes.HitData:Create(GetUUID(target), GetUUID(source), damage, handle, skill)
			-- if Ext.IsDeveloperMode() then
			-- 	PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillHit] source(",source,") skill(",skill,") data(",Ext.JsonStringify(data),")")
			-- end
			for i,callback in ipairs(listeners) do
				local status,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.HIT, data)
				if not status then
					Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
				end
			end
		end

		if Features.ApplyBonusWeaponStatuses == true then
			local canApplyStatuses = target ~= nil and Ext.StatGetAttribute(skill, "UseWeaponProperties") == "Yes"
			if canApplyStatuses then
				---@type EsvCharacter
				local character = Ext.GetCharacter(source)
				for i,status in pairs(character:GetStatuses()) do
					local potion = nil
					if type(status) == "string" then
						potion = Ext.StatGetAttribute(status, "StatsId")
					elseif status.StatusId ~= nil then
						potion = Ext.StatGetAttribute(status.StatusId, "StatsId")
					end
					if potion ~= nil and potion ~= "" then
						local bonusWeapon = Ext.StatGetAttribute(potion, "BonusWeapon")
						if bonusWeapon ~= nil and bonusWeapon ~= "" then
							local extraProps = Ext.StatGetAttribute(bonusWeapon, "ExtraProperties")
							if extraProps ~= nil then
								GameHelpers.ApplyProperties(target, source, extraProps)
							end
						end
					end
				end
			end
		end
	end
end