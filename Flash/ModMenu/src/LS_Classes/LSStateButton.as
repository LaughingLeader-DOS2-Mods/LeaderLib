package LS_Classes
{
   import flash.display.MovieClip;
   import flash.events.FocusEvent;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class LSStateButton extends MovieClip
   {
       
      
      private var pressedFunc:Function;
      
      private var pressedParams:Object;
      
      private var m_Active:Boolean = false;
      
      private var m_Disabled:Boolean = false;
      
      public var SND_Over:String = "UI_Generic_Over";
      
      public var SND_Press:String = "";
      
      public var SND_Click:String = "UI_Gen_XButton_Click";
      
      public var textY:Number;
      
      public var textInActiveAlpha:Number = 1;
      
      public var textActiveAlpha:Number = 1;
      
      public var interactiveTextOnClick:Boolean = true;
      
      public var m_AllowToggleActive:Boolean = true;
      
      public var hitArea_mc:MovieClip;
      
      public var text_txt:TextField;
      
      public var bg_mc:MovieClip;
      
      public var activeBG_mc:MovieClip;
      
      public var disabled_mc:MovieClip;
      
      public var onOverFunc:Function;
      
      public var onDownFunc:Function;
      
      public var onOutFunc:Function;
      
      public function LSStateButton()
      {
         super();
         if(this.text_txt)
         {
            this.text_txt.mouseEnabled = false;
            this.text_txt.alpha = this.textInActiveAlpha;
            this.text_txt.defaultTextFormat.size = 22;
            this.text_txt.defaultTextFormat.color = 0xFFFFFF;
            this.text_txt.defaultTextFormat.font = "Ubuntu Mono";
         }
         if(this.hitArea_mc)
         {
            this.hitArea_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
            this.hitArea_mc.addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
            this.hitArea_mc.addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         }
         else
         {
            addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
            addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
            addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         }
         addEventListener(FocusEvent.FOCUS_OUT,this.onFocusLost);
      }
      
      public function initialize(buttonText:String, onClick:Function, onClickParams:Object = null, selected:Boolean = false, textSize:Number = -1, disabled:Boolean = false) : *
      {
         var _loc7_:TextFormat = null;
         if(this.text_txt)
         {
            if(textSize != -1)
            {
               _loc7_ = this.text_txt.defaultTextFormat;
               _loc7_.size = textSize;
               this.text_txt.defaultTextFormat = _loc7_;
            }
            this.text_txt.alpha = !!selected?Number(this.textActiveAlpha):Number(this.textInActiveAlpha);
            this.text_txt.htmlText = buttonText;
            this.textY = this.text_txt.y;
            this.text_txt.y = this.textY;
         }
         this.init(onClick,onClickParams,selected,disabled);
      }
      
      public function init(onClick:Function, onClickParams:Object = null, selected:Boolean = false, disabled:Boolean = false) : *
      {
         this.pressedFunc = onClick;
         if(onClickParams)
         {
            this.pressedParams = onClickParams;
         }
         if(this.text_txt)
         {
            this.text_txt.y = this.textY;
         }
         this.bg_mc.visible = !selected;
         this.activeBG_mc.visible = selected;
         this.m_Active = selected;
         this.setEnabled(!disabled);
      }
      
      public function setText(text:String, textSize:Number = -1) : *
      {
         var formatter:TextFormat = null;
         if(this.text_txt)
         {
            if(textSize != -1)
            {
               formatter = this.text_txt.defaultTextFormat;
               formatter.size = textSize;
               this.text_txt.defaultTextFormat = formatter;
            }
            this.text_txt.htmlText = text;
         }
      }
      
      public function setActive(param1:Boolean) : *
      {
         this.m_Active = param1;
         this.bg_mc.visible = !param1;
         this.activeBG_mc.visible = param1;
         if(this.text_txt)
         {
            this.text_txt.alpha = !!param1?Number(this.textActiveAlpha):Number(this.textInActiveAlpha);
         }
      }
      
      public function get isActive() : Boolean
      {
         return this.m_Active;
      }
      
      public function setEnabled(param1:Boolean) : *
      {
         if(this.disabled_mc)
         {
            this.disabled_mc.visible = !param1;
         }
         this.m_Disabled = !param1;
      }
      
      public function get isEnabled() : Boolean
      {
         return !this.m_Disabled;
      }
      
      private function onFocusLost(param1:FocusEvent) : void
      {
         if(this.text_txt)
         {
            this.text_txt.y = this.textY;
         }
      }
      
      private function onMouseOver(param1:MouseEvent) : *
      {
         if(!this.m_Disabled)
         {
            this.bg_mc.gotoAndStop(2);
            this.activeBG_mc.gotoAndStop(2);
            if(this.SND_Over != null)
            {
               ExternalInterface.call("PlaySound",this.SND_Over);
            }
            if(this.text_txt)
            {
               this.text_txt.alpha = this.textActiveAlpha;
            }
            if(this.onOverFunc != null)
            {
               this.onOverFunc(this as MovieClip);
            }
         }
      }
      
      private function onMouseOut(param1:MouseEvent) : *
      {
         if(this.hitArea_mc)
         {
            this.hitArea_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         else
         {
            removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         this.bg_mc.gotoAndStop(1);
         this.activeBG_mc.gotoAndStop(1);
         if(this.text_txt)
         {
            this.text_txt.y = this.textY;
            if(!this.activeBG_mc.visible)
            {
               this.text_txt.alpha = this.textInActiveAlpha;
            }
         }
         if(this.onOutFunc != null)
         {
            this.onOutFunc(this as MovieClip);
         }
      }
      
      private function onDown(param1:MouseEvent) : *
      {
         if(!this.m_Disabled)
         {
            if(this.SND_Press != null)
            {
               ExternalInterface.call("PlaySound",this.SND_Press);
            }
            if(this.hitArea_mc)
            {
               this.hitArea_mc.addEventListener(MouseEvent.MOUSE_UP,this.onUp);
            }
            else
            {
               addEventListener(MouseEvent.MOUSE_UP,this.onUp);
            }
            this.bg_mc.gotoAndStop(3);
            this.activeBG_mc.gotoAndStop(3);
            if(this.text_txt && this.interactiveTextOnClick)
            {
               this.text_txt.y = this.textY + 2;
            }
            if(this.onDownFunc != null)
            {
               this.onDownFunc(this as MovieClip);
            }
         }
      }
      
      private function onUp(param1:MouseEvent) : *
      {
         if(this.hitArea_mc)
         {
            this.hitArea_mc.removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         else
         {
            removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
         }
         if(this.SND_Click != null)
         {
            ExternalInterface.call("PlaySound",this.SND_Click);
         }
         if(!this.m_Disabled && this.m_AllowToggleActive)
         {
            this.setActive(!this.m_Active);
         }
         this.bg_mc.gotoAndStop(2);
         this.activeBG_mc.gotoAndStop(2);
         if(this.text_txt && this.interactiveTextOnClick)
         {
            this.text_txt.y = this.textY;
         }
         if(this.pressedFunc != null && !this.m_Disabled)
         {
            if(this.pressedParams != null)
            {
               this.pressedFunc(this.pressedParams);
            }
            else
            {
               this.pressedFunc();
            }
         }
      }
   }
}
