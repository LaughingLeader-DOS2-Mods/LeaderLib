package characterCreation_fla
{
	import LS_Classes.listDisplay;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class attributesMC_49 extends MovieClip
	{
		public var attrHolder_mc:MovieClip;
		public var backBtn_mc:brownBtn;
		public var button_mc:greenBtn;
		public var desc_txt:TextField;
		public var freePoints_txt:TextField;
		public var nextBtn_mc:greenBtn;
		public var title_txt:TextField;
		public var root_mc:MovieClip;
		public var attributes:listDisplay;
		
		public function attributesMC_49()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(rootMC:MovieClip) : *
		{
			this.root_mc = rootMC;
			this.button_mc.init(this.root_mc.CCPanel_mc.nextPanel);
			this.backBtn_mc.init(this.root_mc.CCPanel_mc.prevPanel);
			this.nextBtn_mc.init(this.root_mc.CCPanel_mc.nextPanel);
			this.button_mc.visible = this.root_mc.creationType == 0 || this.root_mc.creationType == 2;
			this.backBtn_mc.visible = this.root_mc.creationType == 1;
			this.nextBtn_mc.visible = this.root_mc.creationType == 1;
			this.title_txt.wordWrap = this.title_txt.multiline = false;
			this.title_txt.autoSize = TextFieldAutoSize.CENTER;
			this.freePoints_txt.wordWrap = this.freePoints_txt.multiline = false;
			this.freePoints_txt.autoSize = TextFieldAutoSize.CENTER;
			this.desc_txt.autoSize = TextFieldAutoSize.NONE;
			this.desc_txt.wordWrap = this.desc_txt.multiline = true;
			this.attributes = new listDisplay();
			this.attrHolder_mc.addChild(this.attributes);
		}
		
		public function updateAttributes(param1:Array) : *
		{
			var val2:Array = null;
			var val3:uint = 0;
			var val4:uint = 0;
			var val5:String = null;
			var val6:String = null;
			var val7:Number = NaN;
			var val8:Number = NaN;
			if(param1.length > 0)
			{
				val2 = new Array();
				val3 = 0;
				while(val3 < param1.length)
				{
					val4 = param1[val3++];
					val5 = param1[val3++];
					val6 = param1[val3++];
					val7 = param1[val3++];
					val8 = param1[val3++];
					this.addAttribute(val4,val5,val6,val7,val8);
					if(val8 != 0)
					{
						val2.push(val4);
						val2.push(val5);
						val2.push(val8);
					}
				}
				this.root_mc.CCPanel_mc.class_mc.addTabTextContent(0,val2);
			}
			this.attributes.cleanUpElements();
			this.freePoints_txt.htmlText = this.root_mc.textArray[12] + " " + this.root_mc.availableAttributePoints;
		}
		
		public function onPlus(mc:MovieClip) : *
		{
			ExternalInterface.call(mc.plus_mc.callbackStr,mc.statID);
		}
		
		public function onMin(mc:MovieClip) : *
		{
			ExternalInterface.call(mc.min_mc.callbackStr,mc.statID);
		}
		
		public function addAttribute(statID:*, label:String, attributeInfo:String, value:Number, delta:Number, frame:uint=0, isCustom:Boolean=false) : *
		{
			var attribute_mc:MovieClip = !isCustom ? this.attributes.getElementByNumber("statID", statID) : this.attributes.getElementByString("statID", statID);
			if(!attribute_mc)
			{
				attribute_mc = new attributeEntry();
				attribute_mc.onInit(this.root_mc,this.onPlus,this.onMin);
				attribute_mc.statID = statID;
				attribute_mc.icon_mc.gotoAndStop(frame);
				attribute_mc.heightOverride = 28;
				this.attributes.addElement(attribute_mc,false);
			}
			attribute_mc.MakeCustom(statID, isCustom);
			attribute_mc.setAttribute(label,attributeInfo);
			attribute_mc.setValue(value,delta);
			attribute_mc.isUpdated = true;
		}
		
		public function frame1() : *
		{
		}
	}
}
