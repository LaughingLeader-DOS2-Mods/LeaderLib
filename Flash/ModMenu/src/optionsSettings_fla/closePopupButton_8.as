package optionsSettings_fla
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   
   public dynamic class closePopupButton_8 extends MovieClip
   {
       
      
      public var bg_mc:MovieClip;
      
      public var hit_mc:MovieClip;
      
      public var base:MovieClip;
      
      public function closePopupButton_8()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function onOut(param1:MouseEvent) : *
      {
         this.bg_mc.gotoAndStop(1);
         removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
      }
      
      public function onOver(param1:MouseEvent) : *
      {
         this.bg_mc.gotoAndStop(2);
         ExternalInterface.call("PlaySound","UI_Generic_Over");
      }
      
      public function onUp(param1:MouseEvent) : *
      {
         ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
         this.bg_mc.gotoAndStop(2);
         (root as MovieClip).cancelChanges();
         removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
      }
      
      public function onDown(param1:MouseEvent) : *
      {
         this.bg_mc.gotoAndStop(3);
         addEventListener(MouseEvent.MOUSE_UP,this.onUp);
      }
      
      function frame1() : *
      {
         this.hit_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         this.hit_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         this.hit_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         this.base = parent as MovieClip;
      }
   }
}
