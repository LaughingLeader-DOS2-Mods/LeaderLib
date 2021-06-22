---@class FlashHorizontalList:FlashListDisplay
---@field rightSided boolean
---@field m_MaxWidth integer
---@field m_MaxRowElements integer
---@field m_RowSpacing integer
---@field m_CenterHolders boolean
---@field m_RowHeight number
---@field m_holderArray table
---@field positionElements fun():void
---@field moveElementsToPosition fun(param1:number.8, param2:boolean):void
---@field getContainerWidth fun():number

---@class FlashListDisplay:FlashMovieClip
---@field content_array table
---@field scrollHit_mc FlashMovieClip
---@field container_mc FlashMovieClip
---@field containerBG_mc FlashMovieClip
---@field containerContent_mc FlashMovieClip
---@field EL_SPACING number
---@field m_topSpacing number
---@field m_sideSpacing number
---@field m_cyclic boolean
---@field m_customElementWidth number
---@field m_customElementHeight number
---@field m_forceDepthReorder boolean
---@field m_CurrentSelection FlashMovieClip
---@field idInc integer
---@field m_hasScrollRect boolean
---@field OnSelectionChanged Function
---@field m_AlphaTweenFunc Function
---@field m_PositionTweenFunc Function
---@field m_tweeningMcs integer
---@field m_visibleLength number
---@field m_NeedsSorting boolean
---@field m_SortOnFieldName Object
---@field m_SortOnOptions Object
---@field m_positionInvisibleElements boolean
---@field m_height number
---@field m_width number
---@field m_myInterlinie number
---@field setFrameWidth fun(param1:number):void
---@field setFrame fun(param1:number, param2:number):void
---@field getCurrentMovieClip fun():FlashMovieClip
---@field getElement fun(param1:number):FlashMovieClip
---@field getAt fun(param1:number):FlashMovieClip
---@field getElementByListID fun(param1:number):FlashMovieClip
---@field selectLastElement fun():void
---@field isLastElement fun(param1:FlashMovieClip):boolean
---@field isFirstElement fun(param1:FlashMovieClip):boolean
---@field getElementByNumber fun(param1:string, param2:number):FlashMovieClip
---@field getElementByBool fun(param1:string, param2:boolean):FlashMovieClip
---@field selectByOffset fun(param1:number, param2:boolean):boolean
---@field getElementByString fun(param1:string, param2:string):FlashMovieClip
---@field cleanUpElements fun():void
---@field positionElements fun():void
---@field getElementWidth fun(param1:FlashMovieClip):number
---@field getElementHeight fun(param1:FlashMovieClip):number
---@field getContentHeight fun():number
---@field moveElementsToPosition fun(param1:number.8, param2:boolean):void
---@field moveElementToPosition fun(param1:number, param2:number):boolean
---@field moveElementToBack fun(param1:number):void
---@field onRemovedFromStage fun(param1:Event):void
---@field addElement fun(param1:DisplayObject, param2:boolean, param3:boolean):void
---@field addElementOnPosition fun(param1:DisplayObject, param2:integer, param3:boolean, param4:boolean):void
---@field addElementToFront fun(param1:DisplayObject, param2:boolean):void
---@field resetListPos fun():void
---@field stopElementTweens fun(param1:number):void
---@field fadeOutAndRemoveElement fun(param1:number, param2:number, param3:number, param4:boolean, param5:boolean):void
---@field removeElement fun(param1:number, param2:boolean, param3:boolean, param4:number.3):void
---@field removeElementByListId fun(param1:number, param2:boolean):boolean
---@field clearElements fun():void
---@field next fun():void
---@field previous fun():void
---@field getPreviousVisibleElement fun():FlashMovieClip
---@field selectByListID fun(param1:number):void
---@field selectMC fun(param1:FlashMovieClip, param2:boolean):void
---@field clearSelection fun():void
---@field select fun(param1:number, param2:boolean, param3:boolean):void
---@field filterShowAll fun():void
---@field filterHideAll fun():void
---@field filterHideBoolean fun(param1:string, param2:boolean):void
---@field filterShowBoolean fun(param1:string, param2:boolean, param3:boolean):void
---@field filterBySubString fun(param1:string, param2:string):void
---@field filterShowType fun(param1:string, param2:Object, param3:boolean):void
---@field filterHideType fun(param1:string, param2:Object):void
---@field filterType fun(param1:string, param2:Object):void
---@field getFirstElement fun(param1:boolean, param2:boolean):FlashMovieClip
---@field getFirstVisible fun(param1:boolean):FlashMovieClip
---@field getLastElement fun(param1:boolean, param2:boolean):FlashMovieClip
---@field getLastVisible fun(param1:boolean):FlashMovieClip
---@field selectFirstVisible fun(param1:boolean):void
---@field sortOn fun(param1:Object, param2:Object, param3:boolean):void
---@field redoSort fun():void
---@field sortOnce fun(param1:Object, param2:Object, param3:boolean):void
---@field cursorLeft fun():void
---@field cursorRight fun():void
---@field cursorUp fun():void
---@field cursorDown fun():void
---@field cursorAccept fun():void
---@field isOverlappingPosition fun(targetX:number, targetY:number, shapeTest:boolean):void

