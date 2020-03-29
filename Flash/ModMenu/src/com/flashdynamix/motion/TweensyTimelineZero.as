package com.flashdynamix.motion
{
   public class TweensyTimelineZero
   {
       
      
      public var time:Number = 0;
      
      public var instance;
      
      public var key:Object;
      
      public var ease:Function;
      
      public var easeParams:Array;
      
      public var properties:int = 0;
      
      public var to:Object;
      
      public var from:Object;
      
      public var duration:Number = 0;
      
      public var delayStart:Number = 0;
      
      public var delayEnd:Number = 0;
      
      public var onUpdate:Function;
      
      public var onUpdateParams:Array;
      
      public var onComplete:Function;
      
      public var onCompleteParams:Array;
      
      public var update;
      
      public function TweensyTimelineZero()
      {
         super();
         this.to = {};
         this.from = {};
         this.easeParams = [];
      }
   }
}
