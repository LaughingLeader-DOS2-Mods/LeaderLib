Ext.Require("Shared.lua")

Client = Classes.ClientData:Create("")

if UI == nil then
	---@class LeaderLibUIMain
	UI = {}
end
UI.Debug = {
	LogUI = false,
	PrintAll = false,
}

UI.MaxHotbarSlots = 29

Ext.RegisterUITypeCall(Data.UIType.hotBar, "updateSlots", function (ui, call, maxSlots)
	UI.MaxHotbarSlots = maxSlots
	ui:GetRoot()._totalVisibleSlots = maxSlots
end)
Ext.RegisterUITypeCall(Data.UIType.bottomBar_c, "updateSlots", function (ui, call, maxSlots)
	UI.MaxHotbarSlots = maxSlots
	ui:GetRoot()._totalVisibleSlots = maxSlots
end)

Events.LuaReset:Subscribe(function ()
	local ui = Ext.UI.GetByType(not Vars.ControllerEnabled and Data.UIType.hotBar or Data.UIType.bottomBar_c)
	if ui then
		local this = ui:GetRoot()
		if this and type(this._totalVisibleSlots) == "number" then
			UI.MaxHotbarSlots = this._totalVisibleSlots
		end
	end
end)

---@deprecated
---Deprecated since UIListeners were moved to the regular Listeners.
---Registers a function to call when a specific Lua LeaderLib UI event fires.
---@param event string OnTooltipPositioned
---@param callback function
function UI.RegisterListener(event, callback, ...)
	---@diagnostic disable-next-line
	RegisterListener(event, callback, ...)
end

Ext.Events.UIObjectCreated:Subscribe(function(e)
	if e.UI.Type == Data.UIType.msgBox_c then
		if not Vars.ControllerEnabled then
			Vars.ControllerEnabled = true
		end
	end
end)

-- Should exist before SessionLoaded
Vars.ControllerEnabled = (Ext.UI.GetByPath("Public/Game/GUI/msgBox_c.swf") or Ext.UI.GetByType(Data.UIType.msgBox_c)) ~= nil
-- if controllerUI ~= nil then
-- 	Ext.Require("Client/UI/Game.Tooltip.Controllers.lua")
-- end

local function EnableGameTooltipOverride()
	return true
	-- if Game and Game.Tooltip and Game.Tooltip.RequestProcessor then
	-- 	return false
	-- end
	-- return true
end

Ext.Require("Client/Classes/_Init.lua")
Ext.Require("Client/Data/_Init.lua")
Ext.Require("Client/ClientHelpers.lua")
Ext.Require("Client/Helpers/CharacterCreationHelpers.lua")
Ext.Require("Client/ClientNetMessages.lua")
Ext.Require("Client/InputManager.lua")

Ext.Require("Client/UI/UITypeWorkaround.lua")
Ext.Require("Client/UI/UIListeners.lua")
Ext.Require("Client/QOL/StatusHider.lua")
Ext.Require("Client/QOL/ShowConsumableEffects.lua")
Ext.Require("Client/QOL/ShowBarText.lua")
Ext.Require("Client/QOL/TooltipDelay.lua")
Ext.Require("Client/QOL/ModMenuFixes.lua")
Ext.Require("Client/QOL/ToggleChain.lua")
if EnableGameTooltipOverride() then
	Ext.Require("Client/UI/Tooltips/Game.Tooltip.Extended.lua")
end
Ext.Require("Client/UI/CustomAttributes.lua")
Ext.Require("Client/UI/CharacterSheet.lua")
Ext.Require("Client/UI/ModMenu/_Init.lua")
Ext.Require("Client/UI/Tooltips/TooltipHandler.lua")
Ext.Require("Client/UI/Tooltips/TooltipInfoExpander.lua")
Ext.Require("Client/UI/Tooltips/ExperienceTooltipFix.lua")
Ext.Require("Client/UI/Tooltips/StatusMalusTooltipFix.lua")
Ext.Require("Client/UI/ControllerUIHelpers.lua")
Ext.Require("Client/UI/UIFeatures.lua")
Ext.Require("Client/UI/UIExtensions.lua")
Ext.Require("Client/UI/InterfaceCommands.lua")
Ext.Require("Client/UI/ContextMenu.lua")
Ext.Require("Client/UI/CharacterCreation/CCExtensionUI.lua")
if Ext.Utils.Version() >= 56 then
	Ext.Require("Client/UI/CharacterCreation/PresetExtension.lua")
	Ext.Require("Client/QOL/ChatLogHider.lua")
	Ext.Require("Shared/QOL/ExtenderVisualSupport.lua")
	Ext.Require("Shared/QOL/InventoryTweaks.lua")
end
Ext.Require("Client/UI/JournalChangelog.lua")
Ext.Require("Client/_Init.lua")
Ext.Require("Shared/UI/CombatLog.lua")
Ext.Require("Shared/UI/MessageBox.lua")
Ext.Require("Shared/UI/Overhead.lua")
Ext.Require("Shared/System/TutorialManager.lua")

if Ext.Debug.IsDeveloperMode() then
	Ext.Require("Shared/Debug/SharedDebug.lua")
end

local function LeaderLib_SyncRanSeed(call, seedstr)
	LEADERLIB_RAN_SEED = math.tointeger(seedstr)
	fprint(LOGLEVEL.TRACE, "[LeaderLib:BootstrapClient.lua:LeaderLib_SyncRanSeed] Set [LEADERLIB_RAN_SEED] to (%s", LEADERLIB_RAN_SEED)
end

Ext.RegisterNetListener("LeaderLib_SyncRanSeed", LeaderLib_SyncRanSeed)

Ext.Events.SessionLoaded:Subscribe(function()
	if not SettingsManager.LoadedInitially then
		LoadGlobalSettings()
	end

	---@param e LeaderLibCustomAttributeTooltipCallbackEventArgs
	local function _GetResistancePenElement(e)
		if e.Value > 0 then
			local damageType = Data.ResistancePenetrationAttributes[e.Attribute]
			local resistanceText = GameHelpers.GetResistanceNameFromDamageType(damageType)
			if not StringHelpers.IsNullOrWhitespace(resistanceText) then
				if e.TooltipType == "Item" then
					e.Tooltip:AppendElementAfterType({
						Type = "ResistanceBoost",
						Label = LocalizedText.ItemBoosts.ResistancePenetration:ReplacePlaceholders(resistanceText),
						Value = e.Value,
					}, "ResistanceBoost")
				elseif e.TooltipType == "Status" then
					e.Tooltip:AppendElementAfterType({
						Type = "StatusBonus",
						Label = LocalizedText.StatusBoosts.ResistancePenetration:ReplacePlaceholders(resistanceText, e.Value),
					}, "StatusBonus")
				end
			end
		end
	end

	for attributeName,_ in pairs(Data.ResistancePenetrationAttributes) do
		GameHelpers.UI.RegisterCustomAttribute({
			Attribute = attributeName,
			GetTooltipElement = _GetResistancePenElement,
			StatType = {"Armor", "Shield", "Weapon", "Character", "Potion"}
		})
	end

	if Vars.LeaderDebugMode then
		GameHelpers.UI.RegisterCustomAttribute({
			Attribute = "ArmorBoost",
			GetTooltipElement = function (e)
				if e.TooltipType == "Rune" and e.Value > 0 then
					e:UpdateElement("Spaghetti Code: 2")
				end
			end,
			StatType = {"Armor"}
		})
	end
end)

Events.Loaded:Invoke(nil)