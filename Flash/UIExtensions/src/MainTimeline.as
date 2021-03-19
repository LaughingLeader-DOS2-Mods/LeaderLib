package
{
	import fl.motion.Color;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import Controls.*;
	
	public dynamic class MainTimeline extends MovieClip
	{		
		public var layout:String;
		public var events:Array;
		public var mainPanel_mc:MovieClip;
		
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
		
		public function addCheckbox(id:Number, label:String, tooltip:String, stateID:Number=0, x:Number=0, y:Number=0, filterBool:Boolean = false, enabled:Boolean = true) : MovieClip
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
			if(enabled == false)
			{
				checkbox.alpha = 0.3;
			}
			mainPanel_mc.list.addElement(checkbox);
			checkbox.formHL_mc.alpha = 0;
			ExternalInterface.call("LeaderLib_ControlAdded", "checkbox", checkbox.id);

			return checkbox
		}
		
		function frame1() : *
		{
			this.layout = "fixed";
			this.events = new Array();
		}
	}
}