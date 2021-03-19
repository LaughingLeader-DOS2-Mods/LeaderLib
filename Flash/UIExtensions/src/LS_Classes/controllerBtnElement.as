package LS_Classes
{
	import flash.display.MovieClip;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.getDefinitionByName;
	
	public dynamic class controllerBtnElement extends MovieClip
	{
		 
		
		public var icon_mc:controllerBtnHint;
		
		public var text_txt:TextField;
		
		public const strokeW:Number = 2.5;
		
		public var iconY:Number;
		
		public var iconId:Number;
		
		public var id:Number;
		
		public var list_pos:Number;
		
		public var list_id:Number;
		
		public var selectable:Boolean;
		
		public var m_filteredObject:Boolean;
		
		public var ownerList:MovieClip;
		
		public var btnEnabled:Boolean = true;
		
		public function controllerBtnElement()
		{
			super();
			this.icon_mc = new controllerBtnHint();
			addChild(this.icon_mc);
			this.text_txt = new TextField();
			addChild(this.text_txt);
			var val1:Class = getDefinitionByName("$Title") as Class;
			var val2:Font = new val1();
			var val3:TextFormat = this.text_txt.getTextFormat();
			val3.font = val2.fontName;
			val3.color = 16777215;
			val3.size = 24;
			val3.leading = -10;
			val3.align = "left";
			this.text_txt.defaultTextFormat = val3;
			this.text_txt.x = 50;
			this.text_txt.autoSize = TextFieldAutoSize.LEFT;
			this.text_txt.filters = textEffect.createStrokeFilter(1050888,this.strokeW,1,1,9);
		}
		
		public function setBtnHintState(param1:Boolean) : *
		{
			this.btnEnabled = param1;
			var val2:TextFormat = this.text_txt.getTextFormat();
			val2.color = !!this.btnEnabled?16777215:11444117;
			this.text_txt.setTextFormat(val2);
			alpha = !!this.btnEnabled?Number(1):Number(0.7);
		}
		
		public function setBtnHint(param1:String, param2:Number, param3:Number = 200, param4:Boolean = true) : *
		{
			this.iconId = param2;
			this.icon_mc.setHintIcon(this.iconId);
			this.btnEnabled = param4;
			this.text_txt.htmlText = param1;
			var val5:Number = this.text_txt.textWidth;
			var val6:Number = textHelpers.getLongestWordLength(this.text_txt);
			if(this.text_txt.textWidth > param3)
			{
				val5 = val6 > param3?Number(val6):Number(param3);
				this.text_txt.multiline = true;
				this.text_txt.wordWrap = true;
			}
			else
			{
				this.text_txt.multiline = false;
				this.text_txt.wordWrap = false;
			}
			var val7:Number = Math.round(this.strokeW) * 2;
			this.text_txt.width = Math.ceil(val5 + val7);
			this.text_txt.width = Math.ceil(this.text_txt.textWidth + val7);
			this.text_txt.y = -Math.round(this.text_txt.textHeight * 0.5) - 2;
			this.iconY = this.icon_mc.y = -Math.round(this.icon_mc.height * 0.5);
			this.text_txt.x = this.icon_mc.x + this.icon_mc.width + 3;
			this.setBtnHintState(this.btnEnabled);
		}
		
		public function selectElement() : *
		{
		}
		
		public function deselectElement() : *
		{
		}
		
		public function getTextWidth() : Number
		{
			return this.text_txt.width;
		}
	}
}
