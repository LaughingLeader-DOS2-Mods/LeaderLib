local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Version()
local _type = type

if GameHelpers.Visual == nil then
	GameHelpers.Visual = {}
end

if _ISCLIENT then
	--- @class ExtenderClientVisual
	--- @field OverrideScalarMaterialParameter fun(self:ExtenderClientVisual, propertyName:string, value:number)
	--- @field OverrideTextureMaterialParameter fun(self:ExtenderClientVisual, propertyName:string, value:string)
	--- @field OverrideVec2MaterialParameter fun(self:ExtenderClientVisual, propertyName:string, value:number[])
	--- @field OverrideVec3MaterialParameter fun(self:ExtenderClientVisual, propertyName:string, value:number[], isColor:boolean)
	--- @field OverrideVec4MaterialParameter fun(self:ExtenderClientVisual, propertyName:string, value:number[], isColor:boolean)
	--- @field Actor ExtenderClientVisualAttachment
	--- @field AllowReceiveDecalWhenAnimated boolean
	--- @field Attachments ExtenderClientVisualAttachment[]
	--- @field CastShadow boolean
	--- @field ChildVisualHasCloth boolean
	--- @field CullFlags integer
	--- @field FadeOpacity number
	--- @field GameObject EclGameObject
	--- @field Handle ObjectHandle
	--- @field HasCloth boolean
	--- @field IsShadowProxy boolean
	--- @field LODDistances number[]
	--- @field Parent ExtenderClientVisual
	--- @field PlayingAttachedEffects boolean
	--- @field ReceiveColorFromParent boolean
	--- @field ReceiveDecal boolean
	--- @field Reflecting boolean
	--- @field ShowMesh boolean
	--- @field Skeleton userdata
	--- @field SubObjects table
	--- @field TextKeyPrepareFlags integer
	--- @field VisualResource userdata

	---@class ExtenderClientVisualAttachment
	---@field Visual ExtenderClientVisual
	---@field Armor boolean
	---@field AttachmentBoneName string
	---@field BoneIndex integer
	---@field BonusWeaponFX boolean
	---@field DestroyWithParent boolean
	---@field DoNotUpdate boolean
	---@field DummyAttachmentBoneIndex integer
	---@field Equipment boolean
	---@field ExcludeFromBounds boolean
	---@field Horns boolean
	---@field InheritAnimations boolean
	---@field KeepRot boolean
	---@field KeepScale boolean
	---@field Overhead boolean
	---@field UseLocalTransform boolean
	---@field Weapon boolean
	---@field WeaponFX boolean
	---@field WeaponOverlayFX boolean
	---@field Wings boolean

	---Gets all active weapon visuals for a character.
	---🔧**Client-Only**🔧
	---@param character UUID|NETID|EclCharacter
	---@param includeShield boolean|nil If true, include shield visuals.
	---@return ExtenderClientVisualAttachment[]
	function GameHelpers.Visual.GetWeaponVisuals(character, includeShield)
		if _EXTVERSION >= 56 then
			---@type EclCharacter
			local character = GameHelpers.GetCharacter(character)
			assert(GameHelpers.Ext.ObjectIsCharacter(character), "target parameter must be a character UUID, NetID, or Esv/EclCharacter")
			local visuals = {}
			--Visual.Attachments["16"].Weapon
			--Visual.SubObjects["1"].Renderable.PropertyList.field_6
			--Visual.ShowMesh
			--Visual.Attachments["1"].Visual.Attachments["1"].Armor
			if character.Visual then
				for index,v in pairs(character.Visual.Attachments) do
					if v.Weapon == true then
						if includeShield or v.AttachmentBoneName ~= "Dummy_Weapon_SH" then
							visuals[#visuals+1] = v
						end
					end
				end
			end
			return visuals
		end
		return {}
	end

	---Gets all attached effect visuals for a character's weapons. These may be visuals such as the effect damage type overlays.
	---🔧**Client-Only**🔧
	---@param character UUID|NETID|EclCharacter
	---@param includeShield boolean|nil If true, include shield visuals.
	---@return ExtenderClientVisualAttachment[]
	function GameHelpers.Visual.GetAttachedWeaponEffectVisuals(character, includeShield)
		if _EXTVERSION >= 56 then
			local character = GameHelpers.TryGetObject(character)
			assert(GameHelpers.Ext.ObjectIsCharacter(character), "target parameter must be a character UUID, NetID, or Esv/EclCharacter")
			local effects = {}
			for _,visual in pairs(GameHelpers.Visual.GetWeaponVisuals(character, includeShield)) do
				for _,attachment in pairs(visual.Visual.Attachments) do
					if attachment.BonusWeaponFX == true then
						effects[#effects+1] = attachment
					end
				end
			end
			return effects
		end
		return {}
	end
end