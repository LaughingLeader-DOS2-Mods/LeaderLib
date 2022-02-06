package controls.dropdowns
{
	import flash.display.MovieClip;
	import interfaces.IDropdownButton;

	public dynamic class PresetButtonGraphic extends MovieClip implements IDropdownButton
	{
		public var _toggled:Boolean = false;
		public var state:int = 0;

		public function get toggled():Boolean
		{
			return this._toggled;
		}

		public function set toggled(b:Boolean):void
		{
			this._toggled = b;
			this.changeState(this.state);
		}

		public function changeState(toState:int):void
		{
			this.state = toState;
			switch(this.state)
			{
				case 1:
					this.gotoAndStop(this.toggled ? "hover1" : "hover0");
					break;
				case 2:
					this.gotoAndStop(this.toggled ? "click1" : "click0");
					break;
				case 1:
				default:
					this.gotoAndStop(this.toggled ? "inactive1" : "inactive0");
			}
		}

		public function PresetButtonGraphic()
		{
			super();
			this.stop();
			this.addFrameScript(0, this.frame1);
		}

		public function frame1() : void
		{
			this.stop();
		}

		public function onOut() : void
		{
			this.changeState(0);
		}

		public function onUp() : void
		{
			this.changeState(0);
		}

		public function onHover() : void
		{
			this.changeState(1);
		}

		public function onClick() : void
		{
			this.changeState(2);
		}
	}
}