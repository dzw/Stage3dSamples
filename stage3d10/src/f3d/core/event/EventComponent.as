package f3d.core.event {

	import flash.events.Event;
	
	/**
	 * 组件事件 
	 * @author Neil
	 * 
	 */	
	public class EventComponent extends Event {
		
		/** 启用组件 */
		public static const ENABLE 	: String = "ENABLE";
		/** disable */
		public static const DISABLE : String = "DISABLE";
		
		public function EventComponent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}
		
	}
}
