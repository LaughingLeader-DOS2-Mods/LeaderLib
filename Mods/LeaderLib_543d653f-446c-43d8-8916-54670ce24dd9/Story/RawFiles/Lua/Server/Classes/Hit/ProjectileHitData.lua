---Data passed to hit callbacks, such as the various functions in SkillListeners.lua
---@class ProjectileHitData
local ProjectileHitData = {
	Type = "ProjectileHitData",
	Target = "",
	Attacker = "",
	Skill = "",
	---@type EsvProjectile
	Projectile = nil,
	---@type number[]
	Position = nil,
}
ProjectileHitData.__index = ProjectileHitData

---@param target string The source of the skill.
---@param attacker string
---@param projectile EsvProjectile
---@param position number[]
---@param skill string|nil
---@return ProjectileHitData
function ProjectileHitData:Create(target, attacker, projectile, position, skill)
	---@type ProjectileHitData
    local this =
    {
		Target = target,
		Attacker = attacker,
		--Projectile = GameHelpers.Ext.ProjectileToTable(projectile),
		Projectile = projectile,
		Position = position,
		Skill = skill
	}
	setmetatable(this, self)
    return this
end

function ProjectileHitData:Print()
	fprint(LOGLEVEL.TRACE, "[LeaderLib:ProjectileHitData]")
	fprint(LOGLEVEL.TRACE, "============")
	self:PrintTargets()
	fprint(LOGLEVEL.TRACE, "============")
end
function ProjectileHitData:PrintTargets()
	fprint(LOGLEVEL.TRACE, "[ProjectileHitData:%s] Target(%s) Position(%s)", self.Skill, self.Target, Common.Dump(self.Position))
end

Classes.ProjectileHitData = ProjectileHitData