local isClient = Ext.IsClient()

---@type ModSettings
local ModSettings = Classes.ModSettingsClasses.ModSettings
local settings = ModSettings:Create(ModuleUUID)
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
	"LeaderLib_AutoIdentifyItemsEnabled",
	"LeaderLib_PermanentSpiritVisionEnabled",
	"LeaderLib_ShowConsumableEffectsEnabled",
})
settings.Global.Flags.LeaderLib_RemovePathInfluencesOnChainAll.DebugOnly = true
--settings.Global:AddLocalizedVariable("AutosaveInterval", "LeaderLib_Variables_AutosaveInterval", 15, 1, 600, 1)
settings.Global:AddLocalizedVariable("AutoCombatRange", "LeaderLib_Variables_AutoCombatRange", 30, 1, 30, 1)
settings.Global:AddLocalizedVariable("CombatSightRangeMultiplier", "LeaderLib_Variables_CombatSightRangeMultiplier", 2.5, 1, 30, 1)
settings.Global:AddLocalizedVariable("CarryWeightBase", "LeaderLib_Variables_CarryWeightBase", 0, 0, 200000, 1)

settings.GetMenuOrder = function()
	local order = {
		{DisplayName = GameHelpers.GetStringKeyText("LeaderLib_UI_Settings_Features", "Features"),
		Entries = {
			"LeaderLib_FriendlyFireEnabled",
			"LeaderLib_BuffStatusPreserverEnabled",
			"LeaderLib_PullPartyIntoCombat",
			"AutoCombatRange",
			"CombatSightRangeMultiplier",
		}},
		{DisplayName = GameHelpers.GetStringKeyText("LeaderLib_UI_Settings_QOL", "Quality of Life"),
		Entries = {
			"LeaderLib_AutoAddModMenuBooksDisabled",
			"LeaderLib_AutoUnlockInventoryInMultiplayer",
			"LeaderLib_AutoIdentifyItemsEnabled",
			"CarryWeightBase",
			"LeaderLib_PermanentSpiritVisionEnabled",
			"LeaderLib_ShowConsumableEffectsEnabled",
			"LeaderLib_AllTooltipsForItemsEnabled",
			"LeaderLib_RemovePathInfluencesOnChainAll"
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
			--"AutosaveInterval",
		}},	
		{DisplayName = GameHelpers.GetStringKeyText("LeaderLib_UI_Settings_Fixes", "Fixes"),
		Entries = {
			"LeaderLib_UnhealableFix_Enabled",
		}},	
		{DisplayName = GameHelpers.GetStringKeyText("LeaderLib_UI_Settings_Misc", "Misc"),
		Entries = {
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

--round(((1 (or 2.0 if Packmule talent) * Strength) * [ExtraData:CarryWeightPerStr:10000]) + CarryWeightBase)
local _weightFormulaText = "round((Packmule:%s x Strength:%s) x CarryWeightPerStr:%s) + CarryWeightBase:<font color='#33DD33'>%s</font>) = <font color='#33FF33'>%s</font>"

Events.GetTextPlaceholder:Subscribe(function (e)
	--round(((1 (or 2.0 if Packmule talent) * Strength) * [ExtraData:CarryWeightPerStr:10000]) + CarryWeightBase)
	local packMuleBonus = e.Character.TALENT_Carry and 2.0 or 1.0
	local strength = e.Character.Strength
	local weightPerStr = GameHelpers.GetExtraData("CarryWeightPerStr", 10000)
	local carryWeightBase = GameHelpers.GetExtraData("CarryWeightBase", 0)
	local result = Ext.Round(((packMuleBonus * strength) * weightPerStr) + carryWeightBase)
	return _weightFormulaText:format(packMuleBonus, strength, weightPerStr, carryWeightBase, result)

end, {MatchArgs={ID="CarryWeightFormula"}})

Ext.Events.SessionLoaded:Subscribe(function (e)
	local sightRange = GameHelpers.GetExtraData("End Of Combat SightRange Multiplier", 2.5)
	if sightRange ~= 2.5 then
		settings.Global.Variables.CombatSightRangeMultiplier.Default = sightRange
	end
	local carryWeightBase = GameHelpers.GetExtraData("CarryWeightBase", 2.5)
	if carryWeightBase ~= 0 then
		settings.Global.Variables.CarryWeightBase.Default = carryWeightBase
	end

end)

Events.BeforeLuaReset:Subscribe(function (e)
	Ext.ExtraData["End Of Combat SightRange Multiplier"] = settings.Global.Variables.CombatSightRangeMultiplier.Default
	Ext.ExtraData.CarryWeightBase = settings.Global.Variables.CarryWeightBase.Default
end)

settings.Global.Variables.CombatSightRangeMultiplier:Subscribe(function (e)
	Ext.ExtraData["End Of Combat SightRange Multiplier"] = e.Value
	--Ext.ExtraData["Ally Joins Ally SightRange Multiplier"] = e.Value -- Unused?
	fprint(LOGLEVEL.TRACE, "[LeaderLib] Set 'End Of Combat SightRange Multiplier' to (%s)", e.Value)
end)

settings.Global.Variables.CarryWeightBase:Subscribe(function (e)
	Ext.ExtraData.CarryWeightBase = e.Value
	fprint(LOGLEVEL.TRACE, "[LeaderLib] Set CarryWeightBase to (%s)", e.Value)
end)

if Ext.IsServer() then
	settings.Global.Flags.LeaderLib_BuffStatusPreserverEnabled:Subscribe(function(e)
		if not e.Value then
			BuffStatusPreserver.Disable()
		end
	end)
	settings.Global.Flags.LeaderLib_FriendlyFireEnabled:Subscribe(function(e)
		if Ext.GetGameState() == "Running" then
			TagManager:TagAll(e.Value)
		end
	end)
	settings.Global.Variables.AutoCombatRange:Subscribe(function(e)
		if settings.Global:FlagEquals("LeaderLib_PullPartyIntoCombat", true) then
			Timer.Start("LeaderLib_PullPartyIntoCombat", 500)
		end
	end)
	settings.Global.Flags.LeaderLib_PullPartyIntoCombat:Subscribe(function(e)
		if e.Value then
			Timer.Start("LeaderLib_PullPartyIntoCombat", 500)
		else
			Timer.Cancel("LeaderLib_PullPartyIntoCombat")
		end
	end)
	settings.Global.Flags.LeaderLib_AutoIdentifyItemsEnabled:Subscribe(function(e)
		local switches = Ext.Utils.GetGlobalSwitches()
		if switches then
			switches.AutoIdentifyItems = e.Value == true
		end
		if e.Value then
			fprint(LOGLEVEL.TRACE, "[LeaderLib] Identifying the party's items...")
			local total = 0
			for player in GameHelpers.Character.GetPlayers() do
				total = total + IdentifyAllItems(player)
			end
			fprint(LOGLEVEL.TRACE, "[LeaderLib] Identified (%s) items.", total)
		end
	end)
end

--Making sure autosaves are enabled in the options if this flag is enabled
if Ext.Version() >= 56 then
	settings.Global.Flags.LeaderLib_AutosavingEnabled:Subscribe(function(e)
		if e.Value then
			local options = Ext.Utils.GetGlobalSwitches()
			if options then
				options.CanAutoSave = true
			end
		end
	end)
end