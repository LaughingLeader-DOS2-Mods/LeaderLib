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
		//This is a different var name than KB+M, so we're fixing that.
		//public var contentID:uint;
		public var talentID:uint;
		//Custom non-standard talents
		public var customID:String;
		public var isCustom:Boolean = false;
		
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
				if(!this.isCustom)
				{
					ExternalInterface.call("selectTalent", this.talentID);
				}
				else
				{
					ExternalInterface.call("selectCustomTalent", this.customID);
				}
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
		
		private function frame1() : * {}
	}
}
