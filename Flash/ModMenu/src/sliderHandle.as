package
{
   import flash.display.MovieClip;
   
   public dynamic class sliderHandle extends MovieClip
   {
       
      
      public function sliderHandle()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      function frame1() : *
      {
         stop();
      }
   }
}
