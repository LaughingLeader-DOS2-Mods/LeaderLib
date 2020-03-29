package
{
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.external.ExternalInterface;
   import flash.geom.Point;
   import flash.text.TextField;
   
   public dynamic class comboElement extends MovieClip
   {
       
      
      public var hl_mc:emptyBG;
      
      public var sel_mc:MovieClip;
      
      public var text_txt:TextField;
      
      public function comboElement()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function deselectElement(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = this.Combo.root as MovieClip;
         _loc2_.selectedInfo_txt.visible = false;
         this.text_txt.textColor = 16777215;
         this.text_txt.visible = true;
      }
      
      public function selectElement(param1:MouseEvent) : *
      {
         if(this.Combo.m_isOpen)
         {
            this.text_txt.textColor = 11316396;
            ExternalInterface.call("PlaySound","UI_Generic_Over");
         }
      }
      
      public function setSelectionText() : *
      {
         var _loc1_:MovieClip = this.Combo.root as MovieClip;
         _loc1_.selectedInfo_txt.visible = true;
         var _loc2_:Point = new Point(0,0);
         var _loc3_:Point = _loc1_.globalToLocal(this.localToGlobal(_loc2_));
         _loc1_.selectedInfo_txt.x = _loc3_.x + 22 + root.x;
         _loc1_.selectedInfo_txt.y = _loc3_.y - 48;
         _loc1_.stage.addChild(_loc1_.selectedInfo_txt);
         _loc1_.selectedInfo_txt.htmlText = this.text_txt.htmlText;
      }
      
      public function onMouseOver(param1:MouseEvent) : *
      {
         this.setSelectionText();
         var _loc2_:MovieClip = this.Combo.root as MovieClip;
         if(this.tooltip != null && this.tooltip != "")
         {
            _loc2_.curTooltip = this.pos;
            ExternalInterface.call("showTooltip",this.tooltip);
            _loc2_.hasTooltip = true;
         }
      }
      
      public function onMouseOut(param1:MouseEvent) : *
      {
         var _loc2_:MovieClip = this.Combo.root as MovieClip;
         if(_loc2_.curTooltip == this.pos && _loc2_.hasTooltip)
         {
            ExternalInterface.call("hideTooltip");
            _loc2_.hasTooltip = false;
         }
         _loc2_.curTooltip = -1;
      }
      
      function frame1() : *
      {
         addEventListener(MouseEvent.ROLL_OVER,this.onMouseOver);
         addEventListener(MouseEvent.ROLL_OUT,this.onMouseOut);
         this.text_txt.defaultTextFormat.size = 16;
         this.text_txt.defaultTextFormat.color = 0xFFFFFF;
         this.text_txt.defaultTextFormat.font = "Ubuntu Mono";
      }
   }
}
