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
---@param success boolean|nil
---@return HitData
function HitData:Create(target, attacker, damage, handle, skill, success)
	---@type HitData
    local this =
    {
		Target = target,
		Attacker = attacker,
		Damage = damage,
		Handle = handle,
		Success = true
	}
	if success ~= nil then
		this.Success = success
	else
		---@type EsvStatusHit
		local status = Ext.GetStatus(target, handle)
		if status then
			if status.Hit then
				this.Success = GameHelpers.Hit.Succeeded(status.Hit)
			else
				this.Success = GameHelpers.HitSucceeded(target, handle, 0)
			end
		else
			this.Success = GameHelpers.HitSucceeded(target, handle, 1)
		end
	end
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
	PrintDebug("[LeaderLib:HitData]")
	PrintDebug("============")
	self:PrintTargets()
	PrintDebug("============")
end
function HitData:PrintTargets()
	fprint(LOGLEVEL.TRACE, "[HitData:%s] Target(%s)", self.Handle, self.Target)
end

Classes.HitData = HitData