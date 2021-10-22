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

	local registeredListeners = false

	local NETID_TO_UUID = {}

	Ext.RegisterListener("SessionLoaded", function()
		if not registeredListeners then
			UI.ContextMenu.Register.ShouldOpenListener(function(contextMenu, x, y)
				openTarget = ""
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
		
			UI.ContextMenu.Register.BuiltinOpeningListener(function(contextMenu, ui, this, buttonArr, buttons)
				if Vars.DebugMode then
					local cursor = Ext.GetPickingState()
					if cursor then
						local target = GameHelpers.TryGetObject(cursor.HoverCharacter or cursor.HoverItem)
						if target then
							if StringHelpers.IsNullOrEmpty(target.MyGuid) then
								Ext.PostMessageToServer("LeaderLib_ContextMenu_RequestUUID", target.NetID)
							else
								NETID_TO_UUID[target.NetID] = target.MyGuid
							end
							contextMenu:AddBuiltinEntry("LLCM_CopyUUID", function(contextMenu, ui, id, actionID, handle)
								local uuid = NETID_TO_UUID[handle]
								if uuid then
									local obj = GameHelpers.TryGetObject(handle)
									if obj then
										local data = {}
										local existing = Ext.LoadFile("LeaderLib_UUIDHelper.json")
										if existing then
											data = Common.JsonParse(existing)
											Ext.Print("Updated Osiris Data/LeaderLib_UUIDHelper.json")
										else
											Ext.Print("Created Osiris Data/LeaderLib_UUIDHelper.json")
										end
										--local name_uuid = string.format("%s_%s", obj.RootTemplate.Name, uuid)
										local existingEntry = nil
										for i,v in pairs(data) do
											if v.UUID == uuid then
												existingEntry = v
												break
											end
										end
										if not existingEntry then
											existingEntry = {}
											data[#data+1] = existingEntry
										end
										existingEntry.UUID = uuid
										existingEntry.DisplayName = obj.DisplayName
										existingEntry.RootTemplate = obj.RootTemplate.Id
										existingEntry.StatsId = GameHelpers.Ext.ObjectIsItem(obj) and obj.StatsId or obj.Stats.Name
										existingEntry.Tags = StringHelpers.Join(";", obj:GetTags())
										Ext.SaveFile("LeaderLib_UUIDHelper.json", Ext.JsonStringify(data))
									end
								end
							end, "Save Info to File", true, true, false, true, target.NetID)
						end
					end
				end
			end)

			registeredListeners = true
		end
	end)

	Ext.RegisterNetListener("LeaderLib_ContextMenu_SetUUID", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			NETID_TO_UUID[data.NetID] = data.UUID
		end
	end)
else
	Ext.RegisterNetListener("LeaderLib_ContextMenu_RequestUUID", function(cmd, payload, userid)
		local netid = tonumber(payload)
		local object = GameHelpers.TryGetObject(netid)
		if object then
			Ext.PostMessageToUser(userid, "LeaderLib_ContextMenu_SetUUID", Ext.JsonStringify({NetID = netid, UUID = object.MyGuid}))
		end
	end)
end