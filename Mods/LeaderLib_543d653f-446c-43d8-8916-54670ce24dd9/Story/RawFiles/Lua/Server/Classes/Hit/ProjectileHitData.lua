---Data passed to hit callbacks, such as the various functions in SkillListeners.lua
---@class ProjectileHitData
---@field TargetObject EsvCharacter|EsvItem|nil
---@field AttackerObject EsvCharacter|EsvItem|nil
---@field Position vec3
---@field Projectile EsvProjectile
local ProjectileHitData = {
	Type = "ProjectileHitData",
	Target = "",
	Attacker = "",
	Skill = ""
}

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
	setmetatable(this, {
		__index = function (_,k)
			if k == "TargetObject" and not StringHelpers.IsNullOrEmpty(this.Target) then
				return GameHelpers.TryGetObject(this.Target)
			elseif k == "AttackerObject" and not StringHelpers.IsNullOrEmpty(this.Attacker) then
				return GameHelpers.TryGetObject(this.Attacker)
			end
			return ProjectileHitData[k]
		end
	})
    return this
end

function ProjectileHitData:Print()
	fprint(LOGLEVEL.TRACE, "[LeaderLib:ProjectileHitData]")
	fprint(LOGLEVEL.TRACE, "============")
	self:PrintTargets()
	fprint(LOGLEVEL.TRACE, "============")
end
function ProjectileHitData:PrintTargets()
	fprint(LOGLEVEL.TRACE, "[ProjectileHitData:%s] Target(%s) Position(%s)", self.Skill, self.Target, Ext.DumpExport(self.Position))
end

Classes.ProjectileHitData = ProjectileHitData