---@type ModSettings
local ModSettings = Classes.ModSettingsClasses.ModSettings
local settings = ModSettings:Create("7e737d2f-31d2-4751-963f-be6ccc59cd0c")
settings.TitleColor = "#369BFF"
settings.Global:AddLocalizedFlags({
	"LeaderLib_RemovePathInfluencesOnChainAll",
	"LeaderLib_AutoAddModMenuBooksDisabled",
	"LeaderLib_AutoUnlockInventoryInMultiplayer",
	"LeaderLib_AutosaveOnCombatStart",
	"LeaderLib_AutosavingEnabled",
	"LeaderLib_DisableAutosavingInCombat",
	"LeaderLib_DebugModeEnabled",
	"LeaderLib_DialogRedirectionEnabled",
	"LeaderLib_DialogRedirection_DisableUserRestriction",
	"LeaderLib_DialogRedirection_HighestPersuasionEnabled",
	"LeaderLib_FriendlyFireEnabled",
	"LeaderLib_PullPartyIntoCombat",
	"LeaderLib_UnhealableFix_Enabled",
})
settings.Global.Flags.LeaderLib_RemovePathInfluencesOnChainAll.DebugOnly = true
settings.Global:AddLocalizedVariable("AutosaveInterval", "LeaderLib_Variables_AutosaveInterval", 15, 1, 600, 1)
settings.Global:AddLocalizedVariable("AutoCombatRange", "LeaderLib_Variables_AutoCombatRange", 30, 1, 200, 1)

settings.GetMenuOrder = function()
	return {
		{DisplayName = GameHelpers.GetStringKeyText("LeaderLib_UI_Settings_Features", "Features"),
		Entries = {
			"LeaderLib_AutoAddModMenuBooksDisabled",
			"LeaderLib_AutoUnlockInventoryInMultiplayer",
			"LeaderLib_FriendlyFireEnabled",
			"LeaderLib_PullPartyIntoCombat",
			"AutoCombatRange",
			"LeaderLib_RemovePathInfluencesOnChainAll",
		}},
		{DisplayName = GameHelpers.GetStringKeyText("LeaderLib_UI_Settings_DialogRedirection", "Dialog Redirection"), 
		Entries = {		
			"LeaderLib_DialogRedirectionEnabled",
			"LeaderLib_DialogRedirection_DisableUserRestriction",
			"LeaderLib_DialogRedirection_HighestPersuasionEnabled",
		}},	
		{DisplayName = GameHelpers.GetStringKeyText("LeaderLib_UI_Settings_Autosaving", "Autosaving"), 
		Entries = {		
			"LeaderLib_AutosavingEnabled",
			"LeaderLib_AutosaveOnCombatStart",
			"LeaderLib_DisableAutosavingInCombat",
			"AutosaveInterval",
		}},	
		{DisplayName = GameHelpers.GetStringKeyText("LeaderLib_UI_Settings_Fixes", "Fixes"),
		Entries = {
			"LeaderLib_UnhealableFix_Enabled",
			"LeaderLib_DebugModeEnabled",
		}},
	}
end

GlobalSettings.Mods["7e737d2f-31d2-4751-963f-be6ccc59cd0c"] = settings