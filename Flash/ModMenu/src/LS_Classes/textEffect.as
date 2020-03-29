package LS_Classes
{
   import flash.filters.BitmapFilterQuality;
   import flash.filters.DropShadowFilter;
   
   public class textEffect
   {
       
      
      public function textEffect()
      {
         super();
      }
      
      public static function createStrokeFilter(param1:uint, param2:Number, param3:Number = 1.0, param4:uint = 1, param5:uint = 2) : Array
      {
         var _loc8_:DropShadowFilter = null;
         var _loc9_:DropShadowFilter = null;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:DropShadowFilter = null;
         var _loc6_:Array = new Array();
         var _loc7_:Number = 0;
         if(param5 <= 2)
         {
            _loc8_ = new DropShadowFilter(param2,45,param1,param3,_loc7_,_loc7_,param4,BitmapFilterQuality.LOW,false,false,false);
            _loc9_ = new DropShadowFilter(param2,135,param1,param3,_loc7_,_loc7_,param4,BitmapFilterQuality.LOW,false,false,false);
            _loc6_.push(_loc8_);
            _loc6_.push(_loc9_);
         }
         else
         {
            _loc10_ = 45;
            _loc11_ = 360 / param5;
            _loc12_ = 0;
            while(_loc12_ < param5)
            {
               _loc13_ = new DropShadowFilter(param2,_loc10_,param1,param3,_loc7_,_loc7_,param4,BitmapFilterQuality.LOW,false,false,false);
               _loc6_.push(_loc13_);
               _loc10_ = _loc10_ + _loc11_;
               _loc12_++;
            }
         }
         return _loc6_;
      }
   }
}
