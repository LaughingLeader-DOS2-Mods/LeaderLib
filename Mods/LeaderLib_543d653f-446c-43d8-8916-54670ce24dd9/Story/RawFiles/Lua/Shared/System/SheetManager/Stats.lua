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
					SecondaryStatTypeInteger = SheetManager.Stats.Data.SecondaryStatTypeInteger[data.SecondaryStatType] or 0,
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
					entry.IconClipName = "iggy_" + entry.IconDrawCallName
				end
				entries[#entries+1] = entry
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