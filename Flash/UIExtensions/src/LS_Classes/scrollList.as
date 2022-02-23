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
		
		private function disableDragAutoScroll(param1:MouseEvent) : void
		{
			this.removeEventListener(Event.ENTER_FRAME,this.onDragAutoScrollMove);
		}
		
		private function enableDragAutoScroll(param1:MouseEvent) : void
		{
			this.addEventListener(Event.ENTER_FRAME,this.onDragAutoScrollMove);
		}
		
		private function onDragAutoScrollMove(param1:Event) : void
		{
			var val2:Number = NaN;
			if(root != null && MainTimeline.Instance.isDragging)
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
		
		override public function set TOP_SPACING(v:Number) : void
		{
			this.m_scrollbar_mc.m_extraSpacing = v * 2;
			super.TOP_SPACING = v;
		}
		
		public function set setTileableBG(className:String) : void
		{
			var obj_class:Class = Registry.GetClass(className);
			this.m_bgTile1_mc = new obj_class();
			this.m_bgTile2_mc = new obj_class();
			this.m_bgTile1_mc.id = 1;
			this.m_bgTile2_mc.id = 2;
			containerBG_mc.addChild(this.m_bgTile1_mc);
			containerBG_mc.addChild(this.m_bgTile2_mc);
			this.m_bgTile1_mc.y = 0;
			this.m_bgTile2_mc.y = this.m_bgTile1_mc.y + this.m_bgTile1_mc.height;
		}
		
		private function updateBGPos(e:Event) : void
		{
			var top_mc:MovieClip = null;
			var bottom_mc:MovieClip = null;
			containerBG_mc.scrollRect = containerContent_mc.scrollRect;
			if(this.m_bgTile1_mc && this.m_bgTile2_mc)
			{
				top_mc = this.topBgTile;
				bottom_mc = this.bottomBgTile;
				if(bottom_mc.y < this.m_scrollbar_mc.scrolledY)
				{
					top_mc.y = bottom_mc.y + bottom_mc.height;
				}
				else if(bottom_mc.y > this.m_scrollbar_mc.scrolledY + height)
				{
					bottom_mc.y = top_mc.y - bottom_mc.height;
				}
			}
			this.dispatchEvent(new Event(Event.CHANGE));
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
		
		private function cullMcsToFrame() : void
		{
			var mc:MovieClip = null;
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				mc = content_array[i];
				if(mc && mc.elementInView && mc.elementInView is Function)
				{
					if(mc.y + getElementHeight(mc) - this.m_TextGlowOffset > this.m_scrollbar_mc.scrolledY && mc.y + this.m_TextGlowOffset <= this.m_scrollbar_mc.scrolledY + height)
					{
						mc.elementInView(mc.visible);
					}
					else
					{
						mc.elementInView(false);
					}
				}
				i++;
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
		
		public function set mouseWheelWhenOverEnabled(b:Boolean) : void
		{
			if(this.m_mouseWheelWhenOverEnabled != b)
			{
				this.m_mouseWheelWhenOverEnabled = b;
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
		
		override public function selectMC(mc:MovieClip, force:Boolean = false) : void
		{
			var first_mc:MovieClip = null;
			var mc_height:Number = NaN;
			super.selectMC(mc,force);
			if(this.m_scrollbar_mc.visible && this.m_allowKeepIntoView)
			{
				first_mc = getFirstVisible();
				if(m_CurrentSelection == first_mc)
				{
					this.m_scrollbar_mc.scrollTo(0,this.m_scrollbar_mc.m_animateScrolling);
				}
				else
				{
					mc_height = getElementHeight(m_CurrentSelection);
					this.m_scrollbar_mc.scrollIntoView(m_CurrentSelection.y,mc_height);
				}
			}
		}
		
		override public function clearElements() : void
		{
			super.clearElements();
			this.resetScroll();
			this.checkScrollBar();
		}
		
		public function resetScroll() : void
		{
			if(this.m_scrollbar_mc)
			{
				this.m_scrollbar_mc.resetHandle();
			}
		}
		
		override public function selectByOffset(offsetY:Number, force:Boolean = false) : Boolean
		{
			if(force)
			{
				return super.selectByOffset(offsetY);
			}
			var mc:MovieClip = null;
			var mc_height:Number = NaN;
			var is_selected:Boolean = false;
			offsetY += TOP_SPACING;
			offsetY += this.m_scrollbar_mc.scrolledY;
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				mc = content_array[i];
				if(mc != null && mc.visible)
				{
					mc_height = getElementHeight(mc);
					if(mc.y <= offsetY && mc.y + mc_height > offsetY)
					{
						is_selected = true;
						this.selectMC(mc);
						break;
					}
				}
				i++;
			}
			return is_selected;
		}
		
		public function get mouseWheelEnabled() : Boolean
		{
			return this.m_mouseWheelEnabled;
		}
		
		public function set mouseWheelEnabled(b:Boolean) : void
		{
			if(this.m_mouseWheelEnabled != b)
			{
				this.m_mouseWheelEnabled = b;
				this.m_scrollbar_mc.mouseWheelEnabled = b;
			}
		}
		
		private function disableMouseWheelOnOut(e:MouseEvent) : void
		{
			this.m_scrollbar_mc.mouseWheelEnabled = false;
		}
		
		private function enableMouseWheelOnOver(e:MouseEvent) : void
		{
			this.m_scrollbar_mc.mouseWheelEnabled = true;
		}
		
		public function checkScrollBar() : void
		{
			if(this.m_allowAutoScroll)
			{
				this.m_scrollbar_mc.scrollTo(this.m_scrollbar_mc.m_scrolledY);
			}
			this.m_scrollbar_mc.m_contentFrameHeight = height;
			this.m_scrollbar_mc.m_contentHeight = this.m_ScrollHeight;
			this.m_scrollbar_mc.scrollbarVisible();
		}
		
		override public function setFrameWidth(w:Number) : void
		{
			this.width = w;
			this.calculateScrollRect();
		}
		
		override public function setFrame(w:Number, h:Number) : void
		{
			this.width = w;
			this.height = h;
			this.calculateScrollRect();
		}
		
		public function setFrameHeight(h:Number) : void
		{
			this.height = h;
			this.calculateScrollRect();
		}
		
		private function calculateScrollRect() : void
		{
			this.containerContent_mc.scrollRect = new Rectangle(0,0,width,height);
			this.m_scrollbar_mc.x = this.m_SBSpacing + width;
			this.m_scrollbar_mc.addContent(containerContent_mc);
			this.checkScrollBar();
			this.updateScrollHit();
		}
		
		override public function positionElements() : void
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
		
		public function set scrollbarSpacing(param1:Number) : void
		{
			this.m_SBSpacing = param1;
			this.m_scrollbar_mc.x = width + this.m_SBSpacing + this.m_scrollbar_mc.width;
		}
		
		public function set SB_SPACING(param1:Number) : void
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
