package
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   
   public dynamic class SelectElement extends MovieClip
   {
       
      
      public var label_txt:TextField;
      
      public var base:MovieClip;
      
      public function SelectElement()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function selectElement(param1:*) : *
      {
         ExternalInterface.call("PlaySound","UI_Gen_OptMenu_Over");
      }
      
      public function deselectElement(param1:*) : *
      {
      }
      
      public function onMouseOver(param1:MouseEvent) : *
      {
         this.base.mainMenu_mc.setCursorPosition(this.id);
         if(this.tooltip != null && this.tooltip != "")
         {
            this.base.curTooltip = this.pos;
            ExternalInterface.call("showItemTooltip",this.tooltip);
            this.base.hasTooltip = true;
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
      }
      
      function frame1() : *
      {
         this.base = root as MovieClip;
         addEventListener(MouseEvent.MOUSE_OVER,this.onMouseOver);
         addEventListener(MouseEvent.MOUSE_OUT,this.onMouseOut);
         this.label_txt.defaultTextFormat.size = 16;
         this.label_txt.defaultTextFormat.color = 0xFFFFFF;
         this.label_txt.defaultTextFormat.font = "Ubuntu Mono";
      }
   }
}
