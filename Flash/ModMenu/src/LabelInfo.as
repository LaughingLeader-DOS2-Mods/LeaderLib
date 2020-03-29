package
{
   import LS_Classes.textEffect;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public dynamic class LabelInfo extends MovieClip
   {
       
      
      public var info_txt:TextField;
      
      public var label_txt:TextField;
      
      public var mHeight:Number;
      
      public function LabelInfo()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function deselectElement(param1:MouseEvent) : *
      {
      }
      
      public function selectElement(param1:MouseEvent) : *
      {
      }
      
      function frame1() : *
      {
         this.label_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
         this.mHeight = 40;
         this.info_txt.defaultTextFormat.size = 16;
         this.info_txt.defaultTextFormat.color = 0xFFFFFF;
         this.info_txt.defaultTextFormat.font = "Ubuntu Mono";
         this.label_txt.defaultTextFormat.size = 16;
         this.label_txt.defaultTextFormat.color = 0xFFFFFF;
         this.label_txt.defaultTextFormat.font = "Ubuntu Mono";
      }
   }
}
