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
		public var statID:Number; // Double handle

		//LeaderLib
		public var am:Number; // The stat's value
		public var id:int; // index in the group list
		public var statIndex:int; // Index in stats_array
		public var isCustom:Boolean = false; // Used to avoid calling the base Larian calls for add/remove/edit/delete

		public function MakeCustom(id:Number, b:Boolean=true) : *
		{
			this.statID = id;
			this.isCustom = b;
			if(b)
			{
				this.minus_mc.callbackStr = "minusCustomStatCustom";
				this.plus_mc.callbackStr = "plusCustomStatCustom";
			}
			else
			{
				this.minus_mc.callbackStr = "minusCustomStat";
				this.plus_mc.callbackStr = "plusCustomStat";
			}
		}
		
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
			this.base.showCustomTooltipForMC(this,"showCustomStatTooltip",this.statID, this.id);
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
			if(!this.isCustom) {
				ExternalInterface.call("editCustomStat", this.statID);
			}
		}
		
		public function onDeleteBtnClicked() : *
		{
			if(!this.isCustom) {
				ExternalInterface.call("removeCustomStat", this.statID);
			}
		}
		
		public function frame1() : *
		{
			this.base = root as MovieClip;
			this.hl_mc.addEventListener(MouseEvent.ROLL_OVER, this.onOver);
			this.hl_mc.addEventListener(MouseEvent.ROLL_OUT, this.onOut);
		}
	}
}
