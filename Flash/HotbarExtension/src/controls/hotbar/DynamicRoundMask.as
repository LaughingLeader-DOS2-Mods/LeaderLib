package controls.hotbar
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	
	public dynamic class DynamicRoundMask extends MovieClip
	{
		public function DynamicRoundMask()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function drawWedge(param1:Number, param2:Number, param3:Number, param4:Number, param5:Number, param6:Number = 1, param7:* = 1, param8:* = 0.5) : *
		{
			var val20:* = undefined;
			var val21:* = undefined;
			if(!this.init)
			{
				this.m_CX = param1;
				this.m_CY = param2;
				this.m_R = param3;
				this.m_BA = param4;
				this.m_EA = param5;
				this.m_A = param6;
				this.needsRefresh = true;
				return;
			}
			var val9:Number = Math.PI / 3 * 60;
			var val10:Number = -1;
			var val11:Number = -1;
			if(param4 == val10 && param5 == val11)
			{
				return;
			}
			val10 = param4;
			val11 = param5;
			if(param5 < param4)
			{
				param5 = param5 + 6 * 60;
			}
			var val12:Number = Math.ceil((param5 - param4) / 45);
			if(val12 == 0)
			{
				return;
			}
			var val13:Sprite = this.getChildByName("myPie") as Sprite;
			if(val13 != null)
			{
				this.removeChild(val13);
			}
			var val14:Sprite = new Sprite();
			val14.name = "myPie";
			val14.graphics.lineStyle(param8,0,param7);
			val14.graphics.beginFill(0xffffff,param6);
			var val15:int = 0;
			var val16:Number = (param5 - param4) / val12 * val9;
			var val17:Number = param3 / Math.cos(val16 / 2);
			var val18:Number = param4 * val9;
			var val19:Number = val18 - val16 / 2;
			val14.graphics.moveTo(param1,param2);
			val14.graphics.lineTo(param1 + param3 * Math.cos(val18),param2 + param3 * Math.sin(val18));
			val15 = 0;
			while(val15 < val12)
			{
				val18 = val18 + val16;
				val19 = val19 + val16;
				val20 = param3 * Math.cos(val18);
				val21 = param3 * Math.sin(val18);
				val14.graphics.lineTo(param1 + val20,param2 + val21);
				val15++;
			}
			val14.graphics.lineTo(param1,param2);
			val14.graphics.endFill();
			this.addChild(val14);
		}
		
		public function deleteWedge() : *
		{
			var pie:Sprite = this.getChildByName("myPie") as Sprite;
			if(pie != null)
			{
				this.removeChild(pie);
			}
		}
		
		public function initDraw() : *
		{
			this.init = true;
			if(this.needsRefresh)
			{
				this.drawWedge(this.m_CX,this.m_CY,this.m_R,this.m_BA,this.m_EA,this.m_A);
			}
		}
		
		public function frame1() : *
		{
			this.initDraw();
		}
	}
}
