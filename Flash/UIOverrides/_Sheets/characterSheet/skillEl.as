package
{
	import LS_Classes.scrollList;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	
	public dynamic class skillEl extends MovieClip
	{
		public var hl_mc:MovieClip;
		public var itemSkillFrame_mc:MovieClip;
		public var removeSkillBtn_mc:deleteBtn;
		public const borderOffset:uint = 2;
		public var root_mc:MovieClip;
		public var dragTreshHold:uint;
		public var mousePosDown:Point;
		public var _canBeRemoved:Boolean;
		
		public function skillEl()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(param1:MovieClip) : *
		{
			this.root_mc = param1;
			this.canBeRemoved = true;
			this.hl_mc.width = this.hl_mc.height = this.root_mc.skillIconSize;
			this.hl_mc.alpha = 0;
			this.itemSkillFrame_mc.width = this.itemSkillFrame_mc.height = this.hl_mc.width;
			this.removeSkillBtn_mc.x = this.width - this.removeSkillBtn_mc.width - this.borderOffset;
			this.removeSkillBtn_mc.y = this.borderOffset;
			this.removeSkillBtn_mc.initialize("",this.onRemoveSkillButtonPressed,this);
			this.removeSkillBtn_mc.visible = false;
			this.removeSkillBtn_mc.SND_Press = "UI_GM_Generic_Cancel_Press";
			this.removeSkillBtn_mc.SND_Click = "UI_GM_Generic_Cancel_Release";
		}
		
		public function set canBeRemoved(param1:Boolean) : void
		{
			this.itemSkillFrame_mc.visible = !param1;
			this._canBeRemoved = param1;
		}
		
		public function get canBeRemoved() : Boolean
		{
			return this._canBeRemoved;
		}
		
		public function onRemoveSkillButtonPressed(param1:MovieClip) : *
		{
			ExternalInterface.call("UnlearnSkill",this.skillID);
		}
		
		public function onOver(param1:MouseEvent) : *
		{
			var val4:MovieClip = null;
			var val5:MovieClip = null;
			var val6:scrollList = null;
			var val7:Point = null;
			var val2:uint = 5;
			var val3:int = -29;
			if(this.root_mc)
			{
				val4 = this.root_mc.stats_mc;
				val5 = val4 != null?val4.skillTabHolder_mc:null;
				val6 = val5 != null?val5.skillLists:null;
				val7 = this.localToGlobal(new Point(0,0));
				ExternalInterface.call("showSkillTooltip",this.root_mc.characterHandle,this.skillID,val7.x + val2,val7.y + val3,this.width,this.height);
				this.hl_mc.alpha = !!this.canBeRemoved?Number(0.6):Number(0.1);
				this.removeSkillBtn_mc.visible = this.canBeRemoved;
			}
		}
		
		public function onOut(param1:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			this.hl_mc.alpha = 0;
			this.removeSkillBtn_mc.visible = false;
		}
		
		public function onDown(param1:MouseEvent) : *
		{
			if(this.canBeRemoved)
			{
				addEventListener(MouseEvent.MOUSE_MOVE,this.onDragging);
				this.mousePosDown = new Point(stage.mouseX,stage.mouseY);
			}
		}
		
		public function onUp(param1:MouseEvent) : *
		{
			removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
			removeEventListener(MouseEvent.MOUSE_MOVE,this.onDragging);
		}
		
		public function onDragging(param1:MouseEvent) : *
		{
			if(stage.mouseX > this.mousePosDown.x + this.dragTreshHold || stage.mouseX < this.mousePosDown.x - this.dragTreshHold || stage.mouseY > this.mousePosDown.y + this.dragTreshHold || stage.mouseY < this.mousePosDown.y - this.dragTreshHold)
			{
				removeEventListener(MouseEvent.MOUSE_UP,this.onUp);
				removeEventListener(MouseEvent.MOUSE_MOVE,this.onDragging);
				this.root_mc.draggingSkill = true;
				ExternalInterface.call("dragSkill",this.skillID);
			}
		}
		
		public function frame1() : *
		{
			addEventListener(MouseEvent.ROLL_OVER,this.onOver);
			addEventListener(MouseEvent.ROLL_OUT,this.onOut);
			addEventListener(MouseEvent.MOUSE_DOWN,this.onDown);
			this.dragTreshHold = 5;
		}
	}
}
