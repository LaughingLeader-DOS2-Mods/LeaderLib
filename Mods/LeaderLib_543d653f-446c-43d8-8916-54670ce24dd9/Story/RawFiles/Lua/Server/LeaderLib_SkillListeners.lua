SKILL_STATE = LeaderLib.SKILL_STATE

local function GetRealSkill(id)
	if id ~= nil then
		if string.find(id, "Enemy") then
			local skill = Ext.StatGetAttribute(id, "Using")
			if skill ~= nil then
				return GetRealSkill(skill)
			end
		end
	end
	return id
end

function OnSkillPreparing(char, skillprototype)
	local skill = GetRealSkill(string.gsub(skillprototype, "_%-?%d+$", ""))
	if CharacterIsControlled(char) == 0 then
		Osi.LeaderLib_LuaSkillListeners_IgnorePrototype(char, skillprototype, skill)
	end
	LeaderLib.Print("[LeaderLib_SkillListeners.lua:OnSkillPreparing] char(",char,") skillprototype(",skillprototype,") skill(",skill,")")
	local listeners = LeaderLib.SkillListeners[skill]
	if listeners ~= nil then
		for i,callback in ipairs(listeners) do
			local status,err = xpcall(callback, debug.traceback, GetUUID(char), SKILL_STATE.PREPARE)
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end
end

function OnSkillUsed(char, skillUsed, ...)
	local skill = GetRealSkill(skillUsed)
	if skill ~= nil then
		Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char, skill)
	else
		Osi.LeaderLib_LuaSkillListeners_RemoveIgnoredPrototype(char)
	end
	LeaderLib.Print("[LeaderLib_SkillListeners.lua:OnSkillUsed] char(",char,") skillUsed(",skillUsed,") skill(",skill,") params(",Ext.JsonStringify({...}),")")
	local listeners = LeaderLib.SkillListeners[skill]
	if listeners ~= nil then
		for i,callback in ipairs(listeners) do
			local status,err = xpcall(callback, debug.traceback, GetUUID(char), SKILL_STATE.USED, {...})
			if not status then
				Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
			end
		end
	end
end

function OnSkillCast(char, skillUsed, ...)
	local skill = GetRealSkill(skillUsed)
	LeaderLib.Print("[LeaderLib_SkillListeners.lua:OnSkillCast] char(",char,") skillUsed(",skillUsed,") skill(",skill,") params(",Ext.JsonStringify({...}),")")
	local listeners = LeaderLib.SkillListeners[skill]
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
		local skill = GetRealSkill(string.gsub(skillprototype, "_%-?%d+$", ""))
		LeaderLib.Print("[LeaderLib_SkillListeners.lua:OnSkillHit] char(",char,") skillprototype(",skillprototype,") skill(",skill,") params(",Ext.JsonStringify({...}),")")
		local listeners = LeaderLib.SkillListeners[skill]
		if listeners ~= nil then
			for i,callback in ipairs(listeners) do
				local status,err = xpcall(callback, debug.traceback, GetUUID(char), SKILL_STATE.HIT, {...})
				if not status then
					Ext.PrintError("[LeaderLib_SkillListeners] Error invoking function:\n", err)
				end
			end
		end
	end
end