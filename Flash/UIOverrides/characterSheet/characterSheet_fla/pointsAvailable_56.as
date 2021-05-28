package characterSheet_fla
{
	import LS_Classes.textHelpers;
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	public dynamic class pointsAvailable_56 extends MovieClip
	{
		public var civilAbilPoints_txt:TextField;
		public var combatAbilPoints_txt:TextField;
		public var label_txt:TextField;
		public var statPoints_txt:TextField;
		public var talentPoints_txt:TextField;
		public var customStatPoints_txt:TextField;
		
		public function pointsAvailable_56()
		{
			super();
			customStatPoints_txt = new TextField();
			customStatPoints_txt.name = "customStatPoints_txt";
			customStatPoints_txt.visible = false;
			addChild(customStatPoints_txt);
			addFrameScript(0,this.frame1);
		}
		
		public function setTab(tabIndex:uint) : *
		{
			trace("setTab", tabIndex);
			this.statPoints_txt.visible = Boolean(tabIndex == 0);
			this.combatAbilPoints_txt.visible = Boolean(tabIndex == 1);
			this.civilAbilPoints_txt.visible = Boolean(tabIndex == 2);
			this.talentPoints_txt.visible = Boolean(tabIndex == 3);
			this.customStatPoints_txt.visible = Boolean(tabIndex == 8);
		}
		
		function frame1() : *
		{
			textHelpers.smallCaps(this.label_txt);

			trace("pointsAvailable frame1")

			//customStatPoints_txt.visible = false;
			//var tf:TextFormat = this.combatAbilPoints_txt.getTextFormat();
			// var tf:TextFormat = new TextFormat();
			// tf.font = "Ubuntu Mono";
			// tf.size = 24;
			// tf.color = 16777215;
			// tf.align = TextFormatAlign.CENTER;
			// customStatPoints_txt.defaultTextFormat = tf;
			customStatPoints_txt.defaultTextFormat = this.combatAbilPoints_txt.getTextFormat();
			customStatPoints_txt.setTextFormat(customStatPoints_txt.defaultTextFormat);
			customStatPoints_txt.text = "0";
			customStatPoints_txt.multiline = false;
			// customStatPoints_txt.x = this.combatAbilPoints_txt.x;
			// customStatPoints_txt.y = this.combatAbilPoints_txt.y;
			// customStatPoints_txt.width = this.combatAbilPoints_txt.width;
			// customStatPoints_txt.height = this.combatAbilPoints_txt.height;
			customStatPoints_txt.x = this.combatAbilPoints_txt.x;//99.960006713867;
			customStatPoints_txt.y = this.combatAbilPoints_txt.y;//-5;
			customStatPoints_txt.width = this.combatAbilPoints_txt.width;//50;
			customStatPoints_txt.height = this.combatAbilPoints_txt.height;//34.0;
			customStatPoints_txt.autoSize = combatAbilPoints_txt.autoSize;
			
		}
	}
}
