package LS_Classes
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.getDefinitionByName;
	
	public class scrollListGrouped extends listDisplay
	{
		public var m_scrollbar_mc:scrollbar;
		public var m_bottomAligned:Boolean = false;
		public var m_allowAutoScroll:Boolean = true;
		private var m_SBSpacing:Number = 10;
		public var m_HideEmptyGroups:Boolean = false;
		private var m_mouseWheelWhenOverEnabled:Boolean = false;
		private var m_mouseWheelEnabled:Boolean = false;
		private var m_ScrollHeight:Number = 0;
		private var m_FixedSelectionPosition:Number = -1;
		public var m_GroupHeaderHeight:Number = 52;
		public var m_SelectGroups:Boolean = true;
		public var m_CustomGroupElementHeight:Boolean = false;
		public var m_ScrollOverShoot:Number = 0;
		public var m_ScrollUnderShoot:Number = 0;
		public var m_allowKeepIntoView:Boolean = true;
		private var m_ElSortOnFieldName:Object = null;
		private var m_ElSortOnOptions:Object = null;
		private var groupClass:Class;
		private var gIdCounter:Number = 0;
		private var m_groupedScroll:Boolean = true;
		private var m_preventScrollUpdate:Boolean = false;
		private var m_frameHit_mc:MovieClip;
		private var m_SubElementSpacing:Number = -1;
		public var m_ToggleSelections:Boolean = false;
		public var m_ClearClosedGroups:Boolean = false;
		
		public function scrollListGrouped(param1:String = "down_id", param2:String = "up_id", param3:String = "handle_id", param4:String = "scrollBg_id", param5:String = "", param6:String = "")
		{
			this.groupClass = MovieClip;
			this.m_frameHit_mc = new MovieClip();
			var sprite:Sprite = new Sprite();
			sprite.graphics.lineStyle(0,16777215);
			sprite.graphics.beginFill(16777215);
			sprite.graphics.drawRect(0,0,1,1);
			sprite.graphics.endFill();
			this.m_frameHit_mc.addChild(sprite);
			sprite.alpha = 0;
			this.addChild(this.m_frameHit_mc);
			this.m_scrollbar_mc = new scrollbar(param1,param2,param3,param4,param5,param6);
			super();
			this.m_scrollbar_mc.visible = false;
			this.addChild(this.m_scrollbar_mc);
			this.m_scrollbar_mc.addEventListener(Event.CHANGE,this.updateBGPos);
			OnSelectionChanged = this.selectionChangedFunc;
		}
		
		public function set fixedSelectionPosition(param1:Number) : *
		{
			this.m_FixedSelectionPosition = param1;
			this.m_scrollbar_mc.noContent();
			this.m_scrollbar_mc.visible = true;
		}
		
		public function get fixedSelectionPosition() : Number
		{
			return this.m_FixedSelectionPosition;
		}
		
		public function selectionChangedFunc() : *
		{
			this.updateScroll();
		}
		
		public function set overShoot(param1:Number) : *
		{
			this.m_ScrollOverShoot = param1;
			this.m_scrollbar_mc.m_scrollOverShoot = param1;
		}
		
		public function get groupedScroll() : Boolean
		{
			return this.m_groupedScroll;
		}
		
		public function set groupedScroll(param1:Boolean) : *
		{
			this.m_groupedScroll = param1;
		}
		
		public function set SUBEL_SPACING(param1:Number) : *
		{
			this.m_SubElementSpacing = param1;
			var val2:uint = 0;
			while(val2 < content_array.length)
			{
				if(content_array[val2].list)
				{
					content_array[val2].list.EL_SPACING = this.m_SubElementSpacing == -1 ? EL_SPACING : this.m_SubElementSpacing;
				}
				val2++;
			}
		}
		
		public function get SUBEL_SPACING() : Number
		{
			return this.m_SubElementSpacing;
		}
		
		public function setGroupMC(param1:String) : *
		{
			this.groupClass = getDefinitionByName(param1) as Class;
		}
		
		override public function set canPositionInvisibleElements(param1:Boolean) : *
		{
			var val2:MovieClip = null;
			if(super.canPositionInvisibleElements != param1)
			{
				super.canPositionInvisibleElements = param1;
				for each(val2 in content_array)
				{
					val2.list.canPositionInvisibleElements = param1;
				}
				this.positionElements();
			}
		}
		
		public function addGroup(param1:Number, param2:String, param3:Boolean = true) : MovieClip
		{
			var val4:MovieClip;
			if((val4 = getElementByNumber("groupId",param1)) == null)
			{
				(val4 = new this.groupClass()).list = new listDisplay();
				val4.list.m_cyclic = false;
				val4.list.EL_SPACING = this.m_SubElementSpacing == -1 ? EL_SPACING : this.m_SubElementSpacing;
				if(val4.listContainer_mc == null)
				{
					val4.listContainer_mc = new MovieClip();
					val4.addChild(val4.listContainer_mc);
				}
				val4.listContainer_mc.addChild(val4.list);
				addElement(val4,param3);
				val4._isOpen = false;
				val4.groupId = param1;
				val4.mainList = this;
				val4.isNew = true;
				if(this.m_ElSortOnFieldName)
				{
					val4.list.sortOn(this.m_ElSortOnFieldName,this.m_ElSortOnOptions);
				}
			}
			else
			{
				val4.isNew = false;
			}
			if(val4 && val4.title_txt != null)
			{
				val4.title_txt.htmlText = param2;
			}
			return val4;
		}
		
		public function addGroupElement(param1:Number, param2:MovieClip, param3:Boolean = true) : MovieClip
		{
			var val4:MovieClip;
			if(val4 = getElementByNumber("groupId",param1))
			{
				param2.gId = this.gIdCounter++;
				param2.groupId = param1;
				param2.mainList = this;
				param2.grpMc = val4;
				val4.list.addElement(param2,param3);
				if(param3)
				{
					this.positionElements();
				}
				if(val4.onElementAdded)
				{
					val4.onElementAdded(param2);
				}
			}
			else
			{
				ExternalInterface.call("UIAssert","scrollListGrouped::addGroupElement groupId:" + param1 + " GROUP NOT FOUND");
			}
			return val4;
		}
		
		public function elementsSortOn(param1:Object, param2:Object = null) : *
		{
			this.m_ElSortOnFieldName = param1;
			this.m_ElSortOnOptions = param2;
			var val3:uint = 0;
			while(val3 < content_array.length)
			{
				if(content_array[val3].list)
				{
					content_array[val3].list.sortOn(param1,param2);
				}
				val3++;
			}
		}
		
		public function clearGroup(param1:Number, param2:Boolean = false) : *
		{
			var val3:MovieClip = getElementByNumber("groupId",param1);
			if(val3)
			{
				this.clearElementsOfList(val3.list);
				if(param2)
				{
					this.positionElements();
				}
			}
		}
		
		public function clearGroupElements() : *
		{
			var val1:uint = 0;
			while(val1 < content_array.length)
			{
				if(content_array[val1].list)
				{
					this.clearElementsOfList(content_array[val1].list);
				}
				val1++;
			}
		}
		
		public function clearElementsOfList(param1:listDisplay) : *
		{
			var val2:uint = 0;
			while(val2 < param1.content_array.length)
			{
				if(param1.content_array[val2])
				{
					if(param1.content_array[val2].tweening)
					{
						stopElementMCTweens(param1.content_array[val2]);
					}
					param1.containerContent_mc.removeChild(param1.content_array[val2]);
					param1.content_array[val2] = null;
				}
				val2++;
			}
			param1.content_array = new Array();
			param1.idInc = 0;
			param1.m_CurrentSelection = null;
		}
		
		override public function cleanUpElements() : *
		{
			var val1:uint = 0;
			while(val1 < content_array.length)
			{
				this.content_array[val1].list.cleanUpElements();
				if(this.m_HideEmptyGroups)
				{
					this.content_array[val1].visible = this.content_array[val1].list.visibleLength > 0;
				}
				val1++;
			}
			this.positionElements2();
		}
		
		override public function positionElements() : *
		{
			if(this.content_array.length < 1)
			{
				return;
			}
			var val1:uint = 0;
			while(val1 < this.content_array.length)
			{
				this.content_array[val1].list.positionElements();
				if(this.content_array[val1].setGroupAmount)
				{
					this.content_array[val1].setGroupAmount(this.content_array[val1].list.visibleLength);
				}
				val1++;
			}
			this.positionElements2();
		}
		
		public function positionElements2() : *
		{
			if(this.content_array.length == 0)
			{
				return;
			}
			if(this.m_NeedsSorting && this.m_SortOnFieldName && this.content_array && this.content_array.length > 1)
			{
				this.content_array.sortOn(this.m_SortOnFieldName,this.m_SortOnOptions);
			}
			var val1:Number = TOP_SPACING;
			var val2:uint = 0;
			while(val2 < this.content_array.length)
			{
				this.content_array[val2].list_pos = val2;
				this.content_array[val2].y = val1;
				this.content_array[val2].x = SIDE_SPACING;
				if(this.canPositionInvisibleElements || this.content_array[val2].visible)
				{
					val1 += this.getElementHeight(content_array[val2]) + EL_SPACING;
				}
				val2++;
			}
			this.checkScrollBar();
			if(this.m_bottomAligned && this.m_allowKeepIntoView)
			{
				this.m_scrollbar_mc.alignContentToBottom();
			}
		}
		
		override public function next() : *
		{
			var val2:MovieClip = null;
			var val3:Number = NaN;
			var val4:MovieClip = null;
			var val5:MovieClip = null;
			var val6:Number = NaN;
			var val7:Number = NaN;
			var val8:MovieClip = null;
			var val1:MovieClip = this.getCurrentGroup();
			if(val1 && val1.visible && val1._isOpen && val1.list.visibleLength > 0)
			{
				val2 = val1.list.getCurrentMovieClip();
				if(val2)
				{
					if(val2.list_pos > val1.list.getLastVisible().list_pos - 1)
					{
						if(!this.m_SelectGroups)
						{
							if(val2.INTSelectNext == null || !val2.INTSelectNext())
							{
								if(getLastVisible() == val1 && m_cyclic)
								{
									this.selectFirstVisible();
								}
								else
								{
									val3 = val1.list_pos + 1;
									while(val3 < content_array.length)
									{
										if((val4 = content_array[val3]) && val4.visible && val4._isOpen && val4.list.visibleLength > 0)
										{
											val1.list.selectMC(null);
											this.select(val3);
											if(val4.deselectElement)
											{
												val4.deselectElement();
											}
											val4.list.select(0);
											break;
										}
										val3++;
									}
								}
							}
							else if(val2.deselectElement)
							{
								val2.deselectElement();
							}
						}
						else if(getLastVisible() == val1 && m_cyclic)
						{
							this.selectFirstVisible();
						}
						else if(val1.list_pos < content_array.length - 1)
						{
							val5 = content_array[val1.list_pos + 1];
							val6 = val1.list_pos + 2;
							while(val6 < content_array.length && (!val5 || !val5.visible))
							{
								val5 = content_array[val6];
								val6++;
							}
							if(val5 && val5.visible)
							{
								val1.list.selectMC(null);
								this.selectMC(val5);
							}
						}
					}
					else
					{
						val1.list.next();
					}
				}
				else
				{
					if(val1.deselectElement)
					{
						val1.deselectElement();
					}
					val1.list.select(0);
				}
			}
			else if(!this.m_SelectGroups)
			{
				val7 = 0;
				while(val7 < content_array.length)
				{
					if((val8 = content_array[val7]) && val8.visible && val8._isOpen && val8.list.length > 0)
					{
						select(val7);
						if(val8.deselectElement)
						{
							val8.deselectElement();
						}
						val8.list.select(0);
						break;
					}
					val7++;
				}
			}
			else
			{
				super.next();
			}
			this.updateScroll();
		}
		
		override public function previous() : *
		{
			var val3:MovieClip = null;
			var val4:MovieClip = null;
			var val5:Number = NaN;
			var val6:Number = NaN;
			var val7:MovieClip = null;
			var val8:MovieClip = null;
			var val9:MovieClip = null;
			var val10:Boolean = false;
			var val1:Boolean = false;
			var val2:MovieClip = this.getCurrentGroup();
			if(val2 && val2._isOpen && val2.visible && val2.list.length > 0)
			{
				val3 = val2.list.getCurrentMovieClip();
				if(val3)
				{
					if(!val3.INTSelectPrevious || !val3.INTSelectPrevious())
					{
						if(val3.list_pos == 0 || val3 == val2.list.getFirstVisible())
						{
							if(this.m_SelectGroups)
							{
								val2.list.selectMC(null);
								this.selectMC(val2,true);
							}
							else
							{
								val1 = true;
							}
						}
						else
						{
							val2.list.previous();
						}
					}
				}
				else
				{
					val1 = true;
				}
			}
			else
			{
				val1 = true;
			}
			if(val1 && val2)
			{
				if(this.m_SelectGroups)
				{
					val2.list.selectMC(null);
					if(val2.list_pos > 0)
					{
						val4 = content_array[val2.list_pos - 1];
						val5 = val2.list_pos - 2;
						while(val5 >= 0 && (!val4 || !val4.visible))
						{
							val4 = content_array[val5];
							val5--;
						}
						if(val4 && val4.visible)
						{
							this.m_preventScrollUpdate = true;
							this.selectMC(val4);
							this.m_preventScrollUpdate = false;
							if(val4._isOpen && val4.visible && val4.list.length > 0)
							{
								if(val4.deselectElement)
								{
									val4.deselectElement();
								}
								val4.list.select(val4.list.length - 1);
							}
						}
					}
					else if(m_cyclic)
					{
						if(val4 = getLastVisible())
						{
							this.selectMC(val4);
							this.m_preventScrollUpdate = false;
							if(val4._isOpen && val4.visible && val4.list.length > 0)
							{
								if(val4.deselectElement)
								{
									val4.deselectElement();
								}
								val4.list.selectLastElement();
							}
						}
					}
				}
				else if(val2.list_pos > 0)
				{
					val6 = val2.list_pos - 1;
					while(val6 >= 0)
					{
						if((val7 = content_array[val6]) && val7.visible && val7._isOpen && val7.list.length > 0)
						{
							val2.list.selectMC(null);
							select(val6);
							if(val7.deselectElement)
							{
								val7.deselectElement();
							}
							val8 = val7.list.getLastVisible();
							val7.list.selectMC(val8);
							val3 = val7.list.getCurrentMovieClip();
							if(val3 && val3.INTSelectLast != null && val3.INTSelectLast() && val8.deselectElement)
							{
								val8.deselectElement();
							}
							break;
						}
						val6--;
					}
				}
				else
				{
					val9 = val3;
					val3 = val2.list.getCurrentMovieClip();
					if(val9 && val3)
					{
						if(val3 != val9)
						{
							if(val3.INTSelectLast == null || !val3.INTSelectLast())
							{
								this.selectFirstVisible();
							}
						}
						else if(val3.INTSelectPrevious != null && !val3.INTSelectPrevious())
						{
							val10 = false;
							if(val2 == getFirstVisible() && m_cyclic)
							{
								selectLastElement();
								val2 = this.getCurrentGroup();
								if(val2)
								{
									val2.list.selectLastElement();
									val3 = val2.list.getCurrentMovieClip();
									if(val3.INTSelectLast != null)
									{
										val10 = val3.INTSelectLast();
									}
								}
							}
							if(!val10 && val3.INTDeselect && val3.INTDeselect() && val3.selectElement)
							{
								val3.selectElement();
							}
						}
					}
				}
			}
			this.updateScroll();
		}
		
		override public function getCurrentMovieClip() : MovieClip
		{
			var val2:MovieClip = null;
			var val1:MovieClip = this.getCurrentGroup();
			if(val1)
			{
				if(val1.list)
				{
					val2 = val1.list.getCurrentMovieClip();
					if(val2)
					{
						return val2;
					}
				}
			}
			return m_CurrentSelection;
		}
		
		public function getCurrentGroup() : MovieClip
		{
			return m_CurrentSelection;
		}
		
		public function isFirstElementSelected() : Boolean
		{
			var val1:Boolean = false;
			var val2:MovieClip = this.getCurrentMovieClip();
			var val3:MovieClip = this.getCurrentGroup();
			if(val3 == getFirstVisible() && val2 == val3.list.getFirstVisible())
			{
				val1 = true;
			}
			return val1;
		}
		
		public function updateScroll() : *
		{
			var val1:MovieClip = null;
			var val2:MovieClip = null;
			var val3:Number = NaN;
			var val4:Number = NaN;
			var val5:Number = NaN;
			var val6:MovieClip = null;
			var val7:Point = null;
			var val8:Number = NaN;
			var val9:Number = NaN;
			var val10:Number = NaN;
			var val11:MovieClip = null;
			if(!this.m_preventScrollUpdate && this.m_allowKeepIntoView && this.m_FixedSelectionPosition == -1)
			{
				val1 = this.getCurrentMovieClip();
				val2 = this.getCurrentGroup();
				if(val2)
				{
					if(val1 && val1 != val2)
					{
						val3 = val2.list.getElementHeight(val1);
						if(this.isFirstElementSelected())
						{
							this.m_scrollbar_mc.scrollIntoView(0,val3 + this.m_ScrollOverShoot);
						}
						else
						{
							val4 = val1.y + val2.y - TOP_SPACING - this.m_ScrollUnderShoot;
							if(this.m_CustomGroupElementHeight)
							{
								if(!val2.m_GroupElementHeight)
								{
									ExternalInterface.call("UIAssert","Group element height is undefined (groupClass.m_GroupElementHeight)");
								}
								val4 += val2.m_GroupElementHeight;
							}
							else
							{
								val4 += val2.listContainer_mc.y;
							}
							this.m_scrollbar_mc.scrollIntoView(val4,val3 + (this.m_ScrollOverShoot + this.m_ScrollUnderShoot));
						}
					}
					else
					{
						val5 = val2.y - TOP_SPACING - this.m_ScrollUnderShoot;
						if(this.m_groupedScroll)
						{
							this.m_scrollbar_mc.scrollIntoView(val5,this.getElementHeight(val2) + this.m_ScrollOverShoot + this.m_ScrollUnderShoot);
						}
						else
						{
							this.m_scrollbar_mc.scrollIntoView(val5,this.m_GroupHeaderHeight + this.m_ScrollOverShoot + this.m_ScrollUnderShoot);
						}
					}
				}
			}
			else if(this.m_FixedSelectionPosition != -1)
			{
				if(val6 = this.getCurrentMovieClip())
				{
					val7 = LSDisplayObjectHelpers.getRelativePosition(val6,containerContent_mc);
					val8 = 0;
					if(val6.INTGetSelectOffset)
					{
						val8 = val6.INTGetSelectOffset();
					}
					val9 = val7.y + val8 - this.m_FixedSelectionPosition;
					val10 = 0;
					if(!this.m_SelectGroups)
					{
						if(val11 = getFirstVisible())
						{
							val10 = val11.listContainer_mc.y;
						}
					}
					this.m_scrollbar_mc.scrollToPercent(Math.round(val7.y + val8 - val10 + this.getElementHeight(val6) * 0.5) / containerContent_mc.height,false);
					containerContent_mc.scrollRect = new Rectangle(0,val9,width,height);
				}
			}
		}
		
		public function getGroupInView(param1:MovieClip) : *
		{
			if(this.m_allowKeepIntoView)
			{
				this.m_scrollbar_mc.scrollIntoView(param1.y,this.getElementHeight(param1) + this.m_ScrollOverShoot);
			}
		}
		
		public function checkScrollbarBottom() : *
		{
			if(this.m_allowKeepIntoView)
			{
				this.m_scrollbar_mc.scrollToFit();
			}
		}
		
		public function ResetSelection() : *
		{
			var val1:MovieClip = this.getCurrentGroup();
			if(val1)
			{
				val1.list.selectMC(null);
			}
			this.selectMC(null);
		}
		
		override public function selectFirstVisible(param1:Boolean = true) : *
		{
			var val2:Number = NaN;
			var val3:MovieClip = null;
			this.ResetSelection();
			if(this.m_SelectGroups)
			{
				super.selectFirstVisible(param1);
			}
			else
			{
				val2 = 0;
				while(val2 < content_array.length)
				{
					val3 = content_array[val2];
					if(val3 && val3.visible && val3._isOpen && val3.list.length > 0)
					{
						select(val2,param1);
						val3.list.selectFirstVisible(param1);
						break;
					}
					val2++;
				}
			}
			this.updateScroll();
		}
		
		override public function selectByOffset(param1:Number, param2:Boolean = false) : Boolean
		{
			var val4:uint = 0;
			var val5:MovieClip = null;
			var val6:Number = NaN;
			var val7:Boolean = false;
			var val3:Boolean = false;
			if(param2)
			{
				return super.selectByOffset(param1,param2);
			}
			param1 += TOP_SPACING;
			param1 += this.m_scrollbar_mc.scrolledY;
			val4 = 0;
			while(val4 < content_array.length)
			{
				if((val5 = content_array[val4]) && val5.visible)
				{
					val6 = this.getElementHeight(val5);
					if(val5.y <= param1 && val5.y + val6 > param1)
					{
						val3 = true;
						val7 = false;
						this.selectMC(val5);
						if(val5._isOpen)
						{
							val7 = val5.list.selectByOffset(param1 - (val5.y + val5.listContainer_mc.y));
						}
						break;
					}
				}
				val4++;
			}
			return val3;
		}
		
		public function selectFirst() : *
		{
			var val1:MovieClip = null;
			this.ResetSelection();
			if(this.m_SelectGroups)
			{
				select(0,true);
			}
			else
			{
				val1 = content_array[0];
				if(val1 && val1._isOpen && val1.list.length > 0)
				{
					select(0,true);
					val1.list.select(0);
				}
			}
			this.updateScroll();
		}
		
		public function checkScrollBar() : *
		{
			if(this.m_allowAutoScroll && this.m_allowKeepIntoView)
			{
				this.m_scrollbar_mc.scrollTo(this.m_scrollbar_mc.m_scrolledY);
			}
			this.m_scrollbar_mc.m_contentFrameHeight = height;
			var val1:Number = 0;
			var val2:MovieClip = getLastVisible();
			if(val2)
			{
				val1 = val2.y + this.getElementHeight(val2);
			}
			this.m_ScrollHeight = this.m_scrollbar_mc.m_contentHeight = val1;
			this.m_scrollbar_mc.scrollbarVisible();
		}
		
		override public function set TOP_SPACING(param1:Number) : *
		{
			this.m_scrollbar_mc.m_extraSpacing = param1 * 2;
			super.TOP_SPACING = param1;
		}
		
		private function updateBGPos(param1:Event) : *
		{
			containerBG_mc.scrollRect = containerContent_mc.scrollRect;
			dispatchEvent(new Event(Event.CHANGE));
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
			var val3:Boolean = true;
			if(param1 && m_CurrentSelection && param1.list_pos < m_CurrentSelection.list_pos)
			{
				val3 = false;
			}
			if(param1 && param1.grpMc != null)
			{
				if(m_CurrentSelection && m_CurrentSelection != param1.grpMc)
				{
					m_CurrentSelection.list.clearSelection();
				}
				super.selectMC(param1.grpMc,param2);
				param1.grpMc.list.selectMC(param1,param2);
				dispatchEvent(new Event(Event.CHANGE));
			}
			else
			{
				if(m_CurrentSelection && m_CurrentSelection != param1)
				{
					m_CurrentSelection.list.clearSelection();
				}
				super.selectMC(param1,param2);
				dispatchEvent(new Event(Event.CHANGE));
			}
			if(this.m_scrollbar_mc.visible && this.m_allowAutoScroll)
			{
				this.updateScroll();
			}
		}
		
		override public function clearSelection() : *
		{
			if(m_CurrentSelection)
			{
				m_CurrentSelection.list.clearSelection();
				super.clearSelection();
			}
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
		
		override public function setFrameWidth(param1:Number) : *
		{
			width = param1;
			containerContent_mc.scrollRect = new Rectangle(0,0,param1,height);
			this.m_scrollbar_mc.x = this.m_SBSpacing + param1;
			if(this.m_FixedSelectionPosition == -1)
			{
				this.m_scrollbar_mc.addContent(containerContent_mc);
			}
			this.m_frameHit_mc.width = param1;
		}
		
		override public function setFrame(param1:Number, param2:Number) : *
		{
			width = param1;
			height = param2;
			containerContent_mc.scrollRect = new Rectangle(0,0,param1,param2);
			this.m_scrollbar_mc.x = this.m_SBSpacing + param1;
			if(this.m_FixedSelectionPosition == -1)
			{
				this.m_scrollbar_mc.addContent(containerContent_mc);
			}
			this.checkScrollBar();
			this.m_frameHit_mc.width = param1;
			this.m_frameHit_mc.height = param2;
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
		
		public function onAction() : void
		{
			var val1:MovieClip = this.getCurrentMovieClip();
			if(val1)
			{
				if(val1.list)
				{
					if(val1._isOpen && this.m_ClearClosedGroups)
					{
						this.clearElementsOfList(val1.list);
					}
					if(this.m_ToggleSelections && !val1._isOpen)
					{
						this.collapseAll();
					}
				}
				if(val1.onAction)
				{
					val1.onAction();
				}
			}
		}
		
		public function collapseAll(param1:Boolean = true) : void
		{
			var val2:uint = 0;
			while(val2 < content_array.length)
			{
				if(content_array[val2].list && content_array[val2]._isOpen)
				{
					if(content_array[val2].closeEntry)
					{
						content_array[val2].closeEntry(param1);
					}
					if(this.m_ClearClosedGroups)
					{
						this.clearElementsOfList(content_array[val2].list);
					}
				}
				val2++;
			}
			if(param1)
			{
				this.positionElements();
			}
		}
		
		public function unCollapseAll(param1:Boolean = true) : void
		{
			var val2:uint = 0;
			while(val2 < content_array.length)
			{
				if(content_array[val2].list && !content_array[val2]._isOpen && content_array[val2].openEntry)
				{
					content_array[val2].openEntry(param1);
				}
				val2++;
			}
			if(param1)
			{
				this.positionElements();
			}
		}
		
		override public function getElementHeight(param1:MovieClip) : Number
		{
			var val3:MovieClip = null;
			var val4:MovieClip = null;
			var val2:Number = param1.height;
			if(param1.heightOverride != undefined && !isNaN(param1.heightOverride))
			{
				val2 = param1.heightOverride;
			}
			else if(m_customElementHeight != -1)
			{
				val2 = m_customElementHeight;
			}
			else
			{
				val3 = null;
				if(param1.list)
				{
					val3 = param1.list.getLastVisible();
					if(val3)
					{
						val2 = val3.height + val3.y + param1.listContainer_mc.y;
					}
				}
				else if(val4 = getElementByNumber("groupId",param1.groupId))
				{
					val3 = val4.list.getLastVisible();
					if(val3)
					{
						val2 = val3.height + val3.y;
					}
				}
			}
			return val2;
		}
		
		public function getGroupElementByNumber(param1:String, param2:Number) : MovieClip
		{
			var val4:MovieClip = null;
			var val3:MovieClip = null;
			for each(val4 in content_array)
			{
				val3 = val4.list.getElementByNumber(param1,param2);
				if(val3)
				{
					break;
				}
			}
			return val3;
		}
		
		public function getGroupElementByString(param1:String, param2:String) : MovieClip
		{
			var val4:MovieClip = null;
			var val3:MovieClip = null;
			for each(val4 in content_array)
			{
				val3 = val4.list.getElementByString(param1,param2);
				if(val3)
				{
					break;
				}
			}
			return val3;
		}
	}
}
