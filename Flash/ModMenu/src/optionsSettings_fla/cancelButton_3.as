package optionsSettings_fla
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   
   public dynamic class cancelButton_3 extends MovieClip
   {
       
      
      public var bg_mc:MovieClip;
      
      public var text_txt:TextField;
      
      public var onDownBool:Boolean;
      
      public var pressedFunc:Function;
      
      public var textY:Number;
      
      public var snd_Click:String;
      
      public function cancelButton_3()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function onOut(param1:MouseEvent) : *
      {
         this.bg_mc.gotoAndStop(1);
         this.text_txt.y = this.textY;
         removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
      }
      
      public function onOver(param1:MouseEvent) : *
      {
         this.bg_mc.gotoAndStop(2);
         ExternalInterface.call("PlaySound","UI_Generic_Over");
      }
      
      public function onUp(param1:MouseEvent) : *
      {
         ExternalInterface.call("PlaySound",this.snd_Click);
         this.bg_mc.gotoAndStop(2);
         this.text_txt.y = this.textY;
         removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         if(this.pressedFunc != null)
         {
            this.pressedFunc();
         }
      }
      
      public function onDown(param1:MouseEvent) : *
      {
         addEventListener(MouseEvent.MOUSE_UP,this.onUp);
         this.bg_mc.gotoAndStop(3);
         this.text_txt.y = this.textY + 3;
      }
      
      function frame1() : *
      {
         addEventListener(MouseEvent.ROLL_OUT,this.onOut);
         addEventListener(MouseEvent.ROLL_OVER,this.onOver);
         addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         this.onDownBool = false;
         this.textY = 12;
         this.text_txt.defaultTextFormat.size = 22;
         this.text_txt.defaultTextFormat.color = 0xFFFFFF;
         this.text_txt.defaultTextFormat.font = "Ubuntu Mono";
      }
   }
}
