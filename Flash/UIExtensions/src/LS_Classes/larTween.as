package LS_Classes
{
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.external.ExternalInterface;
   import flash.utils.Timer;
   
   public class larTween extends IggyTween
   {
       
      
      public var m_FinishCallback:Function = null;
      
      public var m_UpdateCallback:Function = null;
      
      public var m_StopCallback:Function = null;
      
      public var m_ResumeCallback:Function = null;
      
      public var m_OverrideCallback:Function = null;
      
      public var m_FinishCallbackParams:Object = null;
      
      private var delayTimer:Timer = null;
      
      public function larTween(param1:Object, param2:String, param3:Function, param4:Number, param5:Number, param6:Number, param7:Function = null, param8:Object = null, param9:Number = 0.0)
      {
         var _loc12_:MovieClip = null;
         var _loc10_:Boolean = true;
         var _loc11_:DisplayObject = param1 as DisplayObject;
         if(_loc11_)
         {
            if(!_loc11_.stage)
            {
               _loc12_ = _loc11_.parent as MovieClip;
               while(_loc12_)
               {
                  _loc12_ = _loc12_.parent as MovieClip;
               }
               ExternalInterface.call("UIAssert","using tween on displayObject that is not attached to the stage :" + _loc11_.name + " parent:" + (_loc11_.parent as MovieClip).name);
               _loc10_ = false;
            }
         }
         if(_loc10_)
         {
            super(param1,param2,param3,param4,param5,param6,true,true,true);
            if(param9 > 0)
            {
               super.stop();
               this.delayTimer = new Timer(param9 * 1000,1);
               this.delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.delayedStart);
               this.delayTimer.start();
            }
            this.m_FinishCallback = param7;
            this.m_FinishCallbackParams = param8;
         }
      }
      
      private function removedFromStageHandler(param1:Event) : *
      {
         var _loc2_:DisplayObject = param1.currentTarget as DisplayObject;
         if(_loc2_)
         {
            _loc2_.removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         }
         this.stop();
         this.cleanupTimer();
      }
      
      private function cleanupTimer() : *
      {
         if(this.delayTimer != null)
         {
            this.delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.delayedStart);
            this.delayTimer.stop();
            this.delayTimer = null;
         }
      }
      
      override public function resume() : *
      {
         if(this.delayTimer != null)
         {
            this.delayTimer.start();
         }
         else
         {
            super.resume();
         }
      }
      
      override public function stop() : *
      {
         if(isPlaying)
         {
            super.stop();
         }
         if(this.delayTimer != null)
         {
            this.delayTimer.stop();
         }
      }
      
      override public function motionStart() : *
      {
         var _loc1_:DisplayObject = null;
         super.motionStart();
         if(obj)
         {
            _loc1_ = obj as DisplayObject;
            if(_loc1_)
            {
               if(_loc1_.stage)
               {
                  _loc1_.addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler,false,0,true);
               }
            }
         }
      }
      
      override public function motionStop() : *
      {
         var _loc1_:DisplayObject = null;
         super.motionStop();
         if(obj)
         {
            _loc1_ = obj as DisplayObject;
            if(_loc1_)
            {
               _loc1_.removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
            }
         }
      }
      
      override public function motionFinish() : *
      {
         if(this.m_FinishCallback != null)
         {
            if(this.m_FinishCallbackParams == null)
            {
               this.m_FinishCallback();
            }
            else
            {
               this.m_FinishCallback(this.m_FinishCallbackParams);
            }
         }
      }
      
      override public function motionResume() : *
      {
         super.motionResume();
         if(this.m_ResumeCallback != null)
         {
            this.m_ResumeCallback();
         }
      }
      
      override public function set time(param1:Number) : *
      {
         super.time = param1;
         if(this.m_UpdateCallback != null)
         {
            this.m_UpdateCallback();
         }
      }
      
      override public function motionOverride() : *
      {
         if(this.m_OverrideCallback != null)
         {
            this.m_OverrideCallback();
         }
      }
      
      private function delayedStart(param1:TimerEvent) : *
      {
         this.cleanupTimer();
         super.resume();
      }
      
      public function set onComplete(param1:Function) : *
      {
         this.m_FinishCallback = param1;
      }
      
      public function get onComplete() : Function
      {
         return this.m_FinishCallback;
      }
      
      public function set onUpdate(param1:Function) : *
      {
         this.m_UpdateCallback = param1;
      }
      
      public function get onUpdate() : Function
      {
         return this.m_UpdateCallback;
      }
   }
}
