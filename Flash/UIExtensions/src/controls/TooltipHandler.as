package controls
{
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public class TooltipHandler
	{
		public static function init(mc:MovieClip, mouseTarget:MovieClip = null) : void
		{
			mc.base = mc.root as MovieClip;
			if(mouseTarget == null)
			{
				mouseTarget = mc;
			}
			mouseTarget.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent) : void
			{
				TooltipHandler.showTooltip(mc);
				if (mc.mouseOver != null)
				{
					mc.mouseOver(e);
				}
			});
			mouseTarget.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent) : void
			{
				TooltipHandler.hideTooltip(mc);
				if (mc.mouseOut != null)
				{
					mc.mouseOut(e);
				}
			});

			mc.tooltipOverrideW = 0;
			mc.tooltipYOffset = 0;
			if(mc.tooltipSide == null)
			{
				mc.tooltipSide = "topRight";
			}
		}

		public static function showTooltip(mc:MovieClip, fade:Boolean=true) : void
		{
			var base:MovieClip = mc.base || mc.root as MovieClip;
			if(base != null && mc.tooltip != null && mc.tooltip != "")
			{
				fade = base.hasTooltip == true;
				base.curTooltip = mc.tooltip;
				mc.tooltipOverrideW = mc.base.ElW;
				mc.tooltipYOffset = -4;
				tooltipHelper.ShowTooltipForMC(mc,base,mc.tooltipSide,fade);
			}
		}

		public static function hideTooltip(mc:MovieClip) : void
		{
			var base:MovieClip = mc.base || mc.root as MovieClip;
			if(base != null && base.curTooltip == mc.tooltip && base.hasTooltip)
			{
				Registry.ExtCall("hideTooltip");
				base.hasTooltip = false;
				base.curTooltip = "";
			}
		}
	}
}