---@class FlashScrollList:FlashListDisplay
---@field m_scrollbar_mc scrollbar
---@field m_bottomAligned boolean
---@field m_allowAutoScroll boolean
---@field m_SBSpacing number
---@field m_mouseWheelWhenOverEnabled boolean
---@field m_mouseWheelEnabled boolean
---@field m_ScrollHeight number
---@field m_allowKeepIntoView boolean
---@field leftAligned boolean
---@field m_TextGlowOffset number
---@field m_dragAutoScroll boolean
---@field m_dragAutoScrollDistance number
---@field m_dragAutoScrollMod number
---@field m_bgTile1_mc FlashMovieClip
---@field m_bgTile2_mc FlashMovieClip
---@field selectMC fun(param1:FlashMovieClip, param2:boolean):void
---@field clearElements fun():void
---@field resetScroll fun():void
---@field selectByOffset fun(param1:number, param2:boolean):boolean
---@field checkScrollBar fun():void
---@field setFrameWidth fun(param1:number):void
---@field setFrame fun(param1:number, param2:number):void
---@field setFrameHeight fun(param1:number):void
---@field positionElements fun():void


---@class CombatLogFlashMainTimeline:FlashMainTimeline
---@field log_mc CombatLogFlashMC
---@field events table
---@field layout string
---@field isUIMoving boolean
---@field tooltip_array table
---@field onEventResize fun():void
---@field onEventResolution fun(w:number, h:number):void
---@field onEventUp fun(index:number):void
---@field onEventInit fun():void
---@field onEventDown fun(index:number):void
---@field addFilter fun(index:number, tooltip:string, frame:number):void
---@field addTab fun(tabTooltip:string):void
---@field addTextToFilter fun(index:number, text:string):void
---@field addTextToTab fun(index:number, text:string):void
---@field clearAll fun():void
---@field clearAllTexts fun():void
---@field clearFilter fun(index:number):void
---@field clearTab fun(index:number):void
---@field reOpen fun():void
---@field requestSize fun():void
---@field selectFilter fun(index:number):void
---@field setBGVisibility fun(b:boolean):void
---@field setFilterSelection fun(index:number, b:boolean):void
---@field setLockInput fun(b:boolean):void
---@field setLogSize fun(b:number, param2:number):void
---@field setLogVisible fun(b:boolean):void
---@field setTooltip fun(index:number, tooltip:string):void
---@field startsWith fun(str1:string, str2:string):boolean

---@class CombatLogFlashMC:FlashMovieClip
---@field bg_mc FlashMovieClip
---@field filterHolder_mc FlashMovieClip
---@field hide_mc FlashMovieClip
---@field lock_mc FlashMovieClip
---@field resize_mc FlashMovieClip
---@field visibility_mc FlashMovieClip
---@field filterList FlashHorizontalList
---@field filterAmount number
---@field filterDist number
---@field resized boolean
---@field textList scrollList
---@field textOrder number
---@field currentText string
---@field isMouseOver boolean
---@field dragStartMP Point
---@field windowDragStarted boolean
---@field acceptInput boolean
---@field constrBoxX number
---@field constrBoxWidth number
---@field constrBoxHeight number
---@field constrBoxY number
---@field base FlashMovieClip
---@field fadeBG boolean
---@field lockInput boolean
---@field bgVisible boolean
---@field maxLinesCap number
---@field previousMax number
---@field frameW number
---@field sizeDispl number
---@field resizeDragging boolean
---@field addFilter fun(id:number, tooltip:string, frame:number):void
---@field addTextToFilter fun(param1:number, param2:string):void
---@field clearAll fun():void
---@field clearAllTexts fun():void
---@field clearFilter fun(param1:number):void
---@field dragInv fun(param1:MouseEvent):void
---@field dragInvMove fun(param1:MouseEvent):void
---@field filterInput fun(param1:number, param2:boolean):void
---@field getFilter fun(param1:number):CombatLogFlashFilter
---@field mouseLeave fun(param1:Event):void
---@field onBgHide fun(param1:MouseEvent):void
---@field onBgMouseOut fun(param1:MouseEvent):void
---@field onBgMouseOver fun(param1:MouseEvent):void
---@field onBgShow fun(param1:MouseEvent):void
---@field onMoveResize fun(param1:MouseEvent):void
---@field onResizeOut fun(param1:MouseEvent):void
---@field onResizeOver fun(param1:MouseEvent):void
---@field onResizeStartDrag fun(param1:MouseEvent):void
---@field onResizeStopDrag fun(param1:MouseEvent):void
---@field onSBOut fun(param1:MouseEvent):void
---@field onSBOver fun(param1:MouseEvent):void
---@field refreshText fun():void
---@field removeFilterEntriesFromList fun(param1:number):void
---@field removeOldLines fun():void
---@field resizing fun():void
---@field selectFilter fun(param1:number):void
---@field setBGVisibility fun(param1:boolean):void
---@field setFilterSelection fun(param1:number, param2:boolean):void
---@field setListWidths fun(param1:number):void
---@field setLockInput fun(param1:boolean):void
---@field setLogSize fun(param1:number, param2:number):void
---@field setScrollWheelEnabled fun(param1:boolean):void
---@field stopDragging fun():void
---@field stopDragInv fun(param1:MouseEvent):void
---@field toggleFadeVisibility fun():void
---@field toggleLock fun():void

---@class CombatLogFlashFilter:FlashMovieClip
---@field id integer
---@field tooltip string
---@field bg_mc FlashMovieClip
---@field icon_mc FlashMovieClip
---@field fadeTime number
---@field selectedB boolean
---@field timeline TweensyTimelineZero
---@field textContent string
---@field onDown fun(param1:MouseEvent):void
---@field onOut fun(param1:MouseEvent):void
---@field onOver fun(param1:MouseEvent):void