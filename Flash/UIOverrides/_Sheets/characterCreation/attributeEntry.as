package
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class attributeEntry extends MovieClip
	{
		public var hit_mc:hit;
		public var icon_mc:MovieClip;
		public var min_mc:minusButton;
		public var plus_mc:plusButton;
		public var title_txt:TextField;
		public var value_txt:TextField;
		public var root_mc:MovieClip;
		public var currentValue:Number;
		public var deltaValue:Number;
		public var attributeInfo:String;

		//LeaderLib Changes
		public var statID:*;
		public var tooltip:Number; // The tooltip ID
		public var callbackStr:String = "showStatTooltip";
		public var isCustom:Boolean = false;

		public function MakeCustom(id:*, b:Boolean=true) : *
		{
			this.statID = id;
			this.isCustom = b;
			if(b)
			{
				this.callbackStr = "showStatTooltipCustom";
				this.min_mc.callbackStr = "minusStatCustom";
				this.plus_mc.callbackStr = "plusStatCustom";
			}
			else
			{
				this.callbackStr = "showStatTooltip";
				this.min_mc.callbackStr = "minusStat";
				this.plus_mc.callbackStr = "plusStat";
			}
		}
		
		public function attributeEntry()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(param1:MovieClip, param2:Function, param3:Function) : *
		{
			this.root_mc = param1;
			this.title_txt.wordWrap = false;
			this.title_txt.multiline = false;
			this.title_txt.autoSize = TextFieldAutoSize.LEFT;
			this.plus_mc.init(param2,this);
			this.min_mc.init(param3,this);
		}
		
		public function onHover(param1:MouseEvent) : *
		{
			var val2:Point = this.localToGlobal(new Point(0,0));
			ExternalInterface.call(this.callbackStr,this.root_mc.characterHandle,this.statID - 1,val2.x - this.root_mc.x,val2.y,this.hit_mc.width,this.hit_mc.height,"left");
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
		}
		
		public function setAttribute(label:String, attributeInfo:String) : *
		{
			this.title_txt.htmlText = label;
			this.attributeInfo = attributeInfo;
			this.hit_mc.width = this.title_txt.width;
			this.hit_mc.height = this.title_txt.height;
		}
		
		public function setValue(value:Number, delta:Number) : *
		{
			this.currentValue = value;
			this.deltaValue = delta;
			this.min_mc.visible = this.deltaValue > 0;
			this.plus_mc.visible = this.root_mc.availableAttributePoints > 0 && (this.deltaValue < this.root_mc.attributeCap || this.root_mc.attributeCap < 0);
			this.value_txt.htmlText = String(value);
		}
		
		public function frame1() : *
		{
			this.hit_mc.addEventListener(MouseEvent.ROLL_OVER,this.onHover);
			this.hit_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
		}
	}
}
