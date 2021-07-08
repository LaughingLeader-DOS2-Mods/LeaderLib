package LS_Classes
{
	import flash.display.DisplayObject;
	import flash.display.InteractiveObject;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	public class LSDisplayObjectHelpers
	{
		public function LSDisplayObjectHelpers()
		{
			super();
		}
		
		public static function getDisplayObjectUnderCursor(param1:MovieClip, param2:Number, param3:Number) : DisplayObject
		{
			var val4:Point = null;
			var val7:DisplayObject = null;
			var val8:MovieClip = null;
			var val9:DisplayObject = null;
			var val10:TextField = null;
			var val5:int = param1.numChildren;
			var val6:int = val5 - 1;
			while(val6 >= 0)
			{
				val7 = param1.getChildAt(val6);
				if(val7.visible)
				{
					val4 = val7.globalToLocal(new Point(param2,param3));
					if(!(val7.scrollRect != null && (val4.x < 0 || val4.y < 0 || val7.scrollRect.width < val4.x || val7.scrollRect.height < val4.y)))
					{
						if(val7 is TextField)
						{
							val10 = val7 as TextField;
							if(val10 && val10.type == TextFieldType.INPUT && val10.mouseEnabled && (val4.x >= 0 && val4.y >= 0 && val10.width >= val4.x && val10.height >= val4.y))
							{
								return val7;
							}
						}
						if(val7.hitTestPoint(param2,param3,true))
						{
							val8 = val7 as MovieClip;
							if(val8 == null)
							{
								return val7;
							}
							if(val8.mouseEnabled)
							{
								val9 = getDisplayObjectUnderCursor(val8,param2,param3);
								if(val9 != null)
								{
									return val9;
								}
							}
						}
					}
				}
				val6--;
			}
			return null;
		}
		
		public static function getRelativePosition(param1:DisplayObject, param2:DisplayObject = null) : Point
		{
			var val5:Rectangle = null;
			var val3:Point = new Point(param1.x,param1.y);
			var val4:DisplayObject = param1.parent;
			while(val4 != null && (param1.stage != null && val4 != param1.stage))
			{
				if(val4 == param2)
				{
					val4 = null;
				}
				else
				{
					val3.x = val3.x + val4.x;
					val3.y = val3.y + val4.y;
					if(val4.scrollRect != null)
					{
						val5 = val4.scrollRect;
						val3.x = val3.x - val5.x;
						val3.y = val3.y - val5.y;
					}
					val4 = val4.parent;
				}
			}
			return val3;
		}
		
		public static function dispatchCustomMouseEvent(param1:DisplayObject, param2:String) : Boolean
		{
			var val4:Number = NaN;
			var val5:Number = NaN;
			var val6:DisplayObject = null;
			var val7:DisplayObject = null;
			var val8:Number = NaN;
			var val9:TextField = null;
			var val3:MovieClip = param1 as MovieClip;
			if(val3 != null)
			{
				val4 = param1.mouseX;
				val5 = param1.mouseY;
				val6 = getDisplayObjectUnderCursor(val3,val4,val5);
				val7 = val6;
				while(val7 != null)
				{
					if(val7.hasEventListener(param2))
					{
						val8 = 0;
						val9 = val6 as TextField;
						if(val9 != null && val9.numLines > 0)
						{
							val8 = val9.textHeight / val9.numLines * Math.max(0,val9.scrollV - 1);
						}
						val7.dispatchEvent(new MouseEvent(param2,true,false,val6.mouseX,val6.mouseY + val8,val6 as InteractiveObject,false,false,false,true));
						return true;
					}
					val7 = val7.parent;
				}
			}
			return false;
		}
	}
}
