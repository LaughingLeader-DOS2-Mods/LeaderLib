package
{
	import flash.utils.getDefinitionByName;
	import flash.utils.Dictionary;
	import flash.external.ExternalInterface;
	import font.*;

	public class Registry
	{
		private static var _canCallExternally:Boolean = true;

		private static var _debugMode:Boolean = false;
		public static function get DebugMode():Boolean
		{
			return _debugMode;
		}

		private static var ClassMap:Dictionary = new Dictionary();

		/* Font classes
		Source: Public/Game/GUI/fonts.lsx
		$Default = QuadraatOffcPro.ttf
		$Default_Bold = QuadraatOffcPro-Bold.ttf
		$BigNumbers = COLLEGIATEBLACKFLF.TTF
		$Title = QuadraatOffcPro.ttf
		$Title_Bold = QuadraatOffcPro-Bold.ttf
		$Title_Italic = QuadraatOffcPro-Italic.ttf
		$Fallback = FZHei-B01.ttf
		*/

		public static function Init() : *
		{
			if(!ExternalInterface.available)
			{
				_canCallExternally = false;
				_debugMode = true;
			}
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
				if(args && args.length > 0)
				{
					var argsStr:String = "";
					var len:uint = args.length;
					for(var i:uint=0; i < len; i++)
					{
						if(args[i] is String)
						{
							argsStr = argsStr + "\"%s\"";
						}
						else
						{
							argsStr = argsStr + "%s";
						}
						
						if(i < len-1)
						{
							argsStr = argsStr + ", ";
						}
					}
					var msg:String = "[Registry] ExternalInterface.call(\"%s\", " + argsStr + ")";
					args.unshift(msg, name);
					Registry.Log.apply(null, args);
					//Registry.Log("[Registry] ExternalInterface.call(\"%s\",%s)", name, args);
				}
				else
				{
					Registry.Log("[Registry] ExternalInterface.call(\"%s\")", name);
				}
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
			if (!_canCallExternally)
			{
				trace(msg);
			}
			else
			{
				ExtCall("UIAssert", msg);
			}
		}

		public static function IsValidString(str:String):Boolean
		{
			if (str == null || str == "")
			{
				return false;
			}
			return true;
		}
	}
}