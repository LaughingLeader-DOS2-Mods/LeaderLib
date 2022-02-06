package
{
	import controls.*;
	import LS_Classes.tooltipHelper;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;

	import interfaces.IInputHandler;

	import system.HotbarManager;
	
	public class MainTimeline extends MovieClip
	{		
		private static var instance:MainTimeline;
		//Engine variables
		public var layout:String = "fixed";
		//public var alignment:String;
		public var events:Array;
		public var anchorId:String = "LeaderLib_HotbarExtension";
		public var anchorPos:String = "bottom";
		public var anchorTPos:String = "bottom";
		public var anchorTarget:String = "screen";
		public var uiScaling:Number = 1.0;

		public const designResolution:Point = new Point(1940,1000);

		public var hotbars_mc:HotbarManager;
		//public var screenScaleHelper:MovieClip;
		
		public var curTooltip:String;
	  	public var hasTooltip:Boolean;
	  	public var tooltipWidthOverride:Number = 0;

		public var screenWidth:Number = 0;
		public var screenHeight:Number = 0;

		public var inputHandlers:Array;

		public var isDragging:Boolean = false;

		public const baseBarWidth:uint = 317;
		public const visualSlotWidth:uint = 55;
		public const barStopWidth:uint = 17;
		
		public function MainTimeline()
		{
			super();
			Registry.Init();
			instance = this;
			this.addFrameScript(0,this.frame1);
		}

		public static function get Instance():MainTimeline
		{
			return instance;
		}

		public function addInputHandler(obj:IInputHandler) : void
		{
			this.inputHandlers.push(obj);
		}

		public function removeInputHandler(obj:IInputHandler) : void
		{
			var index:int = 0;
			while(index < this.inputHandlers.length)
			{
				if(this.inputHandlers[index] == obj)
				{
					this.inputHandlers.splice(index, 1);
				}
				index++;
			}
		}

		public function invokeInputCallbacks(inputId:String, isUp:Boolean = false) : Boolean
		{
			var isHandled:Boolean = false;
			var handler:IInputHandler = null;
			for(var i:int = 0; i < this.inputHandlers.length; i++)
			{
				handler = this.inputHandlers[i] as IInputHandler;
				if (handler && handler.IsInputEnabled) {
					if (!isUp) {
						if (handler.OnInputDown(inputId)) {
							isHandled = true;
							break;
						}
					} else {
						if (handler.OnInputUp(inputId)) {
							isHandled = true;
							break;
						}
					}
				}
			}
			return isHandled;
		}
		
		public function onEventUp(id:Number) : Boolean
		{
			var isHandled:Boolean = false;
			var input:String = this.events[id];
			if (input != null)
			{
				isHandled = this.invokeInputCallbacks(input, true);
			}

			return isHandled;
		}
		
		public function onEventDown(id:Number) : Boolean
		{
			var isHandled:Boolean = false;
			var input:String = this.events[id];
			if (input != null)
			{
				isHandled = this.invokeInputCallbacks(input, true);
			}

			return isHandled;
		}
		
		public function onEventInit() : void
		{
			Registry.ExtCall("registeranchorId", this.anchorId);
			Registry.ExtCall("setAnchor",this.anchorPos, this.anchorTarget, this.anchorTPos);
		}

		public function onEventResolution(w:Number, h:Number) : void
		{
			w = w / this.uiScaling;
			h = h / this.uiScaling;
			var sizeDiff:uint = Math.floor(w / h * (this.designResolution.y / this.uiScaling));
			this.hotbars_mc.onResize(w,h,sizeDiff);
		}

		public function setHasTooltip(isEnabled:Boolean, text:String = "") : void
		{
			this.hasTooltip = isEnabled;
			this.curTooltip = text;
		}

		private function onMouseOverTooltip(e:MouseEvent) : void
		{
			var obj:MovieClip = e.target as MovieClip;
			if(obj.tooltip != null && obj.tooltip != "")
			{
				obj.tooltipOverrideW = this.tooltipWidthOverride;
				obj.tooltipYOffset = -4;
				tooltipHelper.ShowTooltipForMC(obj,this,"bottom",this.hasTooltip == false);
				MainTimeline.Instance.setHasTooltip(true, obj.tooltip);
			}
		}

		public function onMouseOutTooltip(e:MouseEvent) : void
		{
			if(this.curTooltip == e.target.tooltip && this.hasTooltip)
			{
				Registry.ExtCall("hideTooltip");
			}
			MainTimeline.Instance.setHasTooltip(false);
		}

		private function setupControlForTooltip(obj:MovieClip) : void
		{
			obj.addEventListener(MouseEvent.MOUSE_OVER, this.onMouseOverTooltip);
			obj.addEventListener(MouseEvent.MOUSE_OUT, this.onMouseOutTooltip);
		}
		
		public function frame1() : void
		{
			this.inputHandlers = new Array();

			this.screenWidth = this.width;
			this.screenHeight = this.height;

			this.hotbars_mc = new HotbarManager();
			this.addChild(this.hotbars_mc);

			this.events = new Array("IE UISelectSlot1","IE UISelectSlot2","IE UISelectSlot3","IE UISelectSlot4","IE UISelectSlot5","IE UISelectSlot6","IE UISelectSlot7","IE UISelectSlot8","IE UISelectSlot9","IE UISelectSlot0","IE UISelectSlot11","IE UISelectSlot12","IE UIHotBarPrev","IE UIHotBarNext","IE UIToggleActions");

			if (Capabilities.isDebugger) {
				this.hotbars_mc.add(1, 20, 30);
				this.hotbars_mc.add(2, 20, 100);
				this.hotbars_mc.add(3, 20, 170);
			}
		}
	}
}