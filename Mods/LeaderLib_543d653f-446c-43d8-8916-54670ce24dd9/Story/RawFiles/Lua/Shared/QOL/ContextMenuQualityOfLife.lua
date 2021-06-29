local isClient = Ext.IsClient()
local ts = Classes.TranslatedString

if isClient then
	--local combatLogTooltip = ts:Create("hf7c8b6b6g580bg4bc0g96efg5d9cd1500754", "Combat Log")
	local combatLogTooltip = ts:Create("h1b7b6ddbg0b60g455dgac16g21fc2e843581", "Toggle Log")
	---@private
	---@class ContextMenuOpenTarget
	local TARGET = {
		CombatLog = "CombatLog"
	}

	local function ClearCombatLog()
		CombatLog.Clear()
		Ext.Print("[LeaderLib] Cleared the combat log.")
	end

	local openTarget = ""

	Ext.RegisterListener("SessionLoaded", function()
		UI.ContextMenu.Register.ShouldOpenListener(function(contextMenu, x, y)
			openTarget = ""
			print(Game.Tooltip.TooltipHooks.ActiveType, Game.Tooltip.IsOpen())
			if Game.Tooltip.LastRequestTypeEquals("Generic") and Game.Tooltip.IsOpen() then
				---@type TooltipGenericRequest
				local data = Game.Tooltip.GetCurrentOrLastRequest()
				if combatLogTooltip:Equals(data.Text) then
					openTarget = TARGET.CombatLog
					return true
				end
			end
		end)
	
		UI.ContextMenu.Register.OpeningListener(function(contextMenu, x, y)
			if openTarget == TARGET.CombatLog then
				contextMenu:AddEntry("LLCM_ClearCombatLog", ClearCombatLog, GameHelpers.GetStringKeyText("LeaderLib_UI_ContextMenu_ClearCombatLog", "<font color='#CC5500'>Clear Combat Log</font>"))
			end
			openTarget = ""
		end)
	end)
end