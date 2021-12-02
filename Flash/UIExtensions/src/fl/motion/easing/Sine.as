package fl.motion.easing
{
	public class Sine
	{
		 
		
		public function Sine()
		{
			super();
		}
		
		public static function easeIn(a:Number, b:Number, c:Number, d:Number) : Number
		{
			return -c * Math.cos(a / d * (Math.PI / 2)) + c + b;
		}
		
		public static function easeOut(a:Number, b:Number, c:Number, d:Number) : Number
		{
			return c * Math.sin(a / d * (Math.PI / 2)) + b;
		}
		
		public static function easeInOut(a:Number, b:Number, c:Number, d:Number) : Number
		{
			return -c / 2 * (Math.cos(Math.PI * a / d) - 1) + b;
		}
	}
}
