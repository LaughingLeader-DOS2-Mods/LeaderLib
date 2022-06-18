--local groups = {"EqHeader","Warnings","Skills","Critical","Special","AP","SP","SavingThrow","Properties","Runes","RuneEffect","ActiveRuneEffect","InActiveRuneEffect","Tags","EmptyRunes","Description","STRMove","STRCarry","MEMSlots","StatsPointUp","StatsBonus","StatsMalus","StatsBase","StatsPercentageBoost","StatsPercentageMalus","StatsPercentageTotal","StatsGearBoostNormal","StatsATKAPCost","StatsAPTitle","StatsAPBase","StatsAPBonus","StatsAPMalus","SkillCurrentLevel","StatusImmunity","StatusBonus","StatusMalus","Duration","Fire","Water","Earth","Air","Poison","Physical","Sulfur","Heal","ArmorSet"}

local ArmorSetGroupID = 45
local StatusMalusGroupID = 33

Ext.PrintError("ArmorSet", ArmorSetGroupID)
Ext.PrintError("StatusMalus", StatusMalusGroupID)

local function IsStatusMalupGroup(group)
	local len = #group.list.content_array - 1
	for i=0,len do
		local entry = group.list.content_array[i]
		if entry then
			--print(entry.label_txt.textColor, group.penaltyColour)
			if string.find(entry.label_txt.htmlText, "-", 1, true) or entry.label_txt.textColor == group.penaltyColour then
				return true,entry.height
			end
		end
	end
	return false
end

local nextTooltipIsStatus = false

Ext.RegisterUINameInvokeListener("addStatusTooltip", function (ui, ...)
	nextTooltipIsStatus = true
end)

local function FixMalusGroup(ui)
	local ui = ui Ext.GetUIByType(Data.UIType.tooltip)
	if ui then
		local this = ui:GetRoot()
		if this then
			if this.tf and this.tf.tooltip_mc and this.tf.tooltip_mc.list then
				local groups_array = this.tf.tooltip_mc.list.content_array
				local len = #groups_array-1
				local needsResort = false
				for i=0,len do
					local group = groups_array[i]
					if group then
						--ArmorSets icon
						if group.iconId == 18.0 then
							local b,height = IsStatusMalupGroup(group)
							if b then
								for j=0,#group.list.content_array-1 do
									--The actionscript code checks if this variable via if(!heightOverride), so setting it to false should work to disable it.
									group.list.content_array[j].heightOverride = false
								end
								group.heightOverride = height
								group.needsSubSection = false
								group.iconId = 0
								group.setupHeader()
								needsResort = true
								--fprint(LOGLEVEL.DEFAULT, "[TooltipGroup] iconId(%s) orderId(%s) needsSubSection(%s)", group.iconId, group.orderId, group.needsSubSection)
							end
						end
					end
				end
				if needsResort and this.tf.tooltip_mc.repositionElements then
					this.tf.tooltip_mc.repositionElements()
				end
			end
		end
	end
end

Ext.RegisterUINameInvokeListener("showFormattedTooltipAfterPos", function (ui, ...)
	if nextTooltipIsStatus then
		local settings = GameSettingsManager.GetSettings()
		--Remove ArmorSets icons from StatusMalus entries, and fix spacing
		if settings.Client.FixStatusTooltips then
			local b,err = xpcall(FixMalusGroup, debug.traceback, ui)
			if not b then
				Ext.PrintError(err)
			end
		end
		nextTooltipIsStatus = false
	end
end)