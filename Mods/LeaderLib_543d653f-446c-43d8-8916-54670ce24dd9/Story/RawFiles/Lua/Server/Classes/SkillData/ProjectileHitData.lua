---Data passed to hit callbacks, such as the various functions in SkillListeners.lua
---@class ProjectileHitData
local ProjectileHitData = {
	ID = "ProjectileHitData",
	Target = "",
	Attacker = "",
	Skill = "",
	Projectile = nil,
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

Classes.ProjectileHitData = ProjectileHitData