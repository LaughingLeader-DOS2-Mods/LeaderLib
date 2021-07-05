if SheetManager.Data == nil then
	SheetManager.Data = {}
end
SheetManager.Data.Calls = {
	Tooltip = {
		Ability = "showAbilityTooltipCustom",
		Talent = "showTalentTooltipCustom",
		Stat = "showStatTooltipCustom",
		SecondaryStat = "showStatTooltipCustom",
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

RegisterListener("ControllerModeEnabled", function()
	SheetManager.Data.Calls.Tooltip = {
		Ability = "selectAbilityCustom",
		Talent = "selectTalentCustom",
		Stat = "selectStatCustom",
		SecondaryStat = "selectSecStatCustom",
	}
end)