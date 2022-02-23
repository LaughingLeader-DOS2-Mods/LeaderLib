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
	
	public dynamic class listDisplay extends MovieClip
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
			var h:Number = 0;
			var last_mc:MovieClip = this.getLastVisible(false);
			if(last_mc)
			{
				h = this.getElementHeight(last_mc) + last_mc.y;
			}
			return h;
		}
		
		override public function set width(v:Number) : void
		{
			this.m_width = v;
			this.updateScrollHit();
		}
		
		override public function set height(v:Number) : void
		{
			this.m_height = v;
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
		
		public function setFrameWidth(frameWidth:Number) : void
		{
			this.setFrame(frameWidth,this.container_mc.height);
		}
		
		public function setFrame(frameWidth:Number, frameHeight:Number) : void
		{
			this.m_width = frameWidth;
			this.m_height = frameHeight;
			this.updateScrollHit();
			this.container_mc.scrollRect = new Rectangle(0,0,frameWidth,frameHeight);
			this.m_hasScrollRect = true;
		}
		
		protected function updateScrollHit() : void
		{
			var spr:Sprite = null;
			if(this.scrollHit_mc.numChildren == 0)
			{
				spr = new Sprite();
				spr.graphics.lineStyle(1,16777215);
				spr.graphics.beginFill(16777215);
				spr.graphics.drawRect(0,0,100,100);
				spr.graphics.endFill();
				this.scrollHit_mc.addChild(spr);
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
		
		public function set canPositionInvisibleElements(b:Boolean) : void
		{
			if(this.m_positionInvisibleElements != b)
			{
				this.m_positionInvisibleElements = b;
				this.positionElements();
			}
		}
		
		public function getElement(index:Number) : MovieClip
		{
			if(index >= 0 && index < this.content_array.length)
			{
				return this.content_array[index];
			}
			return null;
		}
		
		public function getAt(index:Number) : MovieClip
		{
			if(index >= 0 && index < this.content_array.length)
			{
				return this.content_array[index];
			}
			return null;
		}
		
		public function getElementByListID(id:Number) : MovieClip
		{
			if(id == -1)
			{
				return null;
			}
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				if(this.content_array[i] && this.content_array[i].hasOwnProperty("list_id") && this.content_array[i].list_id == id)
				{
					this.content_array[i].list_pos = i;
					return this.content_array[i];
				}
				i++;
			}
			return null;
		}
		
		public function selectLastElement() : void
		{
			if(this.content_array.length > 0)
			{
				this.select(this.content_array.length - 1,false,false);
			}
		}
		
		public function isLastElement(mc:MovieClip) : Boolean
		{
			if(this.content_array.length > 0)
			{
				return mc == this.getLastElement(false,false);
			}
			return false;
		}
		
		public function isFirstElement(mc:MovieClip) : Boolean
		{
			if(this.content_array.length > 0)
			{
				return mc == this.getFirstElement(false,false);
			}
			return false;
		}
		
		public function getElementByNumber(property:String, value:Number) : MovieClip
		{
			var mc:MovieClip = null;
			for (var i:uint = this.content_array.length; i--;)
			{
				mc = this.content_array[i];
				if(mc && mc[property] == value)
				{
					mc.list_pos = i;
					return mc;
				}
			}
			return null;
		}
		
		public function getElementByBool(property:String, value:Boolean) : MovieClip
		{
			var mc:MovieClip = null;
			for (var i:uint = this.content_array.length; i--;)
			{
				mc = this.content_array[i];
				if(mc && mc[property] == value)
				{
					mc.list_pos = i;
					return mc;
				}
			}
			return null;
		}
		
		public function selectByOffset(offset:Number, force:Boolean = true) : Boolean
		{
			var obj_mc:MovieClip = null;
			var obj_height:Number = NaN;
			var success:Boolean = false;
			offset += this.TOP_SPACING;
			var i:uint = 0;
			while(i < this.content_array.length)
			{
				obj_mc = this.content_array[i];
				if(obj_mc && obj_mc.visible)
				{
					obj_height = this.getElementHeight(obj_mc);
					if(obj_mc.y <= offset && obj_mc.y + obj_height > offset)
					{
						success = true;
						this.selectMC(obj_mc);
						break;
					}
				}
				i++;
			}
			return success;
		}
		
		public function getElementByString(property:String, value:String) : MovieClip
		{
			var mc:MovieClip = null;
			for (var i:uint = this.content_array.length; i--;)
			{
				mc = this.content_array[i];
				if(mc && mc[property] == value)
				{
					mc.list_pos = i;
					return mc;
				}
			}
			return null;
		}
		
		protected function INTSort() : void
		{
			if(this.m_SortOnFieldName && this.content_array && this.content_array.length > 1)
			{
				this.content_array.sortOn(this.m_SortOnFieldName,this.m_SortOnOptions);
			}
		}
		
		public function cleanUpElements() : void
		{
			var mc:MovieClip = null;
			for (var i:uint = this.content_array.length; i--;)
			{
				mc = this.content_array[i];
				if(mc)
				{
					if(mc.isUpdated)
					{
						mc.isUpdated = false;
					}
					else
					{
						this.removeElement(i,false);
					}
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
		
		public function positionElements() : void
		{
			if(this.content_array.length < 1)
			{
				return;
			}
			if(this.m_NeedsSorting)
			{
				this.INTSort();
			}
			var yPos:Number = this.m_topSpacing;
			this.m_visibleLength = 0;
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				if(this.content_array[i].visible || this.canPositionInvisibleElements)
				{
					this.content_array[i].list_pos = i;
					this.content_array[i].y = yPos;
					this.content_array[i].tweenToY = yPos;
					if(this.content_array[i].INTUpd4PosEl != null)
					{
						this.content_array[i].INTUpd4PosEl();
					}
					yPos += this.getElementHeight(this.content_array[i]) + this.EL_SPACING;
					if(this.m_sideSpacing != 0)
					{
						this.content_array[i].x = this.SIDE_SPACING;
					}
					if(this.content_array[i].visible)
					{
						++this.m_visibleLength;
					}
				}
				i++;
			}
			if(this.m_NeedsSorting)
			{
				this.m_NeedsSorting = false;
				dispatchEvent(new Event("listSorted"));
			}
		}
		
		public function getElementWidth(mc:MovieClip) : Number
		{
			var mc_width:Number = mc.width;
			if(mc.widthOverride != undefined && !isNaN(mc.widthOverride))
			{
				mc_width = mc.widthOverride;
			}
			else if(this.m_customElementWidth != -1)
			{
				mc_width = this.m_customElementWidth;
			}
			return mc_width;
		}
		
		public function getElementHeight(mc:MovieClip) : Number
		{
			var mc_height:Number = mc.height;
			if(mc.heightOverride != undefined && !isNaN(mc.heightOverride))
			{
				mc_height = mc.heightOverride;
			}
			else if(this.m_customElementHeight != -1)
			{
				mc_height = this.m_customElementHeight;
			}
			return mc_height;
		}
		
		public function getContentHeight() : Number
		{
			var totalHeight:uint = 0;
			var spacingVal:Number = this.EL_SPACING;
			var mc:MovieClip = null;
			for (var i:uint = this.content_array.length; i--;)
			{
				mc = this.content_array[i];
				if(mc)
				{
					totalHeight += this.getElementHeight(mc) + spacingVal;
				}
			}
			return totalHeight;
		}
		
		protected function reOrderDepths() : void
		{
			if(this.m_forceDepthReorder)
			{
				var mc:MovieClip = null;
				for (var i:uint = this.content_array.length; i--;)
				{
					mc = this.content_array[i];
					if(mc)
					{
						this.containerContent_mc.addChild(mc);
					}
				}
			}
		}
		
		public function moveElementsToPosition(yPos:Number = 0.8, tweenX:Boolean = false) : void
		{
			var mc:MovieClip = null;
			if(this.content_array.length < 1)
			{
				return;
			}
			var tweenToY:Number = 0;
			this.m_tweeningMcs = 0;
			dispatchEvent(new Event("listMoveStart"));
			var i:uint = 0;
			while(i < this.content_array.length)
			{
				++this.m_tweeningMcs;
				(mc = this.content_array[i]).tweening = true;
				mc.tweenToY = tweenToY;
				this.stopElementMCPosTweens(mc);
				mc.list_tweenY = new larTween(mc,"y",this.m_PositionTweenFunc,NaN,tweenToY,yPos,this.removeTweenState,mc.list_id);
				if(tweenX || this.m_sideSpacing != 0)
				{
					mc.list_tweenX = new larTween(mc,"x",this.m_PositionTweenFunc,NaN,this.m_sideSpacing,yPos);
				}
				tweenToY += this.getElementHeight(mc) + this.EL_SPACING;
				i++;
			}
		}
		
		protected function removeTweenState(list_id:uint) : void
		{
			var mc:MovieClip = this.getElementByNumber("list_id",list_id);
			--this.m_tweeningMcs;
			if(this.m_tweeningMcs == 0)
			{
				dispatchEvent(new Event("listMoveStop"));
			}
			mc.dispatchEvent(new Event("elementMoveStop"));
			mc.tweening = false;
		}
		
		public function moveElementToPosition(index:Number, toIndex:Number) : Boolean
		{
			var mc:MovieClip = null;
			if(index >= 0 && toIndex >= 0)
			{
				mc = this.content_array[index];
				this.content_array.splice(index,1);
				this.content_array.splice(toIndex,0,mc);
				this.resetListPos();
				return true;
			}
			return false;
		}
		
		public function moveElementToBack(index:Number) : void
		{
			var mc:MovieClip = null;
			if(index >= 0 && index < this.content_array.length)
			{
				mc = this.content_array[index];
				if(mc)
				{
					this.content_array.splice(index,1);
					this.content_array.push(mc);
					this.resetListPos();
				}
			}
		}
		
		public function onRemovedFromStage(e:Event) : void
		{
			var mc:MovieClip = e.currentTarget as MovieClip;
			if(mc)
			{
				this.stopElementMCTweens(mc);
				mc.removeEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
			}
		}
		
		public function addElement(obj:DisplayObject, reposition:Boolean = true, isSelectable:Boolean = true) : void
		{
			var mc:MovieClip = obj as MovieClip;
			this.containerContent_mc.addChild(obj);
			mc.list_pos = this.content_array.length;
			this.content_array.push(mc);
			obj.addEventListener(Event.REMOVED_FROM_STAGE,this.onRemovedFromStage);
			mc.list_id = this.idInc++;
			if(mc.deselectElement)
			{
				mc.deselectElement();
			}
			mc.selectable = isSelectable;
			mc.m_filteredObject = false;
			this.m_NeedsSorting = true;
			this.reOrderDepths();
			mc.ownerList = this;
			if(reposition)
			{
				this.positionElements();
			}
		}
		
		public function addElementOnPosition(mc:MovieClip, index:uint, bSort:Boolean = true, isSelectable:Boolean = true) : void
		{
			if(mc.deselectElement)
			{
				mc.deselectElement();
			}
			this.containerContent_mc.addChild(mc);
			mc.list_id = this.idInc;
			++this.idInc;
			mc.selectable = isSelectable;
			this.content_array.splice(index,0,mc);
			this.m_NeedsSorting = true;
			this.reOrderDepths();
			this.resetListPos();
			if(bSort)
			{
				this.positionElements();
			}
		}
		
		public function addElementToFront(mc:MovieClip, bSort:Boolean = true) : void
		{
			this.containerContent_mc.addChild(mc);
			this.content_array.unshift(mc);
			mc.list_id = ++this.idInc;
			this.resetListPos();
			if(bSort)
			{
				this.positionElements();
			}
		}
		
		public function resetListPos() : void
		{
			var val1:uint = 0;
			while(val1 < this.content_array.length)
			{
				this.content_array[val1].list_pos = val1;
				val1++;
			}
		}
		
		public function stopElementTweens(index:Number) : void
		{
			if(index >= 0 && index < this.content_array.length)
			{
				this.stopElementMCTweens(this.content_array[index]);
			}
		}
		
		protected function stopElementMCTweens(mc:MovieClip) : void
		{
			if(mc)
			{
				this.stopElementMCPosTweens(mc);
				this.stopElementMCAlphaTweens(mc);
				this.stopElementMCScaleTweens(mc);
				mc.tweening = false;
			}
		}
		
		protected function stopElementMCScaleTweens(mc:MovieClip) : void
		{
			if(mc)
			{
				if(mc.list_tweenScaleX)
				{
					mc.list_tweenScaleX.stop();
				}
				if(mc.list_tweenScaleY)
				{
					mc.list_tweenScaleY.stop();
				}
			}
		}
		
		private function stopElementMCAlphaTweens(mc:MovieClip) : void
		{
			if(mc)
			{
				if(mc.list_tweenAlpha)
				{
					mc.list_tweenAlpha.stop();
				}
			}
		}
		
		protected function stopElementMCPosTweens(mc:MovieClip) : void
		{
			if(mc)
			{
				if(mc.list_tweenX)
				{
					mc.list_tweenX.stop();
				}
				if(mc.list_tweenY)
				{
					mc.list_tweenY.stop();
				}
			}
		}
		
		public function fadeOutAndRemoveElement(pos:Number, fadeTime:Number, delay:Number, update:Boolean = true, removeElementBefore:Boolean = false) : void
		{
			var mc:MovieClip = null;
			if(pos >= 0 && pos < this.content_array.length)
			{
				mc = this.content_array[pos];
				if(mc)
				{
					mc.tweenDelay = new Timer(delay * 1000,1);
					mc.tweenDelay.addEventListener(TimerEvent.TIMER_COMPLETE,function():void
					{
						stopElementMCAlphaTweens(mc);
						mc.list_tweenAlpha = new larTween(mc,"alpha",m_AlphaTweenFunc,mc.alpha,0,fadeTime);
						if(removeElementBefore)
						{
							mc.list_tweenAlpha.m_FinishCallback = removeChildAfterFade;
							mc.list_tweenAlpha.m_FinishCallbackParams = [mc];
							content_array.splice(pos,1);
						}
						else
						{
							mc.list_tweenAlpha.m_FinishCallback = removeElement;
							mc.list_tweenAlpha.m_FinishCallbackParams = [pos,true,true,0.1];
						}
					});
				}
			}
		}
		
		private function removeChildAfterFade(mc:MovieClip) : void
		{
			this.containerContent_mc.removeChild(mc);
		}
		
		public function removeElement(index:Number, bSort:Boolean = true, bMoveToPosition:Boolean = false, yPosition:Number = 0.3) : void
		{
			var mc:MovieClip = null;
			var cur_index:Number = NaN;
			var parent_mc:MovieClip = null;
			if(index >= 0 && index < this.content_array.length)
			{
				mc = this.content_array[index]
				if(mc)
				{
					this.stopElementMCTweens(mc);
					parent_mc = mc.parent as MovieClip;
					if(parent_mc)
					{
						parent_mc.removeChild(mc);
					}
				}
				this.content_array.splice(index,1);
				cur_index = this.currentSelection;
				if(index == cur_index && this.content_array.length > 0)
				{
					if(cur_index > 0)
					{
						this.m_CurrentSelection = this.content_array[cur_index - 1];
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
				if(bSort)
				{
					if(bMoveToPosition)
					{
						this.moveElementsToPosition(yPosition);
					}
					else
					{
						this.positionElements();
					}
				}
			}
			this.dispatchEvent(new Event("elementRemoved"));
		}
		
		public function removeElementByListId(id:Number, bSort:Boolean = true) : Boolean
		{
			var i:uint = 0;
			while(i < this.content_array.length)
			{
				if(this.content_array[i].list_id == id)
				{
					this.removeElement(i,bSort);
					return true;
				}
				i++;
			}
			return false;
		}
		
		public function clearElements() : void
		{
			var mc:MovieClip = null;
			var i:uint = 0;
			while(i < this.content_array.length)
			{
				if(this.content_array[i])
				{
					mc = this.content_array[i];
					this.stopElementMCTweens(mc);
					this.containerContent_mc.removeChild(this.content_array[i]);
				}
				i++;
			}
			this.content_array = new Array();
			this.idInc = 0;
			this.m_CurrentSelection = null;
			this.m_visibleLength = -1;
		}
		
		public function set elementSpacing(v:Number) : void
		{
			this.EL_SPACING = v;
			this.positionElements();
		}
		
		public function get elementSpacing() : Number
		{
			return this.EL_SPACING;
		}
		
		public function set TOP_SPACING(v:Number) : void
		{
			this.m_topSpacing = v;
			this.positionElements();
		}
		
		public function get TOP_SPACING() : Number
		{
			return this.m_topSpacing;
		}
		
		public function set SIDE_SPACING(v:Number) : void
		{
			this.m_sideSpacing = v;
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
		
		public function next() : void
		{
			var index:Number = 0;
			if(this.visibleLength > 1)
			{
				index = this.currentSelection;
				if(this.currentSelection <= 0)
				{
					index = 0;
				}
				if(!this.m_CurrentSelection || this.m_CurrentSelection.INTSelectNext == null || !this.m_CurrentSelection.INTSelectNext())
				{
					this.select(index + 1,false,true);
				}
			}
		}
		
		public function previous() : void
		{
			if(this.visibleLength > 1 && (!this.m_CurrentSelection || this.m_CurrentSelection.INTSelectPrevious == null || !this.m_CurrentSelection.INTSelectPrevious()))
			{
				this.select(this.currentSelection - 1,false,false);
			}
		}
		
		public function getPreviousVisibleElement() : MovieClip
		{
			if(this.currentSelection > 0)
			{
				var element:MovieClip = null;
				for (var i:uint = this.currentSelection - 1; i--;)
				{
					element = this.content_array[i];
					if(element && element.visible)
					{
						return element;
					}
				}
			}
			return null;
		}
		
		public function selectByListID(id:Number) : void
		{
			var obj_mc:MovieClip = this.getElementByListID(id);
			this.selectMC(obj_mc);
		}
		
		public function selectMC(obj_mc:MovieClip, force:Boolean = false) : void
		{
			if(this.m_CurrentSelection != obj_mc || force)
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
				if(obj_mc)
				{
					this.m_CurrentSelection = obj_mc;
					dispatchEvent(new Event(Event.CHANGE));
					if(this.OnSelectionChanged != null)
					{
						this.OnSelectionChanged();
					}
					if(obj_mc.selectElement)
					{
						obj_mc.selectElement();
					}
				}
				else
				{
					this.m_CurrentSelection = null;
				}
			}
		}
		
		public function clearSelection() : void
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
					dispatchEvent(new Event(Event.CLEAR));
				}
				this.m_CurrentSelection = null;
			}
		}
		
		public function select(index:Number, force:Boolean = false, forward:Boolean = true) : void
		{
			var obj_mc:MovieClip = null;
			if(this.visibleLength <= 1 && this.m_CurrentSelection && this.m_CurrentSelection.visible && !(this.currentSelection == index && force))
			{
				return;
			}
			if(this.m_cyclic)
			{
				if(index < 0)
				{
					index = this.content_array.length - 1;
				}
				else if(index >= this.content_array.length)
				{
					index = 0;
				}
			}
			else if(index < 0 || index >= this.content_array.length)
			{
				return;
			}
			if(this.currentSelection != index || force)
			{
				obj_mc = this.content_array[index];
				if(obj_mc)
				{
					if(obj_mc.visible && obj_mc.selectable)
					{
						this.selectMC(obj_mc,force);
						if(!forward && obj_mc.INTSelectLast != null && obj_mc.INTSelectLast())
						{
							if(obj_mc.deselectElement)
							{
								obj_mc.deselectElement();
							}
						}
					}
					else if(forward)
					{
						this.select(index + 1,force,forward);
					}
					else
					{
						this.select(index - 1,force,forward);
					}
				}
			}
		}
		
		public function filterShowAll() : void
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
		
		public function filterHideAll() : void
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
		
		public function filterHideBoolean(propertyName:String, compareValue:Boolean) : void
		{
			var totalVisible:Number = 0;
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				if(this.content_array[i][propertyName] && this.content_array[i][propertyName] == compareValue)
				{
					this.content_array[i].visible = false;
					this.content_array[i].m_filteredObject = true;
				}
				if(this.content_array[i].visible)
				{
					totalVisible++;
				}
				i++;
			}
			this.m_visibleLength = totalVisible;
		}
		
		public function filterShowBoolean(propertyName:String, compareValue:Boolean, hideIfNotEqual:Boolean = true) : void
		{
			var totalVisible:Number = 0;
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				if(this.content_array[i][propertyName])
				{
					if(this.content_array[i][propertyName] == compareValue)
					{
						this.content_array[i].visible = true;
					}
					else if(hideIfNotEqual)
					{
						this.content_array[i].visible = false;
					}
				}
				if(this.content_array[i].visible)
				{
					totalVisible++;
				}
				i++;
			}
			this.m_visibleLength = totalVisible;
		}
		
		public function filterBySubString(propertyName:String, compareValue:String) : void
		{
			var totalVisible:Number = 0;
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				if(!this.content_array[i].m_filteredObject && (compareValue == "" || this.content_array[i][propertyName].toLowerCase().indexOf(compareValue.toLowerCase()) != -1))
				{
					this.content_array[i].visible = true;
					this.content_array[i].m_filteredObject = false;
				}
				else
				{
					this.content_array[i].visible = false;
					this.content_array[i].m_filteredObject = true;
				}
				if(this.content_array[i].visible)
				{
					totalVisible++;
				}
				i++;
			}
			this.m_visibleLength = totalVisible;
		}
		
		public function filterShowType(propertyName:String, compareValue:Object, hideIfNotEqual:Boolean = true) : void
		{
			var totalVisible:Number = 0;
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				if(this.content_array[i][propertyName] != null && this.content_array[i][propertyName] == compareValue)
				{
					this.content_array[i].visible = true;
					this.content_array[i].m_filteredObject = false;
				}
				else if(hideIfNotEqual)
				{
					this.content_array[i].visible = false;
					this.content_array[i].m_filteredObject = true;
				}
				if(this.content_array[i].visible)
				{
					totalVisible++;
				}
				i++;
			}
			this.m_visibleLength = totalVisible;
		}
		
		public function filterHideType(propertyName:String, compareValue:Object) : void
		{
			var totalVisible:Number = 0;
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				if(this.content_array[i][propertyName] != null && this.content_array[i][propertyName] == compareValue)
				{
					this.content_array[i].visible = false;
					this.content_array[i].m_filteredObject = true;
				}
				if(this.content_array[i].visible)
				{
					totalVisible++;
				}
				i++;
			}
			this.m_visibleLength = totalVisible;
		}
		
		public function filterType(propertyName:String, compareValue:Object) : void
		{
			var totalVisible:Number = 0;
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				if(!(this.content_array[i][propertyName] != null && this.content_array[i][propertyName] == compareValue))
				{
					this.content_array[i].visible = false;
				}
				if(this.content_array[i].visible)
				{
					totalVisible++;
				}
				i++;
			}
			this.m_visibleLength = totalVisible;
		}
		
		public function getFirstElement(onlyVisible:Boolean = true, onlySelectable:Boolean = true) : MovieClip
		{
			var i:uint = 0;
			var len:uint = this.content_array.length;
			while(i < len)
			{
				if(this.content_array[i])
				{
					if(!(onlyVisible && !this.content_array[i].visible))
					{
						if(!(onlySelectable && this.content_array[i].selectable == false))
						{
							return this.content_array[i];
						}
					}
				}
				i++;
			}
			return null;
		}
		
		public function getFirstVisible(onlySelectable:Boolean = true) : MovieClip
		{
			return this.getFirstElement(true,onlySelectable);
		}
		
		public function getLastElement(visibleOnly:Boolean = true, onlySelectable:Boolean = true) : MovieClip
		{
			var mc:MovieClip = null;
			for (var i:uint = this.content_array.length; i--;)
			{
				mc = this.content_array[i];
				if(mc)
				{
					if(!(visibleOnly && !mc.visible))
					{
						if(!(onlySelectable && mc.selectable == false))
						{
							return mc;
						}
					}
				}
			}
			return null;
		}
		
		public function getLastVisible(onlySelectable:Boolean = true) : MovieClip
		{
			return this.getLastElement(true,onlySelectable);
		}
		
		public function selectFirstVisible(force:Boolean = false) : void
		{
			var mc:MovieClip = this.getFirstVisible();
			if(mc)
			{
				this.selectMC(mc,force);
			}
		}
		
		public function sortOn(propertyName:Object, sortOptions:Object = null, reposition:Boolean = true) : void
		{
			this.m_SortOnFieldName = propertyName;
			this.m_SortOnOptions = sortOptions;
			if(this.content_array && this.content_array.length > 1)
			{
				this.content_array.sortOn(this.m_SortOnFieldName,this.m_SortOnOptions);
				if(reposition)
				{
					this.positionElements();
				}
				else
				{
					this.resetListPos();
				}
				this.dispatchEvent(new Event("listSorted"));
			}
		}
		
		public function redoSort() : void
		{
			this.m_NeedsSorting = true;
		}
		
		public function sortOnce(propertyName:Object, sortOptions:Object = null, reposition:Boolean = true) : void
		{
			if(this.content_array && this.content_array.length > 1)
			{
				this.content_array.sortOn(propertyName,sortOptions);
				if(reposition)
				{
					this.positionElements();
				}
				else
				{
					this.resetListPos();
				}
				this.dispatchEvent(new Event("listSorted"));
			}
		}
		
		public function cursorLeft() : void
		{
		}
		
		public function cursorRight() : void
		{
		}
		
		public function cursorUp() : void
		{
			this.previous();
		}
		
		public function cursorDown() : void
		{
			this.next();
		}
		
		public function cursorAccept() : void
		{
			if(this.m_CurrentSelection && this.m_CurrentSelection.onClick != null)
			{
				this.m_CurrentSelection.onClick();
			}
		}
		
		// LeaderLib Addition
		public function isOverlappingPosition(targetX:Number, targetY:Number, shapeTest:Boolean=true) : Boolean
		{
			var mc:MovieClip = null;
			for (var i:uint = this.content_array.length; i--;)
			{
				mc = this.content_array[i];
				if(mc != null && mc.hitTestPoint(targetX, targetY, shapeTest))
				{
					return true;
				}
			}
			return false;
		}
	}
}