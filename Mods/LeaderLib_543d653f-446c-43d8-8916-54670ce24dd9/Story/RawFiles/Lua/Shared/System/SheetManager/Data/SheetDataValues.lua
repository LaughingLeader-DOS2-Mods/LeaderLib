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
		Ability = "minusAbilityCustom",
		Talent = "minusTalentCustom",
		PrimaryStat = "minusStatCustom",
		SecondaryStat = "minusSecStatCustom",
	},
	PointAdded = {
		Ability = "plusAbilityCustom",
		Talent = "plusTalentCustom",
		PrimaryStat = "plusStatCustom",
		SecondaryStat = "plusSecStatCustom",
	}
}