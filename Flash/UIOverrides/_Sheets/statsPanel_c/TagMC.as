package
{
	import LS_Classes.larTween;
	import fl.motion.easing.Quartic;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class TagMC extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var desc_txt:TextField;
		public var hl_mc:MovieClip;
		public var label_txt:TextField;
		public var timeline:larTween;
		public var base:MovieClip;
		
		public function TagMC()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setEmpty() : *
		{
			this.label_txt.visible = false;
		}
		
		public function setTag(param1:String, param2:Number, param3:String, param4:Number) : *
		{
			this.label_txt.autoSize = TextFieldAutoSize.LEFT;
			if(param1 == "")
			{
				param1 = " ";
			}
			this.label_txt.htmlText = param1;
			this.label_txt.visible = true;
			this.tooltip = param3;
		}
		
		public function selectElement() : *
		{
			this.timeline = new larTween(this.hl_mc,"alpha",Quartic.easeIn,this.hl_mc.alpha,1,0.1);
			ExternalInterface.call("selectTag",this.tooltip);
			this.label_txt.textColor = 0;
			this.desc_txt.textColor = 0;
		}
		
		public function deselectElement() : *
		{
			if(this.timeline)
			{
				this.timeline.stop();
			}
			this.hl_mc.alpha = 0;
			this.label_txt.textColor = 0;
			this.desc_txt.textColor = 0;
		}
		
		public function setText(param1:String, param2:Number = 1) : *
		{
			this.desc_txt.htmlText = param1;
			this.bg_mc.setBG(this.desc_txt.textHeight + this.desc_txt.y + 10,param2);
			this.hl_mc.setHeight(this.desc_txt.textHeight + this.desc_txt.y + 10);
		}
		
		public function adaptHLFirstTag() : *
		{
			this.hl_mc.y = 1;
			this.hl_mc.setHeight(this.desc_txt.textHeight + this.desc_txt.y + 9);
		}
		
		private function frame1() : *
		{
			this.base = root as MovieClip;
		}
	}
}
