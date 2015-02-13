package f3d.core.utils {
	import flash.utils.getTimer;

	public class Time3D {
		
		/** 上一帧时间 */
		private static var lastTime : int = 0;
		/** 当前时间 */
		private static var currTime : int = 0;
		
		private static var _deltaTime : int = 0;		// 帧频
		private static var _totalTime : int = 0;		// 总时间
		
		public function Time3D() {
			
		}
		
		public static function update() : void {
			currTime = getTimer();
			_deltaTime = currTime - lastTime;
			lastTime = currTime;			
			_totalTime += _deltaTime;
		}
		
		/**
		 * 获取deltaTime 
		 * @return 
		 * 
		 */		
		public static function get deltaTime() : int {
			return _deltaTime;
		}
		
		public static function get totalTime() : int {
			return _totalTime;
		}
		
	}
}
