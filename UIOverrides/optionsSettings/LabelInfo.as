package
{
	import LS_Classes.textEffect;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	public dynamic class LabelInfo extends MovieClip
	{
		 
		
		public var info_txt:TextField;
		
		public var label_txt:TextField;
		
		public var mHeight:Number;
		
		public function LabelInfo()
		{
			super();
			addFrameScript(0,this.frame1);
		}
		
		public function deselectElement(param1:MouseEvent) : *
		{
		}
		
		public function selectElement(param1:MouseEvent) : *
		{
		}
		
		function frame1() : *
		{
			this.label_txt.filters = textEffect.createStrokeFilter(0,1.2,1,1.4,3);
			this.mHeight = 40;
			//this.label_txt.x = 20;
			//this.label_txt.y = 0;
			//this.info_txt.y = 0;
			//this.info_txt.x = this.label_txt.x + this.label_txt.width + 20;
		}
	}
}
