--- @class ExtenderMaterialVector4
--- @field IsColor boolean
--- @field Value number[]

---@class ExtenderClientVisualOptions
---@field Bone string
---@field AllowTPose boolean
---@field ResetScale boolean
---@field SyncAnimationWithParent boolean
---@field Color1 ExtenderMaterialVector4
---@field Color2 ExtenderMaterialVector4
---@field Color3 ExtenderMaterialVector4
---@field Color4 ExtenderMaterialVector4
---@field Color5 ExtenderMaterialVector4
---@field ExcludeFromBounds boolean
---@field KeepRot boolean
---@field KeepScale boolean
---@field UseLocalTransform boolean
---@field InheritAnimations boolean
---@field DoNotUpdate boolean
---@field Equipment boolean
---@field Weapon boolean Whether it's a weapon visual.
---@field Armor boolean
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

---@class EclLuaVisualClientMultiVisual
--- @field AttachedVisualComponents ObjectHandle[]
--- @field Effects ObjectHandle[]
--- @field ListenForTextKeysHandle ObjectHandle
--- @field ListeningOnTextKeys boolean
--- @field Position Vector3
--- @field TargetObjectHandle ObjectHandle
--- @field TextKeyEffects table<string, table>
--- @field Visuals table
--- @field WeaponAttachments table[]
--- @field WeaponBones string
--- @field AddVisual fun(self:EclLuaVisualClientMultiVisual, id:string, options:ExtenderClientVisualOptions|nil):table
--- @field Delete fun(self:EclLuaVisualClientMultiVisual)
--- @field ParseFromStats fun(self:EclLuaVisualClientMultiVisual, effect:string, weaponBones:string|nil)
--- @field AttachedVisuals ObjectHandle[]

---@type table<NETID,table<string, EclLuaVisualClientMultiVisual>>
local ActiveVisuals = {}

---@param character EclCharacter
---@param visualResource string
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

-- VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="LowerArm_R_Twist_Bone", Weapon=true, UseLocalTransform=true}, {Rotate=Mods.LeaderLib.Game.Math.EulerToRotationMatrix({180,0,0})})

--df8b6237-d031-44d7-b729-a80eb074f3b3
--Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="LowerArm_R_Twist_Bone"})
--Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="LowerArm_R_Twist_Bone", Weapon=true,UseLocalTransform=true, InheritAnimations=true, SyncAnimationWithParent=true}, {Rotate=Mods.LeaderLib.Game.Math.EulerToRotationMatrix({90,0,0})})
--Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="Dummy_R_Hand", Weapon=true,UseLocalTransform=true, InheritAnimations=true, SyncAnimationWithParent=true}, {Rotate={[1]=-1,[5]=-1}, Translate={[2]=-1}})
--TestVisual=Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "6254c2b7-dd9e-4821-9aa4-830fa4c0bc50", {Bone="Dummy_R_Hand", UseLocalTransform=true}, {Scale={10,10,10}})
--Mods.LeaderLib.VisualManager.AttachVisual(Ext.GetCharacter(me.NetID), "48491cef-a2de-4dec-9d65-9c6aea8a769e", {Bone="Dummy_R_Hand", Armor=true, UseLocalTransform=true})

---@param character EclCharacter
---@param visualResource string
---@param handler EclLuaVisualClientMultiVisual
function VisualManager.StoreVisualHandler(character, visualResource, handler)
	if  ActiveVisuals[character.NetID] == nil then
		ActiveVisuals[character.NetID] = {}
	end
	ActiveVisuals[character.NetID][visualResource] = handler
end

---@param character EclCharacter
---@param visualResource string
---@return boolean
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
---@param visualResource string
---@param options ExtenderClientVisualOptions|nil
---@param positionOptions LeaderLibClientVisualOptions|nil
function VisualManager.AttachVisual(character, visualResource, options, positionOptions)
	options = options or {}

	VisualManager.DeleteVisual(character, visualResource)
	---@diagnostic disable unknown-field
	---@type EclLuaVisualClientMultiVisual
	local handler = Ext.Visual.CreateOnCharacter(character.Translate, character, character)
	VisualManager.StoreVisualHandler(character, visualResource, handler)
	local addedVisual = handler:AddVisual(visualResource, options)

	---@diagnostic enable

	if addedVisual and positionOptions and type(positionOptions) == "table" then
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

--Only works for visuals created via the console, since they have no lifetime
Events.BeforeLuaReset:Subscribe(function ()
	pcall(function ()
		for netid,entries in pairs(ActiveVisuals) do
			for resourceid,handler in pairs(entries) do
				if handler then
					handler:Delete()
				end
			end
		end
	end)
end)

local testMountVisual = nil

Ext.RegisterConsoleCommand("lltestvisual", function (cmd, t)
	if StringHelpers.IsNullOrEmpty(t) then
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
	elseif t == "mount" then
		if testMountVisual then
			testMountVisual:Delete()
		end
		--Wolf
		testMountVisual = VisualManager.AttachVisual(Client:GetCharacter(), "ebcf1ade-cfa1-4d48-9f10-e5e409830dcc",
		{
			Bone="Dummy_Root",
			Armor=true,
			InheritAnimations = true,
			SyncAnimationWithParent = true,
		})

		--Mods.LeaderLib.VisualManager.AttachVisual(_C(), "ebcf1ade-cfa1-4d48-9f10-e5e409830dcc",{Bone="Dummy_Root",Armor=true,SyncAnimationWithParent = true,InheritAnimations=true})
	end
end)

function VisualManager.CreateClientEffect(fx, target, params)
	params = params or {}
	local ft = type(fx)
	if ft == "string" then
		local t = type(target)
		---@type EclLuaVisualClientMultiVisual
		local handler = nil
		if t == "table" then
			if type(target[1]) == "number" then
				--Position
				handler = Ext.Visual.Create(target)
			end
		elseif t == "number" then
			--NetID
			local object = GameHelpers.TryGetObject(target)
			if object then
				local otherTarget = nil
				if params.Target then
					otherTarget = GameHelpers.TryGetObject(params.Target)
				end
				if not otherTarget then
					otherTarget = object
				end
				if GameHelpers.Ext.ObjectIsCharacter(object) then
					handler = Ext.Visual.CreateOnCharacter(object.WorldPos, object, object)
				elseif GameHelpers.Ext.ObjectIsItem(object) then
					handler = Ext.Visual.CreateOnItem(object.WorldPos, object, object)
				end
			end
		end
		if handler then
			handler:ParseFromStats(fx, params.WeaponBones or nil)
			GameHelpers.IO.SaveFile("Dumps/ClientMultiVisual.json", Ext.DumpExport(handler))
			-- for i,v in pairs(handler.Effects) do
			-- 	local effect = Ext.Visual.Get(v)
			-- 	print(effect, v)
			-- end
			-- GameHelpers.IO.SaveFile("Dumps/ClientMultiVisual_Effect.json", Ext.DumpExport(Ext.Types.GetObjectType(handler.Effects)))
			-- for _,v in pairs(handler.Effects) do
			-- 	v.
			-- end
		end
	elseif ft == "table" then
		for _,v in pairs(fx) do
			VisualManager.CreateClientEffect(v, target, params)
		end
	end
end

Ext.RegisterNetListener("LeaderLib_EffectManager_PlayClientEffect", function (cmd, payload)
	local data = Common.JsonParse(payload)
	if data then
		VisualManager.CreateClientEffect(data.FX, data.Target, data.Params)
	end
end)