package controls.hotbar
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public class LockButton extends MovieClip
	{
		public var disabled_mc:MovieClip;
		public var bIsLocked:Boolean;
		public var tooltipA:String;
		public var tooltipB:String;
		
		public function LockButton()
		{
			super();
		}

		private var _hotbar:Hotbar;
		public function get hotbar():Hotbar
		{
			if(!_hotbar) {
				_hotbar = parent as Hotbar;
			}
			return _hotbar;
		}

		public function onInit() : void
		{
			this.stop();
			this.addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
			this.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			this.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			this.disabled_mc.visible = false;
		}
		
		public function setLocked(isLocked:Boolean) : *
		{
			if(this.bIsLocked != isLocked)
			{
				this.bIsLocked = isLocked;
				if(this.bIsLocked)
				{
					this.gotoAndStop(4);
				}
				else
				{
					this.gotoAndStop(1);
				}
			}
		}
		
		public function onDown(e:MouseEvent) : *
		{
			if(!this.disabled_mc.visible)
			{
				Registry.ExtCall("PlaySound","UI_Gen_XButton_Click");
				if(this.bIsLocked)
				{
					this.gotoAndStop(6);
				}
				else
				{
					this.gotoAndStop(3);
				}
				addEventListener(MouseEvent.MOUSE_UP,this.onUp);
			}
		}
		
		public function onUp(e:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.bIsLocked = !this.bIsLocked;
			Registry.ExtCall("setHotbarLocked",this.bIsLocked);
			if(this.bIsLocked)
			{
				this.gotoAndStop(5);
			}
			else
			{
				this.gotoAndStop(2);
			}
			this.showTooltip();
		}
		
		public function onOver(e:MouseEvent) : *
		{
			if(!this.disabled_mc.visible)
			{
				if(this.bIsLocked)
				{
					this.gotoAndStop(5);
				}
				else
				{
					this.gotoAndStop(2);
				}
			}
			Registry.ExtCall("PlaySound","UI_Generic_Over");
			this.showTooltip();
		}
		
		public function showTooltip() : *
		{
			var mc:MovieClip = root as MovieClip;
			if(this.bIsLocked)
			{
				if(this.tooltipB != null && this.tooltipB != "")
				{
					mc.hotbar_mc.showBtnTooltip(this,this.tooltipB);
				}
			}
			else if(this.tooltipA != null && this.tooltipA != "")
			{
				mc.hotbar_mc.showBtnTooltip(this,this.tooltipA);
			}
		}
		
		public function onOut(e:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			if(!this.disabled_mc.visible)
			{
				if(this.bIsLocked)
				{
					this.gotoAndStop(4);
				}
				else
				{
					this.gotoAndStop(1);
				}
			}
			if(this.tooltipA != null && this.tooltipA != "" || this.tooltipB != null && this.tooltipB != "")
			{
				Registry.ExtCall("hideTooltip");
				MainTimeline.Instance.setHasTooltip(false);
			}
		}
		
		public function setEnabled(isEnabled:Boolean) : *
		{
			this.disabled_mc.visible = !isEnabled;
		}
	}
}
