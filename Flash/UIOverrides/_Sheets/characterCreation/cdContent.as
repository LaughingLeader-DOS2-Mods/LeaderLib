package
{
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public dynamic class cdContent extends MovieClip
	{
		public var iconHolder_mc:MovieClip;
		public const tooltipOffset:int = 5;
		public var root_mc:MovieClip;
		
		public function cdContent()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function onInit(root:MovieClip) : *
		{
			this.root_mc = root;
		}

		//LeaderLib: Making custom draw calls possible for racial/origin skills
		public function setRacialSkillIcons(name:String, skillCount:uint) : *
		{
			var icon_mc:iggy = null;
			var i:uint = 0;
			while(i < skillCount)
			{
				icon_mc = new iggy();
				icon_mc.bg_mc.height = this.root_mc.iconSize;
				icon_mc.bg_mc.width = this.root_mc.iconSize;
				icon_mc.name = "iggy_leaderlib_racial" + i;
				this.iconHolder_mc.addChild(icon_mc);
				icon_mc.x = (i * this.root_mc.iconSize) + (i * this.root_mc.iconSpacing);
				icon_mc.skillIdx = i;
				icon_mc.iggyID = name;
				icon_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
				icon_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
				i++;
			}
		}
		
		public function setIcon(name:String, skillCount:uint) : *
		{
			//LeaderLib, making custom draw calls possible for racial/origin skills
			if(name == "r")
			{
				this.setRacialSkillIcons(name, skillCount);
				return;
			}

			var iggyIcon:MovieClip = new iggy();
			iggyIcon.bg_mc.width = skillCount * this.root_mc.iconSize + (skillCount - 1) * this.root_mc.iconSpacing;
			iggyIcon.bg_mc.height = this.root_mc.iconSize;
			iggyIcon.name = "iggy_" + name;
			if(name == "s")
			{
				iggyIcon.scrollRect = new Rectangle(0,0,500,60);
			}
			this.iconHolder_mc.addChild(iggyIcon);
			var hit_mc:MovieClip = null;
			var skillIdx:uint = 0;
			while(skillIdx < skillCount)
			{
				hit_mc = new hit();
				addChild(hit_mc);
				hit_mc.height = hit_mc.width = this.root_mc.iconSize;
				hit_mc.x = skillIdx * this.root_mc.iconSize + skillIdx * this.root_mc.iconSpacing;
				hit_mc.skillIdx = skillIdx;
				hit_mc.iggyID = name;
				hit_mc.addEventListener(MouseEvent.ROLL_OVER,this.onOver);
				hit_mc.addEventListener(MouseEvent.ROLL_OUT,this.onOut);
				skillIdx++;
			}
		}
		
		public function onOver(e:MouseEvent) : *
		{
			trace("cdContent", this.x, this.y, this.width, this.height);
			var hit_mc:MovieClip = e.target as MovieClip;
			var pos:Point = hit_mc.localToGlobal(new Point(0,0));
			var skill:String = null;
			if(hit_mc.iggyID == "s" && hit_mc.skillIdx < this.root_mc.chosenSkills.length)
			{
				skill = this.root_mc.chosenSkills[hit_mc.skillIdx];
			}
			else if(hit_mc.iggyID == "r" && hit_mc.skillIdx < this.root_mc.racialSkills.length)
			{
				skill = this.root_mc.racialSkills[hit_mc.skillIdx];
			}
			ExternalInterface.call("PlaySound","UI_Generic_Over");
			if(skill != "")
			{
				ExternalInterface.call("showSkillTooltip",this.root_mc.characterHandle,skill,pos.x + this.tooltipOffset - this.root_mc.x,pos.y,hit_mc.width,hit_mc.height);
			}
		}
		
		public function onOut(e:MouseEvent) : *
		{
			ExternalInterface.call("hideTooltip");
		}
		
		public function setContentSize(pos:Point) : *
		{
		}
		
		public function frame1() : *
		{
		}
	}
}
