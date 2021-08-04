local ts = Classes.TranslatedString

local isClient = Ext.IsClient()

---@alias SheetStatType string | "PrimaryStat" | "SecondaryStat" | "Spacing"
---@alias SheetSecondaryStatType string | "Info" | "Normal" | "Resistance"

---@class StatsManager
SheetManager.Stats = {
	Data = {
		{
			Default = {
				Primary = {
					Strength = {
						DisplayName = LocalizedText.CharacterSheet.Strength,
						StatID = 0,
						TooltipID = 0,
						Attribute = "Strength"
					},
					Finesse = {
						DisplayName = LocalizedText.CharacterSheet.Finesse,
						StatID = 1,
						TooltipID = 1,
						Attribute = "Finesse"
					},
					Intelligence = {
						DisplayName = LocalizedText.CharacterSheet.Intelligence,
						StatID = 2,
						TooltipID = 2,
						Attribute = "Intelligence"
					},
					Constitution = {
						DisplayName = LocalizedText.CharacterSheet.Constitution,
						StatID = 3,
						TooltipID = 3,
						Attribute = "Constitution"
					},
					Memory = {
						DisplayName = LocalizedText.CharacterSheet.Memory,
						StatID = 4,
						TooltipID = 4,
						Attribute = "Memory"
					},
					Wits = {
						DisplayName = LocalizedText.CharacterSheet.Wits,
						StatID = 5,
						TooltipID = 5,
						Attribute = "Wits"
					}
				},
				Secondary = {
					Dodging = {
						StatID = 11,
						StatType = 1,
						DisplayName = LocalizedText.CharacterSheet.Dodging,
						Type = "SecondaryStat",
						Frame = 15,
						Attribute = "Dodge"
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
						Display = "Percentage"
					},
					Accuracy = {
						StatID = 10,
						StatType = 1,
						DisplayName = LocalizedText.CharacterSheet.Accuracy,
						Type = "SecondaryStat",
						Frame = 13,
						Attribute = "Accuracy",
						Display = "Percentage"
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

							if offHandWeapon ~= nil and Game.Math.IsRangedWeapon(mainWeapon) == Game.Math.IsRangedWeapon(offHandWeapon) then
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
								minDamage = minDamage + min + math.ceil(min * Game.Math.GetDamageBoostByType(character, damageType))
								maxDamage = maxDamage + max + math.ceil(max * Game.Math.GetDamageBoostByType(character, damageType))
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
						Attribute = function(character) return string.format("%s", math.floor(character.Experience - Data.LevelExperience[character.Level+1])) end
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
						Display = "Percentage"
					},
					Earth = {
						StatID = 30,
						StatType = 2,
						DisplayName = LocalizedText.CharacterSheet.Earth,
						Type = "SecondaryStat",
						Frame = 7,
						Attribute = "EarthResistance",
						Display = "Percentage"
					},
					Fire = {
						StatID = 28,
						StatType = 2,
						DisplayName = LocalizedText.CharacterSheet.Fire,
						Type = "SecondaryStat",
						Frame = 5,
						Attribute = "FireResistance",
						Display = "Percentage"
					},
					Poison = {
						StatID = 32,
						StatType = 2,
						DisplayName = LocalizedText.CharacterSheet.Poison,
						Type = "SecondaryStat",
						Frame = 9,
						Attribute = "PoisonResistance",
						Display = "Percentage"
					},
					Water = {
						StatID = 29,
						StatType = 2,
						DisplayName = LocalizedText.CharacterSheet.Water,
						Type = "SecondaryStat",
						Frame = 6,
						Attribute = "WaterResistance",
						Display = "Percentage"
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
					"Spacing",
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
		for mod,dataTable in pairs(SheetManager.Data.Stats) do
			for id,data in pairs(dataTable) do
				local value = data:GetValue(player)
				if SheetManager:IsEntryVisible(data, player, value) then
					local entry = {
						ID = data.GeneratedID,
						DisplayName = data.DisplayName,
						Value = string.format("%s", value),
						CanAdd = SheetManager:GetIsPlusVisible(data, player, isGM, value),
						CanRemove = SheetManager:GetIsMinusVisible(data, player, isGM, value),
						IsCustom = true,
						StatType = data.StatType,
						Frame = 0,
						SecondaryStatType = data.SecondaryStatType,
						SecondaryStatTypeInteger = SheetManager.Stats.Data.SecondaryStatType[data.SecondaryStatType] or 0,
						SpacingHeight = data.SpacingHeight,
						Icon = data.Icon,
						IconWidth = data.IconWidth,
						IconHeight = data.IconHeight,
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