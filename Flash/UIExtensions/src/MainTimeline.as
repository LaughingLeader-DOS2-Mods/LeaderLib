package
{
	import fl.motion.Color;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import Controls.Checkbox;
	
	public dynamic class MainTimeline extends MovieClip
	{		
		public var layout:String;
		public var events:Array;
		public var mainPanel_mc:MovieClip;
		
		public var curTooltip:String;
      	public var hasTooltip:Boolean;
		
		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onEventUp(id:Number) : *
		{
			return false;
		}
		
		public function onEventDown(id:Number) : Boolean
		{
			// var isHandled:Boolean = false;
			// switch(this.events[id])
			// {
			//	case "IE UIUp":
			//		isHandled = true;
			//		break;
			//	case "IE UIDown":
			//		isHandled = true;
			//		break;
			//	case "IE UICancel":
			//		isHandled = true;
			// }
			// return isHandled;
			return false;
		}
		
		public function onEventInit() : *
		{
			ExternalInterface.call("registeranchorId","LeaderLib_UIExtensions");
			ExternalInterface.call("setAnchor","center","screen","center");
		}

		public function removeControl(id:Number): Boolean
		{
			return mainPanel_mc.list.removeElementByListId(id);
		}
		
		public function addCheckbox(id:Number, label:String, tooltip:String, stateID:Number=0, x:Number=0, y:Number=0, filterBool:Boolean = false, enabled:Boolean = true) : *
		{
			var checkbox:MovieClip = new Checkbox();
			checkbox.x = x;
			checkbox.y = y;
			checkbox.label_txt.htmlText = label;
			checkbox.id = id;
			checkbox.mHeight = 30;
			checkbox.filterBool = filterBool;
			checkbox.stateID = stateID;
			checkbox.tooltip = tooltip;
			checkbox.bg_mc.gotoAndStop(stateID * 3 + 1);
			checkbox.enable = enabled;
			//checkbox.label_txt.width = checkbox.label_txt.textWidth;
			if(enabled == false)
			{
				checkbox.alpha = 0.3;
			}
			//mainPanel_mc.list.addElement(checkbox);
			mainPanel_mc.addElement(checkbox);
			checkbox.label_bg_mc.width = checkbox.label_txt.textWidth * 2
			//this.mainPanel_mc.addChild(checkbox);
			//checkbox.formHL_mc.alpha = 0;
			ExternalInterface.call("LeaderLib_ControlAdded", "checkbox", checkbox.id, id, checkbox.label_txt.textWidth, checkbox.label_txt.width, checkbox.label_bg_mc.width);
		}

		public function clearElements() : * 
		{
			//mainPanel_mc.list.clearElements();
			mainPanel_mc.clearElements();
		}
		
		function frame1() : *
		{
			this.layout = "fixed";
			this.events = new Array("IE UIUp","IE UIDown","IE UICancel");
			this.curTooltip = "";
         	this.hasTooltip = false;
		}
	}
}