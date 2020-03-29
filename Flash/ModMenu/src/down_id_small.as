package
{
   import flash.display.MovieClip;
   
   public dynamic class down_id_small extends MovieClip
   {
       
      
      public function down_id_small()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3);
      }
      
      function frame1() : *
      {
         stop();
      }
      
      function frame2() : *
      {
         stop();
      }
      
      function frame3() : *
      {
         stop();
      }
   }
}
