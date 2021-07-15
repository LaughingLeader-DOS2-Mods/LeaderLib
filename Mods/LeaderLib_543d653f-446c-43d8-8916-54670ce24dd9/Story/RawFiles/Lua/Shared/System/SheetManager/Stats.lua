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
	function SheetManager.Stats.GetVisible(player, civilOnly, this)
		local abilities = {}
		local tooltip = LocalizedText.UI.AbilityPlusTooltip:ReplacePlaceholders(Ext.ExtraData.CombatAbilityLevelGrowth)

		local abilityPoints = Client.Character.Points.Ability
		local civilPoints = Client.Character.Points.Civil
		--local abilityPoints = GetAvailablePoints("combat", this)
		--local civilPoints = GetAvailablePoints("civil", this)
	
		local maxAbility = Ext.ExtraData.CombatAbilityCap or 10
		local maxCivil = Ext.ExtraData.CivilAbilityCap or 5

		for numId,id in Data.Ability:Get() do
			local data = SheetManager.Stats.Data.Abilities[id] or SheetManager.Stats.Data.DOSAbilities[id]
			if data ~= nil and (civilOnly == true and data.Civil) or (civilOnly == false and not data.Civil) then
				if SheetManager.Stats.CanAddAbility(id, player) then
					local canAddPoints = false
					if civilOnly then
						canAddPoints = civilPoints > 0 and player.Stats[id] < maxCivil
					else
						canAddPoints = abilityPoints > 0 and player.Stats[id] < maxAbility
					end
					local name = GameHelpers.GetAbilityName(id)
					local isCivil = data.Civil == true
					local groupID = data.Group
					local statVal = player.Stats[id] or 0
					---@type TalentManagerUITalentEntry
					local data = {
						ID = id,
						SheetID = Data.AbilityEnum[id],
						DisplayName = name,
						IsCivil = isCivil,
						GroupID = groupID,
						IsCustom = false,
						Value = statVal,
						Delta = statVal,
						AddPointsTooltip = tooltip,
						CanAdd = canAddPoints,
						CanRemove = false,
					}
					abilities[#abilities+1] = data
				end
			end
		end
		local i = 0
		local count = #abilities
		return function ()
			i = i + 1
			if i <= count then
				return abilities[i]
			end
		end
	end
end