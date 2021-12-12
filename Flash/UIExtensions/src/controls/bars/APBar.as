package controls.bars
{
	import LS_Classes.horizontalList;
	import flash.display.MovieClip;
	import flash.geom.Rectangle;
	import flash.text.TextFieldAutoSize;
	import controls.APUnit;
	
	public dynamic class APBar extends MovieClip
	{
		public var apGlow_mc:MovieClip;
		public var apHolder_mc:MovieClip;
		public var apOverflow_mc:MovieClip;
		public var apStudHolder_mc:MovieClip;
		public var maxAPs:int;
		public var standardAP:uint;
		public var totalSlots:int;
		public var extraApSlots:Number;
		public var extraAps:Number;
		public var activeAps:int;
		public var apLeft:int;
		public var slotWidth:Number;
		public var apList:horizontalList;
		public var originalPosX:int;
		public var originalStudX:int;
		
		public function APBar()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		public function initAp() : *
		{
		}
		
		public function setMaxAp(param1:Number) : *
		{
			this.totalSlots = param1;
			var val2:uint = 0;
			if(param1 <= 0)
			{
				this.apGlow_mc.visible = false;
			}
			else
			{
				this.apGlow_mc.visible = true;
			}
			if(param1 > this.maxAPs)
			{
				this.extraApSlots = param1 - this.maxAPs;
				param1 = this.maxAPs;
			}
			else
			{
				this.extraApSlots = 0;
			}
			if(param1 != this.apList.length)
			{
				this.apList.clearElements();
				val2 = 0;
				while(val2 < param1 && val2 < 20)
				{
					this.addApC();
					val2++;
				}
				this.apList.positionElements();
				this.calculateBarOffset();
			}
			else
			{
				val2 = 0;
				while(val2 < this.apList.length)
				{
					this.setMCSTate(this.apList.content_array[val2],1);
					val2++;
				}
			}
			if(param1 != 0)
			{
				this.apStudHolder_mc.visible = true;
				param1 = param1 + 1;
				this.apStudHolder_mc.scrollRect = new Rectangle(0,0,param1 * 22,12);
			}
			else
			{
				this.apStudHolder_mc.visible = false;
			}
			this.ExtraSlotsDisplaying();
		}
		
		public function calculateBarOffset() : *
		{
			var val1:Number = NaN;
			if(this.apList.size > this.standardAP)
			{
				val1 = this.apList.size - this.standardAP;
				this.apHolder_mc.x = this.originalPosX - Math.floor(val1 * 0.5 * (this.slotWidth + this.apList.EL_SPACING));
				this.apStudHolder_mc.x = this.originalStudX + (this.apHolder_mc.x - this.originalPosX);
			}
			else
			{
				this.apHolder_mc.x = this.originalPosX;
				this.apStudHolder_mc.x = this.originalStudX;
			}
		}
		
		public function setBonusAP(param1:Number) : *
		{
			var val3:MovieClip = null;
			var val2:uint = 0;
			while(val2 < param1)
			{
				if(val2 < this.apList.length)
				{
					val3 = this.apList.getElement(val2);
					if(val3)
					{
						val3.bonus = true;
					}
				}
				val2++;
			}
		}
		
		public function setGreyAP(param1:Number) : *
		{
			var val2:uint = 0;
			while(val2 < this.apList.length)
			{
				if(val2 < param1)
				{
					this.setMCSTate(this.apList.content_array[val2],6);
				}
				else
				{
					this.setMCSTate(this.apList.content_array[val2],0);
					(this.apList.content_array[val2] as MovieClip).bonus = false;
				}
				val2++;
			}
		}
		
		public function addApC(param1:Boolean = false) : *
		{
			var val2:MovieClip = new APUnit();
			var val3:Number = 1;
			val2.gotoAndStop(val3);
			val2.state = val3;
			val2.bonus = param1;
			this.apList.addElement(val2,false);
		}
		
		public function setMCSTate(param1:MovieClip, param2:Number) : *
		{
			if(param1)
			{
				param1.state = param2;
				param1.gotoAndStop(param2);
			}
		}
		
		public function setActiveAp(param1:Number) : *
		{
			var val4:Number = NaN;
			var val5:Number = NaN;
			var val2:uint = 0;
			var val3:Number = param1;
			if(val3 > this.maxAPs)
			{
				val3 = this.maxAPs;
			}
			if(this.apLeft >= param1)
			{
				this.activeAps = this.apLeft - this.maxAPs;
				if(this.activeAps < 0)
				{
					this.activeAps = 0;
				}
				val2 = 0;
				while(val2 < this.apList.length)
				{
					if(val2 < this.apLeft - param1 - this.activeAps)
					{
						val4 = 2;
						if(this.apList.content_array[val2].bonus)
						{
							val4 = 5;
						}
						this.setMCSTate(this.apList.content_array[val2],val4);
					}
					else if(val2 < this.apLeft - this.activeAps)
					{
						this.setMCSTate(this.apList.content_array[val2],3);
					}
					val2++;
				}
			}
			else
			{
				this.activeAps = 0;
				val5 = this.apLeft;
				if(val5 > this.apList.content_array.length - 1)
				{
					val5 = this.apList.content_array.length - 1;
				}
				val2 = 0;
				while(val2 < this.apLeft)
				{
					this.setMCSTate(this.apList.content_array[val2],4);
					val2++;
				}
			}
			this.ExtraSlotsDisplaying();
		}
		
		public function setAvailableAp(param1:Number) : *
		{
			var val3:Number = NaN;
			var val2:uint = 0;
			val2 = 0;
			while(val2 < this.apList.length)
			{
				if(val2 < param1)
				{
					val3 = 2;
					if(this.apList.content_array[val2].bonus)
					{
						val3 = 5;
					}
					this.setMCSTate(this.apList.content_array[val2],val3);
				}
				else
				{
					this.setMCSTate(this.apList.content_array[val2],1);
				}
				val2++;
			}
			this.apLeft = param1;
		}
		
		public function ExtraSlotsDisplaying() : *
		{
			if(this.activeAps > 0)
			{
				this.apOverflow_mc.overflow_txt.htmlText = "+" + this.activeAps;
				this.apOverflow_mc.visible = true;
			}
			else
			{
				this.apOverflow_mc.overflow_txt.htmlText = " ";
				this.apOverflow_mc.visible = false;
			}
		}
		
		public function frame1() : void
		{
			this.maxAPs = 20;
			this.apOverflow_mc.overflow_txt.autoSize = TextFieldAutoSize.LEFT;
			this.standardAP = 6;
			this.totalSlots = 0;
			this.extraApSlots = 0;
			this.extraAps = 0;
			this.activeAps = 0;
			this.apLeft = 0;
			this.slotWidth = 28;
			this.apList = new horizontalList();
			this.apList.EL_SPACING = -2;
			this.apHolder_mc.addChild(this.apList);
			this.apHolder_mc.x = 17;
			this.apStudHolder_mc.x = 7;
			this.apStudHolder_mc.y = 17;
			this.originalPosX = this.apHolder_mc.x;
			this.originalStudX = this.apStudHolder_mc.x;
		}
	}
}
