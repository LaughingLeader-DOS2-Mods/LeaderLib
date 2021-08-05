local ts = Classes.TranslatedString

local isClient = Ext.IsClient()

---@alias SheetStatType string | "PrimaryStat" | "SecondaryStat" | "Spacing"
---@alias SheetSecondaryStatType string | "Info" | "Normal" | "Resistance"

---@class StatsManager
SheetManager.Stats = {
	Data = {
		Default = {
			Entries = {
				Strength = {
					DisplayName = LocalizedText.CharacterSheet.Strength,
					StatID = 0,
					TooltipID = 0,
					Attribute = "Strength",
					Type = "PrimaryStat",
				},
				Finesse = {
					DisplayName = LocalizedText.CharacterSheet.Finesse,
					StatID = 1,
					TooltipID = 1,
					Attribute = "Finesse",
					Type = "PrimaryStat",
				},
				Intelligence = {
					DisplayName = LocalizedText.CharacterSheet.Intelligence,
					StatID = 2,
					TooltipID = 2,
					Attribute = "Intelligence",
					Type = "PrimaryStat",
				},
				Constitution = {
					DisplayName = LocalizedText.CharacterSheet.Constitution,
					StatID = 3,
					TooltipID = 3,
					Attribute = "Constitution",
					Type = "PrimaryStat",
				},
				Memory = {
					DisplayName = LocalizedText.CharacterSheet.Memory,
					StatID = 4,
					TooltipID = 4,
					Attribute = "Memory",
					Type = "PrimaryStat",
				},
				Wits = {
					DisplayName = LocalizedText.CharacterSheet.Wits,
					StatID = 5,
					TooltipID = 5,
					Attribute = "Wits",
					Type = "PrimaryStat",
				},
				Dodging = {
					StatID = 11,
					StatType = 1,
					DisplayName = LocalizedText.CharacterSheet.Dodging,
					Type = "SecondaryStat",
					Frame = 15,
					Attribute = "Dodge",
					Suffix = "%"
				},
				Movement = {
					StatID = 20,
					StatType = 1,
					DisplayName = LocalizedText.CharacterSheet.Movement,
					Type = "SecondaryStat",
					Frame = 18,
					Attribute = "Movement"
				},
				Initiative = {
					StatID = 21,
					StatType = 1,
					DisplayName = LocalizedText.CharacterSheet.Initiative,
					Type = "SecondaryStat",
					Frame = 16,
					Attribute = "Initiative"
				},
				CriticalChance = {
					StatID = 9,
					StatType = 1,
					DisplayName = LocalizedText.CharacterSheet.CriticalChance,
					Type = "SecondaryStat",
					Frame = 20,
					Attribute = "CriticalChance",
					Suffix = "%"
				},
				Accuracy = {
					StatID = 10,
					StatType = 1,
					DisplayName = LocalizedText.CharacterSheet.Accuracy,
					Type = "SecondaryStat",
					Frame = 13,
					Attribute = "Accuracy",
					Suffix = "%"
				},
				Damage = {
					StatID = 6,
					StatType = 1,
					DisplayName = LocalizedText.CharacterSheet.Damage,
					Type = "SecondaryStat",
					Frame = 14,
					---@param character StatCharacter
					Attribute = function(character)
						local mainWeapon = character.MainWeapon
						local offHandWeapon = character.OffHandWeapon

						local mainDamageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, mainWeapon)

						local minDamage = 0
						local maxDamage = 0

						local mainDamageType = "Sentinel"
						local offDamageType = "Sentinel"

						if mainWeapon ~= nil then
							mainDamageType = mainWeapon["Damage Type"]
						end

						if offHandWeapon ~= nil and Game.Math.IsRangedWeapon(mainWeapon) == Game.Math.IsRangedWeapon(offHandWeapon) then
							offDamageType = offHandWeapon["Damage Type"]
							local offHandDamageRange = Game.Math.CalculateWeaponScaledDamageRanges(character, offHandWeapon)
							local dualWieldPenalty = Ext.ExtraData.DualWieldingDamagePenalty
							for damageType, range in pairs(offHandDamageRange) do
								local min = math.ceil(range.Min * dualWieldPenalty)
								local max = math.ceil(range.Max * dualWieldPenalty)
								local range = mainDamageRange[damageType]
								if mainDamageRange[damageType] ~= nil then
									range.Min = range.Min + min
									range.Max = range.Max + max
								else
									mainDamageRange[damageType] = {Min = min, Max = max}
								end
							end
						end
				
						for damageType, range in pairs(mainDamageRange) do
							local min = Ext.Round(range.Min * 1.0)
							local max = Ext.Round(range.Max * 1.0)
							range.Min = min + math.ceil(min * Game.Math.GetDamageBoostByType(character, damageType))
							range.Max = max + math.ceil(max * Game.Math.GetDamageBoostByType(character, damageType))
						end

						-- if mainDamageType ~= "None" and mainDamageType ~= "Sentinel" then
						-- 	local min, max = 0, 0
						-- 	local boost = Game.Math.GetDamageBoostByType(character, mainDamageType)
						-- 	for _, range in pairs(mainDamageRange) do
						-- 		min = min + range.Min + math.ceil(range.Min * Game.Math.GetDamageBoostByType(character, mainDamageType))
						-- 		max = max + range.Max + math.ceil(range.Min * Game.Math.GetDamageBoostByType(character, mainDamageType))
						-- 	end
					
						-- 	mainDamageRange[mainDamageType] = {Min = min, Max = max}
						-- end

						-- if offDamageType ~= "None" and offDamageType ~= "Sentinel" and offDamageType ~= mainDamageType then
						-- 	local min, max = 0, 0
						-- 	local boost = Game.Math.GetDamageBoostByType(character, offDamageType)
						-- 	for _, range in pairs(mainDamageRange) do
						-- 		min = min + range.Min + math.ceil(range.Min * Game.Math.GetDamageBoostByType(character, offDamageType))
						-- 		max = max + range.Max + math.ceil(range.Min * Game.Math.GetDamageBoostByType(character, offDamageType))
						-- 	end
						-- 	mainDamageRange[mainDamageType] = {Min = min, Max = max}
						-- end

						for damageType, range in pairs(mainDamageRange) do
							minDamage = minDamage + range.Min
							maxDamage = maxDamage + range.Max
						end

						return string.format("%s - %s", minDamage, maxDamage) 
					end
				},
				Vitality = {
					StatID = 12,
					StatType = 0,
					DisplayName = LocalizedText.CharacterSheet.Vitality,
					Type = "SecondaryStat",
					Frame = 1,
					Attribute = function(character) return string.format("%s/%s", character.CurrentVitality, character.MaxVitality) end
				},
				ActionPoints = {
					StatID = 13,
					StatType = 0,
					DisplayName = LocalizedText.CharacterSheet.ActionPoints,
					Type = "SecondaryStat",
					Frame = 2,
					Attribute = "APStart"
				},
				SourcePoints = {
					StatID = 14,
					StatType = 0,
					DisplayName = LocalizedText.CharacterSheet.SourcePoints,
					Type = "SecondaryStat",
					Frame = 3,
					Attribute = "MaxMpOverride"
				},
				PhysicalArmour = {
					StatID = 7,
					StatType = 1,
					DisplayName = LocalizedText.CharacterSheet.PhysicalArmour,
					Type = "SecondaryStat",
					Frame = 10,
					Attribute = function(character) return string.format("%s/%s", character.CurrentArmor, character.MaxArmor) end
				},
				MagicArmour = {
					StatID = 8,
					StatType = 1,
					DisplayName = LocalizedText.CharacterSheet.MagicArmour,
					Type = "SecondaryStat",
					Frame = 11,
					Attribute = function(character) return string.format("%s/%s", character.CurrentMagicArmor, character.MaxMagicArmor) end
				},
				NextLevel = {
					StatID = 37,
					StatType = 3,
					DisplayName = LocalizedText.CharacterSheet.NextLevel,
					Type = "SecondaryStat",
					Frame = 17,
					Attribute = function(character) return string.format("%s", math.floor(Data.LevelExperience[character.Level+1] - character.Experience)) end
				},
				Experience = {
					StatID = 36,
					StatType = 3,
					DisplayName = LocalizedText.CharacterSheet.Total,
					Type = "SecondaryStat",
					Frame = 19,
					Attribute = "Experience"
				},
				Air = {
					StatID = 31,
					StatType = 2,
					DisplayName = LocalizedText.CharacterSheet.Air,
					Type = "SecondaryStat",
					Frame = 8,
					Attribute = "AirResistance",
					Suffix = "%"
				},
				Earth = {
					StatID = 30,
					StatType = 2,
					DisplayName = LocalizedText.CharacterSheet.Earth,
					Type = "SecondaryStat",
					Frame = 7,
					Attribute = "EarthResistance",
					Suffix = "%"
				},
				Fire = {
					StatID = 28,
					StatType = 2,
					DisplayName = LocalizedText.CharacterSheet.Fire,
					Type = "SecondaryStat",
					Frame = 5,
					Attribute = "FireResistance",
					Suffix = "%"
				},
				Poison = {
					StatID = 32,
					StatType = 2,
					DisplayName = LocalizedText.CharacterSheet.Poison,
					Type = "SecondaryStat",
					Frame = 9,
					Attribute = "PoisonResistance",
					Suffix = "%"
				},
				Water = {
					StatID = 29,
					StatType = 2,
					DisplayName = LocalizedText.CharacterSheet.Water,
					Type = "SecondaryStat",
					Frame = 6,
					Attribute = "WaterResistance",
					Suffix = "%"
				},
				Spacing = {
					Height = 10,
					Type = "Spacing",
					StatType = 1
				}
			},
			Order = {
				"Strength",
				"Finesse",
				"Intelligence",
				"Constitution",
				"Memory",
				"Wits",
				"Vitality",
				"ActionPoints",
				"SourcePoints",
				"Damage",
				"CriticalChance",
				"Accuracy",
				"Dodging",
				"PhysicalArmour",
				"MagicArmour",
				--"Spacing",
				"Movement",
				"Initiative",
				"Fire",
				"Water",
				"Earth",
				"Air",
				"Poison",
				"Experience",
				"NextLevel"
			}
		},
		Attributes = {},
		Resistances = {},
		StatType = {
			PrimaryStat = "PrimaryStat",
			SecondaryStat = "SecondaryStat",
			Spacing = "Spacing"
		},
		SecondaryStatType = {
			Info = 0,
			Stat = 1,
			Resistance = 2,
			Experience = 3,
		},
		---@type table<integer,SheetSecondaryStatType>
		SecondaryStatTypeInteger = {
			[0] = "Info",
			[1] = "Stat",
			[2] = "Resistance",
			[3] = "Experience",
		}
	}
}
SheetManager.Stats.__index = SheetManager.Stats

