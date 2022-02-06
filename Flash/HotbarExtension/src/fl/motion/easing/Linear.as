package fl.motion.easing
{
	public class Linear
	{
		public function Linear()
		{
			super();
		}
		
		public static function easeNone(a:Number, b:Number, c:Number, d:Number) : Number
		{
			return c * a / d + b;
		}
		
		public static function easeIn(a:Number, b:Number, c:Number, d:Number) : Number
		{
			return c * a / d + b;
		}
		
		public static function easeOut(a:Number, b:Number, c:Number, d:Number) : Number
		{
			return c * a / d + b;
		}
		
		public static function easeInOut(a:Number, b:Number, c:Number, d:Number) : Number
		{
			return c * a / d + b;
		}
	}
}
