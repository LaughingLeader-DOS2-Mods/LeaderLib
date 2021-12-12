package controls
{
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public class TooltipHandler
	{
		public static function init(mc:MovieClip) : void
		{
			mc.base = mc.root as MovieClip;
			mc.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent) : void
			{
				TooltipHandler.showTooltip(mc, mc.base.hasTooltip == false);
				if (mc.mouseOver != null)
				{
					mc.mouseOver(e);
				}
			});
			mc.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent) : void
			{
				TooltipHandler.hideTooltip(mc);
				if (mc.mouseOut != null)
				{
					mc.mouseOut(e);
				}
			});

			mc.tooltip = "";
			mc.tooltipOverrideW = 0;
			mc.tooltipYOffset = 0;
			mc.tooltipSide = "bottom";
		}

		public static function showTooltip(mc:MovieClip, fade:Boolean=true) : void
		{
			if(mc.tooltip != null && mc.tooltip != "")
			{
				mc.base.curTooltip = mc.name;
				mc.tooltipOverrideW = mc.base.ElW;
				mc.tooltipYOffset = -4;
				tooltipHelper.ShowTooltipForMC(mc,mc.base,mc.tooltipSide,fade);
			}
		}

		public static function hideTooltip(mc:MovieClip) : void
		{
			if(mc.base.curTooltip == mc.name && mc.base.hasTooltip)
			{
				Registry.ExtCall("hideTooltip");
				mc.base.hasTooltip = false;
				mc.base.curTooltip = "";
			}
		}
	}
}