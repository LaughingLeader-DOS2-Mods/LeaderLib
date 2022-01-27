if GameHelpers.Surface == nil then
	GameHelpers.Surface = {}
end

---@param startPos number[]
---@param endPos number[]
function GameHelpers.Surface.CreateRectSurface(startPos, endPos, surface, width, lengthModifier, duration, speed, statusChance, deathType, owner, lineCheckBlock)
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

---@param pos number[]|string
---@param surface string
---@param radius number
---@param duration number
---@param ownerHandle userdata
---@param ignoreCursed boolean
---@param statusChance number
---@return EsvSurfaceAction
function GameHelpers.Surface.CreateSurface(pos, surface, radius, duration, ownerHandle, ignoreCursed, statusChance)
	if type(pos) == "string" then
		pos = table.pack(GetPosition(pos))
	end
	---@type EsvRectangleSurfaceAction
	local surf = Ext.CreateSurfaceAction("CreateSurfaceAction")
	surf.Position = pos
	surf.SurfaceType = surface or "Water"
	surf.Radius = radius or 1.0
	if ignoreCursed == nil then
		ignoreCursed = true
	end
	surf.IgnoreIrreplacableSurfaces = ignoreCursed
	surf.Duration = duration or 6.0
	surf.StatusChance = statusChance or 1.0
	--surf.DeathType = deathType or "DoT"
	surf.OwnerHandle = ownerHandle or nil
	Ext.ExecuteSurfaceAction(surf)
end

---@type table<integer,EsvChangeSurfaceOnPathAction>
local surfaceActions = {}

local function CreateFollowSurface(projectile)
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

function GameHelpers.Surface.UpdateRules()
	if GameSettings.Settings.SurfaceSettings.PoisonDoesNotIgnite == true then
		local rulesUpdated = false
		local rules = Ext.GetSurfaceTransformRules()
		for surfaceElement,contents in pairs(rules) do
			for i,parentTable in pairs(contents) do
				if parentTable.TransformType == "Ignite" then
					for i,surfaces in pairs(parentTable.ActionableSurfaces) do
						local remove = false
						for i,surface in pairs(surfaces) do
							if surfaceElement ~= "Poison" and surface == "Poison" then
								remove = true
							elseif surfaceElement == "Poison" and (surface == "Fire" or surface == "Lava") then
								remove = true
							end
						end
						if remove then
							--PrintDebug(string.format("[LeaderLib.GameHelpers.Surface.UpdateRules] Removing surfaces (%s) from [%s] ActionableSurfaces.", StringHelpers.Join(", ", surfaces), surfaceElement))
							parentTable.ActionableSurfaces[i] = nil
							rulesUpdated = true
						end
					end
				end
			end
		end
		if rulesUpdated then
			Ext.Print("[LeaderLib.GameHelpers.Surface.UpdateRules] Updating surface action rules.")
			Ext.UpdateSurfaceTransformRules(rules)
		end
	end
end

---@param pos number[]|string
---@param action string
---@param layer integer
---@param duration number
---@param ownerHandle userdata
---@param originSurface string
---@param statusChance number
---@return EsvSurfaceAction
function GameHelpers.Surface.Transform(pos, action, layer, duration, ownerHandle, originSurface, statusChance)
	if type(pos) == "string" then
		pos = table.pack(GetPosition(pos))
	end

	---@type EsvTransformSurfaceAction
	local surf = Ext.CreateSurfaceAction("TransformSurfaceAction")
	surf.SurfaceTransformAction = action
	surf.Position = pos
	surf.OriginSurface = originSurface or ""
	surf.SurfaceLayer = layer or 0
	surf.GrowCellPerSecond = 4.0
	surf.SurfaceLifetime = duration or 6.0
	surf.SurfaceStatusChance = statusChance or 1.0
	surf.OwnerHandle = ownerHandle or nil
	Ext.ExecuteSurfaceAction(surf)
end

function GameHelpers.Surface.TransformSurfaces(transformToSurfaceType, matchNames, x, z, radius, layer, duration, ownerHandle, statusChance, explicitMatch, grid, ignoreCursed, createdSurfaceSize)
	createdSurfaceSize = createdSurfaceSize or 1.0
	local surfaces = GameHelpers.Grid.GetSurfaces(x, z, grid, radius, 18)
	if layer == 0 then
		for i,v in pairs(surfaces.Ground) do
			if StringHelpers.IsMatch(v.Surface.SurfaceType, matchNames, explicitMatch) then
				--CreatePuddle(CharacterGetHostCharacter(), "SurfaceBloodFrozen", 4, 4, 4, 4, 1.0)
				--CreateSurfaceAtPosition(v.Position[1], v.Position[2], v.Position[3], "SurfaceBloodFrozen", createdSurfaceSize, duration)
				GameHelpers.Surface.CreateSurface(v.Position, transformToSurfaceType, createdSurfaceSize, duration or v.Surface.LifeTime, ownerHandle, ignoreCursed, statusChance)
			end
		end
	elseif layer == 1 then
		for i,v in pairs(surfaces.Cloud) do
			if StringHelpers.IsMatch(v.Surface.SurfaceType, matchNames, explicitMatch) then
				GameHelpers.Surface.CreateSurface(v.Position, transformToSurfaceType, createdSurfaceSize, duration or v.Surface.LifeTime, ownerHandle, ignoreCursed, statusChance)
			end
		end
	else
		for k,tbl in pairs(surfaces.SurfaceMap) do
			if StringHelpers.IsMatch(k, matchNames, explicitMatch) then
				for _,v in pairs(tbl) do
					GameHelpers.Surface.CreateSurface(v.Position, transformToSurfaceType, createdSurfaceSize, duration or v.Surface.LifeTime, ownerHandle, ignoreCursed, statusChance)
				end
			end
		end
	end
end

---@param x number
---@param z number
---@param matchNames string|string[]
---@param maxRadius number|nil
---@param containingName boolean Look for surfaces containing the name, instead of explicit matching.
---@param onlyLayer integer Look only on layer 0 (ground) or 1 (clouds).
---@param grid AiGrid|nil
function GameHelpers.Surface.HasSurface(x, z, matchNames, maxRadius, containingName, onlyLayer, grid)
	local surfaces = GameHelpers.Grid.GetSurfaces(x, z, grid, maxRadius)
	return surfaces and surfaces.HasSurface(matchNames, containingName, onlyLayer)
end