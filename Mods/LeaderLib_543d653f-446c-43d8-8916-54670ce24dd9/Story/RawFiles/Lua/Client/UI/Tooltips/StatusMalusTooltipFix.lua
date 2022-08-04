--local groups = {"EqHeader","Warnings","Skills","Critical","Special","AP","SP","SavingThrow","Properties","Runes","RuneEffect","ActiveRuneEffect","InActiveRuneEffect","Tags","EmptyRunes","Description","STRMove","STRCarry","MEMSlots","StatsPointUp","StatsBonus","StatsMalus","StatsBase","StatsPercentageBoost","StatsPercentageMalus","StatsPercentageTotal","StatsGearBoostNormal","StatsATKAPCost","StatsAPTitle","StatsAPBase","StatsAPBonus","StatsAPMalus","SkillCurrentLevel","StatusImmunity","StatusBonus","StatusMalus","Duration","Fire","Water","Earth","Air","Poison","Physical","Sulfur","Heal","ArmorSet"}

local ArmorSetGroupID = 45
local StatusMalusGroupID = 33

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

				--FIX duplicate last element
				--Not sure why this is happening, since there's no duplicate in the tooltip_array. This seems to get added by the UI, when a status is ticking, and the extender adds a new tooltip element.
				local lastGroupID = -1
				local lastGroupElementCount = -1
				local lastGroup = nil

				for i=0,len do
					local group = groups_array[i]
					if group then
						--[[ print(group.groupID, lastGroupID)
						if group.groupID == lastGroupID then
							local compareTo = nil
							local glen = math.max(#group.list.content_array, lastGroupElementCount)
							for j=0,glen-1 do
								local obj1 = group.list.content_array[j]
								local obj2 = lastGroup.list.content_array[j]
								if obj1 and obj1.label_txt then
									compareTo = obj1
									print("1", obj1.label_txt and obj1.label_txt.htmlText or obj1.name)
								else
									obj1 = compareTo
								end
								if obj2 then
									print("2", obj2.label_txt and obj2.label_txt.htmlText or obj2.name)
								end
								if obj1 and obj2 and obj1.label_txt and obj2.label_txt then
									if obj1.label_txt.htmlText == obj2.label_txt.htmlText
									and obj1.value_txt.htmlText == obj2.value_txt.htmlText
									then
										Ext.PrintError("DUPLICATE?")
										group.visible = false
										group.heightOverride = 0
										for l=0,#group.list.content_array-1 do
											group.list.content_array[l].heightOverride = false
										end
										needsResort = true
										break
									end
								end
							end
						end ]]
						-- print(i, group.iconId, group.groupID)
						-- for j=0,#group.list.content_array-1 do
						-- 	local obj = group.list.content_array[j]
						-- 	if obj then
						-- 		print("*", j, obj.label_txt and obj.label_txt.htmlText or obj.name)
						-- 	end
						-- end
						--ArmorSets icon
						if group.iconId == 18.0 then
							local b,height = IsStatusMalupGroup(group)
							if b then
								if group.list then
									for j=0,#group.list.content_array-1 do
										--The actionscript code checks if this variable via if(!heightOverride), so setting it to false should work to disable it.
										group.list.content_array[j].heightOverride = false
									end
								end
								group.heightOverride = height
								group.needsSubSection = false
								group.iconId = 0
								group.setupHeader()
								needsResort = true
								--fprint(LOGLEVEL.DEFAULT, "[TooltipGroup] iconId(%s) orderId(%s) needsSubSection(%s)", group.iconId, group.orderId, group.needsSubSection)
							end
						end
						--[[ lastGroupID = group.groupID
						lastGroupElementCount = #group.list.content_array
						lastGroup = group ]]
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