package LS_Classes
{
	import fl.motion.easing.Quartic;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	
	public class listDisplay extends MovieClip
	{
		public var content_array:Array;
		public var scrollHit_mc:MovieClip;
		public var container_mc:MovieClip;
		public var containerBG_mc:MovieClip;
		public var containerContent_mc:MovieClip;
		public var EL_SPACING:Number = 4;
		public var m_topSpacing:Number = 0;
		public var m_sideSpacing:Number = 0;
		public var m_cyclic:Boolean = false;
		public var m_customElementWidth:Number = -1;
		public var m_customElementHeight:Number = -1;
		public var m_forceDepthReorder:Boolean = false;
		public var m_CurrentSelection:MovieClip = null;
		public var idInc:uint = 0;
		protected var m_hasScrollRect:Boolean = false;
		public var OnSelectionChanged:Function = null;
		public var m_AlphaTweenFunc:Function;
		public var m_PositionTweenFunc:Function;
		protected var m_tweeningMcs:uint = 0;
		private var m_visibleLength:Number = -1;
		protected var m_NeedsSorting:Boolean = false;
		protected var m_SortOnFieldName:Object = null;
		protected var m_SortOnOptions:Object = null;
		protected var m_positionInvisibleElements:Boolean = false;
		protected var m_height:Number = -1;
		protected var m_width:Number = -1;
		public var m_myInterlinie:Number = 0;
		
		public function listDisplay()
		{
			this.content_array = new Array();
			this.scrollHit_mc = new MovieClip();
			this.container_mc = new MovieClip();
			this.containerBG_mc = new MovieClip();
			this.containerContent_mc = new MovieClip();
			this.m_AlphaTweenFunc = Quartic.easeIn;
			this.m_PositionTweenFunc = Quartic.easeOut;
			super();
			this.addChild(this.scrollHit_mc);
			this.scrollHit_mc.alpha = 0;
			this.addChild(this.container_mc);
			this.container_mc.addChild(this.containerBG_mc);
			this.container_mc.addChild(this.containerContent_mc);
			this.container_mc.x = 0;
		}
		
		override public function get width() : Number
		{
			if(this.m_width == -1)
			{
				return super.width;
			}
			return this.m_width;
		}
		
		override public function get height() : Number
		{
			if(this.m_height == -1)
			{
				return super.height;
			}
			return this.m_height;
		}
		
		public function get visibleHeight() : Number
		{
			var val1:Number = 0;
			var val2:MovieClip = this.getLastVisible(false);
			if(val2)
			{
				val1 = this.getElementHeight(val2) + val2.y;
			}
			return val1;
		}
		
		override public function set width(param1:Number) : void
		{
			this.m_width = param1;
			this.updateScrollHit();
		}
		
		override public function set height(param1:Number) : void
		{
			this.m_height = param1;
			this.updateScrollHit();
		}
		
		public function get length() : Number
		{
			return this.content_array.length;
		}
		
		public function get visibleLength() : Number
		{
			if(this.m_visibleLength == -1)
			{
				return this.length;
			}
			return this.m_visibleLength;
		}
		
		public function setFrameWidth(param1:Number) : *
		{
			this.setFrame(param1,this.container_mc.height);
		}
		
		public function setFrame(param1:Number, param2:Number) : *
		{
			this.m_width = param1;
			this.m_height = param2;
			this.updateScrollHit();
			this.container_mc.scrollRect = new Rectangle(0,0,param1,param2);
			this.m_hasScrollRect = true;
		}
		
		protected function updateScrollHit() : *
		{
			var val1:Sprite = null;
			if(this.scrollHit_mc.numChildren == 0)
			{
				val1 = new Sprite();
				val1.graphics.lineStyle(1,16777215);
				val1.graphics.beginFill(16777215);
				val1.graphics.drawRect(0,0,100,100);
				val1.graphics.endFill();
				this.scrollHit_mc.addChild(val1);
			}
			this.scrollHit_mc.width = this.width;
			this.scrollHit_mc.height = this.height;
		}
		
		public function getCurrentMovieClip() : MovieClip
		{
			return this.m_CurrentSelection;
		}
		
		public function get currentSelection() : Number
		{
			if(this.m_CurrentSelection)
			{
				return this.m_CurrentSelection.list_pos;
			}
			return -1;
		}
		
		public function get canPositionInvisibleElements() : Boolean
		{
			return this.m_positionInvisibleElements;
		}
		
		public function set canPositionInvisibleElements(param1:Boolean) : *
		{
			if(this.m_positionInvisibleElements != param1)
			{
				this.m_positionInvisibleElements = param1;
				this.positionElements();
			}
		}
		
		public function getElement(param1:Number) : MovieClip
		{
			if(param1 >= 0 && param1 < this.content_array.length)
			{
				return this.content_array[param1];
			}
			return null;
		}
		
		public function getAt(param1:Number) : MovieClip
		{
			if(param1 >= 0 && param1 < this.content_array.length)
			{
				return this.content_array[param1];
			}
			return null;
		}
		
		public function getElementByListID(param1:Number) : MovieClip
		{
			if(param1 == -1)
			{
				return null;
			}
			var val2:uint = 0;
			while(val2 < this.content_array.length)
			{
				if(this.content_array[val2] && this.content_array[val2].hasOwnProperty("list_id") && this.content_array[val2].list_id == param1)
				{
					this.content_array[val2].list_pos = val2;
					return this.content_array[val2];
				}
				val2++;
			}
			return null;
		}
		
		public function selectLastElement() : *
		{
			if(this.content_array.length > 0)
			{
				this.select(this.content_array.length - 1,false,false);
			}
		}
		
		public function isLastElement(param1:MovieClip) : Boolean
		{
			if(this.content_array.length > 0)
			{
				return param1 == this.getLastElement(false,false);
			}
			return false;
		}
		
		public function isFirstElement(param1:MovieClip) : Boolean
		{
			if(this.content_array.length > 0)
			{
				return param1 == this.getFirstElement(false,false);
			}
			return false;
		}
		
		public function getElementByNumber(param1:String, param2:Number) : MovieClip
		{
			var val4:MovieClip = null;
			var val3:uint = 0;
			while(val3 < this.content_array.length)
			{
				val4 = this.content_array[val3];
				if(val4 && val4[param1] == param2)
				{
					val4.list_pos = val3;
					return val4;
				}
				val3++;
			}
			return null;
		}
		
		public function getElementByBool(param1:String, param2:Boolean) : MovieClip
		{
			var val4:MovieClip = null;
			var val3:uint = 0;
			while(val3 < this.content_array.length)
			{
				val4 = this.content_array[val3];
				if(val4 && val4[param1] == param2)
				{
					val4.list_pos = val3;
					return val4;
				}
				val3++;
			}
			return null;
		}
		
		public function selectByOffset(param1:Number, param2:Boolean = true) : Boolean
		{
			var val5:MovieClip = null;
			var val6:Number = NaN;
			var val3:Boolean = false;
			param1 = param1 + this.TOP_SPACING;
			var val4:uint = 0;
			while(val4 < this.content_array.length)
			{
				val5 = this.content_array[val4];
				if(val5 && val5.visible)
				{
					val6 = this.getElementHeight(val5);
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
		
		public function getElementByString(param1:String, param2:String) : MovieClip
		{
			var val4:MovieClip = null;
			var val3:uint = 0;
			while(val3 < this.content_array.length)
			{
				val4 = this.content_array[val3];
				if(val4 && val4[param1] == param2)
				{
					val4.list_pos = val3;
					return val4;
				}
				val3++;
			}
			return null;
		}
		
		protected function INTSort() : *
		{
			if(this.m_SortOnFieldName && this.content_array && this.content_array.length > 1)
			{
				this.content_array.sortOn(this.m_SortOnFieldName,this.m_SortOnOptions);
			}
		}
		
		public function cleanUpElements() : *
		{
			var val2:MovieClip = null;
			var val1:uint = 0;
			while(val1 < this.content_array.length)
			{
				val2 = this.content_array[val1];
				if(val2)
				{
					if(val2.isUpdated)
					{
						val2.isUpdated = false;
						val1++;
					}
					else
					{
						this.removeElement(val1,false);
					}
				}
				else
				{
					val1++;
				}
			}
			if(this.content_array.length > 0)
			{
				this.positionElements();
			}
			else
			{
				this.m_visibleLength = -1;
			}
		}
		
		public function positionElements() : *
		{
			if(this.content_array.length < 1)
			{
				return;
			}
			if(this.m_NeedsSorting)
			{
				this.INTSort();
			}
			var val1:Number = this.m_topSpacing;
			this.m_visibleLength = 0;
			var val2:uint = 0;
			while(val2 < this.content_array.length)
			{
				if(this.content_array[val2].visible || this.canPositionInvisibleElements)
				{
					this.content_array[val2].list_pos = val2;
					this.content_array[val2].y = val1;
					this.content_array[val2].tweenToY = val1;
					if(this.content_array[val2].INTUpd4PosEl != null)
					{
						this.content_array[val2].INTUpd4PosEl();
					}
					val1 = val1 + (this.getElementHeight(this.content_array[val2]) + this.EL_SPACING);
					if(this.m_sideSpacing != 0)
					{
						this.content_array[val2].x = this.SIDE_SPACING;
					}
					if(this.content_array[val2].visible)
					{
						this.m_visibleLength++;
					}
				}
				val2++;
			}
			if(this.m_NeedsSorting)
			{
				this.m_NeedsSorting = false;
				dispatchEvent(new Event("listSorted"));
			}
		}
		
		public function getElementWidth(param1:MovieClip) : Number
		{
			var val2:Number = param1.width;
			if(param1.widthOverride != undefined && !isNaN(param1.widthOverride))
			{
				val2 = param1.widthOverride;
			}
			else if(this.m_customElementWidth != -1)
			{
				val2 = this.m_customElementWidth;
			}
			return val2;
		}
		
		public function getElementHeight(param1:MovieClip) : Number
		{
			var val2:Number = param1.height;
			if(param1.heightOverride != undefined && !isNaN(param1.heightOverride))
			{
				val2 = param1.heightOverride;
			}
			else if(this.m_customElementHeight != -1)
			{
				val2 = this.m_customElementHeight;
			}
			return val2;
		}
		
		public function getContentHeight() : Number
		{
			var val3:MovieClip = null;
			var val1:uint = 0;
			var val2:int = 0;
			for each(val3 in this.content_array)
			{
				if(val3 && val3.visible)
				{
					val1 = val1 + (this.getElementHeight(val3) + val2);
					val2 = this.EL_SPACING;
				}
			}
			return val1;
		}
		
		protected function reOrderDepths() : *
		{
			var val1:int = 0;
			if(this.m_forceDepthReorder)
			{
				val1 = this.content_array.length - 1;
				while(val1 >= 0)
				{
					this.containerContent_mc.addChild(this.content_array[val1]);
					val1--;
				}
			}
		}
		
		public function moveElementsToPosition(param1:Number = 0.8, param2:Boolean = false) : *
		{
			var val4:Object = null;
			var val6:MovieClip = null;
			if(this.content_array.length < 1)
			{
				return;
			}
			var val3:Number = 0;
			this.m_tweeningMcs = 0;
			dispatchEvent(new Event("listMoveStart"));
			var val5:uint = 0;
			while(val5 < this.content_array.length)
			{
				this.m_tweeningMcs++;
				val6 = this.content_array[val5];
				val6.tweening = true;
				val6.tweenToY = val3;
				this.stopElementMCPosTweens(val6);
				val6.list_tweenY = new larTween(val6,"y",this.m_PositionTweenFunc,NaN,val3,param1,this.removeTweenState,val6.list_id);
				if(param2 || this.m_sideSpacing != 0)
				{
					val6.list_tweenX = new larTween(val6,"x",this.m_PositionTweenFunc,NaN,this.m_sideSpacing,param1);
				}
				val3 = val3 + (this.getElementHeight(val6) + this.EL_SPACING);
				val5++;
			}
		}
		
		protected function removeTweenState(param1:uint) : *
		{
			var val2:MovieClip = this.getElementByNumber("list_id",param1);
			this.m_tweeningMcs--;
			if(this.m_tweeningMcs == 0)
			{
				dispatchEvent(new Event("listMoveStop"));
			}
			val2.dispatchEvent(new Event("elementMoveStop"));
			val2.tweening = false;
		}
		
		public function moveElementToPosition(param1:Number, param2:Number) : Boolean
		{
			var val3:DisplayObject = null;
			if(param1 >= 0 && param2 >= 0)
			{
				val3 = this.content_array[param1];
				this.content_array.splice(param1,1);
				this.content_array.splice(param2,0,val3);
				this.resetListPos();
				return true;
			}
			return false;
		}
		
		public function moveElementToBack(param1:Number) : *
		{
			var val2:DisplayObject = null;
			if(param1 >= 0 && param1 < this.content_array.length)
			{
				val2 = this.content_array[param1];
				if(val2)
				{
					this.content_array.splice(param1,1);
					this.content_array.push(val2);
					this.resetListPos();
				}
			}
		}
		
		public function onRemovedFromStage(param1:Event) : *
		{
			var val2:MovieClip = param1.currentTarget as MovieClip;
			if(val2)
			{
				this.stopElementMCTweens(val2);
				val2.removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
			}
		}
		
		public function addElement(param1:DisplayObject, param2:Boolean = true, param3:Boolean = true) : *
		{
			var val4:MovieClip = param1 as MovieClip;
			this.containerContent_mc.addChild(param1);
			val4.list_pos = this.content_array.length;
			this.content_array.push(val4);
			param1.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
			val4.list_id = this.idInc++;
			if(val4.deselectElement)
			{
				val4.deselectElement();
			}
			val4.selectable = param3;
			val4.m_filteredObject = false;
			this.m_NeedsSorting = true;
			this.reOrderDepths();
			val4.ownerList = this;
			if(param2)
			{
				this.positionElements();
			}
		}
		
		public function addElementOnPosition(param1:DisplayObject, param2:uint, param3:Boolean = true, param4:Boolean = true) : *
		{
			var val5:MovieClip = param1 as MovieClip;
			if(val5.deselectElement)
			{
				val5.deselectElement();
			}
			this.containerContent_mc.addChild(param1);
			val5.list_id = this.idInc;
			this.idInc++;
			val5.selectable = param4;
			this.content_array.splice(param2,0,val5);
			this.m_NeedsSorting = true;
			this.reOrderDepths();
			this.resetListPos();
			if(param3)
			{
				this.positionElements();
			}
		}
		
		public function addElementToFront(param1:DisplayObject, param2:Boolean = true) : *
		{
			this.containerContent_mc.addChild(param1);
			this.content_array.unshift(param1 as MovieClip);
			(param1 as MovieClip).list_id = ++this.idInc;
			this.resetListPos();
			if(param2)
			{
				this.positionElements();
			}
		}
		
		public function resetListPos() : *
		{
			var val1:uint = 0;
			while(val1 < this.content_array.length)
			{
				this.content_array[val1].list_pos = val1;
				val1++;
			}
		}
		
		public function stopElementTweens(param1:Number) : *
		{
			if(param1 >= 0 && param1 < this.content_array.length)
			{
				this.stopElementMCTweens(this.content_array[param1]);
			}
		}
		
		protected function stopElementMCTweens(param1:MovieClip) : *
		{
			if(param1)
			{
				this.stopElementMCPosTweens(param1);
				this.stopElementMCAlphaTweens(param1);
				this.stopElementMCScaleTweens(param1);
				param1.tweening = false;
			}
		}
		
		protected function stopElementMCScaleTweens(param1:MovieClip) : *
		{
			if(param1)
			{
				if(param1.list_tweenScaleX)
				{
					param1.list_tweenScaleX.stop();
				}
				if(param1.list_tweenScaleY)
				{
					param1.list_tweenScaleY.stop();
				}
			}
		}
		
		private function stopElementMCAlphaTweens(param1:MovieClip) : *
		{
			if(param1)
			{
				if(param1.list_tweenAlpha)
				{
					param1.list_tweenAlpha.stop();
				}
			}
		}
		
		protected function stopElementMCPosTweens(param1:MovieClip) : *
		{
			if(param1)
			{
				if(param1.list_tweenX)
				{
					param1.list_tweenX.stop();
				}
				if(param1.list_tweenY)
				{
					param1.list_tweenY.stop();
				}
			}
		}
		
		public function fadeOutAndRemoveElement(param1:Number, param2:Number, param3:Number, param4:Boolean = true, param5:Boolean = false) : *
		{
			var _element:MovieClip = null;
			var pos:Number = param1;
			var fadeTime:Number = param2;
			var delay:Number = param3;
			var update:Boolean = param4;
			var removeElementBefore:Boolean = param5;
			if(pos >= 0 && pos < this.content_array.length)
			{
				_element = this.content_array[pos];
				if(_element)
				{
					_element.tweenDelay = new Timer(delay * 1000,1);
					_element.tweenDelay.addEventListener(TimerEvent.TIMER_COMPLETE,function():*
					{
						stopElementMCAlphaTweens(_element);
						_element.list_tweenAlpha = new larTween(_element,"alpha",m_AlphaTweenFunc,_element.alpha,0,fadeTime);
						if(removeElementBefore)
						{
							_element.list_tweenAlpha.m_FinishCallback = removeChildAfterFade;
							_element.list_tweenAlpha.m_FinishCallbackParams = [_element];
							content_array.splice(pos,1);
						}
						else
						{
							_element.list_tweenAlpha.m_FinishCallback = removeElement;
							_element.list_tweenAlpha.m_FinishCallbackParams = [pos,true,true,0.1];
						}
					});
				}
			}
		}
		
		private function removeChildAfterFade(param1:MovieClip) : *
		{
			this.containerContent_mc.removeChild(param1);
		}
		
		public function removeElement(param1:Number, param2:Boolean = true, param3:Boolean = false, param4:Number = 0.3) : *
		{
			var val5:MovieClip = null;
			var val6:Number = NaN;
			var val7:MovieClip = null;
			if(param1 >= 0 && param1 < this.content_array.length)
			{
				val5 = this.content_array[param1];
				if(val5)
				{
					this.stopElementMCTweens(val5);
					val7 = val5.parent as MovieClip;
					if(val7)
					{
						val7.removeChild(val5);
					}
				}
				this.content_array.splice(param1,1);
				val6 = this.currentSelection;
				if(param1 == val6 && this.content_array.length > 0)
				{
					if(val6 > 0)
					{
						this.m_CurrentSelection = this.content_array[val6 - 1];
					}
					else
					{
						this.m_CurrentSelection = this.content_array[0];
					}
					if(this.OnSelectionChanged != null)
					{
						this.OnSelectionChanged();
					}
				}
				else if(this.content_array.length == 0)
				{
					this.m_CurrentSelection = null;
				}
				this.resetListPos();
				if(param2)
				{
					if(param3)
					{
						this.moveElementsToPosition(param4);
					}
					else
					{
						this.positionElements();
					}
				}
			}
			dispatchEvent(new Event("elementRemoved"));
		}
		
		public function removeElementByListId(param1:Number, param2:Boolean = true) : Boolean
		{
			var val3:uint = 0;
			while(val3 < this.content_array.length)
			{
				if(this.content_array[val3].list_id == param1)
				{
					this.removeElement(val3,param2);
					return true;
				}
				val3++;
			}
			return false;
		}
		
		public function clearElements() : *
		{
			var val2:MovieClip = null;
			var val1:uint = 0;
			while(val1 < this.content_array.length)
			{
				if(this.content_array[val1])
				{
					val2 = this.content_array[val1];
					this.stopElementMCTweens(val2);
					this.containerContent_mc.removeChild(this.content_array[val1]);
				}
				val1++;
			}
			this.content_array = new Array();
			this.idInc = 0;
			this.m_CurrentSelection = null;
			this.m_visibleLength = -1;
		}
		
		public function set elementSpacing(param1:Number) : *
		{
			this.EL_SPACING = param1;
			this.positionElements();
		}
		
		public function get elementSpacing() : Number
		{
			return this.EL_SPACING;
		}
		
		public function set TOP_SPACING(param1:Number) : *
		{
			this.m_topSpacing = param1;
			this.positionElements();
		}
		
		public function get TOP_SPACING() : Number
		{
			return this.m_topSpacing;
		}
		
		public function set SIDE_SPACING(param1:Number) : *
		{
			this.m_sideSpacing = param1;
			this.positionElements();
		}
		
		public function get SIDE_SPACING() : Number
		{
			return this.m_sideSpacing;
		}
		
		public function get size() : Number
		{
			return this.content_array.length;
		}
		
		public function next() : *
		{
			var val1:Number = NaN;
			if(this.visibleLength > 1)
			{
				val1 = this.currentSelection;
				if(this.currentSelection <= 0)
				{
					val1 = 0;
				}
				if(!this.m_CurrentSelection || this.m_CurrentSelection.INTSelectNext == null || !this.m_CurrentSelection.INTSelectNext())
				{
					this.select(val1 + 1,false,true);
				}
			}
		}
		
		public function previous() : *
		{
			if(this.visibleLength > 1 && (!this.m_CurrentSelection || this.m_CurrentSelection.INTSelectPrevious == null || !this.m_CurrentSelection.INTSelectPrevious()))
			{
				this.select(this.currentSelection - 1,false,false);
			}
		}
		
		public function getPreviousVisibleElement() : MovieClip
		{
			var val1:int = 0;
			if(this.currentSelection > 0)
			{
				val1 = this.currentSelection - 1;
				while(val1 >= 0)
				{
					if(this.content_array[val1] && this.content_array[val1].visible)
					{
						return this.content_array[val1];
					}
					val1--;
				}
			}
			return null;
		}
		
		public function selectByListID(param1:Number) : *
		{
			var val2:MovieClip = this.getElementByListID(param1);
			this.selectMC(val2);
		}
		
		public function selectMC(param1:MovieClip, param2:Boolean = false) : *
		{
			if(this.m_CurrentSelection != param1 || param2)
			{
				if(this.m_CurrentSelection)
				{
					if(this.m_CurrentSelection.deselectElement)
					{
						this.m_CurrentSelection.deselectElement();
					}
					if(this.m_CurrentSelection.INTDeselect)
					{
						this.m_CurrentSelection.INTDeselect();
					}
				}
				if(param1)
				{
					this.m_CurrentSelection = param1;
					dispatchEvent(new Event(Event.CHANGE));
					if(this.OnSelectionChanged != null)
					{
						this.OnSelectionChanged();
					}
					if(param1.selectElement)
					{
						param1.selectElement();
					}
				}
				else
				{
					this.m_CurrentSelection = null;
				}
			}
		}
		
		public function clearSelection() : *
		{
			if(this.currentSelection != -1)
			{
				if(this.m_CurrentSelection)
				{
					if(this.m_CurrentSelection.deselectElement)
					{
						this.m_CurrentSelection.deselectElement();
					}
					if(this.m_CurrentSelection.INTDeselect)
					{
						this.m_CurrentSelection.INTDeselect();
					}
				}
				this.m_CurrentSelection = null;
			}
		}
		
		public function select(param1:Number, param2:Boolean = false, param3:Boolean = true) : *
		{
			var val4:MovieClip = null;
			if(this.visibleLength <= 1 && this.m_CurrentSelection && this.m_CurrentSelection.visible && !(this.currentSelection == param1 && param2))
			{
				return;
			}
			if(this.m_cyclic)
			{
				if(param1 < 0)
				{
					param1 = this.content_array.length - 1;
				}
				else if(param1 >= this.content_array.length)
				{
					param1 = 0;
				}
			}
			else if(param1 < 0 || param1 >= this.content_array.length)
			{
				return;
			}
			if(this.currentSelection != param1 || param2)
			{
				val4 = this.content_array[param1];
				if(val4)
				{
					if(val4.visible && val4.selectable)
					{
						this.selectMC(val4,param2);
						if(!param3 && val4.INTSelectLast != null && val4.INTSelectLast())
						{
							if(val4.deselectElement)
							{
								val4.deselectElement();
							}
						}
					}
					else if(param3)
					{
						this.select(param1 + 1,param2,param3);
					}
					else
					{
						this.select(param1 - 1,param2,param3);
					}
				}
			}
		}
		
		public function filterShowAll() : *
		{
			var val1:uint = 0;
			while(val1 < this.content_array.length)
			{
				this.content_array[val1].visible = true;
				this.content_array[val1].m_filteredObject = false;
				val1++;
			}
			this.m_visibleLength = -1;
		}
		
		public function filterHideAll() : *
		{
			var val1:uint = 0;
			while(val1 < this.content_array.length)
			{
				this.content_array[val1].visible = false;
				this.content_array[val1].m_filteredObject = false;
				val1++;
			}
			this.m_visibleLength = -1;
		}
		
		public function filterHideBoolean(param1:String, param2:Boolean) : *
		{
			var val3:Number = 0;
			var val4:uint = 0;
			while(val4 < this.content_array.length)
			{
				if(this.content_array[val4][param1] && this.content_array[val4][param1] == param2)
				{
					this.content_array[val4].visible = false;
					this.content_array[val4].m_filteredObject = true;
				}
				if(this.content_array[val4].visible)
				{
					val3++;
				}
				val4++;
			}
			this.m_visibleLength = val3;
		}
		
		public function filterShowBoolean(param1:String, param2:Boolean, param3:Boolean = true) : *
		{
			var val4:Number = 0;
			var val5:uint = 0;
			while(val5 < this.content_array.length)
			{
				if(this.content_array[val5][param1])
				{
					if(this.content_array[val5][param1] == param2)
					{
						this.content_array[val5].visible = true;
					}
					else if(param3)
					{
						this.content_array[val5].visible = false;
					}
				}
				if(this.content_array[val5].visible)
				{
					val4++;
				}
				val5++;
			}
			this.m_visibleLength = val4;
		}
		
		public function filterBySubString(param1:String, param2:String) : *
		{
			var val3:Number = 0;
			var val4:uint = 0;
			while(val4 < this.content_array.length)
			{
				if(!this.content_array[val4].m_filteredObject && (param2 == "" || this.content_array[val4][param1].toLowerCase().indexOf(param2.toLowerCase()) != -1))
				{
					this.content_array[val4].visible = true;
					this.content_array[val4].m_filteredObject = false;
				}
				else
				{
					this.content_array[val4].visible = false;
					this.content_array[val4].m_filteredObject = true;
				}
				if(this.content_array[val4].visible)
				{
					val3++;
				}
				val4++;
			}
			this.m_visibleLength = val3;
		}
		
		public function filterShowType(param1:String, param2:Object, param3:Boolean = true) : *
		{
			var val4:Number = 0;
			var val5:uint = 0;
			while(val5 < this.content_array.length)
			{
				if(this.content_array[val5][param1] != null && this.content_array[val5][param1] == param2)
				{
					this.content_array[val5].visible = true;
					this.content_array[val5].m_filteredObject = false;
				}
				else if(param3)
				{
					this.content_array[val5].visible = false;
					this.content_array[val5].m_filteredObject = true;
				}
				if(this.content_array[val5].visible)
				{
					val4++;
				}
				val5++;
			}
			this.m_visibleLength = val4;
		}
		
		public function filterHideType(param1:String, param2:Object) : *
		{
			var val3:Number = 0;
			var val4:uint = 0;
			while(val4 < this.content_array.length)
			{
				if(this.content_array[val4][param1] != null && this.content_array[val4][param1] == param2)
				{
					this.content_array[val4].visible = false;
					this.content_array[val4].m_filteredObject = true;
				}
				if(this.content_array[val4].visible)
				{
					val3++;
				}
				val4++;
			}
			this.m_visibleLength = val3;
		}
		
		public function filterType(param1:String, param2:Object) : *
		{
			var val3:Number = 0;
			var val4:uint = 0;
			while(val4 < this.content_array.length)
			{
				if(!(this.content_array[val4][param1] != null && this.content_array[val4][param1] == param2))
				{
					this.content_array[val4].visible = false;
				}
				if(this.content_array[val4].visible)
				{
					val3++;
				}
				val4++;
			}
			this.m_visibleLength = val3;
		}
		
		public function getFirstElement(param1:Boolean = true, param2:Boolean = true) : MovieClip
		{
			var val3:uint = 0;
			while(val3 < this.content_array.length)
			{
				if(this.content_array[val3])
				{
					if(!(param1 && !this.content_array[val3].visible))
					{
						if(!(param2 && this.content_array[val3].selectable == false))
						{
							return this.content_array[val3];
						}
					}
				}
				val3++;
			}
			return null;
		}
		
		public function getFirstVisible(param1:Boolean = true) : MovieClip
		{
			return this.getFirstElement(true,param1);
		}
		
		public function getLastElement(param1:Boolean = true, param2:Boolean = true) : MovieClip
		{
			var val3:int = this.content_array.length - 1;
			while(val3 >= 0)
			{
				if(this.content_array[val3])
				{
					if(!(param1 && !this.content_array[val3].visible))
					{
						if(!(param2 && this.content_array[val3].selectable == false))
						{
							return this.content_array[val3];
						}
					}
				}
				val3--;
			}
			return null;
		}
		
		public function getLastVisible(param1:Boolean = true) : MovieClip
		{
			return this.getLastElement(true,param1);
		}
		
		public function selectFirstVisible(param1:Boolean = false) : *
		{
			var val2:MovieClip = this.getFirstVisible();
			if(val2)
			{
				this.selectMC(val2,param1);
			}
		}
		
		public function sortOn(param1:Object, param2:Object = null, param3:Boolean = true) : *
		{
			this.m_SortOnFieldName = param1;
			this.m_SortOnOptions = param2;
			if(this.content_array && this.content_array.length > 1)
			{
				this.content_array.sortOn(this.m_SortOnFieldName,this.m_SortOnOptions);
				if(param3)
				{
					this.positionElements();
				}
				else
				{
					this.resetListPos();
				}
				dispatchEvent(new Event("listSorted"));
			}
		}
		
		public function redoSort() : *
		{
			this.m_NeedsSorting = true;
		}
		
		public function sortOnce(param1:Object, param2:Object = null, param3:Boolean = true) : *
		{
			if(this.content_array && this.content_array.length > 1)
			{
				this.content_array.sortOn(param1,param2);
				if(param3)
				{
					this.positionElements();
				}
				else
				{
					this.resetListPos();
				}
				dispatchEvent(new Event("listSorted"));
			}
		}
		
		public function cursorLeft() : *
		{
		}
		
		public function cursorRight() : *
		{
		}
		
		public function cursorUp() : *
		{
			this.previous();
		}
		
		public function cursorDown() : *
		{
			this.next();
		}
		
		public function cursorAccept() : *
		{
			if(this.m_CurrentSelection && this.m_CurrentSelection.onClick != null)
			{
				this.m_CurrentSelection.onClick();
			}
		}

		// LeaderLib Addition
		public function isOverlappingPosition(targetX:Number, targetY:Number, shapeTest:Boolean=true) : *
		{
			if(this.content_array && this.content_array.length > 1)
			{
				var index:uint = 0;
				var obj:MovieClip = null;
				while(index < this.content_array.length)
				{
					obj = this.content_array[index];
					if(obj != null && obj.hitTestPoint(targetX, targetY, shapeTest))
					{
						return true;
					}
					index++;
				}
			}
			return false;
		}
	}
}
