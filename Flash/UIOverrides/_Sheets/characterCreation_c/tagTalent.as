package
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class tagTalent extends MovieClip
	{
		public var bg_mc:MovieClip;
		public var bullet_mc:MovieClip;
		public var hl_mc:MovieClip;
		public var label_txt:TextField;
		public var root_mc:MovieClip;
		public var dColour:Number;

		//LeaderLib Changes
		public var statID:*;
		public var callbackStr:String = "selectTalent";
		public var isCustom:Boolean = false;

		public function MakeCustom(id:*, b:Boolean=true) : *
		{
			this.statID = id;
			this.isCustom = b;
			if(b)
			{
				this.callbackStr = "selectTalentCustom";
				this.minus_mc.callbackStr = "minusTalentCustom";
				this.plus_mc.callbackStr = "plusTalentCustom";
			}
			else
			{
				this.callbackStr = "selectTalent";
				this.minus_mc.callbackStr = "minusTalent";
				this.plus_mc.callbackStr = "plusTalent";
			}
		}
		
		public function tagTalent()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(rootMovieclip:MovieClip) : *
		{
			this.root_mc = rootMovieclip;
			this.label_txt.wordWrap = this.label_txt.multiline = false;
			this.label_txt.autoSize = TextFieldAutoSize.LEFT;
			this.bullet_mc.gotoAndStop(2);
			this.bullet_mc.visible = false;
		}
		
		public function setLabel(contentName:String) : *
		{
			this.label_txt.htmlText = contentName;
			this.label_txt.textColor = !!this.isActive?uint(this.root_mc.hFont):uint(this.root_mc.dFont);
			this.contentName = contentName;
		}
		
		public function get isActive() : *
		{
			return this.bullet_mc.visible;
		}
		
		public function setActive(isVisible:Boolean) : *
		{
			this.bullet_mc.visible = isVisible;
			if(this.choosable || this.isRacial)
			{
				this.label_txt.textColor = !!this.isActive?uint(this.root_mc.hFont):uint(this.root_mc.dFont);
			}
			else
			{
				this.label_txt.textColor = this.dColour;
			}
		}
		
		public function selectElement() : *
		{
			if(this.isTalent)
			{
				ExternalInterface.call(this.callbackStr, this.statID);
			}
			else
			{
				ExternalInterface.call("selectTag", this.categoryID, this.contentID);
			}
			this.hl_mc.startAnimHL();
			this.hl_mc.visible = true;
		}
		
		public function deselectElement() : *
		{
			this.hl_mc.stopTweens();
			this.hl_mc.visible = false;
		}
		
		public function frame1() : * {}
	}
}
