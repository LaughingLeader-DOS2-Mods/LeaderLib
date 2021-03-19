package LS_Classes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	
	public class horizontalList extends listDisplay
	{
		 
		
		public var rightSided:Boolean = true;
		
		public var m_MaxWidth:int = -1;
		
		public var m_MaxRowElements:int = -1;
		
		public var m_RowSpacing:int = 0;
		
		public var m_CenterHolders:Boolean = false;
		
		public var m_RowHeight:Number = -1;
		
		private var m_holderArray:Array;
		
		public function horizontalList()
		{
			this.m_holderArray = new Array();
			super();
		}
		
		override public function positionElements() : *
		{
			var val7:Number = NaN;
			var val8:int = 0;
			if(content_array.length < 1)
			{
				return;
			}
			if(m_NeedsSorting && m_SortOnFieldName && content_array && content_array.length > 1)
			{
				content_array.sortOn(m_SortOnFieldName,m_SortOnOptions);
				m_NeedsSorting = false;
			}
			var val1:Number = 0;
			var val2:uint = 0;
			var val3:uint = 1;
			var val4:uint = content_array.length;
			var val5:MovieClip = null;
			var val6:uint = 0;
			while(val6 < val4)
			{
				if(content_array[val6].visible || canPositionInvisibleElements)
				{
					if(this.rightSided)
					{
						content_array[val6].x = val1;
						content_array[val6].tweenToX = val1;
						val1 = val1 + Math.round(getElementWidth(content_array[val6]) + EL_SPACING);
					}
					else
					{
						val7 = getElementWidth(content_array[val6]);
						content_array[val6].x = val1 - val7;
						content_array[val6].tweenToX = val1 - val7;
						val1 = val1 - Math.round(val7 + EL_SPACING);
					}
					if(this.m_MaxWidth > 0)
					{
						val8 = content_array[val6].x + content_array[val6].width;
						if(val8 > this.m_MaxWidth)
						{
							content_array[val6].x = 0;
							val2++;
							val1 = Math.round(getElementWidth(content_array[val6]) + EL_SPACING);
						}
						val5 = this.createNewRowHolderWhenNeeded(val2);
						val5.addChild(content_array[val6]);
						val5.overrideWidth = content_array[val6].x + getElementWidth(content_array[val6]);
					}
					else if(this.m_MaxRowElements > 0)
					{
						if(val3 > this.m_MaxRowElements)
						{
							val3 = 1;
							content_array[val6].x = 0;
							val2++;
							val1 = Math.round(getElementWidth(content_array[val6]) + EL_SPACING);
						}
						val5 = this.createNewRowHolderWhenNeeded(val2);
						val5.addChild(content_array[val6]);
						val5.overrideWidth = content_array[val6].x + getElementWidth(content_array[val6]);
						val3++;
					}
				}
				else
				{
					content_array[val6].x = 0;
				}
				val6++;
			}
			this.cleanupUnusedRowHolders(val2);
			this.centerHolders();
		}
		
		private function centerHolders() : void
		{
			var val1:uint = 0;
			var val2:MovieClip = null;
			if(this.m_CenterHolders)
			{
				val1 = 0;
				while(val1 < this.m_holderArray.length)
				{
					val2 = this.m_holderArray[val1];
					val2.x = -Math.round(val2.overrideWidth * 0.5);
					val1++;
				}
			}
		}
		
		private function createNewRowHolderWhenNeeded(param1:Number) : MovieClip
		{
			var val2:MovieClip = null;
			var val3:MovieClip = null;
			if(this.m_holderArray.length <= param1)
			{
				val2 = new MovieClip();
				containerContent_mc.addChild(val2);
				if(this.m_holderArray.length > 0)
				{
					val3 = this.m_holderArray[this.m_holderArray.length - 1];
					if(val3)
					{
						if(this.m_RowHeight == -1)
						{
							val2.y = val3.y + val3.height + this.m_RowSpacing;
						}
						else
						{
							val2.y = val3.y + this.m_RowHeight + this.m_RowSpacing;
						}
					}
				}
				this.m_holderArray.push(val2);
				return val2;
			}
			return this.m_holderArray[param1];
		}
		
		private function cleanupUnusedRowHolders(param1:Number) : *
		{
			var val2:uint = param1 + 1;
			while(this.m_holderArray.length > val2)
			{
				containerContent_mc.removeChild(this.m_holderArray[val2]);
				this.m_holderArray.splice(val2,1);
			}
		}
		
		override public function moveElementsToPosition(param1:Number = 0.8, param2:Boolean = false) : *
		{
			var val8:Object = null;
			var val10:MovieClip = null;
			var val11:Number = NaN;
			var val12:int = 0;
			if(content_array.length < 1)
			{
				return;
			}
			var val3:Number = 0;
			var val4:uint = 0;
			var val5:uint = 1;
			var val6:MovieClip = null;
			m_tweeningMcs = 0;
			dispatchEvent(new Event("listMoveStart"));
			var val7:uint = content_array.length;
			var val9:uint = 0;
			while(val9 < val7)
			{
				val10 = content_array[val9];
				if(val10)
				{
					if(this.rightSided)
					{
						m_tweeningMcs++;
						val10.tweening = true;
						val10.tweenToX = val3;
						val3 = val3 + Math.round(getElementWidth(content_array[val9]) + EL_SPACING);
					}
					else
					{
						m_tweeningMcs++;
						val10.tweening = true;
						val11 = getElementWidth(content_array[val9]);
						val10.tweenToX = val3 - val11;
						val3 = val3 - Math.round(val11 + EL_SPACING);
					}
					stopElementMCPosTweens(val10);
					if(param2)
					{
						val10.list_tweenY = new larTween(val10,"y",m_PositionTweenFunc,val10.y,0,param1);
					}
					val10.list_tweenX = new larTween(val10,"x",m_PositionTweenFunc,val10.x,val10.tweenToX,param1,removeTweenState,val10.list_id);
					if(this.m_MaxWidth > 0)
					{
						val12 = content_array[val9].x + content_array[val9].width;
						if(val12 > this.m_MaxWidth)
						{
							content_array[val9].tweenToX = 0;
							val4++;
							val3 = Math.round(getElementWidth(content_array[val9]) + EL_SPACING);
						}
						val6 = this.createNewRowHolderWhenNeeded(val4);
						val6.addChild(content_array[val9]);
						val6.overrideWidth = content_array[val9].tweenToX + getElementWidth(content_array[val9]);
					}
					else if(this.m_MaxRowElements > 0)
					{
						if(val5 > this.m_MaxRowElements)
						{
							val5 = 1;
							content_array[val9].x = 0;
							val4++;
							val3 = Math.round(getElementWidth(content_array[val9]) + EL_SPACING);
						}
						val6 = this.createNewRowHolderWhenNeeded(val4);
						val6.addChild(content_array[val9]);
						val6.overrideWidth = content_array[val9].tweenToX + getElementWidth(content_array[val9]);
						val5++;
					}
				}
				val9++;
			}
			this.cleanupUnusedRowHolders(val4);
		}
		
		public function getContainerWidth() : Number
		{
			var val1:Number = 0;
			var val2:MovieClip = getLastVisible();
			if(val2)
			{
				if(this.rightSided)
				{
					return val2.x + getElementWidth(val2);
				}
				return -val2.x;
			}
			return 0;
		}
	}
}
