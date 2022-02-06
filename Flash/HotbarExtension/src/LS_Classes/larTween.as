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
      
      public function larTween(target:Object, properyName:String, tweenFunc:Function, beginAt:Number, finishAt:Number, duration:Number, finishCallback:Function = null, finishParams:Object = null, delay:Number = 0.0)
      {
         var topParent:MovieClip = null;
         var isValid:Boolean = true;
         var targetObject:DisplayObject = target as DisplayObject;
         if(targetObject)
         {
            if(!targetObject.stage)
            {
               topParent = targetObject.parent as MovieClip;
               while(topParent)
               {
                  topParent = topParent.parent as MovieClip;
               }
               Registry.ExtCall("UIAssert","using tween on displayObject that is not attached to the stage :" + targetObject.name + " parent:" + (targetObject.parent as MovieClip).name);
               isValid = false;
            }
         }
         if(isValid)
         {
            super(target,properyName,tweenFunc,beginAt,finishAt,duration,true,true,true);
            if(delay > 0)
            {
               super.stop();
               this.delayTimer = new Timer(delay * 1000,1);
               this.delayTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.delayedStart);
               this.delayTimer.start();
            }
            this.m_FinishCallback = finishCallback;
            this.m_FinishCallbackParams = finishParams;
         }
      }
      
      private function removedFromStageHandler(e:Event) : void
      {
         var target:DisplayObject = e.currentTarget as DisplayObject;
         if(target)
         {
            target.removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
         }
         this.stop();
         this.cleanupTimer();
      }
      
      private function cleanupTimer() : void
      {
         if(this.delayTimer != null)
         {
            this.delayTimer.removeEventListener(TimerEvent.TIMER_COMPLETE,this.delayedStart);
            this.delayTimer.stop();
            this.delayTimer = null;
         }
      }
      
      override public function resume() : void
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
      
      override public function stop() : void
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
      
      override public function motionStart() : void
      {
         var target:DisplayObject = null;
         super.motionStart();
         if(this.obj)
         {
            target = this.obj as DisplayObject;
            if(target)
            {
               if(target.stage)
               {
                  target.addEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler,false,0,true);
               }
            }
         }
      }
      
      override public function motionStop() : void
      {
         var target:DisplayObject = null;
         super.motionStop();
         if(this.obj)
         {
            target = this.obj as DisplayObject;
            if(target)
            {
               target.removeEventListener(Event.REMOVED_FROM_STAGE,this.removedFromStageHandler);
            }
         }
      }
      
      override public function motionFinish() : void
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
      
      override public function motionResume() : void
      {
         super.motionResume();
         if(this.m_ResumeCallback != null)
         {
            this.m_ResumeCallback();
         }
      }
      
      override public function set time(time:Number) : void
      {
         super.time = time;
         if(this.m_UpdateCallback != null)
         {
            this.m_UpdateCallback();
         }
      }
      
      override public function motionOverride() : void
      {
         if(this.m_OverrideCallback != null)
         {
            this.m_OverrideCallback();
         }
      }
      
      private function delayedStart(e:TimerEvent) : void
      {
         this.cleanupTimer();
         super.resume();
      }
      
      public function set onComplete(callback:Function) : void
      {
         this.m_FinishCallback = callback;
      }
      
      public function get onComplete() : Function
      {
         return this.m_FinishCallback;
      }
      
      public function set onUpdate(callback:Function) : void
      {
         this.m_UpdateCallback = callback;
      }
      
      public function get onUpdate() : Function
      {
         return this.m_UpdateCallback;
      }
   }
}
