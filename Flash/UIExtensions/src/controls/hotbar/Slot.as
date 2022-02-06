package controls.hotbar
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	
	public class Slot extends MovieClip
	{
		public var amount_mc:MovieClip;
		public var cd_mc:SlotCooldown;
		public var disable_mc:MovieClip;
		public var refreshSlot_mc:MovieClip;
		public var unavailable_mc:MovieClip;
		public var iggySlot_mc:IggySlot;
		public var oldCD:Number;
		public var isEnabled:Boolean;
		public var inUse:Boolean;

		public var type:int;
		public var tooltip:String;
		public var isUpdated:Boolean = false;
		public var handle:*;
		public var amount:Number;

		public var slotHolder:SlotHolder;

		private var _id:Number;

		public function get id():Number
		{
			return this._id;
		}
		
		public function set id(v:Number):void
		{
			this._id = v;
			//this.iggySlot_mc.name = "iggy_LeaderLib_Hotbar_Slot" + v
		}
		
		public function Slot()
		{
			super();
			addFrameScript(0,this.frame1);
		}

		public function setIcon(name:String = "") : void
		{
			if(this.iggySlot_mc == null) {
				this.iggySlot_mc = new IggySlot();
				this.addChildAt(this.iggySlot_mc, 0);
			}
			this.iggySlot_mc.name = name;
			this.iggySlot_mc.visible = name != "";
		}
		
		public function setCoolDown(cd:Number) : *
		{
			if(cd == -1)
			{
				this.oldCD = 0;
				cd = 0;
			}
			if(cd == 0)
			{
				this.disable_mc.alpha = 1;
				this.isEnabled = true;
				this.cd_mc.visible = false;
				if(this.oldCD != 0)
				{
					this.refreshSlot_mc.visible = true;
					this.refreshSlot_mc.alpha = 1;
					this.refreshSlot_mc.gotoAndPlay(2);
					Registry.ExtCall("PlaySound","UI_Game_Skill_Cooldown_End");
				}
			}
			else
			{
				this.disable_mc.alpha = 0;
				this.cd_mc.visible = true;
				this.isEnabled = false;
			}
			this.oldCD = cd;
			this.cd_mc.setCoolDown(cd);
		}
		
		public function onOver(e:MouseEvent) : *
		{
			this.onMouseOver();
		}
		
		public function onOut(e:MouseEvent) : *
		{
			this.onMouseOut();
		}
		
		public function onClick(e:MouseEvent) : *
		{
			Registry.ExtCall("LeaderLib_Hotbar_SlotPressed", this.id, this.isEnabled, this.slotHolder.hotbar.currentHotBarIndex);
			if(this.isEnabled)
			{
				Registry.ExtCall("PlaySound","UI_Generic_Click");
			}
			else if(this.cd_mc.visible)
			{
				Registry.ExtCall("PlaySound","UI_Game_Skill_Cooldown_Neg");
			}
		}
		
		public function onMouseOver() : *
		{
			if((root as MovieClip).isDragging || this.inUse && this.isEnabled)
			{
				Registry.ExtCall("PlaySound","UI_Generic_Over");
				Registry.ExtCall("LeaderLib_Hotbar_SlotHover", this.id, this.slotHolder.hotbar.currentHotBarIndex);
			}
		}
		
		public function onMouseOut() : *
		{
			Registry.ExtCall("LeaderLib_Hotbar_SlotHoverOut", this.id, this.slotHolder.hotbar.currentHotBarIndex);
		}
		
		public function frame1() : *
		{
			this.amount_mc.mouseEnabled = false;
			this.amount_mc.mouseChildren = false;
			this.refreshSlot_mc.visible = false;

			if(this.iggySlot_mc == null) {
				this.iggySlot_mc = new IggySlot();
				this.addChildAt(this.iggySlot_mc, 0);
			}
		}
	}
}
