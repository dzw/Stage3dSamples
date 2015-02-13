package f3d.core.event {

	import flash.events.Event;
	
	public class LensEvent extends Event {
		
		public static const PROJECTION_UPDATE : String = "PROJECTION_UPDATE";
		
		public function LensEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super(type, bubbles, cancelable);
		}
	}
}
