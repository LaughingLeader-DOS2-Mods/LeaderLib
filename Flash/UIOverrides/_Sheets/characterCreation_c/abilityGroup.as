package
{
	import LS_Classes.listDisplay;
	import LS_Classes.scrollList;
	import LS_Classes.scrollbar;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	
	public dynamic class abilityGroup extends MovieClip
	{
		public var hit_mc:MovieClip;
		public var listContainer_mc:empty;
		public var title_txt:TextField;
		public var root_mc:MovieClip;
		public var abilityList:listDisplay;
		public const elementHeight:uint = 44;
		
		public function abilityGroup()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(param1:MovieClip) : *
		{
			this.root_mc = param1;
			this.abilityList = new listDisplay();
			this.listContainer_mc.addChild(this.abilityList);
			this.title_txt.autoSize = TextFieldAutoSize.CENTER;
		}
		
		public function setTitle(param1:String, param2:Boolean) : *
		{
			this.title_txt.htmlText = !!param2?param1.toUpperCase():param1;
		}
		
		public function get length() : Number
		{
			return this.abilityList.length;
		}
		
		public function get currentIdx() : Number
		{
			return this.abilityList.currentSelection;
		}
		
		public function selectElement(param1:Number, param2:Boolean = false) : *
		{
			this.abilityList.select(param1,param2);
		}
		
		public function clear() : *
		{
			this.abilityList.clearSelection();
		}
		
		public function next() : Boolean
		{
			var val1:uint = this.abilityList.currentSelection;
			this.abilityList.next();
			return val1 != this.abilityList.currentSelection;
		}
		
		public function previous() : Boolean
		{
			var val1:uint = this.abilityList.currentSelection;
			this.abilityList.previous();
			return val1 != this.abilityList.currentSelection;
		}
		
		public function keepIntoView(param1:Boolean) : *
		{
			var val6:* = undefined;
			var val2:scrollList = this.abilityList.parent.parent.parent.parent.parent as scrollList;
			var val3:scrollbar = val2.m_scrollbar_mc;
			var val4:MovieClip = this.abilityList.getCurrentMovieClip();
			var val5:* = this.y + this.listContainer_mc.y + val4.y;
			if(param1)
			{
				if(val5 - this.elementHeight <= val3.scrolledY)
				{
					val3.scrollIntoView(val5 - this.elementHeight,this.elementHeight);
				}
			}
			else
			{
				val6 = this.elementHeight * (val4.list_pos == 0?3:2);
				if(val5 + val6 >= val3.scrolledY + 636)
				{
					val3.scrollIntoView(val5,this.elementHeight * 2);
				}
			}
		}
		
		public function selectFirst() : *
		{
			this.abilityList.select(0,true);
			var val1:scrollList = this.abilityList.parent.parent.parent.parent.parent as scrollList;
			var val2:scrollbar = val1.m_scrollbar_mc;
			val2.scrollIntoView(0,this.elementHeight);
		}
		
		public function selectLast() : *
		{
			this.abilityList.selectLastElement();
			var val1:MovieClip = this.abilityList.getCurrentMovieClip();
			var val2:* = this.y + this.listContainer_mc.y + val1.y;
			var val3:scrollList = this.abilityList.parent.parent.parent.parent.parent as scrollList;
			var val4:scrollbar = val3.m_scrollbar_mc;
			val4.scrollIntoView(0,this.elementHeight);
			val4.scrollIntoView(val2,this.elementHeight * 2);
		}
		
		public function addAbility(abilityID:uint, label:String, value:int, delta:int) : *
		{
			var ability_mc:MovieClip = this.abilityList.getElementByNumber("abilityID",abilityID);
			if(!ability_mc)
			{
				ability_mc = new abilEntry();
				ability_mc.onInit(this.root_mc);
				this.abilityList.addElement(ability_mc,false);
				ability_mc.abilityID = abilityID;
				ability_mc.isCivil = this.isCivil;
			}
			ability_mc.setAbility(label,value,delta);
			ability_mc.bg_mc.gotoAndStop(1);
			ability_mc.isUpdated = true;
		}

		public function addCustomAbility(customID:String, label:String, value:int, delta:int) : *
		{
			var ability_mc:MovieClip = this.abilities.getElementByString("customID",customID);
			if(!ability_mc)
			{
				ability_mc = new abilEntry();
				ability_mc.onInit(this.root_mc);
				this.abilityList.addElement(ability_mc,false);
				ability_mc.customID = customID;
				ability_mc.isCustom = true;
				ability_mc.isCivil = this.isCivil;
			}
			ability_mc.setAbility(label,value,delta);
			ability_mc.bg_mc.gotoAndStop(1);
			ability_mc.isUpdated = true;
		}
		
		public function positionElements() : *
		{
			this.abilityList.cleanUpElements();
			this.abilityList.getLastVisible().bg_mc.gotoAndStop(2);
		}
		
		function frame1() : *
		{
		}
	}
}
