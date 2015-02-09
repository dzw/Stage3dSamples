package f3d.core.event {

	import flash.events.Event;

	public class Object3DEvent extends Event {
		
		/** 开始绘制 */
		public static const ENTER_DRAW : String = "ENTER_DRAW";
		/** 退出draw */
		public static const EXIT_DRAW : String  = "EXIT_DRAW";
		
		public function Object3DEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
	}
}
