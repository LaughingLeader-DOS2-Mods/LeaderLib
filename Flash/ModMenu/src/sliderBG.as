package
{
   import flash.display.MovieClip;
   
   public dynamic class sliderBG extends MovieClip
   {
       
      
      public function sliderBG()
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
