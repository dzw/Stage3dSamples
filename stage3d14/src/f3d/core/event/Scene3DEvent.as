package f3d.core.event {

	import flash.events.Event;

	public class Scene3DEvent extends Event {

		/** 不支持该profile */
		public static const UNSUPORT_PROFILE 	: String = "UNSUPORT_PROFILE";
		/** 软解模式 */
		public static const SOFTWARE 			: String = "SOFTWARE";
		/** 创建完成 */
		public static const CREATE   			: String = Event.CONTEXT3D_CREATE;
		/** context被销毁 */
		public static const DISPOSED 			: String = "DISPOSED";
		/** enterframe事件 */
		public static const ENTER_FRAME 		: String = "ENTER_FRAME";
		/** exit frame事件 */
		public static const EXIT_FRAME 			: String = "EXIT_FRAME";
		/** pre render */
		public static const PRE_RENDER 			: String = "PRE_RENDER";
		/** post render */
		public static const POST_RENDER 		: String = "POST_RENDER";
		/** render */
		public static const RENDER				: String = "RENDER";
		
		public function Scene3DEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}
