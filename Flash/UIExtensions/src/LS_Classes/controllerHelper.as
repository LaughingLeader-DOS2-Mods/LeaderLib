package LS_Classes
{
	public class controllerHelper
	{
		public static const BTN_B:uint = 1;
		public static const BTN_A:uint = 2;
		public static const BTN_X:uint = 3;
		public static const BTN_Y:uint = 4;
		public static const BTN_LT:uint = 5;
		public static const BTN_RT:uint = 6;
		public static const BTN_StickLeft:uint = 7;
		public static const BTN_StickRight:uint = 8;
		public static const BTN_StickLeft_up:uint = 9;
		public static const BTN_StickLeft_down:uint = 10;
		public static const BTN_StickLeft_left:uint = 11;
		public static const BTN_StickLeft_right:uint = 12;
		public static const BTN_StickLeft_horiz:uint = 13;
		public static const BTN_StickLeft_vert:uint = 14;
		public static const BTN_StickRight_up:uint = 15;
		public static const BTN_StickRight_down:uint = 16;
		public static const BTN_StickRight_left:uint = 17;
		public static const BTN_StickRight_right:uint = 18;
		public static const BTN_StickRight_horiz:uint = 19;
		public static const BTN_StickRight_vert:uint = 20;
		public static const BTN_DPad_up:uint = 21;
		public static const BTN_DPad_down:uint = 22;
		public static const BTN_DPad_left:uint = 23;
		public static const BTN_DPad_right:uint = 24;
		public static const BTN_DPad_horiz:uint = 25;
		public static const BTN_DPad_vert:uint = 26;
		public static const BTN_Back:uint = 27;
		public static const BTN_Start:uint = 28;
		public static const BTN_StickLeft_press:uint = 29;
		public static const BTN_StickRight_press:uint = 30;
		public static const BTN_LB:uint = 31;
		public static const BTN_RB:uint = 32;
		 
		
		public function controllerHelper()
		{
			super();
		}
		
		public static function getIconClassName(param1:uint, param2:Boolean = false) : String
		{
			var val3:String = "";
			switch(param1)
			{
				case BTN_B:
					if(param2)
					{
						val3 = "LS_Symbols.consoleHints.iconBigCircle";
					}
					else
					{
						val3 = "LS_Symbols.consoleHints.iconCircle";
					}
					break;
				case BTN_A:
					if(param2)
					{
						val3 = "LS_Symbols.consoleHints.iconBigCross";
					}
					else
					{
						val3 = "LS_Symbols.consoleHints.iconCross";
					}
					break;
				case BTN_X:
					val3 = "LS_Symbols.consoleHints.iconSquare";
					break;
				case BTN_Y:
					val3 = "LS_Symbols.consoleHints.iconTriangle";
					break;
				case BTN_LT:
					val3 = "LS_Symbols.consoleHints.iconLT";
					break;
				case BTN_RT:
					val3 = "LS_Symbols.consoleHints.iconRT";
					break;
				case BTN_StickLeft:
					val3 = "LS_Symbols.consoleHints.iconStickLeft";
					break;
				case BTN_StickRight:
					val3 = "LS_Symbols.consoleHints.iconStickRight";
					break;
				case BTN_StickLeft_up:
					val3 = "LS_Symbols.consoleHints.iconStickLeft_up";
					break;
				case BTN_StickLeft_down:
					val3 = "LS_Symbols.consoleHints.iconStickLeft_down";
					break;
				case BTN_StickLeft_left:
					val3 = "LS_Symbols.consoleHints.iconStickLeft_left";
					break;
				case BTN_StickLeft_right:
					val3 = "LS_Symbols.consoleHints.iconStickLeft_right";
					break;
				case BTN_StickLeft_horiz:
					val3 = "LS_Symbols.consoleHints.iconStickLeft_horiz";
					break;
				case BTN_StickLeft_vert:
					val3 = "LS_Symbols.consoleHints.iconStickLeft_vert";
					break;
				case BTN_StickRight_up:
					val3 = "LS_Symbols.consoleHints.iconStickRight_up";
					break;
				case BTN_StickRight_down:
					val3 = "LS_Symbols.consoleHints.iconStickRight_down";
					break;
				case BTN_StickRight_left:
					val3 = "LS_Symbols.consoleHints.iconStickRight_left";
					break;
				case BTN_StickRight_right:
					val3 = "LS_Symbols.consoleHints.iconStickRight_right";
					break;
				case BTN_StickRight_horiz:
					val3 = "LS_Symbols.consoleHints.iconStickRight_horiz";
					break;
				case BTN_StickRight_vert:
					val3 = "LS_Symbols.consoleHints.iconStickRight_vert";
					break;
				case BTN_DPad_up:
					val3 = "LS_Symbols.consoleHints.iconDpad_up";
					break;
				case BTN_DPad_down:
					val3 = "LS_Symbols.consoleHints.iconDpad_down";
					break;
				case BTN_DPad_left:
					val3 = "LS_Symbols.consoleHints.iconDpad_left";
					break;
				case BTN_DPad_right:
					val3 = "LS_Symbols.consoleHints.iconDpad_right";
					break;
				case BTN_DPad_horiz:
					val3 = "LS_Symbols.consoleHints.iconDpad_horiz";
					break;
				case BTN_DPad_vert:
					val3 = "LS_Symbols.consoleHints.iconDpad_vert";
					break;
				case BTN_Back:
					val3 = "LS_Symbols.consoleHints.iconBack";
					break;
				case BTN_Start:
					val3 = "LS_Symbols.consoleHints.iconStart";
					break;
				case BTN_StickLeft_press:
					val3 = "LS_Symbols.consoleHints.iconStickLeft_press";
					break;
				case BTN_StickRight_press:
					val3 = "LS_Symbols.consoleHints.iconStickRight_press";
					break;
				case BTN_LB:
					val3 = "LS_Symbols.consoleHints.iconLB";
					break;
				case BTN_RB:
					val3 = "LS_Symbols.consoleHints.iconRB";
			}
			return val3;
		}
		
		public static function getIconHLClassName(param1:uint, param2:Boolean = false) : String
		{
			var val3:String = "";
			switch(param1)
			{
				case BTN_LT:
					val3 = "LS_Symbols.consoleHints.iconLTHL";
					break;
				case BTN_RT:
					val3 = "LS_Symbols.consoleHints.iconRTHL";
			}
			return val3;
		}
	}
}
