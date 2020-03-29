package optionsSettings_fla
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   
   public dynamic class AcceptButton_5 extends MovieClip
   {
       
      
      public var bg_mc:MovieClip;
      
      public var disable_mc:MovieClip;
      
      public var text_txt:TextField;
      
      public var base:MovieClip;
      
      public var textY:Number;
      
      public var pressedFunc:Function;
      
      public var snd_Click:String;
      
      public function AcceptButton_5()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function onOut(param1:MouseEvent) : *
      {
         if(!this.disable_mc.visible)
         {
            this.bg_mc.gotoAndStop(1);
            this.text_txt.y = this.textY;
         }
         removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
      }
      
      public function onOver(param1:MouseEvent) : *
      {
         if(!this.disable_mc.visible)
         {
            this.bg_mc.gotoAndStop(2);
            ExternalInterface.call("PlaySound","UI_Generic_Over");
         }
      }
      
      public function onUp(param1:MouseEvent) : *
      {
         if(!this.disable_mc.visible)
         {
            ExternalInterface.call("PlaySound",this.snd_Click);
            this.bg_mc.gotoAndStop(2);
            this.text_txt.y = this.textY;
            if(this.pressedFunc != null)
            {
               this.pressedFunc();
            }
         }
         removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
      }
      
      public function onDown(param1:MouseEvent) : *
      {
         if(!this.disable_mc.visible)
         {
            addEventListener(MouseEvent.MOUSE_UP,this.onUp);
            this.bg_mc.gotoAndStop(3);
            this.text_txt.y = this.textY + 3;
         }
      }
      
      function frame1() : *
      {
         this.base = root as MovieClip;
         addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         this.textY = 12;
         this.disable_mc.visible = false;
         this.text_txt.defaultTextFormat.size = 22;
         this.text_txt.defaultTextFormat.color = 0xFFFFFF;
         this.text_txt.defaultTextFormat.font = "Ubuntu Mono";
      }
   }
}
