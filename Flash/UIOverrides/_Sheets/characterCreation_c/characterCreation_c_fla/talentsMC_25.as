package characterCreation_c_fla
{
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class talentsMC_25 extends MovieClip
	{
		public var base_mc:MovieClip;
		public var talents_mc:MovieClip;
		public var title_txt:TextField;
		public var root_mc:MovieClip;
		
		public function talentsMC_25()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(param1:MovieClip) : *
		{
			this.root_mc = param1;
			this.talents_mc.onInit(param1,1);
		}
		
		public function delegateUp(param1:String) : Boolean
		{
			return this.talents_mc.delegateUp(param1);
		}
		
		public function delegateDown(param1:String, param2:Number) : Boolean
		{
			var val3:MovieClip = null;
			switch(param1)
			{
				case "IE UIUp":
				case "IE UIDown":
					return this.talents_mc.delegateDown(param1);
				case "IE UIAccept":
					val3 = this.talents_mc.contentList.getCurrentMovieClip();
					if(val3 && val3.choosable)
					{
						ExternalInterface.call("PlaySound","UI_Gen_XButton_Click");
						ExternalInterface.call("toggleTalent",val3.contentID);
					}
					return true;
				default:
					return false;
			}
		}
		
		public function updateTalents(param1:Array, param2:Array) : *
		{
			var val3:uint = 0;
			var val4:uint = 0;
			var val5:String = null;
			var val6:Boolean = false;
			var val7:Boolean = false;
			if(param1.length > 0)
			{
				this.root_mc.availableTalentPoints = param1[0];
				this.talents_mc.setAvailablePoints(this.root_mc.textArray[15] + " " + this.root_mc.availableTalentPoints);
				val3 = 1;
				while(val3 < param1.length)
				{
					val4 = param1[val3++];
					val5 = param1[val3++];
					val6 = param1[val3++];
					val7 = param1[val3++];
					this.addTalentElement(val4,val5,val6,val7,false);
				}
			}
			if(param2.length > 0)
			{
				val3 = 0;
				while(val3 < param2.length)
				{
					val4 = param2[val3++];
					val5 = param2[val3++];
					this.addTalentElement(val4,val5,true,false,true);
				}
			}
			this.talents_mc.setupLists();
		}
		
		public function applySelection() : *
		{
			this.talents_mc.contentList.select(0,true);
		}
		
		public function addTalentElement(param1:uint, param2:String, param3:Boolean, param4:Boolean, param5:Boolean) : *
		{
			var val6:MovieClip = null;
			if(param5)
			{
				val6 = this.talents_mc.racialList.getElementByNumber("contentID",param1);
			}
			else
			{
				val6 = this.talents_mc.contentList.getElementByNumber("contentID",param1);
			}
			if(!val6)
			{
				val6 = new tagTalent();
				val6.onInit(this.root_mc);
				val6.contentID = param1;
				val6.contentName = param2;
				val6.isRacial = param5;
				val6.isTalent = true;
				this.talents_mc.addContent(val6,param5);
			}
			val6.dColour = !!param4?0:12910617;
			val6.choosable = param4;
			val6.setLabel(param2);
			val6.setActive(param3);
			val6.bg_mc.gotoAndStop(2);
			val6.isUpdated = true;
		}
		
		private function frame1() : * { }
	}
}
