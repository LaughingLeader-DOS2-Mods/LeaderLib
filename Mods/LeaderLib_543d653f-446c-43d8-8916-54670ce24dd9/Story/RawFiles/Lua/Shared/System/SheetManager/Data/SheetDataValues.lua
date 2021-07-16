if SheetManager.Config == nil then
	SheetManager.Config = {}
end
SheetManager.Config.Calls = {
	Tooltip = {
		Ability = "showAbilityTooltipCustom",
		Talent = "showTalentTooltipCustom",
		PrimaryStat = "showStatTooltipCustom",
		SecondaryStat = "showStatTooltipCustom",
	},
	TooltipController = {
		Ability = "selectAbilityCustom",
		Talent = "selectTalentCustom",
		PrimaryStat = "selectStatCustom",
		SecondaryStat = "selectSecStatCustom",
	},
	PointRemoved = {
		Ability = "minAbilityCustom",
		Talent = "minTalentCustom",
		PrimaryStat = "minStatCustom",
		SecondaryStat = "minSecStatCustom",
	},
	PointAdded = {
		Ability = "plusAbilityCustom",
		Talent = "plusTalentCustom",
		PrimaryStat = "plusStatCustom",
		SecondaryStat = "plusSecStatCustom",
	}
}