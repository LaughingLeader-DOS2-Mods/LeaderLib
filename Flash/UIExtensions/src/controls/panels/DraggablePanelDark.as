package controls.panels
{
	import LS_Classes.scrollList;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import controls.buttons.MinimizeButton;
	import controls.buttons.CloseButton;
	import flash.external.ExternalInterface;
	import LS_Classes.LSPanelHelpers;
	
	public dynamic class DraggablePanelDark extends BaseDraggablePanel implements IPanel
	{
		public var listHolder_mc:MovieClip;
		public var hit_mc:MovieClip;
		public var title_txt:TextField;
		public var bg_mc:MovieClip;
		public var minimize_mc:MinimizeButton;
		public var close_mc:CloseButton;
		public var list:scrollList;

		public var id:String = "";
		public var minimized:Boolean = false;
		
		public function DraggablePanelDark()
		{
			super();
		}
		
		public function init(title:String="") : void
		{
			this.title_txt.htmlText = title;
			if(this.list != null)
			{
				this.list.clearElements();
				this.listHolder_mc.removeChild(this.list);
			}
			this.list = new scrollList("controls.scrollbar.ScrollDown","controls.scrollbar.ScrollUp","controls.scrollbar.ScrollHandle","controls.scrollbar.ScrollMover");
			this.list.dragAutoScroll = true;
			this.list.EL_SPACING = 0;
			this.list.scrollbarSpacing = 0;
			this.list.m_scrollbar_mc.m_hideWhenDisabled = false;
			this.list.mouseWheelWhenOverEnabled = true;
			this.list.setFrame(412,792);
			this.list.m_scrollbar_mc.SND_Click = "UI_GM_Generic_Click_Press";
			this.list.m_scrollbar_mc.SND_Over = "";
			this.list.m_scrollbar_mc.SND_Release = "UI_GM_Generic_Click_Release";
			this.listHolder_mc.addChild(this.list);
		}
		
		public function addText(text:String) : void
		{
			var tf:PanelTextEntry = new PanelTextEntry();
			tf.text_txt.width = 410;
			tf.setText(text);
			this.list.addElement(tf);
		}
		
		public function positionElements() : void
		{
			if(this.list != null)
			{
				this.list.positionElements();
			}
		}

		public function onClose(): void
		{
			Registry.ExtCall("hideTooltip");
			if(this.list != null)
			{
				this.list.clearElements();
				this.listHolder_mc.removeChild(this.list);
			}
			MainTimeline.Instance.panels_mc.removePanel(this);
		}

		public function onMinimize(): void
		{
			this.minimized = !this.minimized;
			if(this.list != null)
			{
				this.list.visible = !this.minimized;
			}
			if(this.minimized)
			{
				this.bg_mc.gotoAndStop(2);
			}
			else
			{
				this.bg_mc.gotoAndStop(1);
			}
		}
		
		public override function frame1() : void
		{
			super.frame1();
			this.close_mc.init(this.onClose);
			this.minimize_mc.init(this.onMinimize);
			this.initializeDrag(this.hit_mc);
			//LSPanelHelpers.makeDraggable(this.hit_mc);
		}
	}
}
