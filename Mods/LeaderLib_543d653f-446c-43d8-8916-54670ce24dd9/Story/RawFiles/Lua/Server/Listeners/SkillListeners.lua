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

-- Example: Finding the base skill of an enemy skill
-- GetBaseSkill(skill, "Enemy")

function OnSkillPreparing(char, skillprototype)
	local skill = string.gsub(skillprototype, "_%-?%d+$", "")
	if CharacterIsControlled(char) == 0 then
		Osi.LeaderLib_LuaSkillListeners_IgnorePrototype(char, skillprototype, skill)
	end
	PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillPreparing] char(",char,") skillprototype(",skillprototype,") skill(",skill,")")
	local listeners = SkillListeners[skill]
	if listeners ~= nil then
		for i,callback in ipairs(listeners) do
			local status,err = xpcall(callback, debug.traceback, skill, GetUUID(char), SKILL_STATE.PREPARE)
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end
end

---A temporary table used to store data for a skill, including targets / skill information.
---@type table<string,SkillEventData>
local skillEventDataTable = {}

local function GetCharacterSkillData(skill, uuid, skillType, skillAbility)
	local data = nil
	local skillDataHolder = skillEventDataTable[skill]
	if skillDataHolder ~= nil then
		data = skillDataHolder[uuid]
	else
		skillDataHolder = {}
		skillEventDataTable[skill] = skillDataHolder
	end

	if data == nil then
		data = Classes.SkillEventData:Create(uuid, skill, skillType, skillAbility)
		skillDataHolder[uuid] = data
		print("[GetCharacterSkillData] data created for skill/caster | skillEventDataTable", Ext.JsonStringify(skillEventDataTable))
	end
	return data
end

local function RemoveCharacterSkillData(uuid, skill)
	local skillDataHolder = skillEventDataTable[skill]
	if skillDataHolder ~= nil then
		skillDataHolder[uuid] = nil
	end
end

function StoreSkillData(char, skill, skillType, skillAbility, ...)
	local listeners = SkillListeners[skill]
	if listeners ~= nil then
		local uuid = GetUUID(char)
		local eventParams = {...}
		---@type SkillEventData
		local data = GetCharacterSkillData(skill, uuid, skillType, skillAbility)
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

-- Fires when CharacterUsedSkill fires. This happens after all the target events.
function OnSkillUsed(char, skill, ...)
	if skill ~= nil then
		Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char, skill)
	else
		Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char)
	end
	local listeners = SkillListeners[skill]
	if listeners ~= nil then
		local uuid = GetUUID(char)
		local eventParams = {...}
		local data = GetCharacterSkillData(skill, uuid)
		local hasSkillData = data ~= nil
		for i,callback in ipairs(listeners) do
			local status = nil
			local err = nil
			if hasSkillData then
				if Ext.IsDeveloperMode() then
					PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillUsed] char(",char,") skill(",skill,") params(",Ext.JsonStringify(eventParams),") data(",data:ToString(),")")
				end
				status,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.USED, data, eventParams)
			else
				status,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.USED, eventParams)
			end
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end
end

function OnSkillCast(char, skill, ...)
	local listeners = SkillListeners[skill]
	if listeners ~= nil then
		local uuid = GetUUID(char)
		local eventParams = {...}
		local data = GetCharacterSkillData(skill, uuid)
		local hasSkillData = data ~= nil
		for i,callback in ipairs(listeners) do
			local status = nil
			local err = nil
			if hasSkillData then
				if Ext.IsDeveloperMode() then
					PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillCast] char(",char,") skill(",skill,") params(",Ext.JsonStringify(eventParams),") data(",data:ToString(),")")
				end
				status,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.CAST, data, eventParams)
			else
				status,err = xpcall(callback, debug.traceback, skill, uuid, SKILL_STATE.CAST, nil, eventParams)
			end
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end

		if data ~= nil then
			RemoveCharacterSkillData(skill, uuid)
		end
	end
end

---@param source string
---@param skillprototype string
---@param target string
---@param handle integer
---@param damage integer
function OnSkillHit(source, skillprototype, target, handle, damage)
	if skillprototype ~= "" and skillprototype ~= nil then
		local skill = string.gsub(skillprototype, "_%-?%d+$", "")
		local listeners = SkillListeners[skill]
		if listeners ~= nil then
			---@type HitData
			local data = Classes.HitData:Create(target, source, damage, handle, skill)
			if Ext.IsDeveloperMode() then
				PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillHit] char(",char,") skillprototype(",skillprototype,") skill(",skill,") data(",Ext.JsonStringify(data),")")
			end
			for i,callback in ipairs(listeners) do
				local status,err = xpcall(callback, debug.traceback, skill, GetUUID(char), SKILL_STATE.HIT, data)
				if not status then
					Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
				end
			end
		end

		if Features.ApplyBonusWeaponStatuses == true then
			local target = params[1]
			local canApplyStatuses = target ~= nil and Ext.StatGetAttribute(skill, "UseWeaponProperties") == "Yes"
			if canApplyStatuses then
				PrintDebug("Skill Hit:", skill, ". Checking for statuses with a BonusWeapon")
				---@type EsvCharacter
				local character = Ext.GetCharacter(char)
				for i,status in pairs(character:GetStatuses()) do
					if NRD_StatAttributeExists(status, "StatsId") == 1 then
						local potion = Ext.StatGetAttribute(status, "StatsId")
						if potion ~= nil and potion ~= "" then
							local bonusWeapon = Ext.StatGetAttribute(potion, "BonusWeapon")
							if bonusWeapon ~= nil and bonusWeapon ~= "" then
								local extraProps = Ext.StatGetAttribute(bonusWeapon, "ExtraProperties")
								if extraProps ~= nil then
									GameHelpers.ApplyProperties(target, char, extraProps)
								end
							end
						end
					end
				end
			end
		end
	end
end