package LS_Classes
{
	import flash.display.MovieClip;
	import flash.utils.getDefinitionByName;
	
	public class controllerBtnHint extends MovieClip
	{
		 
		
		public var iconHL_mc:MovieClip;
		
		public var icon_mc:MovieClip;
		
		public function controllerBtnHint()
		{
			super();
			this.iconHL_mc = new MovieClip();
			this.icon_mc = new MovieClip();
			addChild(this.icon_mc);
			addChild(this.iconHL_mc);
		}
		
		public function setHintIcon(param1:Number, param2:Boolean = false) : *
		{
			var val5:MovieClip = null;
			var val6:MovieClip = null;
			var val7:Class = null;
			var val8:Class = null;
			var val3:String = controllerHelper.getIconHLClassName(param1,param2);
			var val4:String = controllerHelper.getIconClassName(param1,param2);
			if(!val5 && val4 != "")
			{
				val7 = getDefinitionByName(val4) as Class;
				val5 = new val7();
			}
			if(val5)
			{
				this.icon_mc.addChild(val5);
			}
			if(!val6 && val3 != "")
			{
				val8 = getDefinitionByName(val3) as Class;
				val6 = new val8();
			}
			if(val6)
			{
				this.iconHL_mc.addChild(val6);
			}
			this.iconHL_mc.visible = false;
		}
	}
}
