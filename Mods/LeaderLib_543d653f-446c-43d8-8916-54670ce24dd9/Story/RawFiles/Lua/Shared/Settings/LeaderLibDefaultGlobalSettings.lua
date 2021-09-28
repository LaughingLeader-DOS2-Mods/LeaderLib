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
	"LeaderLib_AllTooltipsForItemsEnabled",
	"LeaderLib_BuffStatusPreserverEnabled",
})
settings.Global.Flags.LeaderLib_RemovePathInfluencesOnChainAll.DebugOnly = true
settings.Global:AddLocalizedVariable("AutosaveInterval", "LeaderLib_Variables_AutosaveInterval", 15, 1, 600, 1)
settings.Global:AddLocalizedVariable("AutoCombatRange", "LeaderLib_Variables_AutoCombatRange", 30, 1, 200, 1)

settings.GetMenuOrder = function()
	local order = {
		{DisplayName = GameHelpers.GetStringKeyText("LeaderLib_UI_Settings_Features", "Features"),
		Entries = {
			"LeaderLib_AutoAddModMenuBooksDisabled",
			"LeaderLib_AutoUnlockInventoryInMultiplayer",
			"LeaderLib_FriendlyFireEnabled",
			"LeaderLib_PullPartyIntoCombat",
			"AutoCombatRange",
			"LeaderLib_RemovePathInfluencesOnChainAll",
			"LeaderLib_AllTooltipsForItemsEnabled",
			"LeaderLib_BuffStatusPreserverEnabled",
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
		}}
	}
	if Vars.DebugMode then
		table.insert(order, {
			DisplayName = GameHelpers.GetStringKeyText("LeaderLib_UI_Settings_Buttons", "Actions"),
			Entries = {
				"LeaderLib_Button_Reset",
		}})
	end
	return order
end

if Ext.IsDeveloperMode() then
	settings.Global:AddLocalizedButton("LeaderLib_Button_Reset", "LeaderLib_UI_Button_Reset", function(button, uuid, character)
		for i,v in pairs(settings.Global.Flags) do
			v.Enabled = v.Default
		end
		for i,v in pairs(settings.Global.Variables) do
			v.Value = v.Default
		end
		if Ext.IsClient() then
			if ModMenuManager.Controls then
				-- TODO: Update control settings, update actual flash controls.
			end
		end
	end, true, true)
end

GlobalSettings.Mods[ModuleUUID] = settings

if Ext.IsServer() then
	settings.Global.Flags.LeaderLib_BuffStatusPreserverEnabled:AddListener(function(id, enabled, data, settingsData)
		BuffStatusPreserver:SetEnabled(enabled)
	end)
	settings.Global.Flags.LeaderLib_FriendlyFireEnabled:AddListener(function(id, enabled, data, settingsData)
		TagManager:TagAll(enabled)
	end)
end