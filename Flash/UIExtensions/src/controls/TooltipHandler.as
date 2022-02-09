package controls
{
	import LS_Classes.tooltipHelper;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	public class TooltipHandler
	{
		public static function init(mc:MovieClip, mouseTarget:MovieClip = null) : void
		{
			//mc.base = mc.root as MovieClip;
			if(mouseTarget == null)
			{
				mouseTarget = mc;
			}
			mouseTarget.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent) : void
			{
				if (TooltipHandler.showTooltip(mc) && mc.mouseOver != null)
				{
					mc.mouseOver(e);
				}
			});
			mouseTarget.addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent) : void
			{
				if (TooltipHandler.hideTooltip(mc) && mc.mouseOut != null)
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

		public static function showTooltip(mc:MovieClip, fade:Boolean=true) : Boolean
		{
			if(mc.tooltip != null && mc.tooltip != "" && MainTimeline.Instance.curTooltip != mc.tooltip)
			{
				fade = MainTimeline.Instance.hasTooltip == true;
				mc.tooltipOverrideW = MainTimeline.Instance.tooltipWidthOverride;
				mc.tooltipYOffset = -4;
				tooltipHelper.ShowTooltipForMC(mc,MainTimeline.Instance,mc.tooltipSide,fade);
				MainTimeline.Instance.setHasTooltip(true, mc.tooltip);
				return true;
			}
			return false;
		}

		public static function hideTooltip(mc:MovieClip) : Boolean
		{
			if(MainTimeline.Instance.curTooltip == mc.tooltip && MainTimeline.Instance.hasTooltip)
			{
				Registry.ExtCall("hideTooltip");
				MainTimeline.Instance.setHasTooltip(false);
				return true;
			}
			return false;
		}
	}
}