package
{
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import flash.external.ExternalInterface;
	import font.*;
	import font.QuadraatBoldFont;
	import font.QuadraatFont;
	import font.QuadraatItalicFont;
	import flash.utils.getQualifiedClassName;

	public class Registry
	{
		private static var _canCallExternally:Boolean = true;
		private static var ClassMap:Dictionary = new Dictionary();

		public static function Init() : *
		{
			if(!ExternalInterface.available)
			{
				_canCallExternally = false;
			}

			/*
			Source: Public/Game/GUI/fonts.lsx
			$Default = QuadraatOffcPro.ttf
			$Default_Bold = QuadraatOffcPro-Bold.ttf
			$BigNumbers = COLLEGIATEBLACKFLF.TTF
			$Title = QuadraatOffcPro.ttf
			$Title_Bold = QuadraatOffcPro-Bold.ttf
			$Title_Italic = QuadraatOffcPro-Italic.ttf
			$Fallback = FZHei-B01.ttf
			*/
			ClassMap["$Default"] = QuadraatFont;
			ClassMap["$Default_Bold"] = QuadraatBoldFont;
			ClassMap["$BigNumbers"] = CollegiateBlackFLF;
			ClassMap["$Title"] = QuadraatFont;
			ClassMap["$Title_Bold"] = QuadraatBoldFont;
			ClassMap["$Title_Italic"] = QuadraatItalicFont;
		}

		public static function ExtCall(name:String, ...args:Array) : *
		{
			if(_canCallExternally)
			{
				args.unshift(name);
				ExternalInterface.call.apply(null, args);
				return true;
			} else {
				trace(name);
			}
			return false;
		}

		public static function GetClass(path:String) : Class
		{
			try
			{
				if(ClassMap[path] != null) {
					return ClassMap[path] as Class;
				}
				var c:Object = getDefinitionByName(path);
				if (c != null)
				{
					ClassMap[path] = c;
					return c as Class;
				}
			}
			catch(e:*) {
				trace(e);
			}
			trace("Failed to find class with path: " + path);
			return null;
		}

		public static function Log(msg:String, ...args:Array) : void
		{
			try
			{
				var len:uint = args.length;
				for(var i:uint=0; i < len; i++)
				{
					msg = msg.replace("%s", String(args[i]));
				}
			}
			catch(e:*) {
				trace(e);
			}
			if (!ExtCall("LeaderLib_UIAssert", msg))
			{
				trace(msg);
			}
		}
	}
}