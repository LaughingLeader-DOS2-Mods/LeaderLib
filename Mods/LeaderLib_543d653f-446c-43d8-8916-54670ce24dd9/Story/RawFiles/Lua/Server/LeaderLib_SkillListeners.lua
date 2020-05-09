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
			local status,err = xpcall(callback, debug.traceback, GetUUID(char), SKILL_STATE.PREPARE)
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end
end

function OnSkillUsed(char, skill, ...)
	if skill ~= nil then
		Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char, skill)
	else
		Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char)
	end
	PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillUsed] char(",char,") skill(",skill,") params(",Ext.JsonStringify({...}),")")
	local listeners = SkillListeners[skill]
	if listeners ~= nil then
		for i,callback in ipairs(listeners) do
			local status,err = xpcall(callback, debug.traceback, GetUUID(char), SKILL_STATE.USED, {...})
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end
end

function OnSkillCast(char, skill, ...)
	PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillCast] char(",char,") skill(",skill,") params(",Ext.JsonStringify({...}),")")
	local listeners = SkillListeners[skill]
	if listeners ~= nil then
		for i,callback in ipairs(listeners) do
			local status,err = xpcall(callback, debug.traceback, GetUUID(char), SKILL_STATE.CAST, {...})
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end
end

function OnSkillHit(char, skillprototype, ...)
	if skillprototype ~= "" and skillprototype ~= nil then
		local skill = string.gsub(skillprototype, "_%-?%d+$", "")
		local listeners = SkillListeners[skill]
		if listeners ~= nil then
			PrintDebug("[LeaderLib_SkillListeners.lua:OnSkillHit] char(",char,") skillprototype(",skillprototype,") skill(",skill,") params(",Ext.JsonStringify({...}),")")
			for i,callback in ipairs(listeners) do
				local status,err = xpcall(callback, debug.traceback, GetUUID(char), SKILL_STATE.HIT, {...})
				if not status then
					Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
				end
			end
		end
	end
end