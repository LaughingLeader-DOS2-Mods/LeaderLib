package LS_Classes
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   
   public class tooltipHelper extends MovieClip
   {
      public function tooltipHelper()
      {
         super();
      }
      
      public static function ShowItemTooltipForMC(target:MovieClip, parentRoot:DisplayObject, tooltipSide:String = "right") : void
      {
         var tooltipWidth:Number = target.width;
         var tooltipHeight:Number = target.height;
         var offsetX:Number = 0;
         var offsetY:Number = 0;
         var contextParam:Number = -1;
         if(target.tooltipOverrideW)
         {
            tooltipWidth = target.tooltipOverrideW;
         }
         if(target.tooltipOverrideH)
         {
            tooltipHeight = target.tooltipOverrideH;
         }
         if(target.tooltipXOffset)
         {
            offsetX = target.tooltipXOffset;
         }
         if(target.tooltipYOffset)
         {
            offsetY = target.tooltipYOffset;
         }
         if(target.contextParam)
         {
            contextParam = target.contextParam;
         }
         var pos:Point = getGlobalPositionOfMC(target,parentRoot);
         ExternalInterface.call("showItemTooltip",target.itemHandle,pos.x + offsetX,pos.y + offsetY,tooltipWidth,tooltipHeight,contextParam,tooltipSide);
         var base:MovieClip = parentRoot as MovieClip;
         base.hasTooltip = true;
      }
      
      public static function ShowTooltipForMC(target:MovieClip, parentRoot:DisplayObject, tooltipSide:String = "right", fadeTooltip:Boolean = true) : void
      {
         var offsetX:Number = NaN;
         var offsetY:Number = NaN;
         var tooltipWidth:Number = NaN;
         var tooltipHeight:Number = NaN;
         var pos:Point = null;
         var base:MovieClip = null;
         if(target.tooltip && target.tooltip != "")
         {
            offsetX = 0;
            offsetY = 0;
            tooltipWidth = target.width;
            tooltipHeight = target.height;
            if(target.tooltipOverrideW)
            {
               tooltipWidth = target.tooltipOverrideW;
            }
            if(target.tooltipOverrideH)
            {
               tooltipHeight = target.tooltipOverrideH;
            }
            if(target.tooltipXOffset)
            {
               offsetX = target.tooltipXOffset;
            }
            if(target.tooltipYOffset)
            {
               offsetY = target.tooltipYOffset;
            }
            pos = getGlobalPositionOfMC(target,parentRoot);
            ExternalInterface.call("showTooltip",target.tooltip,pos.x + offsetX,pos.y + offsetY,tooltipWidth,tooltipHeight,tooltipSide,fadeTooltip);
            base = parentRoot as MovieClip;
            base.hasTooltip = true;
         }
      }
      
      public static function ShowStatusTooltipForMC(target:MovieClip, parentRoot:DisplayObject, tooltipSide:String = "right") : void
      {
         var offsetX:Number = NaN;
         var offsetY:Number = NaN;
         var tooltipWidth:Number = NaN;
         var tooltipHeight:Number = NaN;
         var pos:Point = null;
         var base:MovieClip = null;
         if(target.owner && target.id)
         {
            offsetX = 0;
            offsetY = 0;
            tooltipWidth = target.width;
            tooltipHeight = target.height;
            if(target.tooltipOverrideW)
            {
               tooltipWidth = target.tooltipOverrideW;
            }
            if(target.tooltipOverrideH)
            {
               tooltipHeight = target.tooltipOverrideH;
            }
            if(target.tooltipXOffset)
            {
               offsetX = target.tooltipXOffset;
            }
            if(target.tooltipYOffset)
            {
               offsetY = target.tooltipYOffset;
            }
            pos = getGlobalPositionOfMC(target,parentRoot);
            ExternalInterface.call("showStatusTooltip",target.owner,target.id,pos.x + offsetX,pos.y + offsetY,tooltipWidth,tooltipHeight,tooltipSide);
            base = parentRoot as MovieClip;
            base.hasTooltip = true;
         }
      }
      
      public static function getGlobalPositionOfMC(target:MovieClip, parentRoot:DisplayObject) : Point
      {
         var pos:Point = target.localToGlobal(new Point(0,0));
         pos.x = pos.x - parentRoot.x;
         pos.y = pos.y - parentRoot.y;
         return pos;
      }
   }
}
