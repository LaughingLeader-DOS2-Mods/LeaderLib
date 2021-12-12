package LS_Classes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
		
	public class scrollList extends listDisplay
	{
		public var m_scrollbar_mc:scrollbar;
		public var m_bottomAligned:Boolean = false;
		public var m_allowAutoScroll:Boolean = true;
		private var m_SBSpacing:Number = 10;
		private var m_mouseWheelWhenOverEnabled:Boolean = false;
		private var m_mouseWheelEnabled:Boolean = false;
		private var m_ScrollHeight:Number = 0;
		public var m_allowKeepIntoView:Boolean = true;
		public var m_TextGlowOffset:Number = 3;
		private var m_dragAutoScroll:Boolean = false;
		public var m_dragAutoScrollDistance:Number = 100;
		public var m_dragAutoScrollMod:Number = 0.2;
		private var m_bgTile1_mc:MovieClip = null;
		private var m_bgTile2_mc:MovieClip = null;
		
		public function scrollList(param1:String = "LS_Symbols.down_id", param2:String = "LS_Symbols.up_id", param3:String = "LS_Symbols.handle_id", param4:String = "LS_Symbols.scrollBg_id", param5:String = "", param6:String = "")
		{
			this.m_scrollbar_mc = new scrollbar(param1,param2,param3,param4,param5,param6);
			super();
			this.m_scrollbar_mc.visible = false;
			this.addChild(this.m_scrollbar_mc);
			this.m_scrollbar_mc.addEventListener(Event.CHANGE,this.updateBGPos);
		}
		
		public function get frameHit() : MovieClip
		{
			return scrollHit_mc;
		}
		
		public function set dragAutoScroll(param1:Boolean) : void
		{
			if(this.m_dragAutoScroll != param1)
			{
				if(param1)
				{
					this.addEventListener(MouseEvent.ROLL_OUT,this.disableDragAutoScroll);
					this.addEventListener(MouseEvent.ROLL_OVER,this.enableDragAutoScroll);
				}
				else
				{
					this.removeEventListener(MouseEvent.ROLL_OUT,this.disableDragAutoScroll);
					this.removeEventListener(MouseEvent.ROLL_OVER,this.enableDragAutoScroll);
				}
				this.m_dragAutoScroll = param1;
			}
		}
		
		private function disableDragAutoScroll(param1:MouseEvent) : *
		{
			this.removeEventListener(Event.ENTER_FRAME,this.onDragAutoScrollMove);
		}
		
		private function enableDragAutoScroll(param1:MouseEvent) : *
		{
			this.addEventListener(Event.ENTER_FRAME,this.onDragAutoScrollMove);
		}
		
		private function onDragAutoScrollMove(param1:Event) : *
		{
			var val2:Number = NaN;
			if(root != null && (root as MovieClip).isDragging)
			{
				val2 = 0;
				if(this.mouseY > 0 && this.mouseY < this.m_dragAutoScrollDistance)
				{
					val2 = this.m_dragAutoScrollDistance - this.mouseY;
					this.m_scrollbar_mc.adjustScrollHandle(-val2 * this.m_dragAutoScrollMod);
				}
				else if(this.mouseY > m_height - this.m_dragAutoScrollDistance && this.mouseY < m_height)
				{
					val2 = this.mouseY - (m_height - this.m_dragAutoScrollDistance);
					this.m_scrollbar_mc.adjustScrollHandle(val2 * this.m_dragAutoScrollMod);
				}
			}
		}
		
		public function get dragAutoScroll() : Boolean
		{
			return this.m_dragAutoScroll;
		}
		
		override public function set TOP_SPACING(param1:Number) : *
		{
			this.m_scrollbar_mc.m_extraSpacing = param1 * 2;
			super.TOP_SPACING = param1;
		}
		
		public function set setTileableBG(param1:String) : *
		{
			var val2:Class = Registry.GetClass(param1);
			this.m_bgTile1_mc = new val2();
			this.m_bgTile2_mc = new val2();
			this.m_bgTile1_mc.id = 1;
			this.m_bgTile2_mc.id = 2;
			containerBG_mc.addChild(this.m_bgTile1_mc);
			containerBG_mc.addChild(this.m_bgTile2_mc);
			this.m_bgTile1_mc.y = 0;
			this.m_bgTile2_mc.y = this.m_bgTile1_mc.y + this.m_bgTile1_mc.height;
		}
		
		private function updateBGPos(param1:Event) : *
		{
			var val2:MovieClip = null;
			var val3:MovieClip = null;
			containerBG_mc.scrollRect = containerContent_mc.scrollRect;
			if(this.m_bgTile1_mc && this.m_bgTile2_mc)
			{
				val2 = this.topBgTile;
				val3 = this.bottomBgTile;
				if(val3.y < this.m_scrollbar_mc.scrolledY)
				{
					val2.y = val3.y + val3.height;
				}
				else if(val3.y > this.m_scrollbar_mc.scrolledY + height)
				{
					val3.y = val2.y - val3.height;
				}
			}
			dispatchEvent(new Event(Event.CHANGE));
			this.cullMcsToFrame();
		}
		
		private function get topBgTile() : MovieClip
		{
			if(this.m_bgTile1_mc.y > this.m_bgTile2_mc.y)
			{
				return this.m_bgTile2_mc;
			}
			return this.m_bgTile1_mc;
		}
		
		private function get bottomBgTile() : MovieClip
		{
			if(this.m_bgTile1_mc.y > this.m_bgTile2_mc.y)
			{
				return this.m_bgTile1_mc;
			}
			return this.m_bgTile2_mc;
		}
		
		private function cullMcsToFrame() : *
		{
			var val2:MovieClip = null;
			var val1:uint = 0;
			while(val1 < content_array.length)
			{
				val2 = content_array[val1];
				if(val2 && val2.elementInView && val2.elementInView is Function)
				{
					if(val2.y + getElementHeight(val2) - this.m_TextGlowOffset > this.m_scrollbar_mc.scrolledY && val2.y + this.m_TextGlowOffset <= this.m_scrollbar_mc.scrolledY + height)
					{
						val2.elementInView(val2.visible);
					}
					else
					{
						val2.elementInView(false);
					}
				}
				val1++;
			}
		}
		
		public function get mouseWheelWhenOverEnabled() : Boolean
		{
			return this.m_mouseWheelWhenOverEnabled;
		}
		
		public function get scrolledY() : Number
		{
			return this.m_scrollbar_mc.scrolledY;
		}
		
		public function set mouseWheelWhenOverEnabled(param1:Boolean) : *
		{
			if(this.m_mouseWheelWhenOverEnabled != param1)
			{
				this.m_mouseWheelWhenOverEnabled = param1;
				if(this.m_mouseWheelWhenOverEnabled)
				{
					this.addEventListener(MouseEvent.ROLL_OUT,this.disableMouseWheelOnOut);
					this.addEventListener(MouseEvent.ROLL_OVER,this.enableMouseWheelOnOver);
				}
				else
				{
					this.removeEventListener(MouseEvent.ROLL_OUT,this.disableMouseWheelOnOut);
					this.removeEventListener(MouseEvent.ROLL_OVER,this.enableMouseWheelOnOver);
				}
			}
		}
		
		override public function selectMC(param1:MovieClip, param2:Boolean = false) : *
		{
			var val4:MovieClip = null;
			var val5:Number = NaN;
			var val3:Boolean = true;
			if(param1 && m_CurrentSelection && param1.list_pos < m_CurrentSelection.list_pos)
			{
				val3 = false;
			}
			super.selectMC(param1,param2);
			if(this.m_scrollbar_mc.visible && this.m_allowKeepIntoView)
			{
				val4 = getFirstVisible();
				if(m_CurrentSelection == val4)
				{
					this.m_scrollbar_mc.scrollTo(0,this.m_scrollbar_mc.m_animateScrolling);
				}
				else
				{
					val5 = getElementHeight(m_CurrentSelection);
					this.m_scrollbar_mc.scrollIntoView(m_CurrentSelection.y,val5);
				}
			}
		}
		
		override public function clearElements() : *
		{
			super.clearElements();
			this.resetScroll();
			this.checkScrollBar();
		}
		
		public function resetScroll() : *
		{
			if(this.m_scrollbar_mc)
			{
				this.m_scrollbar_mc.resetHandle();
			}
		}
		
		override public function selectByOffset(param1:Number, param2:Boolean = false) : Boolean
		{
			var val4:* = undefined;
			var val5:MovieClip = null;
			var val6:Number = NaN;
			var val3:Boolean = false;
			if(param2)
			{
				return super.selectByOffset(param1);
			}
			param1 += TOP_SPACING;
			param1 += this.m_scrollbar_mc.scrolledY;
			val4 = 0;
			while(val4 < content_array.length)
			{
				val5 = content_array[val4];
				if(val5 != null && val5.visible)
				{
					val6 = getElementHeight(val5);
					if(val5.y <= param1 && val5.y + val6 > param1)
					{
						val3 = true;
						this.selectMC(val5);
						break;
					}
				}
				val4++;
			}
			return val3;
		}
		
		public function get mouseWheelEnabled() : Boolean
		{
			return this.m_mouseWheelEnabled;
		}
		
		public function set mouseWheelEnabled(param1:Boolean) : *
		{
			if(this.m_mouseWheelEnabled != param1)
			{
				this.m_mouseWheelEnabled = param1;
				this.m_scrollbar_mc.mouseWheelEnabled = param1;
			}
		}
		
		private function disableMouseWheelOnOut(param1:MouseEvent) : *
		{
			this.m_scrollbar_mc.mouseWheelEnabled = false;
		}
		
		private function enableMouseWheelOnOver(param1:MouseEvent) : *
		{
			this.m_scrollbar_mc.mouseWheelEnabled = true;
		}
		
		public function checkScrollBar() : *
		{
			if(this.m_allowAutoScroll)
			{
				this.m_scrollbar_mc.scrollTo(this.m_scrollbar_mc.m_scrolledY);
			}
			this.m_scrollbar_mc.m_contentFrameHeight = height;
			this.m_scrollbar_mc.m_contentHeight = this.m_ScrollHeight;
			this.m_scrollbar_mc.scrollbarVisible();
		}
		
		override public function setFrameWidth(param1:Number) : *
		{
			width = param1;
			this.calculateScrollRect();
		}
		
		override public function setFrame(param1:Number, param2:Number) : *
		{
			width = param1;
			height = param2;
			this.calculateScrollRect();
		}
		
		public function setFrameHeight(param1:Number) : *
		{
			height = param1;
			this.calculateScrollRect();
		}
		
		private function calculateScrollRect() : *
		{
			containerContent_mc.scrollRect = new Rectangle(0,0,width,height);
			this.m_scrollbar_mc.x = this.m_SBSpacing + width;
			this.m_scrollbar_mc.addContent(containerContent_mc);
			this.checkScrollBar();
			updateScrollHit();
		}
		
		override public function positionElements() : *
		{
			if(content_array.length == 0)
			{
				return;
			}
			if(m_NeedsSorting && m_SortOnFieldName && content_array && content_array.length > 1)
			{
				content_array.sortOn(m_SortOnFieldName,m_SortOnOptions);
			}
			var val1:Number = TOP_SPACING;
			var val2:uint = 0;
			while(val2 < content_array.length)
			{
				content_array[val2].list_pos = val2;
				content_array[val2].y = val1;
				content_array[val2].x = SIDE_SPACING;
				if(content_array[val2].visible)
				{
					val1 += getElementHeight(content_array[val2]) + EL_SPACING;
				}
				val2++;
			}
			this.m_ScrollHeight = val1 - EL_SPACING;
			this.checkScrollBar();
			if(this.m_bottomAligned)
			{
				this.m_scrollbar_mc.alignContentToBottom();
			}
			this.cullMcsToFrame();
		}
		
		public function set scrollbarSpacing(param1:Number) : *
		{
			this.m_SBSpacing = param1;
			this.m_scrollbar_mc.x = width + this.m_SBSpacing + this.m_scrollbar_mc.width;
		}
		
		public function set SB_SPACING(param1:Number) : *
		{
			this.m_SBSpacing = param1;
			this.m_scrollbar_mc.x = width + this.m_SBSpacing + this.m_scrollbar_mc.width;
		}
		
		public function get SB_SPACING() : Number
		{
			return this.m_SBSpacing;
		}
		
		public function get scrollbarSpacing() : Number
		{
			return this.SB_SPACING;
		}
	}
}