if isClient then
	---@class SheetManager.StatsUIEntry
	---@field ID integer
	---@field DisplayName string
	---@field Value string
	---@field StatType string
	---@field SecondaryStatType string
	---@field SecondaryStatTypeInteger integer
	---@field CanAdd boolean
	---@field CanRemove boolean
	---@field IsCustom boolean
	---@field SpacingHeight number
	---@field Frame integer stat_mc.icon_mc's frame. If > totalFrames, then a custom iggy icon is used.
	---@field IconClipName string iggy_LL_ID
	---@field IconDrawCallName string LL_ID
	---@field Icon string
	---@field IconWidth number
	---@field IconHeight number

	---@private
	---@param player EclCharacter
	---@param isCharacterCreation boolean|nil
	---@param isGM boolean|nil
	---@return fun():SheetManager.StatsUIEntry
	function SheetManager.Stats.GetVisible(player, isCharacterCreation, isGM)
		if isCharacterCreation == nil then
			isCharacterCreation = false
		end
		if isGM == nil then
			isGM = false
		end
		local entries = {}
		--local tooltip = LocalizedText.UI.AbilityPlusTooltip:ReplacePlaceholders(Ext.ExtraData.CombatAbilityLevelGrowth)
		local points = Client.Character.Points.Attribute

		for i=1,#SheetManager.Stats.Data.Default.Order do
			local id = SheetManager.Stats.Data.Default.Order[i]
			local data = SheetManager.Stats.Data.Default.Entries[id]
			if id == "Spacing" then
				local entry = {
					StatType = SheetManager.Stats.Data.StatType.Spacing,
					SpacingHeight = data.Height,
				}
				entries[#entries+1] = entry
			else
				local value = nil
				if type(data.Attribute) == "function" then
					value = data.Attribute(player.Stats)
				else
					value = player.Stats[data.Attribute]
				end
				local canAdd = points > 0 and data.Type == "PrimaryStat"
				local canRemove = data.Type == "PrimaryStat" and (isCharacterCreation or isGM) and value > Ext.ExtraData.AttributeBaseValue
				local entry = {
					ID = data.StatID,
					DisplayName = data.DisplayName.Value,
					Value = string.format("%s", value) .. (data.Suffix or ""),
					CanAdd = canAdd,
					CanRemove = canRemove,
					IsCustom = false,
					StatType = data.Type,
					Frame = data.Frame or (data.Type == "PrimaryStat" and -1 or 0),
					SecondaryStatTypeInteger = data.StatType or 0,
					Icon = "",
					IconWidth = 0,
					IconHeight = 0,
					IconClipName = "",
					IconDrawCallName = ""
				}
				entries[#entries+1] = entry
			end
		end

		for mod,dataTable in pairs(SheetManager.Data.Stats) do
			for id,data in pairs(dataTable) do
				local value = data:GetValue(player)
				if SheetManager:IsEntryVisible(data, player, value) then
					local entry = {
						ID = data.GeneratedID,
						DisplayName = data:GetDisplayName(),
						Value = string.format("%s", value) .. data.Suffix,
						CanAdd = SheetManager:GetIsPlusVisible(data, player, isGM, value),
						CanRemove = SheetManager:GetIsMinusVisible(data, player, isGM, value),
						IsCustom = true,
						StatType = data.StatType,
						Frame = data.Frame or (data.StatType == "PrimaryStat" and -1 or 0),
						SecondaryStatType = data.SecondaryStatType,
						SecondaryStatTypeInteger = SheetManager.Stats.Data.SecondaryStatType[data.SecondaryStatType] or 0,
						SpacingHeight = data.SpacingHeight,
						Icon = data.SheetIcon or "",
						IconWidth = data.SheetIconWidth or 0,
						IconHeight = data.SheetIconHeight or 0,
						IconClipName = "",
						IconDrawCallName = ""
					}
					if not StringHelpers.IsNullOrEmpty(data.Icon) then
						entry.Frame = 99
						entry.IconDrawCallName = string.format("LL_%s", data.ID)
						entry.IconClipName = "iggy_" .. entry.IconDrawCallName
					end
					entries[#entries+1] = entry
				end
			end
		end

		local i = 0
		local count = #entries
		return function ()
			i = i + 1
			if i <= count then
				return entries[i]
			end
		end
	end
end