--[[
examine_c
"Public/Game/GUI/examine_c.swf"

Show tooltip event:
"showFormattedTooltip"
tooltipArray

ExternalInterface.call events:

switch(this.type)
{
	case 0:
		ExternalInterface.call("selectNone",id);
		break;
	case 1:
		ExternalInterface.call("selectStat",id);
		break;
	case 2:
		ExternalInterface.call("selectAbility",id);
		break;
	case 3:
		ExternalInterface.call("selectTalent",id);
		if(id == 0)
		{
			(root as MovieClip).clearTooltip();
		}
		break;
	case 4:
		ExternalInterface.call("selectNone",id);
		break;
	case 5:
		ExternalInterface.call("selectTitle",id);
		break;
	case 6:
		ExternalInterface.call("selectNone",8,this.label_txt.htmlText);
		break;
	case 7:
		ExternalInterface.call("selectStatus",this.id);
		break;
	case 8:
		ExternalInterface.call("selectNone",-1);
		val2 = root as MovieClip;
		if(val2 && val2.examine_mc.tooltip_mc.visible)
		{
			val2.clearTooltip();
		}
}

bottomBar_c
"Public/Game/GUI/bottomBar_c.swf"

Show tooltip event:
"updateTooltip"
tooltip_array

ExternalInterface.call events:
public function setSlotTooltip(slot:MovieClip) : *
{
	if(slot.handle != this.tooltipSlot || slot.tooltip != this.tooltipStr || this.tooltipSlotType != slot.type)
	{
		this.tooltipSlotType = slot.type;
		this.tooltipSlot = slot.handle;
		this.tooltipStr = slot.tooltip;
	}
	ExternalInterface.call("SlotHover",slot.id);
}
]]

local function OnControllerEvent(ui, event, ...)
	print(event, Common.Dump({...}))
	if event == "updateStatusses" then
		UI.PrintArray(ui, "status_array")
	elseif event == "update" then
		UI.PrintArray(ui, "addStats_array")
	elseif event == "showFormattedTooltip" then
		UI.PrintArray(ui, "tooltipArray")
	end
end


local UITYPE = {
	CHARACTER_CREATION = 4,
	BOTTOMBAR = 59,
	TRADE = 73,
	EXAMINE = 67,
	PARTY_INVENTORY = 142,
	REWARD = 137,
	STATS_PANEL = 63, -- a.k.a. the character sheet
	EQUIPMENT_PANEL = 64, -- a.k.a. the character sheet equipment panel,
	CRAFT_PANEL = 84
}

---@class TooltipArrayData
---@field Main string
---@field CompareMain string|nil
---@field CompareOff string|nil

---@class TooltipHelperData
---@field Array table<string, TooltipArrayData>
---@field MC table<string, fun(any):any>

