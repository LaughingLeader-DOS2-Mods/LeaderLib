package
{
	import LS_Classes.larTween;
	import fl.motion.easing.Quartic;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class CustomStat extends MovieClip
	{
		public var delete_mc:btnDeleteCustomStat;
		public var edit_mc:btnEditCustomStat;
		public var hl_mc:MovieClip;
		public var label_txt:TextField;
		public var line_mc:MovieClip;
		public var minus_mc:MovieClip;
		public var plus_mc:MovieClip;
		public var text_txt:TextField;
		public var timeline:larTween;
		public var base:MovieClip;
		public var tooltip:String;
		public var statId:Number;
		public var am:Number; // The stat's value
		
		public function CustomStat()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function init() : *
		{
			this.minus_mc.callbackStr = "minusCustomStat";
			this.plus_mc.callbackStr = "plusCustomStat";
			this.edit_mc.init(this.onEditBtnClicked);
			this.delete_mc.init(this.onDeleteBtnClicked);
			this.label_txt.wordWrap = true;
			this.label_txt.multiline = true;
			this.label_txt.autoSize = TextFieldAutoSize.LEFT;
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			this.base.showTooltipForMC(this,"showCustomStatTooltip");
			if(this.timeline && this.timeline.isPlaying)
			{
				this.timeline.stop();
			}
			this.hl_mc.visible = true;
			this.timeline = new larTween(this.hl_mc,"alpha",Quartic.easeIn,this.hl_mc.alpha,1,0.1);
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			this.timeline = new larTween(this.hl_mc,"alpha",Quartic.easeOut,this.hl_mc.alpha,0,0.1);
			this.base.hasTooltip = false;
			ExternalInterface.call("hideTooltip");
		}
		
		public function onEditBtnClicked() : *
		{
			ExternalInterface.call("editCustomStat",this.statId, this.id);
		}
		
		public function onDeleteBtnClicked() : *
		{
			ExternalInterface.call("removeCustomStat",this.statId, this.id);
		}
		
		private function frame1() : *
		{
			this.base = root as MovieClip;
			this.hl_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.hl_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
		}
	}
}
