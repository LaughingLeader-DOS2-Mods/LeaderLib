package tooltip_fla
{
	import LS_Classes.larTween;
	import fl.motion.easing.Cubic;
	import fl.motion.easing.Sine;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.external.ExternalInterface;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	
	public dynamic class MainTimeline extends MovieClip
	{
		public var tooltip_mc:MovieClip;
		public var events:Array;
		public var layout:String;
		public var cachedStickToMouse:Number;
		public const cEquippedSpacing:Number = 21;
		public var ComparePaneOffset:Number;
		public var ComparePaneOffset2:Number;
		public var ComparePaneOffset3:Number;
		public const desWidth:Number = 1920;
		public const desHeight:Number = 1080;
		public var frame_width:Number;
		public var frame_height:Number;
		public const frameSpacing:Number = 10;
		public var tf:MovieClip;
		public var ctf:MovieClip;
		public var ohctf:MovieClip;
		public const glMaxTooltipWidth:Number = 400;
		public const ydispForCompareheader:Number = 18;
		public var offsetX:Number;
		public var offsetY:Number;
		public const textColour:uint = 16777215;
		public const bgColour:uint = 0;
		public var compareShowTimer:Timer;
		public var compareMode:Boolean;
		public var tooltipModeTimer:Timer;
		public var tooltip_array:Array;
		public var tooltipCompare_array:Array;
		public var tooltipOffHand_array:Array;
		public var formatTooltip:tooltipFormattedMC;
		public var compareTooltip:ItemCompareTooltip;
		public var offhandTooltip:ItemCompareTooltip;
		public var defaultTooltip:MovieClip;
		public var statusTooltip:MovieClip;
		public var NormalTooltip:Boolean;
		public var isStatusTT:Boolean;
		public const tweenInTime:Number = 0.09;
		public var tooltipAlignmentLeft:Boolean;
		
		public function MainTimeline()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function setGroupLabel(param1:Number, param2:String) : void
		{
			this.formatTooltip.tooltip_mc.setGroupLabel(param1,param2);
			this.compareTooltip.tooltip_mc.setGroupLabel(param1,param2);
			this.offhandTooltip.tooltip_mc.setGroupLabel(param1,param2);
		}
		
		public function setWindow(param1:Number, param2:Number) : *
		{
			var val3:Number = param1 / param2;
			var val4:Number = this.desWidth;
			var val5:Number = this.desHeight;
			if(val3 > 1.7)
			{
				val5 = this.desWidth / param1 * param2;
			}
			else
			{
				val4 = this.desHeight / param2 * param1;
			}
			this.frame_width = val4;
			this.frame_height = val5;
			this.checkTooltipBoundaries(this.getTooltipWidth(),this.getTooltipHeight(),stage.mouseX + this.frameSpacing,stage.mouseY + this.frameSpacing);
		}
		
		public function onEventInit() : *
		{
			this.cachedStickToMouse = 0;
			ExternalInterface.call("registerAnchorId","tooltip");
		}
		
		public function onEventResize() : *
		{
		}
		
		public function strReplace(param1:String, param2:String, param3:String) : String
		{
			return param1.split(param2).join(param3);
		}
		
		public function traceArray(param1:Array) : *
		{
			var val2:String = "";
			var val3:* = "new Array(";
			var val4:uint = 0;
			while(val4 < param1.length)
			{
				val3 = val3 + (val2 + param1[val4] + "");
				val2 = ",";
				val4++;
			}
			val3 = val3 + ");";
		}
		
		public function addFormattedTooltip(xPos:Number = 0, yPos:Number = 18, deferShow:Boolean = true) : *
		{
			if(this.tooltip_array.length <= 0)
			{
				return;
			}
			if(this.tf)
			{
				this.INTRemoveTooltip();
			}
			var val4:Number = 1;
			if(this.tf == null)
			{
				this.tf = this.formatTooltip;
			}
			this.tf.visible = false;
			this.tf.scaleX = this.tf.scaleY = val4;
			this.tooltip_mc.tt_mc.x = 0;
			if(this.tooltipCompare_array.length > 0)
			{
				this.addCompareTooltip(this.tooltipCompare_array);
				this.tooltipCompare_array = new Array();
			}
			else
			{
				this.tooltip_mc.tt_mc.targetX = 0;
			}
			if(this.tooltipOffHand_array.length > 0)
			{
				this.addCompareOffhandTooltip(this.tooltipOffHand_array);
				this.tooltipOffHand_array = new Array();
			}
			this.tooltip_mc.tt_mc.addChild(this.tf);
			this.tf.tooltip_mc.setupTooltip(this.tooltip_array,20);
			this.tf.alpha = 0;
			this.tf.tooltip_mc.y = !!this.tf.tooltip_mc.isEquipped?0:this.cEquippedSpacing;
			this.tooltip_array = new Array();
			this.tooltip_mc.ttX = xPos;
			this.tooltip_mc.ttY = yPos;
			this.tf.widthOverride = -1;
			this.checkTooltipBoundaries(this.getTooltipWidth(),this.getTooltipHeight(),xPos + this.frameSpacing,yPos + this.frameSpacing);
			if(!this.compareMode || !deferShow)
			{
				this.INTshowTooltip();
			}
		}
		
		public function addStatusTooltip(param1:Number = 0, param2:Number = 0) : *
		{
			if(!this.isStatusTT)
			{
				/* var i:uint = 0;
				while (i < this.tooltip_array.length)
				{
					trace(i, this.tooltip_array[i]);
					i++;
				} */
				this.addFormattedTooltip(param1,param2,false);
				this.isStatusTT = true;
			}
			this.tooltip_array = new Array();
		}
		
		public function addTooltip(text:String, widthOverride:Number = 0, heightOverride:Number = 18, allowDelay:Boolean = true, stickToMouse:Number = 0, bgType:uint = 0) : *
		{
			//trace("[addTooltip]", text);
			if(text == "")
			{
				return;
			}
			if(this.tf && this.tf.shortDesc == text)
			{
				return;
			}
			this.NormalTooltip = true;
			text = this.strReplace(text,"<bp>","<img src=\'Icon_BulletPoint\'>");
			text = this.strReplace(text,"<line>","<img src=\'Icon_Line\'>");
			text = this.strReplace(text,"<shortLine>","<img src=\'Icon_Line\' width=\'85%\'>");
			var val7:Boolean = true;
			var val8:Number = 1;
			if(this.tf && this.tf != this.defaultTooltip)
			{
				this.INTRemoveTooltip();
			}
			if(this.tf == null)
			{
				this.tf = this.defaultTooltip;
				this.tf.text_txt.htmlText = "";
				this.tf.text_txt.wordWrap = false;
				this.tf.text_txt.width = 10;
			}
			this.tf.allowDelay = allowDelay;
			this.tf.visible = false;
			this.tf.scaleX = this.tf.scaleY = val8;
			this.tf.text_txt.textColor = this.textColour;
			this.tf.text_txt.autoSize = TextFieldAutoSize.LEFT;
			this.tf.shortDesc = text;
			this.tf.setText(text,bgType);
			this.tooltip_mc.tt_mc.addChild(this.tf);
			this.tooltip_mc.tt_mc.targetX = this.tooltip_mc.tt_mc.x = 0;
			if(stickToMouse == 0)
			{
				this.checkTooltipBoundaries(this.getTooltipWidth(),this.getTooltipHeight(),widthOverride + this.frameSpacing,heightOverride + this.frameSpacing);
			}
			if(!(!this.compareMode && allowDelay || this.cachedStickToMouse != stickToMouse && stickToMouse != 0))
			{
				this.INTshowTooltip();
			}
			if(stickToMouse > 0 && stickToMouse < 5)
			{
				ExternalInterface.call("keepUIinScreen",true);
			}
			else
			{
				ExternalInterface.call("keepUIinScreen",false);
			}
			if(this.cachedStickToMouse != stickToMouse)
			{
				this.cachedStickToMouse = stickToMouse;
				switch(stickToMouse)
				{
					case 0:
						break;
					case 1:
						ExternalInterface.call("setAnchor","topleft","mouse","bottomright");
						break;
					case 2:
						ExternalInterface.call("setAnchor","topright","mouse","bottomleft");
						break;
					case 3:
						ExternalInterface.call("setAnchor","bottomleft","mouse","bottomleft");
						break;
					case 4:
						ExternalInterface.call("setAnchor","bottomright","mouse","bottomleft");
				}
			}
		}
		
		public function swapCompare() : *
		{
			this.setCompare(true);
		}
		
		public function showFormattedTooltipAfterPos(param1:Boolean) : *
		{
			this.setCompare(param1);
			this.INTshowTooltip();
		}
		
		public function setCompare(param1:Boolean) : *
		{
			this.tooltipAlignmentLeft = param1;
			if(this.ctf)
			{
				if(param1)
				{
					if(this.ohctf)
					{
						this.tooltip_mc.tt_mc.targetX = this.ComparePaneOffset2;
						this.tooltip_mc.tt_mc.x = this.tooltip_mc.tt_mc.targetX;
					}
					else
					{
						this.tooltip_mc.tt_mc.targetX = this.ComparePaneOffset;
						this.tooltip_mc.tt_mc.x = this.tooltip_mc.tt_mc.targetX;
					}
					this.tooltip_mc.comp_mc.x = 0;
				}
				else
				{
					this.tooltip_mc.tt_mc.targetX = this.tooltip_mc.tt_mc.x = 0;
					this.tooltip_mc.comp_mc.x = this.ComparePaneOffset;
				}
			}
		}
		
		public function addCompareTooltip(param1:Array, param2:Number = 0, param3:Number = 18) : *
		{
			var val4:Boolean = true;
			if(this.ctf)
			{
				this.ctf.tooltip_mc.clear();
				this.tooltip_mc.comp_mc.removeChild(this.ctf);
				this.tooltip_mc.comp_mc.x = 0;
				this.ctf = null;
			}
			if(this.ctf == null)
			{
				this.ctf = this.compareTooltip;
			}
			this.ctf.visible = false;
			if(this.tf)
			{
				this.tf.x = 0;
				this.tf.y = 0;
				this.tooltip_mc.tt_mc.addChild(this.tf);
				this.tooltip_mc.tt_mc.targetX = this.tooltip_mc.tt_mc.x = 0;
			}
			this.tooltip_mc.comp_mc.addChild(this.ctf);
			this.ctf.tooltip_mc.setupTooltip(param1);
			this.ctf.tooltip_mc.alpha = 0;
			this.ctf.tooltip_mc.y = !!this.ctf.tooltip_mc.isEquipped?0:this.cEquippedSpacing;
			this.tooltip_mc.comp_mc.x = this.ComparePaneOffset;
		}
		
		public function addCompareOffhandTooltip(param1:Array, param2:Number = 0, param3:Number = 18) : *
		{
			var val4:Boolean = false;
			if(this.ctf)
			{
				val4 = true;
				if(this.ohctf)
				{
					this.ohctf.tooltip_mc.clear();
					this.ctf.offhand_mc.removeChild(this.ohctf);
				}
				if(this.ohctf == null)
				{
					this.ohctf = this.offhandTooltip;
					this.ctf.offhand_mc.addChild(this.ohctf);
					this.ctf.offhand_mc.x = this.ComparePaneOffset;
				}
				this.ohctf.visible = false;
				this.ohctf.tooltip_mc.setupTooltip(param1);
				this.ohctf.tooltip_mc.alpha = 0;
				this.ohctf.tooltip_mc.y = !!this.ohctf.tooltip_mc.isEquipped?0:this.cEquippedSpacing;
			}
			else
			{
				this.addCompareTooltip(param1,param2,param3);
			}
		}
		
		public function INTshowTooltip() : *
		{
			var delay:* = undefined;
			if(this.tf)
			{
				delay = !!this.tf.allowDelay?0.5:0;
				this.tf.visible = true;
				if(this.tf.tw)
				{
					this.tf.tw.stop();
				}
				if(this.tf.alpha < 1)
				{
					this.tf.tw = new larTween(this.tf,"alpha",Cubic.easeOut,NaN,1,this.tweenInTime,null,null,delay);
				}
			}
			if(this.ctf)
			{
				this.ctf.visible = false;
				this.compareShowTimer.reset();
				this.compareShowTimer.start();
			}
			if(this.ohctf)
			{
				this.ohctf.visible = false;
			}
			this.compareMode = true;
			this.tooltipModeTimer.stop();
		}
		
		public function onShowCompareTooltip(param1:TimerEvent) : *
		{
			var val3:larTween = null;
			var val4:larTween = null;
			this.compareShowTimer.stop();
			var val2:Number = 0.05;
			if(this.ctf)
			{
				this.ctf.visible = true;
				val3 = new larTween(this.ctf.tooltip_mc,"alpha",Cubic.easeOut,NaN,1,this.tweenInTime,null,null,!!this.tooltipAlignmentLeft?Number(val2):Number(0));
			}
			if(this.ohctf)
			{
				this.ohctf.visible = true;
				val4 = new larTween(this.ohctf.tooltip_mc,"alpha",Cubic.easeOut,NaN,1,this.tweenInTime,null,null,!!this.tooltipAlignmentLeft?Number(0):Number(val2));
			}
		}
		
		public function startModeTimer() : *
		{
			this.tooltipModeTimer.reset();
			this.tooltipModeTimer.start();
		}
		
		public function resetTooltipMode(param1:TimerEvent) : *
		{
			this.compareMode = false;
			this.tooltipModeTimer.stop();
		}
		
		public function onMove(param1:MouseEvent) : *
		{
			this.checkTooltipBoundaries(this.getTooltipWidth(),this.getTooltipHeight(),stage.mouseX + this.frameSpacing,stage.mouseY + this.frameSpacing);
		}
		
		public function INTRemoveTooltip() : *
		{
			this.compareShowTimer.stop();
			if(this.ohctf != null && this.ctf)
			{
				this.ohctf.tooltip_mc.clear();
				this.ctf.offhand_mc.removeChild(this.ohctf);
				this.ohctf = null;
			}
			else
			{
				this.ohctf = null;
			}
			if(this.ctf != null)
			{
				this.ctf.tooltip_mc.clear();
				this.tooltip_mc.comp_mc.removeChild(this.ctf);
				this.tooltip_mc.comp_mc.x = 0;
				this.ctf = null;
			}
			if(this.tf != null)
			{
				if(this.tf.tw)
				{
					this.tf.tw.stop();
				}
				if(this.tf.tooltip_mc)
				{
					this.tf.tooltip_mc.clear();
				}
				this.tooltip_mc.tt_mc.removeChild(this.tf);
				this.tf.alpha = 0;
				this.tf = null;
			}
			this.NormalTooltip = false;
			this.isStatusTT = false;
		}
		
		public function removeTooltip() : *
		{
			this.INTRemoveTooltip();
			this.startModeTimer();
			ExternalInterface.call("clearAnchor");
			this.cachedStickToMouse = 0;
		}
		
		public function fadeOutTooltip(param1:Number, param2:Number) : *
		{
			if(this.tf.tw)
			{
				this.tf.tw.stop();
			}
			this.tf.tw = new larTween(this.tf,"alpha",Sine.easeOut,this.tf.alpha,0,param2,this.removeTooltip);
			if(this.ctf)
			{
				this.ctf.visible = false;
			}
		}
		
		public function checkTooltipBoundaries(w:Number, h:Number, unused1:Number, unused2:Number) : *
		{
			if(this.NormalTooltip)
			{
				ExternalInterface.call("setTooltipSize",w,h);
			}
			else
			{
				ExternalInterface.call("setTooltipSize",w,h);
			}
		}
		
		public function getTooltipHeight() : Number
		{
			var val1:Number = 0;
			if(this.tf && this.tf.tooltip_mc)
			{
				if(this.ohctf)
				{
					val1 = Math.max(this.ohctf.tooltip_mc.getHeight() + this.ohctf.y,val1);
				}
				if(this.ctf)
				{
					val1 = Math.max(this.ctf.tooltip_mc.getHeight() + this.ctf.y,val1);
				}
				val1 = Math.max(this.tf.tooltip_mc.getHeight() + this.tf.y,val1);
			}
			else
			{
				val1 = this.tooltip_mc.height;
			}
			this.tooltip_mc.y = !!this.NormalTooltip?Number(0):Number(11);
			return val1 + this.tooltip_mc.y;
		}
		
		public function getTooltipWidth() : Number
		{
			var val1:Number = 3;
			if(this.tf && this.tf.widthOverride != -1)
			{
				return this.tf.widthOverride;
			}
			if(this.ohctf)
			{
				return this.ComparePaneOffset3 + val1;
			}
			if(this.ctf)
			{
				return this.ComparePaneOffset2 + val1;
			}
			return this.ComparePaneOffset + val1;
		}
		
		function frame1() : *
		{
			this.events = new Array();
			this.layout = "fixed";
			this.ComparePaneOffset = 410;
			this.ComparePaneOffset2 = 820;
			this.ComparePaneOffset3 = 1230;
			this.frame_width = 1920;
			this.frame_height = 1080;
			this.tf = null;
			this.ctf = null;
			this.ohctf = null;
			this.offsetX = 5;
			this.offsetY = 4;
			this.compareShowTimer = new Timer(600,1);
			this.compareShowTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.onShowCompareTooltip);
			this.compareMode = false;
			this.tooltipModeTimer = new Timer(400,1);
			this.tooltipModeTimer.addEventListener(TimerEvent.TIMER_COMPLETE,this.resetTooltipMode);
			this.tooltip_array = new Array();
			this.tooltipCompare_array = new Array();
			this.tooltipOffHand_array = new Array();
			this.formatTooltip = new tooltipFormattedMC();
			this.formatTooltip.tooltip_mc.scaleH = true;
			this.formatTooltip.mouseChildren = false;
			this.formatTooltip.mouseEnabled = false;
			this.compareTooltip = new ItemCompareTooltip();
			this.compareTooltip.tooltip_mc.scaleH = true;
			this.offhandTooltip = new ItemCompareTooltip();
			this.offhandTooltip.tooltip_mc.scaleH = true;
			this.defaultTooltip = new tooltipMC();
			this.defaultTooltip.mouseChildren = false;
			this.defaultTooltip.mouseEnabled = false;
			this.defaultTooltip.maxTooltipWidth = this.glMaxTooltipWidth;
			this.statusTooltip = new statusTooltipMC();
			this.statusTooltip.isStatusTooltip = true;
			this.statusTooltip.maxTooltipWidth = this.glMaxTooltipWidth;
			this.statusTooltip.text_txt.autoSize = TextFieldAutoSize.CENTER;
			this.statusTooltip.mouseChildren = false;
			this.statusTooltip.mouseEnabled = false;
			this.NormalTooltip = false;
			this.isStatusTT = false;
			this.tooltipAlignmentLeft = false;
		}
	}
}
