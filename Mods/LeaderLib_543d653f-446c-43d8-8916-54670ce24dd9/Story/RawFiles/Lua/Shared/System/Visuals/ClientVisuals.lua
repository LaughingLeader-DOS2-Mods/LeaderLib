---@class ExtenderClientVisualOptions
---@field Bone FixedString
---@field AllowTPose boolean
---@field ResetScale boolean
---@field SyncAnimationWithParent boolean
---@field Color1 MaterialVector4
---@field Color2 MaterialVector4
---@field Color3 MaterialVector4
---@field Color4 MaterialVector4
---@field Color5 MaterialVector4
---@field ExcludeFromBounds boolean
---@field KeepRot boolean
---@field KeepScale boolean
---@field UseLocalTransform boolean
---@field InheritAnimations boolean
---@field DoNotUpdate boolean
---@field Equipment boolean
---@field Armor boolean Whether it's a weapon visual.
---@field Wings boolean
---@field Horns boolean
---@field Overhead boolean
---@field CastShadow boolean
---@field ReceiveDecal boolean
---@field Reflecting boolean
---@field IsShadowProxy boolean
---@field AllowReceiveDecalWhenAnimated boolean


---@class LeaderLibClientVisualOptions
--- @field Matrix number[] Size 16 table of matrices.
--- @field Rotate number[] Size 9 table of matrices.
--- @field Scale number[] Size 3 Vector3-style table.
--- @field Translate number[] Size 3 Vector3-style table.

---@type table<NETID,table<FixedString, EclLuaVisualClientMultiVisual>>
local ActiveVisuals = {}

---@param character EclCharacter
---@param visualResource FixedString
function VisualManager.GetVisualHandler(character, visualResource)
	local characterData = ActiveVisuals[character.NetID]
	if characterData then
		local handler = characterData[visualResource]
		if handler then
			return handler
		end
	end
	return nil
end

---@param character EclCharacter
---@param visualResource FixedString
---@param handler EclLuaVisualClientMultiVisual
function VisualManager.StoreVisualHandler(character, visualResource, handler)
	if  ActiveVisuals[character.NetID] == nil then
		ActiveVisuals[character.NetID] = {}
	end
	ActiveVisuals[character.NetID][visualResource] = handler
end

-- VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="LowerArm_R_Twist_Bone", Weapon=true, UseLocalTransform=true}, {Rotate=Mods.LeaderLib.Game.Math.EulerToRotationMatrix({180,0,0})})

--df8b6237-d031-44d7-b729-a80eb074f3b3
--Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="LowerArm_R_Twist_Bone"})
--Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="LowerArm_R_Twist_Bone", Weapon=true,UseLocalTransform=true, InheritAnimations=true, SyncAnimationWithParent=true}, {Rotate=Mods.LeaderLib.Game.Math.EulerToRotationMatrix({90,0,0})})
--Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="Dummy_R_Hand", Weapon=true,UseLocalTransform=true, InheritAnimations=true, SyncAnimationWithParent=true}, {Rotate={[1]=-1,[5]=-1}, Translate={[2]=-1}})
--TestVisual=Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "6254c2b7-dd9e-4821-9aa4-830fa4c0bc50", {Bone="Dummy_R_Hand", UseLocalTransform=true}, {Scale={10,10,10}})
--Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "48491cef-a2de-4dec-9d65-9c6aea8a769e", {Bone="Dummy_R_Hand", Armor=true, UseLocalTransform=true})

---@param character EclCharacter
---@param visualResource FixedString
function VisualManager.DeleteVisual(character, visualResource)
	local handler = VisualManager.GetVisualHandler(character, visualResource)
	if handler then
		handler:Delete()
		ActiveVisuals[character.NetID][visualResource] = nil
		return true
	end
	return false
end

---@param character EclCharacter
---@param visualResource FixedString
---@param options ?ExtenderClientVisualOptions
---@param positionOptions ?LeaderLibClientVisualOptions
function VisualManager.AttachVisual(character, visualResource, options, positionOptions)
	VisualManager.DeleteVisual(character, visualResource)
	---@type EclLuaVisualClientMultiVisual
	local handler = Ext.Visual.CreateOnCharacter(character.Translate, character, character)
	VisualManager.StoreVisualHandler(character, visualResource, handler)
	local addedVisual = handler:AddVisual(visualResource, options)

	if addedVisual and type(positionOptions) == "table" then
		local target = addedVisual.WorldTransform
		if options.UseLocalTransform then
			target = addedVisual.LocalTransform
		end
		if positionOptions.Matrix then
			local mat = target.Matrix
			for i,v in pairs(positionOptions.Matrix) do
				mat[i] = v
			end
			target.Matrix = mat
		end
		if positionOptions.Rotate then
			positionOptions.Rotate = GameHelpers.Math.EulerToRotationMatrix(positionOptions.Rotate)
			local rot = target.Rotate
			for i,v in pairs(positionOptions.Rotate) do
				rot[i] = v
			end
			target.Rotate = rot
		end
		if positionOptions.Scale then
			local scale = target.Scale
			for i,v in pairs(positionOptions.Scale) do
				scale[i] = v
			end
			target.Scale = scale
		end
		if positionOptions.Translate then
			local tran = target.Translate
			for i,v in pairs(positionOptions.Translate) do
				tran[i] = v
			end
			target.Translate = tran
		end
		-- print("addedVisual.WorldTransform", addedVisual.WorldTransform)
		-- print("addedVisual.LocalTransform", addedVisual.LocalTransform)
		-- if options.UseLocalTransform then
		-- 	addedVisual.LocalTransform = target
		-- else
		-- 	addedVisual.WorldTransform = target
		-- end
	end
	GameHelpers.IO.SaveJsonFile("Dumps/NewVisual.json", Ext.DumpExport({CreateOnCharacterVisual=handler,AddedVisual=addedVisual}))
	return addedVisual
end

--local v = Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "48491cef-a2de-4dec-9d65-9c6aea8a769e", {Bone="Dummy_R_Hand", Armor=true, UseLocalTransform=true}); v.LocalTransform.Rotate[5] = 10
--me.Visual.Attachments[5].Visual.LocalTransform.Scale[1] = 10
--me.Visual.Attachments[5].Visual.WorldTransform.Scale[1] = 10
--me.Visual.Attachments[5].UseLocalTransform = true


RegisterListener("BeforeLuaReset", function ()
	for netid,entries in pairs(ActiveVisuals) do
		for resourceid,handler in pairs(entries) do
			handler:Delete()
		end
	end
end)

Ext.RegisterConsoleCommand("lltestvisual", function ()
	VisualManager.AttachVisual(Client:GetCharacter(), "df8b6237-d031-44d7-b729-a80eb074f3b3",
	{
		Bone="LowerArm_R_Twist_Bone",
		Weapon=true,
		UseLocalTransform=true,
		-- InheritAnimations=true,
		-- SyncAnimationWithParent=true
	},
	{
		Rotate=GameHelpers.Math.EulerToRotationMatrix({90,0,0}),
		Translate = {-100,-100,-100},
	})
end)