---@type table<integer, TooltipHelperData>
local TooltipVariables = {
	[UITYPE.CHARACTER_CREATION] = {
		Array = {Main = "tooltipArray"},
		MC = {Main = function(main) return main.tooltipMC end},
		UpdateEvent = "showTooltip"
	},
	[UITYPE.PARTY_INVENTORY] = {
		Array = {
			Main = "tooltip_array",
			CompareMain = "compareTooltip_array",
			CompareOff = "offhandTooltip_array"
		},
		MC = {
			Main = function(main) return main.inventoryPanel_mc.tooltip_mc.tooltip_mc.tooltip_mc end,
			Compare = function(main) return main.inventoryPanel_mc.tooltip_mc.tooltip_mc.compare_mc end,
		},
		UpdateEvent = "updateTooltip"
	},
	[UITYPE.BOTTOMBAR] = {
		Array = {Main = "tooltip_array"},
		MC = {Main = function(main) return main.bottombar_mc.tooltipHolder_mc.tooltip_mc end},
		UpdateEvent = "updateTooltip"
	},
	[UITYPE.EXAMINE] = {
		Array = {Main = "tooltipArray"},
		MC = {Main = function(main) return main.examine_mc.tooltip_mc end},
		UpdatEvent = "showFormattedTooltip"
	},
	[UITYPE.TRADE] = {
		Array = {
			Main = "tooltip_array",
			CompareMain = "tooltipCompare_array",
			CompareOff = "equipOffhandTooltip_array"
		},
		MC = {
			Main = function(main) return main.trade_mc.TTHolder_mc.tooltip_mc end,
			Compare = function(main) return main.trade_mc.TTHolder_mc.compare_mc end,
		},
		UpdateEvent = "updateTooltip" -- "showTooltip"
	},
	[UITYPE.REWARD] = {
		Array = {Main = "tooltip_array"},
		MC = {Main = function(main) return main.reward_mc.tooltip_mc end},
		UpdateEvent = "updateTooltip"
	},
	[UITYPE.STATS_PANEL] = {
		Array = {Main = "tooltipArray"},
		MC = {Main = function(main) return main.mainpanel_mc.stats_mc.tooltip_mc end},
		UpdateEvent = "showTooltip"
	},
	[UITYPE.EQUIPMENT_PANEL] = {
		Array = {
			Main = "tooltip_array",
			Compare = "equipTooltip_array",
		},
		MC = {
			Main = function(main) return main.mainpanel_mc.TTHolder_mc.tooltip_mc end,
			Compare = function(main) return main.mainpanel_mc.TTHolder_mc.compare_mc end,
		},
		--UpdateEvent = "enableCompare"
		UpdateEvent = {"updateEquipTooltip", "updateTooltip"}
	},
	[UITYPE.CRAFT_PANEL] = {
		Array = {Main = "tooltip_array"},
		MC = {Main = function(main) return main.craftPanel_mc.tooltip_mc.tooltip_mc end},
		UpdateEvent = "updateTooltip"
	},
}

local function FormatTagTooltip(ui, tooltip_mc, ...)
	local length = #tooltip_mc.list.content_array
	print(tooltip_mc.name, "tooltip length:", length, tooltip_mc.name)
	if length > 0 then
		for i=0,length,1 do
			local group = tooltip_mc.list.content_array[i]
			if group ~= nil then
				print(string.format("[%i] groupID(%i) orderId(%s) icon(%s)", i, group.groupID or -1, group.orderId or -1, group.iconId))
				if group.list ~= nil then
					UI.FormatArrayTagText(group.list.content_array, group, true)
				end
			end
		end
	end
end

