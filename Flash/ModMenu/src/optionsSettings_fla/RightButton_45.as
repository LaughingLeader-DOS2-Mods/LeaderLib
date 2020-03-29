package optionsSettings_fla
{
   import com.flashdynamix.motion.TweensyTimelineZero;
   import com.flashdynamix.motion.TweensyZero;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public dynamic class RightButton_45 extends MovieClip
   {
       
      
      public var bg_mc:MovieClip;
      
      public var hl_mc:MovieClip;
      
      public var base:MovieClip;
      
      public var timeline:TweensyTimelineZero;
      
      public function RightButton_45()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function onMouseOver(param1:MouseEvent) : *
      {
         if(this.timeline)
         {
            this.timeline.onComplete = null;
         }
         this.hl_mc.visible = true;
         TweensyZero.to(this.hl_mc,{"alpha":1});
      }
      
      public function onMouseOut(param1:MouseEvent) : *
      {
         this.timeline = TweensyZero.to(this.hl_mc,{"alpha":0});
         this.timeline.onComplete = this.hlInvis;
      }
      
      public function onDown(param1:MouseEvent) : *
      {
         this.base.next();
      }
      
      public function hlInvis() : *
      {
         this.hl_mc.visible = false;
      }
      
      function frame1() : *
      {
         this.base = (parent as MovieClip).selList;
         this.hl_mc.visible = false;
         addEventListener(MouseEvent.MOUSE_UP,this.onDown);
         addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
      }
   }
}
