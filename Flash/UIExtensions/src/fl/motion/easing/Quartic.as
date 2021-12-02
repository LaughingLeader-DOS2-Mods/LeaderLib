package fl.motion.easing
{
	public class Quartic
	{
		public function Quartic()
		{
			super();
		}
		
		public static function easeIn(a:Number, b:Number, c:Number, d:Number) : Number
		{
			return c * (a = a / d) * a * a * a + b;
		}
		
		public static function easeOut(a:Number, b:Number, c:Number, d:Number) : Number
		{
			return -c * ((a = a / d - 1) * a * a * a - 1) + b;
		}
		
		public static function easeInOut(a:Number, b:Number, c:Number, d:Number) : Number
		{
			if((a = a / (d / 2)) < 1)
			{
				return c / 2 * a * a * a * a + b;
			}
			return -c / 2 * ((a = a - 2) * a * a * a - 2) + b;
		}
	}
}
