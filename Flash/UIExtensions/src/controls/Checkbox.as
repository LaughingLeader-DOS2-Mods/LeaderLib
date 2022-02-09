package controls
{
   import LS_Classes.tooltipHelper;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.geom.Rectangle;
   
   public dynamic class Checkbox extends MovieClip
   {
      public var bg_mc:MovieClip;
      public var label_txt:TextField;
      public var label_bg_mc:MovieClip;
      public var mHeight:Number;
      
      public var filterBool:Boolean = false;
      public var isEnabled:Boolean = true;
      public var stateID:Number = 0;
      public var id:*;

      public var tooltip:String = "";
      public var tooltipOverrideW:Number = 0;
      public var tooltipYOffset:Number = 0;
      public var tooltipSide:String = null;

      public var mouseOver:Function;
      public var mouseOut:Function;

      public var callbackName:String = "LeaderLib_UIExtensions_OnControl";

      public function get tooltipActive():Boolean
      {
         return MainTimeline.Instance.hasTooltip && MainTimeline.Instance.curTooltip == this.tooltip;
      }
      
      public function Checkbox()
      {
         super();
         this.addFrameScript(0,this.frame1);
      }
      
      public function onDown(e:MouseEvent) : void
      {
         this.bg_mc.gotoAndStop(this.stateID * 3 + 3);
         this.addEventListener(MouseEvent.MOUSE_UP,this.onClick);
      }

      public function toggle() : void 
      {
         this.stateID++;
         if(this.filterBool)
         {
            if(this.stateID > 2)
            {
               this.stateID = 0;
            }
         }
         else if(this.stateID > 1)
         {
            this.stateID = 0;
         }
         this.bg_mc.gotoAndStop(this.stateID * 3 + (this.tooltipActive ? 2 : 1));
         Registry.ExtCall("PlaySound","UI_Gen_XButton_Click");
         Registry.ExtCall(this.callbackName, "checkbox", this.id, this.stateID);
      }
      
      public function onClick(e:MouseEvent) : void
      {
         if(this.isEnabled)
         {
            toggle();
         }
         this.removeEventListener(MouseEvent.MOUSE_UP,this.onClick);
      }
      
      public function deselectElement(e:MouseEvent=null) : void
      {
         this.removeEventListener(MouseEvent.MOUSE_UP,this.onClick);
         this.bg_mc.gotoAndStop(this.stateID * 3 + (this.tooltipActive ? 2 : 1));
      }
      
      public function selectElement(e:MouseEvent=null) : void
      {
         this.bg_mc.gotoAndStop(this.stateID * 3 + 2);
      }
      
      public function setState(state:Number) : void
      {
         this.stateID = state;
         this.bg_mc.gotoAndStop(this.stateID * 3 + (this.tooltipActive ? 2 : 1));
      }

      public function setText(text:String) : void
      {
         // this.label_txt.defaultTextFormat.size = 16;
         // this.label_txt.defaultTextFormat.color = 0xFFFFFF;
         // this.label_txt.defaultTextFormat.font = "Quadraat Offc Pro";
         this.label_txt.autoSize = TextFieldAutoSize.LEFT;
         this.label_txt.htmlText = text;
         var bounds:Rectangle = this.label_txt.getBounds(this);
         this.label_bg_mc.width = Math.ceil(bounds.x + bounds.width);
         //this.label_bg_mc.width = Math.ceil((this.label_txt.width*1.2) + 12);
      }
      
      public function frame1() : void
      {
         this.mouseOver = this.selectElement;
         this.mouseOut = this.deselectElement;
         TooltipHandler.init(this);
         this.mHeight = 30;
         this.label_txt.mouseEnabled = false;

         this.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
         //this.bg_mc.addEventListener(MouseEvent.MOUSE_OVER,this.selectElement);
         //this.bg_mc.addEventListener(MouseEvent.MOUSE_OUT,this.deselectElement);

         // this.label_txt.defaultTextFormat.size = 16;
         // this.label_txt.defaultTextFormat.color = 0xFFFFFF;
         // this.label_txt.defaultTextFormat.font = "Quadraat Offc Pro";
         this.label_txt.autoSize = TextFieldAutoSize.LEFT;

         this.setState(this.stateID);
      }
   }
}