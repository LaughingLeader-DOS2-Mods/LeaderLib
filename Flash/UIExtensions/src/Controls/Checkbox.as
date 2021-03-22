package Controls
{
   import LS_Classes.tooltipHelper;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   
   public dynamic class Checkbox extends MovieClip
   {
      public var bg_mc:MovieClip;
      
      public var label_txt:TextField;
      public var label_bg_mc:MovieClip;
      
      public var base:MovieClip;
      
      public var mHeight:Number;
      
      public function Checkbox()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function onDown(param1:MouseEvent) : *
      {
         this.bg_mc.gotoAndStop(this.stateID * 3 + 3);
         bg_mc.addEventListener(MouseEvent.MOUSE_UP,this.onClick);
      }

      public function toggle() : * 
      {
         this.stateID++;
         if(this.filterBool)
         {
            if(this.stateID > 2)
            {
               this.stateID = 0;
            }
         }
         else if(this.stateID > 1)
         {
            this.stateID = 0;
         }
         this.bg_mc.gotoAndStop(this.stateID * 3 + 1);
         ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
         ExternalInterface.call("LeaderLib_OnControl", "checkbox", this.id, this.stateID);
      }
      
      public function onClick(param1:MouseEvent) : *
      {
         if(this.enable)
         {
            toggle();
         }
         removeEventListener(MouseEvent.MOUSE_UP,this.onClick);
      }
      
      public function deselectElement(param1:MouseEvent) : *
      {
         bg_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onClick);
         this.bg_mc.gotoAndStop(this.stateID * 3 + 1);
      }
      
      public function selectElement(param1:MouseEvent) : *
      {
         this.bg_mc.gotoAndStop(this.stateID * 3 + 2);
      }
      
      public function onMouseOver(param1:MouseEvent) : *
      {
         if(this.enable)
         {
            if(this.tooltip != null && this.tooltip != "")
            {
               this.base.curTooltip = this.pos;
               this.tooltipOverrideW = this.base.ElW;
               this.tooltipYOffset = -4;
               tooltipHelper.ShowTooltipForMC(this,root,"bottom");
            }
         }
      }
      
      public function onMouseOut(param1:MouseEvent) : *
      {
         if(this.base.curTooltip == this.pos && this.base.hasTooltip)
         {
            ExternalInterface.call("hideTooltip");
            this.base.hasTooltip = false;
         }
         this.base.curTooltip = -1;
         bg_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onClick);
      }
      
      public function setState(param1:Number) : *
      {
         this.stateID = param1;
         this.bg_mc.gotoAndStop(this.stateID * 3 + 1);
      }
      
      function frame1() : *
      {
         this.base = root as MovieClip;
         this.mHeight = 30;
         this.bg_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         this.bg_mc.addEventListener(MouseEvent.MOUSE_OVER,this.selectElement);
         this.bg_mc.addEventListener(MouseEvent.MOUSE_OUT,this.deselectElement);
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);

         this.label_txt.defaultTextFormat.size = 16;
         this.label_txt.defaultTextFormat.color = 0xFFFFFF;
         this.label_txt.defaultTextFormat.font = "Ubuntu Mono Bold";
         this.label_txt.autoSize = TextFieldAutoSize.LEFT;
      }
   }
}