---@param ui UIObject
local function OnConsoleTooltipPositioned(ui, data, ...)
	if UI.Tooltip.HasTagTooltipData or #UIListeners.OnTooltipPositioned > 0 then
		local root = ui:GetRoot()
		if root ~= nil then
			if data ~= nil then
				local tooltips = {}
				if data.MC ~= nil then
					if data.MC.Main ~= nil then
						local tooltip_mc = data.MC.Main(root)
						if tooltip_mc ~= nil then
							tooltips[#tooltips+1] = tooltip_mc
						end
					end
					if data.MC.Compare ~= nil then
						local compare_mc = data.MC.Compare(root)
						if compare_mc ~= nil then
							tooltips[#tooltips+1] = compare_mc
						end
					end
				end
				if #tooltips > 0 then
					for i,mc in pairs(tooltips) do
						if Features.FormatTagElementTooltips then
							FormatTagTooltip(ui, mc)
						end
						for i,callback in pairs(UIListeners.OnTooltipPositioned) do
							local status,err = xpcall(callback, debug.traceback, ui, mc, true, ...)
							if not status then
								Ext.PrintError("[LeaderLib:AdjustTagElements] Error invoking callback:")
								Ext.PrintError(err)
							end
						end
					end
				end
			end
		end
	end
end

local updatingTooltip = false

Ext.RegisterNetListener("LeaderLib_UI_OnControllerTooltipPositioned", function(cmd, payload)
	if payload ~= nil and payload ~= "" then
		local uiType = tonumber(payload)
		local ui = Ext.GetUIByType(uiType)
		if ui ~= nil then
			local uiData = TooltipVariables[uiType]
			OnConsoleTooltipPositioned(ui, uiData)
		end
	end
	updatingTooltip = false
end)

local function OnTooltipUpdating(ui, uiType, ...)
	if not updatingTooltip then
		local data = Classes.MessageData:CreateFromTable("TooltipPositioningEventData", {
			UIType = uiType,
			Client = Client.Character.UUID
		})
		Ext.PostMessageToServer("LeaderLib_UI_StartControllerTooltipTimer", data:ToString())
		updatingTooltip = true
	end
end

local function RegisterControllerTooltipEvents()
	for typeId,data in pairs(TooltipVariables) do
		if data.UpdateEvent ~= nil then
			if type(data.UpdateEvent) == "table" then
				for i,v in pairs(data.UpdateEvent) do
					Ext.RegisterUITypeInvokeListener(typeId, v, function(ui, ...)
						--onconsoletooltippositioned(ui, data, ...)
						OnTooltipUpdating(ui, typeId, ...)
					end, "After")
				end
			else
				Ext.RegisterUITypeInvokeListener(typeId, data.UpdateEvent, function(ui, ...)
					--print(Common.Dump{...})
					--OnConsoleTooltipPositioned(ui, data, ...)
					OnTooltipUpdating(ui, typeId, ...)
				end, "After")
			end
		end
	end
	print("**************Registered controller UI events.************")

	local debugEvents = {
		"setTooltip",
		"setEquippedTitle",
		"toggleTooltip",
		"enableCompare",
		"ShowCellTooltip",
		"SendTooltipRequest",
		"setTooltipGroupLabel",
		"setTooltipCompareHint",
		"setTooltipPanelVisible",
		"updateTooltip",
		"updateEquipTooltip",
		"clearTooltip",
		"clearEquipTooltip",
		"tooltipFadeDone",
	}

	for i,v in pairs(debugEvents) do
		Ext.RegisterUINameInvokeListener(v, function(ui, method, ...)
			local matched = false
			local id = ui:GetTypeId()
			for name,type in pairs(UITYPE) do
				if type == id then
					print(string.format("[%s(%s)]:%s params(%s)", name, id, method, Ext.JsonStringify({...})))
					matched = true
					break
				end
			end
			if not matched then
				print(string.format("[%s(%s)]:%s params(%s)", ui:GetRoot().name, id, method, Ext.JsonStringify({...})))
			end
			if method == "updateEquipTooltip" then
				UI.PrintArray(ui, "equipTooltip_array")
			end
		end, "After")
	end

	-- local debugCalls = {
	-- 	"slotOver",
	-- 	"itemDollOver",
	-- }

	-- for i,v in pairs(debugCalls) do
	-- 	Ext.RegisterUINameCall(v, function(ui, method, ...)
	-- 		local matched = false
	-- 		local id = ui:GetTypeId()
	-- 		for name,type in pairs(UITYPE) do
	-- 			if type == id then
	-- 				print(string.format("[%s(%s)]:%s params(%s)", name, id, method, Ext.JsonStringify({...})))
	-- 				matched = true
	-- 				break
	-- 			end
	-- 		end
	-- 		if not matched then
	-- 			print(string.format("[%s(%s)]:%s params(%s)", ui:GetRoot().name, id, method, Ext.JsonStringify({...})))
	-- 		end
	-- 	end)
	-- end
end

Ext.RegisterListener("SessionLoaded", function()
	local bottomBar = Ext.GetBuiltinUI("Public/Game/GUI/bottomBar_c.swf")
	if bottomBar ~= nil then
		-- controller mode
		RegisterControllerTooltipEvents()
		local ui = Ext.GetBuiltinUI("Public/Game/GUI/partyInventory_c.swf")
		print("Public/Game/GUI/partyInventory_c.swf", ui:GetTypeId())
	end
	-- local ui = Ext.GetBuiltinUI("Public/Game/GUI/examine_c.swf")
	-- if ui ~= nil then
	-- 	--Ext.RegisterUIInvokeListener(ui, "update", OnControllerEvent)
	-- 	--Ext.RegisterUIInvokeListener(ui, "updateStatusses", OnControllerEvent)
	-- 	Ext.RegisterUIInvokeListener(ui, "showFormattedTooltip", OnControllerEvent)
	-- 	Ext.RegisterUICall(ui, "selectStatus", OnControllerEvent)
	-- end
	-- Ext.RegisterUINameCall("buttonPressed", function(ui, method, ...)
	-- 	print(method, Common.Dump({...}))
	-- end)
end)