package gameMenu_fla
{
			import flash.display.MovieClip;
			import flash.external.ExternalInterface;
			import flash.text.TextFormat;
			
			public dynamic class MenuMC_1 extends MovieClip
			{
						 
						
						public var buttonHolder_mc:MovieClip;
						
						public var decoButton_mc:buttonDeco;
						
						public var menuBG_mc:MovieClip;
						
						public var opened:Boolean;
						
						public var Root;
						
						public var arrItems:Array;
						
						public var selectedID:Number;
						
						public var totalHeight:Number;
						
						public var maxWidth:Number;
						
						public var factor:Number;
						
						public var buttonSpacing:Number;
						
						public var WidthSpacing:Number;
						
						public var HeightSpacing:Number;
						
						public var minWidth:Number;
						
						public var selectedPos:Number;
						
						public var defaultBtnId:Number;
						
						public var canLoop:Boolean;
						
						public function MenuMC_1()
						{
									super();
									addFrameScript(0,this.frame1);
						}
						
						public function openMenu() : *
						{
									ExternalInterface.call("PlaySound","UI_Game_PauseMenu_Open");
									this.alpha = 1;
									this.visible = true;
						}
						
						public function closeMenu() : *
						{
									ExternalInterface.call("PlaySound","UI_Game_PauseMenu_Close");
									ExternalInterface.call("requestCloseUI");
									if(this.selectedID != -1 && this.arrItems[this.selectedID])
									{
												this.arrItems[this.selectedID].bg_mc.gotoAndStop(1);
									}
						}

						public function insertMenuButton(id:Number, label:String, enabled:Boolean, atIndex:Number) : *
						{
									var textFormat:TextFormat = null;
									var button:MovieClip = new Menu_button();
									var count:Number = this.arrItems.length;
									button.pos = atIndex;
									if(count > 0)
									{
										button.y = this.arrItems[atIndex].y;
										var lastY = button.y;
										arrItems.splice(atIndex, 0, button);
										for (var i = atIndex+1; i < count; i++)
										{
											var nextButton = this.arrItems[i];
											nextButton.y = lastY + this.arrItems[i-1].height + this.buttonSpacing;
											lastY = nextButton.y;
											trace(i + "| Moved button down: " + nextButton.y);
										}
									}
									else
									{
										button.y = 0;
									}
									button.label_mc.text_txt.htmlText = label.toUpperCase();
									while(button.label_mc.text_txt.numLines > 1)
									{
										textFormat = button.label_mc.text_txt.getTextFormat();
										textFormat.size = textFormat.size - 1;
										button.label_mc.text_txt.setTextFormat(textFormat);
										button.label_mc.text_txt.y++;
									}
									button.defaultColour = !!enabled?16777215:10263708;
									button.id = id;
									button.name = "item" + id + "_mc";
									button.bg_mc.gotoAndStop(1);
									button.isEnabled = enabled;
									this.totalHeight = Number(Number(this.totalHeight + button.height));
									if(button.label_mc.text_txt.textWidth > this.minWidth)
									{
										if(this.maxWidth < button.label_mc.text_txt.textWidth)
										{
											this.maxWidth = Number(Number(button.label_mc.text_txt.textWidth));
										}
									}
									else
									{
										this.maxWidth = this.minWidth;
									}
									this.buttonHolder_mc.addChild(button);
									this.resetBtnsPos();
									ExternalInterface.call("onGameMenuButtonAdded",id,label);
						}
						
						public function addMenuButton(param1:Number, param2:String, param3:Boolean) : *
						{
									var _loc6_:TextFormat = null;
									var _loc4_:MovieClip = new Menu_button();
									var _loc5_:Number = this.arrItems.length;
									_loc4_.pos = this.arrItems.length;
									if(_loc5_ > 0)
									{
												_loc4_.y = this.arrItems[_loc5_ - 1].y + this.arrItems[_loc5_ - 1].height + this.buttonSpacing;
									}
									else
									{
												_loc4_.y = 0;
									}
									_loc4_.label_mc.text_txt.htmlText = param2.toUpperCase();
									while(_loc4_.label_mc.text_txt.numLines > 1)
									{
												_loc6_ = _loc4_.label_mc.text_txt.getTextFormat();
												_loc6_.size = _loc6_.size - 1;
												_loc4_.label_mc.text_txt.setTextFormat(_loc6_);
												_loc4_.label_mc.text_txt.y++;
									}
									_loc4_.defaultColour = !!param3?16777215:10263708;
									_loc4_.id = param1;
									_loc4_.name = "item" + param1 + "_mc";
									_loc4_.bg_mc.gotoAndStop(1);
									_loc4_.isEnabled = param3;
									this.totalHeight = Number(Number(this.totalHeight + _loc4_.height));
									if(_loc4_.label_mc.text_txt.textWidth > this.minWidth)
									{
												if(this.maxWidth < _loc4_.label_mc.text_txt.textWidth)
												{
															this.maxWidth = Number(Number(_loc4_.label_mc.text_txt.textWidth));
												}
									}
									else
									{
												this.maxWidth = this.minWidth;
									}
									this.buttonHolder_mc.addChild(_loc4_);
									this.arrItems.push(_loc4_);
									this.resetBtnsPos();
									ExternalInterface.call("onGameMenuButtonAdded",param1,param2);
						}
						
						public function resetBtnsPos() : *
						{
									this.buttonHolder_mc.y = 180 + Math.round((860 - this.buttonHolder_mc.height) * 0.5);
						}
						
						public function addDefaultMenuButton(param1:Number, param2:String, param3:Boolean) : *
						{
									var _loc4_:MovieClip = this.decoButton_mc;
									_loc4_.label_mc.text_txt.htmlText = param2.toUpperCase();
									_loc4_.id = param1;
									this.defaultBtnId = param1;
									_loc4_.pos = this.arrItems.length;
									_loc4_.bg_mc.gotoAndStop(1);
									_loc4_.defaultColour = !!param3?16777215:10263708;
									_loc4_.changeTextColour(_loc4_.defaultColour);
									_loc4_.isEnabled = param3;
									this.totalHeight = Number(Number(this.totalHeight + _loc4_.height));
									if(_loc4_.label_mc.text_txt.textWidth > this.minWidth)
									{
												if(this.maxWidth < _loc4_.label_mc.text_txt.textWidth)
												{
															this.maxWidth = Number(Number(_loc4_.label_mc.text_txt.textWidth));
												}
									}
									else
									{
												this.maxWidth = this.minWidth;
									}
									this.buttonHolder_mc.addChild(_loc4_);
									this.arrItems.push(_loc4_);
									_loc4_.x = 0;
									_loc4_.y = 0;
						}
						
						public function setButtonEnabled(param1:Number, param2:Boolean) : *
						{
									var _loc3_:MovieClip = this.getButton(param1);
									if(_loc3_)
									{
												_loc3_.isEnabled = param2;
												_loc3_.defaultColour = !!param2?16777215:10263708;
									}
						}
						
						public function setDefaultButtonEnabled(param1:Boolean) : *
						{
									if(this.decoButton_mc)
									{
												this.decoButton_mc.isEnabled = param1;
												itemMC.defaultColour = !!param1?16777215:10263708;
									}
						}
						
						public function moveCursor(param1:Boolean) : *
						{
									if(param1)
									{
												this.setCursorByPos(this.selectedPos - 1);
									}
									else
									{
												this.setCursorByPos(this.selectedPos + 1);
									}
									this.setListLoopable(false);
						}
						
						public function setListLoopable(param1:Boolean) : *
						{
									this.canLoop = param1;
						}
						
						public function setCursorByPos(param1:Number) : *
						{
									var _loc2_:MovieClip = null;
									if(param1 >= this.arrItems.length && this.canLoop)
									{
												param1 = 0;
									}
									if(param1 < 0 && this.canLoop)
									{
												param1 = this.arrItems.length - 1;
									}
									if(param1 >= 0 && param1 < this.arrItems.length)
									{
												_loc2_ = this.arrItems[param1];
												if(_loc2_)
												{
															this.setCursorPosition(_loc2_.id);
												}
									}
						}
						
						public function setCursorPosition(param1:Number) : *
						{
									var _loc2_:MovieClip = this.getButton(this.selectedID);
									if(_loc2_)
									{
												_loc2_.deselect();
									}
									var _loc3_:MovieClip = this.getButton(param1);
									if(_loc3_)
									{
												this.selectedID = param1;
												this.selectedPos = Number(Number(_loc3_.pos));
												_loc3_.select();
									}
						}
						
						public function getButton(param1:Number) : MovieClip
						{
									var _loc2_:MovieClip = null;
									var _loc3_:uint = 0;
									while(_loc3_ < this.arrItems.length)
									{
												if(this.arrItems[_loc3_].id == param1)
												{
															this.arrItems[_loc3_].pos = _loc3_;
															_loc2_ = this.arrItems[_loc3_];
															break;
												}
												_loc3_++;
									}
									return _loc2_;
						}
						
						public function executeSelected() : *
						{
									var _loc1_:MovieClip = this.getButton(this.selectedID);
									if(_loc1_)
									{
												_loc1_.buttonAction();
									}
						}
						
						public function removeItems() : *
						{
									var _loc1_:uint = 0;
									while(_loc1_ < this.arrItems.length)
									{
												this.buttonHolder_mc.removeChild(this.arrItems[_loc1_]);
												_loc1_++;
									}
									this.arrItems.splice(0,this.arrItems.length);
									this.totalHeight = Number(Number(0));
									this.maxWidth = Number(Number(0));
						}
						
						function frame1() : *
						{
									this.opened = false;
									this.Root = this;
									this.arrItems = new Array();
									this.selectedID = Number(Number(-1));
									this.totalHeight = Number(Number(0));
									this.maxWidth = Number(Number(0));
									this.factor = Number(Number(30));
									this.buttonSpacing = Number(Number(2));
									this.WidthSpacing = Number(Number(80));
									this.HeightSpacing = Number(Number(40));
									this.minWidth = Number(Number(400));
									this.selectedPos = Number(Number(-1));
									this.defaultBtnId = Number(Number(-2));
									this.canLoop = true;
						}
			}
}