package LS_Classes
{
	import flash.events.Event;
	import flash.geom.Rectangle;
	
	public class grid extends listDisplay
	{
		 
		
		protected var m_row:uint = 3;
		
		protected var m_col:uint = 9;
		
		protected var m_maxPages:uint = 1;
		
		protected var m_currpage:uint = 1;
		
		public var ROW_SPACING:Number = 4;
		
		public var m_centered:Boolean = false;
		
		public var m_gridAlign:Number = 0;
		
		public function grid()
		{
			super();
			this.m_currpage = 1;
		}
		
		override public function positionElements() : *
		{
			if(content_array.length < 1)
			{
				return;
			}
			var val1:Number = m_sideSpacing;
			var val2:Number = 0;
			var val3:uint = 0;
			if(m_NeedsSorting)
			{
				INTSort();
			}
			if(this.m_centered)
			{
				val2 = Math.round(getElementWidth(content_array[0]) * 0.5);
			}
			var val4:Boolean = true;
			var val5:Number = m_topSpacing;
			var val6:uint = 0;
			var val7:uint = 0;
			var val8:uint = 1;
			if(this.m_gridAlign == 0)
			{
				val3 = 0;
				while(val3 < content_array.length)
				{
					this.m_maxPages = val8;
					if(!content_array[val3].m_filteredObject)
					{
						content_array[val3].x = val2 + val1;
						content_array[val3].y = val5;
						val1 = val1 + Math.round(getElementWidth(content_array[val3]) + EL_SPACING);
						if(!m_hasScrollRect)
						{
							if(this.m_currpage == val8)
							{
								if(val4)
								{
									m_CurrentSelection = content_array[val3];
									val4 = false;
								}
								content_array[val3].visible = true;
							}
							else
							{
								content_array[val3].visible = false;
							}
						}
						val6++;
						if(val6 >= this.m_col)
						{
							val6 = 0;
							val7++;
							val1 = m_sideSpacing;
							val5 = val5 + Math.round(getElementHeight(content_array[val3]) + this.ROW_SPACING);
						}
						if(this.m_row != 0 && val7 >= this.m_row)
						{
							if(!m_hasScrollRect)
							{
								val2 = 0;
							}
							else
							{
								val2 = Math.round(content_array[val3].x + getElementWidth(content_array[val3]) + EL_SPACING);
							}
							val1 = m_sideSpacing;
							val5 = m_topSpacing;
							val8++;
							val7 = 0;
							val6 = 0;
						}
					}
					val3++;
				}
			}
			else
			{
				if(this.m_col > content_array.length)
				{
					val1 = Math.round((this.m_col - content_array.length) * (getElementWidth(content_array[0]) + EL_SPACING));
				}
				val3 = 0;
				while(val3 < content_array.length)
				{
					this.m_maxPages = val8;
					content_array[val3].x = val2 + val1;
					content_array[val3].y = val5;
					val1 = val1 + (getElementWidth(content_array[val3]) + EL_SPACING);
					if(!m_hasScrollRect)
					{
						if(this.m_currpage == val8)
						{
							if(val4)
							{
								m_CurrentSelection = content_array[val3];
								val4 = false;
							}
							content_array[val3].visible = true;
						}
						else
						{
							content_array[val3].visible = false;
						}
					}
					val6++;
					if(val6 >= this.m_col)
					{
						if(this.m_col > content_array.length - val3)
						{
							val1 = Math.round((this.m_col + 1 - (content_array.length - val3)) * (getElementWidth(content_array[val3]) + EL_SPACING));
						}
						else
						{
							val1 = m_sideSpacing;
						}
						val6 = 0;
						val7++;
						val5 = val5 + (Math.round(getElementHeight(content_array[val3]) + this.ROW_SPACING) + m_topSpacing);
					}
					if(this.m_row != 0 && val7 >= this.m_row)
					{
						if(!m_hasScrollRect)
						{
							val2 = 0;
						}
						else
						{
							val2 = Math.round(content_array[val3].x + getElementWidth(content_array[val3]) + EL_SPACING);
						}
						val1 = m_sideSpacing;
						val5 = m_topSpacing;
						val8++;
						val7 = 0;
						val6 = 0;
					}
					val3++;
				}
			}
			if(m_NeedsSorting)
			{
				m_NeedsSorting = false;
				dispatchEvent(new Event("listSorted"));
			}
		}
		
		public function getCurrRow() : Number
		{
			if(m_CurrentSelection)
			{
				return this.getRowOfElement(m_CurrentSelection.list_pos);
			}
			return -1;
		}
		
		public function selectPos(param1:Number, param2:Number, param3:Boolean = false) : *
		{
			var val4:Number = param1 * this.m_col + param2;
			if(val4 >= 0 && val4 < content_array.length)
			{
				select(val4,param3);
			}
		}
		
		public function nextPage() : *
		{
			this.setPage(this.m_currpage + 1);
		}
		
		public function previousPage() : *
		{
			this.setPage(this.m_currpage - 1);
		}
		
		public function nextRow() : *
		{
			select(currentSelection + this.m_col);
		}
		
		public function previousRow() : *
		{
			var val1:Number = this.getRowOfElement(currentSelection);
			if(val1 != 0)
			{
				select(currentSelection - this.m_col);
			}
		}
		
		public function previousCol() : Boolean
		{
			var val1:Boolean = false;
			var val2:Number = this.getRowOfElement(currentSelection);
			var val3:Number = this.getRowOfElement(currentSelection - 1);
			if(currentSelection != 0 && val2 == val3)
			{
				super.previous();
				val1 = true;
			}
			return val1;
		}
		
		public function nextCol() : Boolean
		{
			var val1:Boolean = false;
			var val2:Number = this.getRowOfElement(currentSelection);
			var val3:Number = this.getRowOfElement(currentSelection + 1);
			if(currentSelection != content_array.length - 1 && val2 == val3)
			{
				super.next();
				val1 = true;
			}
			return val1;
		}
		
		private function getRowOfElement(param1:Number) : Number
		{
			var val2:Number = Math.floor(param1 / this.m_col);
			return val2;
		}
		
		private function getColOfElement(param1:Number) : Number
		{
			return Math.floor(param1 / this.m_row);
		}
		
		override public function clearElements() : *
		{
			this.m_currpage = 1;
			this.m_maxPages = 1;
			super.clearElements();
		}
		
		public function setPage(param1:Number) : *
		{
			var val2:Number = NaN;
			var val3:Rectangle = null;
			if(param1 > 0 && this.m_currpage != param1 && content_array.length > 0)
			{
				if(param1 <= 1)
				{
					param1 = 1;
				}
				else if(param1 > this.m_maxPages)
				{
					param1 = this.m_maxPages;
				}
				this.m_currpage = param1;
				if(m_hasScrollRect)
				{
					val2 = container_mc.scrollRect.width;
					val3 = new Rectangle((param1 - 1) * val2,0,val2,container_mc.scrollRect.height);
					container_mc.scrollRect = val3;
				}
				else
				{
					this.positionElements();
				}
				dispatchEvent(new Event(Event.CHANGE));
			}
		}
		
		public function refreshPage() : *
		{
			var val1:uint = this.m_currpage;
			this.m_currpage = 1;
			this.setPage(val1);
		}
		
		public function get col() : uint
		{
			return this.m_col;
		}
		
		public function set col(param1:uint) : void
		{
			this.m_col = param1;
			this.refreshPage();
		}
		
		public function get row() : uint
		{
			return this.m_row;
		}
		
		public function set row(param1:uint) : void
		{
			this.m_row = param1;
			this.refreshPage();
		}
		
		public function getRow(param1:uint) : uint
		{
			return Math.ceil((param1 + 1) / this.col);
		}
		
		public function getCol(param1:uint) : uint
		{
			var val2:Number = this.getRow(param1);
			return Math.ceil(param1 - (val2 - 1) * this.col);
		}
		
		public function get rowsUsed() : uint
		{
			return Math.ceil(content_array.length / this.m_col);
		}
		
		public function get maxPages() : uint
		{
			return this.m_maxPages;
		}
		
		public function get currPage() : uint
		{
			return this.m_currpage;
		}
		
		override public function cursorLeft() : *
		{
			var val1:Number = NaN;
			var val2:Number = NaN;
			var val3:Number = NaN;
			if(currentSelection == -1)
			{
				select(0);
			}
			else
			{
				val1 = currentSelection - 1;
				val2 = this.getRow(currentSelection);
				val3 = this.getRow(val1);
				if(val1 >= 0 && val2 == val3)
				{
					select(val1);
				}
			}
		}
		
		override public function cursorRight() : *
		{
			var val1:Number = NaN;
			var val2:Number = NaN;
			if(currentSelection == -1)
			{
				select(0);
			}
			else
			{
				val1 = this.getRow(currentSelection);
				val2 = this.getRow(currentSelection + 1);
				if(val1 == val2)
				{
					select(currentSelection + 1);
				}
			}
		}
		
		override public function cursorUp() : *
		{
			var val1:Number = NaN;
			if(currentSelection == -1)
			{
				select(0);
			}
			else
			{
				val1 = currentSelection - this.col;
				if(val1 >= 0)
				{
					select(val1);
				}
			}
		}
		
		override public function cursorDown() : *
		{
			var val1:Number = NaN;
			if(currentSelection == -1)
			{
				select(0);
			}
			else
			{
				val1 = currentSelection + this.col;
				if(val1 < content_array.length)
				{
					select(val1);
				}
			}
		}
	}
}
