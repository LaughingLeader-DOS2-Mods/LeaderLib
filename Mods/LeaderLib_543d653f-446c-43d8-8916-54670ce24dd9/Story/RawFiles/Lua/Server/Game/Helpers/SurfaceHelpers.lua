if GameHelpers.Surface == nil then
	GameHelpers.Surface = {}
end

---@param startPos number[]
---@param endPos number[]
function GameHelpers.Surface.CreateRectSurface(startPos, endPos, surface, width, lengthModifier, duration, speed, statusChance, deathType, owner, lineCheckBlock)
	Ext.EnableExperimentalPropertyWrites()
	---@type EsvRectangleSurfaceAction
	local surf = Ext.CreateSurfaceAction("RectangleSurfaceAction")
	surf.Position = startPos
	surf.Target = endPos
	surf.SurfaceType = surface or "Water"
	surf.SurfaceArea = width or 1.0
	surf.Width = width or 1.0
	surf.Length = GameHelpers.Math.GetDistance(startPos, endPos) + (lengthModifier or 0)
	surf.Duration = duration or 3.0
	surf.StatusChance = statusChance or 1.0
	surf.GrowStep = speed or 128
	surf.LineCheckBlock = lineCheckBlock or 0
	surf.DeathType = deathType or "DoT"
	surf.OwnerHandle = owner or nil
	return surf
end

---@type table<integer,EsvChangeSurfaceOnPathAction>
local surfaceActions = {}

local function CreateFollowSurface(projectile)
	Ext.EnableExperimentalPropertyWrites()
	---@type EsvChangeSurfaceOnPathAction
	local surf = Ext.CreateSurfaceAction("ChangeSurfaceOnPathAction")
	surf.FollowObject = projectile.Handle
	surf.SurfaceType = "FrostCloud"
	--surf.SurfaceLayer = 0
	surf.Radius = 4.0
	--surf.CheckExistingSurfaces = false
	--surf.IgnoreIrreplacableSurfaces = true
	surf.Duration = 12.0
	--surf.OwnerHandle = projectile.OwnerHandle
	return surf
end