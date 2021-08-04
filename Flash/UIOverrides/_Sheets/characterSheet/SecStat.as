package
{
	import LS_Classes.larTween;
	import LS_Classes.textHelpers;
	import fl.motion.easing.Quartic;
	import flash.display.MovieClip;
	import flash.events.FocusEvent;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextField;
	
	public dynamic class SecStat extends MovieClip
	{
		public var editText_txt:TextField;
		public var hl_mc:MovieClip;
		public var icon_mc:MovieClip;
		public var minus_mc:MovieClip;
		public var mod_txt:TextField;
		public var plus_mc:MovieClip;
		public var texts_mc:MovieClip;
		public var timeline:larTween;
		public var base:MovieClip;
		public var boostValue:Number;

		//LeaderLib Changes
		public var statID:Number;
		public var tooltip:Number; // The tooltip ID
		public var callbackStr:String = "showStatTooltip";
		public var isCustom:Boolean = false;

		public function MakeCustom(statID:Number, b:Boolean=true) : *
		{
			this.statID = statID;
			this.isCustom = b;
			if(b)
			{
				this.callbackStr = "showStatTooltipCustom";
				this.minus_mc.callbackStr = "minusSecStatCustom";
				this.plus_mc.callbackStr = "plusSecStatCustom";
			}
			else
			{
				this.callbackStr = "showStatTooltip";
				this.minus_mc.callbackStr = "minusSecStat";
				this.plus_mc.callbackStr = "plusSecStat";
			}
		}
		
		public function SecStat()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setupButtons(param1:Boolean, minusVisible:Boolean, plusVisible:Boolean, maxChars:Number = 5) : void
		{
			if(minusVisible || plusVisible)
			{
				this.hl_mc.addEventListener(MouseEvent.MOUSE_DOWN,this.onTextPress);
				textHelpers.makeInputFieldModal(this.editText_txt);
				this.editText_txt.restrict = "0-9\\-";
				this.editText_txt.maxChars = maxChars;
				this.mod_txt.htmlText = "%";
				this.mod_txt.width = 32;
			}
			else
			{
				this.hl_mc.removeEventListener(MouseEvent.MOUSE_DOWN,this.onTextPress);
			}
			this.minus_mc.visible = minusVisible;
			this.plus_mc.visible = plusVisible;
			if(param1)
			{
				this.plus_mc.x = 242;
				this.hl_mc.width = 264;
			}
			else
			{
				this.plus_mc.x = this.minus_mc.x + this.minus_mc.width;
				this.hl_mc.width = 248;
			}
			this.widthOverride = this.hl_mc.width;
		}
		
		public function onTextPress(e:MouseEvent) : void
		{
			var val2:Number = NaN;
			if((this.minus_mc.visible || this.plus_mc.visible) && stage.focus == null)
			{
				this.editText_txt.visible = true;
				this.editText_txt.border = true;
				this.texts_mc.text_txt.visible = false;
				this.editText_txt.htmlText = String(this.boostValue);
				val2 = this.plus_mc.x - this.minus_mc.x - this.minus_mc.width;
				if(val2 > 0)
				{
					this.editText_txt.width = val2 - 4;
					this.editText_txt.x = this.minus_mc.x + this.minus_mc.width * 2 + 2;
				}
				else
				{
					this.editText_txt.width = 64;
					this.editText_txt.x = this.plus_mc.x + this.minus_mc.width * 2 + 2;
				}
				if(this.texts_mc.text_txt.text.indexOf("-") >= 0 || this.texts_mc.text_txt.text.indexOf("%") >= 0)
				{
					this.editText_txt.width = this.editText_txt.width - 16;
					this.mod_txt.visible = true;
					this.mod_txt.x = this.editText_txt.x + this.editText_txt.width - 2;
				}
				else
				{
					this.mod_txt.visible = false;
				}
				stage.focus = this.editText_txt;
				this.editText_txt.addEventListener(FocusEvent.FOCUS_OUT,this.onValueAccept);
			}
			else
			{
				stage.focus = null;
			}
		}
		
		public function onValueAccept(e:FocusEvent) : void
		{
			this.editText_txt.removeEventListener(FocusEvent.FOCUS_OUT,this.onValueAccept);
			this.editText_txt.visible = false;
			this.texts_mc.text_txt.visible = true;
			if(this.statID != null)
			{
				!isCustom ? ExternalInterface.call("changeSecStat",this.statID,int(this.editText_txt.text)) : ExternalInterface.call("changeSecStatCustom",this.statID,int(this.editText_txt.text));
			}
		}
		
		public function onOver(e:MouseEvent) : *
		{
			this.widthOverride = 269;
			!isCustom ? this.base.showCustomTooltipForMC(this, this.callbackStr, this.tooltip) : this.base.showCustomTooltipForMC(this, this.callbackStr, this.statID);
			if(this.timeline && this.timeline.isPlaying)
			{
				this.timeline.stop();
			}
			this.timeline = new larTween(this.hl_mc,"alpha",Quartic.easeIn,this.hl_mc.alpha,1,0.01);
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			this.timeline = new larTween(this.hl_mc,"alpha",Quartic.easeOut,this.hl_mc.alpha,0,0.01,this.hlInvis);
			this.base.hasTooltip = false;
			ExternalInterface.call("hideTooltip");
		}
		
		public function hlInvis() : *
		{
		}
		
		function frame1() : *
		{
			this.base = root as MovieClip;
			this.hl_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.hl_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.hl_mc.alpha = 0;
			// this.minus_mc.callbackStr = "minusSecStat";
			// this.plus_mc.callbackStr = "plusSecStat";
		}
	}
}
