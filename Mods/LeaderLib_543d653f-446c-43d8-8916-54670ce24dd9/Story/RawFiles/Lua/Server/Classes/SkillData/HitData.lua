---Data passed to hit callbacks, such as the various functions in SkillListeners.lua
---@class HitData
local HitData = {
	ID = "HitData",
	Target = "",
	Attacker = "",
	Skill = "",
	Damage = 0,
	Handle = 0,
	IsFromSkll = false,
	---@type boolean The hit did not miss.
	Success = true
}
HitData.__index = HitData

---@param target string The source of the skill.
---@param attacker string
---@param damage integer
---@param handle integer
---@param skill string|nil
---@return HitData
function HitData:Create(target, attacker, damage, handle, skill)
	---@type HitData
    local this =
    {
		Target = target,
		Attacker = attacker,
		Damage = damage,
		Handle = handle,
		Success = GameHelpers.HitSucceeded(target, handle, 0)
	}
	if StringHelpers.IsNullOrEmpty(this.Target) then
		this.Success = false
	end
	if skill ~= nil then
		this.Skill = skill
		this.IsFromSkll = true
	end
	setmetatable(this, self)
    return this
end

function HitData:PrintTargets()
	fprint(LOGLEVEL.TRACE, "[HitData:%s] Target(%s)", self.Handle, self.Target)
end

Classes.HitData = HitData