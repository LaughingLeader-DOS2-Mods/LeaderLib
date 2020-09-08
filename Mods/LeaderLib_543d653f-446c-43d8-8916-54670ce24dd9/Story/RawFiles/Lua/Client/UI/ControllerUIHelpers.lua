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

Ext.RegisterListener("SessionLoaded", function()
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