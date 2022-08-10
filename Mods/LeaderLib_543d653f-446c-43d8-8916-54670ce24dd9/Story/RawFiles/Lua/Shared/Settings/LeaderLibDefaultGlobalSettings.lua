local _ISCLIENT = Ext.IsClient()

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
	"LeaderLib_CarryWeightOverrideEnabled",
})
settings.Global.Flags.LeaderLib_RemovePathInfluencesOnChainAll.DebugOnly = true
--settings.Global:AddLocalizedVariable("AutosaveInterval", "LeaderLib_Variables_AutosaveInterval", 15, 1, 600, 1)
settings.Global:AddLocalizedVariable("AutoCombatRange", "LeaderLib_Variables_AutoCombatRange", 30, 1, 30, 1)
settings.Global:AddLocalizedVariable("CombatSightRangeMultiplier", "LeaderLib_Variables_CombatSightRangeMultiplier", 2.5, 1, 30, 0.5)
settings.Global:AddLocalizedVariable("CarryWeightBase", "LeaderLib_Variables_CarryWeightBase", 0, 0, 1000, 10)
settings.Global:AddLocalizedButton("LeaderLib_ReloadStatChangesConfig", "LeaderLib_ReloadStatChangesConfig", function (entry, modUUID, character)
	if _ISCLIENT then
		Ext.Net.PostMessageToServer("LeaderLib_StatChangesConfig_Run", "")
	else
		QOL.StatChangesConfig:Run()
	end
end, true, true)

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
			"LeaderLib_CarryWeightOverrideEnabled",
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
				"LeaderLib_ReloadStatChangesConfig",
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
local _weightFormulaText = "<br>((%s x [Strength:%s]) x [CarryWeightPerStr:%s]) + ([CarryWeightBase:<font color='#33DD33'>%s</font>] x 1000)<br>[Handle:hccfc1bb7ga7feg41d1g8d2fg3c0c2972e723:Result]: <font color='#33FF33'>%s [Handle:hd47021f7g7867g4714ga91cg02ac22e9cfb3:MaxWeight]</font>"

Events.GetTextPlaceholder:Subscribe(function (e)
	--round(((1 (or 2.0 if Packmule talent) * Strength) * [ExtraData:CarryWeightPerStr:10000]) + CarryWeightBase)
	local packMuleBonus = 1.0
	local packMuleText = tostring(math.ceil(packMuleBonus))
	if e.Character.TALENT_Carry then
		packMuleBonus = 2.0
		packMuleText = string.format("[%s:%i]", LocalizedText.TalentNames.Carry.Value, packMuleBonus)
	end
	local strength = e.Character.Strength
	local weightPerStr = GameHelpers.GetExtraData("CarryWeightPerStr", 10000)
	local carryWeightBase = GameHelpers.GetExtraData("CarryWeightBase", 0)
	local result = Ext.Round((((packMuleBonus * strength) * weightPerStr) + carryWeightBase) * 0.001)
	e.Result = GameHelpers.Tooltip.ReplacePlaceholders(_weightFormulaText:format(packMuleText, strength, weightPerStr, carryWeightBase, result))
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
	Ext.ExtraData["End Of Combat SightRange Multiplier"] = 2.5
	Ext.ExtraData.CarryWeightBase = 0
end)

settings.Global.Variables.CombatSightRangeMultiplier:Subscribe(function (e)
	Ext.ExtraData["End Of Combat SightRange Multiplier"] = e.Value
	--Ext.ExtraData["Ally Joins Ally SightRange Multiplier"] = e.Value -- Unused?
	fprint(LOGLEVEL.TRACE, "[LeaderLib] Set 'End Of Combat SightRange Multiplier' to (%s) [%s]", e.Value, _ISCLIENT and "CLIENT" or "SERVER")
end)

local hasSetBaseCarryweight = false
local carryWeightAwaitingNextTick = false

local function UpdateBaseCarryWeight(value)
	local weightBase = Ext.Utils.Round(value * 1000)
	if not hasSetBaseCarryweight then
		hasSetBaseCarryweight = Ext.ExtraData.CarryWeightBase ~= weightBase
	end
	Ext.ExtraData.CarryWeightBase = weightBase
	fprint(LOGLEVEL.TRACE, "[LeaderLib:%s] Set CarryWeightBase to (%s)", _ISCLIENT and "CLIENT" or "SERVER", weightBase)
end

settings.Global.Variables.CarryWeightBase:Subscribe(function (e)
	if not carryWeightAwaitingNextTick then
		carryWeightAwaitingNextTick = true
		Ext.OnNextTick(function (e)
			local var = settings.Global.Variables.CarryWeightBase
			if settings.Global:FlagEquals("LeaderLib_CarryWeightOverrideEnabled", true) then
				UpdateBaseCarryWeight(var.Value)
			elseif hasSetBaseCarryweight then
				Ext.ExtraData.CarryWeightBase = var.Default or 0
				fprint(LOGLEVEL.TRACE, "[LeaderLib:%s] Disabled CarryWeightBase override.", _ISCLIENT and "CLIENT" or "SERVER")
				hasSetBaseCarryweight = false
			end
			carryWeightAwaitingNextTick = false
		end)
	end
end)

settings.Global.Flags.LeaderLib_CarryWeightOverrideEnabled:Subscribe(function (e)
	if not carryWeightAwaitingNextTick then
		if e.Value then
			carryWeightAwaitingNextTick = true
			Ext.OnNextTick(function (e)
				local value = settings.Global:GetVariable("CarryWeightBase", 0)
				UpdateBaseCarryWeight(value)
				carryWeightAwaitingNextTick = false
			end)
		elseif hasSetBaseCarryweight then
			local var = e.Settings.Variables.CarryWeightBase
			Ext.ExtraData.CarryWeightBase = var and var.Default or 0
			hasSetBaseCarryweight = false
		end
		fprint(LOGLEVEL.TRACE, "[LeaderLib:%s] Disabled CarryWeightBase override.", _ISCLIENT and "CLIENT" or "SERVER")
	end
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
settings.Global.Flags.LeaderLib_AutosavingEnabled:Subscribe(function(e)
	if e.Value then
		local options = Ext.Utils.GetGlobalSwitches()
		if options then
			options.CanAutoSave = true
		end
	end
end)