package gameMenu_fla
{
			import flash.display.MovieClip;
			
			public dynamic class MainTimeline extends MovieClip
			{
						 
						
						public var gameMenu_mc:MovieClip;
						
						public var events:Array;
						
						public var layout:String;
						
						public const anchorId:String = "gameMenu";
						
						public const anchorPos:String = "center";
						
						public const anchorTPos:String = "center";
						
						public const anchorTarget:String = "screen";
						
						public function MainTimeline()
						{
									super();
									addFrameScript(0,this.frame1);
						}
						
						public function onEventInit() : *
						{
									ExternalInterface.call("registeranchorId","gameMenu");
									ExternalInterface.call("setAnchor","center","screen","center");
						}
						
						public function onEventResize() : *
						{
						}
						
						public function onEventUp(param1:Number) : Boolean
						{
									var _loc2_:Boolean = false;
									switch(this.events[param1])
									{
												case "IE UICancel":
												case "IE ToggleInGameMenu":
															_loc2_ = true;
															break;
												case "IE UIAccept":
															this.executeSelected();
															_loc2_ = true;
															break;
												case "IE UIUp":
												case "IE UIDown":
															this.gameMenu_mc.setListLoopable(true);
									}
									return _loc2_;
						}
						
						public function onEventDown(param1:Number) : Boolean
						{
									var _loc2_:Boolean = false;
									switch(this.events[param1])
									{
												case "IE UIUp":
															this.gameMenu_mc.moveCursor(true);
															_loc2_ = true;
															break;
												case "IE UIDown":
															this.gameMenu_mc.moveCursor(false);
															_loc2_ = true;
															break;
												case "IE UIAccept":
															_loc2_ = true;
															break;
												case "IE UICancel":
												case "IE ToggleInGameMenu":
															this.closeMenu();
															_loc2_ = true;
									}
									return _loc2_;
						}
						
						public function hideWin() : void
						{
									this.gameMenu_mc.visible = false;
						}
						
						public function showWin() : void
						{
									this.gameMenu_mc.visible = true;
						}
						
						public function getHeight() : Number
						{
									return this.gameMenu_mc.height;
						}
						
						public function getWidth() : Number
						{
									return this.gameMenu_mc.width;
						}
						
						public function setX(param1:Number) : void
						{
									this.gameMenu_mc.x = param1;
						}
						
						public function setY(param1:Number) : void
						{
									this.gameMenu_mc.y = param1;
						}
						
						public function setPos(param1:Number, param2:Number) : void
						{
									this.gameMenu_mc.x = param1;
									this.gameMenu_mc.y = param2;
						}
						
						public function getX() : Number
						{
									return this.gameMenu_mc.x;
						}
						
						public function getY() : Number
						{
									return this.gameMenu_mc.y;
						}
						
						public function openMenu() : *
						{
									this.gameMenu_mc.openMenu();
						}
						
						public function closeMenu() : *
						{
									this.gameMenu_mc.closeMenu();
						}
						
						public function fadeIn() : *
						{
									this.openMenu();
						}
						
						public function fadeOut() : *
						{
						}
						
						public function addMenuButton(param1:Number, param2:String, param3:Boolean) : *
						{
									this.gameMenu_mc.addMenuButton(param1,param2,param3);
						}
						
						public function addDefaultMenuButton(param1:Number, param2:String, param3:Boolean) : *
						{
									this.gameMenu_mc.addDefaultMenuButton(param1,param2,param3);
						}
						
						public function setButtonEnabled(param1:Number, param2:Boolean) : *
						{
									this.gameMenu_mc.setButtonEnabled(param1,param2);
						}
						
						public function setDefaultButtonEnabled(param1:Boolean) : *
						{
									this.gameMenu_mc.setDefaultButtonEnabled(param1);
						}
						
						public function executeSelected() : *
						{
									this.gameMenu_mc.executeSelected();
						}
						
						public function moveCursor(param1:String) : *
						{
									this.gameMenu_mc.moveCursor(param1);
						}
						
						public function removeItems() : *
						{
									this.gameMenu_mc.removeItems();
						}
						
						public function setCursorPosition(param1:Number) : *
						{
									this.gameMenu_mc.setCursorPosition(param1);
						}
						
						function frame1() : *
						{
									this.events = new Array("IE UIUp","IE UIDown","IE UIAccept","IE UICancel");
									this.layout = "fitVertical";
						}
			}
}
