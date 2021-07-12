package ContextMenu
{
	import fl.motion.easing.Quartic;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import LS_Classes.IggyTween;
	
	public dynamic class ContextMenuBG extends MovieClip
	{
		public var bottom_mc:MovieClip;
		public var container_mc:MovieClip;
		public var firstLine_mc:MovieClip;
		public var mid_mc:MovieClip;
		public var title_txt:TextField;
		public var top_mc:MovieClip;
		public const bottomOffset:uint = 10;
		public const iggyDuration:Number = 0.2;
		public var contextContent:MovieClip;
		public var scaleTween:IggyTween;
		public var listAlphaTween:IggyTween;
		
		public function ContextMenuBG()
		{
			super();
			this.addFrameScript(0,this.frame1);
		}
		
		public function setHeight(height:Number, contextContent:MovieClip) : *
		{
			var tweenHeight:uint = 0;
			if(contextContent)
			{
				this.contextContent = contextContent;
				tweenHeight = this.container_mc.y + this.container_mc.height;
				this.animateOpening(tweenHeight);
				//ExternalInterface.call("setHeight", height + this.bottom_mc.height);
			}
			else
			{
				ExternalInterface.call("UIAssert","There is an empty content list in the contextmenu!");
			}
		}
		
		public function animateOpening(height:uint) : *
		{
			var frameHeight:uint = height;
			if(this.scaleTween != null)
			{
				this.scaleTween.stop();
				this.scaleTween = null;
			}
			if(this.listAlphaTween != null)
			{
				this.listAlphaTween.stop();
				this.listAlphaTween = null;
			}
			this.scaleTween = new IggyTween(this.mid_mc,"height",Quartic.easeOut,0,frameHeight,this.iggyDuration,true);
			this.scaleTween.motionFinishCallback = function():*
			{
				removeEventListener(Event.ENTER_FRAME,animationLoop);
			};
			this.listAlphaTween = new IggyTween(this.contextContent,"alpha",Quartic.easeOut,0,1,this.iggyDuration * 2,true);
			addEventListener(Event.ENTER_FRAME,this.animationLoop);
		}
		
		public function animationLoop() : *
		{
			this.contextContent.scrollRect = new Rectangle(0,0,this.contextContent.width,this.mid_mc.height);
			this.bottom_mc.y = this.mid_mc.y + this.mid_mc.height - this.bottomOffset;
		}
		
		public function frame1() : void
		{
			this.contextContent = null;
			this.scaleTween = null;
			this.listAlphaTween = null;
		}
	}
}