package ide.events {

	import flash.events.Event;

	public class SceneEvent extends Event {

		public static const INVALIDATE 			: String = "scene:invalidate";
		public static const CHANGE 				: String = "scene:change";
		public static const UPDATE_EVENT 		: String = "scene:updateEvent";
		public static const PRE_RENDER_EVENT	: String = "scene:preRenderEvent";
		public static const RENDER_EVENT 		: String = "scene:renderEvent";
		public static const POST_RENDER_EVENT 	: String = "scene:postEvent";
		public static const OVERLAY_RENDER_EVENT: String = "scene:overlayRenderEvent";
		public static const RENDER_QUEUE 		: String = "scene:renderQueue";

		public function SceneEvent(type : String) {
			super(type, false, false);
		}
		
		override public function clone() : Event {
			return new SceneEvent(type);
		}
		
		override public function toString() : String {
			return formatToString("SceneEvent", "type");
		}

	}
}
