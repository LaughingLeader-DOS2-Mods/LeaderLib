package
{
	import LS_Classes.tooltipHelper;

	import controls.buttons.SkipTutorialButton;
	import controls.buttons.PresetButton;

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	public class MainTimeline extends MovieClip
	{		
		//Engine variables
		public var layout:String = "fitVertical";
		public var alignment:String = "none";
		public var anchorId:String = "LeaderLib_CharacterCreationExtensions";
		public var anchorPos:String = "center";
		public var anchorTPos:String = "center";
		public var anchorTarget:String = "screen";
		public var uiScaling:Number = 1.0;

		public const designResolution:Point = new Point(2120,1080);
		public const fixedContentSize:Point = new Point(300,150);
		
	  	public var isDragging:Boolean;
		public var curTooltip:String;
	  	public var hasTooltip:Boolean;
	  	public var tooltipWidthOverride:Number = 0;

		public var screenWidth:Number = 0;
		public var screenHeight:Number = 0;

		private static var instance:MainTimeline;
		public var skipTutorial_mc:SkipTutorialButton;
		public var presetButton_mc:PresetButton;
		
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
		
		public function onEventInit() : void
		{
			Registry.ExtCall("registeranchorId", this.anchorId);
			Registry.ExtCall("setAnchor",this.anchorPos, this.anchorTarget, this.anchorTPos);

			this.presetButton_mc.init();
			this.skipTutorial_mc.init();
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

		public function togglePresetButton(b:Boolean, destroyEntries:Boolean = false): void
		{
			this.presetButton_mc.visible = b;
			this.presetButton_mc.isEnabled = b;
			if(destroyEntries) {
				this.presetButton_mc.combo_mc.removeAll();
			}
		}
		
		public function frame1() : void
		{
			this.curTooltip = "";
		 	this.hasTooltip = false;
		}
	}
}