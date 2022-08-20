---@class ExtenderClientVisualOptions
---@field Bone string
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
---@field Matrix number[] Size 16 table of matrices.
---@field Rotate number[] Size 9 table of matrices.
---@field Scale number[] Size 3 Vector3-style table.
---@field Translate number[] Size 3 Vector3-style table.

---@type table<NETID,table<string, integer>>
local ActiveVisuals = {}

---@param handleINT integer
---@return EclLuaVisualClientMultiVisual
local function _TryGetHandlerFromInt(handleINT)
	if handleINT then
		local handle = Ext.Utils.IntegerToHandle(handleINT)
		if GameHelpers.IsValidHandle(handle) then
			local handler = Ext.Visual.Get(handle)
			if handler then
				return handler
			end
		end
	end
	return nil
end

---@param character EclCharacter
---@param visualResource string
---@return EclLuaVisualClientMultiVisual
function VisualManager.GetVisualHandler(character, visualResource)
	local characterData = ActiveVisuals[character.NetID]
	if characterData then
		local handler = _TryGetHandlerFromInt(characterData[visualResource])
		if not handler then
			characterData[visualResource] = nil
			if not Common.TableHasAnyEntry(characterData) then
				ActiveVisuals[character.NetID] = nil
			end
		else
			return handler
		end
	end
	return nil
end

---@param character EclCharacter
---@param visualResource string
---@param handler EclLuaVisualClientMultiVisual
function VisualManager.StoreVisualHandler(character, visualResource, handler)
	if GameHelpers.IsValidHandle(handler.Handle) then
		if  ActiveVisuals[character.NetID] == nil then
			ActiveVisuals[character.NetID] = {}
		end
		local handleINT = Ext.Utils.HandleToInteger(handler.Handle)
		Ext.Dump({
			HandleINT = handleINT,
			Handle = handler.Handle,
			VisualResource = visualResource
		})
		ActiveVisuals[character.NetID][visualResource] = handleINT
	end
end

---@param character EclCharacter
---@param visualResource string
---@return boolean
function VisualManager.DeleteVisual(character, visualResource)
	local handler = VisualManager.GetVisualHandler(character, visualResource)
	if handler then
		handler:Delete()
		ActiveVisuals[character.NetID][visualResource] = nil
		if not Common.TableHasAnyEntry(ActiveVisuals[character.NetID]) then
			ActiveVisuals[character.NetID] = nil
		end
		return true
	end
	return false
end

---@param character CharacterParam
---@param visualResource string
---@param options ExtenderClientVisualOptions|nil
---@param positionOptions LeaderLibClientVisualOptions|nil
---@return Visual
function VisualManager.AttachVisual(character, visualResource, options, positionOptions)
	options = options or {}
	character = GameHelpers.GetCharacter(character)
	if not character then
		error("Character parameter is invalid")
	end

	VisualManager.DeleteVisual(character, visualResource)
	---@type EclLuaVisualClientMultiVisual
	local handler = Ext.Visual.CreateOnCharacter(character.Translate, character, character)
	VisualManager.StoreVisualHandler(character, visualResource, handler)
	local addedVisual = handler:AddVisual(visualResource, options)

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
	-- Ext.OnNextTick(function (e)
	-- 	GameHelpers.IO.SaveJsonFile("Dumps/NewVisual.json", Ext.DumpExport({CreateOnCharacterVisual=handler,AddedVisual=addedVisual}))
	-- 	print("Ext.Visual.Get(Handle)", Ext.Visual.Get(handler.Handle))
	-- 	print("Ext.Visual.Get(addedVisual.Handle)", Ext.Visual.Get(addedVisual.Handle))
	-- end)
	return addedVisual
end

---@class LeaderLibRequestAttachVisualData
---@field Target NETID
---@field Resource string
---@field Options ExtenderClientVisualOptions|nil
---@field ExtraOptions LeaderLibClientVisualOptions|nil

Ext.RegisterNetListener("LeaderLib_VisualManager_RequestAttachVisual", function (channel, payload, user)
	local data = Common.JsonParse(payload, true)
	if data then
		---@cast data LeaderLibRequestAttachVisualData
		local character = GameHelpers.GetCharacter(data.Target)
		fassert(character ~= nil, "Failed to get character from data.Target(%s)", data.Target)

		VisualManager.AttachVisual(character, data.Resource, data.Options, data.ExtraOptions)
	end
end)

--local v = Mods.LeaderLib.VisualManager.AttachVisual(GameHelpers.GetCharacter(me.NetID), "48491cef-a2de-4dec-9d65-9c6aea8a769e", {Bone="Dummy_R_Hand", Armor=true, UseLocalTransform=true}); v.LocalTransform.Rotate[5] = 10
--me.Visual.Attachments[5].Visual.LocalTransform.Scale[1] = 10
--me.Visual.Attachments[5].Visual.WorldTransform.Scale[1] = 10
--me.Visual.Attachments[5].UseLocalTransform = true

--Only works for visuals created via the console, since they have no lifetime
Events.BeforeLuaReset:Subscribe(function ()
	pcall(function ()
		for netid,entries in pairs(ActiveVisuals) do
			for resourceid,handleINT in pairs(entries) do
				local handler = _TryGetHandlerFromInt(handleINT)
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

---@param fx string|string[]
---@param target ObjectParam
---@param params {Target:ObjectParam, WeaponBones:string}|nil
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

-- VisualManager.AttachVisual(GameHelpers.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="LowerArm_R_Twist_Bone", Weapon=true, UseLocalTransform=true}, {Rotate=Mods.LeaderLib.Game.Math.EulerToRotationMatrix({180,0,0})})

--df8b6237-d031-44d7-b729-a80eb074f3b3
--Mods.LeaderLib.VisualManager.AttachVisual(GameHelpers.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="LowerArm_R_Twist_Bone"})
--Mods.LeaderLib.VisualManager.AttachVisual(GameHelpers.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="LowerArm_R_Twist_Bone", Weapon=true,UseLocalTransform=true, InheritAnimations=true, SyncAnimationWithParent=true}, {Rotate=Mods.LeaderLib.Game.Math.EulerToRotationMatrix({90,0,0})})
--Mods.LeaderLib.VisualManager.AttachVisual(GameHelpers.GetCharacter(me.NetID), "df8b6237-d031-44d7-b729-a80eb074f3b3", {Bone="Dummy_R_Hand", Weapon=true,UseLocalTransform=true, InheritAnimations=true, SyncAnimationWithParent=true}, {Rotate={[1]=-1,[5]=-1}, Translate={[2]=-1}})
--TestVisual=Mods.LeaderLib.VisualManager.AttachVisual(GameHelpers.GetCharacter(me.NetID), "6254c2b7-dd9e-4821-9aa4-830fa4c0bc50", {Bone="Dummy_R_Hand", UseLocalTransform=true}, {Scale={10,10,10}})
--Mods.LeaderLib.VisualManager.AttachVisual(GameHelpers.GetCharacter(me.NetID), "48491cef-a2de-4dec-9d65-9c6aea8a769e", {Bone="Dummy_R_Hand", Armor=true, UseLocalTransform=true})