if SheetManager.Config == nil then
	SheetManager.Config = {}
end
SheetManager.Config.Calls = {
	Tooltip = {
		Ability = "showAbilityTooltipCustom",
		Talent = "showTalentTooltipCustom",
		Stat = "showStatTooltipCustom",
		SecondaryStat = "showStatTooltipCustom",
	},
	TooltipController = {
		Ability = "selectAbilityCustom",
		Talent = "selectTalentCustom",
		Stat = "selectStatCustom",
		SecondaryStat = "selectSecStatCustom",
	},
	PointRemoved = {
		Ability = "minAbilityCustom",
		Talent = "minTalentCustom",
		Stat = "minStatCustom",
		SecondaryStat = "minSecStatCustom",
	},
	PointAdded = {
		Ability = "plusAbilityCustom",
		Talent = "plusTalentCustom",
		Stat = "plusStatCustom",
		SecondaryStat = "plusSecStatCustom",
	}
}