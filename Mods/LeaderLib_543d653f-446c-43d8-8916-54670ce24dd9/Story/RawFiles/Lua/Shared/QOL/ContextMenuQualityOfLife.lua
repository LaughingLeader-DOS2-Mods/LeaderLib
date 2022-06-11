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

	local NETID_TO_UUID = {
		Character = {},
		Item = {}
	}
	local CharacterServerData = {}

	local function SaveInfoToFile(netid, hoverType)
		---@type EclCharacter
		local obj = nil
		if hoverType then
			if hoverType == "Character" then
				obj = GameHelpers.GetCharacter(netid)
			elseif hoverType == "Item" then
				obj = GameHelpers.GetItem(netid)
			end
		else
			obj = GameHelpers.TryGetObject(netid)
		end
		if obj then
			if not hoverType then
				if GameHelpers.Ext.ObjectIsCharacter(obj) then
					hoverType = "Character"
				else
					hoverType = "Item"
				end
			end
			local uuid = obj.MyGuid or NETID_TO_UUID[hoverType][obj.NetID]
			if uuid then
				local data = {}
				local existing = Ext.LoadFile("LeaderLib_UUIDHelper.json")
				if existing then
					data = Common.JsonParse(existing, true)
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
				existingEntry.NetID = obj.NetID
				existingEntry.DisplayName = obj.DisplayName

				local serverData = CharacterServerData[uuid]

				if serverData then
					existingEntry.RootTemplate = serverData.Template
					if serverData.Temporary then
						existingEntry.Temporary = true
					end
					if serverData.Boss then
						existingEntry.Boss = true
					end
				end

				existingEntry.RootTemplateName = obj.RootTemplate.Name
				existingEntry.StatsId = GameHelpers.Ext.ObjectIsItem(obj) and obj.StatsId or obj.Stats.Name
				existingEntry.Tags = StringHelpers.Join(";", obj:GetTags())
				if GameHelpers.Ext.ObjectIsItem(obj) then
					existingEntry.WorldPos = obj.WorldPos
					if serverData then
						existingEntry.Rotation = serverData.Rotation
					end
				end
				Ext.SaveFile("LeaderLib_UUIDHelper.json", Common.JsonStringify(data))
			end
		end
	end

	local function TryProcessHoverObject(id, handle, hoverType, contextMenu, displayName)
		if handle then
			local target = nil
			if GameHelpers.Ext.ObjectIsCharacter(handle) or GameHelpers.Ext.ObjectIsItem(handle) then
				target = handle
			else
				if hoverType then
					if hoverType == "Character" then
						target = GameHelpers.GetCharacter(handle)
					elseif hoverType == "Item" then
						target = GameHelpers.GetItem(handle)
					end
				else
					target = GameHelpers.TryGetObject(handle)
				end
			end
			if target then
				if not hoverType then
					if GameHelpers.Ext.ObjectIsCharacter(target) then
						hoverType = "Character"
					else
						hoverType = "Item"
					end
				end
				if StringHelpers.IsNullOrEmpty(target.MyGuid) then
					Ext.PostMessageToServer("LeaderLib_ContextMenu_RequestUUID", Common.JsonStringify({NetID=target.NetID, Type=hoverType}))
				else
					NETID_TO_UUID[hoverType][target.NetID] = target.MyGuid
				end
				contextMenu:AddBuiltinEntry(id, function(contextMenu, ui, id, actionID, netid)
					SaveInfoToFile(netid, hoverType)
				end, displayName, true, true, false, true, target.NetID)
				return target.NetID
			end
		end
	end

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
		
			UI.ContextMenu.Register.BuiltinOpeningListener(function(contextMenu, ui, this, buttonsArr, buttons, targetObject)
				if Vars.DebugMode then
					local entries = {}
					if not Vars.IsEditorMode then
						local cursor = Ext.GetPickingState()
						if cursor then
							entries = {
								TryProcessHoverObject("LLCM_CopyInfo1", cursor.HoverItem, "Item", contextMenu, "Save Cursor Item to File"),
								TryProcessHoverObject("LLCM_CopyInfo2", cursor.HoverCharacter, "Character", contextMenu, "Save Cursor Character to File"),
								TryProcessHoverObject("LLCM_CopyInfo3", cursor.HoverCharacter2, "Character", contextMenu, "Save Cursor Character (2) to File"),
							}
							for i=1,#entries-1 do
								if entries[i] == nil then
									table.remove(entries, i)
								end
							end
							if cursor.HoverEntity and (cursor.HoverItem ~= cursor.HoverEntity and cursor.HoverCharacter ~= cursor.HoverEntity) then
								local result = TryProcessHoverObject("LLCM_CopyInfo4", cursor.HoverEntity, nil, contextMenu, "Save Cursor Entity to File")
								if result then
									table.insert(entries, result)
								end
							end
						end
					else
						---@type TooltipRequest
						local req = Game.Tooltip.GetCurrentOrLastRequest()
						if req and req.ItemNetID then
							local result = TryProcessHoverObject("LLCM_CopyInfoEditorItem", req.Item, "Item", contextMenu, "Save Cursor Item to File")
							if result then
								table.insert(entries, result)
							end
						end
					end
					if targetObject and GameHelpers.Ext.ObjectIsItem(targetObject) then
						local result = TryProcessHoverObject("LLCM_CopyEquipmentInfo", targetObject, "Item", contextMenu, "Save Cursor EQ to File")
						if result then
							table.insert(entries, result)
						end
					end
					if #entries > 1 then
						contextMenu:AddBuiltinEntry("LLCM_CopyInfoAll", function(contextMenu, ui, id, actionID, none)
							for i,v in pairs(entries) do
								if v ~= nil then
									SaveInfoToFile(v)
								end
							end
						end, "Save All Cursor Info to File", true, true, false, true)
					end
				end
			end)

			
			UI.ContextMenu.Register.BuiltinOpeningListener(function(contextMenu, ui, this, buttonsArr, buttons, targetObject)
				local targetHandle = nil
				if targetObject then
					targetHandle = Ext.HandleToDouble(targetObject.Handle)
				else
					local cursor = Ext.GetPickingState()
					if cursor and cursor.HoverCharacter then
						targetHandle = Ext.HandleToDouble(cursor.HoverCharacter)
					end
				end
				contextMenu:AddBuiltinEntry("LLCM_HighGroundTest", function(contextMenu, ui, id, actionID, handle)
					local target = GameHelpers.TryGetObject(Ext.DoubleToHandle(handle))
					if target then
						local source = Client:GetCharacter().WorldPos
						fprint(LOGLEVEL.DEFAULT, "[HighGroundFlag] Result(%s) me.Y(%s) target.Y(%s) heightDiff(%s) HighGroundThreshold(%s)", GameHelpers.Math.GetHighGroundFlag(source, target.WorldPos), source[2], target.WorldPos[2], source[2] - target.WorldPos[2], Ext.ExtraData.HighGroundThreshold)
					end
				end, "Print HighGroundFlag", true, true, false, true, targetHandle)
			end)

			registeredListeners = true
		end
	end)

	Ext.RegisterNetListener("LeaderLib_ContextMenu_SetUUID", function(cmd, payload)
		local data = Common.JsonParse(payload)
		if data then
			NETID_TO_UUID[data.Type][data.NetID] = data.UUID
			CharacterServerData[data.UUID] = {
				Rotation = data.Rotation,
				Template = data.Template,
				Temporary = data.Temporary,
				Boss = data.Boss,
			}
		end
	end)
else
	Ext.RegisterNetListener("LeaderLib_ContextMenu_RequestUUID", function(cmd, payload, userid)
		local data = Common.JsonParse(payload)
		if data then
			local object = GameHelpers.TryGetObject(data.NetID)
			if object then
				local data = {
					NetID = object.NetID,
					UUID = object.MyGuid,
					Type = data.Type,
					Rotation={GetRotation(object.MyGuid)},
					Template = StringHelpers.GetUUID(GetTemplate(object.MyGuid))
				}
				if ObjectIsCharacter(object.MyGuid) == 1 then
					data.Boss = IsBoss(object.MyGuid) == 1 and true or false
					data.Temporary = object.Temporary
				end
				GameHelpers.Net.PostToUser(userid, "LeaderLib_ContextMenu_SetUUID", data)
			end
		end
	end)
end