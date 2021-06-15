package LS_Classes
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.external.ExternalInterface;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextLineMetrics;
	import flash.utils.getDefinitionByName;
	
	public class textHelpers
	{
		public function textHelpers()
		{
			super();
		}
		
		public static function smallCaps(param1:TextField, param2:Number = 7, param3:Boolean = false, param4:String = "") : void
		{
			var val12:Object = null;
			var val13:Number = NaN;
			var val14:String = null;
			var val15:Array = null;
			var val16:Number = NaN;
			var val17:Number = NaN;
			var val18:String = null;
			var val19:String = null;
			var val5:String = "";
			var val6:TextFormat = param1.getTextFormat();
			var val7:Number = Number(val6.size);
			var val8:Number = val7 - param2;
			var val9:String = param1.htmlText;
			if(param4 != "")
			{
				val9 = param4;
			}
			var val10:Array = getFullTags(val9);
			if(val10.length == 0)
			{
				val12 = new Object();
				val12.tagStr = "";
				val12.charPos = 0;
				val12.tagContent = val9;
				val10.push(val12);
			}
			var val11:Number = 0;
			while(val11 < val10.length)
			{
				val13 = val9.length - 1;
				if(val11 + 1 != val10.length)
				{
					val13 = val10[val11 + 1].charPos;
				}
				val14 = val10[val11].tagContent;
				val15 = new Array(val14);
				if(param3)
				{
					val15 = val14.split(" ");
				}
				val5 = val5 + ("" + val10[val11].tagStr);
				val16 = 0;
				while(val16 < val15.length)
				{
					if(val15[val16].length > 0)
					{
						val17 = Number(val15[val16]);
						if(isNaN(val17))
						{
							val18 = val15[val16].charAt(0).toUpperCase();
							val19 = val15[val16].slice(1).toUpperCase();
							val5 = val5 + (val18 + "<font size=\'" + val8 + "\'>" + val19 + "</font>");
						}
						else
						{
							val5 = val5 + val17;
						}
						if(param3)
						{
							val5 = val5 + " ";
						}
					}
					val16++;
				}
				val11++;
			}
			param1.htmlText = val5;
		}
		
		public static function capTextFieldWidth(param1:TextField, param2:uint) : Boolean
		{
			var val3:Rectangle = null;
			var val4:uint = 0;
			var val5:String = null;
			if(param1.textWidth > param2)
			{
				val4 = 0;
				while(val4 < param1.length)
				{
					val3 = param1.getCharBoundaries(val4);
					if(val3.left > param2)
					{
						val5 = param1.htmlText.slice(0,val4);
						val5 = val5 + "...";
						param1.htmlText = val5;
						return true;
					}
					val4++;
				}
			}
			return false;
		}
		
		public static function toUpperCase(param1:String) : String
		{
			var val2:Array = getFullTags(param1);
			if(val2.length == 0)
			{
				return param1.toUpperCase();
			}
			var val3:String = "";
			var val4:Number = 0;
			while(val4 < val2.length)
			{
				val3 = val3 + ("" + val2[val4].tagStr + val2[val4].tagContent.toUpperCase());
				val4++;
			}
			return val3;
		}
		
		public static function cleanUpTextFieldDecoration(param1:Event) : *
		{
			var val4:MovieClip = null;
			var val2:TextField = param1.currentTarget as TextField;
			var val3:MovieClip = val2.parent as MovieClip;
			if(val3)
			{
				if(val3[val2.name + "Deco"] != null)
				{
					val4 = val3[val2.name + "Deco"];
					if(val4)
					{
						val4.graphics.clear();
					}
					val2.removeEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
				}
			}
		}
		
		public static function setFormattedText(param1:TextField, param2:String, param3:String = "$Title_Bold", param4:String = "$Title_Italic") : void
		{
			var val16:Number = NaN;
			var val17:Number = NaN;
			var val18:uint = 0;
			var val19:TextLineMetrics = null;
			var val20:int = 0;
			var val21:int = 0;
			var val22:Rectangle = null;
			var val23:Rectangle = null;
			var val24:Number = NaN;
			var val25:Number = NaN;
			var val26:int = 0;
			var val27:TextFormat = null;
			var val28:uint = 0;
			var val29:Number = NaN;
			var val5:Class = getDefinitionByName(param3) as Class;
			var val6:Class = getDefinitionByName(param4) as Class;
			var val7:Font = new val5();
			var val8:Font = new val6();
			var val9:TextFormat = param1.getTextFormat();
			var val10:MovieClip = param1.parent as MovieClip;
			val9.font = val8.fontName;
			var val11:TextFormat = param1.getTextFormat();
			val11.font = val7.fontName;
			param1.htmlText = param2;
			var val12:MovieClip = null;
			if(val10[param1.name + "Deco"] != null)
			{
				val12 = val10[param1.name + "Deco"];
				if(val12)
				{
					val12.graphics.clear();
				}
				param1.removeEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
			}
			var val13:Array = getTags(param2);
			var val14:int = 0;
			var val15:uint = 0;
			while(val15 < val13.length)
			{
				switch(val13[val15].tagStr)
				{
					case "<s>":
						val14 = findNextTag("</s>",val15,val13);
						if(val14 > 0 && val14 < val13.length)
						{
							val16 = param1.getLineIndexOfChar(val13[val15].charPos);
							val17 = param1.getLineIndexOfChar(val13[val14].charPos);
							if(val17 < 0)
							{
								val17 = param1.numLines - 1;
							}
							if(val16 >= 0 && val17 >= 0)
							{
								val18 = val16;
								while(val18 <= val17)
								{
									if(val12 == null)
									{
										val12 = val10[param1.name + "Deco"] = new MovieClip();
										val10.addChild(val12);
										val12.x = param1.x;
										val12.y = param1.y;
										param1.addEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
									}
									val19 = param1.getLineMetrics(val18);
									val20 = param1.getLineOffset(val18);
									val21 = val20 + param1.getLineLength(val18);
									if(val20 < val13[val15].charPos)
									{
										val20 = val13[val15].charPos;
									}
									if(val21 > val13[val14].charPos)
									{
										val21 = val13[val14].charPos;
									}
									val22 = param1.getCharBoundaries(val20);
									val23 = param1.getCharBoundaries(val21 - 1);
									if(val22)
									{
										val24 = Boolean(val23)?Number(val23.right):Number(val22.right);
										val25 = val22.left;
										val26 = val19.ascent * 0.8 + val22.top;
										val27 = param1.getTextFormat(val13[val15].charPos,val13[val14].charPos);
										if(val27.color == null)
										{
											val27 = param1.getTextFormat(val13[val15].charPos,val13[val15].charPos + 1);
										}
										val28 = new uint(val27.color);
										val29 = new Number(val27.size);
										val12.graphics.lineStyle(Math.ceil(val29 * 0.08),val28);
										val12.graphics.moveTo(val25,val26);
										val12.graphics.lineTo(val24,val26);
									}
									val18++;
								}
							}
						}
						break;
					case "<u>":
						val14 = findNextTag("</u>",val15,val13);
						if(val14 > 0 && val14 < val13.length)
						{
							val16 = param1.getLineIndexOfChar(val13[val15].charPos);
							val17 = param1.getLineIndexOfChar(val13[val14].charPos);
							if(val17 < 0)
							{
								val17 = param1.numLines - 1;
							}
							if(val16 >= 0 && val17 >= 0)
							{
								val18 = val16;
								while(val18 <= val17)
								{
									if(val12 == null)
									{
										val12 = val10[param1.name + "Deco"] = new MovieClip();
										val10.addChild(val12);
										val12.x = param1.x;
										val12.y = param1.y;
										param1.addEventListener(Event.REMOVED_FROM_STAGE,cleanUpTextFieldDecoration);
									}
									val19 = param1.getLineMetrics(val18);
									val20 = param1.getLineOffset(val18);
									val21 = val20 + param1.getLineLength(val18);
									if(val20 < val13[val15].charPos)
									{
										val20 = val13[val15].charPos;
									}
									if(val21 > val13[val14].charPos)
									{
										val21 = val13[val14].charPos;
									}
									val22 = param1.getCharBoundaries(val20);
									if(val22)
									{
										val23 = param1.getCharBoundaries(val21 - 1);
										if(val23)
										{
											val23 = param1.getCharBoundaries(val21 - 2);
										}
										val24 = Boolean(val23)?Number(val23.right):Number(val22.right);
										val25 = val22.left;
										val27 = param1.getTextFormat(val13[val15].charPos,val13[val14].charPos);
										val28 = new uint(val27.color);
										val29 = new Number(val27.size);
										val26 = val19.ascent + val19.descent * 0.04 * val29 + val22.top;
										val12.graphics.lineStyle(Math.ceil(val29 * 0.08),val28);
										val12.graphics.moveTo(val25,val26);
										val12.graphics.lineTo(val24,val26);
									}
									val18++;
								}
							}
						}
						break;
					case "<b>":
						val14 = findNextTag("</b>",val15,val13);
						if(val14 > 0 && val14 < val13.length)
						{
							param1.setTextFormat(val11,val13[val15].charPos,val13[val14].charPos);
						}
						break;
					case "<i>":
						val14 = findNextTag("</i>",val15,val13);
						if(val14 > 0 && val14 < val13.length)
						{
							param1.setTextFormat(val9,val13[val15].charPos,val13[val14].charPos);
						}
				}
				val15++;
			}
		}
		
		private static function findNextTag(param1:String, param2:uint, param3:Array) : int
		{
			var val4:uint = param2;
			while(val4 < param3.length)
			{
				if(param3[val4].tagStr == param1)
				{
					return val4;
				}
				val4++;
			}
			return -1;
		}
		
		private static function getFullTags(param1:String) : Array
		{
			var val5:Object = null;
			var val2:Array = new Array();
			var val3:int = 0;
			var val4:int = param1.indexOf("<",val3);
			while(val4 != -1)
			{
				val3 = val4;
				val4 = param1.indexOf(">",val3);
				val5 = new Object();
				val5.tagStr = param1.substring(val3,val4 + 1);
				val5.charPos = val3;
				val2.push(val5);
				val3 = val4;
				val4 = param1.indexOf("<",val3);
				if(val3 == -1 && val4 == -1 || val3 >= param1.length - 1)
				{
					val5.tagContent = "";
				}
				else if(val4 == -1)
				{
					val5.tagContent = param1.substring(val3 + 1);
				}
				else
				{
					val5.tagContent = param1.substring(val3 + 1,val4);
				}
			}
			return val2;
		}
		
		private static function getTags(param1:String) : Array
		{
			var val6:Object = null;
			var val2:Array = new Array();
			var val3:int = 0;
			var val4:int = param1.indexOf("<",val3);
			var val5:int = 0;
			while(val4 != -1)
			{
				val3 = val4;
				val4 = param1.indexOf(">",val3);
				val6 = new Object();
				val6.tagStr = param1.substr(val3,val4 - val3 + 1);
				val6.charPos = val3 - val5;
				val2.push(val6);
				val5 = val5 + val6.tagStr.length;
				val3 = val4;
				val4 = param1.indexOf("<",val3);
			}
			return val2;
		}
		
		public static function trim(param1:String) : String
		{
			var val2:Number = 0;
			while(param1.charAt(val2) == " ")
			{
				val2 = val2 + 1;
			}
			param1 = param1.substring(val2);
			var val3:Number = param1.length;
			val3 = val3 - 1;
			while(param1.charAt(val3) == " ")
			{
				val3 = val3 - 1;
			}
			param1 = param1.substring(0,val3 + 1);
			return param1;
		}
		
		public static function getLongestWordLength(param1:TextField) : Number
		{
			var val3:Boolean = false;
			var val4:Boolean = false;
			var val5:String = null;
			var val6:Number = NaN;
			var val7:Number = NaN;
			var val8:Number = NaN;
			var val9:Boolean = false;
			var val10:Rectangle = null;
			var val11:Rectangle = null;
			var val12:Number = NaN;
			var val13:Number = NaN;
			var val2:Number = 0;
			if(param1.text.length > 0)
			{
				val3 = param1.multiline;
				val4 = param1.wordWrap;
				val5 = param1.autoSize;
				param1.multiline = false;
				param1.autoSize = TextFieldAutoSize.LEFT;
				val6 = 0;
				val7 = 0;
				val8 = 0;
				val9 = false;
				while(val6 != -1)
				{
					val7 = val6;
					val6 = param1.text.indexOf(" ",val7 + 1);
					if(val6 == -1)
					{
						val6 = param1.text.length;
						val9 = true;
					}
					if(val6 != -1 && val7 != -1)
					{
						val10 = param1.getCharBoundaries(val6 - 1);
						if(val10)
						{
							val11 = param1.getCharBoundaries(val7);
							if(val11)
							{
								val12 = val10.right;
								val13 = val11.right;
								if(val7 == 0)
								{
									val13 = val11.left;
								}
								val8 = val12 - val13;
								if(val8 > val2)
								{
									val2 = val8;
								}
							}
						}
					}
					if(val9)
					{
						val6 = -1;
					}
				}
				if(val2 == 0)
				{
					val2 = param1.textWidth;
				}
				param1.multiline = val3;
				param1.wordWrap = val4;
				param1.autoSize = val5;
			}
			return Math.ceil(val2);
		}
		
		public static function firstLetterUpperCase(param1:String) : String
		{
			var val4:* = null;
			var val2:Array = param1.split(" ");
			var val3:Array = [];
			for(val4 in val2)
			{
				val3.push(val2[val4].charAt(0).toUpperCase() + val2[val4].slice(1));
			}
			return val3.join(" ");
		}
		
		public static function getSelectionLengthOfText(param1:TextField, param2:Number, param3:Number) : Number
		{
			var val4:Number = textHelpers.getCharIndexAtPoint(param1,param2,param3);
			var val5:Number = Math.max(param1.selectionEndIndex,param1.selectionBeginIndex);
			var val6:Number = Math.min(param1.selectionEndIndex,param1.selectionBeginIndex);
			if(val5 < val4 || val4 < val6)
			{
				param1.setSelection(val4,val4);
			}
			return Math.abs(param1.selectionEndIndex - param1.selectionBeginIndex);
		}
		
		public static function getCharIndexAtPoint(param1:TextField, param2:Number, param3:Number) : Number
		{
			var val9:Rectangle = null;
			var val10:Number = NaN;
			var val11:Number = NaN;
			var val4:Number = 0;
			var val5:Number = param1.text.length;
			var val6:Number = -1;
			var val7:Boolean = false;
			var val8:Number = 0;
			while(val8 < val5)
			{
				val9 = param1.getCharBoundaries(val8);
				if(val9)
				{
					val10 = val9.y + val9.height;
					if(val6 > 0 && val10 > val6)
					{
						val7 = true;
						break;
					}
					if(val10 > param3)
					{
						val6 = val10;
						if(val9.x > param2)
						{
							val7 = true;
							val11 = val9.x + val9.width / 2;
							if(param2 > val11)
							{
								val4++;
							}
							break;
						}
					}
				}
				val4 = val8;
				val8++;
			}
			return !!val7?Number(val4):Number(val5);
		}
		
		public static function makeInputFieldModal(param1:TextField, param2:Boolean = true) : *
		{
			if(param2)
			{
				param1.addEventListener(FocusEvent.FOCUS_IN,onFocusInModalInputField);
				param1.addEventListener(FocusEvent.FOCUS_OUT,onFocusOutModalInputField);
			}
			else
			{
				param1.removeEventListener(FocusEvent.FOCUS_IN,onFocusInModalInputField);
				param1.removeEventListener(FocusEvent.FOCUS_OUT,onFocusOutModalInputField);
				if(param1.selectionBeginIndex != -1)
				{
					ExternalInterface.call("inputFocusLost");
				}
			}
		}
		
		public static function onFocusInModalInputField(param1:FocusEvent) : *
		{
			var val2:TextField = null;
			if(param1.target is TextField)
			{
				val2 = param1.target as TextField;
				if(val2.type == TextFieldType.INPUT)
				{
					val2.removeEventListener(FocusEvent.FOCUS_IN,onFocusInModalInputField);
					val2.addEventListener(FocusEvent.FOCUS_OUT,onFocusOutModalInputField);
					ExternalInterface.call("inputFocus");
				}
			}
		}
		
		public static function onFocusOutModalInputField(param1:FocusEvent) : *
		{
			var val2:TextField = null;
			if(param1.target is TextField)
			{
				val2 = param1.target as TextField;
				if(val2.type == TextFieldType.INPUT)
				{
					val2.addEventListener(FocusEvent.FOCUS_IN,onFocusInModalInputField);
					val2.removeEventListener(FocusEvent.FOCUS_OUT,onFocusOutModalInputField);
					ExternalInterface.call("inputFocusLost");
				}
			}
		}
		
		public static function adjustFontSize(param1:TextField, param2:Number, param3:Number) : *
		{
			var val5:Number = NaN;
			var val6:Number = NaN;
			var val4:TextFormat = param1.getTextFormat();
			if(Number(val4.size) != param2)
			{
				val4.size = param2;
				param1.setTextFormat(val4);
			}
			if(param1.textWidth > param1.width)
			{
				val5 = param1.width / param1.textWidth;
				val6 = Math.floor(param2 * val5);
				if(val6 >= param3)
				{
					val4.size = val6;
					param1.setTextFormat(val4);
				}
				else
				{
					val4.size = param3;
					param1.setTextFormat(val4);
					capTextFieldWidth(param1,param1.width);
				}
			}
		}
	}
}
