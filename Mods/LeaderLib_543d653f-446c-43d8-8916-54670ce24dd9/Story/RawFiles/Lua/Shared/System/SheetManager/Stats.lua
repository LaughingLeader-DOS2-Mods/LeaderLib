local ts = Classes.TranslatedString

local isClient = Ext.IsClient()

---@class StatsManager
SheetManager.Stats = {
	Data = {
		Attributes = {},
		Resistances = {}
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
	---@field IsCustom boolean

	---@private
	---@param player EclCharacter
	---@param civilOnly boolean|nil
	---@return fun():SheetManager.StatsUIEntry
	function SheetManager.Stats.GetVisible(player)
		local entries = {}
		--local tooltip = LocalizedText.UI.AbilityPlusTooltip:ReplacePlaceholders(Ext.ExtraData.CombatAbilityLevelGrowth)
		local points = Client.Character.Points.Attribute
		for mod,dataTable in pairs(SheetManager.Data.Stats) do
			for id,data in pairs(dataTable) do
				entries[#entries+1] = {
					ID = data.GeneratedID,
					DisplayName = data.DisplayName,
					Value = string.format("%s", data:GetValue(player)),
					TooltipID = data.TooltipID,
					CanAdd = false,
					CanRemove = false,
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