package
{
	import LS_Classes.selector;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	//LeaderLib Changes: Changed calls to ll equivalents
	public dynamic class SelectorMC extends MovieClip
	{
		public var cont_mc:emptyBG;
		public var formHL_mc:MovieClip;
		public var hl_mc:MovieClip;
		public var label_txt:TextField;
		public var left_mc:MovieClip;
		public var right_mc:MovieClip;
		public var biggestWidth:Number;
		public var selList:selector;
		public var timeOut:Number;
		public var scrollRight:Boolean;
		public var base:MovieClip;
		public const arrowSpacing:Number = 38;
		
		public function SelectorMC()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onChange(param1:Event) : *
		{
			ExternalInterface.call("PlaySound","UI_Generic_Slider");
			if(this.isCheckBox)
			{
				ExternalInterface.call("llcheckBoxID",this.id,this.selList.currentSelection);
			}
			else
			{
				ExternalInterface.call("llcomboBoxID",this.id,this.selList.currentSelection);
			}
		}
		
		public function deselectElement() : *
		{
			var val1:MovieClip = null;
			this.hl_mc.visible = false;
			this.left_mc.visible = false;
			this.right_mc.visible = false;
			if(this.selList)
			{
				val1 = this.selList.getCurrentMovieClip();
				if(val1)
				{
					val1.stopScrolling();
				}
				this.stopScrolling();
			}
			if(this.onOut)
			{
				this.onOut();
			}
		}
		
		public function selectElement() : *
		{
			ExternalInterface.call("PlaySound","UI_Generic_Over");
			this.hl_mc.visible = true;
			this.left_mc.visible = true;
			this.right_mc.visible = true;
			var val1:MovieClip = this.selList.getCurrentMovieClip();
			if(val1)
			{
				val1.checkScrolling();
			}
			this.checkLabelScrolling();
			if(this.onOver)
			{
				this.onOver(this);
			}
		}
		
		public function checkLabelScrolling() : *
		{
			if(this.label_txt.width < this.label_txt.textWidth)
			{
				addEventListener(Event.ENTER_FRAME,this.onFrameScroll);
			}
		}
		
		public function onFrameScroll(param1:Event) : *
		{
			if(this.timeOut > 0 && this.timeOut < 100)
			{
				this.timeOut++;
			}
			else if(this.scrollRight)
			{
				if(this.label_txt.scrollH >= this.label_txt.maxScrollH)
				{
					this.scrollRight = false;
					this.timeOut = 1;
				}
				else
				{
					this.label_txt.scrollH++;
				}
			}
			else if(this.label_txt.scrollH <= 0)
			{
				this.timeOut = 1;
				this.scrollRight = true;
			}
			else
			{
				this.label_txt.scrollH--;
			}
		}
		
		public function stopScrolling() : *
		{
			removeEventListener(Event.ENTER_FRAME,this.onFrameScroll);
			this.label_txt.scrollH = 0;
			this.timeOut = 1;
			this.scrollRight = true;
		}
		
		public function onMouseOver(param1:MouseEvent = null) : *
		{
			this.base.mainMenu_mc.setCursorPosition(this.id);
			if(this.tooltip != null && this.tooltip != "")
			{
				this.base.curTooltip = this.pos;
				ExternalInterface.call("showItemTooltip",this.tooltip);
				this.base.hasTooltip = true;
			}
		}
		
		public function onMouseOut(param1:MouseEvent = null) : *
		{
			if(this.base.curTooltip == this.pos && this.base.hasTooltip)
			{
				ExternalInterface.call("hideTooltip");
				this.base.hasTooltip = false;
			}
			this.base.curTooltip = -1;
		}
		
		public function AddElement(param1:MovieClip) : *
		{
			this.selList.addElement(param1,false);
			this.cont_mc.x = this.right_mc.x - this.selList.frameWidth - this.arrowSpacing;
			this.left_mc.x = this.cont_mc.x - this.arrowSpacing;
			this.label_txt.width = this.left_mc.x - this.label_txt.x - this.arrowSpacing * 2;
		}
		
		public function handleEvent(param1:String, param2:Boolean) : Boolean
		{
			var val3:Boolean = false;
			switch(param1)
			{
				case "IE UILeft":
					if(param2 && this.enabled != false)
					{
						this.selList.previous();
						ExternalInterface.call("PlaySound","UI_Generic_Click");
					}
					val3 = true;
					break;
				case "IE UIRight":
					if(param2 && this.enabled != false)
					{
						this.selList.next();
						ExternalInterface.call("PlaySound","UI_Generic_Click");
					}
					val3 = true;
			}
			return val3;
		}
		
		function frame1() : *
		{
			this.selList.addEventListener(Event.CHANGE,this.onChange);
			this.selList.m_cyclic = true;
			this.timeOut = 1;
			this.scrollRight = true;
			this.base = root as MovieClip;
		}
	}
}
