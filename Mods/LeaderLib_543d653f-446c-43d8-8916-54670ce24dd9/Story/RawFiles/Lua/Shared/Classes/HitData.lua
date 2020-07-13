---Data passed to hit callbacks, such as the various functions in SkillListeners.lua
---@class HitData
local HitData = {
	ID = "HitData",
	Target = "",
	Attacker = "",
	Skill = "",
	IsFromSkll = false
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
		Handle = handle
	}
	if skill ~= nil then
		this.Skill = skill
		this.IsFromSkll = true
	end
	setmetatable(this, self)
    return this
end

Classes["HitData"] = HitData