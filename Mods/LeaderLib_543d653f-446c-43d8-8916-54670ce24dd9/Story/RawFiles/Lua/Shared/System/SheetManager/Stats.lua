local ts = Classes.TranslatedString

local isClient = Ext.IsClient()

---@alias SheetStatType string | "Primary" | "Secondary" | "Spacing"
---@alias SheetSecondaryStatType string | "Info" | "Normal" | "Resistance"

---@class StatsManager
SheetManager.Stats = {
	Data = {
		Attributes = {},
		Resistances = {},
		StatType = {
			Primary = "Primary",
			Secondary = "Secondary",
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
	---@field ID string
	---@field SheetID integer
	---@field DisplayName string
	---@field IsCivil boolean
	---@field GroupID integer
	---@field GroupTitle string
	---@field AddPointsTooltip string
	---@field Value integer
	---@field Delta integer
	---@field CanAdd boolean
	---@field CanRemove boolean
	---@field IsCustom boolean

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
				entries[#entries+1] = {
					ID = data.GeneratedID,
					DisplayName = data.DisplayName,
					Value = string.format("%s", value),
					TooltipID = data.TooltipID,
					CanAdd = SheetManager:GetIsPlusVisible(data, player, isGM, value),
					CanRemove = SheetManager:GetIsMinusVisible(data, player, isGM, value),
					IsCustom = true,
					IsPrimary = data.IsPrimary
				}
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