local _ISCLIENT = Ext.IsClient()
local _EXTVERSION = Ext.Utils.Version()
local _type = type

if GameHelpers.Visual == nil then
	GameHelpers.Visual = {}
end

---@param character CharacterParam
---@param ignorePolymorph? boolean
---@return VisualSet
function GameHelpers.Visual.GetVisualSet(character, ignorePolymorph)
	character = GameHelpers.GetCharacter(character, "EsvCharacter")
	local template = GameHelpers.GetTemplate(character, true, ignorePolymorph) --[[@as CharacterTemplate]]
	assert(template ~= nil, "Failed to get root template for character: " .. tostring(character))
	return template.VisualSet
end

---@param character CharacterParam
---@return CharacterCreationRaceDesc
function GameHelpers.Visual.GetRacePreset(character)
	character = GameHelpers.GetCharacter(character, "EsvCharacter")
	assert(character.PlayerCustomData ~= nil, "character.PlayerCustomData not set")
	local race = character.PlayerCustomData.Race
	local cc = Ext.Stats.GetCharacterCreation()
	--#a42832
	for _,v in pairs(cc.RacePresets) do
		if v.RaceName == race then
			return v
		end
	end
	return cc.DefaultRace
end

--me.CurrentTemplate.VisualSetIndices:SetVisual(3, 0)

---@param character CharacterParam
---@param slot integer
---@param visualName string
---@return boolean
function GameHelpers.Visual.SetVisualElementByName(character, slot, visualName)
	local character = GameHelpers.GetCharacter(character, "EsvCharacter")
	local visualSet = GameHelpers.Visual.GetVisualSet(character)
	local visuals = visualSet.Visuals[slot]
	for i,guid in pairs(visuals) do
		local resource = Ext.Resource.Get("Visual", guid) --[[@as VisualResource]]
		if resource and resource.Name == visualName then
			print(i, guid, resource.Name)
			character.CurrentTemplate.VisualSetIndices:SetVisual(slot, i)
			if not _ISCLIENT then
				GameHelpers.Net.Broadcast("LeaderLib_Visual_SetVisualSetIndice", {NetID=character.NetID, Slot=slot, Index=i})
			end
			return true
		end
	end
	return false
end

if not _ISCLIENT then
	---@class LeaderLib_Visual_SetVisualSetIndice
	---@field NetID NetId
	---@field Slot integer
	---@field Index integer

	GameHelpers.Net.Subscribe("LeaderLib_Visual_SetVisualSetIndice", function (e, data)
		local character = GameHelpers.GetCharacter(data.NetID, "EclCharacter")
		if character then
			character.CurrentTemplate.VisualSetIndices:SetVisual(data.Slot, data.Index)
		end
	end)
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
	---@param character CharacterParam
	---@param includeShield? boolean If true, include shield visuals.
	---@return ExtenderClientVisualAttachment[]
	function GameHelpers.Visual.GetWeaponVisuals(character, includeShield)
		---@type EclCharacter
		local character = GameHelpers.GetCharacter(character)
		assert(GameHelpers.Ext.ObjectIsCharacter(character), "target parameter must be a character UUID, NetID, or Esv/EclCharacter")
		local visuals = {}
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

	---Gets all attached effect visuals for a character's weapons. These may be visuals such as the effect damage type overlays.
	---🔧**Client-Only**🔧
	---@param character CharacterParam
	---@param includeShield? boolean If true, include shield visuals.
	---@return ExtenderClientVisualAttachment[]
	function GameHelpers.Visual.GetAttachedWeaponEffectVisuals(character, includeShield)
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
end